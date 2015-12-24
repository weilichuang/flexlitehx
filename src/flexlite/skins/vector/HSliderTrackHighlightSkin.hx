package flexlite.skins.vector;



import flexlite.skins.VectorSkin;



/**
* 水平滑块track默认皮肤
* @author weilichuang
*/
class HSliderTrackHighlightSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minHeight = 4;
        this.minWidth = 15;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        var offsetY : Float = Math.round(h * 0.5 - 2);
        
        graphics.clear();
        graphics.beginFill(0xFFFFFF, 0);
        graphics.drawRect(0, 0, w, h);
        graphics.endFill();
        h = 4;
        graphics.lineStyle();
        drawRoundRect(
                0, offsetY, w, h, 1,
                VectorSkin.fillColors[2], 1,
                verticalGradientMatrix(0, offsetY, w, h));
        if (w > 5) 
            drawLine(1, offsetY, w - 1, offsetY, 0x457cb2);
    }
}
