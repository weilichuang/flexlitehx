package flexlite.skins.vector;


import flexlite.components.HScrollBar;
import flexlite.components.VScrollBar;

import flexlite.skins.VectorSkin;


/**
* 垂直滚动条默认皮肤
* @author weilichuang
*/
class ScrollerSkin extends VectorSkin
{
    public function new()
    {
        super();
    }
    
    public var horizontalScrollBar : HScrollBar;
    
    public var verticalScrollBar : VScrollBar;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        horizontalScrollBar = new HScrollBar();
        horizontalScrollBar.visible = false;
        addElement(horizontalScrollBar);
        
        verticalScrollBar = new VScrollBar();
        verticalScrollBar.visible = false;
        addElement(verticalScrollBar);
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
