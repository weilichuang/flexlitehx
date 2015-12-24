package flexlite.skins.vector;


import flexlite.components.Button;

import flexlite.skins.VectorSkin;


/**
* 垂直滚动条默认皮肤
* @author weilichuang
*/
class VScrollBarSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minWidth = 15;
        this.minHeight = 50;
    }
    
    public var decrementButton : Button;
    
    public var incrementButton : Button;
    
    public var thumb : Button;
    
    public var track : Button;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        track = new Button();
        track.top = 16;
        track.bottom = 16;
        track.height = 54;
        track.skinName = VScrollBarTrackSkin;
        addElement(track);
        
        decrementButton = new Button();
        decrementButton.top = 0;
        decrementButton.skinName = ScrollBarUpButtonSkin;
        addElement(decrementButton);
        
        incrementButton = new Button();
        incrementButton.bottom = 0;
        incrementButton.skinName = ScrollBarDownButtonSkin;
        addElement(incrementButton);
        
        thumb = new Button();
        thumb.skinName = VScrollBarThumbSkin;
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
