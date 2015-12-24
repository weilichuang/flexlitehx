package flexlite.dll;



import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flexlite.utils.MathUtil;
import haxe.ds.StringMap;

import flexlite.core.Injector;

import flexlite.dll.core.ConfigItem;
import flexlite.dll.core.DllConfig;
import flexlite.dll.core.DllItem;
import flexlite.dll.core.DllLoader;
import flexlite.dll.core.IDllConfig;
import flexlite.dll.core.IResolver;
import flexlite.dll.events.DllEvent;
import flexlite.dll.resolvers.AmfResolver;
import flexlite.dll.resolvers.BinResolver;
import flexlite.dll.resolvers.DxrResolver;
import flexlite.dll.resolvers.GrpResolver;
import flexlite.dll.resolvers.ImgResolver;
import flexlite.dll.resolvers.RslResolver;
import flexlite.dll.resolvers.SoundResolver;
import flexlite.dll.resolvers.SwfResolver;
import flexlite.dll.resolvers.TxtResolver;
import flexlite.dll.resolvers.XmlResolver;
import flexlite.utils.CRC32Util;



/**
* 配置文件加载并解析完成事件
*/
@:meta(Event(name="configComplete",type="org.flexlite.domDll.events.DllEvent"))

/**
* 一组资源加载完成事件
*/
@:meta(Event(name="groupComplete",type="org.flexlite.domDll.events.DllEvent"))

/**
* 一组资源加载进度事件
*/
@:meta(Event(name="groupProgress",type="org.flexlite.domDll.events.DllEvent"))

/**
* 一个加载项加载结束事件，可能是加载成功也可能是加载失败。
*/
@:meta(Event(name="itemLoadFinished",type="org.flexlite.domDll.events.DllEvent"))


/**
* 资源管理器
* @author weilichuang
*/
class Dll extends EventDispatcher
{
    private static var instance(get, never) : Dll;
    public static var eventDispather(get, never) : Dll;
    public static var Language(get, never) : String;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        if (_instance != null) 
        {
            throw "实例化单例:Dll出错！";
        }
        init();
    }
    
    private static var _instance : Dll;
    /**
	* 获取单例
	*/
    private static function get_instance() : Dll
    {
        if (_instance == null) 
        {
            _instance = new Dll();
        }
        return _instance;
    }
    /**
	* 获取事件监听对象
	*/
    private static function get_eventDispather() : Dll
    {
        return instance;
    }
    
    /**
	* 加载配置文件并解析
	* @param configList 配置文件信息列表
	* @param version 资源版本号。请求资源时加在url后的Get参数，以避免浏览器缓存问题而获取错误的资源。
	* @param language 当前的语言环境 
	*/
    public static function LoadConfig(configList : Array<ConfigItem>, version : String = "", language : String = "cn") : Void
    {
        instance.loadConfig(configList, version, language);
    }
    /**
	* 根据组名加载一组资源
	* @param name 要加载资源组的组名
	* @param priority 加载优先级,可以为负数,默认值为0。
	* 低优先级的组必须等待高优先级组完全加载结束才能开始，同一优先级的组会同时加载。
	*/
    public static function LoadGroup(name : String, priority : Int = 0) : Void
    {
        instance.loadGroup(name, priority);
    }
    /**
	* 创建自定义的加载资源组
	* @param name 要创建的加载资源组的组名
	* @param keys 要包含的键名列表，key对应配置文件里的name属性或sbuKeys属性的一项。
	* @param overrideOld 是否覆盖已经存在的同名资源组,默认false。
	* @return 是否创建成功，如果传入的keys为空，或keys全部无效，则创建失败。
	*/
    public static function CreateGroup(name : String, keys : Array<Dynamic>, overrideOld : Bool = false) : Bool
    {
        return instance.createGroup(name, keys, overrideOld);
    }
    /**
	* 语言版本,如"cn","en","tw"等。
	*/
    private static function get_Language() : String
    {
        return instance.language;
    }
    /**
	* 检查某个资源组是否已经加载完成
	* @param groupName 组名
	*/
    public static function IsGroupLoaded(name : String) : Bool
    {
        return instance.isGroupLoaded(name);
    }
    /**
	* 根据组名获取组加载项列表
	* @param name 组名
	*/
    public static function GetGroupByName(name : String) : Array<DllItem>
    {
        return instance.getGroupByName(name);
    }
    /**
	* 检查配置文件里是否含有指定的资源
	* @param key 对应配置文件里的name属性或sbuKeys属性的一项。
	*/
    public static function HasKey(key : String) : Bool
    {
        return instance.hasKey(key);
    }
    /**
	* 同步方式获取配置里的资源。<br/>
	* 预加载的资源可以同步获取，但位图资源或含有需要异步解码的资源除外。<br/>
	* 注意:获取的资源是全局共享的，若你需要修改它，请确保不会对其他模块造成影响，否则建议创建资源的副本以操作。
	* @param key 对应配置文件里的name属性或sbuKeys属性的一项。
	* @return 
	* "swf" key是name返回:Loader key是subkey返回:Class<br/>
	* "rsl" key是name返回:Loader key是subkey返回:Class<br/>
	* "dxr" key是name返回:DxrFile key是subkey返回:DxrData<br/>
	* "amf" key是name返回:Object<br/>
	* "xml" key是name返回:XML<br/>
	* "txt" key是name返回:String<br/>
	* "img" key是name返回:BitmapData<br/>
	* "sound" key是name返回:Sound<br/>
	* "bin" key是name返回:ByteArray
	*/
    public static function GetRes(key : String) : Dynamic
    {
        return instance.getRes(key);
    }
    /**
	* 异步方式获取配置里的资源。只要是配置文件里存在的资源，都可以通过异步方式获取。<br/>
	* 注意:获取的资源是全局共享的，若你需要修改它，请确保不会对其他模块造成影响，否则建议创建资源的副本以操作。
	* @param key 对应配置文件里的name属性或sbuKeys属性的一项。
	* @param compFunc 回调函数。示例：compFunc(data):void,若设置了other参数则为:compFunc(data,other):void。
	* 回调函数的参数类型参考getRes()方法注释。
	* @param other 回调参数(可选),若设置了此参数，获取资源后它将会作为回调函数的第二个参数传入。
	*/
    public static function GetResAsync(key : String, compFunc : Dynamic, other : Dynamic = null) : Void
    {
        instance.getResAsync(key, compFunc, other);
    }
    /**
	* 通过URL方式获取外部资源。<br/>
	* 注意:通过此方式获取的资源不具有缓存和共享功能。若需要缓存和共享资源，请把资源加入配置文件，通过getResAs()或getResAsync()获取。
	* @param url 要加载文件的外部路径。
	* @param compFunc 回调函数。示例：compFunc(data):void,若设置了other参数则为:compFunc(data,other):void。
	* 回调函数的参数类型参考getRes()方法注释。
	* @param type 文件类型(可选)。请使用DllItem类中定义的静态常量。若不设置将根据文件扩展名生成。
	* @param other 回调参数(可选),若设置了此参数，获取资源后它将会作为回调函数的第二个参数传入。
	*/
    public static function GetResByUrl(url : String, compFunc : Dynamic, type : String = "", other : Dynamic = null) : Void
    {
        instance.getResByUrl(url, compFunc, type, other);
    }
    /**
	* 销毁某个资源文件的二进制数据,返回是否删除成功。
	* 注意：Dll通常是只缓存文件字节流数据(占内存很少),而解码后的对像采用的是动态缓存，
	* 在外部引用都断开时能自动回收,所以不需要显式销毁它们。
	* @param name 配置文件中加载项的name属性或资源组名
	*/
    public static function DestroyRes(name : String) : Bool
    {
        return instance.destroyRes(name);
    }
    
    /**
	* 解析器字典
	*/
    private var resolverDic : StringMap<IResolver> = new StringMap<IResolver>();
    /**
	* 根据type获取对应的文件解析库
	*/
    private function getResolverByType(type : String) : IResolver
    {
        var resolver : IResolver = resolverDic.get(type);
        if (resolver == null) 
        {
            resolver = Injector.getInstance(IResolver, type);
			resolverDic.set(type, resolver);
        }
        return resolver;
    }
    
    /**
	* 多文件队列加载器
	*/
    private var dllLoader : DllLoader;
    /**
	* 初始化
	*/
    private function init() : Void
    {
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_XML)) 
            Injector.mapClass(IResolver, XmlResolver, DllItem.TYPE_XML);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_BIN)) 
            Injector.mapClass(IResolver, BinResolver, DllItem.TYPE_BIN);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_AMF)) 
            Injector.mapClass(IResolver, AmfResolver, DllItem.TYPE_AMF);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_IMG)) 
            Injector.mapClass(IResolver, ImgResolver, DllItem.TYPE_IMG);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_SWF)) 
            Injector.mapClass(IResolver, SwfResolver, DllItem.TYPE_SWF);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_RSL)) 
            Injector.mapClass(IResolver, RslResolver, DllItem.TYPE_RSL);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_DXR)) 
            Injector.mapClass(IResolver, DxrResolver, DllItem.TYPE_DXR);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_TXT)) 
            Injector.mapClass(IResolver, TxtResolver, DllItem.TYPE_TXT);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_GRP)) 
            Injector.mapClass(IResolver, GrpResolver, DllItem.TYPE_GRP);
        if (!Injector.hasMapRule(IResolver, DllItem.TYPE_SOUND)) 
            Injector.mapClass(IResolver, SoundResolver, DllItem.TYPE_SOUND);
        if (!Injector.hasMapRule(IDllConfig)) 
            Injector.mapClass(IDllConfig, DllConfig);
        dllConfig = Injector.getInstance(IDllConfig);
        dllLoader = new DllLoader();
        dllLoader.addEventListener(DllEvent.GROUP_PROGRESS, dispatchEvent);
        dllLoader.addEventListener(DllEvent.GROUP_COMPLETE, onGroupComp);
        dllLoader.addEventListener(DllEvent.ITEM_LOAD_FINISHED, dispatchEvent);
    }
    
    /**
	* 配置文件组组名
	*/
    private static inline var GROUP_CONFIG : String = "DLL__CONFIG";
    /**
	* 配置文件名列表
	*/
    private var configItemList : Array<Dynamic> = [];
    /**
	* 配置文件加载解析完成标志
	*/
    private var configComplete : Bool = false;
    /**
	* 语言版本
	*/
    private var language : String = "cn";
    /**
	* 加载配置文件并解析
	* @param configList 配置文件信息列表
	* @param version 资源版本号。请求资源时加在url后的Get参数，以避免浏览器缓存问题而获取错误的资源。
	* @param language 当前的语言环境 
	*/
    public function loadConfig(configList : Array<ConfigItem>, version : String = "", language : String = "cn") : Void
    {
        this.language = language;
        dllLoader.setVersion(version);
        dllConfig.setLanguage(language);
        var itemList : Array<DllItem> = new Array<DllItem>();
        var index : Int = 0;
        for (config in configList)
        {
            config.name = GROUP_CONFIG + index;
            configItemList.push(config);
            var dllItem : DllItem = new DllItem(config.name, config.url, config.type, 0);
            itemList.push(dllItem);
            index++;
        }
        dllLoader.loadGroup(itemList, GROUP_CONFIG, MathUtil.INT_MAX_VALUE);
    }
    /**
	* 已经加载过组名列表
	*/
    private var loadedGroups : Array<String> = new Array<String>();
    /**
	* 检查某个资源组是否已经加载完成
	* @param groupName 组名
	*/
    public function isGroupLoaded(name : String) : Bool
    {
        return loadedGroups.indexOf(name) != -1;
    }
    /**
	* 根据组名获取组加载项列表
	* @param name 组名
	*/
    private function getGroupByName(name : String) : Array<DllItem>
    {
        return dllConfig.getGroupByName(name);
    }
    
    private var groupNameList : Array<Dynamic> = [];
    /**
	* 根据组名加载一组资源
	* @param name 要加载资源组的组名
	* @param priority 加载优先级,低优先级的组必须等待高优先级组完全加载结束才能开始，同一优先级的组同时加载。
	*/
    private function loadGroup(name : String, priority : Int = 0) : Void
    {
        if (loadedGroups.indexOf(name) != -1 || dllLoader.isGroupInLoading(name)) 
            return;
        if (configComplete) 
        {
            var group : Array<DllItem> = dllConfig.getGroupByName(name);
            dllLoader.loadGroup(group, name, priority);
        }
        else 
        {
            groupNameList.push({
                        name : name,
                        priority : priority,

                    });
        }
    }
    /**
	* 创建自定义的加载资源组
	* @param name 要创建的加载资源组的组名
	* @param keys 要包含的键名列表，key对应配置文件里的name属性或sbuKeys属性的一项。
	* @param overrideOld 是否覆盖已经存在的同名资源组,默认false。
	* @return 是否创建成功，如果传入的keys为空，或keys全部无效，则创建失败。
	*/
    private function createGroup(name : String, keys : Array<Dynamic>, overrideOld : Bool = false) : Bool
    {
        if (overrideOld) 
        {
            var index : Int = loadedGroups.indexOf(name);
            if (index != -1) 
            {
                loadedGroups.splice(index, 1);
            }
        }
        return dllConfig.createGroup(name, keys, overrideOld);
    }
    /**
	* dll配置数据
	*/
    private var dllConfig : IDllConfig;
    /**
	* 队列加载完成事件
	*/
    private function onGroupComp(event : DllEvent) : Void
    {
        if (event.groupName == GROUP_CONFIG) 
        {
            for (config in configItemList)
            {
                var resolver : IResolver = getResolverByType(config.type);
                var data : Dynamic = resolver.getRes(config.name);
                resolver.destroyRes(config.name);
                dllConfig.parseConfig(data, config.folder);
            }
            configComplete = true;
            configItemList = null;
            event = new DllEvent(DllEvent.CONFIG_COMPLETE);
            for (item in groupNameList)
            {
                LoadGroup(item.name, item.priority);
            }
            groupNameList = [];
        }
        else 
        {
            loadedGroups.push(event.groupName);
        }
        dispatchEvent(event);
    }
    /**
	* 检查配置文件里是否含有指定的资源
	* @param key 对应配置文件里的name属性或sbuKeys属性的一项。
	*/
    private function hasKey(key : String) : Bool
    {
        return dllConfig.getType(key) != "";
    }
    
    private function getRes(key : String) : Dynamic
    {
        var type : String = dllConfig.getType(key);
        if (type == "") 
            return null;
        var resolver : IResolver = getResolverByType(type);
        return resolver.getRes(key);
    }
    
    /**
	* 异步获取资源参数缓存字典
	*/
    private var asyncDic : StringMap<Array<Dynamic>> = new StringMap<Array<Dynamic>>();
    /**
	* 异步方式获取配置里的资源。只要是配置文件里存在的资源，都可以通过异步方式获取。<br/>
	* 注意:获取的资源是全局共享的，若你需要修改它，请确保不会对其他模块造成影响，否则建议创建资源的副本以操作。
	* @param key 对应配置文件里的name属性或sbuKeys属性的一项。
	* @param compFunc 回调函数。示例：compFunc(data):void,若设置了other参数则为:compFunc(data,other):void
	* @param other 回调参数(可选),若设置了此参数，获取资源后它将会作为回调函数的第二个参数传入。
	*/
    private function getResAsync(key : String, compFunc : Dynamic, other : Dynamic = null) : Void
    {
        if (compFunc == null) 
            return;
        var type : String = dllConfig.getType(key);
        if (type == "") 
        {
            doCompFunc(compFunc, null, other);
            return;
        }
        var resolver : IResolver = getResolverByType(type);
        var res : Dynamic = resolver.getRes(key);
        if (res != null) 
        {
            doCompFunc(compFunc, res, other);
            return;
        }
        var name : String = dllConfig.getName(key);
        if (resolver.hasRes(name)) 
        {
            doGetResAsync(resolver, key, compFunc, other);
        }
        else 
        {
            var args : Dynamic = {
                key : key,
                compFunc : compFunc,
                other : other,
            };
			
            if (asyncDic.exists(name)) 
            {
                asyncDic.get(name).push(args);
            }
            else 
            {
                asyncDic.set(name, [args]);
                var dllItem : DllItem = dllConfig.getDllItem(key);
                dllItem.compFunc = onDllItemComp;
                dllLoader.loadItem(dllItem);
            }
        }
    }
    /**
	* 统计同一个外部资源请求计数的字典
	*/
    private var outResNameDic : StringMap<Int> = new StringMap<Int>();
    /**
	* 通过URL方式获取外部资源。<br/>
	* 注意:通过此方式获取的资源不具有缓存和共享功能。若需要缓存和共享资源，请把资源加入配置文件，通过getResAs()或getResAsync()获取。
	* @param url 要加载文件的外部路径。
	* @param compFunc 回调函数。示例：compFunc(data):void,若设置了other参数则为:compFunc(data,other):void
	* @param type 文件类型(可选)。请使用DllItem类中定义的静态常量。若不设置将根据文件扩展名判断，未知的扩展名默认作为字节流类型。
	* @param other 回调参数(可选),若设置了此参数，获取资源后它将会作为回调函数的第二个参数传入。
	*/
    private function getResByUrl(url : String, compFunc : Dynamic, type : String = "", other : Dynamic = null) : Void
    {
        if (compFunc == null) 
            return;
        if (url == null) 
        {
            doCompFunc(compFunc, null, other);
            return;
        }
        if (type == null) 
            type = getTypeByUrl(url);
        var resolver : IResolver = getResolverByType(type);
        var bytes : ByteArray = new ByteArray();
        bytes.writeUTF(url + type);
        var name : String = "URLRES__" + Std.string(CRC32Util.getCRC32(bytes)).toUpperCase();
        
        var args : Dynamic = {
            key : name,
            compFunc : onUrlComp,
            other : {
                name : name,
                type : type,
                compFunc : compFunc,
                other : other,

            }
        };
		
        if (outResNameDic.exists(name)) 
            outResNameDic.set(name, outResNameDic.get(name) + 1);
        else 
			outResNameDic.set(name, 1);
			
        if (asyncDic.exists(name)) 
        {
            asyncDic.get(name).push(args);
        }
        else 
        {
            asyncDic.set(name, [args]);
            var dllItem : DllItem = new DllItem(name, url, type, 0);
            dllItem.compFunc = onDllItemComp;
            dllLoader.loadItem(dllItem);
        }
    }
    
    /**
	* 通过url获取文件类型
	*/
    private function getTypeByUrl(url : String) : String
    {
        var suffix : String = url.substr(url.lastIndexOf(".") + 1);
        var type : String;
        switch (suffix)
        {
            case DllItem.TYPE_AMF, DllItem.TYPE_DXR, DllItem.TYPE_SWF, DllItem.TYPE_XML, DllItem.TYPE_TXT:
                type = suffix;
            case "png", "jpg", "gif":
                type = DllItem.TYPE_IMG;
            case "mp3":
                type = DllItem.TYPE_SOUND;
            case "json":
                type = DllItem.TYPE_TXT;
            default:
                type = DllItem.TYPE_BIN;
        }
        return type;
    }
    /**
	* 通过URL方式加载的资源完成
	*/
    private function onUrlComp(data : Dynamic, args : Dynamic) : Void
    {
        var other : Dynamic = args.other;
        var compFunc : Dynamic = args.compFunc;
        var name : String = args.name;
		
		outResNameDic.set(name, outResNameDic.get(name) - 1);
		
        if (outResNameDic.get(name) == 0) 
        {
            outResNameDic.remove(name);
            var resolver : IResolver = getResolverByType(args.type);
            resolver.destroyRes(name);
        }
        if (other != null) 
            compFunc(data, other)
        else 
			compFunc(data);
    }
    /**
	* 执行回调函数
	*/
    private function doCompFunc(compFunc : Dynamic, res : Dynamic, other : Dynamic) : Void
    {
        if (other != null) 
            compFunc(res, other)
        else 
        compFunc(res);
    }
    /**
	* 执行异步获取资源
	*/
    private function doGetResAsync(resolver : IResolver, key : String, compFunc : Dynamic, other : Dynamic) : Void
    {
        resolver.getResAsync(key, function(data : Dynamic) : Void{
                    if (other != null) 
                        compFunc(data, other);
                    else 
						compFunc(data);
                });
    }
    /**
	* 一个加载项加载完成
	*/
    private function onDllItemComp(item : DllItem) : Void
    {
        var argsList : Array<Dynamic> = asyncDic.get(item.name);
        asyncDic.remove(item.name);
        var resolver : IResolver = getResolverByType(item.type);
        for (args in argsList)
        {
            doGetResAsync(resolver, args.key, args.compFunc, args.other);
        }
    }
    /**
	* 销毁某个资源文件的二进制数据,返回是否删除成功。
	* 注意：Dll通常是只缓存文件字节流数据(占内存很少),而解码后的对像采用的是动态缓存，
	* 在外部引用都断开时能自动回收,所以不需要显式销毁它们。
	* @param name 配置文件中加载项的name属性或资源组名
	*/
    public function destroyRes(name : String) : Bool
    {
        var group : Array<DllItem> = this.dllConfig.getGroupByName(name);
        if (group != null) 
		{
            var index : Int = this.loadedGroups.indexOf(name);
            if (index != -1) {
                this.loadedGroups.splice(index, 1);
            }
            var length : Int = group.length;
            for (i in 0...length)
			{
                var item : DllItem = group[i];
                item.loaded = false;
                var analyzer : IResolver = this.getResolverByType(item.type);
                analyzer.destroyRes(item.name);
            }
            return true;
        }
        else
		{
            var type : String = this.dllConfig.getType(name);
            if (type == "") 
                return false;
            var item : DllItem = this.dllConfig.getDllItem(name);
            item.loaded = false;
            var analyzer : IResolver = this.getResolverByType(type);
            return analyzer.destroyRes(name);
        }
    }
}
