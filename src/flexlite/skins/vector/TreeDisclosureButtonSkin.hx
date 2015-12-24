package flexlite.skins.vector;


import flash.display.Graphics;


import flexlite.skins.VectorSkin;


/**
* ComboBox的下拉按钮默认皮肤
* @author weilichuang
*/
class TreeDisclosureButtonSkin extends VectorSkin
{
    public var overColor(get, set) : Int;
    public var selectedColor(get, set) : Int;

    public function new()
    {
        super();
        states = ["up", "over", "down", "disabled"];
        this.height = 9;
        this.width = 9;
    }
    
    private var _overColor : Int = 0x666666;
    /**
	* 鼠标经过时的箭头颜色,默认0x666666。
	*/
    private function get_overColor() : Int
    {
        return _overColor;
    }
    private function set_overColor(value : Int) : Int
    {
        if (_overColor == value) 
            return value;
        _overColor = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _selectedColor : Int = 0x333333;
    /**
	* 节点开启时的箭头颜色,默认0x333333。
	*/
    private function get_selectedColor() : Int
    {
        return _selectedColor;
    }
    private function set_selectedColor(value : Int) : Int
    {
        if (_selectedColor == value) 
            return value;
        _selectedColor = value;
        invalidateDisplayList();
        return value;
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
        g.drawRect(0, 0, 9, 9);
        g.endFill();
        var arrowColor : UInt = 0;
        var selected : Bool = false;
        switch (currentState)
        {
            case "up", "disabled", "over", "down":
                arrowColor = _overColor;
            case "overAndSelected", "upAndSelected", "downAndSelected", "disabledAndSelected":
                selected = true;
                arrowColor = _selectedColor;
        }
        this.alpha = currentState == "disabled" || currentState == ("disabledAndSelected") ? 0.5 : 1;
        g.beginFill(arrowColor);
        if (selected) 
        {
            g.lineStyle(0, 0, 0);
            g.moveTo(1, 7);
            g.lineTo(7, 7);
            g.lineTo(7, 0);
            g.lineTo(1, 7);
            g.endFill();
        }
        else 
        {
            g.moveTo(2, 0);
            g.lineTo(2, 9);
            g.lineTo(7, 5);
            g.lineTo(2, 0);
            g.endFill();
        }
    }
}
