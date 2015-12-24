package flexlite.core;

import flexlite.core.IUIComponent;


/**
* 工具提示组件接口
* @author weilichuang
*/
interface IToolTip extends IUIComponent
{
    
    
    
    /**
	* 工具提示的数据对象，通常为一个字符串。
	*/
    var toolTipData(get, set) : Dynamic;

}
