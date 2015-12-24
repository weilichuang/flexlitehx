package flexlite.managers;


import flash.display.DisplayObjectContainer;
import flash.events.IEventDispatcher;

/**
* 使用布局管理器的组件接口
* @author weilichuang
*/
interface ILayoutManagerClient extends IEventDispatcher
{
    
    
    
    /**
	* 在显示列表的嵌套深度
	*/
    var nestLevel(get, set) : Int;    
    
    /**
	* 是否完成初始化。此标志只能由 LayoutManager 修改。
	*/
    var initialized(get, set) : Bool;    
    
    /**
	* 一个标志，用于确定某个对象是否正在等待分派其updateComplete事件。此标志只能由 LayoutManager 修改。
	*/
    var updateCompletePendingFlag(get, set) : Bool;    
    /**
	* 父级显示对象
	*/
    var parent(default, never) : DisplayObjectContainer;

    /**
	* 验证组件的属性
	*/
    function validateProperties() : Void;
    /**
	* 验证组件的尺寸
	*/
    function validateSize(recursive : Bool = false) : Void;
    /**
	* 验证子项的位置和大小，并绘制其他可视内容
	*/
    function validateDisplayList() : Void;
}
