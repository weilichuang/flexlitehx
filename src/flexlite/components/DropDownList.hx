package flexlite.components;
import flexlite.components.supportclasses.DropDownListBase;
import flexlite.core.IDisplayText;
@:meta(DXML(show="true"))
/**
* 不可输入的下拉列表控件。带输入功能的下拉列表控件，请使用ComboBox。
* @see flexlite.components.ComboBox
* @author weilichuang
*/
class DropDownList extends DropDownListBase
{
	public var prompt(get, set) : String;

	/**
	* [SkinPart]选中项文本
	*/
	@SkinPart
	public var labelDisplay : IDisplayText;

	private var _prompt : String = "";

	/**
	* label发生改变标志
	*/
	//private var labelChanged : Bool = false;

	/**
	* 构造函数
	*/
	public function new()
	{
		super();
	}

	/**
	* @inheritDoc
	*/
	override private function get_hostComponentKey() : Dynamic
	{
		return DropDownList;
	}

	/**
	* 当没有选中项时在DropDownList上要显示的字符串。<p/>
	* 它通常是一个类似于“请选择一项...”的文本。当下拉列表中的某个项目被选中后，会被替换为该选定项目中的文本。
	*/
	private function get_prompt() : String
	{
		return _prompt;
	}
	private function set_prompt(value : String) : String
	{
		if (_prompt == value)
			return value;

		_prompt = value;
		labelChanged = true;
		invalidateProperties();
		return value;
	}

	/**
	* @inheritDoc
	*/
	override private function commitProperties() : Void
	{
		super.commitProperties();

		if (labelChanged)
		{
			labelChanged = false;
			updateLabelDisplay();
		}
	}

	/**
	* @inheritDoc
	*/
	override private function partAdded(partName : String, instance : Dynamic) : Void
	{
		super.partAdded(partName, instance);

		if (instance == labelDisplay)
		{
			labelChanged = true;
			invalidateProperties();
		}
	}

	/**
	* @inheritDoc
	*/
	override private function updateLabelDisplay(displayItem : Dynamic = null) : Void
	{
		if (labelDisplay != null)
		{
			if (displayItem == null)
				displayItem = selectedItem;
			if (displayItem != null && displayItem != null)
				labelDisplay.text = itemToLabel(displayItem);
			else
				labelDisplay.text = _prompt;
		}
	}
}
