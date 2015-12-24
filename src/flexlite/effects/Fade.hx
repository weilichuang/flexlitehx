package flexlite.effects;



import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.supportclasses.Effect;

using Reflect;

/**
* 淡入淡出特效，此动画作用于对象的alpha属性。
* @author weilichuang
*/
@:meta(DXML(show="false"))
class Fade extends Effect
{
    /**
	* 构造函数
	* @param target 要应用此动画特效的对象
	*/
    public function new(target : Dynamic = null)
    {
        super(target);
    }
    /**
	* alpha起始值。若不设置，则使用目标对象的当前alpha值。
	*/
    public var alphaFrom : Float = Math.NaN;
    /**
	* alpha结束值。若不设置，则使用目标对象的当前alpha值。
	*/
    public var alphaTo : Float = Math.NaN;
    
    /**
	* @inheritDoc
	*/
    override public function reset() : Void
    {
        super.reset();
        alphaFrom = alphaTo = Math.NaN;
    }
    
    /**
	* @inheritDoc
	*/
    override private function createMotionPath() : Array<MotionPath>
    {
        var alphaFromSet : Bool = !Math.isNaN(alphaFrom);
        var alphaToSet : Bool = !Math.isNaN(alphaTo);
        
        var index : Int = 0;
        var motionPaths : Array<MotionPath> = new Array<MotionPath>();
        var alphaStart : Float = alphaFrom;
        var alphaEnd : Float = alphaTo;
        for (target in _targets)
        {
            if (!alphaFromSet) 
                alphaStart = target.getProperty("alpha");
            if (!alphaToSet) 
                alphaEnd = target.getProperty("alpha");
				
            motionPaths.push(new MotionPath("alpha" + index, alphaStart, alphaEnd));
            index++;
        }
        return motionPaths;
    }
    
    /**
	* @inheritDoc
	*/
    override private function animationUpdateHandler(animation : Animation) : Void
    {
        var index : Int = 0;
        for (target in _targets)
        {
			var value:Dynamic = animation.currentValue.getProperty("alpha" + index);
            target.setProperty("alpha", value);
            index++;
        }
    }
}
