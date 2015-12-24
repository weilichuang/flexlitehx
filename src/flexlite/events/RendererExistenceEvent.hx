package flexlite.events;


import flash.events.Event;

import flexlite.components.IItemRenderer;

/**
* 在DataGroup添加或删除项呈示器时分派的事件。
* @author weilichuang
*/
class RendererExistenceEvent extends Event
{
    /**
	* 添加了项呈示器 
	*/
    public static inline var RENDERER_ADD : String = "rendererAdd";
    /**
	* 移除了项呈示器 
	*/
    public static inline var RENDERER_REMOVE : String = "rendererRemove";
    
    public function new(type : String, bubbles : Bool = false,
            cancelable : Bool = false, renderer : IItemRenderer = null,
            index : Int = -1, data : Dynamic = null)
    {
        super(type, bubbles, cancelable);
        
        this.renderer = renderer;
        this.index = index;
        this.data = data;
    }
    
    /**
	* 呈示器的数据项目。 
	*/
    public var data : Dynamic;
    
    /**
	* 指向已添加或删除项呈示器的位置的索引。 
	*/
    public var index : Int;
    
    /**
	* 对已添加或删除的项呈示器的引用。 
	*/
    public var renderer : IItemRenderer;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new RendererExistenceEvent(type, bubbles, cancelable, 
        renderer, index, data);
    }
}
