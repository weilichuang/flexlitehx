package flexlite.components.supportclasses;



import flash.events.Event;


import flexlite.events.UIEvent;



@:meta(Event(name="change",type="flash.events.Event"))


@:meta(DXML(show="false"))


@:meta(SkinState(name="up"))

@:meta(SkinState(name="over"))

@:meta(SkinState(name="down"))

@:meta(SkinState(name="disabled"))

@:meta(SkinState(name="upAndSelected"))

@:meta(SkinState(name="overAndSelected"))

@:meta(SkinState(name="downAndSelected"))

@:meta(SkinState(name="disabledAndSelected"))


/**
* 切换按钮组件基类
* @author weilichuang
*/
class ToggleButtonBase extends ButtonBase
{
    public var selected(get, set) : Bool;

    public function new()
    {
        super();
    }
    
    private var _selected : Bool;
    /**
	* 按钮处于按下状态时为 true，而按钮处于弹起状态时为 false。
	*/
    private function get_selected() : Bool
    {
        return _selected;
    }
    
    private function set_selected(value : Bool) : Bool
    {
        if (value == _selected) 
            return value;
        
        _selected = value;
        dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
        invalidateSkinState();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function getCurrentSkinState() : String
    {
        if (!selected) 
            return super.getCurrentSkinState()
        else 
			return super.getCurrentSkinState() + "AndSelected";
    }
    /**
	* 是否根据鼠标事件自动变换选中状态,默认true。
	*/
    public var autoSelected : Bool = true;
    /**
	* @inheritDoc
	*/
    override private function buttonReleased() : Void
    {
        super.buttonReleased();
        if (!autoSelected || !enabled) 
            return;
        selected = !selected;
        dispatchEvent(new Event(Event.CHANGE));
    }
}


