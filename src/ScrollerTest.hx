package;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.components.Button;
import flexlite.components.Group;
import flexlite.components.Scroller;
import flexlite.components.TabBar;
import flexlite.components.TabNavigator;
import flexlite.components.ViewStack;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.TileLayout;
import flexlite.layouts.TileOrientation;

/**
 * ...
 * @author weilichuang
 */
class ScrollerTest extends AppContainer
{
	static function main() 
	{
		var test:ScrollerTest = new ScrollerTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}

	override private function createChildren():Void
	{
		super.createChildren();
		
		var scroller:Scroller = new Scroller();
		scroller.width = 300;
		scroller.height = 300;
		addElement(scroller);
		
		var g:Group = new Group();
		var layout:TileLayout = new TileLayout();
		layout.orientation = TileOrientation.COLUMNS;
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.paddingLeft = 300;
		g.layout = layout;
		scroller.viewport = g;
		var btn:Button = new Button();
		btn.enabled = false;
		btn.width = 100;
		btn.height = 300;
		g.addElement(btn);
		var btn2:Button = new Button();
		btn2.enabled = false;
		btn2.width = 400;
		btn2.height = 300;
		g.addElement(btn2);
		var btn3:Button = new Button();
		btn3.enabled = false;
		btn3.width = 400;
		btn3.height = 300;
		g.addElement(btn3);
	}
}