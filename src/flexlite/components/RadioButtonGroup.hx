package flexlite.components;



import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.Lib;


import flexlite.core.FlexLiteGlobals;
import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.core.UIComponent;
import flexlite.events.UIEvent;



/**
* 选中项改变事件。仅当用户与此控件交互时才抛出此事件。 
* 以编程方式更改选中项的值时，该控件并不抛出change事件，而是抛出valueCommit事件。
*/
@:meta(Event(name="change",type="flash.events.Event"))

/**
* 属性提交事件
*/
@:meta(Event(name="valueCommit",type="flexlite.events.UIEvent"))


@:meta(DXML(show="false"))


/**
* 单选按钮组
* @author weilichuang
*/
class RadioButtonGroup extends EventDispatcher
{
    public var enabled(get, set) : Bool;
    public var numRadioButtons(get, never) : Int;
    public var selectedValue(get, set) : Dynamic;
    public var selection(get, set) : RadioButton;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        name = "radioButtonGroup" + groupCount;
        groupCount++;
    }
    
    private static var groupCount : Int = 0;
    /**
	* 组名
	*/
    public var name : String;
    /**
	* 单选按钮列表
	*/
    public var radioButtons : Array<RadioButton> = [];
    
    private var _enabled : Bool = true;
    /**
	* 组件是否可以接受用户交互。默认值为true。设置此属性将影响组内所有单选按钮。
	*/
    private function get_enabled() : Bool
    {
        return _enabled;
    }
    private function set_enabled(value : Bool) : Bool
    {
        if (_enabled == value) 
            return value;
        
        _enabled = value;
        for (i in 0...numRadioButtons){getRadioButtonAt(i).invalidateSkinState();
        }
        return value;
    }
    /**
	* 组内单选按钮数量
	*/
    private function get_numRadioButtons() : Int
    {
        return radioButtons.length;
    }
    
    private var _selectedValue : Dynamic;
    /**
	* 当前被选中的单选按钮的value属性值。注意，此属性仅当目标RadioButton在显示列表时有效。
	*/
    private function get_selectedValue() : Dynamic
    {
        if (selection != null) 
        {
            return selection.value != (null) ? 
            selection.value : 
            selection.label;
        }
        return null;
    }
    private function set_selectedValue(value : Dynamic) : Dynamic
    {
        _selectedValue = value;
        if (value == null) 
        {
            setSelection(null, false);
            return value;
        }
        var n : Int = numRadioButtons;
        for (i in 0...n){
            var radioButton : RadioButton = getRadioButtonAt(i);
            if (radioButton.value == value ||
                radioButton.label == value) 
            {
                changeSelection(i, false);
                _selectedValue = null;
                
                dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
                
                break;
            }
        }
        return value;
    }
    
    private var _selection : RadioButton;
    /**
	* 当前被选中的单选按钮引用,注意，此属性仅当目标RadioButton在显示列表时有效。
	*/
    private function get_selection() : RadioButton
    {
        return _selection;
    }
    private function set_selection(value : RadioButton) : RadioButton
    {
        if (_selection == value) 
            return value;
        setSelection(value, false);
        return value;
    }
    /**
	* 获取指定索引的单选按钮
	* @param index 单选按钮的索引
	*/
    public function getRadioButtonAt(index : Int) : RadioButton
    {
        if (index >= 0 && index < numRadioButtons) 
            return radioButtons[index];
        
        return null;
    }
    /**
	* 添加单选按钮到组内
	*/
    public function addInstance(instance : RadioButton) : Void
    {
        instance.addEventListener(Event.REMOVED, radioButton_removedHandler);
        
        radioButtons.push(instance);
        radioButtons.sort(breadthOrderRadioCompare);
        for (i in 0...radioButtons.length){radioButtons[i].indexNumber = i;
        }
        if (_selectedValue != null) 
            selectedValue = _selectedValue;
        if (instance.selected == true) 
            selection = instance;
        
        instance.radioButtonGroup = this;
        instance.invalidateSkinState();
        
        dispatchEvent(new Event("numRadioButtonsChanged"));
    }
    /**
	* 从组里移除单选按钮
	*/
    public function removeInstance(instance : RadioButton) : Void
    {
        doRemoveInstance(instance, false);
    }
    /**
	* 执行从组里移除单选按钮
	*/
    private function doRemoveInstance(instance : RadioButton, addListener : Bool = true) : Void
    {
        if (instance != null) 
        {
            var foundInstance : Bool = false;
			var i:Int = 0;
            while (i < numRadioButtons)
			{
                var rb : RadioButton = getRadioButtonAt(i);
                
                if (foundInstance) 
                {
                    
                    rb.indexNumber = rb.indexNumber - 1;
                }
                else if (rb == instance) 
                {
                    if (addListener) 
                        instance.addEventListener(Event.ADDED, radioButton_addedHandler);
                    if (instance == _selection) 
                        _selection = null;
                    
                    instance.radioButtonGroup = null;
                    instance.invalidateSkinState();
                    radioButtons.splice(i, 1);
                    foundInstance = true;
                    i--;
                }
				i++;
            }
            
            if (foundInstance) 
                dispatchEvent(new Event("numRadioButtonsChanged"));
        }
    }
    /**
	* 设置选中的单选按钮
	*/
    public function setSelection(value : RadioButton, fireChange : Bool = true) : Void
    {
        if (_selection == value) 
            return;
        
        if (value == null) 
        {
            if (selection != null) 
            {
                _selection.selected = false;
                _selection = null;
                if (fireChange) 
                    dispatchEvent(new Event(Event.CHANGE));
            }
        }
        else 
        {
            var n : Int = numRadioButtons;
            for (i in 0...n){
                if (value == getRadioButtonAt(i)) 
                {
                    changeSelection(i, fireChange);
                    break;
                }
            }
        }
        dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
    }
    /**
	* 改变选中项
	*/
    private function changeSelection(index : Int, fireChange : Bool = true) : Void
    {
        var rb : RadioButton = getRadioButtonAt(index);
        if (rb != null && rb != _selection) 
        {
            
            if (_selection != null) 
                _selection.selected = false;
            _selection = rb;
            _selection.selected = true;
            if (fireChange) 
                dispatchEvent(new Event(Event.CHANGE));
        }
    }
	
	private function breadthOrderRadioCompare(a : RadioButton, b : RadioButton) : Int
    {
		return breadthOrderCompare(a, b);
	}
    
    /**
	* 显示对象深度排序
	*/
    private function breadthOrderCompare(a : DisplayObject, b : DisplayObject) : Int
    {
        var aParent : DisplayObjectContainer = a.parent;
        var bParent : DisplayObjectContainer = b.parent;
        
        if (aParent == null || bParent == null) 
            return 0;
        
        var aNestLevel : Int = Std.is(a, UIComponent) ? cast(a, UIComponent).nestLevel : -1;
        var bNestLevel : Int = Std.is(b, UIComponent) ? cast(b, UIComponent).nestLevel : -1;
        
        var aIndex : Int = 0;
        var bIndex : Int = 0;
        
        if (aParent == bParent) 
        {
            if (Std.is(aParent, IVisualElementContainer) && Std.is(a, IVisualElement)) 
                aIndex = Lib.as(aParent, IVisualElementContainer).getElementIndex(Lib.as(a, IVisualElement));
            else 
            aIndex = cast(aParent, DisplayObjectContainer).getChildIndex(a);
            
            if (Std.is(bParent, IVisualElementContainer) && Std.is(b, IVisualElement)) 
                bIndex = Lib.as(bParent, IVisualElementContainer).getElementIndex(Lib.as(b, IVisualElement));
            else 
				bIndex = cast(bParent, DisplayObjectContainer).getChildIndex(b);
        }
        
        if (aNestLevel > bNestLevel || aIndex > bIndex) 
            return 1;
        else if (aNestLevel < bNestLevel || bIndex > aIndex) 
            return -1;
        else if (a == b) 
            return 0;
        else 
			return breadthOrderCompare(aParent, bParent);
    }
    /**
	* 单选按钮添加到显示列表
	*/
    private function radioButton_addedHandler(event : Event) : Void
    {
        var rb : RadioButton = cast(event.target, RadioButton);
        if (rb != null) 
        {
            rb.removeEventListener(Event.ADDED, radioButton_addedHandler);
            addInstance(rb);
        }
    }
    /**
	* 单选按钮从显示列表移除
	*/
    private function radioButton_removedHandler(event : Event) : Void
    {
        var rb : RadioButton = cast(event.target, RadioButton);
        if (rb != null) 
        {
            rb.removeEventListener(Event.REMOVED, radioButton_removedHandler);
            doRemoveInstance(rb);
        }
    }
}


