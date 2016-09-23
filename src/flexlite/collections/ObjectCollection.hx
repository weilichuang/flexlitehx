package flexlite.collections;
import flash.events.EventDispatcher;

import flexlite.events.CollectionEvent;
import flexlite.events.CollectionEventKind;

/**
* 集合数据发生改变
*/
@:meta(Event(name="collectionChange",type="flexlite.events.CollectionEvent"))
@:meta(DXML(show="false"))
@:meta(DefaultProperty(name="source"))

/**
 * Object的集合类数据结构包装器,通常作为Tree组件的数据源。
 * @author weilichuang
 */
class ObjectCollection extends EventDispatcher implements ICollection implements ITreeCollection
{
	public var source(get, set) : Dynamic;
	public var openNodes(get, set) : Array<Dynamic>;
	public var length(get, never) : Int;
	public var showRoot(get, set) : Bool;

	/**
	* 构造函数
	* @param childrenKey 要从item中获取子项列表的属性名,属性值为一个数组或Vector。
	* @param parentKey 要从item中获取父级项的属性名
	*/
	public function new(childrenKey : String = "children", parentKey : String = "parent")
	{
		super();
		this.childrenKey = childrenKey;
		this.parentKey = parentKey;
	}
	/**
	* 要从item中获取子项列表的属性名
	*/
	private var childrenKey : String;
	/**
	* 要从item中获取父级项的属性名
	*/
	private var parentKey : String;

	private var _source : Dynamic;
	/**
	* 数据源。注意：设置source会同时清空openNodes。
	*/
	private function get_source() : Dynamic
	{
		return _source;
	}

	private function set_source(value : Dynamic) : Dynamic
	{
		_source = value;
		_openNodes = [];
		nodeList = [];
		if (_source != null)
		{
			if (_showRoot)
			{
				nodeList.push(_source);
			}
			else
			{
				_openNodes = [_source];
				addChildren(_source, nodeList);
			}
		}
		dispatchCoEvent(CollectionEventKind.RESET);
		return value;
	}

	/**
	* 要显示的节点列表
	*/
	private var nodeList : Array<Dynamic> = [];

	private var _openNodes : Array<Dynamic> = [];
	/**
	* 处于展开状态的节点列表
	*/
	private function get_openNodes() : Array<Dynamic>
	{
		return _openNodes.concat([]);
	}
	private function set_openNodes(value : Array<Dynamic>) : Array<Dynamic>
	{
		_openNodes = (value != null) ? value.concat([]) : [];
		refresh();
		return value;
	}

	/**
	* @inheritDoc
	*/
	private function get_length() : Int
	{
		return nodeList.length;
	}
	/**
	* @inheritDoc
	*/
	public function getItemAt(index : Int) : Dynamic
	{
		return nodeList[index];
	}
	/**
	* @inheritDoc
	*/
	public function getItemIndex(item : Dynamic) : Int
	{
		var length : Int = nodeList.length;
		for (i in 0...length)
		{
			if (nodeList[i] == item)
			{
				return i;
			}
		}
		return -1;
	}

	/**
	* 通知视图，某个项目的属性已更新。
	*/
	public function itemUpdated(item : Dynamic) : Void
	{
		var index : Int = getItemIndex(item);
		if (index != -1)
		{
			dispatchCoEvent(CollectionEventKind.UPDATE, index, -1, [item]);
		}
	}

	/**
	* 删除指定节点
	*/
	public function removeItem(item : Dynamic) : Void
	{
		if (isItemOpen(item))
			closeNode(item);

		if (item == null)
			return;

		var parent : Dynamic = Reflect.field(item, parentKey);
		if (parent == null)
			return;

		var list : Array<Dynamic> = Reflect.field(parent, childrenKey);
		if (list == null)
			return;

		var index : Int = list.indexOf(item);
		if (index != -1)
			list.splice(index, 1);

		Reflect.setField(item, parentKey, null);

		index = nodeList.indexOf(item);
		if (index != -1)
		{
			nodeList.splice(index, 1);
			dispatchCoEvent(CollectionEventKind.REMOVE, index, -1, [item]);
		}
	}

	private var _showRoot : Bool = false;
	/**
	* 是否显示根节点,默认false。
	*/
	private function get_showRoot() : Bool
	{
		return _showRoot;
	}
	private function set_showRoot(value : Bool) : Bool
	{
		if (_showRoot == value)
			return value;

		_showRoot = value;
		if (_source != null)
		{
			if (_showRoot)
			{
				nodeList.insert(0, _source);
			}
			else
			{
				nodeList.shift();
				if (openNodes.indexOf(_source) == -1)
					openNodes.push(_source);
			}
			refresh();
		}
		return value;
	}

	/**
	* 添加打开的节点到列表
	*/
	private function addChildren(parent : Dynamic, list : Array<Dynamic>) : Void
	{
		if (!Reflect.hasField(parent,childrenKey) || _openNodes.indexOf(parent) == -1)
			return;

		var childs:Array<Dynamic> = Reflect.field(parent, childrenKey);
		for (child in childs)
		{
			list.push(child);
			addChildren(child, list);
		}
	}
	/**
	* @inheritDoc
	*/
	public function hasChildren(item : Dynamic) : Bool
	{
		if (Reflect.hasField(item,childrenKey))
			return Reflect.field(item, childrenKey).length > 0;
		return false;
	}
	/**
	* @inheritDoc
	*/
	public function isItemOpen(item : Dynamic) : Bool
	{
		return _openNodes.indexOf(item) != -1;
	}
	/**
	* @inheritDoc
	*/
	public function expandItem(item : Dynamic, open : Bool = true) : Void
	{
		if (open)
			openNode(item)
			else
				closeNode(item);
	}
	/**
	* 打开一个节点
	*/
	private function openNode(item : Dynamic) : Void
	{
		if (_openNodes.indexOf(item) == -1)
		{
			_openNodes.push(item);
			var index : Int = nodeList.indexOf(item);
			if (index != -1)
			{
				var list : Array<Dynamic> = [];
				addChildren(item, list);
				var i : Int = index;
				while (list.length != 0)
				{
					i++;
					var node : Dynamic = list.shift();
					nodeList.insert(i, node);
					dispatchCoEvent(CollectionEventKind.ADD, i, -1, [node]);
				}
				dispatchCoEvent("open", index, index, [item]);
			}
		}
	}
	/**
	* 关闭一个节点
	*/
	private function closeNode(item : Dynamic) : Void
	{
		var index : Int = _openNodes.indexOf(item);
		if (index == -1)
			return;
		var list : Array<Dynamic> = [];
		addChildren(item, list);
		_openNodes.splice(index, 1);
		index = nodeList.indexOf(item);
		if (index != -1)
		{
			index++;
			while (list.length != 0)
			{
				var node : Dynamic = nodeList.splice(index, 1)[0];
				dispatchCoEvent(CollectionEventKind.REMOVE, index, -1, [node]);
				list.shift();
			}
			index--;
			dispatchCoEvent(CollectionEventKind.CLOSE, index, index, [item]);
		}
	}
	/**
	* @inheritDoc
	*/
	public function getDepth(item : Dynamic) : Int
	{
		var depth : Int = 0;
		var parent : Dynamic = Reflect.field(item, parentKey);
		while (parent != null)
		{
			depth++;
			parent = Reflect.field(parent, parentKey);
		}
		if (depth > 0 && !_showRoot)
			depth--;
		return depth;
	}
	/**
	* 刷新数据源。
	*/
	public function refresh() : Void
	{
		nodeList = [];
		if (_source != null)
		{
			if (_showRoot)
			{
				nodeList.push(_source);
			}
			addChildren(_source, nodeList);
		}
		dispatchCoEvent(CollectionEventKind.REFRESH);
	}

	/**
	* 抛出事件
	*/
	private function dispatchCoEvent(kind : String = null, location : Int = -1,
									 oldLocation : Int = -1, items : Array<Dynamic> = null, oldItems : Array<Dynamic> = null) : Void
	{
		var event : CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false,
		kind, location, oldLocation, items, oldItems);
		dispatchEvent(event);
	}
	/**
	* 一个工具方法，给parent的子项以及子孙项赋值父级引用。
	* @param parent 要遍历子项的parent对象。
	* @param childrenKey 要从parent中获取子项列表的属性名,属性值为一个数组或Vector。
	* @param parentKey 要给子项赋值父级引用的属性名。
	*/
	public static function assignParent(parent : Dynamic, childrenKey : String = "children", parentKey : String = "parent") : Void
	{
		if (!Reflect.hasField(parent,childrenKey))
			return;

		var chlils:Array<Dynamic> = Reflect.field(parent, childrenKey);
		for (child in chlils)
		{
			try
			{
				Reflect.setField(child, parentKey, parent);
			}
			catch (e : String) { };
			assignParent(child, childrenKey, parentKey);
		}
	}
}
