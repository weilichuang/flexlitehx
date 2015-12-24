package flexlite.components.supportclasses;



import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.Lib;
import flexlite.collections.ICollection;
import flexlite.components.IItemRenderer;
import flexlite.components.SkinnableDataContainer;
import flexlite.core.IVisualElement;
import flexlite.events.CollectionEvent;
import flexlite.events.CollectionEventKind;
import flexlite.events.IndexChangeEvent;
import flexlite.events.ListEvent;
import flexlite.events.RendererExistenceEvent;
import flexlite.events.UIEvent;
import flexlite.layouts.supportclasses.LayoutBase;



/**
* 指示用户执行了将鼠标指针滑过控件中某个项呈示器的操作。 
*/
@:meta(Event(name="itemRollOver",type="flexlite.events.ListEvent"))

/**
* 指示用户执行了将鼠标指针从控件中某个项呈示器上移开的操作  
*/
@:meta(Event(name="itemRollOut",type="flexlite.events.ListEvent"))

/**
* 指示用户执行了将鼠标在某个项呈示器上单击的操作。 
*/
@:meta(Event(name="itemClick",type="flexlite.events.ListEvent"))

/**
* 指示索引即将更改,可以通过调用preventDefault()方法阻止索引发生更改
*/
@:meta(Event(name="changing",type="flexlite.events.IndexChangeEvent"))

/**
* 选中项改变事件。仅当用户与此控件交互时才抛出此事件。 
* 以编程方式更改 selectedIndex 或 selectedItem 属性的值时，该控件并不抛出change事件，而是抛出valueCommit事件。
*/
@:meta(Event(name="change",type="flexlite.events.IndexChangeEvent"))

/**
* 属性改变事件
*/
@:meta(Event(name="valueCommit",type="flexlite.events.UIEvent"))


@:meta(DXML(show="false"))


/**
* 支持选择内容的所有组件的基类。 
* @author weilichuang
*/
class ListBase extends SkinnableDataContainer
{
    public var labelField(get, set) : String;
    public var labelFunction(get, set) : Dynamic->String;
    public var requireSelection(get, set) : Bool;
    public var selectedIndex(get, set) : Int;
    public var selectedItem(get, set) : Dynamic;
    public var useVirtualLayout(get, set) : Bool;

    /**
	* 未选中任何项时的索引值 
	*/
    public static var NO_SELECTION : Int = -1;
    
    /**
	* 未设置缓存选中项的值
	*/
    private static var NO_PROPOSED_SELECTION : Int = -2;
    /**
	* 自定义的选中项
	*/
    private static var CUSTOM_SELECTED_ITEM : Int = -3;
    
    public function new()
    {
        super();
        focusEnabled = true;
    }
    
    /**
	* 正在进行所有数据源的刷新操作
	*/
    private var doingWholesaleChanges : Bool = false;
    
    private var dataProviderChanged : Bool;
    
    /**
	* @inheritDoc
	*/
    override private function set_dataProvider(value : ICollection) : ICollection
    {
        if (dataProvider != null) 
            dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
                dataProvider_collectionChangeHandler);
        
        dataProviderChanged = true;
        doingWholesaleChanges = true;
        
        if (value != null) 
            value.addEventListener(CollectionEvent.COLLECTION_CHANGE,
                dataProvider_collectionChangeHandler, false, 0, true);
        
        super.dataProvider = value;
        invalidateProperties();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_layout(value : LayoutBase) : LayoutBase
    {
        if (value != null && useVirtualLayout) 
            value.useVirtualLayout = true;
        
        return super.layout = value;
    }
    
    
    private var _labelField : String = "label";
    
    private var labelFieldOrFunctionChanged : Bool;
    
    /**
	* 数据项如果是一个对象，此属性为数据项中用来显示标签文字的字段名称。
	* 若设置了labelFunction，则设置此属性无效。
	*/
    private function get_labelField() : String
    {
        return _labelField;
    }
    
    private function set_labelField(value : String) : String
    {
        if (value == _labelField) 
            return value;
        
        _labelField = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties();
        return value;
    }
    
    private var _labelFunction : Dynamic->String;
    
    /**
	* 用户提供的函数，在每个项目上运行以确定其标签。
	* 示例：function labelFunc(item:Object):String 。
	*/
    private function get_labelFunction() : Dynamic->String
    {
        return _labelFunction;
    }
    
    private function set_labelFunction(value : Dynamic->String) : Dynamic->String
    {
        if (value == _labelFunction) 
            return value;
        
        _labelFunction = value;
        labelFieldOrFunctionChanged = true;
        invalidateProperties();
        return value;
    }
    
    private var _requireSelection : Bool = false;
    
    private var requireSelectionChanged : Bool = false;
    
    /**
	* 如果为 true，则必须始终在控件中选中数据项目。<br/>
	* 如果该值为 true，则始终将 selectedIndex 属性设置为 0 和 (dataProvider.length - 1) 之间的一个值。 
	*/
    private function get_requireSelection() : Bool
    {
        return _requireSelection;
    }
    
    private function set_requireSelection(value : Bool) : Bool
    {
        if (value == _requireSelection) 
            return value;
        
        _requireSelection = value;
        
        if (value) 
        {
            requireSelectionChanged = true;
            invalidateProperties();
        }
        return value;
    }
    
    /**
	* 在属性提交前缓存真实的选中项的值
	*/
    private var _proposedSelectedIndex : Int = NO_PROPOSED_SELECTION;
    
    private var _selectedIndex : Int = NO_SELECTION;
    
    /**
	* 选中项目的基于 0 的索引。<br/>
	* 或者如果未选中项目，则为-1。设置 selectedIndex 属性会取消选择当前选定的项目并选择指定索引位置的数据项目。 <br/>
	* 当用户通过与控件交互来更改 selectedIndex 属性时，此控件将分派 change 和 changing 事件。<br/>
	* 当以编程方式更改 selectedIndex 属性的值时，此控件不分派 change 和 changing 事件。
	*/
    private function get_selectedIndex() : Int
    {
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION) 
            return _proposedSelectedIndex;
        
        return _selectedIndex;
    }
    
    private function set_selectedIndex(value : Int) : Int
    {
        setSelectedIndex(value, false);
        return value;
    }
    
    /**
	* 是否允许自定义的选中项
	*/
    private var allowCustomSelectedItem : Bool = false;
    /**
	* 索引改变后是否需要抛出事件 
	*/
    private var dispatchChangeAfterSelection : Bool = false;
    
    /**
	* 设置选中项
	*/
    private function setSelectedIndex(value : Int, dispatchChangeEvent : Bool = false) : Void
    {
        if (value == selectedIndex) 
        {
            return;
        }
        
        if (dispatchChangeEvent) 
            dispatchChangeAfterSelection = (dispatchChangeAfterSelection || dispatchChangeEvent);
        _proposedSelectedIndex = value;
        invalidateProperties();
    }
    
    
    /**
	*  在属性提交前缓存真实选中项的数据源
	*/
    private var _pendingSelectedItem : Dynamic;
    
    private var _selectedItem : Dynamic;
    
    /**
	* 当前已选中的项目。设置此属性会取消选中当前选定的项目并选择新指定的项目。<br/>
	* 当用户通过与控件交互来更改 selectedItem 属性时，此控件将分派 change 和 changing 事件。<br/>
	* 当以编程方式更改 selectedItem 属性的值时，此控件不分派 change 和 changing 事件。
	*/
    private function get_selectedItem() : Dynamic
    {
        if (_pendingSelectedItem != null) 
            return _pendingSelectedItem;
        
        if (allowCustomSelectedItem && selectedIndex == CUSTOM_SELECTED_ITEM) 
            return _selectedItem;
        
        if (selectedIndex == NO_SELECTION || dataProvider == null) 
            return null;
        
        return dataProvider.length > selectedIndex ? dataProvider.getItemAt(selectedIndex) : null;
    }
    
    private function set_selectedItem(value : Dynamic) : Dynamic
    {
        setSelectedItem(value, false);
        return value;
    }
    
    /**
	* 设置选中项数据源
	*/
    private function setSelectedItem(value : Dynamic, dispatchChangeEvent : Bool = false) : Void
    {
        if (selectedItem == value) 
            return;
        
        if (dispatchChangeEvent) 
            dispatchChangeAfterSelection = (dispatchChangeAfterSelection || dispatchChangeEvent);
        
        _pendingSelectedItem = value;
        invalidateProperties();
    }
    
    private var _useVirtualLayout : Bool = false;
    
    /**
	* 是否使用虚拟布局,默认flase
	*/
    private function get_useVirtualLayout() : Bool
    {
        return (layout != null) ? layout.useVirtualLayout : _useVirtualLayout;
    }
    
    private function set_useVirtualLayout(value : Bool) : Bool
    {
        if (value == useVirtualLayout) 
            return value;
        
        _useVirtualLayout = value;
        if (layout != null) 
            layout.useVirtualLayout = value;
        return value;
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (dataProviderChanged) 
        {
            dataProviderChanged = false;
            doingWholesaleChanges = false;
            
            if (selectedIndex >= 0 && dataProvider != null && selectedIndex < dataProvider.length) 
                itemSelected(selectedIndex, true)
            else if (requireSelection) 
                _proposedSelectedIndex = 0
            else 
				setSelectedIndex(-1, false);
        }
        
        if (requireSelectionChanged) 
        {
            requireSelectionChanged = false;
            
            if (requireSelection &&
                selectedIndex == NO_SELECTION &&
                dataProvider != null &&
                dataProvider.length > 0) 
            {
                _proposedSelectedIndex = 0;
            }
        }
        
        if (_pendingSelectedItem != null) 
        {
            if (dataProvider != null) 
                _proposedSelectedIndex = dataProvider.getItemIndex(_pendingSelectedItem)
            else 
				_proposedSelectedIndex = NO_SELECTION;
            
            
            if (allowCustomSelectedItem && _proposedSelectedIndex == -1) 
            {
                _proposedSelectedIndex = CUSTOM_SELECTED_ITEM;
                _selectedItem = _pendingSelectedItem;
            }
            
            _pendingSelectedItem = null;
        }
        
        var changedSelection : Bool = false;
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION) 
            changedSelection = commitSelection();
        
        if (selectedIndexAdjusted) 
        {
            selectedIndexAdjusted = false;
            if (!changedSelection) 
            {
                dispatchEvent(new UIEvent(UIEvent.VALUE_COMMIT));
            }
        }
        
        if (labelFieldOrFunctionChanged) 
        {
            if (dataGroup != null) 
            {
                var itemIndex : Int;
                
                if (layout != null && layout.useVirtualLayout) 
                {
					var indices:Array<Int> = dataGroup.getElementIndicesInView();
                    for (i in 0...indices.length)
                    {
                        updateRendererLabelProperty(indices[i]);
                    }
                }
                else 
                {
                    var n : Int = dataGroup.numElements;
                    for (itemIndex in 0...n)
					{
                        updateRendererLabelProperty(itemIndex);
                    }
                }
            }
            
            labelFieldOrFunctionChanged = false;
        }
    }
    
    /**
	*  更新项呈示器文字标签
	*/
    private function updateRendererLabelProperty(itemIndex : Int) : Void
    {
        var renderer : IItemRenderer = Lib.as(dataGroup.getElementAt(itemIndex), IItemRenderer);
        if (renderer != null) 
            renderer.label = itemToLabel(renderer.data);
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == dataGroup) 
        {
            if (_useVirtualLayout && dataGroup.layout != null) 
                dataGroup.layout.useVirtualLayout = true;
            
            dataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        
        if (instance == dataGroup) 
        {
            dataGroup.removeEventListener(
                    RendererExistenceEvent.RENDERER_ADD, dataGroup_rendererAddHandler);
            dataGroup.removeEventListener(
                    RendererExistenceEvent.RENDERER_REMOVE, dataGroup_rendererRemoveHandler);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function updateRenderer(renderer : IItemRenderer, itemIndex : Int, data : Dynamic) : IItemRenderer
    {
        itemSelected(itemIndex, isItemIndexSelected(itemIndex));
        return super.updateRenderer(renderer, itemIndex, data);
    }
    
    /**
	* @inheritDoc
	*/
    override public function itemToLabel(item : Dynamic) : String
    {
        if (_labelFunction != null) 
            return _labelFunction(item);
        
        if (Std.is(item, String)) 
            return cast item;
        
        if (Std.is(item, Xml)) 
        {
            try
            {
				item = cast(item, Xml).get(labelField);
            }           
			catch (e : String)
            {
                
            }
        }
        else if (Std.is(item, Dynamic)) 
        {
            try
            {
                if (Reflect.field(item, labelField) != null) 
                    item = Reflect.field(item, labelField);
            }          
			catch (e : String)
            {
                
            }
        }
        
        if (Std.is(item, String)) 
            return cast item;
        
        try
        {
            if (item != null) 
                return Std.string(item);
        }        
		catch (e : String)
        {
            
        }
        
        return " ";
    }
    
    /**
	* 选中或取消选中项目时调用。子类必须覆盖此方法才可设置选中项。 
	* @param index 已选中的项目索引。
	* @param selected true为选中，false取消选中
	*/
    private function itemSelected(index : Int, selected : Bool) : Void
    {
        if (dataGroup == null) 
            return;
        var renderer : IItemRenderer = Lib.as(dataGroup.getElementAt(index), IItemRenderer);
        if (renderer == null) 
            return;
        renderer.selected = selected;
    }
    
    /**
	* 返回指定索引是否等于当前选中索引
	*/
    private function isItemIndexSelected(index : Int) : Bool
    {
        return index == selectedIndex;
    }
    
    /**
	* 提交选中项属性，返回是否成功提交，false表示被取消
	*/
    private function commitSelection(dispatchChangedEvents : Bool = true) : Bool
    {
        var maxIndex : Int = (dataProvider != null) ? dataProvider.length - 1 : -1;
        var oldSelectedIndex : Int = _selectedIndex;
        var e : IndexChangeEvent;
        
        if (!allowCustomSelectedItem || _proposedSelectedIndex != CUSTOM_SELECTED_ITEM) 
        {
            if (_proposedSelectedIndex < NO_SELECTION) 
                _proposedSelectedIndex = NO_SELECTION;
            if (_proposedSelectedIndex > maxIndex) 
                _proposedSelectedIndex = maxIndex;
            if (requireSelection && _proposedSelectedIndex == NO_SELECTION &&
                dataProvider != null && dataProvider.length > 0) 
            {
                _proposedSelectedIndex = NO_PROPOSED_SELECTION;
                dispatchChangeAfterSelection = false;
                return false;
            }
        }
        
        var tmpProposedIndex : Int = _proposedSelectedIndex;
        
        if (dispatchChangeAfterSelection) 
        {
            e = new IndexChangeEvent(IndexChangeEvent.CHANGING, false, true);
            e.oldIndex = _selectedIndex;
            e.newIndex = _proposedSelectedIndex;
            if (!dispatchEvent(e)) 
            {
                itemSelected(_proposedSelectedIndex, false);
                _proposedSelectedIndex = NO_PROPOSED_SELECTION;
                dispatchChangeAfterSelection = false;
                return false;
            }
        }
        
        _selectedIndex = tmpProposedIndex;
        _proposedSelectedIndex = NO_PROPOSED_SELECTION;
        
        if (oldSelectedIndex != NO_SELECTION) 
            itemSelected(oldSelectedIndex, false);
        if (_selectedIndex != NO_SELECTION) 
            itemSelected(_selectedIndex, true) ; 
			
		//子类若需要自身抛出Change事件，而不是在此处抛出，可以设置dispatchChangedEvents为false  ;
        if (dispatchChangedEvents) 
        {
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
        
        return true;
    }
    
    private var selectedIndexAdjusted : Bool = false;
    /**
	* 仅调整选中索引值而不更新选中项,即在提交属性阶段itemSelected方法不会被调用，也不会触发changing和change事件。
	* @param newIndex 新索引。
	* @param add 如果已将项目添加到组件，则为 true；如果已删除项目，则为 false。
	*/
    private function adjustSelection(newIndex : Int, add : Bool = false) : Void
    {
        if (_proposedSelectedIndex != NO_PROPOSED_SELECTION) 
            _proposedSelectedIndex = newIndex
        else 
			_selectedIndex = newIndex;
        selectedIndexAdjusted = true;
        invalidateProperties();
    }
    
    /**
	* 数据项添加
	*/
    private function itemAdded(index : Int) : Void
    {
        if (doingWholesaleChanges) 
            return;
        
        if (selectedIndex == NO_SELECTION) 
        {
            if (requireSelection) 
                adjustSelection(index, true);
        }
        else if (index <= selectedIndex) 
        {
            adjustSelection(selectedIndex + 1, true);
        }
    }
    
    /**
	* 数据项移除
	*/
    private function itemRemoved(index : Int) : Void
    {
        if (selectedIndex == NO_SELECTION || doingWholesaleChanges) 
            return;
        
        if (index == selectedIndex) 
        {
            if (requireSelection && dataProvider != null && dataProvider.length > 0) 
            {
                if (index == 0) 
                {
                    _proposedSelectedIndex = 0;
                    invalidateProperties();
                }
                else 
					setSelectedIndex(0, false);
            }
            else 
				adjustSelection(-1, false);
        }
        else if (index < selectedIndex) 
        {
            adjustSelection(selectedIndex - 1, false);
        }
    }
    
    
    /**
	* 项呈示器被添加
	*/
    private function dataGroup_rendererAddHandler(event : RendererExistenceEvent) : Void
    {
        var renderer : DisplayObject = cast(event.renderer, DisplayObject);
        
        if (renderer == null) 
            return;
        
        renderer.addEventListener(MouseEvent.ROLL_OVER, item_mouseEventHandler);
        renderer.addEventListener(MouseEvent.ROLL_OUT, item_mouseEventHandler);
    }
    /**
	* 项呈示器被移除
	*/
    private function dataGroup_rendererRemoveHandler(event : RendererExistenceEvent) : Void
    {
        var renderer : DisplayObject = cast(event.renderer, DisplayObject);
        
        if (renderer == null) 
            return;
        
        renderer.removeEventListener(MouseEvent.ROLL_OVER, item_mouseEventHandler);
        renderer.removeEventListener(MouseEvent.ROLL_OUT, item_mouseEventHandler);
    }
    
    /**
	* 项呈示器鼠标事件
	*/
    private function item_mouseEventHandler(event : MouseEvent) : Void
    {
        var type : String = event.type == MouseEvent.ROLL_OVER ? ListEvent.ITEM_ROLL_OVER : ListEvent.ITEM_ROLL_OUT;
        if (hasEventListener(type)) 
        {
            var itemRenderer : IItemRenderer = Lib.as(event.currentTarget, IItemRenderer);
            dispatchListEvent(event, type, itemRenderer);
        }
    }
    /**
	* 抛出列表事件
	* @param mouseEvent 相关联的鼠标事件
	* @param type 事件名称
	* @param itemRenderer 关联的条目渲染器实例
	*/
    private function dispatchListEvent(mouseEvent : MouseEvent, type : String, itemRenderer : IItemRenderer) : Void
    {
        var itemIndex : Int = -1;
        if (itemRenderer != null) 
            itemIndex = itemRenderer.itemIndex;
        else 
			itemIndex = dataGroup.getElementIndex(Lib.as(mouseEvent.currentTarget, IVisualElement));
        
        var listEvent : ListEvent = new ListEvent(type, false, false, 
													mouseEvent.localX, 
													mouseEvent.localY, 
													mouseEvent.relatedObject, 
													mouseEvent.ctrlKey, 
													mouseEvent.altKey, 
													mouseEvent.shiftKey, 
													mouseEvent.buttonDown, 
													mouseEvent.delta, 
													itemIndex, 
													dataProvider.getItemAt(itemIndex), 
													itemRenderer);
        dispatchEvent(listEvent);
    }
    
    /**
	* 数据源发生改变
	*/
    private function dataProvider_collectionChangeHandler(event : CollectionEvent) : Void
    {
        var items : Array<Dynamic> = event.items;
        if (event.kind == CollectionEventKind.ADD) 
        {
            var length : Int = items.length;
            for (i in 0...length)
			{
                itemAdded(event.location + i);
            }
        }
        else if (event.kind == CollectionEventKind.REMOVE) 
        {
            var length:Int = items.length;
            var i:Int = length - 1;
            while (i >= 0)
			{
                itemRemoved(event.location + i);
                i--;
            }
        }
        else if (event.kind == CollectionEventKind.MOVE) 
        {
            itemRemoved(event.oldLocation);
            itemAdded(event.location);
        }
        else if (event.kind == CollectionEventKind.RESET) 
        {
            if (dataProvider.length == 0) 
            {
                setSelectedIndex(NO_SELECTION, false);
            }
            else 
            {
                dataProviderChanged = true;
                invalidateProperties();
            }
        }
        else if (event.kind == CollectionEventKind.REFRESH) 
        {
            setSelectedIndex(NO_SELECTION, false);
        }
    }
}
