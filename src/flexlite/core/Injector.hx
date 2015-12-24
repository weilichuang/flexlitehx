package flexlite.core;

import haxe.ds.StringMap;

/**
 * 全局注入管理器，在项目中可以通过此类向框架内部注入指定的类，从而定制或者扩展部分模块的功能。<p/>
 * 以下类若有调用，需要显式注入：<br>
 * IBitmapDecoder:DXR位图动画所用的解码器实例<br>
 * IBitmapEncoder:DXR位图动画所用的编码器实例<br>
 * ISkinAdapter:皮肤解析适配器实例。<br>
 * Theme:皮肤默认主题。<br>
 * IResolover:资源管理器调用的文件解析类实例。
 * @author weilichuang
 */
class Injector
{
	/**
* 储存类的映射规则
*/		
	private static var mapClassDic:StringMap<Class<Dynamic>> = new StringMap<Class<Dynamic>>();
	
	private static var mapValueDic:StringMap<Dynamic> = new StringMap<Dynamic>();
	
	/**
* 以类定义为值进行映射注入，只有第一次请求它的单例时才会被实例化。
* @param whenAskedFor 传递类定义或类完全限定名作为需要映射的键。
* @param instantiateClass 传递类作为需要映射的值，它的构造函数必须为空。若不为空，请使用Injector.mapValue()方法直接注入实例。
* @param named 可选参数，在同一个类作为键需要映射多条规则时，可以传入此参数区分不同的映射。在调用getInstance()方法时要传入同样的参数。
*/		
	public static function mapClass(whenAskedFor:Dynamic, instantiateClass:Class<Dynamic>, named:String = ""):Void
	{
		var requestName:String = getKey(whenAskedFor)+"#"+named;
		mapClassDic.set(requestName,instantiateClass);
	}
	
	/**
	* 获取完全限定类名
	*/		
	private static function getKey(hostComponentKey:Dynamic):String
	{
		if(Std.is(hostComponentKey,String))
			return cast hostComponentKey;
			
		return Type.getClassName(hostComponentKey);
		//getQualifiedClassName(hostComponentKey);
	}
	
	
	
	/**
* 以实例为值进行映射注入,当请求单例时始终返回注入的这个实例。
* @param whenAskedFor 传递类定义或类的完全限定名作为需要映射的键。
* @param useValue 传递对象实例作为需要映射的值。
* @param named 可选参数，在同一个类作为键需要映射多条规则时，可以传入此参数区分不同的映射。在调用getInstance()方法时要传入同样的参数。
*/		
	public static function mapValue(whenAskedFor:Dynamic, useValue:Dynamic, named:String = ""):Void
	{
		var requestName:String = getKey(whenAskedFor) + "#" + named;
		mapValueDic.set(requestName, useValue);
	}
	/**
* 检查指定的映射规则是否存在
* @param whenAskedFor 传递类定义或类的完全限定名作为需要映射的键。
* @param named 可选参数，在同一个类作为键需要映射多条规则时，可以传入此参数区分不同的映射。
*/		
	public static function hasMapRule(whenAskedFor:Dynamic, named:String = ""):Bool
	{
		var requestName:String = getKey(whenAskedFor) + "#" + named;
		if(mapValueDic.exists(requestName) || mapClassDic.exists(requestName))
		{
			return true;
		}
		return false;
	}
	/**
* 获取指定类映射的单例
* @param clazz 类定义或类的完全限定名
* @param named 可选参数，若在调用mapClass()映射时设置了这个值，则要传入同样的字符串才能获取对应的单例
*/		
	public static function getInstance(clazz:Dynamic, named:String = ""):Dynamic
	{
		var requestName:String = getKey(clazz) + "#" + named;
		if(mapValueDic.exists(requestName))
			return mapValueDic.get(requestName);
			
		var returnClass:Class<Dynamic> = mapClassDic.get(requestName);
		if(returnClass != null)
		{
			var instance:Dynamic = Type.createInstance(returnClass, []);

			mapValueDic.set(requestName, instance);
			
			mapClassDic.remove(requestName);
			
			return instance;
		}
		throw "调用了未配置的注入规则！Class#named:" + requestName+"。 请先在项目初始化里配置指定的注入规则，再调用对应单例。";
	}
}