package flexlite.skins.vector;



import flexlite.skins.VectorSkin;



/**
* 水平滚动条thumb默认皮肤
* @author weilichuang
*/
class HScrollBarThumbSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled"];
        this.currentState = "up";
        this.minHeight = 15;
        this.minWidth = 15;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        
        graphics.clear();
        switch (currentState)
        {
            case "up", "disabled":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], 1);
            case "over":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[1], VectorSkin.bottomLineColors[1],
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], 1);
            case "down":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[2], VectorSkin.bottomLineColors[2],
                        [VectorSkin.fillColors[4], VectorSkin.fillColors[5]], 1);
        }
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
