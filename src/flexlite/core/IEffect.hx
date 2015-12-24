package flexlite.core;


import flash.events.IEventDispatcher;

/**
* 动画特效接口
* @author weilichuang
*/
interface IEffect extends IEventDispatcher
{
    
    
    /**
	* 要应用此动画特效的对象。若要将特效同时应用到多个对象，请使用targets属性。
	*/
    var target(get, set) : Dynamic;    
    
    /**
	* 要应用此动画特效的多个对象列表。
	*/
    var targets(get, set) : Array<Dynamic>;    
    
    /**
	* 动画持续时间,单位毫秒，默认值500
	*/
    var duration(get, set) : Float;    
    /**
	* 是否正在播放动画，不包括延迟等待和暂停的阶段。
	*/
    var isPlaying(get, never) : Bool;    
    /**
	* 动画已经开始的标志，包括延迟等待和暂停的阶段。
	*/
    var started(get, never) : Bool;    
    /**
	* 正在暂停中
	*/
    var isPaused(get, never) : Bool;    
    /**
	* 正在反向播放。
	*/
    var isReverse(get, never) : Bool;

    /**
	* 开始正向播放动画,无论何时调用都重新从零时刻开始，若设置了延迟会首先进行等待。
	*/
    function play(targets : Array<Dynamic> = null) : Void;
    /**
	* 仅当动画已经在播放中时有效，从当前位置开始沿motionPaths定义的路径反向播放。
	*/
    function reverse() : Void;
    /**
	* 直接跳到动画结尾
	*/
    function end() : Void;
    /**
	* 停止播放动画
	*/
    function stop() : Void;
    /**
	* 暂停播放
	*/
    function pause() : Void;
    /**
	* 继续播放
	*/
    function resume() : Void;
    /**
	* 重置所有属性为初始状态。若正在播放中，同时立即停止动画。
	*/
    function reset() : Void;
}
