package flexlite.components;

import flash.display.DisplayObject;
import flash.events.Event;
import flexlite.components.supportClasses.ColorPickerButton;
import flexlite.components.supportclasses.DropDownController;

import flexlite.events.UIEvent;

/**
 * 下拉框打开事件
 * @eventType flexlite.events.UIEvent.OPEN
 */
@:meta([Event( name = "open", type = "flexlite.events.UIEvent" )])
/**
 * 下来框关闭事件
 */
@:meta([Event( name = "close", type = "flexlite.events.UIEvent" )])

@:meta([SkinState( "normal" )])
@:meta([SkinState( "open" )])
@:meta([SkinState( "disabled" )])

class ColorPicker extends SkinnableComponent
{
	/**
	 * [SkinPart]
	 */
	@SkinPart
	public var openButton : ColorPickerButton;
	
	/**
	 * [SkinPart]
	 */
	@SkinPart
	public var dropDown:DisplayObject;
	
	/**
	 * [SkinPart]
	 */
	@SkinPart
	public var switchPanel:SwitchPanel;

	/**
	 * 颜色改变标志
	 */
	private var colorChanged : Bool = false;

	private var _selectColor : UInt = 0xFFFFFF;

	public function new()
	{
		super();
		dropDownController = new DropDownController();
	}
	
	public var selectColor(get, set):UInt;
	private function get_selectColor():UInt
	{
		return _selectColor;
	}
	
	private function set_selectColor(color:UInt):UInt
	{
		if(_selectColor == color)
			return _selectColor;
		
		_selectColor = color;
		
		if(openButton != null)
			openButton.fillColor = color;
		if(switchPanel != null)
			switchPanel.selectColor = color;
		
		dispatchEvent(new Event(Event.CHANGE));
		
		return _selectColor;
	}

	/**
	 * 打开下拉列表并抛出UIEvent.OPEN事件。
	 */
	public function openDropDown() : Void
	{
		dropDownController.openDropDown();
	}

	/**
	 * 关闭下拉列表并抛出UIEvent.CLOSE事件。
	 */
	public function closeDropDown( commit : Bool ) : Void
	{
		dropDownController.closeDropDown( commit );
	}

	private var _dropDownController : DropDownController;
	
	public var dropDownController(get, set):DropDownController;

	/**
	 * 下拉控制器
	 */
	private function get_dropDownController() : DropDownController
	{
		return _dropDownController;
	}

	private function set_dropDownController( value : DropDownController ) : DropDownController
	{
		if ( _dropDownController == value )
			return _dropDownController;

		_dropDownController = value;

		_dropDownController.addEventListener( UIEvent.OPEN, dropDownController_openHandler );
		_dropDownController.addEventListener( UIEvent.CLOSE, dropDownController_closeHandler );

		if ( openButton != null )
			_dropDownController.openButton = openButton;
		if ( dropDown != null )
			_dropDownController.dropDown = dropDown;
			
		return _dropDownController;
	}

	public var isDropDownOpen(get, never):Bool;
	/**
	 * 下拉列表是否已经已打开
	 */
	private function get_isDropDownOpen() : Bool
	{
		if ( dropDownController != null )
			return dropDownController.isOpen;
		else
			return false;
	}

	/**
	 * @inheritDoc
	 */
	override private function commitProperties() : Void
	{
		super.commitProperties();

		if ( colorChanged )
		{
			colorChanged = false;
			updateRectDisplay();
		}
	}

	/**
	 * 更新选中项的提示文本
	 */
	private function updateRectDisplay( displayItem : Dynamic = null ) : Void
	{
		if ( openButton != null )
		{
			openButton.fillColor = selectColor;
		}
	}

	/**
	 * @inheritDoc
	 */
	override private function partAdded( partName : String, instance : Dynamic ) : Void
	{
		super.partAdded( partName, instance );

		if ( instance == openButton )
		{
			if ( dropDownController != null )
				dropDownController.openButton = openButton;
			
			openButton.fillColor = selectColor;
		}
		else if(instance == switchPanel)
		{
			switchPanel.addEventListener(Event.SELECT,onColorSelect);
			switchPanel.selectColor = selectColor;
		}
		else if ( instance == dropDown && dropDownController != null )
		{
			dropDownController.dropDown = dropDown;
		}
	}
	
	private function onColorSelect(event:Event):Void
	{
		this.selectColor = switchPanel.selectColor;
		closeDropDown(true);
	}
	
	/**
	 * @inheritDoc
	 */
	override private function partRemoved( partName : String, instance : Dynamic ) : Void
	{
		if(instance == switchPanel)
		{
			switchPanel.removeEventListener(Event.SELECT,onColorSelect);
		}
		
		if ( dropDownController != null )
		{
			if ( instance == openButton )
				dropDownController.openButton = null;
			
			if ( instance == dropDown )
				dropDownController.dropDown = null;
		}

		super.partRemoved( partName, instance );
	}
	
	/**
	 * @inheritDoc
	 */
	override private function getCurrentSkinState() : String
	{
		return !enabled ? "disabled" : isDropDownOpen ? "open" : "normal";
	}

	/**
	 * 控制器抛出打开列表事件
	 */
	private function dropDownController_openHandler( event : UIEvent ) : Void
	{
		addEventListener( UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler );
		invalidateSkinState();
	}

	/**
	 * 打开列表后组件一次失效验证全部完成
	 */
	private function open_updateCompleteHandler( event : UIEvent ) : Void
	{
		removeEventListener( UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler );

		dispatchEvent( new UIEvent( UIEvent.OPEN ));
	}

	/**
	 * 控制器抛出关闭列表事件
	 */
	private function dropDownController_closeHandler( event : UIEvent ) : Void
	{
		addEventListener( UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler );
		invalidateSkinState();
	}

	/**
	 * 关闭列表后组件一次失效验证全部完成
	 */
	private function close_updateCompleteHandler( event : UIEvent ) : Void
	{
		removeEventListener( UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler );

		dispatchEvent( new UIEvent( UIEvent.CLOSE ));
	}
}
