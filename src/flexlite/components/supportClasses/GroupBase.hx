package flexlite.components.supportclasses;


import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;


import flexlite.core.ILayoutElement;
import flexlite.core.IViewport;
import flexlite.core.IVisualElement;
import flexlite.core.UIComponent;
import flexlite.events.PropertyChangeEvent;
import flexlite.layouts.BasicLayout;
import flexlite.layouts.supportclasses.LayoutBase;



@:meta(DXML(show="false"))


/**
* 自动布局容器基类
* @author weilichuang
*/
class GroupBase extends UIComponent implements IViewport
{
	/**
	* @inheritDoc
	*/
    public var contentWidth(get, never) : Float;
    public var contentHeight(get, never) : Float;
    public var layout(get, set) : LayoutBase;
    public var clipAndEnableScrolling(get, set) : Bool;
    public var horizontalScrollPosition(get, set) : Float;
    public var verticalScrollPosition(get, set) : Float;
    public var numElements(get, never) : Int;
	
	private var _contentWidth : Float = 0;
    private var _contentHeight : Float = 0;
	
	/**
	* 布局发生改变时传递的参数
	*/
    private var _layoutProperties : Dynamic;
    
    private var _layout : LayoutBase;
	
	/**
	* 在更新显示列表时是否需要更新布局标志 
	*/
    private var layoutInvalidateDisplayListFlag : Bool = false;
    /**
	* 在测量尺寸时是否需要测量布局的标志
	*/
    private var layoutInvalidateSizeFlag : Bool = false;

    public function new()
    {
        super();
    }

    private function get_contentWidth() : Float
    {
        return _contentWidth;
    }
    
    private function setContentWidth(value : Float) : Void
    {
        if (value == _contentWidth) 
            return;
        var oldValue : Float = _contentWidth;
        _contentWidth = value;
        dispatchPropertyChangeEvent("contentWidth", oldValue, value);
    }
    
	
    
    /**
	* @inheritDoc
	*/
    private function get_contentHeight() : Float
    {
        return _contentHeight;
    }
    
    private function setContentHeight(value : Float) : Void
    {
        if (value == _contentHeight) 
            return;
        var oldValue : Float = _contentHeight;
        _contentHeight = value;
        dispatchPropertyChangeEvent("contentHeight", oldValue, value);
    }
    /**
	* @private
	* 设置 contentWidth 和 contentHeight 属性，此方法由Layout类调用
	*/
    public function setContentSize(width : Float, height : Float) : Void
    {
        if ((width == _contentWidth) && (height == _contentHeight)) 
            return;
        setContentWidth(width);
        setContentHeight(height);
    }
    
    
    /**
	* 此容器的布局对象
	*/
    private function get_layout() : LayoutBase
    {
        return _layout;
    }
    
    private function set_layout(value : LayoutBase) : LayoutBase
    {
        if (_layout == value) 
            return value;
        if (_layout != null) 
        {
            _layout.target = null;
            _layout.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, redispatchLayoutEvent);
            _layoutProperties = {
                        clipAndEnableScrolling : _layout.clipAndEnableScrolling

                    };
        }
        
        _layout = value;
        
        if (_layout != null) 
        {
            _layout.target = this;
            _layout.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, redispatchLayoutEvent);
            if (_layoutProperties != null) 
            {
                if (_layoutProperties.clipAndEnableScrolling != null) 
                    value.clipAndEnableScrolling = _layoutProperties.clipAndEnableScrolling;
                
                if (_layoutProperties.verticalScrollPosition != null) 
                    value.verticalScrollPosition = _layoutProperties.verticalScrollPosition;
                
                if (_layoutProperties.horizontalScrollPosition != null) 
                    value.horizontalScrollPosition = _layoutProperties.horizontalScrollPosition;
                
                _layoutProperties = null;
            }
        }
        invalidateSize();
        invalidateDisplayList();
        dispatchEvent(new Event("layoutChanged"));
        return value;
    }
    
    /**
	* 抛出滚动条位置改变事件
	*/
    private function redispatchLayoutEvent(event : Event) : Void
    {
		var _sw1_:Dynamic = null;
        var pce : PropertyChangeEvent = cast(event, PropertyChangeEvent);
        if (pce != null) 
            _sw1_ = pce.property;        

        switch (_sw1_)
        {
            case "verticalScrollPosition", "horizontalScrollPosition":
                dispatchEvent(event);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        if (_layout == null) 
        {
            layout = new BasicLayout();
        }
    }
    
    /**
	* 如果为 true，指定将子代剪切到视区的边界。如果为 false，则容器子代会从容器边界扩展过去，而不管组件的大小规范。默认false
	*/
    private function get_clipAndEnableScrolling() : Bool
    {
        if (_layout != null) 
        {
            return _layout.clipAndEnableScrolling;
        }
        else if (_layoutProperties != null &&
            _layoutProperties.clipAndEnableScrolling != null) 
        {
            return _layoutProperties.clipAndEnableScrolling;
        }
        else 
        {
            return false;
        }
    }
    /**
	* @inheritDoc
	*/
    private function set_clipAndEnableScrolling(value : Bool) : Bool
    {
        if (_layout != null) 
        {
            _layout.clipAndEnableScrolling = value;
        }
        else if (_layoutProperties != null) 
        {
            _layoutProperties.clipAndEnableScrolling = value;
        }
        else 
        {
            _layoutProperties = {
                        clipAndEnableScrolling : value

                    };
        }
        
        invalidateSize();
        return value;
    }
    /**
	* @inheritDoc
	*/
    public function getHorizontalScrollPositionDelta(navigationUnit : Int) : Float
    {
        return ((layout != null)) ? layout.getHorizontalScrollPositionDelta(navigationUnit) : 0;
    }
    /**
	* @inheritDoc
	*/
    public function getVerticalScrollPositionDelta(navigationUnit : Int) : Float
    {
        return ((layout != null)) ? layout.getVerticalScrollPositionDelta(navigationUnit) : 0;
    }
    
    /**
	* 可视区域水平方向起始点
	*/
    private function get_horizontalScrollPosition() : Float
    {
        if (_layout != null) 
        {
            return _layout.horizontalScrollPosition;
        }
        else if (_layoutProperties != null &&
            _layoutProperties.horizontalScrollPosition != null) 
        {
            return _layoutProperties.horizontalScrollPosition;
        }
        else 
        {
            return 0;
        }
    }
    /**
	* @inheritDoc
	*/
    private function set_horizontalScrollPosition(value : Float) : Float
    {
        if (_layout != null) 
        {
            _layout.horizontalScrollPosition = value;
        }
        else if (_layoutProperties != null) 
        {
            _layoutProperties.horizontalScrollPosition = value;
        }
        else 
        {
            _layoutProperties = {
                        horizontalScrollPosition : value

                    };
        }
        return value;
    }
    
    /**
	* 可视区域竖直方向起始点
	*/
    private function get_verticalScrollPosition() : Float
    {
        if (_layout != null) 
        {
            return _layout.verticalScrollPosition;
        }
        else if (_layoutProperties != null &&
            _layoutProperties.verticalScrollPosition != null) 
        {
            return _layoutProperties.verticalScrollPosition;
        }
        else 
        {
            return 0;
        }
    }
    /**
	* @inheritDoc
	*/
    private function set_verticalScrollPosition(value : Float) : Float
    {
        if (_layout != null) 
        {
            _layout.verticalScrollPosition = value;
        }
        else if (_layoutProperties != null) 
        {
            _layoutProperties.verticalScrollPosition = value;
        }
        else 
        {
            _layoutProperties = {
                        verticalScrollPosition : value

                    };
        }
        return value;
    }
    /**
	* @inheritDoc
	*/
    override private function measure() : Void
    {
        if (_layout == null || !layoutInvalidateSizeFlag) 
            return;
        super.measure();
        _layout.measure();
    }
    
    
    
    /**
	* 标记需要更新显示列表但不需要更新布局
	*/
    public function invalidateDisplayListExceptLayout() : Void
    {
        super.invalidateDisplayList();
    }
    
    /**
	* @inheritDoc
	*/
    override public function invalidateDisplayList() : Void
    {
        super.invalidateDisplayList();
        layoutInvalidateDisplayListFlag = true;
    }
    
    /**
	* @inheritDoc
	*/
    override private function childXYChanged() : Void
    {
        invalidateSize();
        invalidateDisplayList();
    }
    
	
    
    /**
	* 标记需要更新显示列表但不需要更新布局
	*/
    private function invalidateSizeExceptLayout() : Void
    {
        super.invalidateSize();
    }
    
    /**
	* @inheritDoc
	*/
    override public function invalidateSize() : Void
    {
        super.invalidateSize();
        layoutInvalidateSizeFlag = true;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if (layoutInvalidateDisplayListFlag && _layout != null) 
        {
            layoutInvalidateDisplayListFlag = false;
            _layout.updateDisplayList(unscaledWidth, unscaledHeight);
            _layout.updateScrollRect(unscaledWidth, unscaledHeight);
        }
    }
    /**
	* 此容器中的可视元素的数量。
	*/
    private function get_numElements() : Int
    {
        return -1;
    }
    
    /**
	* 返回指定索引处的可视元素。
	* @param index 要检索的元素的索引。
	* @throws RangeError 如果在子列表中不存在该索引位置。
	*/
    public function getElementAt(index : Int) : IVisualElement
    {
        return null;
    }
    
    /**
	* 返回可视元素的索引位置。若不存在，则返回-1。
	* @param element 可视元素。
	*/
    public function getElementIndex(element : IVisualElement) : Int
    {
        return -1;
    }
    /**
	* 确定指定的 IVisualElement 是否为容器实例的子代或该实例本身。将进行深度搜索，即，如果此元素是该容器的子代、孙代、曾孙代等，它将返回 true。
	* @param element 要测试的子对象
	*/
    public function containsElement(element : IVisualElement) : Bool
    {
        while (element != null)
        {
            if (element == this) 
                return true;
            
            if (Std.is(element.parent, IVisualElement)) 
                element = Lib.as(element.parent, IVisualElement)
            else 
				return false;
        }
        
        return false;
    }
    
    /**
	* 返回在容器可视区域内的布局元素索引列表,此方法忽略不是布局元素的普通的显示对象
	*/
    public function getElementIndicesInView() : Array<Int>
    {
        var visibleIndices : Array<Int> = new Array<Int>();
        var index : Int;
        if (scrollRect == null) 
        {
            for (index in 0...numChildren){
                visibleIndices.push(index);
            }
        }
        else 
        {
			index = 0;
			while(index < numChildren)
			{
                var layoutElement : ILayoutElement = Lib.as(getChildAt(index), ILayoutElement);
                if (layoutElement == null) 
                {
					index++;
					continue;
                }
                var eltR : Rectangle = new Rectangle();
                eltR.x = layoutElement.layoutBoundsX;
                eltR.y = layoutElement.layoutBoundsY;
                eltR.width = layoutElement.layoutBoundsWidth;
                eltR.height = layoutElement.layoutBoundsHeight;
                if (scrollRect.intersects(eltR)) 
                    visibleIndices.push(index);
					
				index++;
            }
        }
        return visibleIndices;
    }
    /**
	* 在支持虚拟布局的容器中，设置容器内可见的子元素索引范围。此方法在不支持虚拟布局的容器中无效。
	* 通常在即将连续调用getVirtualElementAt()之前需要显式设置一次，以便容器提前释放已经不可见的子元素。
	* @param startIndex 可视元素起始索引
	* @param endIndex 可视元素结束索引
	*/
    public function setVirtualElementIndicesInView(startIndex : Int, endIndex : Int) : Void
    {
        
        
    }
    
    /**
	* 支持useVirtualLayout属性的布局类在updateDisplayList()中使用此方法来获取“处于视图中”的布局元素 
	* @param index 要检索的元素的索引。
	*/
    public function getVirtualElementAt(index : Int) : IVisualElement
    {
        return getElementAt(index);
    }
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(scrollRect) private function set_scrollRect(value : Rectangle) : Void
    {
        super.scrollRect = value;
        if (hasEventListener("scrollRectChange")) 
            dispatchEvent(new Event("scrollRectChange"));
    }
	#else
	override private function set_scrollRect(value : Rectangle) : Rectangle
    {
        super.scrollRect = value;
        if (hasEventListener("scrollRectChange")) 
            dispatchEvent(new Event("scrollRectChange"));
        return value;
    }
	#end
}
