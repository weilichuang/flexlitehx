package flexlite.skins.vector;


import flash.display.GradientType;


import flexlite.components.EditableText;
import flexlite.components.Label;
import flexlite.components.Scroller;
import flexlite.skins.VectorSkin;


/**
* TextArea默认皮肤
* @author weilichuang
*/
class TextAreaSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.states = ["normal", "disabled", "normalWithPrompt", "disabledWithPrompt"];
    }
    
    public var scroller : Scroller;
    
    public var textDisplay : EditableText;
    /**
	* [SkinPart]当text属性为空字符串时要显示的文本。
	*/
	@SkinPart
    public var promptDisplay : Label;
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        
        textDisplay = new EditableText();
        textDisplay.widthInChars = 15;
        textDisplay.heightInLines = 10;
        
        scroller = new Scroller();
        scroller.left = 0;
        scroller.top = 0;
        scroller.right = 0;
        scroller.bottom = 0;
        scroller.minViewportInset = 1;
        scroller.measuredSizeIncludesScrollBars = false;
        scroller.viewport = textDisplay;
        addElement(scroller);
    }
    
    override private function commitCurrentState() : Void
    {
        this.alpha = currentState == "disabled" ||
                currentState == ("disabledWithPrompt") ? 0.5 : 1;
        if (currentState == "disabledWithPrompt" || currentState == "normalWithPrompt") 
        {
            if (promptDisplay == null) 
            {
                createPromptDisplay();
            }
            if (!contains(promptDisplay)) 
                addElement(promptDisplay);
        }
        else if (promptDisplay != null && contains(promptDisplay)) 
        {
            removeElement(promptDisplay);
        }
    }
    
    private function createPromptDisplay() : Void
    {
        promptDisplay = new Label();
        promptDisplay.maxDisplayedLines = 1;
        promptDisplay.x = 1;
        promptDisplay.y = 1;
        promptDisplay.textColor = 0xa9a9a9;
        promptDisplay.mouseChildren = false;
        promptDisplay.mouseEnabled = false;
        if (hostComponent != null) 
            hostComponent.findSkinParts();
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
                    y : 2,
                    w : w - 2,
                    h : h - 3,
                    r : 0,

                });
        //绘制填充
        drawRoundRect(
                1, 2, w - 2, h - 3, 0,
                0xFFFFFF, 1,
                verticalGradientMatrix(1, 2, w - 2, h - 3));
        //绘制底线
        drawLine(1, 0, w, 0, VectorSkin.bottomLineColors[0]);
    }
}
