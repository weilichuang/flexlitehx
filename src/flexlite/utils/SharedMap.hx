package flexlite.utils;


import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.ds.WeakMap;

/**
* 具有动态内存管理功能的哈希表。<br/>
* 此类通常用于动态共享高内存占用的数据对象，比如BitmapData。
* 它类似Dictionary，使用key-value形式来存储数据。
* 但当外部对value的所有引用都断开时，value会被GC标记为可回收对象，并从哈希表移除。<br/>
* <b>注意：</b>
* 只有引用型的value才能启用动态内存管理，若value是基本数据类型(例如String,int等)时，需手动remove()它。
* @author weilichuang
*/
class SharedMap
{
    public var keys(get, never) : Array<String>;
    public var values(get, never) : Array<Dynamic>;

    /**
	* 构造函数
	* @param groupSize 分组大小,数字越小查询效率越高，但内存占用越高。
	*/
    public function new(groupSize : Int = 200)
    {
        if (groupSize < 1) 
            groupSize = 1;
        this.groupSize = groupSize;
    }
    
    /**
	* key缓存字典
	*/
    private var keyDic : StringMap<WeakMap<Dynamic,String>> = new StringMap<WeakMap<Dynamic,String>>();
    /**
	* 上一次的value缓存字典
	*/
    private var lastValueDic : WeakMap<Dynamic,String>;
    /**
	* 通过值获取键
	* @param value
	*/
    private function getValueByKey(key : String) : Dynamic
    {
        var valueDic : WeakMap<Dynamic,String> = keyDic.get(key);
        if (valueDic == null) 
            return null;
			
        var found : Bool = false;
        var value : Dynamic = null;
		
		var keys = valueDic.keys();
        for (value in keys)
        {
            if (valueDic.get(value) == key) 
            {
                found = true;
                break;
            }
        }
        if (!found) 
        {
            value = null;
            keyDic.remove(key);
        }
        return value;
    }
    
    /**
	* 分组大小
	*/
    private var groupSize : Int = 200;
    /**
	* 添加过的key的总数
	*/
    private var totalKeys : Int = 0;
    /**
	* 设置键值映射
	* @param key 键
	* @param value 值
	*/
    public function set(key : String, value : Dynamic) : Void
    {
        var valueDic : WeakMap<Dynamic,String> = keyDic.get(key);
        if (valueDic != null) 
        {
            var oldValue : Dynamic = getValueByKey(key);
            if (oldValue != null) 
                valueDic.remove(oldValue);
        }
        else 
        {
            if (totalKeys % groupSize == 0) 
                lastValueDic = new WeakMap<Dynamic,String>();
            valueDic = lastValueDic;
            totalKeys++;
        }
        if (valueDic.get(value) != null) 
            valueDic = lastValueDic = new WeakMap<Dynamic,String>();
			
        keyDic.set(key, valueDic);
        valueDic.set(value, key);
    }
    /**
	* 获取指定键的值
	* @param key
	*/
    public function get(key : String) : Dynamic
    {
        return getValueByKey(key);
    }
    /**
	* 检测是否含有指定键
	* @param key 
	*/
    public function has(key : String) : Bool
    {
        var valueDic : WeakMap<Dynamic,String> = keyDic.get(key);
        if (valueDic == null) 
            return false;
			
        var has : Bool = false;
		var keys = valueDic.keys();
        for (value in keys)
        {
            if (valueDic.get(value) == key) 
            {
                has = true;
                break;
            }
        }
        if (!has) 
            keyDic.remove(key);
        return has;
    }
    /**
	* 移除指定的键
	* @param key 要移除的键
	* @return 是否移除成功
	*/
    public function remove(key : String) : Bool
    {
        var value : Dynamic = getValueByKey(key);
        if (value == null) 
            return false;
        var valueDic : WeakMap<Dynamic,String> = keyDic.get(key);
        
		keyDic.remove(key);
		valueDic.remove(value);
		
        return true;
    }
    /**
	* 获取键名列表
	*/
    private function get_keys() : Array<String>
    {
        var keyList : Array<String> = new Array<String>();
        var cacheDic : ObjectMap<Dynamic,Bool> = new ObjectMap<Dynamic,Bool>();
		
		var keys = keyDic.keys();
        for (key in keys)
        {
            var valueDic : WeakMap<Dynamic,String> = keyDic.get(key);
            if (cacheDic.get(valueDic) != null) 
                continue;
				
            cacheDic.set(valueDic, true);
			
			var valueKeys = valueDic.keys();
            for (validKey in valueKeys)
            {
                keyList.push(valueDic.get(validKey));
            }
        }
        return keyList;
    }
    /**
	* 获取值列表
	*/
    private function get_values() : Array<Dynamic>
    {
        var valueList : Array<Dynamic> = [];
        var cacheDic : ObjectMap<Dynamic,Bool> = new ObjectMap<Dynamic,Bool>();
		
        var keys = keyDic.keys();
        for (key in keys)
        {
            var valueDic : WeakMap<Dynamic,String> = keyDic.get(key);
			
            if (cacheDic.get(valueDic) != null) 
                continue;
				
            cacheDic.set(valueDic, true);
			
			var valueKeys = valueDic.keys();
            for (value in valueKeys)
            {
                valueList.push(value);
            }
        }
        return valueList;
    }
    /**
	* 刷新缓存并删除所有失效的键值。
	*/
    public function refresh() : Void
    {
        var keyList : Array<String> = keys;
		
        for (key in keyDic.keys())
        {
            if (keyList.indexOf(key) == -1) 
                keyDic.remove(key);
        }
    }
}
