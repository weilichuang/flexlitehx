package flexlite.components;



/**
* 树状列表组件的项呈示器接口
* @author weilichuang
*/
interface ITreeItemRenderer extends IItemRenderer
{
    
    
    /**
	* 图标的皮肤名
	*/
    var iconSkinName(get, set) : Dynamic;    
    
    
    /**
	* 缩进深度。0表示顶级节点，1表示第一层子节点，以此类推。
	*/
    var depth(get, set) : Int;    
    
    
    /**
	* 是否含有子节点。
	*/
    var hasChildren(get, set) : Bool;    
    
    
    /**
	* 节点是否处于开启状态。
	*/
    var opened(get, set) : Bool;

}
