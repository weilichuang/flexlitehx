package flexlite.components.supportClasses;

import flash.events.Event;
import flexlite.components.supportclasses.ButtonBase;

import flexlite.components.Rect;

class ColorPickerButton extends ButtonBase
{
	/**
	 * [SkinPart]
	 */
	@SkinPart
	public var colorDisplay:Rect;
	
	public var fillColor(get, set):UInt;
	
	private var _fillColor : UInt = 0x0;
	
	public function new()
	{
		super();
	}
	
	private function set_fillColor(color:UInt):UInt
	{
		_fillColor = color;
		if(colorDisplay != null)
			colorDisplay.fillColor = _fillColor;
			
		return color;
	}
	
	private function get_fillColor():UInt
	{
		return _fillColor;
	}
	
	override private function partAdded( partName : String, instance : Dynamic ) : Void
	{
		super.partAdded( partName, instance );
		
		if ( instance == colorDisplay )
		{
			colorDisplay.fillColor = fillColor;
		}

	}
}