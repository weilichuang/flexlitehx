package flexlite.skins.vector;


import flash.display.Graphics;


import flexlite.skins.VectorSkin;


/**
* 滚动条向左滚动按钮默认皮肤
* @author weilichuang
*/
class ScrollBarLeftButtonSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled"];
        this.currentState = "up";
        this.minHeight = 15;
        this.minWidth = 17;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        
        var g : Graphics = graphics;
        g.clear();
        var arrowColor : UInt = 0;
        var radius : Dynamic = 0;
        switch (currentState)
        {
            case "up", "disabled":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], radius);
                arrowColor = VectorSkin.themeColors[0];
            case "over":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[1], VectorSkin.bottomLineColors[1],
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], radius);
                arrowColor = VectorSkin.themeColors[1];
            case "down":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[2], VectorSkin.bottomLineColors[2],
                        [VectorSkin.fillColors[4], VectorSkin.fillColors[5]], radius);
                arrowColor = VectorSkin.themeColors[1];
        }
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
        g.lineStyle(0, 0, 0);
        g.beginFill(arrowColor);
        
        g.moveTo(w * 0.5 - 3, h * 0.5);
        g.lineTo(w * 0.5 + 2, h * 0.5 - 3.5);
        g.lineTo(w * 0.5 + 2, h * 0.5 + 3.5);
        g.lineTo(w * 0.5 - 3, h * 0.5);
        g.endFill();
    }
}
