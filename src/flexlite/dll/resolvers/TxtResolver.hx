package flexlite.dll.resolvers;


import flash.utils.ByteArray;

/**
* 文本文件解析器
* @author weilichuang
*/
class TxtResolver extends BinResolver
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
        var bytes : ByteArray = Reflect.field(fileDic, key);
        if (bytes == null) 
            return "";
        bytes.position = 0;
        return bytes.readUTFBytes(bytes.length);
    }
}
