package flexlite.skins.vector;

import flexlite.components.Button;
import flexlite.skins.VectorSkin;

class SpinnerSkin extends VectorSkin
{

	public var decrementButton : Button;

	public var incrementButton : Button;

	public function new()
	{
		super();
	}

	override private function createChildren() : Void
	{
		super.createChildren();

		incrementButton = new Button();
		incrementButton.repeatDelay = 100;
		incrementButton.top = 0;
		incrementButton.right = 0;
		incrementButton.skinName = SpinnerUpButtonSkin;
		addElement( incrementButton );
		
		decrementButton = new Button();
		decrementButton.repeatDelay = 100;
		decrementButton.bottom = 0;
		decrementButton.right = 0;
		decrementButton.skinName = SpinnerDownButtonSkin;
		addElement( decrementButton );
	}
}
