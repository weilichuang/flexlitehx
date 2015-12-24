package flexlite.dxr.codec;


import flash.display.BitmapData;
import flash.display.FrameLabel;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flexlite.core.Injector;
import flexlite.dxr.codec.IBitmapDecoder;
import flexlite.dxr.DxrData;
import flexlite.dxr.image.Jpeg32Decoder;
import flexlite.dxr.image.PngDecoder;






/**
* DXR动画解码器
* @author weilichuang
*/
class DxrDecoder
{
    /**
	* 构造函数
	*/
    public function new()
    {
        if (!injected) 
        {
            injected = true;
            doInject();
        }
    }
    
    private static var injected : Bool = false;
    /**
	* 执行位图解码器注入
	*/
    private static function doInject() : Void
    {
        if (!Injector.hasMapRule(IBitmapDecoder, "png")) 
            Injector.mapClass(IBitmapDecoder, PngDecoder, "png");
        if (!Injector.hasMapRule(IBitmapDecoder, "jpegxr")) 
            Injector.mapClass(IBitmapDecoder, PngDecoder, "jpegxr");
        if (!Injector.hasMapRule(IBitmapDecoder, "jpeg32")) 
            Injector.mapClass(IBitmapDecoder, Jpeg32Decoder, "jpeg32");
    }
    /**
	* 解码完成回调函数
	*/
    private var compFunc : DxrData->Void;
    /**
	* 位图解码器
	*/
    private var bitmapDecoder : IBitmapDecoder;
    /**
	* dxr原始数据
	*/
    private var dxrSourceData : Dynamic;
    /**
	* 解码完成的DxrData对象
	*/
    private var dxrData : DxrData;
    /**
	* 当前加载到的位图序号
	*/
    private var currentIndex : Int;
    /**
	* 解码后的位图列表
	*/
    private var bitmapDataList : Array<BitmapData>;
    /**
	* 将一个Dxr动画数据解码为DxrData对象
	* @param data 要解码的原始数据
	* @param key 动画导出键名
	* @param onComp 解码完成回调函数，示例：onComp(data:DxrData);
	*/
    public function decode(data : Dynamic, key : String, onComp : DxrData->Void) : Void
    {
        dxrData = new DxrData(key, data.codec);
        compFunc = onComp;
        currentIndex = 0;
        dxrSourceData = data;
        bitmapDataList = new Array<BitmapData>();
        this.bitmapDecoder = Injector.getInstance(IBitmapDecoder, dxrData.codecKey);
        addToDecodeList(this);
    }
    /**
	* 解码下一张位图
	*/
    private function next() : Void
    {
        if (currentIndex >= Reflect.field(Reflect.field(dxrSourceData, "bitmapList"), "length")) 
            allComp()
        else 
        decodeOneBitmap();
    }
    /**
	* 解码一张位图
	*/
    private function decodeOneBitmap() : Void
    {
        bitmapDecoder.decode(cast(Reflect.field(dxrSourceData, "bitmapList")[currentIndex], ByteArray), onOneComp);
    }
    /**
	* 一张位图解码完成
	*/
    private function onOneComp(data : BitmapData) : Void
    {
        bitmapDataList.push(data);
        currentIndex++;
        next();
    }
    /**
	* 所有位图序列解码完成
	*/
    private function allComp() : Void
    {
        var bd : BitmapData;
        var rect : Rectangle;
		
		var frameInfos:Array<Array<Dynamic>> = dxrSourceData.frameInfo;
        for (info in frameInfos)
        {
            if (info.length == 10) 
            {
                var copyFromIndex : Int = info[9];
                bd = dxrData.frameList[copyFromIndex];
            }
            else 
            {
                bd = new BitmapData(info[3], info[4], true, 0);
                rect = new Rectangle(info[1], info[2], info[3], info[4]);
                bd.copyPixels(bitmapDataList[info[0]], rect, new Point(0, 0), null, null, true);
            }
            dxrData.frameList.push(bd);
            dxrData.frameOffsetList.push(new Point(info[5], info[6]));
            if (info.length >= 9) 
            {
                dxrData.filterOffsetList[dxrData.frameList.length - 1] = new Point(info[7], info[8]);
            }
        }
        if (Reflect.hasField(dxrSourceData,"scale9Grid")) 
        {
            var sg : Array<Float> = cast dxrSourceData.scale9Grid;
            dxrData.initScale9Grid();
            dxrData.scale9Grid.left = sg[0];
            dxrData.scale9Grid.top = sg[1];
            dxrData.scale9Grid.right = sg[2];
            dxrData.scale9Grid.bottom = sg[3];
        }
        
        if (dxrSourceData.exists("frameLabels")) 
        {
            var fls : Array<Dynamic> = cast dxrSourceData.frameLabels;
            for (label in fls)
            {
                dxrData.frameLabels.push(new FrameLabel(label[1], label[0]));
            }
        }
        if (compFunc != null) 
        {
            compFunc(dxrData);
        }
        dxrData = null;
        compFunc = null;
        currentIndex = 0;
        dxrSourceData = null;
        bitmapDataList = null;
    }
    
    /**
	* Timer事件抛出者
	*/
    private static var timer : Timer = new Timer(40);
    /**
	* 待解码列表
	*/
    private static var decodeList : Array<DxrDecoder> = new Array<DxrDecoder>();
    /**
	* 添加到待解码队列
	*/
    private static function addToDecodeList(decoder : DxrDecoder) : Void
    {
        if (decodeList.indexOf(decoder) != -1) 
            return;
        decodeList.push(decoder);
        if (decodeList.length == 1) 
        {
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            timer.start();
        }
    }
    /**
	* 每帧最大解码字节流总大小
	*/
    public static var maxDecodeLength : Int = 5000;
    /**
	* Timer事件处理函数
	*/
    private static function onTimer(event : TimerEvent) : Void
    {
        var max : Int = maxDecodeLength;
        var total : Int = 0;
        while (total < max && decodeList.length > 0)
        {
            var decoder : DxrDecoder = decodeList.shift();
            decoder.next();
			
			var bitmapList:Array<ByteArray> = decoder.dxrSourceData.bitmapList;
            for (byte in bitmapList)
            {
                total += byte.length;
            }
        }
        if (decodeList.length == 0) 
        {
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER, onTimer);
            timer.reset();
        }
    }
    
    /**
	* 从字节流数据中读取文件信息描述对象
	* @param data 文件的字节流数据
	*/
    public static function readObject(data : ByteArray) : Dynamic
    {
        if (data == null) 
        {
            Lib.trace("DXR动画文件字节流为空！");
        }
        try
        {
            data.position = 0;
            var version : String = data.readUTF();
            var compressStr : String = data.readUTF();
            var dxrBytes : ByteArray = new ByteArray();
            data.readBytes(dxrBytes);
            if (compressStr != "false") 
            {
                if (compressStr == "zlib") 
                    dxrBytes.uncompress()
                else 
                Reflect.field(dxrBytes, "uncompress")(compressStr);
            }
            var keyObject : Dynamic = dxrBytes.readObject();
            if (Reflect.field(keyObject, "keyList") == null) 
            {
                throw "dont have keyList";
            }
            return keyObject;
        }       
		catch (e : String)
        {
            Lib.trace("不是有效的DXR动画文件！");
        }
        return null;
    }
}
