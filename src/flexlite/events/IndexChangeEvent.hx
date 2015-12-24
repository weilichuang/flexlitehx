package flexlite.events;


import flash.events.Event;

/**
* 索引改变事件
* @author weilichuang
*/
class IndexChangeEvent extends Event
{
    /**
	* 指示索引已更改 
	*/
    public static inline var CHANGE : String = "change";
    
    /**
	* 指示索引即将更改,可以通过调用preventDefault()方法阻止索引发生更改
	*/
    public static inline var CHANGING : String = "changing";
    
    public function new(type : String, bubbles : Bool = false,
            cancelable : Bool = false,
            oldIndex : Int = -1,
            newIndex : Int = -1)
    {
        super(type, bubbles, cancelable);
        
        this.oldIndex = oldIndex;
        this.newIndex = newIndex;
    }
    
    /**
	* 进行更改之后的从零开始的索引。
	*/
    public var newIndex : Int;
    
    /**
	* 进行更改之前的从零开始的索引。
	*/
    public var oldIndex : Int;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new IndexChangeEvent(type, bubbles, cancelable, 
        oldIndex, newIndex);
    }
}
