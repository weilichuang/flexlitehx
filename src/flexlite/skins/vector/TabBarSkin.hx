package flexlite.skins.vector;



import flexlite.components.DataGroup;
import flexlite.components.TabBarButton;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.HorizontalLayout;
import flexlite.layouts.VerticalAlign;
import flexlite.layouts.VerticalLayout;
import flexlite.skins.VectorSkin;


/**
* TabBar默认皮肤
* @author weilichuang
*/
class TabBarSkin extends VectorSkin
{
    public function new()
    {
        super();
        minWidth = 60;
        minHeight = 20;
    }
    
    public var dataGroup : DataGroup;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        dataGroup = new DataGroup();
        dataGroup.percentWidth = 100;
        dataGroup.percentHeight = 100;
        dataGroup.itemRenderer = TabBarButton;
        var layout : HorizontalLayout = new HorizontalLayout();
        layout.gap = -1;
        layout.horizontalAlign = HorizontalAlign.JUSTIFY;
        layout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
        dataGroup.layout = layout;
        addElement(dataGroup);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
}
