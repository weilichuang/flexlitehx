package example;
import flash.events.Event;
import flash.Lib;
import flexlite.components.Button;
import flexlite.components.CheckBox;
import flexlite.components.RadioButton;
import flexlite.components.RadioButtonGroup;
import flexlite.components.ToggleButton;
import flexlite.core.PopUpPosition;

/**
 * ...
 * @author weilichuang
 */
class ButtonTest extends AppContainer
{
	static function main() 
	{
		var test:ButtonTest = new ButtonTest();
		Lib.current.addChild(test);
	}
	
	public function new()
	{
		super();
	}
	
	private var btn:Button = new Button();
	
	override private function createChildren():Void
	{
		super.createChildren();
		btn.label = "测试按钮";
		btn.toolTip = "测试提示";
		btn.toolTipPosition = PopUpPosition.BELOW;
		btn.horizontalCenter = 0;
		btn.verticalCenter = -40;
		addElement(btn);
		
		var toggle:ToggleButton = new ToggleButton();
		toggle.label = "切换按钮";
		toggle.x = 10;
		toggle.y = 10;
		addElement(toggle);
		
		var checkBox:CheckBox = new CheckBox();
		checkBox.x = 100;
		checkBox.y = 10;
		checkBox.label = "复选框";
		checkBox.selected = true;
		addElement(checkBox);
		
		var radio1:RadioButton = new RadioButton();
		radio1.label = "单选按钮1";
		radio1.value = "数据源1";
		radio1.y = 100;
		radio1.x = 10;
		addElement(radio1);
		
		var radio2:RadioButton = new RadioButton();
		radio2.label = "单选按钮2";
		radio2.value = "数据源2";
		radio2.y = 100;
		radio2.x = 100;
		addElement(radio2);
		
		radio1.group.addEventListener(Event.CHANGE,onRaidoSelectChange);
	}
	
	private function onRaidoSelectChange(event:Event):Void
	{
		var g:RadioButtonGroup = Lib.as(event.target, RadioButtonGroup);
		Lib.trace("选中了："+g.selectedValue);
	}
	
}
