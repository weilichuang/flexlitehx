package flexlite.dxr;


import flash.utils.ByteArray;
import flash.utils.Dictionary;
import haxe.ds.StringMap;


import flexlite.dxr.codec.DxrDecoder;
import flexlite.dxr.codec.IBitmapDecoder;
import flexlite.utils.SharedMap;


/**
* DXR动画文件解析类
* @author weilichuang
*/
class DxrFile
{
    public var path(get, never) : String;

    /**
	* 构造函数
	* @param data DXR文件字节流数据
	*/
    public function new(data : ByteArray, path : String = "")
    {
        keyObject = DxrDecoder.readObject(data);
        if (keyObject == null) 
            keyObject = {
                    keyList : { }

                };
        this._path = path;
    }
    
    private var _path : String;
    
    /**
	* 文件路径
	*/
    private function get_path() : String
    {
        return _path;
    }
    
    /**
	* 位图解码器实例
	*/
    private var bitmapDecoder : IBitmapDecoder;
    
    /**
	* 获取动画导出键名列表
	*/
    public function getKeyList() : Array<String>
    {
        var keyList : Array<String> = new Array<String>();
        for (key in Reflect.fields(keyObject.keyList))
        {
            keyList.push(key);
        }
        return keyList;
    }
    
    private var keyObject : Dynamic;
    
    /**
	* 是否包含指定导出键名的动画
	* @param key 
	*/
    public function hasKey(key : String) : Bool
    {
        return Reflect.field(keyObject.keyList, key) != null;
    }
    
    /**
	* DxrData缓存表
	*/
    private var dxrDataMap : SharedMap = new SharedMap();
    /**
	* 回调函数字典
	*/
    private var compDic : StringMap<Array<Dynamic>> = new StringMap<Array<Dynamic>>();
    
    /**
	* 通过动画导出键名获取指定的DxrData动画数据
	* @param key 动画导出键名
	* @param onComp 结果回调函数，示例：onComp(data:DxrData):void,若设置了other参数则为:onComp(data,other):void
	* @param other 回调参数(可选),若设置了此参数，获取资源后它将会作为回调函数的第二个参数传入。
	*/
    public function getDxrData(key : String, onComp : Dynamic, other : Dynamic = null) : Void
    {
        if (onComp == null) 
            return;
        var dxr : DxrData = dxrDataMap.get(key);
        if (dxr != null) 
        {
            if (other == null) 
                onComp(dxr)
            else 
				onComp(dxr, other);
            return;
        }
        
        var data : Dynamic = Reflect.field(keyObject.keyList, key);
        if (data == null) 
        {
            if (other == null) 
                onComp(null)
            else 
				onComp(null, other);
            return;
        }
        if (compDic.exists(key)) 
        {
            compDic.get(key).push({
                        onComp : onComp,
                        other : other,

                    });
        }
        else 
        {
            compDic.set(key, [ { onComp : onComp, other : other} ]);
            var decoder : DxrDecoder = new DxrDecoder();
            decoder.decode(data, key, onGetDxrData);
        }
    }
    /**
	* 解析DxrData完成回调函数
	*/
    private function onGetDxrData(dxrData : DxrData) : Void
    {
        dxrDataMap.set(dxrData.key, dxrData);
        var compArr : Array<Dynamic> = compDic.get(dxrData.key);
        compDic.remove(dxrData.key);
        var other : Dynamic;
        for (data in compArr)
        {
            if (data.other == null) 
                data.onComp(dxrData)
            else 
				data.onComp(dxrData, data.other);
        }
    }
}
