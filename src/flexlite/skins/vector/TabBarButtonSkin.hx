package flexlite.skins.vector;


import flash.display.GradientType;
import flash.text.TextFormatAlign;


import flexlite.components.Label;
import flexlite.layouts.VerticalAlign;
import flexlite.skins.VectorSkin;


/**
* TabBarButton默认皮肤
* @author weilichuang
*/
class TabBarButtonSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled", "upAndSelected", "overAndSelected", "downAndSelected", "disabledAndSelected"];
        this.currentState = "up";
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
        
        graphics.clear();
        var textColor : UInt = 0;
        var radius : Dynamic = {
            tl : VectorSkin.cornerRadius,
            tr : VectorSkin.cornerRadius,
            bl : 0,
            br : 0,

        };
        var crr1 : Dynamic = {
            tl : VectorSkin.cornerRadius - 1,
            tr : VectorSkin.cornerRadius - 1,
            bl : 0,
            br : 0,

        };
        switch (currentState)
        {
            case "up", "disabled":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], radius);
                textColor = VectorSkin.themeColors[0];
            case "over":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], radius);
                textColor = VectorSkin.themeColors[1];
            case "down", "overAndSelected", "upAndSelected", "downAndSelected", "disabledAndSelected":
                drawRoundRect(
                        x, y, w, h, radius,
                        VectorSkin.borderColors[0], 1,
                        verticalGradientMatrix(x, y, w, h),
                        GradientType.LINEAR, null,
                        {
                            x : x + 1,
                            y : y + 1,
                            w : w - 2,
                            h : h - 1,
                            r : crr1,

                        });
                drawRoundRect(
                        x + 1, y + 1, w - 2, h - 1, crr1,
                        0xFFFFFF, 1,
                        verticalGradientMatrix(x + 1, y + 1, w - 2, h - 1));
                textColor = VectorSkin.themeColors[0];
        }
        if (labelDisplay != null) 
        {
            labelDisplay.textColor = textColor;
            labelDisplay.applyTextFormatNow();
            labelDisplay.filters = currentState == ("over") ? VectorSkin.textOverFilter : null;
        }
        this.alpha = currentState == "disabled" || currentState == ("disabledAndSelected") ? 0.5 : 1;
    }
}
