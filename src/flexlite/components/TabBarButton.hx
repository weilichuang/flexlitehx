package flexlite.components;


import flash.events.Event;

import flexlite.components.supportclasses.ToggleButtonBase;




@:meta(DXML(show="false"))

/**
* 数据源发生改变
*/
@:meta(Event(name="dataChange",type="flash.events.Event"))


/**
* 选项卡组件的按钮条目
* @author weilichuang
*/
class TabBarButton extends ToggleButtonBase implements IItemRenderer
{
    public var allowDeselection(get, set) : Bool;
    public var data(get, set) : Dynamic;
    public var itemIndex(get, set) : Int;

    
    public function new()
    {
        super();
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return TabBarButton;
    }
    
    private var _allowDeselection : Bool = true;
    /**
	* 如果为 true，用户单击当前选定的按钮时即会将其取消选择。
	* 如果为 false，用户必须选择不同的按钮才可取消选择当前选定的按钮。
	*/
    private function get_allowDeselection() : Bool
    {
        return _allowDeselection;
    }
    
    private function set_allowDeselection(value : Bool) : Bool
    {
        _allowDeselection = value;
        return value;
    }
    
    private var _data : Dynamic;
    /**
	* @inheritDoc
	*/
    private function get_data() : Dynamic
    {
        return _data;
    }
    
    private function set_data(value : Dynamic) : Dynamic
    {
        _data = value;
        dispatchEvent(new Event("dataChange"));
        return value;
    }
    
    private var _itemIndex : Int;
    /**
	* @inheritDoc
	*/
    private function get_itemIndex() : Int
    {
        return _itemIndex;
    }
    
    private function set_itemIndex(value : Int) : Int
    {
        _itemIndex = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_label(value : String) : String
    {
        if (value != label) 
        {
            super.label = value;
            
            if (labelDisplay != null) 
                labelDisplay.text = label;
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function buttonReleased() : Void
    {
        if (selected && !allowDeselection) 
            return;
        
        super.buttonReleased();
    }
}

