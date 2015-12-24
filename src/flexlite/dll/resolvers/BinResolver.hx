package flexlite.dll.resolvers;



import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flexlite.dxr.DxrFile;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

import flexlite.dll.core.DllItem;
import flexlite.dll.core.IResolver;
import flexlite.utils.Recycler;
import flexlite.utils.SharedMap;
/**
* 二进制文件解析器<br/>
* 直接返回文件二进制字节流。若文件是"zlib"方式压缩的，缓存时会先解压它。
* @author weilichuang
*/
class BinResolver implements IResolver
{
    /**
	* 构造函数
	*/
    public function new()
    {
    }
    
    /**
	* 字节流数据缓存字典
	*/
    private var fileDic : StringMap<Dynamic> = new StringMap<Dynamic>();
    /**
	* 解码后对象的共享缓存表
	*/
    private var sharedMap : SharedMap = new SharedMap();
    /**
	* 加载项字典
	*/
    private var dllItemDic : ObjectMap<URLLoader,Dynamic> = new ObjectMap<URLLoader,Dynamic>();
    /**
	* @inheritDoc
	*/
    public function loadFile(dllItem : DllItem, compFunc : Dynamic, onProgress : Dynamic) : Void
    {
        if (fileDic.get(dllItem.name) != null) 
        {
            compFunc(dllItem);
            return;
        }
        var loader : URLLoader = getLoader();
        dllItemDic.set(loader, {
            item : dllItem,
            func : compFunc,
            progress : onProgress,

        });
        loader.load(new URLRequest(dllItem.url));
    }
    /**
	* URLLoader对象池
	*/
    private var recycler : Recycler = new Recycler();
    /**
	* 获取一个URLLoader对象
	*/
    private function getLoader() : URLLoader
    {
        var loader : URLLoader = recycler.get();
        if (loader == null) 
        {
            loader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
            loader.addEventListener(Event.COMPLETE, onLoadFinish);
            loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFinish);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFinish);
        }
        return loader;
    }
    /**
	* 加载进度
	*/
    private function onProgress(event : ProgressEvent) : Void
    {
        var loader : URLLoader = cast(event.target, URLLoader);
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
        compFunc(dllItem);
    }
    /**
	* @inheritDoc
	*/
    public function loadBytes(bytes : ByteArray, name : String) : Void
    {
        if (fileDic.get(name) != null || bytes == null) 
            return;
        try
        {
            bytes.uncompress();
        }        
		catch (e : String)
		{ 
			
		}
        fileDic.set(name, bytes);
    }
    /**
	* @inheritDoc
	*/
    public function getRes(key : String) : Dynamic
    {
        return fileDic.get(key);
    }
    /**
	* @inheritDoc
	*/
    public function getResAsync(key : String, compFunc : Dynamic) : Void
    {
        if (compFunc == null) 
            return;
        var res : Dynamic = getRes(key);
        compFunc(res);
    }
    /**
	* @inheritDoc
	*/
    public function hasRes(name : String) : Bool
    {
        return fileDic.get(name) != null;
    }
    /**
	* @inheritDoc
	*/
    public function destroyRes(name : String) : Bool
    {
        if (fileDic.exists(name)) 
        {
            fileDic.remove(name);
            return true;
        }
        return false;
    }
}
