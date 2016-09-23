package flexlite.components;
import flash.events.Event;
import flash.events.TextEvent;
import flash.text.TextFieldType;

import flexlite.components.supportclasses.TextBase;
import flexlite.core.IDisplayText;
import flexlite.core.IEditableText;
import flexlite.core.IViewport;
import flexlite.core.NavigationUnit;
/**
* 当控件中的文本通过用户输入发生更改后分派。使用代码更改文本时不会引发此事件。
*/
@:meta(Event(name="change",type="flash.events.Event"))
/**
* 当控件中的文本通过用户输入发生更改之前分派。但是当用户按 Delete 键或 Backspace 键时，不会分派任何事件。
* 可以调用preventDefault()方法阻止更改。
*/
@:meta(Event(name="textInput",type="flash.events.TextEvent"))
@:meta(DXML(show="true"))
/**
* 可编辑文本控件
* @author weilichuang
*/
class EditableText extends TextBase implements IEditableText implements IDisplayText implements IViewport
{
	public var displayAsPassword(get, set) : Bool;
	public var editable(get, set) : Bool;
	public var maxChars(get, set) : Int;
	public var multiline(get, set) : Bool;
	public var restrict(get, set) : String;

	/**
	* 控件的默认高度（以行为单位测量）。 若设置了multiline属性为false，则忽略此属性。
	*/
	public var heightInLines(get, set) : Float;

	/**
	* 控件的默认宽度（使用字号：size为单位测量）。 若同时设置了maxChars属性，将会根据两者测量结果的最小值作为测量宽度。
	*/
	public var widthInChars(get, set) : Float;

	public var contentWidth(get, never) : Float;
	public var contentHeight(get, never) : Float;

	public var horizontalScrollPosition(get, set) : Float;
	public var verticalScrollPosition(get, set) : Float;

	public var clipAndEnableScrolling(get, set) : Bool;
	public var selectionBeginIndex(get, never) : Int;
	public var selectionEndIndex(get, never) : Int;
	public var caretIndex(get, never) : Int;

	private var _displayAsPassword : Bool = false;

	private var displayAsPasswordChanged : Bool = true;

	private var pendingEditable : Bool = true;

	private var _editable : Bool = true;

	private var editableChanged : Bool = false;

	private var _maxChars : Int = 0;

	private var maxCharsChanged : Bool = false;

	private var _multiline : Bool = true;

	private var multilineChanged : Bool = false;

	private var _restrict : String = null;

	private var restrictChanged : Bool = false;

	private var _heightInLines : Float = Math.NaN;

	private var heightInLinesChanged : Bool = false;

	private var _widthInChars : Float = Math.NaN;

	private var widthInCharsChanged : Bool = false;

	private var _contentWidth : Float = 0;

	private var _contentHeight : Float = 0;

	private var _horizontalScrollPosition : Float = 0;
	private var _verticalScrollPosition : Float = 0;
	private var _clipAndEnableScrolling : Bool = false;

	/**
	* heightInLines计算出来的默认高度。
	*/
	private var defaultHeight : Float = Math.NaN;
	/**
	* widthInChars计算出来的默认宽度。
	*/
	private var defaultWidth : Float = Math.NaN;

	private var isValidating : Bool = false;

	public function new()
	{
		super();
		selectable = true;
	}
	/**
	* @inheritDoc
	*/
	private function get_displayAsPassword() : Bool
	{
		return _displayAsPassword;
	}

	private function set_displayAsPassword(value : Bool) : Bool
	{
		if (value == _displayAsPassword)
			return value;
		_displayAsPassword = value;
		displayAsPasswordChanged = true;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
		return value;
	}
	/**
	* @inheritDoc
	*/
	private function get_editable() : Bool
	{
		if (enabled)
			return _editable;
		return pendingEditable;
	}

	private function set_editable(value : Bool) : Bool
	{
		if (_editable == value)
			return value;
		if (enabled)
		{
			_editable = value;
			editableChanged = true;
			invalidateProperties();
		}
		else
		{
			pendingEditable = value;
		}
		return value;
	}

	/**
	* @inheritDoc
	*/
	override private function set_enabled(value : Bool) : Bool
	{
		if (value == super.enabled)
			return value;

		super.enabled = value;
		if (enabled)
		{
			if (_editable != pendingEditable)
				editableChanged = true;
			_editable = pendingEditable;
		}
		else
		{
			if (editable)
				editableChanged = true;
			pendingEditable = _editable;
			_editable = false;
		}
		invalidateProperties();
		return value;
	}
	/**
	* @inheritDoc
	*/
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
	private function get_multiline() : Bool
	{
		return _multiline;
	}

	private function set_multiline(value : Bool) : Bool
	{
		if (value == multiline)
			return value;
		_multiline = value;
		multilineChanged = true;
		invalidateProperties();
		return value;
	}

	/**
	* @inheritDoc
	*/
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
	override private function set_size(value : Int) : Int
	{
		if (size == value)
			return value;
		super.size = value;
		heightInLinesChanged = true;
		widthInCharsChanged = true;
		return value;
	}

	/**
	* @inheritDoc
	*/
	override private function set_leading(value : Int) : Int
	{
		if (leading == value)
			return value;
		super.leading = value;
		heightInLinesChanged = true;
		return value;
	}

	private function get_heightInLines() : Float
	{
		return _heightInLines;
	}

	private function set_heightInLines(value : Float) : Float
	{
		if (_heightInLines == value)
			return value;
		_heightInLines = value;
		heightInLinesChanged = true;

		invalidateProperties();
		return value;
	}

	private function get_widthInChars() : Float
	{
		return _widthInChars;
	}

	private function set_widthInChars(value : Float) : Float
	{
		if (_widthInChars == value)
			return value;
		_widthInChars = value;
		widthInCharsChanged = true;

		invalidateProperties();
		return value;
	}

	private function get_contentWidth() : Float
	{
		return _contentWidth;
	}

	private function setContentWidth(value : Float) : Void
	{
		if (value == _contentWidth)
			return;
		var oldValue : Float = _contentWidth;
		_contentWidth = value;
		dispatchPropertyChangeEvent("contentWidth", oldValue, value);
	}
	private function get_contentHeight() : Float
	{
		return _contentHeight;
	}

	private function setContentHeight(value : Float) : Void
	{
		if (value == _contentHeight)
			return;
		var oldValue : Float = _contentHeight;
		_contentHeight = value;
		dispatchPropertyChangeEvent("contentHeight", oldValue, value);
	}
	/**
	* @inheritDoc
	*/
	private function get_horizontalScrollPosition() : Float
	{
		return _horizontalScrollPosition;
	}

	private function set_horizontalScrollPosition(value : Float) : Float
	{
		if (_horizontalScrollPosition == value)
			return value;
		value = Math.round(value);
		var oldValue : Float = _horizontalScrollPosition;
		_horizontalScrollPosition = value;
		if (_clipAndEnableScrolling)
		{
			if (textField != null)
				textField.scrollH = Std.int(value);
			dispatchPropertyChangeEvent("horizontalScrollPosition", oldValue, value);
		}
		return value;
	}
	private function get_verticalScrollPosition() : Float
	{
		return _verticalScrollPosition;
	}

	private function set_verticalScrollPosition(value : Float) : Float
	{
		if (_verticalScrollPosition == value)
			return value;
		value = Math.round(value);
		var oldValue : Float = _verticalScrollPosition;
		_verticalScrollPosition = value;
		if (_clipAndEnableScrolling)
		{
			if (textField != null)
				textField.scrollV = getScrollVByVertitcalPos(value);
			dispatchPropertyChangeEvent("verticalScrollPosition", oldValue, value);
		}
		return value;
	}

	/**
	* 根据垂直像素位置获取对应的垂直滚动位置
	*/
	private function getScrollVByVertitcalPos(value : Float) : Int
	{
		if (textField.numLines == 0)
			return 1;
		var lineHeight : Float = textField.getLineMetrics(0).height;
		var offsetHeight : Float = (height - 4) % lineHeight;
		if (textField.textHeight + offsetHeight - height == value)
		{
			return textField.maxScrollV;
		}
		return Std.int((value - 2) / lineHeight) + 1;
	}
	/**
	* 根据垂直滚动位置获取对应的垂直像位置
	*/
	private function getVerticalPosByScrollV(scrollV : Int) : Float
	{
		if (scrollV == 1 || textField.numLines == 0)
			return 0;
		var lineHeight : Float = textField.getLineMetrics(0).height;
		if (scrollV == textField.maxScrollV)
		{
			var offsetHeight : Float = (height - 4) % lineHeight;
			return textField.textHeight + offsetHeight - height;
		}
		return lineHeight * (scrollV - 1) + 2;
	}
	/**
	* @inheritDoc
	*/
	public function getHorizontalScrollPositionDelta(navigationUnit : Int) : Float
	{
		var delta : Float = 0;

		var maxDelta : Float = _contentWidth - _horizontalScrollPosition - width;
		var minDelta : Float = -_horizontalScrollPosition;

		switch (navigationUnit)
		{
			case NavigationUnit.LEFT:
				delta = _horizontalScrollPosition <= (0) ? 0 : Math.max(minDelta, -size);
			case NavigationUnit.RIGHT:
				delta = ((_horizontalScrollPosition + width >= contentWidth)) ? 0 : Math.min(maxDelta, size);
			case NavigationUnit.PAGE_LEFT:
				delta = Math.max(minDelta, -width);
			case NavigationUnit.PAGE_RIGHT:
				delta = Math.min(maxDelta, width);
			case NavigationUnit.HOME:
				delta = minDelta;
			case NavigationUnit.END:
				delta = maxDelta;
		}
		return delta;
	}
	/**
	* @inheritDoc
	*/
	public function getVerticalScrollPositionDelta(navigationUnit : Int) : Float
	{
		var delta : Float = 0;

		var maxDelta : Float = _contentHeight - _verticalScrollPosition - height;
		var minDelta : Float = -_verticalScrollPosition;

		switch (navigationUnit)
		{
			case NavigationUnit.UP:
				delta = getVScrollDelta(-1);
			case NavigationUnit.DOWN:
				delta = getVScrollDelta(1);
			case NavigationUnit.PAGE_UP:
				delta = Math.max(minDelta, -width);
			case NavigationUnit.PAGE_DOWN:
				delta = Math.min(maxDelta, width);
			case NavigationUnit.HOME:
				delta = minDelta;
			case NavigationUnit.END:
				delta = maxDelta;
		}
		return delta;
	}

	/**
	* 返回指定偏移行数的滚动条偏移量
	*/
	private function getVScrollDelta(offsetLine : Int) : Float
	{
		if (textField == null)
			return 0;
		var currentScrollV : Int = getScrollVByVertitcalPos(_verticalScrollPosition);
		var scrollV : Int = currentScrollV + offsetLine;
		scrollV = Std.int(Math.max(1, Math.min(textField.maxScrollV, scrollV)));
		var startPos : Float = getVerticalPosByScrollV(scrollV);
		var delta : Int = Std.int(startPos - _verticalScrollPosition);
		return delta;
	}
	/**
	* @inheritDoc
	*/
	private function get_clipAndEnableScrolling() : Bool
	{
		return _clipAndEnableScrolling;
	}

	private function set_clipAndEnableScrolling(value : Bool) : Bool
	{
		if (_clipAndEnableScrolling == value)
			return value;
		_clipAndEnableScrolling = value;

		if (textField != null)
		{
			if (value)
			{
				textField.scrollH = Std.int(_horizontalScrollPosition);
				textField.scrollV = getScrollVByVertitcalPos(_verticalScrollPosition);
				updateContentSize();
			}
			else
			{
				textField.scrollH = 0;
				textField.scrollV = 1;
			}
		}
		return value;
	}
	/**
	* @inheritDoc
	*/
	override private function commitProperties() : Void
	{
		if (textField == null)
		{
			editableChanged = true;
			displayAsPasswordChanged = true;
			maxCharsChanged = true;
			multilineChanged = true;
			restrictChanged = true;
		}

		super.commitProperties();

		if (editableChanged)
		{
			textField.type = (_editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			editableChanged = false;
		}

		if (displayAsPasswordChanged)
		{
			textField.displayAsPassword = _displayAsPassword;
			displayAsPasswordChanged = false;
		}

		if (maxCharsChanged)
		{
			textField.maxChars = _maxChars;
			maxCharsChanged = false;
		}

		if (multilineChanged)
		{
			textField.multiline = _multiline;
			textField.wordWrap = _multiline;
			multilineChanged = false;
		}

		if (restrictChanged)
		{
			textField.restrict = _restrict;
			restrictChanged = false;
		}

		if (heightInLinesChanged)
		{
			heightInLinesChanged = false;
			if (Math.isNaN(_heightInLines))
			{
				defaultHeight = Math.NaN;
			}
			else
			{
				var hInLine : Int = Std.int(heightInLines);
				var lineHeight : Float = 22;
				if (textField.length > 0)
				{
					lineHeight = textField.getLineMetrics(0).height;
				}
				else
				{
					textField.nativeText = "M";
					lineHeight = textField.getLineMetrics(0).height;
					textField.nativeText = "";
				}
				defaultHeight = hInLine * lineHeight + 4;
			}
		}

		if (widthInCharsChanged)
		{
			widthInCharsChanged = false;
			if (Math.isNaN(_widthInChars))
			{
				defaultWidth = Math.NaN;
			}
			else
			{
				var wInChars : Int = Std.int(_widthInChars);
				defaultWidth = size * wInChars + 5;
			}
		}
	}
	/**
	* @inheritDoc
	*/
	override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
	{
		isValidating = true;
		var oldScrollH : Int = textField.scrollH;
		var oldScrollV : Int = textField.scrollV;
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		updateContentSize();

		textField.scrollH = oldScrollH;
		textField.scrollV = oldScrollV;
		isValidating = false;
	}

	/**
	* 更新内容尺寸大小
	*/
	private function updateContentSize() : Void
	{
		if (!clipAndEnableScrolling)
			return;
		setContentWidth(textField.textWidth);
		var contentHeight : Float = 0;
		var numLines : Int = textField.numLines;
		if (numLines == 0)
		{
			contentHeight = 4;
		}
		else
		{
			var lineHeight : Float = textField.getLineMetrics(0).height;
			var offsetHeight : Float = (height - 4) % lineHeight;
			contentHeight = textField.textHeight + offsetHeight;
		}
		setContentHeight(contentHeight);
	}

	/**
	* @inheritDoc
	*/
	private function get_selectionBeginIndex() : Int
	{
		validateProperties();
		if (textField != null)
			return textField.selectionBeginIndex;
		return 0;
	}
	/**
	* @inheritDoc
	*/
	private function get_selectionEndIndex() : Int
	{
		validateProperties();
		if (textField != null)
			return textField.selectionEndIndex;
		return 0;
	}
	/**
	* @inheritDoc
	*/
	private function get_caretIndex() : Int
	{
		validateProperties();
		if (textField != null)
			return textField.caretIndex;
		return 0;
	}
	/**
	* @inheritDoc
	*/
	public function setSelection(beginIndex : Int, endIndex : Int) : Void
	{
		validateProperties();
		if (textField != null)
		{
			textField.setSelection(beginIndex, endIndex);
		}
	}
	/**
	* @inheritDoc
	*/
	public function selectAll() : Void
	{
		validateProperties();
		if (textField != null)
		{
			textField.setSelection(0, textField.length);
		}
	}
	/**
	* @inheritDoc
	*/
	override private function measure() : Void
	{
		measuredWidth = (Math.isNaN(defaultWidth)) ? TextBase.DEFAULT_MEASURED_WIDTH : defaultWidth;

		if (_maxChars != 0)
		{
			measuredWidth = Math.min(measuredWidth, textField.textWidth);
		}
		if (_multiline)
		{
			measuredHeight = (Math.isNaN(defaultHeight)) ? TextBase.DEFAULT_MEASURED_HEIGHT * 2 : defaultHeight;
		}
		else
		{
			measuredHeight = textField.textHeight;
		}
	}
	/**
	* 创建文本显示对象
	*/
	override private function createTextField() : Void
	{
		super.createTextField();
		textField.type = (_editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		textField.multiline = _multiline;
		textField.wordWrap = _multiline;

		textField.addEventListener(Event.CHANGE, textField_changeHandler);
		textField.addEventListener(Event.SCROLL, textField_scrollHandler);
		textField.addEventListener(TextEvent.TEXT_INPUT,
		textField_textInputHandler);
		if (_clipAndEnableScrolling)
		{
			textField.scrollH = Std.int(_horizontalScrollPosition);
			textField.scrollV = getScrollVByVertitcalPos(_verticalScrollPosition);
		}
	}

	private function textField_changeHandler(event : Event) : Void
	{
		textFieldChanged(false);
		event.stopImmediatePropagation();
		dispatchEvent(new Event(Event.CHANGE));
		invalidateSize();
		invalidateDisplayList();
		updateContentSize();
	}
	/**
	*  @private
	*/
	private function textField_scrollHandler(event : Event) : Void
	{
		if (isValidating)
			return;
		horizontalScrollPosition = textField.scrollH;
		verticalScrollPosition = getVerticalPosByScrollV(textField.scrollV);
	}

	/**
	* 即将输入文字
	*/
	private function textField_textInputHandler(event : TextEvent) : Void
	{
		event.stopImmediatePropagation();

		var newEvent : TextEvent =
		new TextEvent(TextEvent.TEXT_INPUT, false, true);
		newEvent.text = event.text;
		dispatchEvent(newEvent);

		if (newEvent.isDefaultPrevented())
			event.preventDefault();
	}
}
