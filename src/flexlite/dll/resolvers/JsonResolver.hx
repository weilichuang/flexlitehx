package flexlite.dll.resolvers;
import flash.utils.ByteArray;
import haxe.Json;

/**
 * ...
 * @author weilichuang
 */
class JsonResolver extends BinResolver
{

	public function new() 
	{
		super();
		
	}
	
	override public function getRes(key:String):Dynamic
	{
		if (sharedMap.has(key))
			return sharedMap.get(key);
			
		var bytes:ByteArray = fileDic.get(key);
		if (bytes == null)
			return null;
			
		bytes.position = 0;
		var resultStr:String = bytes.readUTFBytes(bytes.length);
		var data:Dynamic = null;
		try
		{
			data = Json.parse(resultStr);
		}
		catch (e:String)
		{
		}
		sharedMap.set(key, data);
		return data;
	}
	
}