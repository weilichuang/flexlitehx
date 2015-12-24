package flexlite.events;


import flash.events.Event;

/**
* 尺寸改变事件
* @author weilichuang
*/
class ResizeEvent extends Event
{
    public static inline var RESIZE : String = "resize";
    
    public function new(type : String, oldWidth : Float = null, oldHeight : Float = null,
            bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
        
        this.oldWidth = oldWidth;
        this.oldHeight = oldHeight;
    }
    
    /**
	* 旧的高度 
	*/
    public var oldHeight : Float;
    
    /**
	* 旧的宽度 
	*/
    public var oldWidth : Float;
    
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new ResizeEvent(type, oldWidth, oldHeight, bubbles, cancelable);
    }
}
