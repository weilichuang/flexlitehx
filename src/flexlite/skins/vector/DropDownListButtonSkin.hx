package flexlite.skins.vector;


import flash.display.Graphics;


import flexlite.skins.VectorSkin;



/**
* DropDownList下拉按钮默认皮肤
* @author weilichuang
*/
class DropDownListButtonSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled"];
        this.minHeight = 25;
        this.minWidth = 22;
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
        switch (currentState)
        {
            case "up", "disabled":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], VectorSkin.cornerRadius);
                if (w > 21 && h > 2) 
                {
                    drawLine(w - 21, 1, w - 21, h - 1, 0xe4e4e4);
                    drawLine(w - 20, 1, w - 20, h - 1, 0xf9f9f9);
                }
                arrowColor = VectorSkin.themeColors[0];
            case "over":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[1], VectorSkin.bottomLineColors[1],
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], VectorSkin.cornerRadius);
                if (w > 21 && h > 2) 
                {
                    drawLine(w - 21, 1, w - 21, h - 1, 0x3c74ab);
                    drawLine(w - 20, 1, w - 20, h - 1, 0x6a9fd3);
                }
                arrowColor = VectorSkin.themeColors[1];
            case "down":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[2], VectorSkin.bottomLineColors[2],
                        [VectorSkin.fillColors[4], VectorSkin.fillColors[5]], VectorSkin.cornerRadius);
                if (w > 21 && h > 2) 
                {
                    drawLine(w - 21, 1, w - 21, h - 1, 0x787878);
                    drawLine(w - 20, 1, w - 20, h - 1, 0xa4a4a4);
                }
                arrowColor = VectorSkin.themeColors[1];
        }
        if (w > 21) 
        {
            g.lineStyle(0, 0, 0);
            g.beginFill(arrowColor);
            g.moveTo(w - 10, h * 0.5 + 3);
            g.lineTo(w - 13.5, h * 0.5 - 2);
            g.lineTo(w - 6.5, h * 0.5 - 2);
            g.lineTo(w - 10, h * 0.5 + 3);
            g.endFill();
        }
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
