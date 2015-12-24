package flexlite.components;

import flash.events.Event;
import flexlite.components.supportclasses.Range;

import flexlite.events.UIEvent;

/**
 * 当控件的值由于用户交互操作而发生更改时分派。
 */
@:meta([Event( name = "change", type = "flash.events.Event" )])

/**
 * 微调控制器
 * @author dom
 */
class Spinner extends Range
{
	/**
	 * 构造函数
	 */
	public function new() : Void
	{
		super();
	}

	/**
	 * [SkinPart]减小值按钮
	 */
	@SkinPart
	public var decrementButton : Button;
	/**
	 * [SkinPart]增大值按钮
	 */
	@SkinPart
	public var incrementButton : Button;

	private var _allowValueWrap : Bool = false;
	public var allowValueWrap(get, set):Bool;

	/**
	 * 此属性为true时，当value已达到最大值时，还要继续增大将会跳到最小值重新循环，反之当小于最小值时将跳到最大值。
	 */
	private function get_allowValueWrap() : Bool
	{
		return _allowValueWrap;
	}

	private function set_allowValueWrap( value : Bool ) : Bool
	{
		return _allowValueWrap = value;
	}

	override private function partAdded( partName : String, instance : Dynamic ) : Void
	{
		super.partAdded( partName, instance );

		if ( instance == incrementButton )
		{
			incrementButton.addEventListener( UIEvent.BUTTON_DOWN,
				incrementButton_buttonDownHandler );
			incrementButton.autoRepeat = true;
		}
		else if ( instance == decrementButton )
		{
			decrementButton.addEventListener( UIEvent.BUTTON_DOWN,
				decrementButton_buttonDownHandler );
			decrementButton.autoRepeat = true;
		}
	}

	override private function partRemoved( partName : String, instance : Dynamic ) : Void
	{
		super.partRemoved( partName, instance );

		if ( instance == incrementButton )
		{
			incrementButton.removeEventListener( UIEvent.BUTTON_DOWN,
				incrementButton_buttonDownHandler );
		}
		else if ( instance == decrementButton )
		{
			decrementButton.removeEventListener( UIEvent.BUTTON_DOWN,
				decrementButton_buttonDownHandler );
		}
	}

	override public function changeValueByStep( increase : Bool = true ) : Void
	{
		if ( allowValueWrap )
		{
			if ( increase && ( value == maximum ))
				value = minimum;
			else if ( !increase && ( value == minimum ))
				value = maximum;
			else
				super.changeValueByStep( increase );
		}
		else
			super.changeValueByStep( increase );
	}

	/**
	 * 增大值按钮按下事件
	 */
	private function incrementButton_buttonDownHandler( event : Event ) : Void
	{
		var prevValue : Float = this.value;

		changeValueByStep( true );

		if ( value != prevValue )
			dispatchEvent( new Event( "change" ));
	}

	/**
	 * 减小值按钮按下事件
	 */
	private function decrementButton_buttonDownHandler( event : Event ) : Void
	{
		var prevValue : Float = this.value;

		changeValueByStep( false );

		if ( value != prevValue )
			dispatchEvent( new Event( "change" ));
	}
}
