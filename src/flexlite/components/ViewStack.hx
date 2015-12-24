package flexlite.components;


import flash.display.DisplayObject;
import flash.events.Event;


import flexlite.collections.ICollection;
import flexlite.core.IViewStack;
import flexlite.core.IVisualElement;
import flexlite.events.CollectionEvent;
import flexlite.events.CollectionEventKind;
import flexlite.events.ElementExistenceEvent;
import flexlite.events.IndexChangeEvent;
import flexlite.events.UIEvent;
import flexlite.layouts.BasicLayout;
import flexlite.layouts.supportclasses.LayoutBase;



@:meta(DXML(show="true"))

/**
* 集合数据发生改变 
*/
@:meta(Event(name="collectionChange",type="flexlite.events.CollectionEvent"))

/**
* 属性提交事件,当修改选中项时会抛出这个事件。
*/
@:meta(Event(name="valueCommit",type="flexlite.events.UIEvent"))

/**
* 层级堆叠容器,一次只显示一个子对象。
* @author weilichuang
*/
class ViewStack extends Group implements IViewStack implements ICollection
{
    public var createAllChildren(get, set) : Bool;
    public var selectedChild(get, set) : IVisualElement;
    public var selectedIndex(get, set) : Int;
    public var length(get, never) : Int;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        super.layout = new BasicLayout();
    }
    
    /**
	* 此容器的布局对象为只读,默认限制为BasicLayout。
	*/
    override private function get_layout() : LayoutBase
    {
        return super.layout;
    }
    override private function set_layout(value : LayoutBase) : LayoutBase
    {
        return value;
    }
    
    private var _createAllChildren : Bool = false;
    /**
	* 是否立即初始化化所有子项。false表示当子项第一次被显示时再初始化它。默认值false。
	*/
    private function get_createAllChildren() : Bool
    {
        return _createAllChildren;
    }
    
    private function set_createAllChildren(value : Bool) : Bool
    {
        if (_createAllChildren == value) 
            return value;
        _createAllChildren = value;
		
        if (_createAllChildren) 
        {
            var elements : Array<IVisualElement> = getElementsContent();
            for (element in elements)
            {
                if (Std.is(element, DisplayObject) && element.parent != this) 
                {
                    childOrderingChanged = true;
                    addToDisplayList(cast element);
                }
            }
            if (childOrderingChanged) 
                invalidateProperties();
        }
        return value;
    }
    
    
    private var _selectedChild : IVisualElement;
    /**
	* @inheritDoc
	*/
    private function get_selectedChild() : IVisualElement
    {
        var index : Int = selectedIndex;
        if (index >= 0 && index < numElements) 
            return getElementAt(index);
        return null;
    }
    private function set_selectedChild(value : IVisualElement) : IVisualElement
    {
        var index : Int = getElementIndex(value);
        if (index >= 0 && index < numElements) 
            setSelectedIndex(index);
        return value;
    }
    /**
	* 未设置缓存选中项的值
	*/
    private static var NO_PROPOSED_SELECTION : Int = -2;
    
    /**
	* 在属性提交前缓存选中项索引
	*/
    private var proposedSelectedIndex : Int = NO_PROPOSED_SELECTION;
    
    private var _selectedIndex : Int = -1;
    /**
	* @inheritDoc
	*/
    private function get_selectedIndex() : Int
    {
        return proposedSelectedIndex != NO_PROPOSED_SELECTION ? proposedSelectedIndex : _selectedIndex;
    }
    private function set_selectedIndex(value : Int) : Int
    {
        setSelectedIndex(value);
        return value;
    }
    
    private var notifyTabBar : Bool = false;
    /**
	* 设置选中项索引
	*/
    public function setSelectedIndex(value : Int, notifyListeners : Bool = true) : Void
    {
        if (value == selectedIndex) 
        {
            return;
        }
        
        proposedSelectedIndex = value;
        invalidateProperties();
        
        dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
        notifyTabBar = notifyTabBar || notifyListeners;
    }
    
    /**
	* 添加一个显示元素到容器
	*/
    override private function elementAdded(element : IVisualElement, index : Int, notifyListeners : Bool = true) : Void
    {
        if (_createAllChildren) 
        {
            if (Std.is(element, DisplayObject)) 
                addToDisplayListAt(cast element, index);
        }
        if (notifyListeners) 
        {
            if (hasEventListener(ElementExistenceEvent.ELEMENT_ADD)) 
                dispatchEvent(new ElementExistenceEvent(
                    ElementExistenceEvent.ELEMENT_ADD, false, false, element, index));
        }
        
        element.visible = false;
        element.includeInLayout = false;
        if (selectedIndex == -1) 
        {
            setSelectedIndex(index, false);
        }
        else if (index <= selectedIndex && initialized) 
        {
            setSelectedIndex(selectedIndex + 1);
        }
        dispatchCoEvent(CollectionEventKind.ADD, index, -1, [element.name]);
    }
    
    
    /**
	* 从容器移除一个显示元素
	*/
    override private function elementRemoved(element : IVisualElement, index : Int, notifyListeners : Bool = true) : Void
    {
        super.elementRemoved(element, index, notifyListeners);
        element.visible = true;
        element.includeInLayout = true;
        if (index == selectedIndex) 
        {
            if (numElements > 0) 
            {
                if (index == 0) 
                {
                    proposedSelectedIndex = 0;
                    invalidateProperties();
                }
                else 
					setSelectedIndex(0, false);
            }
            else 
				setSelectedIndex(-1);
        }
        else if (index < selectedIndex) 
        {
            setSelectedIndex(selectedIndex - 1);
        }
        dispatchCoEvent(CollectionEventKind.REMOVE, index, -1, [element.name]);
    }
    
    /**
	* 子项显示列表顺序发生改变。
	*/
    private var childOrderingChanged : Bool = false;
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (proposedSelectedIndex != NO_PROPOSED_SELECTION) 
        {
            commitSelection(proposedSelectedIndex);
            proposedSelectedIndex = NO_PROPOSED_SELECTION;
        }
        
        if (childOrderingChanged) 
        {
            childOrderingChanged = false;
            var elements : Array<IVisualElement> = getElementsContent();
            for (element in elements)
            {
                if (Std.is(element, DisplayObject) && element.parent == this) 
                {
                    addToDisplayList(cast element);
                }
            }
        }
        
        if (notifyTabBar) 
        {
            notifyTabBar = true;
            dispatchEvent(new Event("IndexChanged"));
        }
    }
    
    private function commitSelection(newIndex : Int) : Void
    {
        var oldIndex : Int = _selectedIndex;
        if (newIndex >= 0 && newIndex < numElements) 
        {
            _selectedIndex = newIndex;
            if (_selectedChild != null && _selectedChild.parent == this) 
            {
                _selectedChild.visible = false;
                _selectedChild.includeInLayout = false;
            }
            _selectedChild = getElementAt(_selectedIndex);
            _selectedChild.visible = true;
            _selectedChild.includeInLayout = true;
            if (_selectedChild.parent != this && Std.is(_selectedChild, DisplayObject)) 
            {
                addToDisplayList(cast _selectedChild);
                if (!childOrderingChanged) 
                {
                    childOrderingChanged = true;
                }
            }
        }
        else 
        {
            _selectedChild = null;
            _selectedIndex = -1;
        }
        invalidateSize();
        invalidateDisplayList();
    }
    /**
	* @inheritDoc
	*/
    private function get_length() : Int
    {
        return numElements;
    }
    /**
	* @inheritDoc
	*/
    public function getItemAt(index : Int) : Dynamic
    {
        var element : IVisualElement = getElementAt(index);
        if (element != null) 
            return element.name;
        return "";
    }
    /**
	* @inheritDoc
	*/
    public function getItemIndex(item : Dynamic) : Int
    {
        var list : Array<IVisualElement> = getElementsContent();
        var length : Int = list.length;
        for (i in 0...length)
		{
            if (list[i].name == item) 
            {
                return i;
            }
        }
        return -1;
    }
    
    /**
	* 抛出事件
	*/
    private function dispatchCoEvent(kind : String = null, location : Int = -1,
            oldLocation : Int = -1, items : Array<Dynamic> = null, oldItems : Array<Dynamic> = null) : Void
    {
        var event : CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, 
        kind, location, oldLocation, items, oldItems);
        dispatchEvent(event);
    }
}
