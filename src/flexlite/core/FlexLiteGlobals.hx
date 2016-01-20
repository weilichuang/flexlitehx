package flexlite.core;



import flash.display.Stage;
import flash.events.Event;

import flexlite.core.Injector;

import flexlite.managers.FocusManager;
import flexlite.managers.IFocusManager;
import flexlite.managers.ISystemManager;
import flexlite.managers.LayoutManager;



/**
* 全局静态量
* @author weilichuang
*/
class FlexLiteGlobals
{
    public static var stage(get, never) : Stage;
    public static var systemManager(get, never) : ISystemManager;

    /**
	* 一个全局标志，控制在某些鼠标操作或动画特效播放时，是否开启updateAfterEvent()，开启时能增加平滑的体验感,但是会提高屏幕渲染(Render事件)的频率。默认为true。
	*/
    public static var useUpdateAfterEvent : Bool = true;
    
    private static var _stage : Stage;
    /**
	* 舞台引用，当第一个UIComponent添加到舞台时此属性被自动赋值
	*/
    private static function get_stage() : Stage
    {
        return _stage;
    }
    /**
	* 已经初始化完成标志
	*/
    private static var initlized : Bool = false;
    /**
	* 初始化管理器
	*/
    public static function initlize(stage : Stage) : Void
    {
        if (initlized) 
            return;
        _stage = stage;
        layoutManager = new LayoutManager();
        try
        {
            focusManager = Injector.getInstance(IFocusManager);
        }        
		catch (e : String)
        {
            focusManager = new FocusManager();
        }
        focusManager.stage = stage;
        //屏蔽callLaterError
        stage.addEventListener("callLaterError", function(event : Event) : Void{});
        initlized = true;
    }
    /**
	* 延迟渲染布局管理器 
	*/
    public static var layoutManager : LayoutManager;
    /**
	* 焦点管理器
	*/
    public static var focusManager : IFocusManager;
    /**
	* 系统管理器列表
	*/
    public static var _systemManagers : Array<ISystemManager> = new Array<ISystemManager>();
    /**
	* 顶级应用容器
	*/
    private static function get_systemManager() : ISystemManager
    {
        var i : Int = _systemManagers.length - 1;
        while (i >= 0)
		{
            if (_systemManagers[i].getStage() != null) 
                return _systemManagers[i];
            i--;
        }
        return null;
    }
    /**
	* 是否屏蔽失效验证阶段和callLater方法延迟调用的所有报错。
	* 建议在发行版中启用，避免因为一处报错引起全局的延迟调用失效。
	*/
    public static var catchCallLaterExceptions : Bool = true;
}
