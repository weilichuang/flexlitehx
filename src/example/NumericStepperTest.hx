package example;
import flash.Lib;
import flexlite.components.NumericStepper;

/**
 * ...
 * @author 
 */
class NumericStepperTest extends AppContainer
{
	static function main() 
	{
		var test:NumericStepperTest = new NumericStepperTest();
		Lib.current.addChild(test);
	}

	public function new() 
	{
		super();
		
	}
	
	override private function createChildren():Void
	{
		super.createChildren();
		
		var stepper:NumericStepper = new NumericStepper();
		stepper.minimum = 0;
		stepper.maximum = 100;
		stepper.stepSize = 1;
		stepper.x = stepper.y = 50;
		this.addElement(stepper);
	}
	
}