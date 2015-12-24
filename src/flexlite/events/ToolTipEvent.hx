package flexlite.events;


import flash.events.Event;

import flexlite.core.IToolTip;

/**
* 工具提示事件
* @author weilichuang
*/
class ToolTipEvent extends Event
{
    /**
	* 即将隐藏ToolTip
	*/
    public static inline var TOOL_TIP_HIDE : String = "toolTipHide";
    /**
	* 即将显示TooTip
	*/
    public static inline var TOOL_TIP_SHOW : String = "toolTipShow";
    
    /**
	* 构造函数
	*/
    public function new(type : String, bubbles : Bool = false,
            cancelable : Bool = false,
            toolTip : IToolTip = null)
    {
        super(type, bubbles, cancelable);
        
        this.toolTip = toolTip;
    }
    /**
	* 关联的ToolTip显示对象
	*/
    public var toolTip : IToolTip;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new ToolTipEvent(type, bubbles, cancelable, toolTip);
    }
}


