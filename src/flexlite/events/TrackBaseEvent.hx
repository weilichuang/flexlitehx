package flexlite.events;


import flash.events.Event;
/**
* 从TrackBase组件分派的事件。
* @author weilichuang
*/
class TrackBaseEvent extends Event
{
    /**
	* 正在拖拽滑块
	*/
    public static inline var THUMB_DRAG : String = "thumbDrag";
    
    /**
	* 滑块被按下 
	*/
    public static inline var THUMB_PRESS : String = "thumbPress";
    
    /**
	* 滑块被放开
	*/
    public static inline var THUMB_RELEASE : String = "thumbRelease";
    
    /**
	* 构造函数
	*/
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new TrackBaseEvent(type, bubbles, cancelable);
    }
}


