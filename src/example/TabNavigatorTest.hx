package example;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.components.Button;
import flexlite.components.TabBar;
import flexlite.components.TabNavigator;
import flexlite.components.ViewStack;

/**
 * ...
 * @author weilichuang
 */
class TabNavigatorTest extends AppContainer
{
	static function main() 
	{
		var test:TabNavigatorTest = new TabNavigatorTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}

	override private function createChildren():Void
	{
		super.createChildren();
		
		var tabNavigator:TabNavigator = new TabNavigator();
		tabNavigator.horizontalCenter = 0;
		tabNavigator.verticalCenter = 0;
		addElement(tabNavigator);
		
		var button:Button = new Button();
		button.label = "按钮1";
		button.name = "面板1";
		button.horizontalCenter = 0;
		tabNavigator.addElement(button);
		var button2:Button = new Button();
		button2.label = "按钮2";
		button2.name = "面板2";
		tabNavigator.addElement(button2);
		tabNavigator.selectedIndex = 1;
	}
}