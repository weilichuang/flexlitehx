package flexlite.skins.vector;



import flash.text.TextFormatAlign;


import flexlite.components.Label;
import flexlite.layouts.VerticalAlign;
import flexlite.skins.VectorSkin;


/**
* ToggleButton默认皮肤
* @author weilichuang
*/
class ToggleButtonSkin extends VectorSkin
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
        switch (currentState)
        {
            case "up", "disabled":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], VectorSkin.cornerRadius);
                textColor = VectorSkin.themeColors[0];
            case "over":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[1], VectorSkin.bottomLineColors[1],
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], VectorSkin.cornerRadius);
                textColor = VectorSkin.themeColors[1];
            case "down", "overAndSelected", "upAndSelected", "downAndSelected", "disabledAndSelected":
                drawCurrentState(0, 0, w, h, VectorSkin.borderColors[2], VectorSkin.bottomLineColors[2],
                        [VectorSkin.fillColors[4], VectorSkin.fillColors[5]], VectorSkin.cornerRadius);
                textColor = VectorSkin.themeColors[1];
        }
        if (labelDisplay != null) 
        {
            labelDisplay.textColor = textColor;
            labelDisplay.applyTextFormatNow();
            labelDisplay.filters = ((currentState == "over" || currentState == "down")) ? VectorSkin.textOverFilter : null;
        }
        this.alpha = currentState == "disabled" || currentState == ("disabledAndSelected") ? 0.5 : 1;
    }
}
