package flexlite.components;


import flash.events.MouseEvent;
import flash.geom.Point;
import flash.Lib;
import flexlite.utils.MathUtil;

import flexlite.components.supportclasses.ScrollBarBase;
import flexlite.core.IInvalidating;
import flexlite.core.IViewport;
import flexlite.core.NavigationUnit;

import flexlite.events.PropertyChangeEvent;
import flexlite.events.ResizeEvent;




@:meta(DXML(show="true"))


/**
* 水平滚动条组件
* @author weilichuang
*/
class HScrollBar extends ScrollBarBase
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return HScrollBar;
    }
    
    /**
	* 更新最大值和分页大小
	*/
    private function updateMaximumAndPageSize() : Void
    {
        var hsp : Float = viewport.horizontalScrollPosition;
        var viewportWidth : Float = (Math.isNaN(viewport.width)) ? 0 : viewport.width;
        var cWidth : Float = viewport.contentWidth;
        maximum = ((cWidth == 0)) ? hsp : cWidth - viewportWidth;
        pageSize = viewportWidth;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_viewport(newViewport : IViewport) : IViewport
    {
        
        var oldViewport : IViewport = super.viewport;
        if (oldViewport == newViewport) 
            return newViewport;
        
        if (oldViewport != null) 
        {
            oldViewport.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
            removeEventListener(MouseEvent.MOUSE_WHEEL, hsb_mouseWheelHandler, true);
        }
        
        super.viewport = newViewport;
        
        if (newViewport != null) 
        {
            updateMaximumAndPageSize();
            value = newViewport.horizontalScrollPosition;
            newViewport.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, -50);
            addEventListener(MouseEvent.MOUSE_WHEEL, hsb_mouseWheelHandler, true);
        }
        return newViewport;
    }
    
    /**
	* @inheritDoc
	*/
    override private function pointToValue(x : Float, y : Float) : Float
    {
        if (thumb == null || track == null) 
            return 0;
        
        var r : Float = track.layoutBoundsWidth - thumb.layoutBoundsWidth;
        return minimum + (((r != 0)) ? (x / r) * (maximum - minimum) : 0);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateSkinDisplayList() : Void
    {
        if (thumb == null || track == null) 
            return;
        
        var trackSize : Float = track.layoutBoundsWidth;
        var range : Float = maximum - minimum;
        
        var thumbPos : Point;
        var thumbPosTrackX : Float = 0;
        var thumbPosParentX : Float = 0;
        var thumbSize : Float = trackSize;
        if (range > 0) 
        {
            if (fixedThumbSize == false) 
            {
                thumbSize = Math.min((pageSize / (range + pageSize)) * trackSize, trackSize);
                thumbSize = Math.max(thumb.minWidth, thumbSize);
            }
            else 
            {
                thumbSize = (thumb != null) ? thumb.width : 0;
            }
            thumbPosTrackX = (value - minimum) * ((trackSize - thumbSize) / range);
        }
        
        if (fixedThumbSize == false) 
            thumb.width = Math.ceil(thumbSize);
        if (autoThumbVisibility == true) 
            thumb.visible = thumbSize < trackSize;
        thumbPos = track.localToGlobal(new Point(thumbPosTrackX, 0));
        thumbPosParentX = thumb.parent.globalToLocal(thumbPos).x;
        
        thumb.setLayoutBoundsPosition(Math.round(thumbPosParentX), thumb.layoutBoundsY);
    }
    
    /**
	* @inheritDoc
	*/
    override private function setValue(value : Float) : Void
    {
        super.setValue(value);
        if (viewport != null) 
            viewport.horizontalScrollPosition = value;
    }
    
    /**
	* @inheritDoc
	*/
    override public function changeValueByPage(increase : Bool = true) : Void
    {
        var oldPageSize : Float = 0;
        if (viewport != null) 
        {
            oldPageSize = pageSize;
            pageSize = Math.abs(viewport.getHorizontalScrollPositionDelta(
                                    ((increase)) ? NavigationUnit.PAGE_RIGHT : NavigationUnit.PAGE_LEFT));
        }
        super.changeValueByPage(increase);
        if (viewport != null) 
            pageSize = oldPageSize;
    }
    
    /**
	* @inheritDoc
	*/
    override private function animatePaging(newValue : Float, pageSize : Float) : Void
    {
        if (viewport != null) 
        {
            var vpPageSize : Float = Math.abs(viewport.getHorizontalScrollPositionDelta(
                            ((newValue > value)) ? NavigationUnit.PAGE_RIGHT : NavigationUnit.PAGE_LEFT));
            super.animatePaging(newValue, vpPageSize);
            return;
        }
        super.animatePaging(newValue, pageSize);
    }
    
    /**
	* @inheritDoc
	*/
    override public function changeValueByStep(increase : Bool = true) : Void
    {
        var oldStepSize : Float = 0;
        if (viewport != null) 
        {
            oldStepSize = stepSize;
            stepSize = Math.abs(viewport.getHorizontalScrollPositionDelta(
                                    ((increase)) ? NavigationUnit.RIGHT : NavigationUnit.LEFT));
        }
        super.changeValueByStep(increase);
        if (viewport != null) 
            stepSize = oldStepSize;
    }
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        if (instance == thumb) 
        {
            thumb.left = 0;
            thumb.right = 0;
            thumb.horizontalCenter = 0;
        }
        
        super.partAdded(partName, instance);
    }
    
    /**
	* @inheritDoc
	*/
    override private function viewportHorizontalScrollPositionChangeHandler(event : PropertyChangeEvent) : Void
    {
        if (viewport != null) 
            value = viewport.horizontalScrollPosition;
    }
    
    /**
	* @inheritDoc
	*/
    override private function viewportResizeHandler(event : ResizeEvent) : Void
    {
        if (viewport != null) 
            updateMaximumAndPageSize();
    }
    
    /**
	* @inheritDoc
	*/
    override private function viewportContentWidthChangeHandler(event : PropertyChangeEvent) : Void
    {
        if (viewport != null) 
        {
            var viewportWidth : Float = (Math.isNaN(viewport.width)) ? 0 : viewport.width;
            maximum = viewport.contentWidth - viewportWidth;
        }
    }
    
    /**
	* 根据event.delta滚动指定步数的距离。这个事件处理函数优先级比垂直滚动条的低。
	*/
    private function mouseWheelHandler(event : MouseEvent) : Void
    {
        var vp : IViewport = viewport;
        if (event.isDefaultPrevented() || vp == null || !vp.visible || !visible) 
            return;
        
        var nSteps : Int = (useMouseWheelDelta) ? MathUtil.absInt(event.delta) : 1;
        var navigationUnit : Int;
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
    
    private function hsb_mouseWheelHandler(event : MouseEvent) : Void
    {
        var vp : IViewport = viewport;
        if (event.isDefaultPrevented() || vp == null || !vp.visible) 
            return;
        
        event.stopImmediatePropagation();
        vp.dispatchEvent(event);
    }
}

