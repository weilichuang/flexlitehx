package flexlite.effects.easing;

import flexlite.effects.easing.IEaser;

/**
* EaseInOutBase 类是提供缓动功能的基类。<br/>
* EaseInOutBase 类将缓动定义为由两个阶段组成：加速，或缓入阶段，接着是减速，或缓出阶段。<br/>
* 此类的默认行为会为全部两个缓动阶段返回一个线性插值。
* @author weilichuang
*/
class EaseInOutBase implements IEaser
{
    public var easeInFraction(get, set) : Float;

    /**
	* 构造函数
	* @param easeInFraction 缓入过程所占动画播放时间的百分比。剩余即为缓出的时间。
	* 默认值为 EasingFraction.IN_OUT，它会缓入前一半时间，并缓出剩余的一半时间。
	*/
    public function new(easeInFraction : Float = 0.5)
    {
        this.easeInFraction = easeInFraction;
    }
    
    private var _easeInFraction : Float = .5;
    /**
	* 缓入过程所占动画播放时间的百分比。剩余即为缓出的时间。
	* 有效值为 0.0 到 1.0。
	*/
    private function get_easeInFraction() : Float
    {
        return _easeInFraction;
    }
    
    private function set_easeInFraction(value : Float) : Float
    {
        _easeInFraction = value;
        return value;
    }
    
    public function ease(fraction : Float) : Float
    {
        var easeOutFraction : Float = 1 - _easeInFraction;
        
        if (fraction <= _easeInFraction && _easeInFraction > 0) 
            return _easeInFraction * easeIn(fraction / _easeInFraction)
        else 
			return _easeInFraction + easeOutFraction *
        easeOut((fraction - _easeInFraction) / easeOutFraction);
    }
    /**
	* 在动画的缓入阶段期间计算已经缓动部分要映射到的值。
	*/
    private function easeIn(fraction : Float) : Float
    {
        return fraction;
    }
    
    /**
	* 在动画的缓出阶段期间计算已经缓动部分要映射到的值。
	*/
    private function easeOut(fraction : Float) : Float
    {
        return fraction;
    }
}

