package flexlite.dll.resolvers;



import flash.NativeXml.Xml;
import flash.utils.ByteArray;

/**
* XML文件解析器
* @author weilichuang
*/
class XmlResolver extends BinResolver
{
    /**
	* 构造函数
	*/
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
			
        var bytes : ByteArray = fileDic.get(key);
        if (bytes == null) 
            return null;
        bytes.position = 0;
        var resultStr : String = bytes.readUTFBytes(bytes.length);
        var xml : Xml = null;
        try
        {
            xml = Xml.parse(resultStr);
        }      
		catch (e : String)
		{ 
			
		}
        sharedMap.set(key, xml);
        return xml;
    }
}
