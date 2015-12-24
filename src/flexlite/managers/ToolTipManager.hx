package flexlite.managers;




import flash.display.DisplayObject;

import flexlite.core.Injector;

import flexlite.core.IToolTip;
import flexlite.managers.impl.ToolTipManagerImpl;




/**
* 工具提示管理器<p/>
* 若项目需要自定义工具提示管理器，请实现IToolTipManager接口，
* 并在项目初始化前调用Injector.mapClass(IToolTipManager,YourToolTipManager)，
* 注入自定义的工具提示管理器类。
* @author weilichuang
*/
class ToolTipManager
{
    private static var impl(get, never) : IToolTipManager;
    public static var currentTarget(get, set) : IToolTipManagerClient;
    public static var currentToolTip(get, set) : IToolTip;
    public static var enabled(get, set) : Bool;
    public static var hideDelay(get, set) : Float;
    public static var scrubDelay(get, set) : Float;
    public static var showDelay(get, set) : Float;
    public static var toolTipClass(get, set) : Class<IToolTip>;

    /**
	* 构造函数
	*/
    public function new()
    {

    }
    
    private static var _impl : IToolTipManager;
    
    /**
	* 获取单例
	*/
    private static function get_impl() : IToolTipManager
    {
        if (_impl == null) 
        {
            try
            {
                _impl = Injector.getInstance(IToolTipManager);
            }            
			catch (e : String)
            {
                _impl = new ToolTipManagerImpl();
            }
        }
        return _impl;
    }
    
    /**
	* 当前的IToolTipManagerClient组件
	*/
    private static function get_currentTarget() : IToolTipManagerClient
    {
        return impl.currentTarget;
    }
    
    private static function set_currentTarget(value : IToolTipManagerClient) : IToolTipManagerClient
    {
        impl.currentTarget = value;
        return value;
    }
    
    /**
	* 当前可见的ToolTip显示对象；如果未显示ToolTip，则为 null。
	*/
    private static function get_currentToolTip() : IToolTip
    {
        return impl.currentToolTip;
    }
    
    private static function set_currentToolTip(value : IToolTip) : IToolTip
    {
        impl.currentToolTip = value;
        return value;
    }
    
    /**
	* 如果为 true，则当用户将鼠标指针移至组件上方时，ToolTipManager会自动显示工具提示。
	* 如果为 false，则不会显示任何工具提示。
	*/
    private static function get_enabled() : Bool
    {
        return impl.enabled;
    }
    
    private static function set_enabled(value : Bool) : Bool
    {
        impl.enabled = value;
        return value;
    }
    
    /**
	* 自工具提示出现时起，ToolTipManager要隐藏此提示前所需等待的时间量（以毫秒为单位）。默认值：10000。
	*/
    private static function get_hideDelay() : Float
    {
        return impl.hideDelay;
    }
    
    private static function set_hideDelay(value : Float) : Float
    {
        impl.hideDelay = value;
        return value;
    }
    
    /**
	* 当第一个ToolTip显示完毕后，若在此时间间隔内快速移动到下一个组件上，
	* 就直接显示ToolTip而不延迟showDelay。默认值：100。
	*/
    private static function get_scrubDelay() : Float
    {
        return impl.scrubDelay;
    }
    
    private static function set_scrubDelay(value : Float) : Float
    {
        impl.scrubDelay = value;
        return value;
    }
    
    /**
	* 当用户将鼠标移至具有工具提示的组件上方时，等待 ToolTip框出现所需的时间（以毫秒为单位）。
	* 若要立即显示ToolTip框，请将toolTipShowDelay设为0。默认值：200。
	*/
    private static function get_showDelay() : Float
    {
        return impl.showDelay;
    }
    private static function set_showDelay(value : Float) : Float
    {
        impl.showDelay = value;
        return value;
    }
    
    /**
	* 全局默认的创建工具提示要用到的类。
	*/
    private static function get_toolTipClass() : Class<IToolTip>
    {
        return impl.toolTipClass;
    }
    
    private static function set_toolTipClass(value : Class<IToolTip>) : Class<IToolTip>
    {
        impl.toolTipClass = value;
        return value;
    }
    
    /**
	* 注册需要显示ToolTip的组件
	* @param target 目标组件
	* @param oldToolTip 之前的ToolTip数据
	* @param newToolTip 现在的ToolTip数据
	*/
    public static function registerToolTip(target : DisplayObject,
            oldToolTip : Dynamic,
            newToolTip : Dynamic) : Void
    {
        impl.registerToolTip(target, oldToolTip, newToolTip);
    }
    
    /**
	* 使用指定的ToolTip数据,创建默认的ToolTip类的实例，然后在舞台坐标中的指定位置显示此实例。
	* 保存此方法返回的对 ToolTip 的引用，以便将其传递给destroyToolTip()方法销毁实例。
	* @param toolTipData ToolTip数据
	* @param x 舞台坐标x
	* @param y 舞台坐标y
	* @return 创建的ToolTip实例引用
	*/
    public static function createToolTip(toolTipData : String, x : Float, y : Float) : IToolTip
    {
        return impl.createToolTip(toolTipData, x, y);
    }
    /**
	* 销毁由createToolTip()方法创建的ToolTip实例。 
	* @param toolTip 要销毁的ToolTip实例
	*/
    public static function destroyToolTip(toolTip : IToolTip) : Void
    {
        return impl.destroyToolTip(toolTip);
    }
}


