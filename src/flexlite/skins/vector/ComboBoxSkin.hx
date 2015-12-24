package flexlite.skins.vector;


import flash.display.GradientType;
import flash.display.Graphics;

import flexlite.components.Button;
import flexlite.components.DataGroup;
import flexlite.components.Group;
import flexlite.components.PopUpAnchor;
import flexlite.components.RectangularDropShadow;
import flexlite.components.Scroller;
import flexlite.components.TextInput;
import flexlite.core.PopUpPosition;
import flexlite.core.UIComponent;

import flexlite.events.ResizeEvent;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.VerticalLayout;
import flexlite.skins.VectorSkin;


/**
* ComboBox默认皮肤
* @author weilichuang
*/
class ComboBoxSkin extends VectorSkin
{
    public function new()
    {
        super();
        this.states = ["normal", "open", "disabled"];
    }
    
    public var dataGroup : DataGroup;
    
    public var dropDown : Group;
    
    public var openButton : Button;
    
    public var popUp : PopUpAnchor;
    
    public var scroller : Scroller;
    
    public var textInput : TextInput;
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        
        openButton = new Button();
        openButton.width = 20;
        openButton.right = 0;
        openButton.top = 0;
        openButton.bottom = 0;
        openButton.skinName = ComboBoxButtonSkin;
        addElement(openButton);
        
        textInput = new TextInput();
        textInput.skinName = ComboBoxTextInputSkin;
        textInput.left = 0;
        textInput.right = 19;
        textInput.top = 0;
        textInput.bottom = 0;
        addElement(textInput);
    }
    
    private var backgroud : UIComponent;
    /**
	* dropDown尺寸发生改变
	*/
    private function onResize(event : ResizeEvent = null) : Void
    {
        var w : Float = (Math.isNaN(dropDown.width)) ? 0 : dropDown.width;
        var h : Float = (Math.isNaN(dropDown.height)) ? 0 : dropDown.height;
        var g : Graphics = backgroud.graphics;
        g.clear();
        var crr1 : Float = VectorSkin.cornerRadius > (0) ? VectorSkin.cornerRadius - 1 : 0;
        drawRoundRect(
                0, 0, w, h, VectorSkin.cornerRadius,
                VectorSkin.borderColors[0], 1,
                verticalGradientMatrix(0, 0, w, h),
                GradientType.LINEAR, null,
                {
                    x : 1,
                    y : 1,
                    w : w - 2,
                    h : h - 2,
                    r : crr1,

                }, g);
        //绘制填充
        drawRoundRect(
                1, 1, w - 2, h - 2, crr1,
                0xFFFFFF, 1,
                verticalGradientMatrix(1, 1, w - 2, h - 2), GradientType.LINEAR, null, null, g);
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitCurrentState() : Void
    {
        super.commitCurrentState();
        switch (currentState)
        {
            case "open":
                if (popUp == null) 
                {
                    createPopUp();
                }
                popUp.displayPopUp = true;
            case "normal":
                if (popUp != null) 
                    popUp.displayPopUp = false;
            case "disabled":
        }
    }
    /**
	* 创建popUp
	*/
    private function createPopUp() : Void
    {
        //dataGroup
        dataGroup = new DataGroup();
        var layout : VerticalLayout = new VerticalLayout();
        layout.gap = 0;
        layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
        dataGroup.layout = layout;
        //scroller
        scroller = new Scroller();
        scroller.left = 2;
        scroller.top = 2;
        scroller.right = 2;
        scroller.bottom = 2;
        scroller.minViewportInset = 1;
        scroller.viewport = dataGroup;
        //dropShadow
        var dropShadow : RectangularDropShadow = new RectangularDropShadow();
        dropShadow.tlRadius = dropShadow.tlRadius = dropShadow.trRadius = dropShadow.blRadius = dropShadow.brRadius = VectorSkin.cornerRadius;
        dropShadow.blurX = 20;
        dropShadow.blurY = 20;
        dropShadow.alpha = 0.45;
        dropShadow.distance = 7;
        dropShadow.angle = 90;
        dropShadow.color = 0x000000;
        dropShadow.left = 0;
        dropShadow.top = 0;
        dropShadow.right = 0;
        dropShadow.bottom = 0;
        //dropDown
        dropDown = new Group();
        dropDown.addEventListener(ResizeEvent.RESIZE, onResize);
        dropDown.addElement(dropShadow);
        backgroud = new UIComponent();
        dropDown.addElement(backgroud);
        dropDown.addElement(scroller);
        onResize();
        //popUp
        popUp = new PopUpAnchor();
        popUp.left = 0;
        popUp.right = 0;
        popUp.top = 0;
        popUp.bottom = 0;
        popUp.popUpPosition = PopUpPosition.BELOW;
        popUp.popUpWidthMatchesAnchorWidth = true;
        popUp.popUp = dropDown;
        addElement(popUp);
        if (hostComponent != null) 
            hostComponent.findSkinParts();
    }
}
