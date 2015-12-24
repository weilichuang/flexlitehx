package flexlite.dll.resolvers;



import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

/**
* 图片文件解析器<br/>
* 由于图片如果直接缓存解码后的数据将会造成巨大的内存开销。 所以图片只缓存二进制数据，
* 需要使用时异步获取。即使把图片配置到预加载组里，也需要通过异步方式才能获取。
* @author weilichuang
*/
class ImgResolver extends BinResolver
{
    public function new()
    {
        super();
    }
    
    /**
	* @inheritDoc
	*/
    override public function getRes(key : String) : Dynamic
    {
        if (sharedMap.has(key)) 
            return sharedMap.get(key);
        return null;
    }
    
    /**
	* 回调函数字典类 
	*/
    private var compFuncDic : StringMap<Array<Dynamic>>;
    /**
	* 键名字典
	*/
    private var keyDic : ObjectMap<Loader,String>;
    
    /**
	* @inheritDoc
	*/
    override public function getResAsync(key : String, compFunc : Dynamic) : Void
    {
        if (sharedMap.has(key)) 
        {
            var res : Dynamic = sharedMap.get(key);
            if (compFunc != null) 
                compFunc(res);
        }
        else 
        {
            var bytes : ByteArray = fileDic.get(key);
            if (bytes != null) 
            {
                if (compFuncDic == null) 
                    compFuncDic = new StringMap<Array<Dynamic>>();
                var compFuncList : Array<Dynamic> = compFuncDic.get(key);
                if (compFuncList != null) 
                {
                    compFuncList.push(compFunc);
                    return;
                }
                compFuncList = [];
                compFuncList.push(compFunc);
				compFuncDic.set(key, compFuncList);
                
                var loader : Loader = new Loader();
                var loaderContext : LoaderContext = new LoaderContext();
                if (Reflect.hasField(loaderContext,"imageDecodingPolicy"))                       //如果是FP11以上版本，开启异步位图解码  
					Reflect.setField(loaderContext, "imageDecodingPolicy", "onLoad");
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesComplete);
                if (keyDic == null) 
                    keyDic = new ObjectMap<Loader,String>();
                keyDic.set(loader, key);
                loader.loadBytes(bytes, loaderContext);
            }
            else 
            {
                if (compFunc != null) 
                    compFunc(null);
            }
        }
    }
    
    /**
	* 图片解码完成
	*/
    private function bytesComplete(event : Event) : Void
    {
        var loader : Loader = cast(event.target, LoaderInfo).loader;
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesComplete);
        var key : String = keyDic.get(loader);
        keyDic.remove(loader);
        var compFuncList : Array<Dynamic> = compFuncDic.get(key);
        compFuncDic.remove(key);
        var bitmapData : BitmapData = null;
        try
        {
            bitmapData = cast(loader.content, Bitmap).bitmapData;
        }       
		catch (e : String)
		{ 
			
		}
        sharedMap.set(key, bitmapData);
		
        for (func in compFuncList)
        {
            if (func != null) 
                func(bitmapData);
        }
    }
}
