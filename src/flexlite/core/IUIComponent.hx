package flexlite.core;

import flexlite.core.IVisualElement;

import flexlite.managers.ISystemManager;

/**
* UI组件接口
* @author weilichuang
*/
interface IUIComponent extends IVisualElement
{
    
    
    /**
	* 组件是否可以接受用户交互。
	*/
    var enabled(get, set) : Bool;    
    
    /**
	* PopUpManager将其设置为true,以指示已弹出该组件。
	*/
    var isPopUp(get, set) : Bool;    
    /**
	* 外部显式指定的高度
	*/
    var explicitHeight(get, never) : Float;    
    /**
	* 外部显式指定的宽度
	*/
    var explicitWidth(get, never) : Float;    
    
    /**
	* 当鼠标在组件上按下时，是否能够自动获得焦点的标志。注意：UIComponent的此属性默认值为false。
	*/
    var focusEnabled(get, set) : Bool;    
    
    /**
	* 所属的系统管理器
	*/
    var systemManager(get, set) : ISystemManager;

    /**
	* 设置组件的宽高，w,h均不包含scale值。此方法不同于直接设置width,height属性，
	* 不会影响显式标记尺寸属性widthExplicitlySet,_heightExplicitlySet
	*/
    function setActualSize(newWidth : Float, newHeight : Float) : Void;
    /**
	* 设置当前组件为焦点对象
	*/
    function setFocus() : Void;
}


