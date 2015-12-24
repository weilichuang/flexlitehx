package flexlite.components.supportclasses;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.PixelSnapping;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import flexlite.core.ISkinAdapter;


/**
* 默认的ISkinAdapter接口实现
* @author weilichuang
*/
class DefaultSkinAdapter implements ISkinAdapter
{
    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
	
    /**
	* @inheritDoc
	*/
    public function getSkin(skinName : Dynamic, compFunc : Dynamic->Dynamic->Void, oldSkin : DisplayObject = null) : Void
    {
        if (Std.is(skinName, Class)) 
        {
            compFunc(Type.createInstance(skinName, []), skinName);
        }
        else if (Std.is(skinName, String) || Std.is(skinName, ByteArray)) 
        {
            var loader : Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(event : Event) : Void{
                        compFunc(skinName, skinName);
                    });
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(event : Event) : Void{
                        if (Std.is(loader.content, Bitmap)) 
                        {
                            var bitmapData : BitmapData = (cast(loader.content, Bitmap)).bitmapData;
                            compFunc(new Bitmap(bitmapData, PixelSnapping.AUTO, true), skinName);
                        }
                        else 
                        {
                            compFunc(loader.content, skinName);
                        }
                    });
            if (Std.is(skinName, String)) 
                loader.load(new URLRequest(cast(skinName, String)));
            else 
				loader.loadBytes(cast skinName);
        }
        else if (Std.is(skinName, BitmapData)) 
        {
            var skin : Bitmap;
            if (Std.is(oldSkin, Bitmap)) 
            {
                skin = cast oldSkin;
                skin.bitmapData = cast skinName;
            }
            else 
            {
                skin = new Bitmap(cast skinName, PixelSnapping.AUTO, true);
            }
            compFunc(skin, skinName);
        }
        else 
        {
            compFunc(skinName, skinName);
        }
    }
}
