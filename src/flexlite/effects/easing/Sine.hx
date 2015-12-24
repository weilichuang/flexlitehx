package flexlite.effects.easing;


/**
* Sine 类使用 Sine 函数定义缓动功能。<br/>
* 缓动包括两个阶段：加速，或缓入阶段，接着是减速，或缓出阶段。使用 easeInFraction 属性指定动画加速的百分比。
* @author weilichuang
*/
class Sine extends EaseInOutBase
{
    /**
	* 构造函数
	* @param easeInFraction 缓入过程所占动画播放时间的百分比。剩余即为缓出的时间。
	*/
    public function new(easeInFraction : Float = 0.5)
    {
        super(easeInFraction);
    }
    
    /**
	* @inheritDoc
	*/
    override private function easeIn(fraction : Float) : Float
    {
        return 1 - Math.cos(fraction * Math.PI * 0.5);
    }
    
    /**
	* @inheritDoc
	*/
    override private function easeOut(fraction : Float) : Float
    {
        return Math.sin(fraction * Math.PI * 0.5);
    }
}

