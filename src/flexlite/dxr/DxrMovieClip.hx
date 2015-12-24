package flexlite.dxr;

import flexlite.dxr.IDxrDisplay;
import flexlite.dxr.Scale9GridBitmap;
import flexlite.utils.MathUtil;
import haxe.ds.StringMap;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.FrameLabel;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;

import flexlite.core.IBitmapAsset;
import flexlite.core.IInvalidateDisplay;
import flexlite.core.IMovieClip;

import flexlite.dxr.events.MovieClipPlayEvent;



/**
* 一次播放完成事件
*/
@:meta(Event(name="playComplete",type="org.flexlite.domDisplay.events.MovieClipPlayEvent"))


/**
* DXR影片剪辑。
* 请根据实际需求选择最佳的IDxrDisplay呈现DxrData。
* @author weilichuang
*/
class DxrMovieClip extends Sprite implements IMovieClip implements IBitmapAsset implements IDxrDisplay implements IInvalidateDisplay
{
    public var frameRate(get, set) : Int;
    public var smoothing(get, set) : Bool;
    public var dxrData(get, set) : DxrData;
    public var currentFrame(get, never) : Int;
    public var totalFrames(get, never) : Int;
    public var frameLabels(get, never) : Array<Dynamic>;
    public var repeatPlay(get, set) : Bool;
    public var measuredWidth(get, never) : Float;
    public var measuredHeight(get, never) : Float;

    /**
	* 所有DxrMovieClip初始化时默认的帧率。默认24。
	*/
    public static var defaultFrameRate : Int = 24;
    /**
	* Timer字典,每种帧率对应一个Timer实例。
	*/
    private static var timerDic : Array<Dynamic> = [];
    /**
	* 每种帧率的Timer实例被添加监听的次数。
	*/
    private static var timerEventCount : Array<Dynamic> = [];
    /**
	* 零坐标点
	*/
    private static var zeroPoint : Point = new Point();
    /**
	* 构造函数
	* @param data 被引用的DxrData对象
	* @param smoothing 在缩放时是否对位图进行平滑处理。
	* @param frameRate 播放帧率。若不设置，将采用defaultFrameRate的值。
	*/
    public function new(data : DxrData = null, smoothing : Bool = true, frameRate : Int = -1)
    {
        super();
        addEventListener(Event.ADDED_TO_STAGE, onAddedOrRemoved);
        addEventListener(Event.REMOVED_FROM_STAGE, onAddedOrRemoved);
        mouseChildren = false;
        _smoothing = smoothing;
        _frameRate = frameRate == -(1) ? defaultFrameRate : frameRate;
        if (data != null) 
            dxrData = data;
    }
    
    private var _frameRate : Int = 24;
    /**
	* 播放帧率，即每秒钟播放的次数。有效值为1~60。
	* 注意：修改此属性只影响当前实例，若要同时修改所有实例的默认帧率，请设置静态属性defaultFrameRate
	*/
    private function get_frameRate() : Int
    {
        return _frameRate;
    }
    private function set_frameRate(value : Int) : Int
    {
        if (value < 1) 
            value == 1;
        if (value > 60) 
            value = 60;
        if (value == _frameRate) 
            return value;
        var isPlaying : Bool = eventListenerAdded;
        removeTimerEventListener();
        _frameRate = value;
        if (isPlaying) 
            attachTimerEventListener();
        return value;
    }
    
    
    /**
	* smoothing改变标志
	*/
    private var smoothingChanged : Bool = true;
    
    private var _smoothing : Bool;
    /**
	* 在缩放时是否对位图进行平滑处理。
	*/
    private function get_smoothing() : Bool
    {
        return _smoothing;
    }
    
    private function set_smoothing(value : Bool) : Bool
    {
        if (_smoothing == value) 
            return value;
        _smoothing = value;
        smoothingChanged = true;
        invalidateProperties();
        return value;
    }
    /**
	* 是否在舞台上的标志。
	*/
    private var inStage : Bool = false;
    /**
	* 被添加到显示列表时
	*/
    private function onAddedOrRemoved(event : Event) : Void
    {
        inStage = event.type == Event.ADDED_TO_STAGE;
        checkEventListener();
    }
    /**
	* 位图显示对象
	*/
    private var bitmapContent : Bitmap;
    /**
	* 具有九宫格缩放功能的位图显示对象
	*/
    private var s9gBitmapContent : Scale9GridBitmap;
    
    private var useScale9Grid : Bool = false;
    
    private var _dxrData : DxrData;
    /**
	* 被引用的DxrData对象
	*/
    private function get_dxrData() : DxrData
    {
        return _dxrData;
    }
    
    private function set_dxrData(value : DxrData) : DxrData
    {
        if (_dxrData == value) 
            return value;
        _dxrData = value;
        _currentFrame = 0;
        checkEventListener();
        if (value == null) 
        {
            if (bitmapContent != null) 
            {
                removeChild(bitmapContent);
                bitmapContent = null;
            }
            if (s9gBitmapContent != null) 
            {
                graphics.clear();
                s9gBitmapContent = null;
            }
            return null;
        }
        useScale9Grid = (_dxrData.scale9Grid != null);
        if (_dxrData.frameLabels.length > 0) 
        {
            frameLabelDic = new StringMap<Int>();
            for (label in _dxrData.frameLabels)
            {
                frameLabelDic.set(label.name,label.frame);
            }
        }
        else 
        {
            frameLabelDic = null;
        }
        initContent();
        applyCurrentFrameData();
        return value;
    }
    /**
	* 当使用九宫格缩放时的x方向缩放值
	*/
    private var frameScaleX : Float = 1;
    /**
	* 当使用九宫格缩放时的y方向缩放值
	*/
    private var frameScaleY : Float = 1;
    /**
	* 0帧的滤镜水平偏移量。
	*/
    private var initFilterWidth : Float = 0;
    /**
	* 0帧的滤镜竖直偏移量
	*/
    private var initFilterHeight : Float = 0;
    /**
	* 初始化显示对象实体
	*/
    private function initContent() : Void
    {
        frameScaleX = 1;
        frameScaleY = 1;
        var sizeOffset : Point = dxrData.getFilterOffset(0);
        initFilterWidth = (sizeOffset != null) ? sizeOffset.x : 0;
        initFilterHeight = (sizeOffset != null) ? sizeOffset.y : 0;
        if (widthExplicitSet) 
        {
            frameScaleX = _width / (_dxrData.getBitmapData(0).width - initFilterWidth);
        }
        if (heightExplicitSet) 
        {
            frameScaleY = _height / (_dxrData.getBitmapData(0).height - initFilterHeight);
        }
        if (useScale9Grid) 
        {
            if (bitmapContent != null) 
            {
                removeChild(bitmapContent);
                bitmapContent = null;
            }
            if (s9gBitmapContent == null) 
            {
                s9gBitmapContent = new Scale9GridBitmap(null, this.graphics, _smoothing);
            }
        }
        else 
        {
            if (s9gBitmapContent != null) 
            {
                graphics.clear();
                s9gBitmapContent = null;
            }
            if (bitmapContent == null) 
            {
                bitmapContent = new Bitmap();
                addChild(bitmapContent);
            }
        }
    }
    
    private var eventListenerAdded : Bool = false;
    /**
	* 检测是否需要添加事件监听
	* @param remove 强制移除事件监听标志
	*/
    private function checkEventListener(remove : Bool = false) : Void
    {
        var needAddEventListener : Bool = (!remove && inStage && !isStop && totalFrames > 1 && visible);
        if (eventListenerAdded == needAddEventListener) 
            return;
        if (eventListenerAdded) 
        {
            removeTimerEventListener();
        }
        else 
        {
            attachTimerEventListener();
        }
    }
    /**
	* 移除当前的Timer事件监听
	*/
    private function removeTimerEventListener() : Void
    {
        if (!eventListenerAdded) 
            return;
        var timer : Timer = timerDic[_frameRate];
        timer.removeEventListener(TimerEvent.TIMER, render);
        timerEventCount[_frameRate]--;
        if (timerEventCount[_frameRate] <= 0) 
            timer.stop();
        eventListenerAdded = false;
    }
    /**
	* 添加当前的Timer事件监听
	*/
    private function attachTimerEventListener() : Void
    {
        if (eventListenerAdded) 
            return;
        var timer : Timer = timerDic[_frameRate];
        if (timer == null) 
        {
            timer = new Timer(1000 / _frameRate);
            timerDic[_frameRate] = timer;
            timerEventCount[_frameRate] = 0;
        }
        if (!timer.running) 
            timer.start();
        timer.addEventListener(TimerEvent.TIMER, render);
        timerEventCount[_frameRate]++;
        eventListenerAdded = true;
    }
    
    /**
	* 执行一次渲染
	*/
    private function render(evt : TimerEvent) : Void
    {
        var total : Int = totalFrames;
        if (total <= 1 || !visible) 
            return;
        if (_currentFrame < total - 1) 
        {
            gotoFrame(_currentFrame + 1);
        }
        else 
        {
            gotoFrame(0);
        }
        var lastFrame : Bool = (_currentFrame >= total - 1);
        if (lastFrame) 
        {
            if (!_repeatPlay) 
            {
                checkEventListener(true);
            }
        }
        var callBack : Void->Void = callBackList[_currentFrame];
        if (callBack != null) 
        {
            callBack();
        }
        if (lastFrame) 
        {
            if (hasEventListener(MovieClipPlayEvent.PLAY_COMPLETE)) 
            {
                var event : MovieClipPlayEvent = new MovieClipPlayEvent(MovieClipPlayEvent.PLAY_COMPLETE);
                dispatchEvent(event);
            }
        }
    }
    
    /**
	* 应用当前帧的位图数据
	*/
    private function applyCurrentFrameData() : Void
    {
        var bitmapData : BitmapData = dxrData.getBitmapData(_currentFrame);
        var pos : Point = dxrData.getFrameOffset(_currentFrame);
        var sizeOffset : Point = dxrData.getFilterOffset(_currentFrame);
        if (sizeOffset == null) 
            sizeOffset = zeroPoint;
        filterWidth = sizeOffset.x;
        filterHeight = sizeOffset.y;
        _width = Math.round((bitmapData.width - sizeOffset.x) * frameScaleX);
        _height = Math.round((bitmapData.height - sizeOffset.y) * frameScaleY);
        widthChanged = false;
        heightChanged = false;
        if (useScale9Grid) 
        {
            if (smoothingChanged) 
            {
                smoothingChanged = false;
                s9gBitmapContent.smoothing = _smoothing;
            }
            if (_width == 0 || _height == 0) 
            {
                s9gBitmapContent.bitmapData = null;
                return;
            }
            s9gBitmapContent.scale9Grid = dxrData.scale9Grid;
            s9gBitmapContent.offsetPoint = pos;
            s9gBitmapContent.width = _width + sizeOffset.x;
            s9gBitmapContent.height = _height + sizeOffset.y;
            s9gBitmapContent.bitmapData = bitmapData;
        }
        else 
        {
            if (_width == 0 || _height == 0) 
            {
                bitmapContent.bitmapData = null;
                return;
            }
            bitmapContent.x = pos.x;
            bitmapContent.y = pos.y;
            bitmapContent.bitmapData = bitmapData;
            if (_smoothing) 
                bitmapContent.smoothing = _smoothing;
            bitmapContent.width = _width + sizeOffset.x;
            bitmapContent.height = _height + sizeOffset.y;
        }
    }
    
    private var widthChanged : Bool = false;
    /**
	* 显式设置的宽度
	*/
    private var widthExplicitSet : Bool;
    
    private var _width : Float;
    
    /**
	* @inheritDoc
	*/
    #if flash
	@:getter(width) 
	#else
	override 
	#end
	private function get_width() : Float
    {
        return MathUtil.escapeNaN(_width);
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(width) private function set_width(value : Float) : Void
    {
        if (value == _width) 
            return;
        _width = value;
        widthExplicitSet = !Math.isNaN(value);
        if (widthExplicitSet) 
        {
            if (_dxrData != null) 
                frameScaleX = _width / (_dxrData.getBitmapData(0).width - initFilterWidth);
        }
        else 
        {
            frameScaleX = 1;
        }
        
        widthChanged = true;
        invalidateProperties();
    }
	#else
	override private function set_width(value : Float) : Float
    {
        if (value == _width) 
            return value;
        _width = value;
        widthExplicitSet = !Math.isNaN(value);
        if (widthExplicitSet) 
        {
            if (_dxrData != null) 
                frameScaleX = _width / (_dxrData.getBitmapData(0).width - initFilterWidth);
        }
        else 
        {
            frameScaleX = 1;
        }
        
        widthChanged = true;
        invalidateProperties();
        return value;
    } 
	#end
    
    
    private var heightChanged : Bool = false;
    /**
	* 显式设置的高度
	*/
    private var heightExplicitSet : Bool;
    
    private var _height : Float;
    
    /**
	* @inheritDoc
	*/
    #if flash
	@:getter(height) 
	#else
	override 
	#end
	private function get_height() : Float
    {
        return MathUtil.escapeNaN(_height);
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(height) private function set_height(value : Float) : Void
    {
        if (_height == value) 
            return;
        _height = value;
        heightExplicitSet = !Math.isNaN(value);
        if (heightExplicitSet) 
        {
            if (_dxrData != null) 
                frameScaleY = _height / (_dxrData.getBitmapData(0).height - initFilterHeight);
        }
        else 
        {
            frameScaleY = 1;
        }
        widthChanged = true;
        invalidateProperties();
    }
	#else
	override private function set_height(value : Float) : Float
    {
        if (_height == value) 
            return value;
        _height = value;
        heightExplicitSet = !Math.isNaN(value);
        if (heightExplicitSet) 
        {
            if (_dxrData != null) 
                frameScaleY = _height / (_dxrData.getBitmapData(0).height - initFilterHeight);
        }
        else 
        {
            frameScaleY = 1;
        }
        widthChanged = true;
        invalidateProperties();
        return value;
    } 
	#end
    
    private var invalidateFlag : Bool = false;
    /**
	* 标记有属性变化需要延迟应用
	*/
    private function invalidateProperties() : Void
    {
        if (!invalidateFlag) 
        {
            invalidateFlag = true;
            addEventListener(Event.ENTER_FRAME, validateProperties);
            if (stage != null) 
            {
                addEventListener(Event.RENDER, validateProperties);
                stage.invalidate();
            }
        }
    }
    
    /**
	* 立即应用所有标记为延迟验证的属性
	*/
    public function validateNow() : Void
    {
        if (invalidateFlag) 
            validateProperties();
    }
    
    /**
	* 延迟应用属性事件
	*/
    private function validateProperties(event : Event = null) : Void
    {
        removeEventListener(Event.RENDER, validateProperties);
        removeEventListener(Event.ENTER_FRAME, validateProperties);
        commitProperties();
        invalidateFlag = false;
    }
    /**
	* 延迟应用属性
	*/
    private function commitProperties() : Void
    {
        if (widthChanged || heightChanged || smoothingChanged) 
        {
            if (dxrData != null) 
            {
                applyCurrentFrameData();
            }
        }
    }
    
    private var _currentFrame : Int = 0;
    /**
	* @inheritDoc
	*/
    private function get_currentFrame() : Int
    {
        return _currentFrame;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_totalFrames() : Int
    {
        return (dxrData != null) ? dxrData.totalFrames : 0;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_frameLabels() : Array<Dynamic>
    {
        return (dxrData != null) ? dxrData.frameLabels : [];
    }
    
    /**
	* 是否停止播放
	*/
    private var isStop : Bool = false;
    
    private var _repeatPlay : Bool = true;
    /**
	* @inheritDoc
	*/
    private function get_repeatPlay() : Bool
    {
        return _repeatPlay;
    }
    private function set_repeatPlay(value : Bool) : Bool
    {
        if (value == _repeatPlay) 
            return value;
        _repeatPlay = value;
        return value;
    }
    /**
	* @inheritDoc
	*/
    public function gotoAndPlay(frame : Dynamic) : Void
    {
        gotoFrame(frame);
        play();
    }
    /**
	* @inheritDoc
	*/
    public function gotoAndStop(frame : Dynamic) : Void
    {
        gotoFrame(frame);
        stop();
    }
    /**
	* @inheritDoc
	*/
    public function play() : Void
    {
        isStop = false;
        checkEventListener();
    }
    /**
	* @inheritDoc
	*/
    public function stop() : Void
    {
        isStop = true;
        checkEventListener();
    }
    /**
	* 帧回调函数列表
	*/
    private var callBackList : Array<Void->Void> = [];
    /**
	* @inheritDoc
	*/
    public function addFrameScript(frame : Int, callBack : Void->Void) : Void
    {
        callBackList[frame] = callBack;
    }
    
    /**
	* 帧标签字典索引
	*/
    private var frameLabelDic : StringMap<Int>;
    /**
	* 跳到指定帧
	*/
    private function gotoFrame(frame : Dynamic) : Void
    {
        if (_dxrData == null) 
            return;
        if (Std.is(frame, Int)) 
        {
            _currentFrame = Std.parseInt(frame);
        }
        else if (frameLabelDic != null && frameLabelDic.exists(Std.string(frame))) 
        {
            _currentFrame = frameLabelDic.get(Std.string(frame));
        }
        else 
        {
            return;
        }
		
        if (_currentFrame < 0) 
            _currentFrame = 0;
        if (_currentFrame > totalFrames - 1) 
            _currentFrame = totalFrames - 1;
        applyCurrentFrameData();
    }
    
	public function getBitmapData() : BitmapData
	{
		return (dxrData != null) ? dxrData.getBitmapData(_currentFrame) : null;
	}
	
    /**
	* 滤镜宽度
	*/
    private var filterWidth : Float = 0;
    /**
	* @inheritDoc
	*/
    private function get_measuredWidth() : Float
    {
        if (getBitmapData() != null) 
            return getBitmapData().width - filterWidth;
        return 0;
    }
    /**
	* 滤镜高度
	*/
    private var filterHeight : Float = 0;
    /**
	* @inheritDoc
	*/
    private function get_measuredHeight() : Float
    {
        if (getBitmapData() != null) 
            return getBitmapData().height - filterHeight;
        return 0;
    }
}
