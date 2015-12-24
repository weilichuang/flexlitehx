package flexlite.dll.resolvers;



import flash.display.Shape;
import flash.events.Event;
import flash.net.URLLoader;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import haxe.ds.StringMap;

import flexlite.core.Injector;
import flexlite.dll.core.DllItem;
import flexlite.dll.core.IResolver;

/**
* 组资源解析器<br/>
* 为了避免零碎文件造成的加载时间过长，可将预加载的资源组合并成一个字节流文件，通过此类加载并分拆。
* @author weilichuang
*/
class GrpResolver extends BinResolver
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    /**
	* name和subkey到解析器的映射表
	*/
    private var keyMap : StringMap<IResolver> = new StringMap<IResolver>();
    /**
	* EnterFrame事件抛出者
	*/
    private var eventDispatcher : Shape = new Shape();
    /**
	* 已经添加过事件监听的标志
	*/
    private var listenForEnterFrame : Bool = false;
    /**
	* 带回调列表
	*/
    private var completeList : Array<Dynamic> = [];
    /**
	* @inheritDoc
	*/
    override private function onLoadFinish(event : Event) : Void
    {
        var loader : URLLoader = cast(event.target, URLLoader);
        var data : Dynamic = dllItemDic.get(loader);
        dllItemDic.remove(loader);
        recycler.push(loader);
        var dllItem : DllItem = data.item;
        var compFunc : Dynamic = data.func;
        dllItem.loaded = (event.type == Event.COMPLETE);
        if (dllItem.loaded) 
        {
            loadBytes(loader.data, dllItem.name);
        }
        
        completeList.push({
                    compFunc : compFunc,
                    dllItem : dllItem,
                    count : 1,

                });
        if (!listenForEnterFrame) 
        {
            eventDispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            listenForEnterFrame = true;
        }
    }
    
    private function onEnterFrame(event : Event) : Void
    {
        var i : Int = completeList.length - 1;
        while (i >= 0){
            var data : Dynamic = completeList[i];
            data.count--;
            if (data.count < 0) 
            {
                completeList.splice(i, 1);
                data.compFunc(data.dllItem);
            }
            i--;
        }
        if (completeList.length == 0) 
        {
            eventDispatcher.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            listenForEnterFrame = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function loadBytes(bytes : ByteArray, name : String) : Void
    {
        if (keyMap.exists(name) || bytes == null) 
            return;
        try
        {
            bytes.uncompress();
        }        
		catch (e : String)
		{ 
			
		}
        bytes.position = 0;
        if (bytes.readUTF() != "dll") 
            return;
			
        var resList : Dynamic;
        try
        {
            resList = bytes.readObject();
        }        
		catch (e : String)
        {
            return;
        }
        keyMap.set(name, this);
        for (subName in Reflect.fields(resList))
        {
            if (keyMap.exists(subName)) 
                continue;
            var item : Dynamic = Reflect.field(resList, subName);
            var resolver : IResolver = getResolverByType(item.type);
            var subkeys : Array<String> = Std.string(item.subkeys).split(",");
            subkeys.push(subName);
            for (key in subkeys)
            {
                if (keyMap.get(key) != null) 
                    continue;
                keyMap.set(key, resolver);
            }
            resolver.loadBytes(item.bytes, subName);
        }
    }
    /**
	* @inheritDoc
	*/
    override public function getRes(key : String) : Dynamic
    {
        var resolver : IResolver = keyMap.get(key);
        if (resolver != null && resolver != this) 
            return resolver.getRes(key)
        else 
			return null;
    }
    /**
	* @inheritDoc
	*/
    override public function getResAsync(key : String, compFunc : Dynamic) : Void
    {
        var resolver : IResolver = keyMap.get(key);
        if (resolver != null && resolver != this) 
            resolver.getResAsync(key, compFunc)
        else 
        compFunc(null);
    }
    /**
	* @inheritDoc
	*/
    override public function hasRes(name : String) : Bool
    {
        return keyMap.get(name) != null;
    }
    /**
	* @inheritDoc
	*/
    override public function destroyRes(name : String) : Bool
    {
        var resolver : IResolver = keyMap.get(name);
        if (resolver != null && resolver != this) 
            return resolver.destroyRes(name)
        else 
        return false;
    }
    
    /**
	* 解析器字典
	*/
    private var resolverDic : Dictionary = new Dictionary();
    /**
	* 根据type获取对应的文件解析库
	*/
    private function getResolverByType(type : String) : IResolver
    {
        var resolver : IResolver = Reflect.field(resolverDic, type);
        if (resolver == null) 
		{
            resolver = Injector.getInstance(IResolver, type);
			resolverDic.set(type, resolver);
		}
        return resolver;
    }
}

