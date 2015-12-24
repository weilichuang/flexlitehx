package flexlite.managers;


import flash.events.IEventDispatcher;
import flash.geom.Point;
import flexlite.core.IToolTip;

/**
* 包含工具提示功能的组件接口
* @author weilichuang
*/
interface IToolTipManagerClient extends IEventDispatcher
{
    
    
    /**
	* 此组件的工具提示数据。<br/>
	* 此属性将赋值给工具提示显示对象的toolTipData属性。通常给此属性直接赋值一个String。<br/>
	* 当组件的toolTipClass为空时，ToolTipManager将采用注入的默认工具提示类创建显示对象。<br/>
	* 若toolTipClass不为空时，ToolTipManager将使用指定的toolTipClass创建显示对象。
	*/
    var toolTip(get, set) : Dynamic;    
    
    
    /**
	* 创建工具提示显示对象要用到的类,要实现IToolTip接口。ToolTip默认会被禁用鼠标事件。
	* 若此属性为空，ToolTipManager将采用默认的工具提示类创建显示对象。<br/>
	*/
    var toolTipClass(get, set) : Class<IToolTip>;    
    
    
    /**
	* toolTip弹出位置，请使用PopUpPosition定义的常量，若不设置或设置了非法的值，则弹出位置跟随鼠标。
	*/
    var toolTipPosition(get, set) : String;    
    
    /**
	* toolTip弹出位置的偏移量
	*/
    var toolTipOffset(get, set) : Point;

}


