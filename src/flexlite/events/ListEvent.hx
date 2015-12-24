package flexlite.events;


import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;

import flexlite.components.IItemRenderer;

/**
* 列表事件
* @author weilichuang
*/
class ListEvent extends MouseEvent
{
    /**
	* 指示用户执行了将鼠标指针从控件中某个项呈示器上移开的操作 
	*/
    public static inline var ITEM_ROLL_OUT : String = "itemRollOut";
    
    /**
	* 指示用户执行了将鼠标指针滑过控件中某个项呈示器的操作。 
	*/
    public static inline var ITEM_ROLL_OVER : String = "itemRollOver";
    
    /**
	* 指示用户执行了将鼠标在某个项呈示器上单击的操作。 
	*/
    public static inline var ITEM_CLICK : String = "itemClick";
    
    
    public function new(type : String, bubbles : Bool = false,
            cancelable : Bool = false,
            localX : Float = null,
            localY : Float = null,
            relatedObject : InteractiveObject = null,
            ctrlKey : Bool = false,
            altKey : Bool = false,
            shiftKey : Bool = false,
            buttonDown : Bool = false,
            delta : Int = 0,
            itemIndex : Int = -1,
            item : Dynamic = null,
            itemRenderer : IItemRenderer = null)
    {
		if (localX == null)
			localX = Math.NaN;
		if (localY == null)
			localY = Math.NaN;
        super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        
        this.itemIndex = itemIndex;
        this.item = item;
        this.itemRenderer = itemRenderer;
    }
    
    
    /**
	* 触发鼠标事件的项呈示器数据源项。
	*/
    public var item : Dynamic;
    
    /**
	* 触发鼠标事件的项呈示器。 
	*/
    public var itemRenderer : IItemRenderer;
    
    /**
	* 触发鼠标事件的项索引
	*/
    public var itemIndex : Int;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        var cloneEvent : ListEvent = new ListEvent(type, bubbles, cancelable, 
        localX, localY, relatedObject, 
        ctrlKey, altKey, shiftKey, buttonDown, delta, 
        itemIndex, item, itemRenderer);
        
        cloneEvent.relatedObject = this.relatedObject;
        
        return cloneEvent;
    }
}
