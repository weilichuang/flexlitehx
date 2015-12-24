package example;
import flash.Lib;
import flexlite.collections.ArrayCollection;
import flexlite.components.ComboBox;
import flexlite.components.DataGroup;
import flexlite.events.UIEvent;
import flexlite.layouts.TileLayout;

/**
 * ...
 * @author weilichuang
 */
class DataGroupTest extends AppContainer
{
	static function main() 
	{
		var test:DataGroupTest = new DataGroupTest();
		Lib.current.addChild(test);
	}

	public function new() 
	{
		super();
	}

	private var dp:ArrayCollection = new ArrayCollection();
	private var dataGroup:DataGroup;
		
	override private function createChildren():Void
	{
		super.createChildren();
		
		dataGroup = new DataGroup();
		dataGroup.horizontalCenter = 0;
		dataGroup.verticalCenter = 0;
		dataGroup.dataProvider = dp;
		var layout:TileLayout = new TileLayout();
		layout.useVirtualLayout = true;
		layout.requestedRowCount = 3;
		layout.requestedColumnCount = 2;
		dataGroup.layout = layout;
		dataGroup.clipAndEnableScrolling = true;
		addElement(dataGroup);
		
		for(i in 0...10)
		{
			dp.addItem("添加了元素："+i);
		}
	}
	
	private function onOpen(event:UIEvent):Void
	{
	}
	
}