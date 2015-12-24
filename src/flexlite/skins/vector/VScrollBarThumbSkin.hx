package flexlite.skins.vector;


import flash.display.GradientType;


import flexlite.skins.VectorSkin;



/**
* 垂直滚动条thumb默认皮肤
* @author weilichuang
*/
class VScrollBarThumbSkin extends VectorSkin
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
                drawRoundRect(
                        0, 0, w, h, 0,
                        VectorSkin.borderColors[0], 1,
                        horizontalGradientMatrix(0, 0, w, h),
                        GradientType.LINEAR, null,
                        {
                            x : 1,
                            y : 1,
                            w : w - 2,
                            h : h - 2,
                            r : 0,

                        });
                drawRoundRect(
                        1, 1, w - 2, h - 2, 0,
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], 1,
                        horizontalGradientMatrix(1, 1, w - 2, h - 2), GradientType.LINEAR);
                drawLine(w - 1, 0, w - 1, h, VectorSkin.bottomLineColors[0]);
            case "over":
                drawRoundRect(
                        0, 0, w, h, 0,
                        VectorSkin.borderColors[1], 1,
                        horizontalGradientMatrix(0, 0, w, h),
                        GradientType.LINEAR, null,
                        {
                            x : 1,
                            y : 1,
                            w : w - 2,
                            h : h - 2,
                            r : 0,

                        });
                drawRoundRect(
                        1, 1, w - 2, h - 2, 0,
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], 1,
                        horizontalGradientMatrix(1, 1, w - 2, h - 2), GradientType.LINEAR);
                drawLine(w - 1, 0, w - 1, h, VectorSkin.bottomLineColors[1]);
            case "down":
                drawRoundRect(
                        0, 0, w, h, 0,
                        VectorSkin.borderColors[2], 1,
                        horizontalGradientMatrix(0, 0, w, h),
                        GradientType.LINEAR, null,
                        {
                            x : 1,
                            y : 1,
                            w : w - 2,
                            h : h - 2,
                            r : 0,

                        });
                drawRoundRect(
                        1, 1, w - 2, h - 2, 0,
                        [VectorSkin.fillColors[4], VectorSkin.fillColors[5]], 1,
                        horizontalGradientMatrix(1, 1, w - 2, h - 2), GradientType.LINEAR);
                drawLine(w - 1, 0, w - 1, h, VectorSkin.bottomLineColors[2]);
        }
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
