package flexlite.effects;



import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.supportclasses.Effect;

using Reflect;



/**
* 缩放特效,此动画作用于对象的scaleX,scaleY以及x,y属性。
* @author weilichuang
*/
@:meta(DXML(show="false"))
class Scale extends Effect
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
	* 缩放中心点x坐标(相对于scaleX为1时的位置)。若不设置，默认为target.width/2。 
	*/
    public var originX : Float;
    /**
	* 缩放中心点y坐标(相对于scaleY为1时的位置),若不设置，默认为target.height/2。
	*/
    public var originY : Float;
    
    /**
	*  y方向上起始的scale值。若不设置，则使用目标对象的当前scaleY或根据其他值计算出此值。
	*/
    public var scaleYFrom : Float;
    /**
	* y方向上结束的scale值。若不设置，则使用目标对象的当前scaleY或根据其他值计算出此值。
	*/
    public var scaleYTo : Float;
    /**
	* 在y方向上要缩放的量，负值代表缩小。
	*/
    public var scaleYBy : Float;
    /**
	*  x方向上起始的scale值。若不设置，则使用目标对象的当前scaleX或根据其他值计算出此值。
	*/
    public var scaleXFrom : Float;
    /**
	* x方向上结束的scale值。若不设置，则使用目标对象的当前scaleX或根据其他值计算出此值。
	*/
    public var scaleXTo : Float;
    /**
	* 在x方向上要缩放的量，负值代表缩小。
	*/
    public var scaleXBy : Float;
    /**
	* @inheritDoc
	*/
    override public function reset() : Void
    {
        super.reset();
        originX = originY = scaleYFrom = scaleYTo = scaleYBy = scaleXFrom = scaleXTo = scaleXBy = Math.NaN;
    }
    /**
	* @inheritDoc
	*/
    override private function createMotionPath() : Array<MotionPath>
    {
        var motionPath : Array<MotionPath> = new Array<MotionPath>();
        var scaleXFromSet : Bool = !Math.isNaN(scaleXFrom);
        var scaleXToSet : Bool = !Math.isNaN(scaleXTo);
        var scaleYFromSet : Bool = !Math.isNaN(scaleYFrom);
        var scaleYToSet : Bool = !Math.isNaN(scaleYTo);
        var originXSet : Bool = !Math.isNaN(originX);
        var originYSet : Bool = !Math.isNaN(originY);
        
        var scaleXFromUseTarget : Bool = !scaleXFromSet && (Math.isNaN(scaleXTo) || Math.isNaN(scaleXBy));
        var scaleXToUseTarget : Bool = !scaleXToSet && Math.isNaN(scaleXBy);
        var scaleYFromUseTarget : Bool = !scaleYFromSet && (Math.isNaN(scaleYTo) || Math.isNaN(scaleYBy));
        var scaleYToUseTarget : Bool = !scaleYToSet && Math.isNaN(scaleYBy);
        
        var scaleXStart : Float = (scaleXFromSet) ? scaleXFrom : scaleXTo - scaleXBy;
        var scaleYStart : Float = (scaleYFromSet) ? scaleYFrom : scaleYTo - scaleYBy;
        var scaleXEnd : Float;
        var scaleYEnd : Float;
        var orgX : Float;
        var orgY : Float;
        var index : Int = 0;
        var motionPaths : Array<MotionPath> = new Array<MotionPath>();
        for (target in _targets)
        {
            if (scaleXFromUseTarget) 
                scaleXStart = target.getProperty("scaleX");
            if (scaleXToUseTarget) 
                scaleXEnd = target.getProperty("scaleX")
            else if (scaleXToSet) 
                scaleXEnd = scaleXTo
            else 
				scaleXEnd = scaleXStart + scaleXBy;
				
            motionPaths.push(new MotionPath("scaleX" + index, scaleXStart, scaleXEnd));
            
            if (scaleYFromUseTarget) 
                scaleYStart = target.getProperty("scaleY");
            if (scaleYToUseTarget) 
                scaleYEnd = target.getProperty("scaleY")
            else if (scaleYToSet) 
                scaleYEnd = scaleYTo
            else 
				scaleYEnd = scaleYStart + scaleYBy;
				
            motionPaths.push(new MotionPath("scaleY" + index, scaleYStart, scaleYEnd));
            
            if (originXSet) 
                orgX = originX;
            else 
				orgX = target.getProperty("width") * 0.5;
				
            var targetX : Float = target.getProperty("x") + (target.getProperty("scaleX") - 1) * orgX;
            var xStart : Float = targetX + (1 - scaleXStart) * orgX;
            var xEnd : Float = targetX + (1 - scaleXEnd) * orgX;
            motionPaths.push(new MotionPath("x" + index, xStart, xEnd));
            
            if (originYSet) 
                orgY = originY;
            else 
				orgY = target.getProperty("height") * 0.5;
				
            var targetY : Float = target.getProperty("y") + (target.getProperty("scaleY") - 1) * orgY;
            var yStart : Float = targetY + (1 - scaleYStart) * orgY;
            var yEnd : Float = targetY + (1 - scaleYEnd) * orgY;
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
			
            target.setProperty("scaleX", value.getProperty("scaleX" + index));
            target.setProperty("scaleY", value.getProperty("scaleY" + index));

            index++;
        }
    }
}
