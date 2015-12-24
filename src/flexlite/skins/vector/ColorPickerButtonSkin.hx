package flexlite.skins.vector;

import flexlite.components.Rect;
import flexlite.skins.VectorSkin;

class ColorPickerButtonSkin extends VectorSkin
{
	private var _borderColor : UInt = 0x0;
	
	public var colorDisplay : Rect;
	
	public function new()
	{
		super();
		this.minHeight = 20;
		this.minWidth = 20;
	}
	
	override private function createChildren() : Void
	{
		super.createChildren();
		
		this.mouseChildren = false;
		
		colorDisplay = new Rect();
		colorDisplay.mouseChildren = false;
		colorDisplay.mouseEnabled = false;
		colorDisplay.strokeColor = _borderColor;
		colorDisplay.strokeAlpha = 1;
		colorDisplay.strokeWeight = 2;
		colorDisplay.fillAlpha = 1;
		colorDisplay.fillColor = 0xFFFFFF;
		colorDisplay.top = 0;
		colorDisplay.bottom = 0;
		colorDisplay.left = 0;
		colorDisplay.right = 0;
		addElement( colorDisplay );
	}
	
	override private function updateDisplayList( w : Float, h : Float ) : Void
	{
		super.updateDisplayList( w, h );
		this.alpha = currentState == "disabled" ? 0.5 : 1;
	}
}

