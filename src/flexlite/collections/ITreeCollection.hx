package flexlite.collections;
/**
 * Tree组件的集合类数据源对象接口
 * @author weilichuang
 */
interface ITreeCollection extends ICollection
{

	/**
	* 检查指定的节点是否含有子节点
	* @param item 要检查的节点
	*/
	function hasChildren(item : Dynamic) : Bool;

	/**
	* 指定的节点是否打开
	*/
	function isItemOpen(item : Dynamic) : Bool;

	/**
	* 打开或关闭一个节点
	* @param item 要打开或关闭的节点
	* @param open true表示打开节点，反之关闭。
	*/
	function expandItem(item : Dynamic, open : Bool = true) : Void;

	/**
	* 获取节点的深度
	*/
	function getDepth(item : Dynamic) : Int;
}
