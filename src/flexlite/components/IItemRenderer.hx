package flexlite.components;


import flexlite.core.ILayoutElement;

/**
* 列表类组件的项呈示器接口
* @author weilichuang
*/
interface IItemRenderer extends ILayoutElement
{
    
    
    /**
	* 要呈示或编辑的数据。
	*/
    var data(get, set) : Dynamic;    
    
    /**
	* 如果项呈示器可以将其自身显示为已选中，则包含 true。
	*/
    var selected(get, set) : Bool;    
    
    /**
	* 项呈示器的主机组件的数据提供程序中的项目索引。
	*/
    var itemIndex(get, set) : Int;    
    
    /**
	* 要在项呈示器中显示的 String。 
	*/
    var label(get, set) : String;

}
