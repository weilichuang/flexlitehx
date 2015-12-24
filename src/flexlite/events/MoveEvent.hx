package flexlite.events;


import flash.events.Event;

/**
* 移动事件
* @author weilichuang
*/
class MoveEvent extends Event
{
    public static inline var MOVE : String = "move";
    
    public function new(type : String, oldX : Float = null, oldY : Float = null,
            bubbles : Bool = false,
            cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
        
        this.oldX = oldX;
        this.oldY = oldY;
    }
    
    /**
	* 旧的组件X
	*/
    public var oldX : Float;
    
    /**
	* 旧的组件Y
	*/
    public var oldY : Float;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new MoveEvent(type, oldX, oldY, bubbles, cancelable);
    }
}
