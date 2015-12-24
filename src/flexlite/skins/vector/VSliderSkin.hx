package flexlite.skins.vector;


import flexlite.components.Button;

import flexlite.components.UIAsset;

import flexlite.skins.VectorSkin;


/**
* 垂直滑块默认皮肤
* @author weilichuang
*/
class VSliderSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minWidth = 11;
        this.minHeight = 50;
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
        track.minHeight = 33;
        track.height = 100;
        track.tabEnabled = false;
        track.skinName = VSliderTrackSkin;
        addElement(track);
        
        trackHighlight = new UIAsset();
        trackHighlight.left = 0;
        trackHighlight.right = 0;
        trackHighlight.minHeight = 33;
        trackHighlight.height = 100;
        trackHighlight.tabEnabled = false;
        trackHighlight.skinName = VSliderTrackHighlightSkin;
        addElement(trackHighlight);
        
        thumb = new Button();
        thumb.left = 0;
        thumb.right = 0;
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
