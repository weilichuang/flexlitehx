package flexlite.components;


import flash.geom.Point;

import flexlite.components.supportclasses.SliderBase;

@:meta(DXML(show="true"))


/**
* 水平滑块控件
* @author weilichuang
*/
class HSlider extends SliderBase
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
        return HSlider;
    }
    
    /**
	* @inheritDoc
	*/
    override private function pointToValue(x : Float, y : Float) : Float
    {
        if (thumb == null || track == null) 
            return 0;
        
        var range : Float = maximum - minimum;
        var thumbRange : Float = track.layoutBoundsWidth - thumb.layoutBoundsWidth;
        return minimum + (((thumbRange != 0)) ? (x / thumbRange) * range : 0);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateSkinDisplayList() : Void
    {
        if (thumb == null || track == null) 
            return;
        
        var thumbRange : Float = track.layoutBoundsWidth - thumb.layoutBoundsWidth;
        var range : Float = maximum - minimum;
        var thumbPosTrackX : Float = ((range > 0)) ? ((pendingValue - minimum) / range) * thumbRange : 0;
        var thumbPos : Point = track.localToGlobal(new Point(thumbPosTrackX, 0));
        var thumbPosParentX : Float = thumb.parent.globalToLocal(thumbPos).x;
        
        thumb.setLayoutBoundsPosition(Math.round(thumbPosParentX), thumb.layoutBoundsY);
        if (showTrackHighlight && trackHighlight != null && trackHighlight.parent != null) 
        {
            var trackHighlightX : Float = trackHighlight.parent.globalToLocal(thumbPos).x - thumbPosTrackX;
            trackHighlight.x = Math.round(trackHighlightX);
            trackHighlight.width = Math.round(thumbPosTrackX);
        }
    }
}


