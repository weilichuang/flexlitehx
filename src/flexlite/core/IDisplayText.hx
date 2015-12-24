package flexlite.core;

import flexlite.core.IUIComponent;

/**
* 简单文本显示控件接口。
* @author weilichuang
*/
interface IDisplayText extends IUIComponent
{
    
    
    /**
	* 此文本组件所显示的文本。
	*/
    var text(get, set) : String;

}
