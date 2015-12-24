package flexlite.dll.core;


import flexlite.dll.core.DllItem;
import flexlite.dll.core.IDllConfig;
import haxe.ds.StringMap;

import flash.utils.ByteArray;
import flash.utils.Dictionary;




/**
* Dll配置文件解析器
* @author weilichuang
*/
class DllConfig implements IDllConfig
{
    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    private var _language : String;
    /**
	* @inheritDoc
	*/
    public function setLanguage(value : String) : Void
    {
        _language = value;
    }
    
    /**
	* @inheritDoc
	*/
    public function getGroupByName(name : String) : Array<DllItem>
    {
        var group : Array<DllItem> = new Array<DllItem>();
        if (!groupDic.exists(name)) 
            return group;
			
		var objs:Array<Dynamic> = groupDic.get(name);
        for (obj in objs)
        {
            group.push(parseDllItem(obj));
        }
        return group;
    }
    /**
	* @inheritDoc
	*/
    public function createGroup(name : String, keys : Array<Dynamic>, overrideOld : Bool = false) : Bool
    {
        if ((!overrideOld && groupDic.exists(name)) || keys == null || keys.length == 0) 
            return false;
        var group : Array<Dynamic> = [];
        for (key in keys)
        {
            var item : Dynamic = keyMap.get(key);
            if (item != null && group.indexOf(item) == -1) 
                group.push(item);
        }
        if (group.length == 0) 
            return false;
        groupDic.set(name, group);
        return true;
    }
    /**
	* 一级键名字典
	*/
    private var keyMap : StringMap<Dynamic> = new StringMap<Dynamic>();
    /**
	* 加载组字典
	*/
    private var groupDic : StringMap<Array<Dynamic>> = new StringMap<Array<Dynamic>>();
    /**
	* @inheritDoc
	*/
    public function parseConfig(data : Dynamic, folder : String) : Void
    {
        if (data == null) 
            return;
        var group : Array<Dynamic>;
        if (Std.is(data, Xml)) 
        {
            var xmlConfig : Xml = cast(data, Xml);
            data = { };
            for (item in xmlConfig)
            {
                var name : String = Std.string(item.get("name"));
                if (name == null) 
                    continue;
                group = groupDic.get(name);
                if (group == null) 
                {
                    group = [];
					groupDic.set(name, group);
                }
                getItemFromXML(item, folder, group);
            }
        }
        else 
        {
            if (Std.is(data, ByteArray)) 
            {
                try
                {
                    (cast(data, ByteArray)).uncompress();
                }                
				catch (e : String)
				{
					
				}
				(cast(data, ByteArray)).position = 0;
                data = (cast(data, ByteArray)).readObject();
            }
            for (key in Reflect.fields(data))
            {
                group = groupDic.get(key);
                if (group == null) 
                {
                    group = [];
					groupDic.set(key, group);
                }
                getItemFromObject(Reflect.field(data, key), folder, group);
            }
        }
    }
    /**
	* 从xml里解析加载项
	*/
    private function getItemFromXML(xml : Xml, folder : String, group : Array<Dynamic> = null) : Void
    {
        for (item in xml)
        {
            var lang : String = Std.string(item.get("language"));
            if (lang != _language && lang != "all") 
                continue;
            var obj : Dynamic = {
                name : Std.string(item.get("name")),
                url : folder + Std.string(item.get("url")),
                type : Std.string(item.get("type")),
                size : Std.string(item.get("size")),

            };
            if (item.get("subkeys") != null) 
                obj.subkeys = Std.string(item.get("subkeys"));
            addItemToKeyMap(obj);
            if (group != null) 
                group.push(obj);
        }
    }
    /**
	* 从Object里解析加载项
	*/
    private function getItemFromObject(list : Array<Dynamic>, folder : String, group : Array<Dynamic> = null) : Void
    {
        for (item in list)
        {
            var lang : String = item.language;
            if (lang != _language && lang != "all") 
                continue;
            //delete item.language;
            item.url = folder + item.url;
            addItemToKeyMap(item);
            if (group != null) 
                group.push(item);
        }
    }
    /**
	* 添加一个加载项数据到列表
	*/
    private function addItemToKeyMap(item : Dynamic) : Void
    {
        if (!keyMap.exists(item.name)) 
            keyMap.set(item.name, item);
        if (item.exists("subkeys")) 
        {
            var subkeys : Array<String> = Std.string(item.subkeys).split(",");
            item.subkeys = subkeys;
            for (key in subkeys)
            {
                if (keyMap.get(key) != null) 
                    continue;
                keyMap.set(key, item);
            }
        }
    }
    /**
	* @inheritDoc
	*/
    public function getType(key : String) : String
    {
        var data : Dynamic = keyMap.get(key);
        return (data != null) ? data.type : "";
    }
    /**
	* @inheritDoc
	*/
    public function getName(key : String) : String
    {
        var data : Dynamic = keyMap.get(key);
        return (data != null) ? data.name : "";
    }
    /**
	* @inheritDoc
	*/
    public function getDllItem(key : String) : DllItem
    {
        var data : Dynamic = keyMap.get(key);
        if (data != null) 
            return parseDllItem(data);
        return null;
    }
    /**
	* 转换Object数据为DllItem对象
	*/
    private function parseDllItem(data : Dynamic) : DllItem
    {
        var dllItem : DllItem = new DllItem(data.name, data.url, data.type, data.size);
        dllItem.data = data;
        return dllItem;
    }
}
