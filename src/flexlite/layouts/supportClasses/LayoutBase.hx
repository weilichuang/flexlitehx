package flexlite.layouts.supportclasses;


import flash.events.Event;
import flash.geom.Rectangle;
import flexlite.components.supportclasses.GroupBase;
import flexlite.core.NavigationUnit;
import flexlite.events.PropertyChangeEvent;
import flexlite.utils.OnDemandEventDispatcher;


@:meta(DXML(show="false"))


/**
* 容器布局基类
* @author weilichuang
*/
class LayoutBase extends OnDemandEventDispatcher
{
	/**
	* 目标容器
	*/
    public var target(get, set) : GroupBase;
	/**
	* 可视区域水平方向起始点
	*/
    public var horizontalScrollPosition(get, set) : Float;
	/**
	* 可视区域竖直方向起始点
	*/
    public var verticalScrollPosition(get, set) : Float;
	
	/**
	* 如果为 true，指定将子代剪切到视区的边界。如果为 false，则容器子代会从容器边界扩展过去，而不管组件的大小规范。
	*/
    public var clipAndEnableScrolling(get, set) : Bool;
	
	/**
	* 若要配置容器使用虚拟布局，请为与容器关联的布局的 useVirtualLayout 属性设置为 true。
	* 只有布局设置为 VerticalLayout、HorizontalLayout 
	* 或 TileLayout 的 DataGroup 或 SkinnableDataContainer 
	* 才支持虚拟布局。不支持虚拟化的布局子类必须禁止更改此属性。
	*/
    public var useVirtualLayout(get, set) : Bool;
	
	/**
	* 由虚拟布局所使用，以估计尚未滚动到视图中的布局元素的大小。 
	*/
    public var typicalLayoutRect(get, set) : Rectangle;

	private var _target : GroupBase;
    private var _horizontalScrollPosition : Float = 0;
    private var _verticalScrollPosition : Float = 0;
    private var _clipAndEnableScrolling : Bool = false;
	private var _useVirtualLayout : Bool = false;
    private var _typicalLayoutRect : Rectangle;
	
    public function new()
    {
        super();
    }
    
    
    
    /**
	* 返回对水平滚动位置的更改以处理不同的滚动选项。
	* 下列选项是由 NavigationUnit 类定义的：END、HOME、LEFT、PAGE_LEFT、PAGE_RIGHT 和 RIGHT。 
	* @param navigationUnit 采用以下值： 
	*  <li> 
	*  <code>END</code>
	*  返回滚动 delta，它将使 scrollRect 与内容区域右对齐。 
	*  </li> 
	*  <li> 
	*  <code>HOME</code>
	*  返回滚动 delta，它将使 scrollRect 与内容区域左对齐。 
	*  </li>
	*  <li> 
	*  <code>LEFT</code>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的左边或在其左边左侧的第一个元素左对齐。 
	*  </li>
	*  <li>
	*  <code>PAGE_LEFT</code>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的左边或在其左边左侧的第一个元素右对齐。 
	*  </li>
	*  <li> 
	*  <code>PAGE_RIGHT</code>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的右边或在其右边右侧的第一个元素左对齐。 
	*  </li>
	*  <li> 
	*  <code>RIGHT</code>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的右边或在其右边右侧的第一个元素右对齐。 
	*  </li>
	*  </ul>
	*/
    public function getHorizontalScrollPositionDelta(navigationUnit : Int) : Float
    {
        var g : GroupBase = target;
        if (g == null) 
            return 0;
        
        var scrollRect : Rectangle = getScrollRect();
        if (scrollRect == null) 
            return 0;
        
        if ((scrollRect.x == 0) && (scrollRect.width >= g.contentWidth)) 
            return 0;
        
        var maxDelta : Float = g.contentWidth - scrollRect.right;
        var minDelta : Float = -scrollRect.left;
        var getElementBounds : Rectangle;
        switch (navigationUnit)
        {
            case NavigationUnit.LEFT, NavigationUnit.PAGE_LEFT:
                getElementBounds = getElementBoundsLeftOfScrollRect(scrollRect);
            case NavigationUnit.RIGHT, NavigationUnit.PAGE_RIGHT:
                getElementBounds = getElementBoundsRightOfScrollRect(scrollRect);
            
            case NavigationUnit.HOME:
                return minDelta;
            
            case NavigationUnit.END:
                return maxDelta;
            
            default:
                return 0;
        }
        
        if (getElementBounds == null) 
            return 0;
        
        var delta : Float = 0;
        switch (navigationUnit)
        {
            case NavigationUnit.LEFT:
                delta = Math.max(getElementBounds.left - scrollRect.left, -scrollRect.width);
            case NavigationUnit.RIGHT:
                delta = Math.min(getElementBounds.right - scrollRect.right, scrollRect.width);
            case NavigationUnit.PAGE_LEFT:
            {
                delta = getElementBounds.right - scrollRect.right;
                
                if (delta >= 0) 
                    delta = Math.max(getElementBounds.left - scrollRect.left, -scrollRect.width);
            }
            case NavigationUnit.PAGE_RIGHT:
            {
                delta = getElementBounds.left - scrollRect.left;
                
                if (delta <= 0) 
                    delta = Math.min(getElementBounds.right - scrollRect.right, scrollRect.width);
            }
        }
        
        return Math.min(maxDelta, Math.max(minDelta, delta));
    }
    /**
	* 返回对垂直滚动位置的更改以处理不同的滚动选项。
	* 下列选项是由 NavigationUnit 类定义的：DOWN、END、HOME、PAGE_DOWN、PAGE_UP 和 UP。
	* @param navigationUnit 采用以下值： DOWN 
	*  <ul>
	*  <li> 
	*  <code>DOWN</code>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的底边或在其底边之下的第一个元素底对齐。 
	*  </li>
	*  <li> 
	*  <code>END</code>
	*  返回滚动 delta，它将使 scrollRect 与内容区域底对齐。 
	*  </li>
	*  <li> 
	*  <code>HOME</code>
	*  返回滚动 delta，它将使 scrollRect 与内容区域顶对齐。 
	*  </li>
	*  <li> 
	*  <code>PAGE_DOWN</code>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的底边或在其底边之下的第一个元素顶对齐。
	*  </li>
	*  <code>PAGE_UP</code>
	*  <li>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的顶边或在其顶边之上的第一个元素底对齐。 
	*  </li>
	*  <li> 
	*  <code>UP</code>
	*  返回滚动 delta，它将使 scrollRect 与跨越 scrollRect 的顶边或在其顶边之上的第一个元素顶对齐。 
	*  </li>
	*  </ul>
	*/
    public function getVerticalScrollPositionDelta(navigationUnit : Int) : Float
    {
        var g : GroupBase = target;
        if (g == null) 
            return 0;
        
        var scrollRect : Rectangle = getScrollRect();
        if (scrollRect == null) 
            return 0;
        
        if ((scrollRect.y == 0) && (scrollRect.height >= g.contentHeight)) 
            return 0;
        
        var maxDelta : Float = g.contentHeight - scrollRect.bottom;
        var minDelta : Float = -scrollRect.top;
        var getElementBounds : Rectangle;
        switch (navigationUnit)
        {
            case NavigationUnit.UP, NavigationUnit.PAGE_UP:
                getElementBounds = getElementBoundsAboveScrollRect(scrollRect);
            case NavigationUnit.DOWN, NavigationUnit.PAGE_DOWN:
                getElementBounds = getElementBoundsBelowScrollRect(scrollRect);
            
            case NavigationUnit.HOME:
                return minDelta;
            
            case NavigationUnit.END:
                return maxDelta;
            
            default:
                return 0;
        }
        
        if (getElementBounds == null) 
            return 0;
        
        var delta : Float = 0;
        switch (navigationUnit)
        {
            case NavigationUnit.UP:
                delta = Math.max(getElementBounds.top - scrollRect.top, -scrollRect.height);
            case NavigationUnit.DOWN:
                delta = Math.min(getElementBounds.bottom - scrollRect.bottom, scrollRect.height);
            case NavigationUnit.PAGE_UP:
            {
                delta = getElementBounds.bottom - scrollRect.bottom;
                
                if (delta >= 0) 
                    delta = Math.max(getElementBounds.top - scrollRect.top, -scrollRect.height);
            }
            case NavigationUnit.PAGE_DOWN:
            {
                delta = getElementBounds.top - scrollRect.top;
                
                if (delta <= 0) 
                    delta = Math.min(getElementBounds.bottom - scrollRect.bottom, scrollRect.height);
            }
        }
        
        return Math.min(maxDelta, Math.max(minDelta, delta));
    }
	
	/**
	* 更新可视区域
	*/
    public function updateScrollRect(w : Float, h : Float) : Void
    {
        if (target == null) 
            return;
        if (_clipAndEnableScrolling) 
        {
            target.scrollRect = new Rectangle(_horizontalScrollPosition, _verticalScrollPosition, w, h);
        }
        else 
        {
            target.scrollRect = null;
        }
    }

    
    
    /**
	* 清理虚拟布局缓存的数据
	*/
    public function clearVirtualLayoutCache() : Void
    {
        
    }
    /**
	* 在已添加布局元素之后且在验证目标的大小和显示列表之前，由目标调用。
	* 按元素状态缓存的布局（比如虚拟布局）可以覆盖此方法以更新其缓存。 
	*/
    public function elementAdded(index : Int) : Void
    {
        
    }
    /**
	* 必须在已删除布局元素之后且在验证目标的大小和显示列表之前，由目标调用此方法。
	* 按元素状态缓存的布局（比如虚拟布局）可以覆盖此方法以更新其缓存。 
	*/
    public function elementRemoved(index : Int) : Void
    {
        
    }
    
    /**
	* 测量组件尺寸大小
	*/
    public function measure() : Void
    {
        
    }
    /**
	* 更新显示列表
	*/
    public function updateDisplayList(width : Float, height : Float) : Void
    {
        
    }
    
    /**
	* 返回布局坐标中目标的滚动矩形的界限。
	*/
    private function getScrollRect() : Rectangle
    {
        var g : GroupBase = target;
        if (g == null || !g.clipAndEnableScrolling) 
            return null;
        var vsp : Float = g.verticalScrollPosition;
        var hsp : Float = g.horizontalScrollPosition;
        return new Rectangle(hsp, vsp, g.width, g.height);
    }
	
    /**
	* 返回跨越 scrollRect 的左边或在其左边左侧的第一个布局元素的界限。 
	*/
    private function getElementBoundsLeftOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.left = scrollRect.left - 1;
        bounds.right = scrollRect.left;
        return bounds;
    }
	
    /**
	* 返回跨越 scrollRect 的右边或在其右边右侧的第一个布局元素的界限。 
	*/
    private function getElementBoundsRightOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.left = scrollRect.right;
        bounds.right = scrollRect.right + 1;
        return bounds;
    }
	
    /**
	* 返回跨越 scrollRect 的顶边或在其顶边之上的第一个布局元素的界限。
	*/
    private function getElementBoundsAboveScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.top = scrollRect.top - 1;
        bounds.bottom = scrollRect.top;
        return bounds;
    }
	
    /**
	* 返回跨越 scrollRect 的底边或在其底边之下的第一个布局元素的界限。 
	*/
    private function getElementBoundsBelowScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.top = scrollRect.bottom;
        bounds.bottom = scrollRect.bottom + 1;
        return bounds;
    }
    
    /**
	* 滚动条位置改变
	*/
    private function scrollPositionChanged() : Void
    {
        if (target == null) 
            return;
        updateScrollRect(target.width, target.height);
        target.invalidateDisplayListExceptLayout();
    }
    
	
	private function get_useVirtualLayout() : Bool
    {
        return _useVirtualLayout;
    }
    
    private function set_useVirtualLayout(value : Bool) : Bool
    {
        if (_useVirtualLayout == value) 
            return value;
        
        _useVirtualLayout = value;
        dispatchEvent(new Event("useVirtualLayoutChanged"));
        
        if (_useVirtualLayout && !value) 
            clearVirtualLayoutCache();
        if (target != null) 
            target.invalidateDisplayList();
        return value;
    }

    private function get_typicalLayoutRect() : Rectangle
    {
        return _typicalLayoutRect;
    }
    
    private function set_typicalLayoutRect(value : Rectangle) : Rectangle
    {
        if (_typicalLayoutRect == value) 
            return value;
        _typicalLayoutRect = value;
        if (target != null) 
            target.invalidateSize();
        return value;
    }
	
	private function get_target() : GroupBase
    {
        return _target;
    }
    
    private function set_target(value : GroupBase) : GroupBase
    {
        if (_target == value) 
            return value;
        _target = value;
        clearVirtualLayoutCache();
        return value;
    }
    
    private function get_horizontalScrollPosition() : Float
    {
        return _horizontalScrollPosition;
    }
    
    private function set_horizontalScrollPosition(value : Float) : Float
    {
        if (value == _horizontalScrollPosition) 
            return value;
        var oldValue : Float = _horizontalScrollPosition;
        _horizontalScrollPosition = value;
        scrollPositionChanged();
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(
                        this, "horizontalScrollPosition", oldValue, value));
        return value;
    }
    
    private function get_verticalScrollPosition() : Float
    {
        return _verticalScrollPosition;
    }
    
    private function set_verticalScrollPosition(value : Float) : Float
    {
        if (value == _verticalScrollPosition) 
            return value;
        var oldValue : Float = _verticalScrollPosition;
        _verticalScrollPosition = value;
        scrollPositionChanged();
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(
                        this, "verticalScrollPosition", oldValue, value));
        return value;
    }
    
    private function get_clipAndEnableScrolling() : Bool
    {
        return _clipAndEnableScrolling;
    }
    
    private function set_clipAndEnableScrolling(value : Bool) : Bool
    {
        if (value == _clipAndEnableScrolling) 
            return value;
        
        _clipAndEnableScrolling = value;
        if (target != null) 
            updateScrollRect(target.width, target.height);
        return value;
    }
}
