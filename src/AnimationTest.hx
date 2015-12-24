package;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.components.Button;
import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.animation.RepeatBehavior;
import flexlite.effects.easing.Elastic;

/**
 * ...
 * @author weilichuang
 */
class AnimationTest extends AppContainer
{
	static function main() 
	{
		var test:AnimationTest = new AnimationTest();
		Lib.current.addChild(test);
	}

	public function new()
	{
		super();
	}
	
	override private function onAddedToStage(event : Event) : Void
    {
		super.onAddedToStage(event);
		this.stage.addEventListener(MouseEvent.CLICK, onStageClick);
	}
	
	private function onStageClick(event:MouseEvent):Void
	{
		animation.motionPaths = [new MotionPath("x",button.x,event.stageX),new MotionPath("y",button.y,event.stageY)];
		animation.play();
	}
	
	private var button:Button;
	private var animation:Animation;
	
	override private function createChildren():Void
	{
		super.createChildren();
		
		animation = new Animation(updateValue);
		
		button = new Button();
		button.label = "点击舞台移动按钮";
		addElement(button);
		animation.startFunction = startAnimation;
		animation.endFunction = endAnimation;
		animation.duration = 3000;
		animation.easer = new Elastic();
		animation.motionPaths = [new MotionPath("x",0,300),new MotionPath("y",0,300)];
		animation.repeatBehavior = RepeatBehavior.REVERSE;
		animation.repeatCount = 0;
		animation.play();
	}
	
	
	private function updateValue(animation:Animation):Void
	{
		button.x = Reflect.getProperty(animation.currentValue, "x");
		button.y = Reflect.getProperty(animation.currentValue, "y");
	}
	
	private function startAnimation(animation:Animation):Void
	{
	}
	
	
	private function endAnimation(animation:Animation):Void
	{
	}
	
}