package flexlite.managers;

import flexlite.managers.IToolTipManagerClient;

import flash.display.DisplayObject;

import flexlite.core.IToolTip;

/**
* 工具提示管理器接口。若项目需要自定义工具提示管理器，请实现此接口，
* 并在项目初始化前调用Injector.mapClass(IToolTipManager,YourToolTipManager)，
* 注入自定义的工具提示管理器类。
* @author weilichuang
*/
interface IToolTipManager
{
    
    
    /**
	* 当前的IToolTipManagerClient组件
	*/
    var currentTarget(get, set) : IToolTipManagerClient;    
    
    
    /**
	* 当前可见的ToolTip显示对象；如果未显示ToolTip，则为 null。
	*/
    var currentToolTip(get, set) : IToolTip;    
    
    
    /**
	* 如果为 true，则当用户将鼠标指针移至组件上方时，ToolTipManager会自动显示工具提示。
	* 如果为 false，则不会显示任何工具提示。
	*/
    var enabled(get, set) : Bool;    
    
    
    /**
	* 自工具提示出现时起，ToolTipManager要隐藏此提示前所需等待的时间量（以毫秒为单位）。默认值：10000。
	*/
    var hideDelay(get, set) : Float;    
    
    
    
    /**
	* 当第一个ToolTip显示完毕后，若在此时间间隔内快速移动到下一个组件上，
	* 就直接显示ToolTip而不延迟showDelay。默认值：100。
	*/
    var scrubDelay(get, set) : Float;    
    
    
    /**
	* 当用户将鼠标移至具有工具提示的组件上方时，等待 ToolTip框出现所需的时间（以毫秒为单位）。
	* 若要立即显示ToolTip框，请将toolTipShowDelay设为0。默认值：200。
	*/
    var showDelay(get, set) : Float;    
    
    
    /**
	* 全局默认的创建工具提示要用到的类。
	*/
    var toolTipClass(get, set) : Class<IToolTip>;

    
    /**
	* 注册需要显示ToolTip的组件
	* @param target 目标组件
	* @param oldToolTip 之前的ToolTip数据
	* @param newToolTip 现在的ToolTip数据
	*/
    function registerToolTip(target : DisplayObject,
            oldToolTip : Dynamic,
            newToolTip : Dynamic) : Void;
    
    /**
	* 使用指定的ToolTip数据,创建默认的ToolTip类的实例，然后在舞台坐标中的指定位置显示此实例。
	* 保存此方法返回的对 ToolTip 的引用，以便将其传递给destroyToolTip()方法销毁实例。
	* @param toolTipData ToolTip数据
	* @param x 舞台坐标x
	* @param y 舞台坐标y
	* @return 创建的ToolTip实例引用
	*/
    function createToolTip(toolTipData : String, x : Float, y : Float) : IToolTip;
    
    /**
	* 销毁由createToolTip()方法创建的ToolTip实例。 
	* @param toolTip 要销毁的ToolTip实例
	*/
    function destroyToolTip(toolTip : IToolTip) : Void;
}
