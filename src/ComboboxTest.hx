package;
import flash.Lib;
import flexlite.collections.ArrayCollection;
import flexlite.components.ComboBox;
import flexlite.events.UIEvent;

/**
 * ...
 * @author weilichuang
 */
class ComboboxTest extends AppContainer
{
	static function main() 
	{
		var test:ComboboxTest = new ComboboxTest();
		Lib.current.addChild(test);
	}

	public function new() 
	{
		super();
	}

	private var dp:ArrayCollection = new ArrayCollection();
		
	override private function createChildren():Void
	{
		super.createChildren();
		var cbb:ComboBox = new ComboBox();
		cbb.dataProvider = dp;
		cbb.prompt = "请输入文字";
		cbb.addEventListener(UIEvent.OPEN,onOpen);
		addElement(cbb);
		cbb.horizontalCenter = 0;
		cbb.width = 100;
		cbb.y = 10;
		for(i in 0...10)
		{
			dp.addItem("添加了元素："+i);
		}
	}
	
	private function onOpen(event:UIEvent):Void
	{
		var target:ComboBox = Lib.as(event.currentTarget,ComboBox);
		//trace();
	}
	
}