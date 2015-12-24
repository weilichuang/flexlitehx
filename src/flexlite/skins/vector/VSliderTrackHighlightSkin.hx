package flexlite.skins.vector;



import flexlite.skins.VectorSkin;



/**
* 水平滑块track默认皮肤
* @author weilichuang
*/
class VSliderTrackHighlightSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minHeight = 15;
        this.minWidth = 4;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        var offsetX : Float = Math.round(w * 0.5 - 2);
        
        graphics.clear();
        graphics.beginFill(0xFFFFFF, 0);
        graphics.drawRect(0, 0, w, h);
        graphics.endFill();
        w = 4;
        graphics.lineStyle();
        drawRoundRect(
                offsetX, 0, w, h, 1,
                VectorSkin.fillColors[2], 1,
                verticalGradientMatrix(offsetX, 0, w, h));
        if (h > 5) 
            drawLine(offsetX, 1, offsetX, h - 1, 0x457cb2);
    }
}
