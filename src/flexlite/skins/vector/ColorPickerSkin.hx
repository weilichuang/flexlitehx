package flexlite.skins.vector;

import flash.display.GradientType;
import flash.display.Graphics;

import flexlite.components.Group;
import flexlite.components.PopUpAnchor;
import flexlite.components.RectangularDropShadow;
import flexlite.components.SwitchPanel;
import flexlite.components.supportClasses.ColorPickerButton;
import flexlite.core.PopUpPosition;
import flexlite.core.UIComponent;
import flexlite.events.ResizeEvent;
import flexlite.skins.VectorSkin;

class ColorPickerSkin extends VectorSkin
{
	public var openButton : ColorPickerButton;
	
	public var popUp : PopUpAnchor;
	
	public var dropDown : Group;
	
	public var switchPanel : SwitchPanel;
	
	public function new()
	{
		super();
		this.minWidth = 20;
		this.minHeight = 20;
		this.states = [ "normal", "open", "disabled" ];
	}
	
	override private function createChildren() : Void
	{
		super.createChildren();
		
		openButton = new ColorPickerButton();
		openButton.skinName = ColorPickerButtonSkin;
		openButton.left = 0;
		openButton.right = 0;
		openButton.top = 0;
		openButton.bottom = 0;
		openButton.tabEnabled = false;
		addElement( openButton );
	}
	
	/**
	 * @inheritDoc
	 */
	override private function commitCurrentState() : Void
	{
		super.commitCurrentState();
		switch ( currentState )
		{
			case "open":
				if ( popUp == null )
				{
					createPopUp();
				}
				popUp.displayPopUp = true;
			case "normal":
				if ( popUp != null )
					popUp.displayPopUp = false;
			case "disabled":
		}
	}
	
	/**
	 * dropDown尺寸发生改变
	 */
	private function onResize( event : ResizeEvent = null ) : Void
	{
		var w : Float = Math.isNaN( dropDown.width ) ? 0 : dropDown.width;
		var h : Float = Math.isNaN( dropDown.height ) ? 0 : dropDown.height;
		var g : Graphics = backgroud.graphics;
		g.clear();
		drawRoundRect(
			0, 0, w, h, 0,
			VectorSkin.borderColors[ 0 ], 1,
			verticalGradientMatrix( 0, 0, w, h ),
			GradientType.LINEAR, null,
			{ x: 1, y: 1, w: w - 2, h: h - 2, r: 0 }, g );
		//绘制填充
		drawRoundRect(
			1, 1, w - 2, h - 2, 0,
			0xFFFFFF, 1,
			verticalGradientMatrix( 1, 1, w - 2, h - 2 ), GradientType.LINEAR, null, null, g );
	}
	
	/**
	 * 创建popUp
	 */
	private var backgroud : UIComponent;
	
	private function createPopUp() : Void
	{
		switchPanel = new SwitchPanel();
		switchPanel.left = 4;
		switchPanel.right = 4;
		switchPanel.top = 4;
		switchPanel.bottom = 4;
		
		//dropShadow
		var dropShadow : RectangularDropShadow = new RectangularDropShadow();
		dropShadow.tlRadius = dropShadow.tlRadius = dropShadow.trRadius = dropShadow.blRadius = dropShadow.brRadius = 0;
		dropShadow.blurX = 4;
		dropShadow.blurY = 4;
		dropShadow.alpha = 0.45;
		dropShadow.distance = 5;
		dropShadow.angle = 90;
		dropShadow.color = 0x000000;
		dropShadow.left = 0;
		dropShadow.top = 0;
		dropShadow.right = 0;
		dropShadow.bottom = 0;
		//dropDown
		dropDown = new Group();
		dropDown.addEventListener( ResizeEvent.RESIZE, onResize );
		dropDown.addElement( dropShadow );
		backgroud = new UIComponent();
		dropDown.addElement( backgroud );
		dropDown.addElement( switchPanel );
		//popUp
		popUp = new PopUpAnchor();
		popUp.closeDuration = 0;
		popUp.openDuration = 0;
		popUp.left = 0;
		popUp.right = 0;
		popUp.top = 0;
		popUp.bottom = 0;
		popUp.popUpPosition = PopUpPosition.BELOW;
		popUp.popUpWidthMatchesAnchorWidth = false;
		popUp.popUp = dropDown;
		addElement( popUp );
		if ( hostComponent != null )
			hostComponent.findSkinParts();
	}
}

