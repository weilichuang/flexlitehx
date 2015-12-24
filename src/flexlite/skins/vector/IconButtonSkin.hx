package flexlite.skins.vector;

import flexlite.components.UIAsset;

/**
 * 图标按钮默认皮肤
 */
class IconButtonSkin extends ButtonSkin
{
	public function new()
	{
		super();
	}

	public var iconDisplay : UIAsset;

	override private function createChildren() : Void
	{
		iconDisplay = new UIAsset();
		iconDisplay.maintainAspectRatio = true;
		addElement( iconDisplay );
		super.createChildren();
	}

	override private function updateDisplayList( w : Float, h : Float ) : Void
	{
		super.updateDisplayList( w, h );
		
		graphics.clear();
		var textColor : UInt = 0x0;
		switch ( currentState )
		{
			case "up","disabled":
				drawCurrentState( 0, 0, w, h, VectorSkin.borderColors[ 0 ], VectorSkin.borderColors[ 0 ],
					[ VectorSkin.fillColors[ 0 ], VectorSkin.fillColors[ 1 ]], VectorSkin.cornerRadius );
				textColor = VectorSkin.themeColors[ 0 ];
			case "over":
				drawCurrentState( 0, 0, w, h, VectorSkin.borderColors[ 1 ], VectorSkin.borderColors[ 1 ],
					[ VectorSkin.fillColors[ 2 ], VectorSkin.fillColors[ 3 ]], VectorSkin.cornerRadius );
				textColor = VectorSkin.themeColors[ 1 ];
			case "down":
					drawCurrentState( 0, 0, w, h, VectorSkin.borderColors[ 2 ], VectorSkin.borderColors[ 2 ],
						[ VectorSkin.fillColors[ 4 ], VectorSkin.fillColors[ 5 ]], VectorSkin.cornerRadius );
				textColor = VectorSkin.themeColors[ 1 ];
		}
		
		if ( labelDisplay != null )
		{
			labelDisplay.textColor = textColor;
			labelDisplay.applyTextFormatNow();
			labelDisplay.filters = ( currentState == "over" || currentState == "down" ) ? VectorSkin.textOverFilter : null;
			
			iconDisplay.x = w * .5 - iconDisplay.layoutBoundsWidth * .5;
			iconDisplay.y = h * .5 - iconDisplay.layoutBoundsHeight * .5;
		}
		this.alpha = currentState == "disabled" ? 0.5 : 1;
	}
}
