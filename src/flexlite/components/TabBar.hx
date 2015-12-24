package flexlite.components;

import flash.Lib;
import flexlite.components.TabBarButton;

import flash.events.Event;
import flash.events.MouseEvent;


import flexlite.collections.ICollection;
import flexlite.components.supportclasses.ListBase;
import flexlite.core.IVisualElement;
import flexlite.events.IndexChangeEvent;
import flexlite.events.ListEvent;
import flexlite.events.RendererExistenceEvent;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.HorizontalLayout;
import flexlite.layouts.VerticalAlign;



@:meta(DXML(show="true"))


/**
* 选项卡组件
* @author weilichuang
*/
class TabBar extends ListBase
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        
        tabChildren = false;
        tabEnabled = true;
        requireSelection = true;
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return TabBar;
    }
    /**
	* requireSelection改变标志
	*/
    //private var requireSelectionChanged : Bool;
    
    /**
	* @inheritDoc
	*/
    override private function set_requireSelection(value : Bool) : Bool
    {
        if (value == requireSelection) 
            return value;
        
        super.requireSelection = value;
        requireSelectionChanged = true;
        invalidateProperties();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_dataProvider(value : ICollection) : ICollection
    {
        if (Std.is(dataProvider, ViewStack)) 
        {
            dataProvider.removeEventListener("IndexChanged", onViewStackIndexChange);
            removeEventListener(IndexChangeEvent.CHANGE, onIndexChanged);
        }
        
        if (Std.is(value, ViewStack)) 
        {
            value.addEventListener("IndexChanged", onViewStackIndexChange);
            addEventListener(IndexChangeEvent.CHANGE, onIndexChanged);
        }
        super.dataProvider = value;
        return value;
    }
    /**
	* 鼠标点击的选中项改变
	*/
    private function onIndexChanged(event : IndexChangeEvent) : Void
    {
        cast(dataProvider, ViewStack).setSelectedIndex(event.newIndex, false);
    }
    
    /**
	* ViewStack选中项发生改变
	*/
    private function onViewStackIndexChange(event : Event) : Void
    {
        setSelectedIndex(cast(dataProvider, ViewStack).selectedIndex, false);
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (requireSelectionChanged && dataGroup != null) 
        {
            requireSelectionChanged = false;
            var n : Int = dataGroup.numElements;
            for (i in 0...n)
			{
                var renderer : TabBarButton = cast(dataGroup.getElementAt(i), TabBarButton);
                if (renderer != null) 
                    renderer.allowDeselection = !requireSelection;
            }
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataGroup_rendererAddHandler(event : RendererExistenceEvent) : Void
    {
        super.dataGroup_rendererAddHandler(event);
        
        var renderer : IItemRenderer = event.renderer;
        if (renderer != null) 
        {
            renderer.addEventListener(MouseEvent.CLICK, item_clickHandler);
            if (Std.is(renderer, TabBarButton)) 
                cast(renderer, TabBarButton).allowDeselection = !requireSelection;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataGroup_rendererRemoveHandler(event : RendererExistenceEvent) : Void
    {
        super.dataGroup_rendererRemoveHandler(event);
        
        var renderer : IItemRenderer = event.renderer;
        if (renderer != null) 
            renderer.removeEventListener(MouseEvent.CLICK, item_clickHandler);
    }
    /**
	* 鼠标在条目上按下
	*/
    private function item_clickHandler(event : MouseEvent) : Void
    {
        var itemRenderer : IItemRenderer = Lib.as(event.currentTarget, IItemRenderer);
        var newIndex : Int;
        if (itemRenderer != null) 
            newIndex = itemRenderer.itemIndex
        else 
			newIndex = dataGroup.getElementIndex(Lib.as(event.currentTarget, IVisualElement));
        
        if (newIndex == selectedIndex) 
        {
            if (!requireSelection) 
                setSelectedIndex(ListBase.NO_SELECTION, true);
        }
        else 
        setSelectedIndex(newIndex, true);
        dispatchListEvent(event, ListEvent.ITEM_CLICK, itemRenderer);
    }
    
    /**
	* @inheritDoc
	*/
    override private function createSkinParts() : Void
    {
        dataGroup = new DataGroup();
        dataGroup.percentHeight = dataGroup.percentWidth = 100;
        dataGroup.clipAndEnableScrolling = true;
        var layout : HorizontalLayout = new HorizontalLayout();
        layout.gap = -1;
        layout.horizontalAlign = HorizontalAlign.JUSTIFY;
        layout.verticalAlign = VerticalAlign.CONTENT_JUSTIFY;
        dataGroup.layout = layout;
        addToDisplayList(dataGroup);
        partAdded("dataGroup", dataGroup);
    }
}
