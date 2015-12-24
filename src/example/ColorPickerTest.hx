package example;
import flash.events.Event;
import flash.Lib;
import flexlite.components.ColorPicker;
import flexlite.components.IconButton;
import flash.display.BitmapData;
/**
 * ...
 * @author 
 */
class ColorPickerTest extends AppContainer
{

	static function main() 
	{
		var test:ColorPickerTest = new ColorPickerTest();
		Lib.current.addChild(test);
	}

	public function new() 
	{
		super();
		
	}
	
	private var colorPicker:ColorPicker;
	override private function createChildren():Void
	{
		super.createChildren();
		
		colorPicker = new ColorPicker();
		colorPicker.x = colorPicker.y = 50;
		this.addElement(colorPicker);
		colorPicker.addEventListener(Event.CHANGE, onChange);
		
		var button:IconButton = new IconButton();
		button.skinName = new DIR(0,0);
		button.x = button.y = 100;
		this.addElement(button);
	}
	
	private function onChange(event:Event):Void
	{
		trace(colorPicker.selectColor);
	}
	
}


@:bitmap("../asset/dir.gif") class DIR extends BitmapData { }