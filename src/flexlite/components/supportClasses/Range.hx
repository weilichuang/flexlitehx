package flexlite.components.supportclasses;


import flexlite.components.SkinnableComponent;

@:meta(DXML(show="false"))


/**
* 范围选取组件,该组件包含一个值和这个值所允许的最大最小约束范围。
* @author weilichuang
*/
class Range extends SkinnableComponent
{
    public var maximum(get, set) : Float;
    public var minimum(get, set) : Float;
    public var stepSize(get, set) : Float;
    public var value(get, set) : Float;
    public var snapInterval(get, set) : Float;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        focusEnabled = true;
    }
    
    private var _maximum : Float = 100;
    
    /**
	* 最大有效值改变标志
	*/
    private var maxChanged : Bool = false;
    
    /**
	* 最大有效值
	*/
    private function get_maximum() : Float
    {
        return _maximum;
    }
    
    private function set_maximum(value : Float) : Float
    {
        if (value == _maximum) 
            return value;
        
        _maximum = value;
        maxChanged = true;
        
        invalidateProperties();
        return value;
    }
    
    private var _minimum : Float = 0;
    
    /**
	* 最小有效值改变标志 
	*/
    private var minChanged : Bool = false;
    
    /**
	* 最小有效值
	*/
    private function get_minimum() : Float
    {
        return _minimum;
    }
    
    private function set_minimum(value : Float) : Float
    {
        if (value == _minimum) 
            return value;
        
        _minimum = value;
        minChanged = true;
        
        invalidateProperties();
        return value;
    }
    
    private var _stepSize : Float = 1;
    
    /**
	* 单步大小改变的标志
	*/
    private var stepSizeChanged : Bool = false;
    
    /**
	* 调用 changeValueByStep() 方法时 value 属性更改的单步大小。默认值为 1。<br/>
	* 除非 snapInterval 为 0，否则它必须是 snapInterval 的倍数。<br/>
	* 如果 stepSize 不是倍数，则会将它近似到大于或等于 snapInterval 的最近的倍数。<br/>
	*/
    private function get_stepSize() : Float
    {
        return _stepSize;
    }
    
    private function set_stepSize(value : Float) : Float
    {
        if (value == _stepSize) 
            return value;
        
        _stepSize = value;
        stepSizeChanged = true;
        
        invalidateProperties();
        return value;
    }
    
    private var _value : Float = 0;
    
    private var _changedValue : Float = 0;
    /**
	* 此范围的当前值改变标志 
	*/
    private var valueChanged : Bool = false;
    /**
	* 此范围的当前值。
	*/
    private function get_value() : Float
    {
        return ((valueChanged)) ? _changedValue : _value;
    }
    
    private function set_value(newValue : Float) : Float
    {
        if (newValue == value) 
            return value;
        _changedValue = newValue;
        valueChanged = true;
        invalidateProperties();
        return newValue;
    }
    
    private var _snapInterval : Float = 1;
    
    private var snapIntervalChanged : Bool = false;
    
    private var _explicitSnapInterval : Bool = false;
    
    /**
	* snapInterval 属性定义 value 属性的有效值。如果为非零，则有效值为 minimum 与此属性的整数倍数之和，且小于或等于 maximum。 <br/>
	* 例如，如果 minimum 为 10，maximum 为 20，而此属性为 3，则可能的有效值为 10、13、16、19 和 20。<br/>
	* 如果此属性的值为零，则仅会将有效值约束到介于 minimum 和 maximum 之间（包括两者）。<br/>
	* 此属性还约束 stepSize 属性（如果设置）的有效值。如果未显式设置此属性，但设置了 stepSize，则 snapInterval 将默认为 stepSize。<br/>
	*/
    private function get_snapInterval() : Float
    {
        return _snapInterval;
    }
    
    private function set_snapInterval(value : Float) : Float
    {
        _explicitSnapInterval = true;
        
        if (value == _snapInterval) 
            return value;
        if (Math.isNaN(value)) 
        {
            _snapInterval = 1;
            _explicitSnapInterval = false;
        }
        else 
        {
            _snapInterval = value;
        }
        
        snapIntervalChanged = true;
        stepSizeChanged = true;
        
        invalidateProperties();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (minimum > maximum) 
        {
            
            if (!maxChanged) 
                _minimum = _maximum
            else 
            _maximum = _minimum;
        }
        
        if (valueChanged || maxChanged || minChanged || snapIntervalChanged) 
        {
            var currentValue : Float = ((valueChanged)) ? _changedValue : _value;
            valueChanged = false;
            maxChanged = false;
            minChanged = false;
            snapIntervalChanged = false;
            setValue(nearestValidValue(currentValue, snapInterval));
        }
        
        if (stepSizeChanged) 
        {
            if (_explicitSnapInterval) 
            {
                _stepSize = nearestValidSize(_stepSize);
            }
            else 
            {
                _snapInterval = _stepSize;
                setValue(nearestValidValue(_value, snapInterval));
            }
            
            stepSizeChanged = false;
        }
    }
    
    /**
	* 修正stepSize到最接近snapInterval的整数倍
	*/
    private function nearestValidSize(size : Float) : Float
    {
        var interval : Float = snapInterval;
        if (interval == 0) 
            return size;
        
        var validSize : Float = Math.round(size / interval) * interval;
        return ((Math.abs(validSize) < interval)) ? interval : validSize;
    }
    
    /**
	* 修正输入的值为有效值
	* @param value 输入值。
	* @param interval snapInterval 的值，或 snapInterval 的整数倍数。
	*/
    private function nearestValidValue(value : Float, interval : Float) : Float
    {
        if (interval == 0) 
            return Math.max(minimum, Math.min(maximum, value));
        
        var maxValue : Float = maximum - minimum;
        var scale : Float = 1;
        
        value -= minimum;
        if (interval != Math.round(interval)) 
        {
            var parts : Array<Dynamic> = Std.string(1 + interval).split(".");
            scale = Math.pow(10, parts[1].length);
            maxValue *= scale;
            value = Math.round(value * scale);
            interval = Math.round(interval * scale);
        }
        
        var lower : Float = Math.max(0, Math.floor(value / interval) * interval);
        var upper : Float = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
        var validValue : Float = (((value - lower) >= ((upper - lower) / 2))) ? upper : lower;
        
        return (validValue / scale) + minimum;
    }
    
    /**
	* 设置当前值。此方法假定调用者已经使用了 nearestValidValue() 方法来约束 value 参数
	* @param value value属性的新值
	*/
    private function setValue(value : Float) : Void
    {
        if (_value == value) 
            return;
        if (Math.isNaN(value)) 
            value = 0;
        if (!Math.isNaN(maximum) && !Math.isNaN(minimum) && (maximum > minimum)) 
            _value = Math.min(maximum, Math.max(minimum, value))
        else 
        _value = value;
        valueChanged = false;
    }
    
    /**
	* 按 stepSize增大或减小当前值
	* @param increase 若为 true，则向value增加stepSize，否则减去它。
	*/
    public function changeValueByStep(increase : Bool = true) : Void
    {
        if (stepSize == 0) 
            return;
        
        var newValue : Float = ((increase)) ? value + stepSize : value - stepSize;
        setValue(nearestValidValue(newValue, snapInterval));
    }
}

