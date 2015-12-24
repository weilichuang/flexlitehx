package flexlite.skins.vector;


import flash.display.Graphics;


import flexlite.components.Group;
import flexlite.components.TabBar;
import flexlite.components.ViewStack;
import flexlite.skins.VectorSkin;


/**
* 垂直滚动条默认皮肤
* @author weilichuang
*/
class TabNavigatorSkin extends VectorSkin
{
    public function new()
    {
        super();
    }
    
    public var contentGroup : Group;
    /**
	* [SkinPart]选项卡组件
	*/
	@SkinPart
    public var tabBar : TabBar;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        contentGroup = new ViewStack();
        contentGroup.top = 25;
        contentGroup.left = 1;
        contentGroup.right = 1;
        contentGroup.bottom = 1;
        contentGroup.clipAndEnableScrolling = true;
        addElement(contentGroup);
        
        tabBar = new TabBar();
        tabBar.height = 25;
        addElement(tabBar);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        var g : Graphics = this.graphics;
        g.clear();
        g.beginFill(0xFFFFFF);
        g.lineStyle(1, VectorSkin.borderColors[0]);
        g.drawRect(0, 24, w, h - 24);
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
