package flexlite.skins.vector;

import flexlite.components.TextInput;

class NumericStepperSkin extends SpinnerSkin
{
	public var textDisplay : TextInput;

	public function new()
	{
		super();
	}

	override private function createChildren() : Void
	{
		super.createChildren();

		textDisplay = new TextInput();
		textDisplay.left = 0;
		textDisplay.top = 0;
		textDisplay.bottom = 0;
		textDisplay.right = 15;
		addElementAt(textDisplay,0);
	}
}
