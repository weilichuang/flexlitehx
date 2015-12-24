package flexlite.dxr.codec;


import flash.display.BitmapData;
import flash.utils.ByteArray;

/**
* 
* @author weilichuang
*/
interface IBitmapDecoder
{
    
    
    /**
	* 编解码器标识符
	*/
    var codecKey(get, never) : String;

    /**
	* 将字节流数据解码为位图数组
	* @param byteArray 要解码的字节流数据
	* @param onComp 解码完成回调函数，示例：onComp(data:BitmapData);
	*/
    function decode(byteArray : ByteArray, onComp : BitmapData->Void) : Void;
}
