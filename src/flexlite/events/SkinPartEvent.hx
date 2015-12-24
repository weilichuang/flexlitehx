package flexlite.events;


import flash.events.Event;

/**
* 皮肤组件附加移除事件
* @author weilichuang
*/
class SkinPartEvent extends Event
{
    /**
	* 附加皮肤公共子部件 
	*/
    public static inline var PART_ADDED : String = "partAdded";
    /**
	* 移除皮肤公共子部件 
	*/
    public static inline var PART_REMOVED : String = "partRemoved";
    
    public function new(type : String, bubbles : Bool = false,
            cancelable : Bool = false,
            partName : String = null,
            instance : Dynamic = null)
    {
        super(type, bubbles, cancelable);
        
        this.partName = partName;
        this.instance = instance;
    }
    
    /**
	* 被添加或移除的皮肤组件实例
	*/
    public var instance : Dynamic;
    
    /**
	* 被添加或移除的皮肤组件的实例名
	*/
    public var partName : String;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new SkinPartEvent(type, bubbles, cancelable, 
        partName, instance);
    }
}
