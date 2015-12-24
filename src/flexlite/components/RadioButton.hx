package flexlite.components;

import flexlite.components.RadioButtonGroup;

import flash.events.Event;


import flexlite.components.supportclasses.ToggleButtonBase;
import flexlite.events.UIEvent;
import flexlite.utils.SharedMap;



@:meta(DXML(show="true"))


/**
* 单选按钮
* @author weilichuang
*/
class RadioButton extends ToggleButtonBase
{
    public var group(get, set) : RadioButtonGroup;
    public var groupName(get, set) : String;
    public var value(get, set) : Dynamic;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        groupName = "radioGroup";
    }
    
    override private function get_hostComponentKey() : Dynamic
    {
        return RadioButton;
    }
    /**
	* 在RadioButtonGroup中的索引
	*/
    public var indexNumber : Int = 0;
    /**
	* 所属的RadioButtonGroup
	*/
    public var radioButtonGroup : RadioButtonGroup = null;
    
    override private function get_enabled() : Bool
    {
        if (!super.enabled) 
            return false;
        return radioButtonGroup == null || radioButtonGroup.enabled;
    }
    
    /**
	* 存储根据groupName自动创建的RadioButtonGroup列表
	*/
    private static var automaticRadioButtonGroups : SharedMap;
    
    private var _group : RadioButtonGroup;
    /**
	* 此单选按钮所属的组。同一个组的多个单选按钮之间互斥。
	* 若不设置此属性，则根据groupName属性自动创建一个唯一的RadioButtonGroup。
	*/
    private function get_group() : RadioButtonGroup
    {
        if (_group == null && _groupName != null) 
        {
            if (automaticRadioButtonGroups == null) 
                automaticRadioButtonGroups = new SharedMap();
            var g : RadioButtonGroup = automaticRadioButtonGroups.get(_groupName);
            if (g == null) 
            {
                g = new RadioButtonGroup();
                g.name = _groupName;
                automaticRadioButtonGroups.set(_groupName, g);
            }
            _group = g;
        }
        return _group;
    }
    private function set_group(value : RadioButtonGroup) : RadioButtonGroup
    {
        if (_group == value) 
            return value;
        if (radioButtonGroup != null) 
            radioButtonGroup.removeInstance(this);
        _group = value;
        _groupName = (value != null) ? group.name : "radioGroup";
        groupChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
        return value;
    }
    
    private var groupChanged : Bool = false;
    
    private var _groupName : String = "radioGroup";
    /**
	* 所属组的名称,具有相同组名的多个单选按钮之间互斥。默认值:"radioGroup"。
	* 可以把此属性当做设置组的一个简便方式，作用与设置group属性相同,。
	*/
    private function get_groupName() : String
    {
        return _groupName;
    }
    private function set_groupName(value : String) : String
    {
        if (value == null || value == "") 
            return value;
        _groupName = value;
        if (radioButtonGroup != null) 
            radioButtonGroup.removeInstance(this);
        _group = null;
        groupChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
        return value;
    }
    /**
	* @inheritDoc
	*/
    override private function set_selected(value : Bool) : Bool
    {
        super.selected = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _value : Dynamic;
    /**
	* 与此单选按钮关联的自定义数据。
	* 当被点击时，所属的RadioButtonGroup对象会把此属性赋值给ItemClickEvent.item属性并抛出事件。
	*/
    private function get_value() : Dynamic
    {
        return _value;
    }
    private function set_value(value : Dynamic) : Dynamic
    {
        if (_value == value) 
            return value;
        
        _value = value;
        
        if (selected && group != null) 
            group.dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
        return value;
    }
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        if (groupChanged) 
        {
            addToGroup();
            groupChanged = false;
        }
        super.commitProperties();
    }
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float,
            unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if (group != null) 
        {
            if (selected) 
                _group.selection = this
            else if (group.selection == this) 
                _group.selection = null;
        }
    }
    /**
	* @inheritDoc
	*/
    override private function buttonReleased() : Void
    {
        if (!enabled || selected) 
            return;
        if (radioButtonGroup == null) 
            addToGroup();
        super.buttonReleased();
        group.setSelection(this);
    }
    /**
	* 添此单选按钮加到组
	*/
    private function addToGroup() : RadioButtonGroup
    {
        var g : RadioButtonGroup = group;
        if (g != null) 
            g.addInstance(this);
        return g;
    }
}


