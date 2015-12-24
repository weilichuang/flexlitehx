package flexlite.skins.vector;


import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;


import flexlite.skins.VectorSkin;



/**
* 按钮默认皮肤
* @author weilichuang
*/
class TitleWindowCloseButtonSkin extends VectorSkin
{
    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled"];
        this.minHeight = 16;
        this.minWidth = 16;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        
        var g : Graphics = graphics;
        g.clear();
        g.beginFill(0xFFFFFF, 0);
        g.drawRect(0, 0, w, h);
        g.endFill();
        var offsetX : Float = Math.round(w * 0.5 - 8);
        var offsetY : Float = Math.round(h * 0.5 - 8);
        switch (currentState)
        {
            case "up", "disabled":
                drawCloseIcon(0xcccccc, offsetX, offsetY);
            case "over":
                drawCloseIcon(0x555555, offsetX, offsetY);
            case "down":
                drawCloseIcon(0xcccccc, offsetX, offsetY + 1);
        }
        this.alpha = currentState == ("disabled") ? 0.5 : 1;
    }
    /**
	* 绘制关闭图标
	*/
    private function drawCloseIcon(color : Int, offsetX : Float, offsetY : Float) : Void
    {
        var g : Graphics = graphics;
        g.lineStyle(2, color, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
        g.moveTo(offsetX + 6, offsetY + 6);
        g.lineTo(offsetX + 10, offsetY + 10);
        g.endFill();
        g.moveTo(offsetX + 10, offsetY + 6);
        g.lineTo(offsetX + 6, offsetY + 10);
        g.endFill();
        g.lineStyle();
        g.beginFill(color);
        g.drawEllipse(offsetX + 0, offsetY + 0, 16, 16);
        g.drawEllipse(offsetX + 2, offsetY + 2, 12, 12);
        g.endFill();
    }
}
