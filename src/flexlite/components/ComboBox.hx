package flexlite.components;

import flash.display.InteractiveObject;
import flash.events.Event;
import flexlite.components.supportclasses.DropDownListBase;
import flexlite.components.supportclasses.ListBase;
import flexlite.components.TextInput;
import flexlite.events.UIEvent;
@:meta(DXML(show="true"))

/**
* 带输入框的下拉列表控件。不带输入功能的下拉列表请使用DropDownList。
* @see flexlite.components.DropDownList
* @author weilichuang
*/
class ComboBox extends DropDownListBase
{
	/**
	* 当用户在文本输入框中输入值且该值被提交时，用来表示当前选中项索引的静态常量。
	*/
	private static var CUSTOM_SELECTED_ITEM : Int = ListBase.CUSTOM_SELECTED_ITEM;

	/**
	* 指定用于将在提示区域中输入的新值转换为与数据提供程序中的数据项具有相同数据类型的回调函数。
	* 当提示区域中的文本提交且在数据提供程序中未找到时，将调用该属性引用的函数。
	* 示例： function myLabelToItem(value:String):Object
	*/
	public var labelToItemFunction(get, set) : String->Dynamic;

	/**
	* 输入文本为 null 时要显示的文本。 <p/>
	* 先创建控件时将显示提示文本。控件获得焦点、输入文本为非 null 或选择了列表中的项目时提示文本将消失。
	* 控件失去焦点时提示文本将重新显示，但仅当未输入文本时（如果文本字段的值为 null 或空字符串）。
	*/
	public var prompt(get, set) : String;

	/**
	* 文本输入框中最多可包含的字符数（即用户输入的字符数）。0 值相当于无限制。默认值为0.
	*/
	public var maxChars(get, set) : Int;

	/**
	* 表示用户可输入到文本字段中的字符集。如果 restrict 属性的值为 null，则可以输入任何字符。
	* 如果 restrict 属性的值为空字符串，则不能输入任何字符。如果 restrict 属性的值为一串字符，
	*  则只能在文本字段中输入该字符串中的字符。从左向右扫描该字符串。可以使用连字符 (-) 指定一个范围。
	*  只限制用户交互；脚本可将任何文本放入文本字段中。此属性不与属性检查器中的“嵌入字体”选项同步。 <p/>
	* 如果字符串以尖号 (ˆ) 开头，则先接受所有字符，然后从接受字符集中排除字符串中 ˆ 之后的字符。
	*  如果字符串不以尖号 (ˆ) 开头，则最初不接受任何字符，然后将字符串中的字符包括在接受字符集中。
	*/
	public var restrict(get, set) : String;

	/**
	* [SkinPart]文本输入控件
	*/
	@SkinPart
	public var textInput : TextInput;

	/**
	* 当用户在提示区域中输入字符时,用于根据输入文字返回匹配的数据项索引列表的回调函数。
	* 示例：function myMatchingFunction(comboBox:ComboBox, inputText:String):Vector.<int>
	*/
	public var itemMatchingFunction : ComboBox->String->Array<Int> = null;

	/**
	* 如果为 true，则用户在文本输入框编辑时会打开下拉列表。
	*/
	public var openOnInput : Bool = true;

	private var actualProposedSelectedIndex : Int = ListBase.NO_SELECTION;

	private var userTypedIntoText : Bool;
	/**
	* 文本改变前上一次的文本内容。
	*/
	private var previousTextInputText : String = "";
	private var _labelToItemFunction : String->Dynamic;
	/**
	* labelToItemFunction属性改标志
	*/
	private var labelToItemFunctionChanged : Bool = false;

	private var _prompt : String;
	private var promptChanged : Bool = false;

	private var _maxChars : Int = 0;
	private var maxCharsChanged : Bool = false;

	private var _restrict : String;
	/**
	* restrict属性改变标志
	*/
	private var restrictChanged : Bool;

	/**
	* 构造函数
	*/
	public function new()
	{
		super();
		allowCustomSelectedItem = true;
	}

	private function set_labelToItemFunction(value : String->Dynamic) : String->Dynamic
	{
		if (value == _labelToItemFunction)
			return value;

		_labelToItemFunction = value;
		labelToItemFunctionChanged = true;
		invalidateProperties();
		return value;
	}

	private function get_labelToItemFunction() : String->Dynamic
	{
		return _labelToItemFunction;
	}
	private function get_prompt() : String
	{
		return _prompt;
	}
	private function set_prompt(value : String) : String
	{
		if (_prompt == value)
			return value;
		_prompt = value;
		promptChanged = true;
		invalidateProperties();
		return value;
	}
	private function get_maxChars() : Int
	{
		return _maxChars;
	}
	private function set_maxChars(value : Int) : Int
	{
		if (value == _maxChars)
			return value;

		_maxChars = value;
		maxCharsChanged = true;
		invalidateProperties();
		return value;
	}
	/**
	* @inheritDoc
	*/
	override private function get_hostComponentKey() : Dynamic
	{
		return ComboBox;
	}
	private function get_restrict() : String
	{
		return _restrict;
	}
	private function set_restrict(value : String) : String
	{
		if (value == _restrict)
			return value;

		_restrict = value;
		restrictChanged = true;
		invalidateProperties();
		return value;
	}

	/**
	* @inheritDoc
	*/
	override private function set_selectedIndex(value : Int) : Int
	{
		super.selectedIndex = value;
		actualProposedSelectedIndex = value;
		return value;
	}

	/**
	* @inheritDoc
	*/
	override private function set_userProposedSelectedIndex(value : Int) : Int
	{
		super.userProposedSelectedIndex = value;
		actualProposedSelectedIndex = value;
		return value;
	}

	/**
	* 处理正在输入文本的操作，搜索并匹配数据项。
	*/
	private function processInputField() : Void
	{
		var matchingItems : Array<Int>;
		actualProposedSelectedIndex = CUSTOM_SELECTED_ITEM;
		if (dataProvider == null || dataProvider.length <= 0)
			return;

		if (textInput.text != "")
		{
			if (itemMatchingFunction != null)
				matchingItems = itemMatchingFunction(this, textInput.text)
				else
					matchingItems = findMatchingItems(textInput.text);
			if (matchingItems.length > 0)
			{
				super.changeHighlightedSelection(matchingItems[0], true);
				var typedLength : Int = textInput.text.length;
				var item : Dynamic = (dataProvider != null) ? dataProvider.getItemAt(matchingItems[0]) : null;
				if (item != null)
				{
					var itemString : String = itemToLabel(item);
					previousTextInputText = textInput.text = itemString;
					textInput.setSelection(typedLength, itemString.length);
				}
			}
			else
			{
				super.changeHighlightedSelection(CUSTOM_SELECTED_ITEM);
			}
		}
		else
		{
			super.changeHighlightedSelection(ListBase.NO_SELECTION);
		}
	}
	/**
	* 根据指定字符串找到匹配的数据项索引列表。
	*/
	private function findMatchingItems(input : String) : Array<Int>
	{
		var startIndex : Int;
		var stopIndex : Int;
		var retVal : Int;
		var retVector : Array<Int> = new Array<Int>();

		retVal = findStringLoop(input, 0, dataProvider.length);

		if (retVal != -1)
			retVector.push(retVal);
		return retVector;
	}

	/**
	* 在数据源中查询指定索引区间的数据项，返回数据字符串与str开头匹配的数据项索引。
	*/
	private function findStringLoop(str : String, startIndex : Int, stopIndex : Int) : Int
	{
		while (startIndex != stopIndex)
		{
			var itmStr : String = itemToLabel(dataProvider.getItemAt(startIndex));
			itmStr = itmStr.substring(0, str.length);
			if (str == itmStr || str.toUpperCase() == itmStr.toUpperCase())
			{
				return startIndex;
			}
			startIndex++;
		}
		return -1;
	}

	private function getCustomSelectedItem() : Dynamic
	{
		var input : String = textInput.text;
		if (input == "")
			return null;
		else if (labelToItemFunction != null)
			return _labelToItemFunction(input);
		else
			return input;
	}

	private function applySelection() : Void
	{
		if (actualProposedSelectedIndex == CUSTOM_SELECTED_ITEM)
		{
			var itemFromInput : Dynamic = getCustomSelectedItem();
			if (itemFromInput != null)
				setSelectedItem(itemFromInput, true)
				else
					setSelectedIndex(ListBase.NO_SELECTION, true);
		}
		else
		{
			setSelectedIndex(actualProposedSelectedIndex, true);
		}

		if (textInput != null)
			textInput.setSelection(-1, -1);

		userTypedIntoText = false;
	}

	/**
	* @inheritDoc
	*/
	override private function commitProperties() : Void
	{
		var selectedIndexChanged : Bool = _proposedSelectedIndex != ListBase.NO_PROPOSED_SELECTION;
		if (_proposedSelectedIndex == CUSTOM_SELECTED_ITEM &&
		_pendingSelectedItem == null)
		{
			_proposedSelectedIndex = ListBase.NO_PROPOSED_SELECTION;
		}

		super.commitProperties();

		if (textInput != null)
		{
			if (promptChanged)
			{
				textInput.prompt = _prompt;
				promptChanged = false;
			}
			if (maxCharsChanged)
			{
				textInput.maxChars = _maxChars;
				maxCharsChanged = false;
			}
			if (restrictChanged)
			{
				textInput.restrict = _restrict;
				restrictChanged = false;
			}
		}
		if (selectedIndexChanged && selectedIndex == ListBase.NO_SELECTION)
			previousTextInputText = textInput.text = "";
	}

	/**
	* @inheritDoc
	*/
	override private function updateLabelDisplay(displayItem : Dynamic = null) : Void
	{
		super.updateLabelDisplay();

		if (textInput != null)
		{
			if (displayItem == null)
				displayItem = selectedItem;
			if (displayItem != null && displayItem != null)
			{
				previousTextInputText = textInput.text = itemToLabel(displayItem);
			}
		}
	}

	/**
	* @inheritDoc
	*/
	override private function partAdded(partName : String, instance : Dynamic) : Void
	{
		super.partAdded(partName, instance);

		if (instance == textInput)
		{
			updateLabelDisplay();
			textInput.addEventListener(Event.CHANGE, textInput_changeHandler);
			textInput.maxChars = maxChars;
			textInput.restrict = restrict;
		}
	}

	/**
	* @inheritDoc
	*/
	override private function partRemoved(partName : String, instance : Dynamic) : Void
	{
		super.partRemoved(partName, instance);

		if (instance == textInput)
		{
			textInput.removeEventListener(Event.CHANGE, textInput_changeHandler);
		}
	}
	/**
	* @inheritDoc
	*/
	override private function changeHighlightedSelection(newIndex : Int, scrollToTop : Bool = false) : Void
	{
		super.changeHighlightedSelection(newIndex, scrollToTop);

		if (newIndex >= 0)
		{
			var item : Dynamic = (dataProvider != null) ? dataProvider.getItemAt(newIndex) : null;
			if (item != null && textInput != null)
			{
				var itemString : String = itemToLabel(item);
				previousTextInputText = textInput.text = itemString;
				textInput.selectAll();
				userTypedIntoText = false;
			}
		}
	}

	/**
	* @inheritDoc
	*/
	override public function setFocus() : Void
	{
		if (stage != null && textInput != null)
		{
			stage.focus = cast(textInput.textDisplay, InteractiveObject);
		}
	}

	/**
	* @inheritDoc
	*/
	override private function dropDownController_openHandler(event : UIEvent) : Void
	{
		super.dropDownController_openHandler(event);
		userProposedSelectedIndex = (userTypedIntoText) ? ListBase.NO_SELECTION : selectedIndex;
	}

	/**
	* @inheritDoc
	*/
	override private function dropDownController_closeHandler(event : UIEvent) : Void
	{
		super.dropDownController_closeHandler(event);
		if (!event.isDefaultPrevented())
		{
			applySelection();
		}
	}

	/**
	* @inheritDoc
	*/
	override private function itemRemoved(index : Int) : Void
	{
		if (index == selectedIndex)
			updateLabelDisplay("");

		super.itemRemoved(index);
	}
	/**
	* 文本输入改变事件处理函数
	*/
	private function textInput_changeHandler(event : Event) : Void
	{
		userTypedIntoText = true;
		if (previousTextInputText.length > textInput.text.length)
		{
			super.changeHighlightedSelection(CUSTOM_SELECTED_ITEM);
		}
		else if (previousTextInputText != textInput.text)
		{
			if (openOnInput)
			{
				if (!isDropDownOpen)
				{
					openDropDown();
					addEventListener(UIEvent.OPEN, editingOpenHandler);
					return;
				}
			}
			processInputField();
		}
		previousTextInputText = textInput.text;
	}
	/**
	* 第一次输入等待下拉列表打开后在处理数据匹配
	*/
	private function editingOpenHandler(event : UIEvent) : Void
	{
		removeEventListener(UIEvent.OPEN, editingOpenHandler);
		processInputField();
	}
}
