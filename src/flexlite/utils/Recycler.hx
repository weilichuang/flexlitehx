package flexlite.utils;


import flash.utils.Dictionary;
import haxe.ds.WeakMap;

/**
* 对象缓存复用工具类，可用于构建对象池。
* 利用了Dictionary弱引用特性。一段时间后会自动回收对象。
* @author weilichuang
*/
class Recycler
{
    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    /**
	* 缓存字典
	*/
    private var cache : WeakMap<Dynamic,Dynamic> = new WeakMap<Dynamic,Dynamic>();
    /**
	* 缓存一个对象以复用
	* @param object
	*/
    public function push(object : Dynamic) : Void
    {
        cache.set(object, null);
    }
    /**
	* 获取一个缓存的对象
	*/
    public function get() : Dynamic
    {
		var keys = cache.keys();
        for (object in keys)
        {
            cache.remove(object);
            return object;
        }
		return null;
    }
    /**
	* 立即清空所有缓存的对象。
	*/
    public function reset() : Void
    {
        cache = new WeakMap<Dynamic,Dynamic>();
    }
}
