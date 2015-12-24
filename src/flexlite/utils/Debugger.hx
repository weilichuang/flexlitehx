package flexlite.utils;



import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.System;
import flash.ui.Keyboard;
import flash.utils.DescribeType;


import flexlite.collections.XMLCollection;
import flexlite.components.Group;
import flexlite.components.Label;
import flexlite.components.RadioButton;
import flexlite.components.RadioButtonGroup;
import flexlite.components.TitleWindow;
import flexlite.components.ToggleButton;
import flexlite.components.Tree;
import flexlite.core.UIComponent;
import flexlite.events.CloseEvent;
import flexlite.events.TreeEvent;
import flexlite.events.UIEvent;
import flexlite.skins.vector.HScrollBarSkin;
import flexlite.skins.vector.ListSkin;
import flexlite.skins.vector.RadioButtonSkin;
import flexlite.skins.vector.ScrollerSkin;
import flexlite.skins.vector.TitleWindowSkin;
import flexlite.skins.vector.ToggleButtonSkin;
import flexlite.skins.vector.TreeItemRendererSkin;
import flexlite.skins.vector.VScrollBarSkin;


/**
* 运行时显示列表调试工具。
* 快捷键：F11开启或关闭调试;F12开启或结束选择;F2复制选中的属性名;F3复制选中属性值;
* F5:最大化或还原属性窗口;F6:设置选中节点为浏览树的根
* @author weilichuang
*/
class Debugger extends Group
{
    /**
	* 初始化调试工具
	* @param stage 舞台引用
	*/
    public static function initialize(stage : Stage) : Void
    {
        if (stage == null) 
            return;
        new Debugger(stage);
    }
    /**
	* 构造函数
	*/
    public function new(stage : Stage)
    {
        super();
        mouseEnabled = false;
        mouseEnabledWhereTransparent = false;
        appStage = stage;
        appStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        addEventListener(MouseEvent.MOUSE_WHEEL, mouseEventHandler, true, 1000);
    }
    
    /**
	* 过滤鼠标事件为可以取消的
	*/
    private function mouseEventHandler(e : MouseEvent) : Void
    {
        if (!e.cancelable && e.eventPhase != EventPhase.BUBBLING_PHASE) 
        {
            e.stopImmediatePropagation();
            var cancelableEvent : MouseEvent = new MouseEvent(e.type, e.bubbles, true, e.localX, 
            e.localY, e.relatedObject, e.ctrlKey, e.altKey, 
            e.shiftKey, e.buttonDown, e.delta);
            e.target.dispatchEvent(cancelableEvent);
        }
    }
    
    private var window : TitleWindow = new TitleWindow();
    private var targetLabel : Label = new Label();
    private var rectLabel : Label = new Label();
    private var selectBtn : ToggleButton = new ToggleButton();
    private var selectMode : RadioButtonGroup = new RadioButtonGroup();
    private var infoTree : Tree = new Tree();
    private var hasInitialized : Bool = false;
    /**
	* 初始化
	*/
    private function init() : Void
    {
        window.skinName = TitleWindowSkin;
        window.isPopUp = true;
        window.width = 250;
        window.addEventListener(CloseEvent.CLOSE, close);
        window.title = "显示列表";
        targetLabel.text = "";
        targetLabel.y = 48;
        rectLabel.y = 30;
        window.addElement(targetLabel);
        window.addElement(rectLabel);
        window.addEventListener(UIEvent.CREATION_COMPLETE, onWindowComp);
        selectBtn.label = "开启选择";
        selectBtn.y = 5;
        selectBtn.x = 3;
        selectBtn.selected = true;
        selectBtn.skinName = ToggleButtonSkin;
        selectBtn.addEventListener(Event.CHANGE, onSelectedChange);
        window.addElement(selectBtn);
        var label : Label = new Label();
        label.text = "模式:";
        label.y = 8;
        label.x = 75;
        window.addElement(label);
        var displayRadio : RadioButton = new RadioButton();
        displayRadio.group = selectMode;
        displayRadio.skinName = RadioButtonSkin;
        displayRadio.x = 110;
        displayRadio.y = 5;
        displayRadio.selected = true;
        displayRadio.label = "显示列表";
        window.addElement(displayRadio);
        var mouseRadio : RadioButton = new RadioButton();
        mouseRadio.skinName = RadioButtonSkin;
        mouseRadio.group = selectMode;
        mouseRadio.x = 180;
        mouseRadio.y = 5;
        mouseRadio.label = "鼠标事件";
        window.addElement(mouseRadio);
        selectMode.addEventListener(Event.CHANGE, onSelectModeChange);
        infoTree.skinName = ListSkin;
        infoTree.left = 0;
        infoTree.right = 0;
        infoTree.top = 66;
        infoTree.bottom = 0;
        infoTree.minHeight = 200;
        infoTree.dataProvider = infoDp;
        infoTree.labelFunction = labelFunc;
        infoTree.addEventListener(TreeEvent.ITEM_OPENING, onTreeOpening);
        infoTree.addEventListener(UIEvent.CREATION_COMPLETE, onTreeComp);
        infoTree.doubleClickEnabled = true;
        infoTree.addEventListener(MouseEvent.DOUBLE_CLICK, onTreeDoubleClick);
        window.addElement(infoTree);
        addElement(window);
    }
    /**
	* 双击一个节点
	*/
    private function onTreeDoubleClick(event : MouseEvent) : Void
    {
        var item : FastXML = infoTree.selectedItem;
        if (item == null || item.node.children.innerData().length() == 0) 
            return;
        var target : DisplayObject = cast(getTargetByItem(item), DisplayObject);
        if (target != null) 
        {
            currentTarget = target;
            infoDp.source = describe(currentTarget);
            invalidateDisplayList();
        }
    }
    /**
	* 选择模式发生改变
	*/
    private function onSelectModeChange(event : Event) : Void
    {
        if (selectMode.selectedValue == "鼠标事件") 
        {
            appStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            appStage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            appStage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        else 
        {
            appStage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            appStage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
            appStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        selectBtn.selected = true;
        onSelectedChange();
    }
    /**
	* 树列表创建完成
	*/
    private function onTreeComp(event : UIEvent) : Void
    {
        infoTree.removeEventListener(UIEvent.CREATION_COMPLETE, onTreeComp);
        infoTree.dataGroup.itemRendererSkinName = TreeItemRendererSkin;
        (Lib.as(infoTree.skin, ListSkin)).scroller.skinName = ScrollerSkin;
        (Lib.as(infoTree.skin, ListSkin)).scroller.verticalScrollBar.skinName = VScrollBarSkin;
        (Lib.as(infoTree.skin, ListSkin)).scroller.horizontalScrollBar.skinName = HScrollBarSkin;
    }
    /**
	* 即将打开树的一个节点,生成子节点内容。
	*/
    private function onTreeOpening(event : TreeEvent) : Void
    {
        if (!event.opening) 
            return;
        var item : FastXML = cast(event.item, FastXML);
        if (item.node.children.innerData().length() == 1 &&
            item.nodes.children()[0].localName() == "child") 
        {
            var target : Dynamic = getTargetByItem(item);
            if (target != null) 
            {
                item.node.setChildren.innerData(describe(target).children());
            }
        }
    }
    /**
	* 根据xml节点获取对应的对象引用
	*/
    private function getTargetByItem(item : FastXML) : Dynamic
    {
        var keys : Array<Dynamic> = [Std.string(item.att.key)];
        var parent : FastXML = item.node.parent.innerData();
        while (parent && parent.node.parent.innerData())
        {
            if (parent.node.localName.innerData() != "others") 
                keys.push(Std.string(parent.att.key));
            parent = parent.node.parent.innerData();
        }
        var target : Dynamic = currentTarget;
        try
        {
            while (keys.length > 0)
            {
                var key : String = keys.pop();
                if (key.substr(0, 8) == "children") 
                {
                    var index : Int = Std.int(key.substring(9, key.length - 1));
                    target = cast((target), DisplayObjectContainer).getChildAt(index);
                }
                else 
                {
                    if (key.charAt(0) == "[" && key.charAt(key.length - 1) == "]") 
                    {
                        index = Std.int(key.substring(9, key.length - 1));
                        target = target[index];
                    }
                    else 
                    {
                        target = Reflect.field(target, key);
                    }
                }
            }
        }        catch (e : Error)
        {
            return null;
        }
        return target;
    }
    /**
	* 树列表项显示文本格式化函数
	*/
    private function labelFunc(item : Dynamic) : String
    {
        if (item.exists("@value")) 
            return item.att.key + " : " + item.att.value;
        return item.att.key;
    }
    
    private function onSelectedChange(event : Event = null) : Void
    {
        if (selectBtn.selected) 
        {
            currentTarget = null;
            mouseEnabled = false;
            infoDp.source = null;
            invalidateDisplayList();
        }
    }
    /**
	* 窗口创建完成
	*/
    private function onWindowComp(event : Event) : Void
    {
        window.removeEventListener(UIEvent.CREATION_COMPLETE, onWindowComp);
        window.moveArea.doubleClickEnabled = true;
        window.moveArea.addEventListener(MouseEvent.DOUBLE_CLICK, onWindowDoubleClick);
    }
    
    private var oldX : Float;
    private var oldY : Float;
    private var oldWidth : Float;
    private var oldHeight : Float;
    /**
	* 双击窗口放大或还原
	*/
    private function onWindowDoubleClick(event : MouseEvent = null) : Void
    {
        window.isPopUp = !window.isPopUp;
        if (window.isPopUp) 
        {
            window.x = oldX;
            window.y = oldY;
            window.width = oldWidth;
            window.height = oldHeight;
        }
        else 
        {
            oldX = window.x;
            oldY = window.y;
            oldWidth = window.width;
            oldHeight = window.height;
            window.x = 0;
            window.y = 0;
            window.width = width;
            window.height = height;
        }
    }
    /**
	* 舞台引用
	*/
    private var appStage : Stage;
    /**
	* 键盘事件
	*/
    private function onKeyDown(event : KeyboardEvent) : Void
    {
        if (event.keyCode == Keyboard.F11) 
        {
            if (parent) 
            {
                close();
            }
            else 
            {
                show();
            }
        }
        if (!parent) 
            return;
        if (event.keyCode == Keyboard.F5) 
        {
            onWindowDoubleClick();
        }
        else if (!currentTarget) 
        {
            return;
        }
        else if (event.keyCode == Keyboard.F2) 
        {
            var item : FastXML = cast(infoTree.selectedItem, FastXML);
            if (item != null) 
            {
                System.setClipboard(Std.string(item.att.key));
            }
        }
        else if (event.keyCode == Keyboard.F3) 
        {
            item = cast(infoTree.selectedItem, FastXML);
            if (item != null) 
            {
                System.setClipboard(Std.string(item.att.value));
            }
        }
        else if (event.keyCode == Keyboard.F12) 
        {
            if (selectBtn.selected) 
            {
                selectBtn.selected = false;
                mouseEnabled = true;
                infoDp.source = describe(currentTarget);
            }
            else 
            {
                selectBtn.selected = true;
                onSelectedChange();
                mouseMoved = true;
                invalidateProperties();
            }
        }
        else if (event.keyCode == Keyboard.F6) 
        {
            if (!selectBtn.selected) 
            {
                changeCurrentTarget();
            }
        }
    }
    /**
	* 设置当前选中节点为根节点
	*/
    private function changeCurrentTarget() : Void
    {
        var item : FastXML = infoTree.selectedItem;
        var target : DisplayObject;
        while (item)
        {
            if (item.node.children.innerData().length() > 0) 
            {
                target = cast(getTargetByItem(item), DisplayObject);
                if (target != null) 
                {
                    currentTarget = target;
                    infoDp.source = describe(currentTarget);
                    invalidateDisplayList();
                    break;
                }
            }
            item = item.node.parent.innerData();
        }
    }
    
    /**
	* 显示
	*/
    private function show() : Void
    {
        if (!hasInitialized) 
        {
            hasInitialized = true;
            init();
        }
        var list : Array<Dynamic> = appStage.getObjectsUnderPoint(new Point(appStage.mouseX, appStage.mouseY));
        if (list.length > 0) 
        {
            currentTarget = list[list.length - 1];
        }
        appStage.addChild(this);
        invalidateDisplayList();
        appStage.addEventListener(Event.ADDED, onAdded);
        appStage.addEventListener(Event.RESIZE, onResize);
        appStage.addEventListener(FullScreenEvent.FULL_SCREEN, onResize);
        if (selectMode.selectedValue == "鼠标事件") 
        {
            appStage.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
            appStage.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        }
        else 
        {
            appStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        appStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        onResize();
        window.x = width - window.width;
    }
    
    /**
	* 关闭
	*/
    private function close(event : Event = null) : Void
    {
        stage.focus = cast(root, InteractiveObject);
        if (parent) 
            parent.removeChild(this);
        currentTarget = null;
        infoDp.source = null;
        selectBtn.selected = true;
        mouseEnabled = false;
        appStage.removeEventListener(Event.ADDED, onAdded);
        appStage.removeEventListener(Event.RESIZE, onResize);
        appStage.removeEventListener(FullScreenEvent.FULL_SCREEN, onResize);
        appStage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        appStage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
        appStage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
        appStage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }
    /**
	* stage子项发生改变
	*/
    private function onAdded(event : Event) : Void
    {
        if (parent.getChildIndex(this) != parent.numChildren - 1) 
            parent.addChild(this);
    }
    
    /**
	* 舞台尺寸改变
	*/
    private function onResize(event : Event = null) : Void
    {
        width = stage.stageWidth;
        height = stage.stageHeight;
        if (!window.isPopUp) 
        {
            window.width = width;
            window.height = height;
        }
        window.maxHeight = height;
    }
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (mouseMoved) 
        {
            mouseMoved = false;
            var target : DisplayObject;
            if (!window.hitTestPoint(appStage.mouseX, appStage.mouseY)
                && appStage.numChildren > 1) 
            {
                var i : Int = appStage.numChildren - 2;
                while (i >= 0){
                    var dp : DisplayObject = appStage.getChildAt(i);
                    if (!dp.hitTestPoint(appStage.mouseX, appStage.mouseY, true)) 
                        {i--;continue;
                    };
                    target = dp;
                    if (Std.is(dp, DisplayObjectContainer)) 
                    {
                        var list : Array<Dynamic> = cast((dp), DisplayObjectContainer).getObjectsUnderPoint(new Point(appStage.mouseX, appStage.mouseY));
                        if (list.length > 0) 
                        {
                            target = list[list.length - 1];
                        }
                    }
                    if (target != null) 
                        break;
                    i--;
                }
            }
            
            if (currentTarget != target) 
            {
                currentTarget = target;
                invalidateDisplayList();
            }
        }
    }
    
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        var g : Graphics = graphics;
        g.clear();
        g.beginFill(0, 0.2);
        g.drawRect(0, 0, w, h);
        if (currentTarget) 
        {
            var pos : Point = currentTarget.localToGlobal(new Point());
            var className : String = Type.getClassName(currentTarget);
            targetLabel.text = "对象:";
            if (className.indexOf("::") != -1) 
                targetLabel.text += className.split("::")[1]
            else 
            targetLabel.text += className;
            targetLabel.text += "#" + currentTarget.name + " : [" + className + "]";
            rectLabel.text = "区域:[" + pos.x + "," + pos.y + "," + currentTarget.width + "," + currentTarget.height + "]";
            g.drawRect(pos.x, pos.y, currentTarget.width, currentTarget.height);
            g.endFill();
            g.beginFill(0x009aff, 0);
            g.lineStyle(1, 0xff0000);
            g.drawRect(pos.x, pos.y, currentTarget.width, currentTarget.height);
        }
        else 
        {
            targetLabel.text = "对象:";
            rectLabel.text = "区域:";
        }
        g.endFill();
    }
    /**
	* 当前鼠标下的对象
	*/
    private var currentTarget : DisplayObject;
    /**
	* 鼠标移动过的标志
	*/
    private var mouseMoved : Bool = false;
    /**
	* 鼠标移动
	*/
    private function onMouseMove(event : MouseEvent) : Void
    {
        if (mouseMoved || !selectBtn.selected) 
            return;
        mouseMoved = true;
        invalidateProperties();
    }
    
    /**
	* 鼠标经过
	*/
    private function onMouseOver(event : MouseEvent) : Void
    {
        if (!selectBtn.selected || contains(cast(event.target, DisplayObject))) 
            return;
        currentTarget = cast(event.target, DisplayObject);
        
        invalidateDisplayList();
    }
    
    private function onMouseOut(event : MouseEvent) : Void
    {
        if (!selectBtn.selected || contains(cast(event.target, DisplayObject))) 
            return;
        currentTarget = null;
        invalidateDisplayList();
    }
    
    private var infoDp : XMLCollection = new XMLCollection();
    private function onMouseDown(event : MouseEvent) : Void
    {
        if (!selectBtn.selected) 
            return;
        if (currentTarget != null) 
        {
            selectBtn.selected = false;
            mouseEnabled = true;
            infoDp.source = describe(currentTarget);
        }
    }
    private function describe(target : Dynamic) : FastXML
    {
        var xml : FastXML = FastXML.parse("<root/>");
        var items : Array<Dynamic> = [];
        try
        {
            var type : String = Type.getClassName(target);
        }        catch (e : Error){ };
        if (type == "Array") 
        {
            var length : Int = cast(target, Array).length;
            for (i in 0...length){
                var childValue : Dynamic = target[i];
                item = FastXML.parse("<item></item>");
                item.setAttribute("key", "[" + i + "]") = "[" + i + "]";
                try
                {
                    type = Type.getClassName(childValue);
                    if (childValue == null || childValue == null ||
                        basicTypes.indexOf(type) != -1) 
                        item.setAttribute("value", childValue)
                    else 
                    {
                        item.setAttribute("value", "[" + type + "]") = "[" + type + "]";
                        item.appendChild(FastXML.parse("<child/>"));
                    }
                }                catch (e : Error){ };
                xml.node.appendChild.innerData(item);
            }
            return xml;
        }
        else if (type == "Object") 
        {
            for (key in Reflect.fields(target))
            {
                item = FastXML.parse("<item/>");
                item.setAttribute("key", key);
                try
                {
                    type = Type.getClassName(Reflect.field(target, key));
                    if (Reflect.field(target, key) == null || Reflect.field(target, key) == null ||
                        basicTypes.indexOf(type) != -1) 
                        item.setAttribute("value", Reflect.setField(target, key, ))
                    else 
                    {
                        item.setAttribute("value", "[" + type + "]") = "[" + type + "]";
                        item.appendChild(FastXML.parse("<child/>"));
                    }
                }                catch (e : Error){ };
                items.push(item);
            }
            items.sortOn("@key");
            while (items.length > 0)
            {
                xml.node.appendChild.innerData(items.shift());
            }
            return xml;
        }
        var info : FastXML = describeType(target);
        var others : Array<Dynamic> = [];
        var children : Array<Dynamic> = [];
        var parent : FastXML;
        var childXMLList : FastXMLList = info.node.variable.innerData + info.node.accessor.innerData;
        for (node in childXMLList)
        {
            if (node.att.access == "writeonly") 
                continue;
            var item : FastXML = FastXML.parse("<item/>");
            key = Std.string(node.att.name);
            if (key == "stage") 
                continue;
            item.setAttribute("key", key);
            if (layoutProps.indexOf(key) == -1) 
                others.push(item)
            else if (key == "parent") 
                parent = item
            else 
            items.push(item);
            try
            {
                type = Type.getClassName(target[key]);
            }            catch (e : Error){ };
            try
            {
                if (target[key] == null || target[key] == null ||
                    basicTypes.indexOf(type) != -1) 
                    item.setAttribute("value", target[key])
                else 
                {
                    item.setAttribute("value", "[" + type + "]") = "[" + type + "]";
                    item.node.appendChild.innerData(FastXML.parse("<child/>"));
                }
            }            catch (e : Error){ };
        }
        if (Std.is(target, DisplayObjectContainer)) 
        {
            var dc : DisplayObjectContainer = cast((target), DisplayObjectContainer);
            var numChildren : Int = dc.numChildren;
            for (i in 0...numChildren){
                var child : DisplayObject = dc.getChildAt(i);
                item = FastXML.parse("<item><child/></item>");
                item.setAttribute("key", "children[" + i + "]") = "children[" + i + "]";
                try
                {
                    item.setAttribute("value", "[" + Type.getClassName(child) + "]") = "[" + Type.getClassName(child) + "]";
                }                catch (e : Error){ };
                children.push(item);
            }
        }
        if (children.length > 0) 
        {
            while (children.length > 0)
            {
                xml.node.appendChild.innerData(children.shift());
            }
        }
        if (parent != null) 
        {
            xml.node.appendChild.innerData(parent);
        }
        items.sortOn("@key");
        others.sortOn("@key");
        if (items.length == 0) 
        {
            items = others;
            others = [];
        }
        else if (!(Std.is(target, DisplayObject))) 
        {
            items = items.concat(others);
            others = [];
        }
        if (others.length > 0) 
        {
            var other : FastXML = FastXML.parse("<others key=\"其他属性\"/>");
            while (others.length > 0)
            {
                other.node.appendChild.innerData(others.shift());
            }
            xml.node.appendChild.innerData(other);
        }
        while (items.length > 0)
        {
            xml.node.appendChild.innerData(items.shift());
        }
        
        return xml;
    }
    
    private var layoutProps : Array<String> = 
        ["x", "y", "width", "height", "measuredWidth", "measuredHeight", 
                "layoutBoundsWidth", "layoutBoundsHeight", "preferredWidth", "preferredHeight", 
                "left", "right", "top", "bottom", "percentWidth", "percentHeight", "verticalCenter", 
                "horizontalCenter", "explicitWidth", "explicitHeight", "margin", "padding", "paddingTop", "paddingLeft", 
                "paddingRight", "paddingBottom", "includeInLayout", "preferredX", "preferredY", 
                "layoutBoundsX", "layoutBoundsY", "scaleX", "scaleY", "maxWidth", "minWidth", 
                "maxHeight", "minHeight", "visible", "alpha", "parent", "skinName", "skin", "enabled", 
                "initialized", "isPopUp", "mouseEnabled", "mouseChildren", "focusEnabled"];
    /**
	* 基本数据类型列表
	*/
    private var basicTypes : Array<String> = 
        ["Number", "int", "String", "Boolean", "uint"];
}
