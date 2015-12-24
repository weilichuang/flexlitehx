package flexlite.core;


import flash.events.IEventDispatcher;

/**
* 影片剪辑接口
* @author weilichuang
*/
interface IMovieClip extends IEventDispatcher
{
    
    /**
	* 当前播放到的帧索引,从0开始
	*/
    var currentFrame(get, never) : Int;    
    /**
	* 动画总帧数
	*/
    var totalFrames(get, never) : Int;    
    /**
	* 返回由FrameLabel对象组成的数组。数组包括整个Dxr动画实例的所有帧标签。
	*/
    var frameLabels(get, never) : Array<Dynamic>;    
    
    /**
	* 是否循环播放,默认为true。
	*/
    var repeatPlay(get, set) : Bool;

    /**
	* 跳到指定帧并播放
	* @param frame 可以是帧索引或者帧标签，帧索引从0开始。
	*/
    function gotoAndPlay(frame : Dynamic) : Void;
    /**
	* 跳到指定帧并停止
	* @param frame 可以是帧索引或者帧标签，帧索引从0开始。
	*/
    function gotoAndStop(frame : Dynamic) : Void;
    /**
	* 从当期帧开始播放
	*/
    function play() : Void;
    /**
	* 在当前帧停止播放
	*/
    function stop() : Void;
    /**
	* 为指定帧添加回调函数。注意：同一帧只能添加一个回调函数。后添加的回调函数将会覆盖之前的。
	* @param frame 要添加回调的帧索引，从0开始。
	* @param callBack 回调函数。设置为null，将取消之前添加的回调函数。
	*/
    function addFrameScript(frame : Int, callBack : Void->Void) : Void;
}
