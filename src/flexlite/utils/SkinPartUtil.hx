package flexlite.utils;


import flash.utils.Dictionary;
import haxe.ds.StringMap;
import haxe.rtti.Meta;


import flexlite.components.SkinnableComponent;

@:meta(ExcludeClass())

/**
* 获取皮肤定义的公开属性名工具类

*/
class SkinPartUtil
{
    /**
	* skinPart缓存字典
	*/
    private static var skinPartCache : StringMap<Array<String>> = new StringMap<Array<String>>();

	/**
	 * 从一个Skin或其子类的实例里获取皮肤定义的公开属性名列表
	 */	
	public static function getSkinParts<T>(host : SkinnableComponent):Array<String>
	{
		var cls:Class<Dynamic> = Type.getClass(host);
		
		var key : String = Type.getClassName(cls);
        if (skinPartCache.exists(key)) 
        {
            return skinPartCache.get(key);
        }
		
		var skinParts:Array<String> = [];
		
		internalGetSkinParts(cls, skinParts);
		
		skinPartCache.set(key, skinParts);
		
		return skinParts;
	}
	
	private static function internalGetSkinParts(cls:Class<Dynamic>, result:Array<String>):Void
	{
		var metaFields:Dynamic = Meta.getFields(cls);
		
		var fields:Array<Dynamic> = Reflect.fields(metaFields);
		
		for (key in fields)
		{
			var info:Dynamic = Reflect.field(metaFields, key);
			if (Reflect.hasField(info, "SkinPart"))
			{
				result.push(key);
			}
		}
		
		var superCls:Class<Dynamic> = Type.getSuperClass(cls);
		if (superCls != null)
		{
			internalGetSkinParts(superCls, result);
		}
	}
}
