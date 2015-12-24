package example;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.components.Button;
import flexlite.components.Group;
import flexlite.components.Label;
import flexlite.components.Rect;
import flexlite.core.DragSource;
import flexlite.events.DragEvent;
import flexlite.layouts.TileLayout;
import flexlite.managers.DragManager;

/**
 * ...
 * @author weilichuang
 */
class DragManagerTest extends AppContainer
{
	static function main() 
	{
		var test:DragManagerTest = new DragManagerTest();
		Lib.current.addChild(test);
	}

	public function new() 
	{
		super();
	}
	
	private var button:Button = new Button();
		
	private var group:Group = new Group();
	
	private var rect:Rect = new Rect();
	
	override private function createChildren():Void
	{
		super.createChildren();
		button.label = "点击开始拖拽";
		button.verticalCenter = 0;
		button.x = 10;
		button.addEventListener(MouseEvent.MOUSE_DOWN,onStartDrag);
		button.addEventListener(DragEvent.DRAG_COMPLETE,onDragComp);
		
		var g:Group = new Group();
		g.width = g.height = 200;
		g.horizontalCenter = 10;
		g.verticalCenter = 0;
		addElement(g);
		addElement(button);
		
		rect.strokeAlpha = 1;
		rect.strokeColor = 0x000000;
		rect.percentHeight = rect.percentWidth = 100;
		rect.fillAlpha = 1;
		rect.fillColor = 0x009aff;
		g.addElement(rect);
		
		var label:Label = new Label();
		label.text = "拖拽到此处";
		label.horizontalCenter = label.verticalCenter = 0;
		g.addElement(label);
		
		group.layout = new TileLayout();
		group.percentHeight = group.percentWidth = 100;
		g.addElement(group);
		
		group.addEventListener(DragEvent.DRAG_ENTER,onDragEnter);
		group.addEventListener(DragEvent.DRAG_DROP,onDragDrop);
		group.addEventListener(DragEvent.DRAG_EXIT,onDragExit);
	}
	
	private var count:Int = 0;
	/**
	 * 发起一次拖拽操作
	 */		
	private function onStartDrag(event:MouseEvent):Void
	{
		count++;
		var dragSource:DragSource = new DragSource();
		dragSource.addData("按钮"+count,"ButtonData");
		var bitmapData:BitmapData = new BitmapData(Std.int(button.width),Std.int(button.height));
		bitmapData.draw(button);
		var dragImage:Bitmap = new Bitmap();
		dragImage.bitmapData = bitmapData;
		
		DragManager.doDrag(button,dragSource,dragImage);
	}
	/**
	 * 拖拽结束
	 */		
	private function onDragComp(event:DragEvent):Void
	{
		if(event.relatedObject != null)
		{
			var target:InteractiveObject = event.relatedObject;
			Lib.trace("接受拖拽的对象是："+target);
		}
		else
		{
			Lib.trace("拖拽失败！没人接受你的数据");
		}
	}	
	/**
	 * group监听拖拽进入事件
	 */		
	private function onDragEnter(event:DragEvent):Void
	{
		rect.strokeColor = 0xFF0000;
		if(event.dragSource.hasFormat("ButtonData"))
		{
			DragManager.acceptDragDrop(group);
		}
	}
	/**
	 * 拖拽移出group
	 */		
	private function onDragExit(event:DragEvent):Void
	{
		rect.strokeColor = 0x000000;
	}
	/**
	 * 在group上放下拖拽的数据
	 */		
	private function onDragDrop(event:DragEvent):Void
	{
		rect.strokeColor = 0x000000;
		var data:String = Std.instance(event.dragSource.dataForFormat("ButtonData"),String);
		var btn:Button = new Button();
		btn.label = data;
		group.addElement(btn);
	}
}