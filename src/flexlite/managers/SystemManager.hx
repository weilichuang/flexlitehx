package flexlite.managers;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.EventPhase;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Keyboard;
import flexlite.components.Group;
import flexlite.core.FlexLiteGlobals;
import flexlite.core.IContainer;
import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.layouts.supportclasses.LayoutBase;
import flexlite.layouts.BasicLayout;






/**
* 系统管理器，应用程序顶级容器。
* 通常情况下，一个程序应该只含有唯一的系统管理器,并且所有的组件都包含在它内部。
* 它负责管理弹窗，鼠标样式，工具提示的显示层级，以及过滤鼠标和键盘事件为可以取消的。
* @author weilichuang
*/
class SystemManager extends Group implements ISystemManager
{
    public var autoResize(get, set) : Bool;
    public var popUpContainer(get, never) : IContainer;
    public var toolTipContainer(get, never) : IContainer;
    public var cursorContainer(get, never) : IContainer;
    private var noTopMostIndex(get, set) : Int;
    private var topMostIndex(get, set) : Int;
    private var toolTipIndex(get, set) : Int;
    private var cursorIndex(get, set) : Int;
    private var raw_numElements(get, never) : Int;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        mouseEnabledWhereTransparent = false;
        addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
        addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
        addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, 1000);
        addEventListener(MouseEvent.MOUSE_WHEEL, mouseEventHandler, true, 1000);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler, true, 1000);
    }
    /**
	* 添加到舞台
	*/
    private function onAddToStage(event : Event) : Void
    {
        var systemManagers : Array<ISystemManager> = FlexLiteGlobals._systemManagers;
        if (systemManagers.length == 0) 
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.stageFocusRect = false;
        }
		
        var index : Int = systemManagers.indexOf(this);
        if (index == -1) 
            systemManagers.push(this);

        if (_autoResize) 
        {
            stage.addEventListener(Event.RESIZE, onResize);
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, onResize);
            onResize();
        }
    }
    /**
	* 从舞台移除
	*/
    private function onRemoveFromStage(event : Event) : Void
    {
        var systemManagers : Array<ISystemManager> = FlexLiteGlobals._systemManagers;
        var index : Int = systemManagers.indexOf(this);
        if (index != -1) 
            systemManagers.splice(index, 1);
        if (_autoResize) 
        {
            stage.removeEventListener(Event.RESIZE, onResize);
            stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onResize);
        }
    }
    
    /**
	* 舞台尺寸改变
	*/
    private function onResize(event : Event = null) : Void
    {
        super.width = stage.stageWidth;
        super.height = stage.stageHeight;
    }
    /**
	* @inheritDoc
	*/
    override public function addEventListener(type : String, listener : Dynamic->Void,
            useCapture : Bool = false,
            priority : Int = 0,
            useWeakReference : Bool = true) : Void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    /**
	* 过滤鼠标事件为可以取消的
	*/
    private function mouseEventHandler(e : MouseEvent) : Void
    {
        if (!e.cancelable && e.eventPhase != EventPhase.BUBBLING_PHASE) 
        {
            e.stopImmediatePropagation();
            var cancelableEvent : MouseEvent = null;
            if (Reflect.hasField(e,"clickCount"))
            {
                var mouseEventClass : Class<Dynamic> = MouseEvent;
                
                cancelableEvent = Type.createInstance(mouseEventClass, [e.type, e.bubbles, true, e.localX, 
                        e.localY, e.relatedObject, e.ctrlKey, e.altKey, 
                        e.shiftKey, e.buttonDown, e.delta, 
                        Reflect.field(e, "commandKey"), Reflect.field(e, "controlKey"), Reflect.field(e, "clickCount")]);
            }
            else 
            {
                cancelableEvent = new MouseEvent(e.type, e.bubbles, true, e.localX, 
                        e.localY, e.relatedObject, e.ctrlKey, e.altKey, 
                        e.shiftKey, e.buttonDown, e.delta);
            }
            
            e.target.dispatchEvent(cancelableEvent);
        }
    }
    
    /**
	* 过滤键盘事件为可以取消的
	*/
    private function keyDownHandler(e : KeyboardEvent) : Void
    {
        if (!e.cancelable) 
        {
            var _sw0_ = (e.keyCode);            

            switch (_sw0_)
            {
                case Keyboard.UP, Keyboard.DOWN, Keyboard.PAGE_UP, Keyboard.PAGE_DOWN, Keyboard.HOME, Keyboard.END, Keyboard.LEFT, Keyboard.RIGHT, Keyboard.ENTER:
                {
                    e.stopImmediatePropagation();
                    var cancelableEvent : KeyboardEvent = 
                    new KeyboardEvent(e.type, e.bubbles, true, e.charCode, e.keyCode, 
                    e.keyLocation, e.ctrlKey, e.altKey, e.shiftKey);
                    e.target.dispatchEvent(cancelableEvent);
                }
            }
        }
    }
    
    private var _autoResize : Bool = true;
    /**
	* 是否自动跟随舞台缩放。当此属性为true时，将强制让SystemManager始终与舞台保持相同大小。
	* 反之需要外部手动同步大小。默认值为true。
	*/
    private function get_autoResize() : Bool
    {
        return _autoResize;
    }
    
    private function set_autoResize(value : Bool) : Bool
    {
        if (_autoResize == value) 
            return value;
        _autoResize = value;
        if (stage == null) 
            return false;
        if (_autoResize) 
        {
            stage.addEventListener(Event.RESIZE, onResize);
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, onResize);
        }
        else 
        {
            stage.removeEventListener(Event.RESIZE, onResize);
            stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onResize);
        }
        return value;
    }
    
    //==========================================================================
    //                            禁止外部布局顶级容器
    //==========================================================================
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(x) override private function set_x(value : Float) : Void
    {
        if (_autoResize) 
            return;
        super.x = value;
    }
	#else
    override private function set_x(value : Float) : Float
    {
        if (_autoResize) 
            return value;
        super.x = value;
        return value;
    }
	#end
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(y) override private function set_y(value : Float) : Void
    {
        if (_autoResize) 
            return;
        super.y = value;
    }
	#else
    override private function set_y(value : Float) : Float
    {
        if (_autoResize) 
            return value;
        super.y = value;
        return value;
    }
	#end
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(width) override private function set_width(value : Float) : Void
    {
        if (_autoResize) 
            return;
        super.width = value;
    }
	#else
    override private function set_width(value : Float) : Float
    {
        if (_autoResize) 
            return value;
        super.width = value;
        return value;
    }
	#end

    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(height) override private function set_height(value : Float) : Void
    {
        if (_autoResize) 
            return;
        super.height = value;
    }
	#else
    override private function set_height(value : Float) : Float
    {
        if (_autoResize) 
            return value;
        super.height = value;
        return value;
    }
	#end
	
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(scaleX) override private function set_scaleX(value : Float) : Void
    {
        if (_autoResize) 
            return;
        super.scaleX = value;
    }
	#else
    override private function set_scaleX(value : Float) : Float
    {
        if (_autoResize) 
            return value;
        super.scaleX = value;
        return value;
    }
	#end

    /**
	* @inheritDoc
	*/
    #if flash
	@:setter(scaleY) override private function set_scaleY(value : Float) : Void
    {
        if (_autoResize) 
            return;
        super.scaleY = value;
    }
	#else
    override private function set_scaleY(value : Float) : Float
    {
        if (_autoResize) 
            return value;
        super.scaleY = value;
        return value;
    }
	#end
    /**
	* @inheritDoc
	*/
    override public function setActualSize(w : Float, h : Float) : Void
    {
        if (_autoResize) 
            return;
        super.setActualSize(w, h);
    }
    /**
	* @inheritDoc
	*/
    override public function setLayoutBoundsPosition(x : Float, y : Float) : Void
    {
        if (_autoResize) 
            return;
        super.setLayoutBoundsPosition(x, y);
    }
    /**
	* @inheritDoc
	*/
    override public function setLayoutBoundsSize(layoutWidth : Float, layoutHeight : Float) : Void
    {
        if (_autoResize) 
            return;
        super.setLayoutBoundsSize(layoutWidth, layoutHeight);
    }
    /**
	* 布局对象,SystemManager只接受BasicLayout
	*/
    override private function get_layout() : LayoutBase
    {
        return super.layout;
    }
    override private function set_layout(value : LayoutBase) : LayoutBase
    {
        if (Std.is(value, BasicLayout)) 
            super.layout = value;
        return value;
    }
    
    private var _popUpContainer : SystemContainer;
    /**
	* 弹出窗口层容器。
	*/
    private function get_popUpContainer() : IContainer
    {
        if (_popUpContainer == null) 
        {
            _popUpContainer = new SystemContainer(this,"noTopMostIndex","topMostIndex");
        }
        
        return _popUpContainer;
    }
    
    private var _toolTipContainer : SystemContainer;
    /**
	* 工具提示层容器。
	*/
    private function get_toolTipContainer() : IContainer
    {
        if (_toolTipContainer == null) 
        {
            _toolTipContainer = new SystemContainer(this,"topMostIndex","toolTipIndex");
        }
        
        return _toolTipContainer;
    }
    
    private var _cursorContainer : SystemContainer;
    /**
	* 鼠标样式层容器。
	*/
    private function get_cursorContainer() : IContainer
    {
        if (_cursorContainer == null) 
        {
            _cursorContainer = new SystemContainer(this,"toolTipIndex","cursorIndex");
        }
        
        return _cursorContainer;
    }
    
    private var _noTopMostIndex : Int = 0;
    /**
	* 弹出窗口层的起始索引(包括)
	*/
    private function get_noTopMostIndex() : Int
    {
        return _noTopMostIndex;
    }
    
    private function set_noTopMostIndex(value : Int) : Int
    {
        var delta : Int = value - _noTopMostIndex;
        _noTopMostIndex = value;
        topMostIndex += delta;
        return value;
    }
    
    private var _topMostIndex : Int = 0;
    /**
	* 弹出窗口层结束索引(不包括)
	*/
    private function get_topMostIndex() : Int
    {
        return _topMostIndex;
    }
    
    private function set_topMostIndex(value : Int) : Int
    {
        var delta : Int = value - _topMostIndex;
        _topMostIndex = value;
        toolTipIndex += delta;
        return value;
    }
    
    private var _toolTipIndex : Int = 0;
    /**
	* 工具提示层结束索引(不包括)
	*/
    private function get_toolTipIndex() : Int
    {
        return _toolTipIndex;
    }
    
    private function set_toolTipIndex(value : Int) : Int
    {
        var delta : Int = value - _toolTipIndex;
        _toolTipIndex = value;
        cursorIndex += delta;
        return value;
    }
    
    private var _cursorIndex : Int = 0;
    /**
	* 鼠标样式层结束索引(不包括)
	*/
    private function get_cursorIndex() : Int
    {
        return _cursorIndex;
    }
    
    private function set_cursorIndex(value : Int) : Int
    {
        var delta : Int = value - _cursorIndex;
        _cursorIndex = value;
        return value;
    }
    
    //==========================================================================
    //                                复写容器操作方法
    //==========================================================================
    /**
	* @inheritDoc
	*/
    override public function addElement(element : IVisualElement) : IVisualElement
    {
        var addIndex : Int = _noTopMostIndex;
        if (element.parent == this) 
            addIndex--;
        return addElementAt(element, addIndex);
    }
    
    /**
	* @inheritDoc
	*/
    override public function addElementAt(element : IVisualElement, index : Int) : IVisualElement
    {
        if (element.parent == this) 
        {
            var oldIndex : Int = getElementIndex(element);
            if (oldIndex < _noTopMostIndex) 
                noTopMostIndex--
            else if (oldIndex >= _noTopMostIndex && oldIndex < _topMostIndex) 
                topMostIndex--
            else if (oldIndex >= _topMostIndex && oldIndex < _toolTipIndex) 
                toolTipIndex--
            else 
            cursorIndex--;
        }
        
        if (index <= _noTopMostIndex) 
            noTopMostIndex++
        else if (index > _noTopMostIndex && index <= _topMostIndex) 
            topMostIndex++
        else if (index > _topMostIndex && index <= _toolTipIndex) 
            toolTipIndex++
        else 
        cursorIndex++;
        
        return super.addElementAt(element, index);
    }
    
    /**
	* @inheritDoc
	*/
    override public function removeElement(element : IVisualElement) : IVisualElement
    {
        return removeElementAt(super.getElementIndex(element));
    }
    
    /**
	* @inheritDoc
	*/
    override public function removeElementAt(index : Int) : IVisualElement
    {
        var element : IVisualElement = super.removeElementAt(index);
        if (index < _noTopMostIndex) 
            noTopMostIndex--
        else if (index >= _noTopMostIndex && index < _topMostIndex) 
            topMostIndex--
        else if (index >= _topMostIndex && index < _toolTipIndex) 
            toolTipIndex--
        else 
        cursorIndex--;
        return element;
    }
    
    /**
	* @inheritDoc
	*/
    override public function removeAllElements() : Void
    {
        while (_noTopMostIndex > 0)
        {
            super.removeElementAt(0);
            noTopMostIndex--;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function containsElement(element : IVisualElement) : Bool
    {
        if (super.containsElement(element)) 
        {
            if (element.parent == this) 
            {
                var elementIndex : Int = super.getElementIndex(element);
                if (elementIndex < _noTopMostIndex) 
                    return true;
            }
            else 
            {
                for (i in 0..._noTopMostIndex){
                    var myChild : IVisualElement = super.getElementAt(i);
                    if (Std.is(myChild, IVisualElementContainer)) 
                    {
                        if (Lib.as(myChild, IVisualElementContainer).containsElement(element)) 
                            return true;
                    }
                }
            }
        }
        return false;
    }
    
    
    override private function elementRemoved(element : IVisualElement, index : Int, notifyListeners : Bool = true) : Void
    {
        if (notifyListeners) 
        {
            //PopUpManager需要监听这个事件
            element.dispatchEvent(new Event("removeFromSystemManager"));
        }
        super.elementRemoved(element, index, notifyListeners);
    }
    
    //==========================================================================
    //                                保留容器原始操作方法
    //==========================================================================
    public function get_raw_numElements() : Int
    {
        return super.numElements;
    }
    public function raw_getElementAt(index : Int) : IVisualElement
    {
        return super.getElementAt(index);
    }
    public function raw_addElement(element : IVisualElement) : IVisualElement
    {
        var index : Int = super.numElements;
        if (element.parent == this) 
            index--;
        return raw_addElementAt(element, index);
    }
    public function raw_addElementAt(element : IVisualElement, index : Int) : IVisualElement
    {
        if (element.parent == this) 
        {
            var oldIndex : Int = getElementIndex(element);
            if (oldIndex < _noTopMostIndex) 
                noTopMostIndex--
            else if (oldIndex >= _noTopMostIndex && oldIndex < _topMostIndex) 
                topMostIndex--
            else if (oldIndex >= _topMostIndex && oldIndex < _toolTipIndex) 
                toolTipIndex--
            else 
				cursorIndex--;
        }
        return super.addElementAt(element, index);
    }
    public function raw_removeElement(element : IVisualElement) : IVisualElement
    {
        return super.removeElementAt(super.getElementIndex(element));
    }
    public function raw_removeElementAt(index : Int) : IVisualElement
    {
        return super.removeElementAt(index);
    }
    public function raw_removeAllElements() : Void
    {
        while (super.numElements > 0)
        {
            super.removeElementAt(0);
        }
    }
    public function raw_getElementIndex(element : IVisualElement) : Int
    {
        return super.getElementIndex(element);
    }
    public function raw_setElementIndex(element : IVisualElement, index : Int) : Void
    {
        super.setElementIndex(element, index);
    }
    public function raw_swapElements(element1 : IVisualElement, element2 : IVisualElement) : Void
    {
        super.swapElementsAt(super.getElementIndex(element1), super.getElementIndex(element2));
    }
    public function raw_swapElementsAt(index1 : Int, index2 : Int) : Void
    {
        super.swapElementsAt(index1, index2);
    }
    public function raw_containsElement(element : IVisualElement) : Bool
    {
        return super.containsElement(element);
    }
}
