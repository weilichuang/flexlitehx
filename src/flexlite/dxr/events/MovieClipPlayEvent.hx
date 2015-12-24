package flexlite.dxr.events;


import flash.events.Event;

/**
* IMoveClip播放事件
* @author weilichuang
*/
class MovieClipPlayEvent extends Event
{
    /**
	* IMoveClip一次播放完成。
	*/
    public static inline var PLAY_COMPLETE : String = "playComplete";
    
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
}
