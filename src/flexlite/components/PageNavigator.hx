package flexlite.components;


import nme.errors.RangeError;
import flexlite.components.SkinnableComponent;

import flash.events.Event;
import flash.events.MouseEvent;


import flexlite.components.supportclasses.GroupBase;
import flexlite.core.IDisplayText;
import flexlite.core.IViewport;
import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.core.NavigationUnit;
import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.easing.IEaser;
import flexlite.effects.easing.Sine;
import flexlite.events.PropertyChangeEvent;
import flexlite.events.ResizeEvent;
import flexlite.layouts.HorizontalLayout;
import flexlite.layouts.TileLayout;
import flexlite.layouts.TileOrientation;
import flexlite.layouts.supportclasses.LayoutBase;
import flexlite.utils.CallLater;



@:meta(DXML(show="true"))


@:meta(DefaultProperty(name="viewport",array="false"))


/**
* 翻页组件
* @author weilichuang
*/
class PageNavigator extends SkinnableComponent implements IVisualElementContainer
{
    public var pageDuration(get, set) : Float;
    private var animator(get, never) : Animation;
    public var currentPage(get, set) : Int;
    public var totalPages(get, never) : Int;
    public var viewport(get, set) : IViewport;
    public var autoButtonVisibility(get, set) : Bool;
    public var numElements(get, never) : Int;

    public function new()
    {
        super();
        focusEnabled = true;
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return PageNavigator;
    }
    /**
	* [SkinPart]上一页按钮
	*/
	@SkinPart
    public var prevPageButton : Button;
    /**
	* [SkinPart]下一页按钮
	*/
	@SkinPart
    public var nextPageButton : Button;
    
    /**
	* [SkinPart]第一页按钮
	*/
	@SkinPart
    public var firstPageButton : Button;
    /**
	* [SkinPart]最后一页按钮
	*/
	@SkinPart
    public var lastPageButton : Button;
    /**
	* [SkinPart]页码文本显示对象
	*/
	@SkinPart
    public var labelDisplay : IDisplayText;
    /**
	* [SkinPart]装载目标viewport的容器
	*/
	@SkinPart
    public var contentGroup : Group;
    
    private var _pageDuration : Float = 500;
    
    /**
	* 翻页缓动动画时间，单位毫秒。设置为0则不执行缓动。默认值500。
	*/
    private function get_pageDuration() : Float
    {
        return _pageDuration;
    }
    
    private function set_pageDuration(value : Float) : Float
    {
        _pageDuration = value;
        return value;
    }
    
    private static var sineEaser : IEaser = new Sine(0);
    private var _animator : Animation = null;
    /**
	* 动画类实例
	*/
    private function get_animator() : Animation
    {
        if (_animator != null) 
            return _animator;
        _animator = new Animation(animationUpdateHandler);
        _animator.endFunction = animationEndHandler;
        animator.easer = sineEaser;
        return _animator;
    }
    
    /**
	* 动画播放过程中触发的更新数值函数
	*/
    private function animationUpdateHandler(animation : Animation) : Void
    {
        if (!_viewport) 
            return;
        var value : Float = animation.currentValue["scrollPosition"];
        if (pageDirectionIsVertical) 
            _viewport.verticalScrollPosition = value
        else 
        _viewport.horizontalScrollPosition = value;
    }
    /**
	* 动画播放结束时到达的滚动位置
	*/
    private var destScrollPostion : Float;
    /**
	* 动画播放完成触发的函数
	*/
    private function animationEndHandler(animation : Animation) : Void
    {
        if (!_viewport) 
            return;
        if (pageDirectionIsVertical) 
        {
            if (destScrollPostion > _viewport.contentHeight - _viewport.height) 
            {
                destScrollPostion = _viewport.contentHeight - _viewport.height;
            }
            _viewport.verticalScrollPosition = destScrollPostion;
        }
        else 
        {
            if (destScrollPostion > _viewport.contentWidth - _viewport.width) 
            {
                destScrollPostion = _viewport.contentWidth - _viewport.width;
            }
            _viewport.horizontalScrollPosition = destScrollPostion;
        }
    }
    /**
	* 立即开始动画的播放
	*/
    private function startAnimation(valueFrom : Float, valueTo : Float) : Void
    {
        if (animator.isPlaying) 
        {
            animationEndHandler(animator);
            animator.stop();
        }
        var pageSize : Float = Math.max(1, _viewport.width);
        var duration : Float = Math.abs(valueTo - valueFrom) / pageSize * _pageDuration;
        animator.duration = Std.int(Math.min(_pageDuration, duration));
        animator.motionPaths = [
                        new MotionPath("scrollPosition", valueFrom, valueTo)];
        animator.play();
    }
    
    
    /**
	* 页码文本格式化回调函数，示例：labelFunction(pageIndex:int,totalPages:int):String;
	*/
    public var labelFunction : Function;
    /**
	* 格式化当前页码为显示的文本
	* @param pageIndex
	*/
    private function pageToLabel(pageIndex : Int, totalPages : Int) : String
    {
        if (labelFunction != null) 
            return labelFunction(pageIndex, totalPages);
        return (pageIndex + 1) + "/" + totalPages;
    }
    
    /**
	* 未设置缓存选中项的值
	*/
    private static var NO_PROPOSED_PAGE : Int = -2;
    /**
	* 在属性提交前缓存外部显式设置的页码值
	*/
    private var proposedCurrentPage : Int = NO_PROPOSED_PAGE;
    
    private var _currentPage : Int = 0;
    /**
	* 当前页码索引，从0开始。
	*/
    private function get_currentPage() : Int
    {
        return proposedCurrentPage == (NO_PROPOSED_PAGE != 0) ? 
        _currentPage : proposedCurrentPage;
    }
    
    private function set_currentPage(value : Int) : Int
    {
        gotoPage(value);
        return value;
    }
    
    private var _totalPages : Int = 0;
    /**
	* 总页数。
	*/
    private function get_totalPages() : Int
    {
        return _totalPages;
    }
    
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
            return;
        
        uninstallViewport();
        _viewport = value;
        installViewport();
        dispatchEvent(new Event("viewportChanged"));
        return value;
    }
    
    /**
	* 安装并初始化视域组件
	*/
    private function installViewport() : Void
    {
        if (contentGroup != null && _viewport != null) 
        {
            _viewport.clipAndEnableScrolling = true;
            _viewport.left = _viewport.right = _viewport.top = _viewport.bottom = 0;
            contentGroup.addElementAt(_viewport, 0);
            _viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
            _viewport.addEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler);
            _viewport.addEventListener(ResizeEvent.RESIZE, onViewPortResized);
            pageDirectionIsVertical = updateDirection();
            if (Std.is(_viewport, GroupBase)) 
            {
                _viewport.addEventListener("layoutChanged", onLayoutChanged);
                var layout : LayoutBase = (cast(_viewport, GroupBase)).layout;
                if (layout != null) 
                {
                    layout.addEventListener("orientationChanged", onLayoutChanged, false, 0, true);
                }
            }
            updateaTotalPages();
        }
    }
    /**
	* viewPort尺寸改变
	*/
    private function onViewPortResized(event : ResizeEvent) : Void
    {
        totalPagesChanged = true;
        invalidateProperties();
    }
    
    /**
	* 卸载视域组件
	*/
    private function uninstallViewport() : Void
    {
        if (skinObject && _viewport != null) 
        {
            _viewport.clipAndEnableScrolling = false;
            _viewport.left = _viewport.right = _viewport.top = _viewport.bottom = NaN;
            contentGroup.removeElement(_viewport);
            _viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
            _viewport.removeEventListener(MouseEvent.MOUSE_WHEEL, skin_mouseWheelHandler);
            _viewport.removeEventListener(ResizeEvent.RESIZE, onViewPortResized);
            if (Std.is(_viewport, GroupBase)) 
            {
                _viewport.removeEventListener("layoutChanged", onLayoutChanged);
                var layout : LayoutBase = (cast(_viewport, GroupBase)).layout;
                if (layout != null) 
                {
                    layout.removeEventListener("orientationChanged", onLayoutChanged);
                }
            }
        }
    }
    /**
	* viewport的layout属性改变,更新翻页方向.
	*/
    private function onLayoutChanged(event : Event = null) : Void
    {
        var oldDirection : Bool = pageDirectionIsVertical;
        pageDirectionIsVertical = updateDirection();
        if (pageDirectionIsVertical != oldDirection) 
            updateaTotalPages();
        if (event.type == "layoutChanged" && Std.is(_viewport, GroupBase)) 
        {
            var layout : LayoutBase = (cast(_viewport, GroupBase)).layout;
            if (layout != null && !layout.hasEventListener("orientationChanged")) 
            {
                layout.addEventListener("orientationChanged", onLayoutChanged, false, 0, true);
            }
        }
    }
    
    /**
	* 翻页朝向，true代表垂直翻页，false代表水平翻页。
	*/
    private var pageDirectionIsVertical : Bool = true;
    /**
	* 安装viewport时调用此方法，返回当前的翻页方向，true代表垂直翻页，反之水平翻页。
	*/
    private function updateDirection() : Bool
    {
        if (!(Std.is(_viewport, GroupBase))) 
            return true;
        var layout : LayoutBase = (cast(_viewport, GroupBase)).layout;
        var direction : Bool = true;
        if (Std.is(layout, HorizontalLayout)) 
        {
            direction = false;
        }
        else if (Std.is(layout, TileLayout) &&
            (cast(layout, TileLayout)).orientation == TileOrientation.COLUMNS) 
        {
            direction = false;
        }
        else 
        {
            direction = true;
        }
        return direction;
    }
    /**
	* 总页数改变
	*/
    private var totalPagesChanged : Bool = false;
    /**
	* 内部正在调整滚动位置的标志
	*/
    private var adjustingScrollPostion : Bool = false;
    /**
	* 视域组件的属性改变
	*/
    private function viewport_propertyChangeHandler(event : PropertyChangeEvent) : Void
    {
        var _sw2_ = (event.property);        

        switch (_sw2_)
        {
            case "contentWidth", "contentHeight":
                totalPagesChanged = true;
                invalidateProperties();
            case "horizontalScrollPosition", "verticalScrollPosition":
                if (adjustingScrollPostion || (_animator != null && _animator.isPlaying)) 
                    break;
                totalPagesChanged = true;
                invalidateProperties();
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (totalPagesChanged) 
        {
            updateaTotalPages();
        }
    }
    
    private var _autoButtonVisibility : Bool = false;
    /**
	* 当已经到达页尾或页首时，是否自动隐藏或显示翻页按钮。默认值为false。
	*/
    private function get_autoButtonVisibility() : Bool
    {
        return _autoButtonVisibility;
    }
    
    private function set_autoButtonVisibility(value : Bool) : Bool
    {
        if (_autoButtonVisibility == value) 
            return;
        _autoButtonVisibility = value;
        checkButtonEnabled();
        return value;
    }
    
    private var scrollPostionMap : Array<Dynamic> = [0];
    /**
	* 更新总页码
	*/
    private function updateaTotalPages() : Void
    {
        totalPagesChanged = false;
        if (_viewport == null) 
            return;
        adjustingScrollPostion = true;
        scrollPostionMap = [0];
        _totalPages = 1;
        var oldScrollPostion : Float;
        var maxScrollPostion : Float;
        var currentPageFoud : Bool = false;
        if (pageDirectionIsVertical) 
        {
            oldScrollPostion = _viewport.verticalScrollPosition;
            _viewport.verticalScrollPosition = 0;
            maxScrollPostion = _viewport.contentHeight - Math.max(0, _viewport.height);
            maxScrollPostion = Math.min(_viewport.contentHeight, maxScrollPostion);
            while (_viewport.verticalScrollPosition < maxScrollPostion)
            {
                _viewport.verticalScrollPosition +=
                _viewport.getVerticalScrollPositionDelta(NavigationUnit.PAGE_DOWN);
                if (!currentPageFoud && _viewport.verticalScrollPosition > oldScrollPostion) 
                {
                    currentPageFoud = true;
                }
                scrollPostionMap[_totalPages] = _viewport.verticalScrollPosition;
                _totalPages++;
            }
            var h : Float = (Math.isNaN(_viewport.height)) ? 0 : _viewport.height;
            _viewport.verticalScrollPosition
                    = Math.max(0, Math.min(oldScrollPostion, _viewport.contentHeight - h));
        }
        else 
        {
            oldScrollPostion = _viewport.horizontalScrollPosition;
            _viewport.horizontalScrollPosition = 0;
            maxScrollPostion = _viewport.contentWidth - Math.max(0, _viewport.width);
            maxScrollPostion = Math.min(_viewport.contentWidth, maxScrollPostion);
            while (_viewport.horizontalScrollPosition < maxScrollPostion)
            {
                _viewport.horizontalScrollPosition +=
                _viewport.getHorizontalScrollPositionDelta(NavigationUnit.PAGE_RIGHT);
                if (!currentPageFoud && _viewport.horizontalScrollPosition > oldScrollPostion) 
                {
                    currentPageFoud = true;
                }
                scrollPostionMap[_totalPages] = _viewport.horizontalScrollPosition;
                _totalPages++;
            }
            var w : Float = (Math.isNaN(_viewport.width)) ? 0 : _viewport.width;
            _viewport.horizontalScrollPosition
                    = Math.max(0, Math.min(oldScrollPostion, _viewport.contentWidth - w));
        }
        if (_animator != null && _animator.isPlaying) 
        {
            proposedCurrentPage = _currentPage;
            doChangePage();
        }
        else 
        {
            if (_currentPage > _totalPages - 1) 
                _currentPage = _totalPages - 1;
            checkButtonEnabled();
            if (labelDisplay != null) 
                labelDisplay.text = pageToLabel(_currentPage, _totalPages);
            if (pageDirectionIsVertical) 
            {
                _viewport.verticalScrollPosition = scrollPostionMap[_currentPage];
            }
            else 
            {
                _viewport.horizontalScrollPosition = scrollPostionMap[_currentPage];
            }
        }
        adjustingScrollPostion = false;
    }
    
    private var pageIndexChanged : Bool = false;
    /**
	* 跳转到指定索引的页面
	*/
    private function gotoPage(index : Int) : Void
    {
        if (index < 0) 
            index = 0;
        proposedCurrentPage = index;
        if (pageIndexChanged) 
            return;
        pageIndexChanged = true;
        callLater(doChangePage);
    }
    
    /**
	* 执行翻页操作
	*/
    private function doChangePage() : Void
    {
        pageIndexChanged = false;
        if (_viewport == null) 
            return;
        _currentPage = proposedCurrentPage;
        if (_currentPage > _totalPages - 1) 
            _currentPage = _totalPages - 1;
        checkButtonEnabled();
        if (labelDisplay != null) 
            labelDisplay.text = pageToLabel(_currentPage, _totalPages);
        
        destScrollPostion = scrollPostionMap[_currentPage];
        if (_pageDuration > 0 && stage) 
        {
            var oldScrollPostion : Float;
            if (pageDirectionIsVertical) 
            {
                oldScrollPostion = _viewport.verticalScrollPosition;
            }
            else 
            {
                oldScrollPostion = _viewport.horizontalScrollPosition;
            }
            startAnimation(oldScrollPostion, destScrollPostion);
        }
        else 
        {
            if (pageDirectionIsVertical) 
            {
                _viewport.verticalScrollPosition = destScrollPostion;
            }
            else 
            {
                _viewport.horizontalScrollPosition = destScrollPostion;
            }
        }
        proposedCurrentPage = NO_PROPOSED_PAGE;
    }
    /**
	* 检查页码并设置按钮禁用状态
	*/
    private function checkButtonEnabled() : Void
    {
        var prev : Bool = false;
        var next : Bool = false;
        var first : Bool = false;
        var last : Bool = false;
        if (_totalPages > 1) 
        {
            if (currentPage < _totalPages - 1) 
            {
                last = next = true;
            }
            if (currentPage > 0) 
            {
                first = prev = true;
            }
        }
        if (prevPageButton != null) 
        {
            prevPageButton.enabled = prev;
            prevPageButton.visible = !_autoButtonVisibility || prev;
            prevPageButton.includeInLayout = !_autoButtonVisibility || prev;
        }
        if (nextPageButton != null) 
        {
            nextPageButton.enabled = next;
            nextPageButton.visible = !_autoButtonVisibility || next;
            nextPageButton.includeInLayout = !_autoButtonVisibility || next;
        }
        if (firstPageButton != null) 
        {
            firstPageButton.enabled = first;
            firstPageButton.visible = !_autoButtonVisibility || first;
            firstPageButton.includeInLayout = !_autoButtonVisibility || first;
        }
        if (lastPageButton != null) 
        {
            lastPageButton.enabled = last;
            lastPageButton.visible = !_autoButtonVisibility || last;
            lastPageButton.includeInLayout = !_autoButtonVisibility || last;
        }
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
        if (instance == prevPageButton) 
        {
            prevPageButton.addEventListener(MouseEvent.CLICK, onPrevPageClick);
        }
        else if (instance == nextPageButton) 
        {
            nextPageButton.addEventListener(MouseEvent.CLICK, onNextPageClick);
        }
        else if (instance == firstPageButton) 
        {
            firstPageButton.addEventListener(MouseEvent.CLICK, onFirstPageClick);
        }
        else if (instance == lastPageButton) 
        {
            lastPageButton.addEventListener(MouseEvent.CLICK, onLastPageClick);
        }
        else if (instance == labelDisplay) 
        {
            labelDisplay.text = pageToLabel(currentPage, _totalPages);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        if (instance == prevPageButton) 
        {
            prevPageButton.removeEventListener(MouseEvent.CLICK, onPrevPageClick);
        }
        else if (instance == nextPageButton) 
        {
            nextPageButton.removeEventListener(MouseEvent.CLICK, onNextPageClick);
        }
        else if (instance == firstPageButton) 
        {
            firstPageButton.removeEventListener(MouseEvent.CLICK, onFirstPageClick);
        }
        else if (instance == lastPageButton) 
        {
            lastPageButton.removeEventListener(MouseEvent.CLICK, onLastPageClick);
        }
    }
    /**
	* "最后一页"按钮被点击
	*/
    private function onLastPageClick(event : MouseEvent) : Void
    {
        if (_viewport == null) 
            return;
        gotoPage(_totalPages - 1);
    }
    /**
	* "第一页"按钮被点击
	*/
    private function onFirstPageClick(event : MouseEvent) : Void
    {
        if (_viewport == null) 
            return;
        gotoPage(0);
    }
    /**
	* "下一页"按钮被点击
	*/
    private function onNextPageClick(event : MouseEvent) : Void
    {
        if (_viewport == null) 
            return;
        gotoPage(Math.min(_totalPages - 1, currentPage + 1));
    }
    /**
	* "上一页"按钮被点击
	*/
    private function onPrevPageClick(event : MouseEvent) : Void
    {
        if (_viewport == null) 
            return;
        gotoPage(currentPage - 1);
    }
    
    
    /**
	* 皮肤上鼠标滚轮事件
	*/
    private function skin_mouseWheelHandler(event : MouseEvent) : Void
    {
        var vp : IViewport = _viewport;
        if (event.isDefaultPrevented() || vp == null || !vp.visible) 
            return;
        if (event.delta > 0) 
            gotoPage(currentPage - 1)
        else 
        gotoPage(Math.min(_totalPages - 1, currentPage + 1));
        event.preventDefault();
    }
    
    private function get_numElements() : Int
    {
        return (_viewport != null) ? 1 : 0;
    }
    
    /**
	* 抛出索引越界异常
	*/
    private function throwRangeError(index : Int) : Void
    {
        throw new RangeError("索引:\"" + index + "\"超出可视元素索引范围");
    }
    
    public function getElementAt(index : Int) : IVisualElement
    {
        if (_viewport != null && index == 0) 
            return _viewport
        else 
        throwRangeError(index);
        return null;
    }
    
    
    public function getElementIndex(element : IVisualElement) : Int
    {
        if (element != null && element == _viewport) 
            return 0
        else 
        return -1;
    }
    
    public function containsElement(element : IVisualElement) : Bool
    {
        if (element != null && element == _viewport) 
            return true;
        return false;
    }
    
    private function throwNotSupportedError() : Void
    {
        throw new Error("此方法在PageNavigator组件内不可用!");
    }
    
    public function addElement(element : IVisualElement) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    public function addElementAt(element : IVisualElement, index : Int) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    public function removeElement(element : IVisualElement) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    public function removeElementAt(index : Int) : IVisualElement
    {
        throwNotSupportedError();
        return null;
    }
    public function removeAllElements() : Void
    {
        throwNotSupportedError();
    }
    public function setElementIndex(element : IVisualElement, index : Int) : Void
    {
        throwNotSupportedError();
    }
    public function swapElements(element1 : IVisualElement, element2 : IVisualElement) : Void
    {
        throwNotSupportedError();
    }
    public function swapElementsAt(index1 : Int, index2 : Int) : Void
    {
        throwNotSupportedError();
    }
}
