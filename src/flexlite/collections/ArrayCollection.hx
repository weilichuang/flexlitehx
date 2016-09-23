package flexlite.collections;

import flash.events.Event;
import flash.events.EventDispatcher;
import flexlite.collections.ICollection;
import flexlite.events.CollectionEvent;
import flexlite.events.CollectionEventKind;
/**
 * 集合数据发生改变
 */
@:meta(Event(name="collectionChange",type="flexlite.events.CollectionEvent"))

@:meta(DXML(show="false"))

@:meta(DefaultProperty(name="source",array="true"))
/**
* 数组的集合类数据结构包装器
* 通常作为列表组件的数据源，使用这种数据结构包装普通数组，
* 能在数据源发生改变的时候主动通知视图刷新变更的数据项
*/
class ArrayCollection implements ICollection
{
	public var source(get, set) : Array<Dynamic>;
	public var length(get, never) : Int;

	/**
	* 构造函数
	* @param source 数据源
	*/
	public function new(source : Array<Dynamic> = null)
	{
		//super();
		eventDispatcher = new EventDispatcher(this);
		if (source != null)
		{
			_source = source;
		}
		else
		{
			_source = [];
		}
	}

	private var _source : Array<Dynamic>;
	/**
	* 数据源
	* 通常情况下请不要直接调用Array的方法操作数据源，否则对应的视图无法收到数据改变的通知。
	* 若对数据源进行了排序或过滤等操作，请手动调用refresh()方法刷新数据。<br/>
	*/
	private function get_source() : Array<Dynamic>
	{
		return _source;
	}

	private function set_source(value : Array<Dynamic>) : Array<Dynamic>
	{
		if (value == null)
			value = [];
		_source = value;
		dispatchCoEvent(CollectionEventKind.RESET);
		return value;
	}
	/**
	* 在对数据源进行排序或过滤操作后可以手动调用此方法刷新所有数据,以更新视图。
	*/
	public function refresh() : Void
	{
		dispatchCoEvent(CollectionEventKind.REFRESH);
	}
	/**
	* 是否包含某项数据
	*/
	public function contains(item : Dynamic) : Bool
	{
		return getItemIndex(item) != -1;
	}

	/**
	* 检测索引是否超出范围
	*/
	private function checkIndex(index : Int) : Void
	{
		if (index < 0 || index >= _source.length)
		{
			throw ("索引:\"" + index + "\"超出集合元素索引范围");
		}
	}

	//--------------------------------------------------------------------------
	//
	// ICollection接口实现方法
	//
	//--------------------------------------------------------------------------
	/**
	* @inheritDoc
	*/
	private inline function get_length() : Int
	{
		return _source.length;
	}
	/**
	* 向列表末尾添加指定项目。等效于 addItemAt(item, length)。
	*/
	public function addItem(item : Dynamic) : Void
	{
		_source.push(item);
		dispatchCoEvent(CollectionEventKind.ADD, _source.length - 1, -1, [item]);
	}

	/**
	* 在指定的索引处添加项目。
	* 任何大于已添加项目的索引的项目索引都会增加 1。
	* @throws RangeError 如果索引小于 0 或大于长度。
	*/
	public function addItemAt(item : Dynamic, index : Int) : Void
	{
		if (index < 0 || index > _source.length)
		{
			throw ("索引:\"" + index + "\"超出集合元素索引范围");
		}
		_source.insert(index, item);
		dispatchCoEvent(CollectionEventKind.ADD, index, -1, [item]);
	}
	/**
	* @inheritDoc
	*/
	public inline function getItemAt(index : Int) : Dynamic
	{
		return _source[index];
	}
	/**
	* @inheritDoc
	*/
	public function getItemIndex(item : Dynamic) : Int
	{
		var length : Int = _source.length;
		for (i in 0...length)
		{
			if (_source[i] == item)
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
	* 删除列表中的所有项目。
	*/
	public function removeAll() : Void
	{
		var items : Array<Dynamic> = _source.concat([]);
		_source = [];
		dispatchCoEvent(CollectionEventKind.REMOVE, 0, -1, items);
	}
	/**
	* 删除指定索引处的项目并返回该项目。原先位于此索引之后的所有项目的索引现在都向前移动一个位置。
	* @throws RangeError 如果索引小于 0 或大于长度。
	*/
	public function removeItemAt(index : Int) : Dynamic
	{
		checkIndex(index);
		var item : Dynamic = _source.splice(index, 1)[0];
		dispatchCoEvent(CollectionEventKind.REMOVE, index, -1, [item]);
		return item;
	}
	/**
	* 替换在指定索引处的项目，并返回该项目。
	* @throws RangeError 如果索引小于 0 或大于长度。
	*/
	public function replaceItemAt(item : Dynamic, index : Int) : Dynamic
	{
		checkIndex(index);
		var oldItem : Dynamic = _source[index];
		_source.insert(index, item);
		dispatchCoEvent(CollectionEventKind.REPLACE, index, -1, [item], [oldItem]);
		return oldItem;
	}
	/**
	* 用新数据源替换原始数据源，此方法与直接设置source不同，它不会导致目标视图重置滚动位置。
	* @param newSource 新的数据源
	*/
	public function replaceAll(newSource : Array<Dynamic>) : Void
	{
		if (newSource == null)
			newSource = [];
		var newLength : Int = newSource.length;
		var oldLenght : Int = _source.length;
		for (i in newLength...oldLenght)
		{
			removeItemAt(newLength);
		}
		for (i in 0...newLength)
		{
			if (i >= oldLenght)
				addItemAt(newSource[i], i)
				else
					replaceItemAt(newSource[i], i);
		}
		_source = newSource;
	}
	/**
	* 移动一个项目
	* 在oldIndex和newIndex之间的项目，
	* 若oldIndex小于newIndex,索引会减1
	* 若oldIndex大于newIndex,索引会加1
	* @return 被移动的项目
	* @throws RangeError 如果索引小于 0 或大于长度。
	*/
	public function moveItemAt(oldIndex : Int, newIndex : Int) : Dynamic
	{
		checkIndex(oldIndex);
		checkIndex(newIndex);
		var item : Dynamic = _source.splice(oldIndex, 1)[0];
		_source.insert(newIndex, item);
		dispatchCoEvent(CollectionEventKind.MOVE, newIndex, oldIndex, [item]);
		return item;
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
	//--------------------------------------------------------------------------
	//
	// 事件接口实现方法
	//
	//--------------------------------------------------------------------------

	private var eventDispatcher : EventDispatcher;

	/**
	* @inheritDoc
	*/
	public function addEventListener(type : String,
									 listener : Dynamic->Void,
									 useCapture : Bool = false,
									 priority : Int = 0,
									 useWeakReference : Bool = false) : Void
	{
		eventDispatcher.addEventListener(type, listener, useCapture,
		priority, useWeakReference);
	}
	/**
	* @inheritDoc
	*/
	public function removeEventListener(type : String,
										listener : Dynamic->Void,
										useCapture : Bool = false) : Void
	{
		eventDispatcher.removeEventListener(type, listener, useCapture);
	}
	/**
	* @inheritDoc
	*/
	public function dispatchEvent(event : Event) : Bool
	{
		return eventDispatcher.dispatchEvent(event);
	}
	/**
	* @inheritDoc
	*/
	public function hasEventListener(type : String) : Bool
	{
		return eventDispatcher.hasEventListener(type);
	}
	/**
	* @inheritDoc
	*/
	public function willTrigger(type : String) : Bool
	{
		return eventDispatcher.willTrigger(type);
	}

	//--------------------------------------------------------------------------
	//
	// 覆盖Proxy的方法，以实现对for each 和for in的支持
	//
	//--------------------------------------------------------------------------

	/**
	* @inheritDoc
	*/
	//override public function getProperty(name : Dynamic) : Dynamic
	//{
	//var index : Int = convertToIndex(name);
	//return getItemAt(index);
	//}
	/**
	* 转换属性名为索引
	*/
	//private function convertToIndex(name : Dynamic) : Int
	//{
	//if (Std.is(name, QName))
	//name = name.localName;
	//
	//var index : Int = -1;
	//try
	//{
	//var n : Float = Std.parseInt(Std.string(name));
	//if (!Math.isNaN(n))
	//index = Std.int(n);
	//}
	//catch (e : String)
	//{
	//
	//}
	//return index;
	//}

	/**
	* @inheritDoc
	*/
	//override public function setProperty(name : Dynamic, value : Dynamic) : Void
	//{
	//var index : Int = convertToIndex(name);
	//replaceItemAt(value, index);
	//}

	/**
	* @inheritDoc
	*/
	//override public function hasProperty(name : Dynamic) : Bool
	//{
	//var index : Int = convertToIndex(name);
	//if (index == -1)
	//return false;
	//return index >= 0 && index < length;
	//}

	/**
	* @inheritDoc
	*/
	//override public function nextNameIndex(index : Int) : Int
	//{
	//return index < length ? index + 1 : 0;
	//}

	/**
	* @inheritDoc
	*/
	//override public function nextName(index : Int) : String
	//{
	//return Std.string((index - 1));
	//}

	/**
	* @inheritDoc
	*/
	//override public function nextValue(index : Int) : Dynamic
	//{
	//return getItemAt(index - 1);
	//}

	/**
	* @inheritDoc
	*/
	//override public function callProperty(name : Dynamic, ?p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic) : Dynamic
	//{
	//return null;
	//}
}
