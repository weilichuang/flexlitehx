package flexlite.dxr.image;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;

import flexlite.dxr.codec.IBitmapDecoder;


/**
* PNG位图解码器,此解码器同样适用于其他所有普通位图解码。比如jpegxr。
* @author weilichuang
*/
class PngDecoder implements IBitmapDecoder
{
    public var codecKey(get, never) : String;

    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    /**
	* @inheritDoc
	*/
    private function get_codecKey() : String
    {
        return "png";
    }
    
    private var onCompDic : ObjectMap<Loader,BitmapData->Void>;
    /**
	* @inheritDoc
	*/
    public function decode(byteArray : ByteArray, onComp : BitmapData->Void) : Void
    {
        var loader : Loader = new Loader();
        var loaderContext : LoaderContext = new LoaderContext();
        if (Reflect.hasField(loaderContext,"imageDecodingPolicy"))               //如果是FP11以上版本，开启异步位图解码  
			Reflect.setField(loaderContext, "imageDecodingPolicy", "onLoad");
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComp);
        if (onCompDic == null) 
            onCompDic = new ObjectMap<Loader,BitmapData->Void>();
        onCompDic.set(loader, onComp);
        loader.loadBytes(byteArray, loaderContext);
    }
    /**
	* 解码完成
	*/
    private function onLoadComp(event : Event) : Void
    {
        var loader : Loader = (cast(event.target, LoaderInfo)).loader;
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComp);
        var bitmapData : BitmapData = (cast(loader.content, Bitmap)).bitmapData;
        if (onCompDic.get(loader) != null) 
        {
            onCompDic.get(loader)(bitmapData);
        }
        onCompDic.remove(loader);
    }
}
