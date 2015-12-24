package flexlite.skins.vector;


import flash.display.GradientType;
import flash.display.Graphics;
import flash.text.TextFormatAlign;


import flexlite.components.Label;
import flexlite.layouts.VerticalAlign;
import flexlite.skins.VectorSkin;



/**
* ItemRenderer默认皮肤
* @author weilichuang
*/
class ItemRendererSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down"];
        this.minHeight = 21;
        this.minWidth = 21;
    }
    
    public var labelDisplay : Label;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        labelDisplay = new Label();
        labelDisplay.textAlign = TextFormatAlign.CENTER;
        labelDisplay.verticalAlign = VerticalAlign.MIDDLE;
        labelDisplay.maxDisplayedLines = 1;
        labelDisplay.left = 5;
        labelDisplay.right = 5;
        labelDisplay.top = 3;
        labelDisplay.bottom = 3;
        addElement(labelDisplay);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        
        var g : Graphics = graphics;
        g.clear();
        var textColor : UInt = 0;
        switch (currentState)
        {
            case "up", "disabled":
                drawRoundRect(
                        0, 0, w, h, 0,
                        0xFFFFFF, 1,
                        verticalGradientMatrix(0, 0, w, h));
                textColor = VectorSkin.themeColors[0];
            case "over", "down":
                drawRoundRect(
                        0, 0, w, h, 0,
                        VectorSkin.borderColors[0], 1,
                        verticalGradientMatrix(0, 0, w, h),
                        GradientType.LINEAR, null,
                        {
                            x : 0,
                            y : 0,
                            w : w,
                            h : h - 1,
                            r : 0,

                        });
                drawRoundRect(
                        0, 0, w, h - 1, 0,
                        0x4f83c4, 1,
                        verticalGradientMatrix(0, 0, w, h - 1));
                textColor = VectorSkin.themeColors[1];
        }
        if (labelDisplay != null) 
        {
            labelDisplay.textColor = textColor;
            labelDisplay.applyTextFormatNow();
            labelDisplay.filters = ((currentState == "over" || currentState == "down")) ? VectorSkin.textOverFilter : null;
        }
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
