package flexlite.dll.resolvers;


import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

import flexlite.dll.core.DllItem;
import flexlite.dll.core.IResolver;


/**
* 声音文件解析器
* @author weilichuang
*/
class SoundResolver implements IResolver
{
    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    /**
	* Sound对象缓存字典
	*/
    private var soundDic : StringMap<Sound> = new StringMap<Sound>();
    /**
	* 加载项字典
	*/
    private var dllItemDic : ObjectMap<Sound,Dynamic> = new ObjectMap<Sound,Dynamic>();
    /**
	* @inheritDoc
	*/
    public function loadFile(dllItem : DllItem, compFunc : Dynamic, progressFunc : Dynamic) : Void
    {
        if (soundDic.exists(dllItem.name)) 
        {
            compFunc(dllItem);
            return;
        }
        if (dllItem.groupName == null) 
        {
            var sound : Sound = new Sound();
            sound.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
            sound.load(new URLRequest(dllItem.url));
            soundDic.set(dllItem.name, sound);
            dllItem.loaded = true;
            compFunc(dllItem);
            return;
        }
        var loader : Sound = new Sound();
        loader.addEventListener(Event.COMPLETE, onLoadFinish);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFinish);
        loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
        dllItemDic.set(loader, {
            item : dllItem,
            func : compFunc,
            progress : progressFunc,

        });
        loader.load(new URLRequest(dllItem.url));
    }
    /**
	* 防止加载不到音乐文件而报错
	*/
    private function onIoError(event : Event) : Void
    {
        
    }
    /**
	* 此方法无效,Sound在低版本的Flash Player上不能通过字节流加载。
	*/
    public function loadBytes(bytes : ByteArray, name : String) : Void
    {
        
    }
    /**
	* 加载进度事件
	*/
    private function onProgress(event : ProgressEvent) : Void
    {
        var loader : Sound = cast(event.target, Sound);
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
        var loader : Sound = cast(event.target, Sound);
        loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadFinish);
        loader.removeEventListener(Event.COMPLETE, onLoadFinish);
        loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        var data : Dynamic = dllItemDic.get(loader);
        dllItemDic.remove(loader);
        var dllItem : DllItem = data.item;
        var compFunc : Dynamic = data.func;
        dllItem.loaded = (event.type == Event.COMPLETE);
        if (dllItem.loaded) 
        {
            if (!soundDic.exists(dllItem.name)) 
            {
                soundDic.set(dllItem.name, loader);
            }
        }
        compFunc(dllItem);
    }
	
    /**
	* @inheritDoc
	*/
    public function getRes(key : String) : Dynamic
    {
        return soundDic.get(key);
    }
    /**
	* @inheritDoc
	*/
    public function getResAsync(key : String, compFunc : Dynamic) : Void
    {
        if (compFunc == null) 
            return;
        var res : Sound = getRes(key);
        compFunc(res);
    }
	
    /**
	* @inheritDoc
	*/
    public function hasRes(name : String) : Bool
    {
        return soundDic.get(name) != null;
    }
	
    /**
	* @inheritDoc
	*/
    public function destroyRes(name : String) : Bool
    {
        if (soundDic.exists(name)) 
        {
            soundDic.remove(name);
            return true;
        }
        return false;
    }
}
