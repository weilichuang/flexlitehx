package flexlite.components;


import flash.geom.Point;

import flexlite.components.supportclasses.SliderBase;

@:meta(DXML(show="true"))

/**
* 垂直滑块控件
* @author weilichuang
*/
class VSlider extends SliderBase
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
        return VSlider;
    }
    
    /**
	* @inheritDoc
	*/
    override private function pointToValue(x : Float, y : Float) : Float
    {
        if (thumb == null || track == null) 
            return 0;
        
        var range : Float = maximum - minimum;
        var thumbRange : Float = track.layoutBoundsHeight - thumb.layoutBoundsHeight;
        return minimum + ((thumbRange != 0) ? ((thumbRange - y) / thumbRange) * range : 0);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateSkinDisplayList() : Void
    {
        if (thumb == null || track == null) 
            return;
        
        var thumbHeight : Float = thumb.layoutBoundsHeight;
        var thumbRange : Float = track.layoutBoundsHeight - thumbHeight;
        var range : Float = maximum - minimum;
        var thumbPosTrackY : Float = (range > 0) ? thumbRange - (((pendingValue - minimum) / range) * thumbRange) : 0;
        var thumbPos : Point = track.localToGlobal(new Point(0, thumbPosTrackY));
        var thumbPosParentY : Float = thumb.parent.globalToLocal(thumbPos).y;
        
        thumb.setLayoutBoundsPosition(thumb.layoutBoundsX, Math.round(thumbPosParentY));
        if (showTrackHighlight && trackHighlight != null && trackHighlight.parent != null) 
        {
            var trackHighlightY : Float = this.trackHighlight.parent.globalToLocal(thumbPos).y;
            trackHighlight.y = Math.round(trackHighlightY + thumbHeight);
            trackHighlight.height = Math.round(thumbRange - trackHighlightY);
        }
    }
}


