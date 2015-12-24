package flexlite.skins.vector;





import flexlite.components.EditableText;
import flexlite.components.Label;
import flexlite.skins.VectorSkin;


/**
* ComboBox的textInput部件默认皮肤
* @author weilichuang
*/
class ComboBoxTextInputSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.states = ["normal", "disabled", "normalWithPrompt", "disabledWithPrompt"];
    }
    
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
        textDisplay.widthInChars = 10;
        textDisplay.heightInLines = 1;
        textDisplay.multiline = false;
        textDisplay.left = 1;
        textDisplay.right = 1;
        textDisplay.verticalCenter = 0;
        addElement(textDisplay);
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
        promptDisplay.verticalCenter = 0;
        promptDisplay.x = 1;
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
        var radius : Dynamic = {
            tl : VectorSkin.cornerRadius,
            tr : 0,
            bl : VectorSkin.cornerRadius,
            br : 0,

        };
        drawCurrentState(0, 0, w, h, VectorSkin.borderColors[0], VectorSkin.bottomLineColors[0],
                0xFFFFFF, radius);
    }
}
