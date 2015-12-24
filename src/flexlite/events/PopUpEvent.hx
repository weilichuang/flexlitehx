package flexlite.events;


import flash.events.Event;

import flexlite.core.IVisualElement;


/**
* 弹出管理器事件
* @author weilichuang
*/
class PopUpEvent extends Event
{
    /**
	* 添加一个弹出框，在执行完添加之后抛出。
	*/
    public static inline var ADD_POPUP : String = "addPopUp";
    /**
	* 移除一个弹出框，在执行完移除之后抛出。
	*/
    public static inline var REMOVE_POPUP : String = "removePopUp";
    /**
	* 移动弹出框到最前，在执行完前置之后抛出。
	*/
    public static inline var BRING_TO_FRONT : String = "bringToFront";
    /**
	* 构造函数
	*/
    public function new(type : String, bubbles : Bool = false,
            cancelable : Bool = false, popUp : IVisualElement = null,
            modal : Bool = false)
    {
        super(type, bubbles, cancelable);
        this.popUp = popUp;
        this.modal = modal;
    }
    /**
	* 弹出框对象
	*/
    public var popUp : IVisualElement;
    /**
	* 弹出窗口是否为模态，此属性仅在事件类型为ADD_POPUP时有效。
	*/
    public var modal : Bool;
}
