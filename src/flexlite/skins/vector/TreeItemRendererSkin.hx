package flexlite.skins.vector;


import flash.display.Graphics;

import flexlite.components.Group;
import flexlite.components.ToggleButton;
import flexlite.components.UIAsset;
import flexlite.layouts.HorizontalLayout;
import flexlite.layouts.VerticalAlign;

/**
* TreeItemRenderer默认皮肤
* @author weilichuang
*/
class TreeItemRendererSkin extends ItemRendererSkin
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        this.minHeight = 22;
    }
    
    /**
	* [SkinPart]图标显示对象
	*/
	@SkinPart
    public var iconDisplay : UIAsset;
    /**
	* [SkinPart]子节点开启按钮
	*/
	@SkinPart
    public var disclosureButton : ToggleButton;
    /**
	* [SkinPart]用于调整缩进值的容器对象。
	*/
	@SkinPart
    public var contentGroup : Group;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        contentGroup = new Group();
        contentGroup.top = 0;
        contentGroup.bottom = 0;
        var layout : HorizontalLayout = new HorizontalLayout();
        layout.gap = 1;
        layout.verticalAlign = VerticalAlign.MIDDLE;
        contentGroup.layout = layout;
        addElement(contentGroup);
        
        disclosureButton = new ToggleButton();
        disclosureButton.skinName = TreeDisclosureButtonSkin;
        contentGroup.addElement(disclosureButton);
        
        iconDisplay = new UIAsset();
        contentGroup.addElement(iconDisplay);
        contentGroup.addElement(labelDisplay);
    }
}
