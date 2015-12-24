package example;
import flash.events.Event;
import flash.Lib;
import flexlite.components.HSlider;
import flexlite.components.Label;
import flexlite.components.VSlider;

/**
 * ...
 * @author weilichuang
 */
class SliderTest extends AppContainer
{
	static function main() 
	{
		var test:SliderTest = new SliderTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}
	
	private var hSlider:HSlider = new HSlider();
	private var vSlider:VSlider = new VSlider();
	override private function createChildren():Void
	{
		super.createChildren();
		hSlider.maximum = 100;
		hSlider.minimum = 0;
		hSlider.stepSize = 1;
		hSlider.addEventListener(Event.CHANGE,onHSliderChange);
		addElement(hSlider);
		
		vSlider.addEventListener(Event.CHANGE,onVSliderChange);
		vSlider.x = 200;
		addElement(vSlider);
		
		
		hLabel.y = 10;
		hLabel.x = 35;
		addElement(hLabel);
		
		vLabel.y = 35;
		vLabel.x = 210;
		addElement(vLabel);
	}
	
	private var vLabel:Label = new Label();
	
	private function onVSliderChange(event:Event):Void
	{
		vLabel.text = vSlider.value + "";
	}
	
	private var hLabel:Label = new Label();
	
	private function onHSliderChange(event:Event):Void
	{
		hLabel.text = hSlider.value + "";
	}
}