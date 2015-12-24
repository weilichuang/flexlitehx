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
* 垂直滚动条组件
* @author weilichuang
*/
class VScrollBar extends ScrollBarBase
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
        return VScrollBar;
    }
    
    /**
	* 更新最大值和分页大小
	*/
    private function updateMaximumAndPageSize() : Void
    {
        var vsp : Float = viewport.verticalScrollPosition;
        var viewportHeight : Float = (Math.isNaN(viewport.height)) ? 0 : viewport.height;
        var cHeight : Float = viewport.contentHeight;
        maximum = ((cHeight == 0)) ? vsp : cHeight - viewportHeight;
        pageSize = viewportHeight;
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
            removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
        }
        
        super.viewport = newViewport;
        
        if (newViewport != null) 
        {
            updateMaximumAndPageSize();
            value = newViewport.verticalScrollPosition;
            newViewport.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
            addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
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
        
        var r : Float = track.layoutBoundsHeight - thumb.layoutBoundsHeight;
        return minimum + (((r != 0)) ? (y / r) * (maximum - minimum) : 0);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateSkinDisplayList() : Void
    {
        if (thumb == null || track == null) 
            return;
        
        var trackSize : Float = track.layoutBoundsHeight;
        var range : Float = maximum - minimum;
        
        var thumbPos : Point;
        var thumbPosTrackY : Float = 0;
        var thumbPosParentY : Float = 0;
        var thumbSize : Float = trackSize;
        if (range > 0) 
        {
            if (fixedThumbSize == false) 
            {
                thumbSize = Math.min((pageSize / (range + pageSize)) * trackSize, trackSize);
                thumbSize = Math.max(thumb.minHeight, thumbSize);
            }
            else 
            {
                thumbSize = (thumb != null) ? thumb.height : 0;
            }
            thumbPosTrackY = (value - minimum) * ((trackSize - thumbSize) / range);
        }
        
        if (fixedThumbSize == false) 
            thumb.height = Math.ceil(thumbSize);
        if (autoThumbVisibility == true) 
            thumb.visible = thumbSize < trackSize;
        thumbPos = track.localToGlobal(new Point(0, thumbPosTrackY));
        thumbPosParentY = thumb.parent.globalToLocal(thumbPos).y;
        
        thumb.setLayoutBoundsPosition(thumb.layoutBoundsX, Math.round(thumbPosParentY));
    }
    
    /**
	* @inheritDoc
	*/
    override private function setValue(value : Float) : Void
    {
        super.setValue(value);
        if (viewport != null) 
            viewport.verticalScrollPosition = value;
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
            pageSize = Math.abs(viewport.getVerticalScrollPositionDelta(
                                    ((increase)) ? NavigationUnit.PAGE_DOWN : NavigationUnit.PAGE_UP));
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
            var vpPageSize : Float = Math.abs(viewport.getVerticalScrollPositionDelta(
                            ((newValue > value)) ? NavigationUnit.PAGE_DOWN : NavigationUnit.PAGE_UP));
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
            stepSize = Math.abs(viewport.getVerticalScrollPositionDelta(
                                    ((increase)) ? NavigationUnit.DOWN : NavigationUnit.UP));
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
            thumb.top = 0;
            thumb.bottom = 0;
            thumb.verticalCenter = 0;
        }
        super.partAdded(partName, instance);
    }
    
    /**
	* @inheritDoc
	*/
    override private function viewportVerticalScrollPositionChangeHandler(event : PropertyChangeEvent) : Void
    {
        if (viewport != null) 
            value = viewport.verticalScrollPosition;
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
    override private function viewportContentHeightChangeHandler(event : PropertyChangeEvent) : Void
    {
        if (viewport != null) 
        {
            var viewportHeight : Float = Math.isNaN(viewport.height) ? 0 : viewport.height;
            maximum = viewport.contentHeight - viewport.height;
        }
    }
    
    /**
	* 根据event.delta滚动指定步数的距离。
	*/
    private function mouseWheelHandler(event : MouseEvent) : Void
    {
        var vp : IViewport = viewport;
        if (event.isDefaultPrevented() || vp == null || !vp.visible || !visible) 
            return;
        
        var nSteps : Int = (useMouseWheelDelta) ? MathUtil.absInt(event.delta) : 1;
        var navigationUnit : Int;
        navigationUnit = ((event.delta < 0)) ? NavigationUnit.DOWN : NavigationUnit.UP;
        for (vStep in 0...nSteps)
		{
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
}

