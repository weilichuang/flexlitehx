package example;

import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.components.Label;
import flexlite.components.TitleWindow;
import flexlite.core.UITextField;
import flexlite.events.CloseEvent;
import flexlite.managers.PopUpManager;
import flexlite.skins.vector.TitleWindowSkin;
import flexlite.utils.SkinPartUtil;
import flexlite.states.State;
import flexlite.utils.CRC32Util;
import haxe.rtti.Meta;


/**
 * TitleWindow测试
 */
class TitleWindowTest extends AppContainer
{
	static function main() 
	{
		var test:TitleWindowTest = new TitleWindowTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}
	
	override private function onAddedToStage(event : Event) : Void
    {
		super.onAddedToStage(event);
		this.stage.addEventListener(MouseEvent.CLICK,onStageClick);
		createOneWindow();
	}
	
	private var windowNum:Int = 0;
	
	private function onStageClick(event:MouseEvent):Void
	{
		var target:InteractiveObject = cast event.target;
		
		var found:Bool = Std.is(target, TitleWindow);
		
		
		while(target.parent != null)
		{
			target = target.parent;
			if(Std.is(target,TitleWindow))
			{
				found = true;
				break;
			}
		}
		
		if (found)
		{
			var win:TitleWindow = Lib.as(target, TitleWindow);
			var label:Label = new Label();
			label.text = "test01234";
			label.x = Math.random() * 400;
			label.y = Math.random() * 400;
			win.contentGroup.addElement(label);
			return;
		}
			
		createOneWindow();
	}
	
	private function createOneWindow():Void
	{
		windowNum++;
		var window:TitleWindow = new TitleWindow();
		window.height = 300;
		window.width = 400;
		window.title = "测试窗口"+windowNum;
		window.addEventListener(CloseEvent.CLOSE,onClose);
		PopUpManager.addPopUp(window);
	}
	
	private function onClose(event:CloseEvent):Void
	{
		var window:TitleWindow = cast event.currentTarget;
		PopUpManager.removePopUp(window);
	}
}