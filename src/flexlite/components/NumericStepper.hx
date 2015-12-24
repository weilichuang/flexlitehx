package flexlite.components;


import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.globalization.LocaleID;
import flash.globalization.NumberFormatter;
import flash.ui.Keyboard;

import flexlite.events.UIEvent;

/**
 * 数字调节器
 * @author dom
 */
class NumericStepper extends Spinner
{
	/**
	 * 构造函数
	 */
	public function new()
	{
		super();
	}

	/**
	 * [SkinPart]文本输入组件
	 */
	@SkinPart
	public var textDisplay : TextInput;

	private var dataFormatter : NumberFormatter;
	/**
	 * 最大值改变
	 */
	//private var maxChanged : Bool = false;

	override public function set_maximum( value : Float ) : Float
	{
		maxChanged = true;
		super.maximum = value;
		return value;
	}

	//private var stepSizeChanged : Bool = false;

	override public function set_stepSize( value : Float ) : Float
	{
		stepSizeChanged = true;
		super.stepSize = value;
		return value;
	}

	private var _maxChars : Int = 0;
	public var maxChars(get, set):Int;

	private var maxCharsChanged : Bool = false;

	/**
	 * 字段中最多可输入的字符数。0 值表示可以输入任意数目的字符。
	 */
	private function get_maxChars() : Int
	{
		return _maxChars;
	}

	private function set_maxChars( value : Int ) : Int
	{
		if ( value == _maxChars )
			return value;

		_maxChars = value;
		maxCharsChanged = true;

		invalidateProperties();
		
		return value;
	}

	private var _valueFormatFunction : Dynamic;
	
	public var valueFormatFunction(get, set):Dynamic;

	private var valueFormatFunctionChanged : Bool;

	/**
	 * 格式化数字为textInput中显示的文字的回调函数。示例： funcName(value:Float):String
	 */
	private function get_valueFormatFunction() : Dynamic
	{
		return _valueFormatFunction;
	}

	private function set_valueFormatFunction( value : Dynamic ) : Dynamic
	{
		_valueFormatFunction = value;
		valueFormatFunctionChanged = true;
		invalidateProperties();
		return value;
	}

	private var _valueParseFunction : Dynamic;
	public var valueParseFunction(get, set):Dynamic;
	
	private var valueParseFunctionChanged : Bool;

	/**
	 * 格式化textInput中输入的文字为数字的回调函数。示例： funcName(value:String):Float
	 */
	private function get_valueParseFunction() : Dynamic
	{
		return _valueParseFunction;
	}

	private function set_valueParseFunction( value : Dynamic ) : Dynamic
	{
		_valueParseFunction = value;
		valueParseFunctionChanged = true;
		invalidateProperties();
		return value;
	}


	override private function commitProperties() : Void
	{
		super.commitProperties();

		if ( maxChanged || stepSizeChanged || valueFormatFunctionChanged )
		{
			if ( textDisplay != null )
				textDisplay.widthInChars = calculateWidestValue();
			maxChanged = false;
			stepSizeChanged = false;

			if ( valueFormatFunctionChanged )
			{
				applyDisplayFormatFunction();

				valueFormatFunctionChanged = false;
			}
		}

		if ( valueParseFunctionChanged )
		{
			commitTextInput( false );
			valueParseFunctionChanged = false;
		}

		if ( maxCharsChanged )
		{
			if ( textDisplay != null )
				textDisplay.maxChars = _maxChars;
			maxCharsChanged = false;
		}
	}

	override private function partRemoved( partName : String, instance : Dynamic ) : Void
	{
		super.partAdded( partName, instance );

		if ( instance == textDisplay )
		{
			textDisplay.removeEventListener( FocusEvent.FOCUS_OUT, textDisplay_focusOutHandler );
			textDisplay.removeEventListener( KeyboardEvent.KEY_DOWN, textDisplay_keyDownHandle );
		}
	}

	override private function partAdded( partName : String, instance : Dynamic ) : Void
	{
		super.partAdded( partName, instance );

		if ( instance == textDisplay )
		{
			textDisplay.addEventListener( FocusEvent.FOCUS_OUT, textDisplay_focusOutHandler );
			textDisplay.addEventListener( KeyboardEvent.KEY_DOWN, textDisplay_keyDownHandle );
			textDisplay.maxChars = _maxChars;

			textDisplay.restrict = "0-9\\-\\.\\,";
			textDisplay.text = Std.string(value);
			textDisplay.widthInChars = calculateWidestValue();
		}
	}

	override public function setFocus() : Void
	{
		if ( stage != null )
		{
			stage.focus = cast textDisplay.textDisplay;
			if ( textDisplay.textDisplay != null &&
				( textDisplay.textDisplay.editable || textDisplay.textDisplay.selectable ))
			{
				textDisplay.textDisplay.selectAll();
			}
		}
	}

	override private function setValue( newValue : Float ) : Void
	{
		super.setValue( newValue );

		applyDisplayFormatFunction();
	}

	override public function changeValueByStep( increase : Bool = true ) : Void
	{
		commitTextInput();

		super.changeValueByStep( increase );
	}

	/**
	 * 提交属性改变的值
	 */
	private function commitTextInput( dispatchChange : Bool = false ) : Void
	{
		var inputValue : Float;
		var prevValue : Float = value;

		if ( valueParseFunction != null )
		{
			inputValue = valueParseFunction( textDisplay.text );
		}
		else
		{
			if ( dataFormatter == null )
				dataFormatter = new NumberFormatter( LocaleID.DEFAULT );

			inputValue = dataFormatter.parseNumber( textDisplay.text );
		}

		if (( textDisplay.text != null && textDisplay.text.length != Std.string(value).length)
			|| textDisplay.text == "" || ( inputValue != value &&
			( Math.abs( inputValue - value ) >= 0.000001 || Math.isNaN( inputValue ))))
		{
			setValue( nearestValidValue( inputValue, snapInterval ));
			if ( value == prevValue && inputValue != prevValue )
				dispatchEvent( new UIEvent( UIEvent.VALUE_COMMIT ));
		}

		if ( dispatchChange )
		{
			if ( value != prevValue )
				dispatchEvent( new Event( Event.CHANGE ));
		}
	}

	/**
	 * 计算水平字符数
	 */
	private function calculateWidestValue() : Float
	{
		var widestNumber : Float = Std.string(minimum).length >
			Std.string(maximum).length ?
			minimum :
			maximum;
		widestNumber += stepSize;

		if ( valueFormatFunction != null )
			return valueFormatFunction( widestNumber ).length;
		else
			return Std.string(widestNumber).length;
	}

	/**
	 * 应用格式化函数
	 */
	private function applyDisplayFormatFunction() : Void
	{
		if ( valueFormatFunction != null )
		{
			if ( textDisplay != null )
				textDisplay.text = valueFormatFunction( value );
		}
		else
		{
			if ( textDisplay != null )
				textDisplay.text = Std.string(value);
		}

	}

	/**
	 * 文本输入框失去焦点
	 */
	private function textDisplay_focusOutHandler( event : Event ) : Void
	{
		commitTextInput( true );
	}
	
	private function textDisplay_keyDownHandle(event:KeyboardEvent):Void
	{
		if(event.keyCode == Keyboard.ENTER)
		{
			commitTextInput( true );
		}
	}
}
