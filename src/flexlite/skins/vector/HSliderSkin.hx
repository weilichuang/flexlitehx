package flexlite.skins.vector;


import flexlite.components.Button;
import flexlite.components.UIAsset;

import flexlite.skins.VectorSkin;


/**
* 水平滑块默认皮肤
* @author weilichuang
*/
class HSliderSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minWidth = 50;
        this.minHeight = 11;
    }
    
    public var thumb : Button;
    
    public var track : Button;
    
    public var trackHighlight : UIAsset;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        track = new Button();
        track.left = 0;
        track.right = 0;
        track.top = 0;
        track.bottom = 0;
        track.minWidth = 33;
        track.width = 100;
        track.tabEnabled = false;
        track.skinName = HSliderTrackSkin;
        addElement(track);
        
        trackHighlight = new UIAsset();
        trackHighlight.top = 0;
        trackHighlight.bottom = 0;
        trackHighlight.minWidth = 33;
        trackHighlight.width = 100;
        trackHighlight.tabEnabled = false;
        trackHighlight.skinName = HSliderTrackHighlightSkin;
        addElement(trackHighlight);
        
        thumb = new Button();
        thumb.top = 0;
        thumb.bottom = 0;
        thumb.width = 11;
        thumb.height = 11;
        thumb.tabEnabled = false;
        thumb.skinName = SliderThumbSkin;
        addElement(thumb);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
