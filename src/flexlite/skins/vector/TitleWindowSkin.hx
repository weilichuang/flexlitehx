package flexlite.skins.vector;


import flexlite.components.Button;
import flexlite.components.Group;




/**
* TitleWindow默认皮肤
* @author weilichuang
*/
class TitleWindowSkin extends PanelSkin
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    public var closeButton : Button;
    
    public var moveArea : Group;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        moveArea = new Group();
        moveArea.left = 0;
        moveArea.right = 0;
        moveArea.top = 0;
        moveArea.height = 30;
        addElement(moveArea);
        
        closeButton = new Button();
        closeButton.skinName = TitleWindowCloseButtonSkin;
        closeButton.right = 7;
        closeButton.top = 7;
        addElement(closeButton);
    }
}
