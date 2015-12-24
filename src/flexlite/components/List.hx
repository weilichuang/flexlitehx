package flexlite.components;


import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;


import flexlite.components.supportclasses.ItemRenderer;
import flexlite.components.supportclasses.ListBase;
import flexlite.core.FlexLiteGlobals;
import flexlite.core.IVisualElement;
import flexlite.events.IndexChangeEvent;
import flexlite.events.ListEvent;
import flexlite.events.RendererExistenceEvent;
import flexlite.events.UIEvent;



@:meta(DXML(show="true"))


/**
* 列表组件
* @author weilichuang
*/
class List extends ListBase
{
    public var allowMultipleSelection(get, set) : Bool;
    public var selectedIndices(get, set) : Array<Int>;
    public var selectedItems(get, set) : Array<Dynamic>;

    public function new()
    {
        super();
        useVirtualLayout = true;
    }
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        if (itemRenderer == null) 
            itemRenderer = ItemRenderer;
        super.createChildren();
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return List;
    }
    
    /**
	* 是否使用虚拟布局,默认true
	*/
    override private function get_useVirtualLayout() : Bool
    {
        return super.useVirtualLayout;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_useVirtualLayout(value : Bool) : Bool
    {
        super.useVirtualLayout = value;
        return value;
    }
    
    
    private var _allowMultipleSelection : Bool = false;
    /**
	* 是否允许同时选中多项
	*/
    private function get_allowMultipleSelection() : Bool
    {
        return _allowMultipleSelection;
    }
    
    private function set_allowMultipleSelection(value : Bool) : Bool
    {
        _allowMultipleSelection = value;
        return value;
    }
    
    private var _selectedIndices : Array<Int> = new Array<Int>();
    
    private var _proposedSelectedIndices : Array<Int>;
    /**
	* 当前选中的一个或多个项目的索引列表
	*/
    private function get_selectedIndices() : Array<Int>
    {
        if (_proposedSelectedIndices != null) 
            return _proposedSelectedIndices;
        return _selectedIndices;
    }
    
    private function set_selectedIndices(value : Array<Int>) : Array<Int>
    {
        setSelectedIndices(value, false);
        return value;
    }
    /**
	* @inheritDoc
	*/
    override private function get_selectedIndex() : Int
    {
        if (_proposedSelectedIndices != null) 
        {
            if (_proposedSelectedIndices.length > 0) 
                return _proposedSelectedIndices[0];
            return -1;
        }
        return super.selectedIndex;
    }
    
    /**
	* 当前选中的一个或多个项目的数据源列表
	*/
    private function get_selectedItems() : Array<Dynamic>
    {
        var result : Array<Dynamic> = new Array<Dynamic>();
        var list : Array<Int> = selectedIndices;
        if (list != null) 
        {
            var count : Int = list.length;
            
            for (i in 0...count){result[i] = dataProvider.getItemAt(list[i]);
            }
        }
        
        return result;
    }
    
    private function set_selectedItems(value : Array<Dynamic>) : Array<Dynamic>
    {
        var indices : Array<Int> = new Array<Int>();
        
        if (value != null) 
        {
            var count : Int = value.length;
            
            for (i in 0...count)
			{
                var index : Int = dataProvider.getItemIndex(value[i]);
                if (index != -1) 
                {
                    indices.insert(0, index);
                }
                if (index == -1) 
                {
                    indices = new Array<Int>();
                    break;
                }
            }
        }
        setSelectedIndices(indices, false);
        return value;
    }
    /**
	* 设置多个选中项
	*/
    private function setSelectedIndices(value : Array<Int>, dispatchChangeEvent : Bool = false) : Void
    {
        if (dispatchChangeEvent) 
            dispatchChangeAfterSelection = (dispatchChangeAfterSelection || dispatchChangeEvent);
        
        if (value != null) 
            _proposedSelectedIndices = value
        else 
			_proposedSelectedIndices = new Array<Int>();
        invalidateProperties();
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (_proposedSelectedIndices != null) 
        {
            commitSelection();
        }
    }
    /**
	* @inheritDoc
	*/
    override private function commitSelection(dispatchChangedEvents : Bool = true) : Bool
    {
        var oldSelectedIndex : Int = _selectedIndex;
        if (_proposedSelectedIndices != null) 
        {
            _proposedSelectedIndices = _proposedSelectedIndices.filter(isValidIndex);
            
            if (!allowMultipleSelection && _proposedSelectedIndices.length > 0) 
            {
                var temp : Array<Int> = new Array<Int>();
                temp.push(_proposedSelectedIndices[0]);
                _proposedSelectedIndices = temp;
            }
            if (_proposedSelectedIndices.length > 0) 
            {
                _proposedSelectedIndex = _proposedSelectedIndices[0];
            }
            else 
            {
                _proposedSelectedIndex = -1;
            }
        }
        
        var retVal : Bool = super.commitSelection(false);
        
        if (!retVal) 
        {
            _proposedSelectedIndices = null;
            return false;
        }
        
        if (selectedIndex > ListBase.NO_SELECTION) 
        {
            if (_proposedSelectedIndices != null) 
            {
                if (_proposedSelectedIndices.indexOf(selectedIndex) == -1) 
                    _proposedSelectedIndices.push(selectedIndex);
            }
            else 
            {
                _proposedSelectedIndices = [selectedIndex];
            }
        }
        
        if (_proposedSelectedIndices != null) 
        {
            if (_proposedSelectedIndices.indexOf(oldSelectedIndex) != -1) 
                itemSelected(oldSelectedIndex, true);
            commitMultipleSelection();
        }
        
        if (dispatchChangedEvents && retVal) 
        {
            var e : IndexChangeEvent;
            
            if (dispatchChangeAfterSelection) 
            {
                e = new IndexChangeEvent(IndexChangeEvent.CHANGE);
                e.oldIndex = oldSelectedIndex;
                e.newIndex = _selectedIndex;
                dispatchEvent(e);
                dispatchChangeAfterSelection = false;
            }
            
            dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
        }
        
        return retVal;
    }
    /**
	* 是否是有效的索引
	*/
    private function isValidIndex(item : Int) : Bool
    {
        return dataProvider != null && (item >= 0) && (item < dataProvider.length);
    }
    /**
	* 提交多项选中项属性
	*/
    private function commitMultipleSelection() : Void
    {
        var removedItems : Array<Int> = new Array<Int>();
        var addedItems : Array<Int> = new Array<Int>();
        var i : Int;
        var count : Int;
        
        if (_selectedIndices.length > 0 && _proposedSelectedIndices.length > 0) 
        {
            count = _proposedSelectedIndices.length;
            for (i in 0...count){
                if (_selectedIndices.indexOf(_proposedSelectedIndices[i]) == -1) 
                    addedItems.push(_proposedSelectedIndices[i]);
            }
            count = _selectedIndices.length;
            for (i in 0...count){
                if (_proposedSelectedIndices.indexOf(_selectedIndices[i]) == -1) 
                    removedItems.push(_selectedIndices[i]);
            }
        }
        else if (_selectedIndices.length > 0) 
        {
            removedItems = _selectedIndices;
        }
        else if (_proposedSelectedIndices.length > 0) 
        {
            addedItems = _proposedSelectedIndices;
        }
        
        _selectedIndices = _proposedSelectedIndices;
        
        if (removedItems.length > 0) 
        {
            count = removedItems.length;
            for (i in 0...count){
                itemSelected(removedItems[i], false);
            }
        }
        
        if (addedItems.length > 0) 
        {
            count = addedItems.length;
            for (i in 0...count){
                itemSelected(addedItems[i], true);
            }
        }
        
        _proposedSelectedIndices = null;
    }
    
    /**
	* @inheritDoc
	*/
    override private function isItemIndexSelected(index : Int) : Bool
    {
        if (_allowMultipleSelection) 
            return _selectedIndices.indexOf(index) != -1;
        
        return super.isItemIndexSelected(index);
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataGroup_rendererAddHandler(event : RendererExistenceEvent) : Void
    {
        super.dataGroup_rendererAddHandler(event);
        
        var renderer : DisplayObject = cast(event.renderer, DisplayObject);
        if (renderer == null) 
            return;
        
        renderer.addEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
        //由于ItemRenderer.mouseChildren有可能不为false，在鼠标按下时会出现切换素材的情况，
        //导致target变化而无法抛出原生的click事件,所以此处监听MouseUp来抛出ItemClick事件。
        renderer.addEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataGroup_rendererRemoveHandler(event : RendererExistenceEvent) : Void
    {
        super.dataGroup_rendererRemoveHandler(event);
        
        var renderer : DisplayObject = cast(event.renderer, DisplayObject);
        if (renderer == null) 
            return;
        
        renderer.removeEventListener(MouseEvent.MOUSE_DOWN, item_mouseDownHandler);
        renderer.removeEventListener(MouseEvent.MOUSE_UP, item_mouseUpHandler);
    }
    /**
	* @inheritDoc
	*/
    override private function itemAdded(index : Int) : Void
    {
        adjustSelection(index, true);
    }
    /**
	* @inheritDoc
	*/
    override private function itemRemoved(index : Int) : Void
    {
        adjustSelection(index, false);
    }
    /**
	* @inheritDoc
	*/
    override private function adjustSelection(index : Int, add : Bool = false) : Void
    {
        var i : Int;
        var curr : Int;
        var newInterval : Array<Int> = new Array<Int>();
        var e : IndexChangeEvent;
        
        if (selectedIndex == ListBase.NO_SELECTION || doingWholesaleChanges) 
        {
            if (dataProvider != null && dataProvider.length == 1 && requireSelection) 
            {
                newInterval.push(0);
                _selectedIndices = newInterval;
                _selectedIndex = 0;
                
                dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
            }
            return;
        }
        
        if ((selectedIndices == null && selectedIndex > ListBase.NO_SELECTION) ||
            (selectedIndex > ListBase.NO_SELECTION && selectedIndices.indexOf(selectedIndex) == -1)) 
        {
            commitSelection();
        }
        
        if (add) 
        {
            for (i in 0...selectedIndices.length)
			{
                curr = selectedIndices[i];
                
                if (curr >= index) 
                    newInterval.push(curr + 1);
                else 
                newInterval.push(curr);
            }
        }
        else 
        {
            if ((selectedIndices == null || selectedIndices.length == 0)
                && selectedIndices.length == 1
                && index == selectedIndex
                && requireSelection) 
            {
                if (dataProvider.length == 0) 
                {
                    newInterval = new Array<Int>();
                }
                else 
                {
                    _proposedSelectedIndex = 0;
                    invalidateProperties();
                    
                    if (index == 0) 
                        return;
                    
                    newInterval.push(0);
                }
            }
            else 
            {
                for (i in 0...selectedIndices.length){
                    curr = selectedIndices[i];
                    if (curr > index) 
                        newInterval.push(curr - 1)
                    else if (curr < index) 
                        newInterval.push(curr);
                }
            }
        }
        
        var oldIndices : Array<Int> = selectedIndices;
        _selectedIndices = newInterval;
        _selectedIndex = getFirstItemValue(newInterval);
        if (_selectedIndices != oldIndices) 
        {
            selectedIndexAdjusted = true;
            invalidateProperties();
        }
    }
    
    private function getFirstItemValue(v : Array<Int>) : Int
    {
        if (v != null && v.length > 0) 
            return v[0]
        else 
        return -1;
    }
    /**
	* 是否捕获ItemRenderer以便在MouseUp时抛出ItemClick事件
	*/
    private var captureItemRenderer : Bool = true;
    
    private var mouseDownItemRenderer : IItemRenderer;
    /**
	* 鼠标在项呈示器上按下
	*/
    private function item_mouseDownHandler(event : MouseEvent) : Void
    {
        if (event.isDefaultPrevented()) 
            return;
        
        var itemRenderer : IItemRenderer = Lib.as(event.currentTarget, IItemRenderer);
        var newIndex : Int;
        if (itemRenderer != null) 
            newIndex = itemRenderer.itemIndex
        else 
			newIndex = dataGroup.getElementIndex(Lib.as(event.currentTarget, IVisualElement));
        if (_allowMultipleSelection) 
        {
            setSelectedIndices(calculateSelectedIndices(newIndex, event.shiftKey, event.ctrlKey), true);
        }
        else 
        {
            setSelectedIndex(newIndex, true);
        }
        if (!captureItemRenderer) 
            return;
        mouseDownItemRenderer = itemRenderer;
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
        FlexLiteGlobals.stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler, false, 0, true);
    }
    /**
	* 计算当前的选中项列表
	*/
    private function calculateSelectedIndices(index : Int, shiftKey : Bool, ctrlKey : Bool) : Array<Int>
    {
        var i : Int;
        var interval : Array<Int> = new Array<Int>();
        if (!shiftKey) 
        {
            if (ctrlKey) 
            {
                if (_selectedIndices.length > 0) 
                {
                    if (_selectedIndices.length == 1 && (_selectedIndices[0] == index)) 
                    {
                        if (!requireSelection) 
                            return interval;
                        
                        interval.insert(0, _selectedIndices[0]);
                        return interval;
                    }
                    else 
                    {
                        var found : Bool = false;
                        for (i in 0..._selectedIndices.length){
                            if (_selectedIndices[i] == index) 
                                found = true
                            else if (_selectedIndices[i] != index) 
                                interval.insert(0, _selectedIndices[i]);
                        }
                        if (!found) 
                        {
                            interval.insert(0, index);
                        }
                        return interval;
                    }
                }
                else 
                {
                    interval.insert(0, index);
                    return interval;
                }
            }
            else 
            {
                interval.insert(0, index);
                return interval;
            }
        }
        else 
        {
            var start : Int = _selectedIndices.length > (0) ? _selectedIndices[_selectedIndices.length - 1] : 0;
            var end : Int = index;
            if (start < end) 
            {
                for (i in start...end + 1)
				{
                    interval.insert( 0, i);
                }
            }
            else 
            {
                i = start;
                while (i >= end)
				{
                    interval.insert( 0, i);
                    i--;
                }
            }
            return interval;
        }
    }
    
    /**
	* 鼠标在项呈示器上弹起，抛出ItemClick事件。
	*/
    private function item_mouseUpHandler(event : MouseEvent) : Void
    {
        var itemRenderer : IItemRenderer = Lib.as(event.currentTarget, IItemRenderer);
        if (itemRenderer != mouseDownItemRenderer) 
            return;
        dispatchListEvent(event, ListEvent.ITEM_CLICK, itemRenderer);
    }
    
    /**
	* 鼠标在舞台上弹起
	*/
    private function stage_mouseUpHandler(event : Event) : Void
    {
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
        FlexLiteGlobals.stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
        mouseDownItemRenderer = null;
    }
}
