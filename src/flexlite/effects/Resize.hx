package flexlite.effects;



import flexlite.core.IUIComponent;
import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.supportclasses.Effect;

using Reflect;

@:meta(DXML(show="false"))


/**
* 尺寸调整特效。此动画作用于对象的width，height以及x，y属性。
* @author weilichuang
*/
class Resize extends Effect
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
	* 缩放中心点x坐标。默认值为0 
	*/
    public var originX : Float = 0;
    /**
	* 缩放中心点y坐标。默认值为0 
	*/
    public var originY : Float = 0;
    
    /**
	* height起始值。若不设置，则使用目标对象的当前height或根据其他值计算出此值。
	*/
    public var heightFrom : Float;
    /**
	* height结束值。若不设置，则使用目标对象的当前height或根据其他值计算出此值。
	*/
    public var heightTo : Float;
    /**
	* height要增加的量，负值代表减小。
	*/
    public var heightBy : Float;
    /**
	*  width起始值。若不设置，则使用目标对象的当前width或根据其他值计算出此值。
	*/
    public var widthFrom : Float;
    /**
	* width结束值。若不设置，则使用目标对象的当前width或根据其他值计算出此值。
	*/
    public var widthTo : Float;
    /**
	* width要增加的量，负值代表减小。
	*/
    public var widthBy : Float;
    /**
	* @inheritDoc
	*/
    override public function reset() : Void
    {
        super.reset();
        originX = originY = 0;
        heightFrom = heightTo = heightBy = widthFrom = widthTo = widthBy = NaN;
    }
    /**
	* @inheritDoc
	*/
    override private function createMotionPath() : Array<MotionPath>
    {
        var motionPath : Array<MotionPath> = new Array<MotionPath>();
        var widthFromSet : Bool = !Math.isNaN(widthFrom);
        var widthToSet : Bool = !Math.isNaN(widthTo);
        var heightFromSet : Bool = !Math.isNaN(heightFrom);
        var heightToSet : Bool = !Math.isNaN(heightTo);
        
        var widthFromUseTarget : Bool = !widthFromSet && (Math.isNaN(widthTo) || Math.isNaN(widthBy));
        var widthToUseTarget : Bool = !widthToSet && Math.isNaN(widthBy);
        var heightFromUseTarget : Bool = !heightFromSet && (Math.isNaN(heightTo) || Math.isNaN(heightBy));
        var heightToUseTarget : Bool = !heightToSet && Math.isNaN(heightBy);
        
        var widthStart : Float = (widthFromSet) ? widthFrom : widthTo - widthBy;
        var heightStart : Float = (heightFromSet) ? heightFrom : heightTo - heightBy;
        var widthEnd : Float;
        var heightEnd : Float;
        var index : Int = 0;
        var motionPaths : Array<MotionPath> = new Array<MotionPath>();
        for (target in _targets)
        {
			var tWidth:Float = target.getProperty("width");
			var tHeight:Float = target.getProperty("height");
			
            if (widthFromUseTarget) 
                widthStart = tWidth;
            if (widthToUseTarget) 
                widthEnd = tWidth;
            else if (widthToSet) 
                widthEnd = widthTo;
            else 
				widthEnd = widthStart + widthBy;
				
            motionPaths.push(new MotionPath("width" + index, widthStart, widthEnd));
            
            if (heightFromUseTarget) 
                heightStart = tHeight;
            if (heightToUseTarget) 
                heightEnd = tHeight;
            else if (heightToSet) 
                heightEnd = heightTo;
            else 
				heightEnd = heightStart + heightBy;
            motionPaths.push(new MotionPath("height" + index, heightStart, heightEnd));
			
			var tx:Float = target.getProperty("x");
			var ty:Float = target.getProperty("y");
			
            
            var xStart : Float = tx + (tWidth - widthStart) * originX / tWidth;
            var xEnd : Float = tx + (widthEnd - tWidth) * originX / tWidth;
            motionPaths.push(new MotionPath("x" + index, xStart, xEnd));
            
            var yStart : Float = ty + (tHeight - heightStart) * originY / tHeight;
            var yEnd : Float = ty + (heightEnd - tHeight) * originY / tHeight;
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
			
            target.setProperty("width", Math.ceil(value.getProperty("width" + index)));
            target.setProperty("height", Math.ceil(value.getProperty("height" + index)));
			
            index++;
        }
    }
}
