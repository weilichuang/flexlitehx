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
* XML的集合类数据结构包装器,通常作为Tree组件的数据源。
* @author weilichuang
*/
class XMLCollection extends EventDispatcher implements ICollection implements ITreeCollection
{
    public var source(get, set) : Xml;
    public var openNodes(get, set) : Array<Xml>;
    public var length(get, never) : Int;
    public var showRoot(get, set) : Bool;

	private var _showRoot : Bool = false;
	
	private var _source : Xml;
	
	/**
	* 要显示的节点列表
	*/
    private var nodeList : Array<Xml> = [];
    
    private var _openNodes : Array<Xml> = [];
	
    /**
	* 构造函数
	* @param source 数据源
	* @param openNodes 打开的节点列表
	*/
    public function new(source : Xml = null, openNodes : Array<Xml> = null)
    {
        super();
        if (openNodes != null) 
        {
            _openNodes = openNodes.concat([]);
        }
        if (source != null) 
        {
            _source = source;
            if (_showRoot) 
            {
                nodeList.push(_source);
            }
            addChildren(_source, nodeList);
        }
    }
    
    
    /**
	* 数据源。注意：设置source会同时清空openNodes。
	*/
    private function get_source() : Xml
    {
        return _source;
    }
    
    private function set_source(value : Xml) : Xml
    {
		if (value.nodeType == Xml.Document)
		{
			_source = value.firstElement();
		}
		else if (value.nodeType == Xml.Element)
		{
			_source = value;
		}
		else
		{
			throw throw 'Bad node type, expected Element or Document but found ${value.nodeType}';
		}
        
        _openNodes = [];
        nodeList = [];
        if (_source != null) 
        {
            if (_showRoot) 
            {
                nodeList.push(_source);
            }
            addChildren(_source, nodeList);
        }
        dispatchCoEvent(CollectionEventKind.RESET);
        return value;
    }
    
    
    /**
	* 处于展开状态的节点列表
	*/
    private function get_openNodes() : Array<Xml>
    {
        return _openNodes.concat([]);
    }
	
    private function set_openNodes(value : Array<Xml>) : Array<Xml>
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
    public function getItemAt(index : Int) : Xml
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
        return 0;
    }
    
    
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
                nodeList.push(_source);
            }
            else 
            {
                nodeList.shift();
            }
        }
        return value;
    }
    /**
	* 添加打开的节点到列表
	*/
    private function addChildren(parent : Xml, list : Array<Xml>) : Void
    {
		for(child in parent) 
		{
			if (child.nodeType != Xml.Element)
				continue;
				
			list.push(child);
            if (_openNodes.indexOf(child) != -1) 
                addChildren(child, list);
		}
    }
	
    /**
	* @inheritDoc
	*/
    public function hasChildren(item : Dynamic) : Bool
    {
        if (!Std.is(item, Xml)) 
            return false;
			
        return cast(item, Xml).elements().hasNext();
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
        if (!(Std.is(item, Xml))) 
            return;
			
        if (open) 
            openNode(cast item)
        else 
			closeNode(cast item);
    }
    /**
	* 打开一个节点
	*/
    private function openNode(item : Xml) : Void
    {
        var index : Int = nodeList.indexOf(item);
        if (index != -1 && _openNodes.indexOf(item) == -1) 
        {
            _openNodes.push(item);
            var list : Array<Xml> = [];
            addChildren(item, list);
            var i : Int = index;
            while (list.length != 0)
            {
                i++;
                var node : Xml = list.shift();
                nodeList.insert(i, node);
                dispatchCoEvent(CollectionEventKind.ADD, i, -1, [node]);
            }
            dispatchCoEvent(CollectionEventKind.OPEN, index, index, [item]);
        }
    }
    /**
	* 关闭一个节点
	*/
    private function closeNode(item : Xml) : Void
    {
        var index : Int = _openNodes.indexOf(item);
        if (index == -1) 
            return;
        _openNodes.splice(index, 1);
        index = nodeList.indexOf(item);
        if (index != -1) 
        {
            var list : Array<Xml> = [];
            addChildren(item, list);
            index++;
            while (list.length != 0)
            {
                var node : Xml = nodeList.splice(index, 1)[0];
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
        if (!Std.is(item, Xml)) 
            return depth;
			
		var xml:Xml = cast item;
			
        var parent : Xml = xml.parent;
        while (parent != null)
        {
            depth++;
            parent = parent.parent;
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
}
