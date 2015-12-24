package flexlite.core;

import flexlite.core.IVisualElement;


/**
* 层级堆叠容器接口
* @author weilichuang
*/
interface IViewStack
{
    
    
    /**
	* 当前可见子元素的索引。索引从0开始。
	*/
    var selectedIndex(get, set) : Int;    
    
    
    /**
	* 当前可见的子元素。
	*/
    var selectedChild(get, set) : IVisualElement;

}
