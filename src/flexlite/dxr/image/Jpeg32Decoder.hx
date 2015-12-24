package flexlite.dxr.image;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.geom.Point;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;

import flexlite.dxr.codec.IBitmapDecoder;


/**
* Jpeg32位图解码器
* @author weilichuang
*/
class Jpeg32Decoder implements IBitmapDecoder
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
        return "jpeg32";
    }
    
    /**
	* 回调函数字典
	*/
    private var onCompDic : ObjectMap<Loader,BitmapData->Void> = new ObjectMap<Loader,BitmapData->Void>();
    /**
	* 透明通道字典类
	*/
    private var alphaBlockDic : ObjectMap<Loader,ByteArray> = new ObjectMap<Loader,ByteArray>();
    /**
	* @inheritDoc
	*/
    public function decode(bytes : ByteArray, onComp : BitmapData->Void) : Void
    {
        var fBlock : ByteArray = bytes;
        fBlock.position = 0;
        var aLength : Int = fBlock.readUnsignedInt();
        var aBlock : ByteArray = new ByteArray();
        var bBlock : ByteArray = new ByteArray();
        fBlock.readBytes(aBlock, 0, aLength);
        fBlock.readBytes(bBlock, 0);
        
        var loader : Loader = new Loader();
        var loaderContext : LoaderContext = new LoaderContext();
        if (Reflect.hasField(loaderContext,"imageDecodingPolicy"))               //如果是FP11以上版本，开启异步位图解码  
			Reflect.setField(loaderContext, "imageDecodingPolicy", "onLoad");
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComp);
        if (onCompDic == null) 
            onCompDic = new ObjectMap<Loader,BitmapData->Void>();
        onCompDic.set(loader, onComp);
        alphaBlockDic.set(loader, aBlock);
        loader.loadBytes(bBlock, loaderContext);
    }
    
    /**
	* 解码字节流完成
	*/
    private function onLoadComp(event : Event) : Void
    {
        var loader : Loader = (cast(event.target, LoaderInfo)).loader;
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComp);
        var bitmapData : BitmapData = (cast(loader.content, Bitmap)).bitmapData;
        var aBlock : ByteArray = alphaBlockDic.get(loader);
        bitmapData = writeAlphaToBitmapData(aBlock, bitmapData);  //合并alpha通道  
        
        if (onCompDic.get(loader) != null) 
        {
            onCompDic.get(loader)(bitmapData);
        }
        onCompDic.remove(loader);
        alphaBlockDic.remove(loader);
    }
    
    /**
	* 将alpha数据块写入bitmapData 
	* @param alphaDataBlock alpha通道数据块
	* @param bitmapData 位图数据
	*/
    private static function writeAlphaToBitmapData(alphaDataBlock : ByteArray, bitmapData : BitmapData) : BitmapData
    {
        var retBitmapData : BitmapData = null;
        alphaDataBlock.uncompress();
        alphaDataBlock.position = 0;
        if (alphaDataBlock.readUTF() == "alphaBlock") 
        {
            var alphaBitmapData : BitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0);
            retBitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0);
            alphaBitmapData.setPixels(retBitmapData.rect, alphaDataBlock);
            retBitmapData.copyPixels(bitmapData, bitmapData.rect, new Point(), alphaBitmapData, new Point(), true);
        }
        return retBitmapData;
    }
}
