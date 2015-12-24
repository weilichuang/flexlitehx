package flexlite.skins.vector;


import flexlite.components.Button;

import flexlite.skins.VectorSkin;


/**
* 水平滚动条默认皮肤
* @author weilichuang
*/
class HScrollBarSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minWidth = 50;
        this.minHeight = 15;
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
        track.left = 16;
        track.right = 16;
        track.width = 54;
        track.skinName = HScrollBarTrackSkin;
        addElement(track);
        
        decrementButton = new Button();
        decrementButton.left = 0;
        decrementButton.skinName = ScrollBarLeftButtonSkin;
        addElement(decrementButton);
        
        incrementButton = new Button();
        incrementButton.right = 0;
        incrementButton.skinName = ScrollBarRightButtonSkin;
        addElement(incrementButton);
        
        thumb = new Button();
        thumb.skinName = HScrollBarThumbSkin;
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
