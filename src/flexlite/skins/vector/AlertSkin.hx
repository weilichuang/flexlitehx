package flexlite.skins.vector;

import flexlite.skins.vector.TitleWindowSkin;

import flash.text.TextFormatAlign;

import flexlite.components.Button;
import flexlite.components.Group;
import flexlite.components.Label;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.HorizontalLayout;
import flexlite.layouts.VerticalAlign;

/**
* Alert默认皮肤
* @author weilichuang
*/
class AlertSkin extends TitleWindowSkin
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        this.minHeight = 100;
        this.minWidth = 170;
        this.maxWidth = 310;
    }
    
    /**
	* [SkinPart]文本内容显示对象
	*/
	@SkinPart
    public var contentDisplay : Label;
    /**
	* [SkinPart]第一个按钮，通常是"确定"。
	*/
	@SkinPart
    public var firstButton : Button;
    /**
	* [SkinPart]第二个按钮，通常是"取消"。
	*/
	@SkinPart
    public var secondButton : Button;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        contentDisplay = new Label();
        contentDisplay.top = 30;
        contentDisplay.left = 1;
        contentDisplay.right = 1;
        contentDisplay.bottom = 36;
        contentDisplay.verticalAlign = VerticalAlign.MIDDLE;
        contentDisplay.textAlign = TextFormatAlign.CENTER;
        contentDisplay.padding = 10;
        contentDisplay.selectable = true;
        addElementAt(contentDisplay, 0);
        
        var hGroup : Group = new Group();
        hGroup.bottom = 10;
        hGroup.horizontalCenter = 0;
        var layout : HorizontalLayout = new HorizontalLayout();
        layout.horizontalAlign = HorizontalAlign.CENTER;
        layout.gap = 10;
        layout.paddingLeft = layout.paddingRight = 20;
        hGroup.layout = layout;
        addElement(hGroup);
        
        firstButton = new Button();
        firstButton.label = "确定";
        hGroup.addElement(firstButton);
        secondButton = new Button();
        secondButton.label = "取消";
        hGroup.addElement(secondButton);
    }
}
