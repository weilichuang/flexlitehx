package flexlite.skins.vector;



import flexlite.skins.VectorSkin;


/**
* 
* @author weilichuang
*/
class ProgressBarThumbSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minHeight = 10;
        this.minWidth = 5;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        
        graphics.clear();
        graphics.beginFill(0xFFFFFF, 0);
        graphics.drawRect(0, 0, w, h);
        graphics.endFill();
        graphics.lineStyle();
        drawRoundRect(
                0, 0, w, h, 0,
                VectorSkin.fillColors[2], 1,
                verticalGradientMatrix(0, 0, w, h));
        if (w > 5) 
            drawLine(1, 0, w - 1, 0, 0x457cb2);
    }
}
