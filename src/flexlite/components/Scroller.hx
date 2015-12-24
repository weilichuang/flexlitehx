package flexlite.components;

import flash.Lib;
import flexlite.components.SkinnableComponent;
import flexlite.components.VScrollBar;
import flexlite.utils.MathUtil;

import flash.events.Event;
import flash.events.MouseEvent;


import flexlite.components.supportclasses.ScrollerLayout;
import flexlite.core.IInvalidating;
import flexlite.core.IViewport;
import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.core.NavigationUnit;
import flexlite.events.PropertyChangeEvent;
import flexlite.layouts.supportclasses.LayoutBase;



@:meta(DXML(show="true"))


@:meta(DefaultProperty(name="viewport",array="false"))


/**
* 滚动条组件
* @author weilichuang
*/
class Scroller extends SkinnableComponent implements IVisualElementContainer
{
    public var layout(get, set) : LayoutBase;
    public var verticalScrollPolicy(get, set) : String;
    public var horizontalScrollPolicy(get, set) : String;
    public var viewport(get, set) : IViewport;
    public var useMouseWheelDelta(get, set) : Bool;
    public var minViewportInset(get, set) : Float;
    public var measuredSizeIncludesScrollBars(get, set) : Bool;
    public var numElements(get, never) : Int;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        focusEnabled = true;
    }
    
    private var _layout : LayoutBase;
    /**
	* 此容器的布局对象,若不设置，默认使用ScrollerLayout。
	*/
    private function get_layout() : LayoutBase
    {
        return _layout;
    }
    
    private function set_layout(value : LayoutBase) : LayoutBase
    {
        if (_layout == value) 
            return value;
        _layout = value;
        if (contentGroup != null) 
        {
            contentGroup.layout = _layout;
        }
        return value;
    }
    /**
	* 实体容器
	*/
    private var contentGroup : Group;
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        contentGroup = new Group();
        if (_layout == null) 
            _layout = new ScrollerLayout();
        contentGroup.layout = _layout;
        addToDisplayList(contentGroup);
        contentGroup.addEventListener(MouseEvent.MOUSE_WHEEL, contentGroup_mouseWheelHandler);
        super.createChildren();
    }
    /**
	* @inheritDoc
	*/
    override private function measure() : Void
    {
        measuredWidth = contentGroup.preferredWidth;
        measuredHeight = contentGroup.preferredHeight;
    }
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        contentGroup.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
    }
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return Scroller;
    }
    
    private var _verticalScrollPolicy : String = "auto";
    
    /**
	* 垂直滚动条显示策略，参见ScrollPolicy类定义的常量。
	*/
    private function get_verticalScrollPolicy() : String
    {
        return _verticalScrollPolicy;
    }
    
    private function set_verticalScrollPolicy(value : String) : String
    {
        if (_verticalScrollPolicy == value) 
            return value;
        _verticalScrollPolicy = value;
        invalidateSkin();
        return value;
    }
    
    private var _horizontalScrollPolicy : String = "auto";
    
    /**
	* 水平滚动条显示策略，参见ScrollPolicy类定义的常量。
	*/
    private function get_horizontalScrollPolicy() : String
    {
        return _horizontalScrollPolicy;
    }
    private function set_horizontalScrollPolicy(value : String) : String
    {
        if (_horizontalScrollPolicy == value) 
            return value;
        _horizontalScrollPolicy = value;
        invalidateSkin();
        return value;
    }
    
    /**
	* 标记皮肤需要更新尺寸和布局
	*/
    private function invalidateSkin() : Void
    {
        if (contentGroup != null) 
        {
            contentGroup.invalidateSize();
            contentGroup.invalidateDisplayList();
        }
    }
    
    /**
	* [SkinPart]水平滚动条
	*/
	@SkinPart
    public var horizontalScrollBar : HScrollBar;
    
    /**
	* [SkinPart]垂直滚动条
	*/
	@SkinPart
    public var verticalScrollBar : VScrollBar;
    
    private var _viewport : IViewport;
    
    /**
	* 要滚动的视域组件。 
	*/
    private function get_viewport() : IViewport
    {
        return _viewport;
    }
    private function set_viewport(value : IViewport) : IViewport
    {
        if (value == _viewport) 
            return value;
        
        uninstallViewport();
        _viewport = value;
        installViewport();
        dispatchEvent(new Event("viewportChanged"));
        return value;
    }
    
    private var _useMouseWheelDelta : Bool = true;
    /**
	* 用户在操作系统中可以设置将鼠标滚轮每滚动一个单位应滚动多少行。
	* 当使用鼠标滚轮滚动此组件的目标容器时，true表示根据用户系统设置的值滚动对应的行数。
	* false则忽略系统设置，始终只滚动一行。默认值为true。
	*/
    private function get_useMouseWheelDelta() : Bool
    {
        return _useMouseWheelDelta;
    }
    private function set_useMouseWheelDelta(value : Bool) : Bool
    {
        if (_useMouseWheelDelta == value) 
            return value;
        _useMouseWheelDelta = value;
        if (horizontalScrollBar != null) 
            horizontalScrollBar.useMouseWheelDelta = _useMouseWheelDelta;
        if (verticalScrollBar != null) 
            verticalScrollBar.useMouseWheelDelta = _useMouseWheelDelta;
        return value;
    }
    
    /**
	* 安装并初始化视域组件
	*/
    private function installViewport() : Void
    {
        if (skinObject && viewport != null) 
        {
            viewport.clipAndEnableScrolling = true;
            contentGroup.addElementAt(viewport, 0);
            viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
        if (verticalScrollBar != null) 
            verticalScrollBar.viewport = viewport;
        if (horizontalScrollBar != null) 
            horizontalScrollBar.viewport = viewport;
    }
    
    /**
	* 卸载视域组件
	*/
    private function uninstallViewport() : Void
    {
        if (horizontalScrollBar != null) 
            horizontalScrollBar.viewport = null;
        if (verticalScrollBar != null) 
            verticalScrollBar.viewport = null;
        if (skin != null && viewport != null) 
        {
            viewport.clipAndEnableScrolling = false;
            contentGroup.removeElement(viewport);
            viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
        }
    }
    
    
    private var _minViewportInset : Float = 0;
    
    /**
	* Scroller四个边与视域组件的最小间隔距离。
	* 如果滚动条都不可见，则四个边的间隔为此属性的值。
	* 如果滚动条可见，则取滚动条的宽度和此属性的值的较大值。
	*/
    private function get_minViewportInset() : Float
    {
        return _minViewportInset;
    }
    private function set_minViewportInset(value : Float) : Float
    {
        if (value == _minViewportInset) 
            return value;
        
        _minViewportInset = value;
        invalidateSkin();
        return value;
    }
    
    private var _measuredSizeIncludesScrollBars : Bool = true;
    /**
	* 如果为 true，Scroller的测量大小会加上滚动条所占的空间，否则 Scroller的测量大小仅取决于其视域组件的尺寸。
	*/
    private function get_measuredSizeIncludesScrollBars() : Bool
    {
        return _measuredSizeIncludesScrollBars;
    }
    private function set_measuredSizeIncludesScrollBars(value : Bool) : Bool
    {
        if (value == _measuredSizeIncludesScrollBars) 
            return value;
        
        _measuredSizeIncludesScrollBars = value;
        invalidateSkin();
        return value;
    }
    
    /**
	* 视域组件的属性改变
	*/
    private function viewport_propertyChangeHandler(event : PropertyChangeEvent) : Void
    {
        var _sw3_ = (event.property);        

        switch (_sw3_)
        {
            case "contentWidth", "contentHeight":
                invalidateSkin();
        }
    }
    
    private function get_numElements() : Int
    {
        return (viewport != null) ? 1 : 0;
    }
    
    /**
	* 抛出索引越界异常
	*/
    private function throwRangeError(index : Int) : Void
    {
        throw ("索引:\"" + index + "\"超出可视元素索引范围");
    }
    /**
	* @inheritDoc
	*/
    public function getElementAt(index : Int) : IVisualElement
    {
        if (viewport != null && index == 0) 
            return viewport
        else 
        throwRangeError(index);
        return null;
    }
    
    /**
	* @inheritDoc
	*/
    public function getElementIndex(element : IVisualElement) : Int
    {
        if (element != null && element == viewport) 
            return 0
        else 
        return -1;
    }
    /**
	* @inheritDoc
	*/
    public function containsElement(element : IVisualElement) : Bool
    {
        if (element != null && element == viewport) 
            return true;
        return false;
    }
    
    private function throwNotSupportedError() : Void
    {
        throw ("此方法在Scroller组件内不可用!");
    }
    /**
	* @inheritDoc
	*/
    public function addElement(element : IVisualElement) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    /**
	* @inheritDoc
	*/
    public function addElementAt(element : IVisualElement, index : Int) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    /**
	* @inheritDoc
	*/
    public function removeElement(element : IVisualElement) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    /**
	* @inheritDoc
	*/
    public function removeElementAt(index : Int) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    /**
	* @inheritDoc
	*/
    public function removeAllElements() : Void
    {
        throwNotSupportedError();
    }
    /**
	* @inheritDoc
	*/
    public function setElementIndex(element : IVisualElement, index : Int) : Void
    {
        throwNotSupportedError();
    }
    /**
	* @inheritDoc
	*/
    public function swapElements(element1 : IVisualElement, element2 : IVisualElement) : Void
    {
        throwNotSupportedError();
    }
    /**
	* @inheritDoc
	*/
    public function swapElementsAt(index1 : Int, index2 : Int) : Void
    {
        throwNotSupportedError();
    }
    
    /**
	* @inheritDoc
	*/
    override private function attachSkin(skin : Dynamic) : Void
    {
        super.attachSkin(skin);
        installViewport();
    }
    
    /**
	* @inheritDoc
	*/
    override private function detachSkin(skin : Dynamic) : Void
    {
        uninstallViewport();
        super.detachSkin(skin);
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == verticalScrollBar) 
        {
            verticalScrollBar.viewport = viewport;
            verticalScrollBar.useMouseWheelDelta = _useMouseWheelDelta;
            contentGroup.addElement(verticalScrollBar);
        }
        else if (instance == horizontalScrollBar) 
        {
            horizontalScrollBar.viewport = viewport;
            horizontalScrollBar.useMouseWheelDelta = _useMouseWheelDelta;
            contentGroup.addElement(horizontalScrollBar);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        
        if (instance == verticalScrollBar) 
        {
            verticalScrollBar.viewport = null;
            if (verticalScrollBar.parent == contentGroup) 
                contentGroup.removeElement(verticalScrollBar);
        }
        else if (instance == horizontalScrollBar) 
        {
            horizontalScrollBar.viewport = null;
            if (horizontalScrollBar.parent == contentGroup) 
                contentGroup.removeElement(horizontalScrollBar);
        }
    }
    
    
    /**
	* 皮肤上鼠标滚轮事件
	*/
    private function contentGroup_mouseWheelHandler(event : MouseEvent) : Void
    {
        var vp : IViewport = viewport;
        if (event.isDefaultPrevented() || vp == null || !vp.visible) 
            return;
        
        var nSteps : Int = MathUtil.absInt(event.delta);
        var navigationUnit : Int;
        if (verticalScrollBar != null && verticalScrollBar.visible) 
        {
            navigationUnit = ((event.delta < 0)) ? NavigationUnit.DOWN : NavigationUnit.UP;
            for (vStep in 0...nSteps){
                var vspDelta : Float = vp.getVerticalScrollPositionDelta(navigationUnit);
                if (!Math.isNaN(vspDelta)) 
                {
                    vp.verticalScrollPosition += vspDelta;
                    if (Std.is(vp, IInvalidating)) 
                        Lib.as(vp, IInvalidating).validateNow();
                }
            }
            event.preventDefault();
        }
        else if (horizontalScrollBar != null && horizontalScrollBar.visible) 
        {
            navigationUnit = ((event.delta < 0)) ? NavigationUnit.RIGHT : NavigationUnit.LEFT;
            for (hStep in 0...nSteps){
                var hspDelta : Float = vp.getHorizontalScrollPositionDelta(navigationUnit);
                if (!Math.isNaN(hspDelta)) 
                {
                    vp.horizontalScrollPosition += hspDelta;
                    if (Std.is(vp, IInvalidating)) 
                        Lib.as(vp, IInvalidating).validateNow();
                }
            }
            event.preventDefault();
        }
    }
}


