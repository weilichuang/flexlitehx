package example;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.collections.ArrayCollection;
import flexlite.components.Button;
import flexlite.components.DropDownList;
import flexlite.components.Group;
import flexlite.components.Scroller;
import flexlite.components.TabBar;
import flexlite.components.TabNavigator;
import flexlite.components.ViewStack;
import flexlite.events.UIEvent;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.TileLayout;
import flexlite.layouts.TileOrientation;

/**
 * ...
 * @author weilichuang
 */
class DropDownListTest extends AppContainer
{
	static function main() 
	{
		var test:DropDownListTest = new DropDownListTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}

	override private function createChildren():Void
	{
		super.createChildren();
		
		var cbb:DropDownList = new DropDownList();
		cbb.dataProvider = dp;
		cbb.addEventListener(UIEvent.OPEN,onOpen);
		addElement(cbb);
		cbb.width = 120;
		cbb.prompt = "请选择一项...";
		cbb.horizontalCenter = 0;
		cbb.y = 10;
		for(i in 0...10)
		{
			dp.addItem("添加了元素：" + i);
		}
	}
	
	private function onOpen(event:UIEvent):Void
	{
		var target:DropDownList = cast event.currentTarget;
	}
	
	private var dp:ArrayCollection = new ArrayCollection();
}