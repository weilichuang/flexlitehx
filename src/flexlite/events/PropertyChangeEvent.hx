package flexlite.events;


import flash.events.Event;

/**
* 对象的一个属性发生更改时传递到事件侦听器的事件
* @author weilichuang
*/
class PropertyChangeEvent extends Event
{
    /**
	* 属性改变 
	*/
    public static inline var PROPERTY_CHANGE : String = "propertyChange";
    
    /**
	* 返回使用指定属性构建的 PropertyChangeEventKind.UPDATE 类型的新 PropertyChangeEvent。 
	* @param source 发生更改的对象。
	* @param property 指定已更改属性的 String、QName 或 int。
	* @param oldValue 更改前的属性的值。
	* @param newValue 更改后的属性的值。
	*/
    public static function createUpdateEvent(
            source : Dynamic,
            property : Dynamic,
            oldValue : Dynamic,
            newValue : Dynamic) : PropertyChangeEvent
    {
        var event : PropertyChangeEvent = 
        new PropertyChangeEvent(PROPERTY_CHANGE);
        
        event.kind = PropertyChangeEventKind.UPDATE;
        event.oldValue = oldValue;
        event.newValue = newValue;
        event.source = source;
        event.property = property;
        
        return event;
    }
    
    /**
	* 构造函数
	*/
    public function new(type : String, bubbles : Bool = false,
            cancelable : Bool = false,
            kind : String = null,
            property : Dynamic = null,
            oldValue : Dynamic = null,
            newValue : Dynamic = null,
            source : Dynamic = null)
    {
        super(type, bubbles, cancelable);
        
        this.kind = kind;
        this.property = property;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.source = source;
    }
    
    /**
	* 指定更改的类型。可能的值为 PropertyChangeEventKind.UPDATE、PropertyChangeEventKind.DELETE 和 null。 
	*/
    public var kind : String;
    
    /**
	* 更改后的属性的值。 
	*/
    public var newValue : Dynamic;
    
    /**
	* 更改后的属性的值。 
	*/
    public var oldValue : Dynamic;
    
    /**
	* 指定已更改属性的 String、QName 或 int。 
	*/
    public var property : Dynamic;
    
    /**
	* 发生更改的对象。 
	*/
    public var source : Dynamic;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new PropertyChangeEvent(type, bubbles, cancelable, kind, 
        property, oldValue, newValue, source);
    }
}
