package flexlite.components;

import flexlite.components.Button;
import flexlite.components.TitleWindow;

import flash.events.MouseEvent;

import flexlite.core.IDisplayText;
import flexlite.events.CloseEvent;
import flexlite.managers.PopUpManager;

/**
* 弹出对话框，可能包含消息、标题、按钮（“确定”、“取消”、“是”和“否”的任意组合)。
* @author weilichuang
*/
class Alert extends TitleWindow
{
	/**
	* 当对话框关闭时，closeEvent.detail的值若等于此属性,表示被点击的按钮为firstButton。
	*/
	public static inline var FIRST_BUTTON : String = "firstButton";
	/**
	* 当对话框关闭时，closeEvent.detail的值若等于此属性,表示被点击的按钮为secondButton。
	*/
	public static inline var SECOND_BUTTON : String = "secondButton";
	/**
	* 当对话框关闭时，closeEvent.detail的值若等于此属性,表示被点击的按钮为closeButton。
	*/
	public static inline var CLOSE_BUTTON : String = "closeButton";

	/**
	* 弹出Alert控件的静态方法。在Alert控件中选择一个按钮，将关闭该控件。
	* @param text 要显示的文本内容字符串。
	* @param title 对话框标题
	* @param closeHandler 按下Alert控件上的任意按钮时的回调函数。示例:closeHandler(event:CloseEvent);
	* event的detail属性包含 Alert.FIRST_BUTTON、Alert.SECOND_BUTTON和Alert.CLOSE_BUTTON。
	* @param firstButtonLabel 第一个按钮上显示的文本。
	* @param secondButtonLabel 第二个按钮上显示的文本，若为null，则不显示第二个按钮。
	* @param modal 是否启用模态。即禁用弹出框以下的鼠标事件。默认true。
	* @param center 是否居中。默认true。
	* @return 弹出的对话框实例的引用
	*/
	public static function show(text : String = "", title : String = "", closeHandler : CloseEvent->Void = null,
								firstButtonLabel : String = "确定", secondButtonLabel : String = "",
								modal : Bool = true, center : Bool = true) : Alert
	{
		var alert : Alert = new Alert();
		alert.contentText = text;
		alert.title = title;
		alert._firstButtonLabel = firstButtonLabel;
		alert._secondButtonLabel = secondButtonLabel;
		alert.closeHandler = closeHandler;
		PopUpManager.addPopUp(alert, modal, center);
		return alert;
	}

	public var firstButtonLabel(get, set) : String;
	public var secondButtonLabel(get, set) : String;
	public var contentText(get, set) : String;

	/**
	* [SkinPart]文本内容显示对象
	*/
	@SkinPart
	public var contentDisplay : IDisplayText;
	/**
	* [SkinPart]第一个按钮，通常是"确定"。
	*/
	@SkinPart
	public var firstButton : Button;
	/**
	* [SkinPart]第二个按钮，通常是"取消"。
	*/
	@SkinPart
	public var secondButton : Button;

	private var _firstButtonLabel : String = "";
	private var _secondButtonLabel : String = "";
	private var _contentText : String = "";
	/**
	* 对话框关闭回调函数
	*/
	private var closeHandler : CloseEvent->Void;

	/**
	* 构造函数，请通过静态方法Alert.show()来创建对象实例。
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
		return Alert;
	}

	/**
	* 第一个按钮上显示的文本
	*/
	private function get_firstButtonLabel() : String
	{
		return _firstButtonLabel;
	}
	private function set_firstButtonLabel(value : String) : String
	{
		if (_firstButtonLabel == value)
			return value;
		_firstButtonLabel = value;
		if (firstButton != null)
			firstButton.label = value;
		return value;
	}

	/**
	* 第二个按钮上显示的文本
	*/
	private function get_secondButtonLabel() : String
	{
		return _secondButtonLabel;
	}
	private function set_secondButtonLabel(value : String) : String
	{
		if (_secondButtonLabel == value)
			return value;
		_secondButtonLabel = value;
		if (secondButton != null)
		{
			if (value == null || value == "")
				secondButton.includeInLayout = secondButton.visible
				= (_secondButtonLabel != "" && _secondButtonLabel != null);
		}
		return value;
	}
	/**
	* 文本内容
	*/
	private function get_contentText() : String
	{
		return _contentText;
	}
	private function set_contentText(value : String) : String
	{
		if (_contentText == value)
			return value;
		_contentText = value;
		if (contentDisplay != null)
			contentDisplay.text = value;
		return value;
	}
	/**
	* 关闭事件
	*/
	private function onClose(event : MouseEvent) : Void
	{
		PopUpManager.removePopUp(this);
		if (closeHandler != null)
		{
			var closeEvent : CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			var target:Dynamic = event.currentTarget;
			if (target == firstButton)
			{
				closeEvent.detail = Alert.FIRST_BUTTON;
			}
			else if (target == secondButton)
			{
				closeEvent.detail = Alert.SECOND_BUTTON;
			}
			closeHandler(closeEvent);
		}
	}
	/**
	* @inheritDoc
	*/
	override private function closeButton_clickHandler(event : MouseEvent) : Void
	{
		super.closeButton_clickHandler(event);
		PopUpManager.removePopUp(this);
		var closeEvent : CloseEvent = new CloseEvent(CloseEvent.CLOSE, false, false, Alert.CLOSE_BUTTON);
		if (closeHandler != null)
			closeHandler(closeEvent);
	}
	/**
	* @inheritDoc
	*/
	override private function partAdded(partName : String, instance : Dynamic) : Void
	{
		super.partAdded(partName, instance);
		if (instance == contentDisplay)
		{
			contentDisplay.text = _contentText;
		}
		else if (instance == firstButton)
		{
			firstButton.label = _firstButtonLabel;
			firstButton.addEventListener(MouseEvent.CLICK, onClose);
		}
		else if (instance == secondButton)
		{
			secondButton.label = _secondButtonLabel;
			secondButton.includeInLayout = secondButton.visible
			= (_secondButtonLabel != "" && _secondButtonLabel != null);
			secondButton.addEventListener(MouseEvent.CLICK, onClose);
		}
	}
	/**
	* @inheritDoc
	*/
	override private function partRemoved(partName : String, instance : Dynamic) : Void
	{
		super.partRemoved(partName, instance);
		if (instance == firstButton)
		{
			firstButton.removeEventListener(MouseEvent.CLICK, onClose);
		}
		else if (instance == secondButton)
		{
			secondButton.removeEventListener(MouseEvent.CLICK, onClose);
		}
	}
}
