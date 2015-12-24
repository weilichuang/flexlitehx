package flexlite.effects.easing;


/**
* Power 类通过使用多项式表达式定义缓动功能。<br/>
* 缓动包括两个阶段：加速，或缓入阶段，接着是减速，或缓出阶段。<br/>
* 加速和减速的速率基于 exponent 属性。exponent 属性的值越大，加速和减速的速率越快。<br/>
* 使用 easeInFraction 属性指定动画加速的百分比。
* @author weilichuang
*/
class Power extends EaseInOutBase
{
    public var exponent(get, set) : Float;

    
    private var _exponent : Float;
    /**
	* 在缓动计算中使用的指数。exponent 属性的值越大，加速和减速的速率越快。
	*/
    private function get_exponent() : Float
    {
        return _exponent;
    }
    
    private function set_exponent(value : Float) : Float
    {
        _exponent = value;
        return value;
    }
    
    /**
	* 构造函数
	* @param easeInFraction 在加速阶段中整个持续时间的部分，在 0.0 和 1.0 之间。
	* @param exponent 在缓动计算中使用的指数。exponent 属性的值越大，加速和减速的速率越快。
	* 
	*/
    public function new(easeInFraction : Float = 0.5, exponent : Float = 2)
    {
        super(easeInFraction);
        this.exponent = exponent;
    }
    
    /**
	* @inheritDoc
	*/
    override private function easeIn(fraction : Float) : Float
    {
        return Math.pow(fraction, _exponent);
    }
    
    /**
	* @inheritDoc
	*/
    override private function easeOut(fraction : Float) : Float
    {
        return 1 - Math.pow((1 - fraction), _exponent);
    }
}

