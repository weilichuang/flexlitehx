package flexlite.dxr;


import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.FrameLabel;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;


import flexlite.dxr.codec.DxrDrawer;



/**
* DXR动画数据
* @author weilichuang
*/
class DxrData
{
    public var key(get, never) : String;
    public var codecKey(get, never) : String;
    public var totalFrames(get, never) : Int;
    public var scale9Grid(get, never) : Rectangle;
    public var frameLabels(get, never) : Array<FrameLabel>;

    /**
	* 构造函数
	* @param key 动画在文件中的导出键名。
	*/
    public function new(key : String = "", codecKey : String = "jpeg32")
    {
        this._key = key;
        this._codecKey = codecKey;
    }
    
    private var _key : String;
    /**
	* 动画在文件中的导出键名。
	*/
    private function get_key() : String
    {
        return _key;
    }
    
    private var _codecKey : String;
    /**
	* 位图编解码器标识符
	*/
    private function get_codecKey() : String
    {
        return _codecKey;
    }
    
    
    /**
	* 动画帧列表
	*/
    public var frameList : Array<Dynamic> = [];
    
    /**
	* 获取指定帧的位图数据,若不存在则返回null
	* @param frame 帧序号，从0开始
	*/
    public function getBitmapData(frame : Int) : BitmapData
    {
        if (drawTarget != null) 
            checkFrame(frame);
        return frameList[frame];
    }
    
    /**
	* 帧偏移列表
	*/
    public var frameOffsetList : Array<Dynamic> = [];
    
    /**
	* 获取指定帧的偏移量,若不存在则返回null
	* @param frame 帧序号，从0开始
	*/
    public function getFrameOffset(frame : Int) : Point
    {
        if (drawTarget != null) 
            checkFrame(frame);
        return frameOffsetList[frame];
    }
    
    public var filterOffsetList : Array<Dynamic> = [];
    /**
	* 获取指定帧的滤镜尺寸,若不存在则返回null
	* @param frame 帧序号，从0开始
	*/
    public function getFilterOffset(frame : Int) : Point
    {
        if (drawTarget != null) 
            checkFrame(frame);
        return filterOffsetList[frame];
    }
    /**
	* 动画的总帧数
	*/
    private function get_totalFrames() : Int
    {
        return frameList.length;
    }
    
    private var _scale9Grid : Rectangle;
	
	public function initScale9Grid():Void
	{
		this._scale9Grid = new Rectangle();
	}
    
    /**
	* 九宫格缩放数据,若不存在则返回null。
	*/
    private function get_scale9Grid() : Rectangle
    {
        if (_scale9Grid != null) 
        {
            return _scale9Grid.clone();
        }
        return null;
    }
    
    private var _frameLabels : Array<FrameLabel> = [];
    /**
	* 返回由FrameLabel对象组成的数组。数组包括整个Dxr动画实例的所有帧标签。
	*/
    private function get_frameLabels() : Array<FrameLabel>
    {
        return _frameLabels.concat([]);
    }
    /**
	* 要绘制的目标显示对象
	*/
    private var drawTarget : DisplayObject;
    /**
	* 是否绘制滤镜
	*/
    private var containsFilter : Bool = false;
    
    /**
	* 位图化一个显示对象或多帧的影片剪辑。<br/>
	* @param drawTarget 要绘制的目标显示对象。
	* @param containsFilter 当目标对象或其子孙项含有滤镜时，绘制出的滤镜效果可能会被截边。
	* 设置此属性true将绘制出包完整含滤镜效果的位图。但是绘制耗时会更长。请根据绘制目标酌情考虑是否开启。默认为false。
	* @param drawImmediately 是否立即绘制目标对象。若设置为false，
	* 将等待外部第一次访问其某一帧位图数据时才绘制该帧。默认值为false。
	*/
    public function draw(drawTarget : DisplayObject,
            containsFilter : Bool = false,
            drawImmediately : Bool = false) : Void
    {
        if (this.drawTarget == drawTarget) 
            return;
        this.drawTarget = drawTarget;
        this.containsFilter = containsFilter;
        drawCount = 0;
        frameList = [];
        frameOffsetList = [];
        filterOffsetList = [];
        if (drawTarget != null) 
        {
            _scale9Grid = drawTarget.scale9Grid;
            var mc : MovieClip = cast(drawTarget, MovieClip);
            if (mc != null) 
            {
                _frameLabels = mc.currentLabels;
				
				frameList = [];
				for (i in 0...mc.totalFrames)
				{
					frameList[i] = null;
				}
            }
            else 
            {
                _frameLabels = [];
				
				frameList = [];
				frameList.push(null);
            }
            if (drawImmediately) 
            {
                if (dxrDrawer == null) 
                    dxrDrawer = new DxrDrawer();
                var frame : Int = frameList.length;
                while (frame > 0){
                    if (mc != null) 
                        mc.gotoAndStop(frame);
                    if (containsFilter) 
                        dxrDrawer.drawDisplayObject(drawTarget, this, frame - 1)
                    else 
                    dxrDrawer.drawWithoutFilter(drawTarget, this, frame - 1);
                    frame--;
                }
                this.dxrDrawer = null;
                this.drawTarget = null;
            }
        }
        else 
        {
            _scale9Grid = null;
            _frameLabels = [];
        }
    }
    /**
	* dxr绘制工具实例
	*/
    private var dxrDrawer : DxrDrawer;
    /**
	* 已经绘制过的帧数
	*/
    private var drawCount : Int = 0;
    /**
	* 检查指定帧是否还未绘制。
	*/
    private function checkFrame(frame : Int) : Void
    {
        if (frameList[frame] || frame < 0 || frame >= frameList.length) 
            return;
        if (dxrDrawer == null) 
            dxrDrawer = new DxrDrawer();
        var mc : MovieClip = cast(drawTarget, MovieClip);
        if (mc != null) 
            mc.gotoAndStop(frame + 1);
        
        if (containsFilter) 
            dxrDrawer.drawDisplayObject(drawTarget, this, frame)
        else 
			dxrDrawer.drawWithoutFilter(drawTarget, this, frame);
        
        drawCount++;
        if (drawCount == frameList.length) 
        {
            dxrDrawer = null;
            drawTarget = null;
        }
    }
}
