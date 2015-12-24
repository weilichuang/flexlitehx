package flexlite.dll.resolvers;



import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

import flexlite.dll.core.DllItem;
import flexlite.dll.core.IResolver;
import flexlite.utils.SharedMap;

/**
* SWF素材文件解析器<br/>
* 在IOS下将swf加载到当前程序域。其他平台默认加载到子程序域。
* 若是共享的代码库，只能加载到当前域的，请使用RslResolver。
* @author weilichuang
*/
class SwfResolver implements IResolver
{
    /**
	* 构造函数
	*/
    public function new()
    {
        if (Capabilities.os.substr(0, 9) == "iPhone OS") 
            loadInCurrentDomain = true;
    }
    
    /**
	* Loader对象缓存字典
	*/
    private var swfDic : StringMap<Loader> = new StringMap<Loader>();
    /**
	* 程序域列表
	*/
    private var appDomainList : Array<ApplicationDomain> = [ApplicationDomain.currentDomain];
    /**
	* 解码后对象的共享缓存表
	*/
    private var sharedMap : SharedMap = new SharedMap();
    /**
	* 加载项字典
	*/
    private var dllItemDic : ObjectMap<Loader,Dynamic> = new ObjectMap<Loader,Dynamic>();
    /**
	* 在IOS系统中运行的标志
	*/
    private var loadInCurrentDomain : Bool = false;
    /**
	* @inheritDoc
	*/
    public function loadFile(dllItem : DllItem, compFunc : Dynamic, progressFunc : Dynamic) : Void
    {
        if (swfDic.exists(dllItem.name)) 
        {
            compFunc(dllItem);
            return;
        }
        var loader : Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadFinish);
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadFinish);
        loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
        dllItemDic.set(loader, {
            item : dllItem,
            func : compFunc,
            progress : progressFunc,
        });
        loadingCount++;
        if (loadInCurrentDomain) 
        {
            var loaderContext : LoaderContext = 
            new LoaderContext(false, ApplicationDomain.currentDomain);
            loader.load(new URLRequest(dllItem.url), loaderContext);
        }
        else 
        {
            loader.load(new URLRequest(dllItem.url));
        }
    }
    /**
	* 加载进度事件
	*/
    private function onProgress(event : ProgressEvent) : Void
    {
        var loader : Loader = (cast(event.target, LoaderInfo)).loader;
        var data : Dynamic = dllItemDic.get(loader);
        var dllItem : DllItem = data.item;
        var progressFunc : Dynamic = data.progress;
        progressFunc(event.bytesLoaded, dllItem);
    }
    /**
	* 一项加载结束
	*/
    private function onLoadFinish(event : Event) : Void
    {
        var loader : Loader = (cast(event.target, LoaderInfo)).loader;
        var data : Dynamic = dllItemDic.get(loader);
        dllItemDic.remove(loader);
        var dllItem : DllItem = data.item;
        var compFunc : Dynamic = data.func;
        dllItem.loaded = (event.type == Event.COMPLETE);
        if (dllItem.loaded) 
        {
            if (!swfDic.exists(dllItem.name)) 
            {
                swfDic.set(dllItem.name, loader);
                if (!loadInCurrentDomain) 
                    appDomainList.push(loader.contentLoaderInfo.applicationDomain);
            }
        }
        checkAsyncList();
        compFunc(dllItem);
    }
    /**
	* 正在加载的文件个数
	*/
    private var loadingCount : Int = 0;
    
    private var nameDic : Dictionary = new Dictionary();
    /**
	* @inheritDoc
	*/
    public function loadBytes(bytes : ByteArray, name : String) : Void
    {
        if (Reflect.field(swfDic, name) || bytes == null) 
            return;
        try
        {
            bytes.uncompress();
        }        
		catch (e : String)
		{
			
		}
        var loader : Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, checkAsyncList);
        Reflect.setField(nameDic, Std.string(loader), name);
        loadingCount++;
        var loaderContext : LoaderContext;
        if (loadInCurrentDomain) 
        {
            loaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
        }
        else 
        {
            loaderContext = new LoaderContext();
        }
        if (Reflect.hasField(loaderContext,"allowCodeImport")) 
            Reflect.setField(loaderContext, "allowCodeImport", true);
        loader.loadBytes(bytes, loaderContext);
    }
    
    /**
	* 解析完成
	*/
    private function bytesComplete(event : Event) : Void
    {
        var loader : Loader = (cast(event.target, LoaderInfo)).loader;
        var name : String = nameDic.get(loader);
        nameDic.remove(loader);
        swfDic.set(name, loader);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesComplete);
        if (!loadInCurrentDomain) 
            appDomainList.push(loader.contentLoaderInfo.applicationDomain);
        checkAsyncList();
    }
    /**
	* 加载结束
	*/
    private function checkAsyncList(event : IOErrorEvent = null) : Void
    {
        loadingCount--;
        if (loadingCount == 0) 
        {
            for (item/* AS3HX WARNING could not determine type for var: item exp: EIdent(asyncList) type: null */ in asyncList)
            {
                getResAsync(item.key, item.compFunc);
            }
            asyncList = [];
        }
    }
    /**
	* @inheritDoc
	*/
    public function getRes(key : String) : Dynamic
    {
        var res : Dynamic = swfDic.get(key);
        if (res != null) 
            return res;
        if (sharedMap.has(key)) 
            return sharedMap.get(key);
        for (domain in appDomainList)
        {
            if (domain.hasDefinition(key)) 
            {
                var clazz : Class<Dynamic> = Type.getClass(domain.getDefinition(key));
                sharedMap.set(key, clazz);
                return clazz;
            }
        }
        
        return null;
    }
    /**
	* 待加载队列
	*/
    private var asyncList : Array<Dynamic> = [];
    /**
	* @inheritDoc
	*/
    public function getResAsync(key : String, compFunc : Dynamic) : Void
    {
        if (compFunc == null) 
            return;
        var res : Dynamic = getRes(key);
        if (res == null && loadingCount > 0) 
        {
            asyncList.push({
                        key : key,
                        compFunc : compFunc,

                    });
        }
        else 
        {
            compFunc(res);
        }
    }
    /**
	* @inheritDoc
	*/
    public function hasRes(name : String) : Bool
    {
        return swfDic.exists(name);
    }
    /**
	* @inheritDoc
	*/
    public function destroyRes(name : String) : Bool
    {
        if (swfDic.exists(name)) 
        {
            if (!loadInCurrentDomain) 
            {
                var domain : ApplicationDomain = swfDic.get(name).contentLoaderInfo.applicationDomain;
                for (i in 0...0)
				{
                    if (appDomainList[i] == domain) 
                    {
                        appDomainList.splice(i, 1);
                        break;
                    }
                }
            }
            swfDic.remove(name);
            return true;
        }
        return false;
    }
}
