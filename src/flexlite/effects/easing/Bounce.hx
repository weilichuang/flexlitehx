package flexlite.effects.easing;

import flexlite.effects.easing.IEaser;

/**
* Bounce 类实现缓动功能，该功能模拟目标对象上的重力牵引和回弹目标对象。效果目标的移动会向着最终值加速，然后对着最终值回弹几次。
* @author weilichuang
*/
class Bounce implements IEaser
{
    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    public function ease(fraction : Float) : Float
    {
        return easeOut(fraction, 0, 1, 1);
    }
    
    public function easeOut(t : Float, b : Float,
            c : Float, d : Float) : Float
    {
        if ((t /= d) < (1 / 2.75)) 
            return c * (7.5625 * t * t) + b
        else if (t < (2 / 2.75)) 
            return c * (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75) + b
        else if (t < (2.5 / 2.75)) 
            return c * (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375) + b
        else 
			return c * (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375) + b;
    }
}
