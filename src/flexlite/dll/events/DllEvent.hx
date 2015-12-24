package flexlite.dll.events;


import flash.events.Event;

import flexlite.dll.core.DllItem;


/**
* 资源管理器事件
* @author weilichuang
*/
class DllEvent extends Event
{
    /**
	* 一个加载项加载结束事件，可能是加载成功也可能是加载失败。
	*/
    public static inline var ITEM_LOAD_FINISHED : String = "itemLoadFinished";
    /**
	* 配置文件加载并解析完成事件
	*/
    public static inline var CONFIG_COMPLETE : String = "configComplete";
    /**
	* 延迟加载组资源加载进度事件
	*/
    public static inline var GROUP_PROGRESS : String = "groupProgress";
    /**
	* 延迟加载组资源加载完成事件
	*/
    public static inline var GROUP_COMPLETE : String = "groupComplete";
    /**
	* 构造函数
	*/
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
    /**
	* 已经加载的字节数
	*/
    public var bytesLoaded : Float = 0;
    /**
	* 要加载的总字节数
	*/
    public var bytesTotal : Float = 0;
    /**
	* 资源组名
	*/
    public var groupName : String;
    /**
	* 一次加载项加载结束的项信息对象
	*/
    public var dllItem : DllItem;
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        var event : DllEvent = new DllEvent(type, bubbles, cancelable);
        event.bytesLoaded = bytesLoaded;
        event.bytesTotal = bytesTotal;
        event.dllItem = dllItem;
        event.groupName = groupName;
        return event;
    }
}
