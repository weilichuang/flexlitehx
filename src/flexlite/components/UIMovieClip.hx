package flexlite.components;


import flash.display.MovieClip;

import flexlite.core.IMovieClip;
import flexlite.events.UIEvent;

@:meta(DXML(show="true"))


/**
* UIMoveClip一次播放完成事件。仅当UIMovieClip.totalFrames>1时会抛出此事件。 
*/
@:meta(Event(name="playComplete",type="flexlite.events.UIEvent"))

/**
* 影片剪辑素材包装器,通常用于在UI中控制动画素材的播放。
* @author weilichuang
*/
class UIMovieClip extends UIAsset implements IMovieClip
{
    public var hasContent(get, never) : Bool;
    public var currentFrame(get, never) : Int;
    public var totalFrames(get, never) : Int;
    public var frameLabels(get, never) : Array<Dynamic>;
    public var repeatPlay(get, set) : Bool;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    private var movieClip : Dynamic;
    /**
	* 皮肤是MovieClip对象的标志
	*/
    private var isMovieClip : Bool = false;
    
    override private function onGetSkin(skin : Dynamic, skinName : Dynamic) : Void
    {
        super.onGetSkin(skin, skinName);
        if (movieClip != null) 
            detachMovieClip(movieClip);
        isMovieClip = (Std.is(skin, MovieClip));
        if (isMovieClip || Std.is(skin, IMovieClip)) 
        {
            movieClip = skin;
        }
        else 
        {
            movieClip = null;
        }
        _totalFrames = 0;
        _frameLabels = [];
        if (movieClip != null) 
            attachMovieClip(movieClip);
        actionCache = [];
    }
    
    private var actionCache : Array<Dynamic> = [];
    /**
	* 缓存一条动画操作记录
	*/
    private function pushAction(func : Dynamic, args : Array<Dynamic> = null) : Void
    {
        actionCache.push({
                    func : func,
                    args : args,

                });
    }
    
    /**
	* 附加影片剪辑
	*/
    private function attachMovieClip(movieClip : Dynamic) : Void
    {
        _totalFrames = movieClip.totalFrames;
        if (movieClip != null) 
        {
            if (isMovieClip) 
                _frameLabels = movieClip.currentLabels;
            else 
				_frameLabels = movieClip.frameLabels;
        }
		
		for (frame in 0...frameMarkList.length)
		{
			if (frameMarkList[frame])
			{
				if (movieClip.totalFrames - 1 == frame) 
					movieClip.addFrameScript(frame, endCallBackFunction)
				else 
					movieClip.addFrameScript(frame, callBackFunction);
			}
		}

        if (_totalFrames > 1) 
        {
            addCallBackAtFrame(Std.int(movieClip.totalFrames - 1));
        }
		
        if (!isMovieClip) 
        {
            movieClip.repeatPlay = _repeatPlay;
        }
		
        for (ac in actionCache)
        {
            if (ac.args == null) 
                ac.func();
            else 
				Reflect.callMethod(null, ac.func, ac.args);
        }
    }
    
    /**
	* 卸载影片剪辑
	*/
    private function detachMovieClip(movieClip : Dynamic) : Void
    {
		for (frame in 0...frameMarkList.length)
		{
			if (frameMarkList[frame])
			{
				movieClip.addFrameScript(frame, null);
			}
		}
        movieClip = null;
        if (_totalFrames > 1) 
            removeCallBackAtFrame(_totalFrames - 1);
    }
    
    /**
	* 是否含有实体动画显示对象。若为false，则currentFrame，totalFrames和frameLabels属性无效。
	*/
    private function get_hasContent() : Bool
    {
        return movieClip != null;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_currentFrame() : Int
    {
        var frame : Int = 0;
        if (movieClip != null) 
        {
            frame = movieClip.currentFrame;
            if (isMovieClip) 
                frame--;
        }
        return frame;
    }
    
    private var _totalFrames : Int = 0;
    /**
	* @inheritDoc
	*/
    private function get_totalFrames() : Int
    {
        return _totalFrames;
    }
    
    private var _frameLabels : Array<Dynamic> = [];
    /**
	* @inheritDoc
	*/
    private function get_frameLabels() : Array<Dynamic>
    {
        return _frameLabels.concat([]);
    }
    
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
        if (_repeatPlay == value) 
            return value;
        _repeatPlay = value;
        if (movieClip != null) 
        {
            if (!isMovieClip) 
            {
                movieClip.repeatPlay = _repeatPlay;
            }
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    public function gotoAndPlay(frame : Dynamic) : Void
    {
        if (movieClip != null) 
        {
            if (isMovieClip && Std.is(frame, Int)) 
                frame += 1;
            movieClip.gotoAndPlay(frame);
        }
        else 
        pushAction(gotoAndPlay, [frame]);
    }
    
    /**
	* @inheritDoc
	*/
    public function gotoAndStop(frame : Dynamic) : Void
    {
        if (movieClip != null) 
        {
            if (isMovieClip && Std.is(frame, Int)) 
                frame += 1;
            movieClip.gotoAndStop(frame);
        }
        else 
        pushAction(gotoAndStop, [frame]);
    }
    
    /**
	* @inheritDoc
	*/
    public function play() : Void
    {
        if (movieClip != null) 
            movieClip.play()
        else 
        pushAction(play);
    }
    
    /**
	* @inheritDoc
	*/
    public function stop() : Void
    {
        if (movieClip != null) 
            movieClip.stop()
        else 
        pushAction(stop);
    }
    
    /**
	* 添加过回调函数的帧列表
	*/
    private var frameMarkList : Array<Bool> = [];
    /**
	* 帧回调函数列表
	*/
    private var callBackList : Array<Dynamic> = [];
    /**
	* @inheritDoc
	*/
    public function addFrameScript(frame : Int, callBack : Void->Void) : Void
    {
        if (callBack == null) 
        {
			callBackList[frame] = null;
            removeCallBackAtFrame(frame);
        }
        else 
        {
            callBackList[frame] = callBack;
            addCallBackAtFrame(frame);
        }
    }
    /**
	* 标记某一帧需要回调
	*/
    private function addCallBackAtFrame(frame : Int) : Void
    {
        if (frameMarkList[frame]) 
            return;
			
        frameMarkList[frame] = true;
        if (movieClip != null) 
        {
            if (_totalFrames - 1 == frame) 
                movieClip.addFrameScript(frame, endCallBackFunction)
            else 
            movieClip.addFrameScript(frame, callBackFunction);
        }
    }
    /**
	* 移除某一帧的回调
	*/
    private function removeCallBackAtFrame(frame : Int) : Void
    {
        if (!frameMarkList[frame]) 
            return;
			
        if (movieClip != null && _totalFrames - 1 == frame || callBackList[frame] != null) 
            return;
			
        frameMarkList[frame] = false;
		
        if (movieClip != null) 
        {
            movieClip.addFrameScript(frame, null);
        }
    }
    /**
	* 回调函数
	*/
    private function callBackFunction() : Void
    {
        var func : Dynamic = callBackList[currentFrame];
        if (func != null) 
        {
            func();
        }
    }
    /**
	* 帧末回调函数
	*/
    private function endCallBackFunction() : Void
    {
        if (!_repeatPlay && isMovieClip) 
        {
            movieClip.stop();
        }
        callBackFunction();
        
        if (hasEventListener(UIEvent.PLAY_COMPLETE)) 
        {
            var event : UIEvent = new UIEvent(UIEvent.PLAY_COMPLETE);
            dispatchEvent(event);
        }
    }
}
