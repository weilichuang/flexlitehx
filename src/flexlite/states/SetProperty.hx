package flexlite.states;


import flexlite.core.IContainer;

/**
* 设置属性
* @author weilichuang
*/
class SetProperty extends OverrideBase
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    /**
	* 要修改的属性名
	*/
    public var name : String;
    
    /**
	* 目标实例名
	*/
    public var target : String;
    
    /**
	* 属性值 
	*/
    public var value : Dynamic;
    
    /**
	* 旧的属性值 
	*/
    private var oldValue : Dynamic;
    
    override public function apply(parent : IContainer) : Void
    {
        var obj : Dynamic = (target == null || target == "") ? parent : Reflect.field(parent, target);
        if (obj == null) 
            return;
        oldValue = Reflect.field(obj, name);
        setPropertyValue(obj, name, value, oldValue);
    }
    
    override public function remove(parent : IContainer) : Void
    {
        var obj : Dynamic = (target == null || target == "") ? parent : Reflect.field(parent, target);
        if (obj == null) 
            return;
        setPropertyValue(obj, name, oldValue, oldValue);
        oldValue = null;
    }
    
    /**
	* 设置属性值
	*/
    private function setPropertyValue(obj : Dynamic, name : String, value : Dynamic, valueForType : Dynamic) : Void
    {
        if (value == null) 
            Reflect.setField(obj, name, value)
        else if (Std.is(valueForType, Float)) 
            Reflect.setField(obj, name, Std.parseFloat(value))
        else if (Std.is(valueForType, Bool)) 
            Reflect.setField(obj, name, toBoolean(value))
        else 
			Reflect.setField(obj, name, value);
    }
    /**
	* 转成Boolean值
	*/
    private function toBoolean(value : Dynamic) : Bool
    {
        if (Std.is(value, String)) 
            return value.toLowerCase() == "true";
        
        return value != false;
    }
}


