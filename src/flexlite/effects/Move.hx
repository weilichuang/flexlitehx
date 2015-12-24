package flexlite.effects;



import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.supportclasses.Effect;

using Reflect;

/**
* 移动特效
* @author weilichuang
*/
@:meta(DXML(show="false"))
class Move extends Effect
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
	* 要在y轴移动的距离，可以为负值。 
	*/
    public var yBy : Float = Math.NaN;
    /**
	* 开始移动时y轴的起始坐标。若不设置，则使用目标对象的当前y坐标或根据其他值计算出此值。
	*/
    public var yFrom : Float = Math.NaN;
    /**
	* 移动结束时y轴要到的坐标。若不设置，则使用目标对象的当前y坐标或根据其他值计算出此值。
	*/
    public var yTo : Float = Math.NaN;
    /**
	* 要在x轴移动的距离，可以为负值。 
	*/
    public var xBy : Float = Math.NaN;
    /**
	* 开始移动时x轴的起始坐标。若不设置，则使用目标对象的当前x坐标或根据其他值计算出此值。
	*/
    public var xFrom : Float = Math.NaN;
    /**
	* 移动结束时x轴要到的坐标。若不设置，则使用目标对象的当前x坐标或根据其他值计算出此值。
	*/
    public var xTo : Float = Math.NaN;
    /**
	* @inheritDoc
	*/
    override public function reset() : Void
    {
        super.reset();
        yBy = yFrom = yTo = xBy = xFrom = xTo = Math.NaN;
    }
    /**
	* @inheritDoc
	*/
    override private function createMotionPath() : Array<MotionPath>
    {
        var xFromSet : Bool = !Math.isNaN(xFrom);
        var xToSet : Bool = !Math.isNaN(xTo);
        var yFromSet : Bool = !Math.isNaN(yFrom);
        var yToSet : Bool = !Math.isNaN(yTo);
        
        var xFromUseTarget : Bool = !xFromSet && (Math.isNaN(xTo) || Math.isNaN(xBy));
        var xToUseTarget : Bool = !xToSet && Math.isNaN(xBy);
        var yFromUseTarget : Bool = !yFromSet && (Math.isNaN(yTo) || Math.isNaN(yBy));
        var yToUseTarget : Bool = !yToSet && Math.isNaN(yBy);
        
        var xStart : Float = (xFromSet) ? xFrom : xTo - xBy;
        var yStart : Float = (yFromSet) ? yFrom : yTo - yBy;
        var xEnd : Float;
        var yEnd : Float;
        var index : Int = 0;
        var motionPaths : Array<MotionPath> = new Array<MotionPath>();
        for (target in _targets)
        {
            if (xFromUseTarget) 
                xStart = target.getProperty("x");
				
            if (xToUseTarget) 
                xEnd = target.getProperty("x");
            else if (xToSet) 
                xEnd = xTo;
            else 
				xEnd = xStart + xBy;
				
            motionPaths.push(new MotionPath("x" + index, xStart, xEnd));
            
            if (yFromUseTarget) 
                yStart = target.getProperty("y");
            if (yToUseTarget) 
                yEnd = target.getProperty("y");
            else if (yToSet) 
                yEnd = yTo;
            else 
				yEnd = yStart + yBy;
				
            motionPaths.push(new MotionPath("y" + index, yStart, yEnd));
            index++;
        }
        return motionPaths;
    }
    
    /**
	* @inheritDoc
	*/
    override private function animationUpdateHandler(animation : Animation) : Void
    {
		var value:Dynamic = animation.currentValue;
        var index : Int = 0;
        for (target in _targets)
        {
            target.setProperty("x", Math.round(value.getProperty("x" + index)));
            target.setProperty("y", Math.round(value.getProperty("y" + index)));
            index++;
        }
    }
}
