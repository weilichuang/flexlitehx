package flexlite.collections;
import flash.events.IEventDispatcher;
/**
 * 列表的集合类数据源对象接口
 * @author weilichuang
 */
interface ICollection extends IEventDispatcher
{

	/**
	* 此集合中的项目数。0 表示不包含项目，而 -1 表示长度未知。
	*/
	var length(get, never) : Int;

	/**
	* 获取指定索引处的项目。
	* @throws RangeError 如果索引小于 0 或大于长度。
	*/
	function getItemAt(index : Int) : Dynamic;

	/**
	* 如果项目位于列表中,返回该项目的索引。否则返回-1。
	*/
	function getItemIndex(item : Dynamic) : Int;
}
