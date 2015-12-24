package example;

import flash.Lib;
import flexlite.collections.ArrayCollection;
import flexlite.components.List;
import flexlite.events.IndexChangeEvent;
import flexlite.events.ListEvent;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.VerticalLayout;
import flexlite.components.supportclasses.ListBase;

/**
 * List组件测试
 * @author weilichuang
 */	
class ListTest extends AppContainer
{
	static function main() 
	{
		var test:ListTest = new ListTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}
	
	private var dp:ArrayCollection = new ArrayCollection();
	
	private var list:List;
	
	private var times:Int = 0;
	
	override private function createChildren():Void
	{
		super.createChildren();
		list = new List();
		list.horizontalCenter = 0;
		list.verticalCenter = 0;
		list.requireSelection = true;
		list.dataProvider = dp;
		var layout:VerticalLayout = new VerticalLayout();
		layout.gap = 0;
		layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
		list.layout = layout;
		list.addEventListener(ListEvent.ITEM_ROLL_OUT,onListEvent);
		list.addEventListener(ListEvent.ITEM_ROLL_OVER,onListEvent);
		list.addEventListener(IndexChangeEvent.CHANGING,onIndexChange);
		list.addEventListener(IndexChangeEvent.CHANGE,onIndexChange);
		
		addElement(list);
		
		for(i in 0...10)
		{
			dp.addItem("添加了元素："+i);
		}
	}
	
	private function onIndexChange(event:IndexChangeEvent):Void
	{
		Lib.trace("[type:" + event.type+" newIndex:" + event.newIndex + " oldIndex:" + event.oldIndex + "]");
		Lib.trace(list.selectedItem);
	}
	
	private function onListEvent(event:ListEvent):Void
	{
		Lib.trace(event.type);
	}
}