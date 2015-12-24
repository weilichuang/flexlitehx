package flexlite.skins.vector;


import flash.display.GradientType;


import flexlite.skins.VectorSkin;



/**
* 水平滚动条track默认皮肤
* @author weilichuang
*/
class HScrollBarTrackSkin extends VectorSkin
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
        //绘制边框
        drawRoundRect(
                0, 0, w, h, 0,
                VectorSkin.borderColors[0], 1,
                verticalGradientMatrix(0, 0, w, h),
                GradientType.LINEAR, null,
                {
                    x : 1,
                    y : 1,
                    w : w - 2,
                    h : h - 2,
                    r : 0,

                });
        //绘制填充
        drawRoundRect(
                1, 1, w - 2, h - 2, 0,
                0xdddbdb, 1,
                verticalGradientMatrix(1, 2, w - 2, h - 3));
        //绘制底线
        drawLine(1, 1, w - 1, 1, 0xbcbcbc);
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
