package flexlite.skins.vector;


import flash.display.Graphics;


import flexlite.skins.VectorSkin;



/**
* 水平滑块thumb默认皮肤
* @author weilichuang
*/
class SliderThumbSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled"];
        this.currentState = "up";
        this.minHeight = 12;
        this.minWidth = 12;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        w = 12;
        h = 12;
        var g : Graphics = graphics;
        g.clear();
        switch (currentState)
        {
            case "up", "disabled":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], 6);
            case "over":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[1], VectorSkin.bottomLineColors[1],
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], 6);
            case "down":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[2], VectorSkin.bottomLineColors[2],
                        [VectorSkin.fillColors[4], VectorSkin.fillColors[5]], 6);
        }
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
