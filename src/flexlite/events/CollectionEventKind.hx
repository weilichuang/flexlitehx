package flexlite.events;


/**
* 定义  CollectionEvent 类 kind 属性的有效值的常量。
* 这些常量指示对集合进行的更改类型。
* @author weilichuang
*/
class CollectionEventKind
{
    /**
	* 指示集合添加了一个或多个项目。 
	*/
    public static inline var ADD : String = "add";
    /**
	* 指示项目已从 CollectionEvent.oldLocation确定的位置移动到 location确定的位置。 
	*/
    public static inline var MOVE : String = "move";
    /**
	* 指示集合应用了排序或/和筛选。
	*/
    public static inline var REFRESH : String = "refresh";
    /**
	* 指示集合删除了一个或多个项目。 
	*/
    public static inline var REMOVE : String = "remove";
    /**
	* 指示已替换由 CollectionEvent.location 属性确定的位置处的项目。 
	*/
    public static inline var REPLACE : String = "replace";
    /**
	* 指示集合已彻底更改，需要进行重置。 
	*/
    public static inline var RESET : String = "reset";
    /**
	* 指示集合中一个或多个项目进行了更新。受影响的项目将存储在  CollectionEvent.items 属性中。 
	*/
    public static inline var UPDATE : String = "update";
    /**
	* 指示集合中某个节点的子项列表已打开，通常应用于Tree的数据源XMLCollection。
	*/
    public static inline var OPEN : String = "open";
    /**
	* 指示集合中某个节点的子项列表已关闭，通常应用于Tree的数据源XMLCollection。
	*/
    public static inline var CLOSE : String = "close";

    public function new()
    {
    }
}
