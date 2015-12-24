package;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.components.Button;
import flexlite.components.TabBar;
import flexlite.components.ViewStack;

/**
 * ...
 * @author weilichuang
 */
class TabBarTest extends AppContainer
{
	static function main() 
	{
		var test:TabBarTest = new TabBarTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}
	
	private var tabBar:TabBar = new TabBar();
	private var viewStack:ViewStack = new ViewStack();
	
	override private function createChildren():Void
	{
		super.createChildren();
		
		for(i in 0...5)
		{
			var button:Button = new Button();
			button.name = "Tab"+i;
			button.label = "按钮"+i;
			viewStack.addElement(button);
		}
		
		tabBar.dataProvider = viewStack;
		tabBar.horizontalCenter = 0;
		addElement(tabBar);
		viewStack.y = 60;
		viewStack.horizontalCenter = 0;
		addElement(viewStack);
		
		var btn:Button = new Button();
		btn.addEventListener(MouseEvent.CLICK,onCLick);
		addElement(btn);
	}
	
	private function onCLick(event:MouseEvent):Void
	{
		viewStack.selectedIndex = 3;
	}
}