package flexlite.skins.vector;



import flexlite.components.Label;
import flexlite.components.UIAsset;
import flexlite.skins.VectorSkin;


/**
* 进度条默认皮肤
* @author weilichuang
*/
class ProgressBarSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.minHeight = 24;
        this.minWidth = 30;
    }
    
    public var thumb : UIAsset;
    public var track : UIAsset;
    public var labelDisplay : Label;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        
        track = new UIAsset();
        track.skinName = ProgressBarTrackSkin;
        track.left = 0;
        track.right = 0;
        addElement(track);
        
        thumb = new UIAsset();
        thumb.skinName = ProgressBarThumbSkin;
        addElement(thumb);
        
        labelDisplay = new Label();
        labelDisplay.y = 14;
        labelDisplay.horizontalCenter = 0;
        addElement(labelDisplay);
    }
}
