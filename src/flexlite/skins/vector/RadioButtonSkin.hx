package flexlite.skins.vector;


import flash.display.Graphics;
import flash.text.TextFormatAlign;


import flexlite.components.Label;
import flexlite.layouts.VerticalAlign;
import flexlite.skins.VectorSkin;


/**
* CheckBox默认皮肤
* @author weilichuang
*/
class RadioButtonSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled", "upAndSelected", "overAndSelected", "downAndSelected", "disabledAndSelected"];
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
        labelDisplay.left = 16;
        labelDisplay.right = 0;
        labelDisplay.top = 3;
        labelDisplay.bottom = 3;
        labelDisplay.verticalCenter = 0;
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
        g.beginFill(0xFFFFFF, 0);
        g.drawRect(0, 0, w, h);
        g.endFill();
        
        var startY : Float = Math.round((h - 14) * 0.5);
        if (startY < 0) 
            startY = 0;
        w = 14;
        h = 14;
        
        var selected : Bool = false;
        var selectedColor : Int = 0xFFFFFF;
        switch (currentState)
        {
            case "upAndSelected", "up", "disabled":
                drawCurrentState(0, startY, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                        [VectorSkin.fillColors[0], VectorSkin.fillColors[1]], 7);
                selected = (currentState == "upAndSelected");
                selectedColor = VectorSkin.fillColors[4];
            case "over", "overAndSelected":
                drawCurrentState(0, startY, w, h, VectorSkin.borderColors[1], VectorSkin.bottomLineColors[1],
                        [VectorSkin.fillColors[2], VectorSkin.fillColors[3]], 7);
                selected = (currentState != "over");
            case "down", "downAndSelected", "disabledAndSelected":
                drawCurrentState(0, startY, w, h, VectorSkin.borderColors[2], VectorSkin.bottomLineColors[2],
                        [VectorSkin.fillColors[4], VectorSkin.fillColors[5]], 7);
                selected = (currentState != "down");
        }
        
        if (selected) 
        {
            g.lineStyle(0, 0, 0);
            g.beginFill(selectedColor);
            g.drawCircle(7, startY + 7, 3);
            g.endFill();
        }
        
        this.alpha = currentState == "disabled" || currentState == ("disabledAndSelected") ? 0.5 : 1;
    }
}
