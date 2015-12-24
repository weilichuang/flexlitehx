package flexlite.effects.animation;


/**
* 数值运动路径。用于定义需要在Animation类中缓动的数值范围。
* @author weilichuang
*/
class MotionPath
{
    public var property(get, set) : String;
    public var valueFrom(get, set) : Float;
    public var valueTo(get, set) : Float;

	private var _property : String;
	private var _valueFrom : Float;
	private var _valueTo : Float;
	
    /**
	* 构造函数
	* @param property 正在设置动画的属性的名称。
	* @param valueFrom 缓动的起始值
	* @param valueTo 缓动的结束值
	*/
    public function new(property : String = null, valueFrom : Float = 0, valueTo : Float = 1)
    {
        _property = property;
        _valueFrom = valueFrom;
        _valueTo = valueTo;
    }
    
    /**
	* 正在设置动画的属性的名称。
	*/
    private inline function get_property() : String
    {
        return _property;
    }
    
    private inline function set_property(value : String) : String
    {
        return _property = value;
    }
    
    /**
	* 缓动的起始值
	*/
    private inline function get_valueFrom() : Float
    {
        return _valueFrom;
    }
    
    private inline function set_valueFrom(value : Float) : Float
    {
        return _valueFrom = value;
    }
    
    /**
	* 缓动的结束值
	*/
    private inline function get_valueTo() : Float
    {
        return _valueTo;
    }
    
    private inline function set_valueTo(value : Float) : Float
    {
        return _valueTo = value;
    }
}
