package example;
import flash.events.Event;
import flash.Lib;
import flexlite.components.TextArea;
import flexlite.components.TextInput;

/**
 * ...
 * @author weilichuang
 */
class TextAreaTest extends AppContainer
{
	static function main() 
	{
		var test:TextAreaTest = new TextAreaTest();
		Lib.current.addChild(test);
	}

	public function new() 
	{
		super();
	}
	
	private var textInput:TextInput;
	override private function createChildren():Void
	{
		super.createChildren();
		textInput = new TextInput();
		textInput.x = 220;
		textInput.y = 5;
		textInput.width = 160;
		textInput.prompt = "请输入文本";
		addElement(textInput);
		textInput.addEventListener(Event.CHANGE,onChange);
		
		var textArea:TextArea = new TextArea();
		textArea.x = 5;
		textArea.y = 5;
		textArea.prompt = "请输入文本";
		addElement(textArea);
	}
	
	private function onChange(event:Event):Void
	{
		Lib.trace(textInput.text);
	}
}