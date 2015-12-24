package flexlite.managers;





import flexlite.core.Injector;

import flexlite.core.IVisualElement;
import flexlite.events.PopUpEvent;
import flexlite.managers.impl.PopUpManagerImpl;



/**
* 窗口弹出管理器<p/>
* 若项目需要自定义弹出框管理器，请实现IPopUpManager接口，
* 并在项目初始化前调用Injector.mapClass(IPopUpManager,YourPopUpManager)，
* 注入自定义的弹出框管理器类。
* @author weilichuang
*/
class PopUpManager
{
    private static var impl(get, never) : IPopUpManager;
    public var modalColor(get, set) : Int;
    public var modalAlpha(get, set) : Float;
    public static var popUpList(get, never) : Array<Dynamic>;

    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    private static var _impl : IPopUpManager;
    /**
	* 获取单例
	*/
    private static function get_impl() : IPopUpManager
    {
        if (_impl == null) 
        {
            try
            {
                _impl = Injector.getInstance(IPopUpManager);
            }           
			catch (e : String)
            {
                _impl = new PopUpManagerImpl();
            }
        }
        return _impl;
    }
    
    /**
	* 模态遮罩的填充颜色
	*/
    private function get_modalColor() : Int
    {
        return impl.modalColor;
    }
    private function set_modalColor(value : Int) : Int
    {
        impl.modalColor = value;
        return value;
    }
    
    /**
	* 模态遮罩的透明度
	*/
    private function get_modalAlpha() : Float
    {
        return impl.modalAlpha;
    }
    private function set_modalAlpha(value : Float) : Float
    {
        impl.modalAlpha = value;
        return value;
    }
    
    /**
	* 弹出一个窗口。<br/>
	* @param popUp 要弹出的窗口
	* @param modal 是否启用模态。即禁用弹出窗口所在层以下的鼠标事件。默认false。
	* @param center 是否居中窗口。等效于在外部调用centerPopUp()来居中。默认true。
	* @param systemManager 要弹出到的系统管理器。若项目中只含有一个系统管理器，可以留空。
	*/
    public static function addPopUp(popUp : IVisualElement, modal : Bool = false,
            center : Bool = true, systemManager : ISystemManager = null) : Void
    {
        impl.addPopUp(popUp, modal, center, systemManager);
        impl.dispatchEvent(new PopUpEvent(PopUpEvent.ADD_POPUP, false, false, popUp, modal));
    }
    
    /**
	* 移除由addPopUp()方法弹出的窗口。
	* @param popUp 要移除的窗口
	*/
    public static function removePopUp(popUp : IVisualElement) : Void
    {
        impl.removePopUp(popUp);
        impl.dispatchEvent(new PopUpEvent(PopUpEvent.REMOVE_POPUP, false, false, popUp));
    }
    
    /**
	* 将指定窗口居中显示
	* @param popUp 要居中显示的窗口
	*/
    public static function centerPopUp(popUp : IVisualElement) : Void
    {
        impl.centerPopUp(popUp);
    }
    
    /**
	* 将指定窗口的层级调至最前
	* @param popUp 要最前显示的窗口
	*/
    public static function bringToFront(popUp : IVisualElement) : Void
    {
        impl.bringToFront(popUp);
        impl.dispatchEvent(new PopUpEvent(PopUpEvent.BRING_TO_FRONT, false, false, popUp));
    }
    /**
	* 已经弹出的窗口列表
	*/
    private static function get_popUpList() : Array<Dynamic>
    {
        return impl.popUpList;
    }
    
    /**
	* 添加事件监听,参考PopUpEvent定义的常量。
	* @see flexlite.events.PopUpEvent
	*/
    public static function addEventListener(type : String, listener : Dynamic->Void,
            useCapture : Bool = false,
            priority : Int = 0,
            useWeakReference : Bool = true) : Void
    {
        impl.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    /**
	* 移除事件监听,参考PopUpEvent定义的常量。
	* @see flexlite.events.PopUpEvent
	*/
    public static function removeEventListener(type : String, listener : Dynamic->Void,
            useCapture : Bool = false) : Void
    {
        impl.removeEventListener(type, listener, useCapture);
    }
}
