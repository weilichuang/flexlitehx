package flexlite.core;


import flash.utils.Dictionary;
import haxe.ds.StringMap;


/**
* 主题管理类。
* 在子类调用mapSkin()方法为每个组件映射默认的皮肤。
* @author weilichuang
*/
class Theme
{
    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    /**
	* 储存类的映射规则
	*/
    private var skinNameDic : StringMap<Dynamic>;
    
    /**
	* 为指定的组件映射默认皮肤。
	* @param hostComponentKey 传入组件实例，类定义或完全限定类名。
	* @param skinClass 传递类定义作为需要映射的皮肤，它的构造函数必须为空。
	* @param named 可选参数，当需要为同一个组件映射多个皮肤时，可以传入此参数区分不同的映射。在调用getInstance()方法时要传入同样的参数。
	*/
    public function mapSkin(hostComponentKey : Dynamic, skinName : Dynamic, named : String = "") : Void
    {
        var requestName : String = getKey(hostComponentKey) + "#" + named;
        
        if (skinNameDic == null) 
        {
            skinNameDic = new StringMap<Dynamic>();
        }
		skinNameDic.set(requestName, skinName);
    }
    /**
	* 获取完全限定类名
	*/
    private function getKey(hostComponentKey : Dynamic) : String
    {
        if (Std.is(hostComponentKey, String)) 
            return cast hostComponentKey;
			
		if (Std.is(hostComponentKey, Class))
		{
			return Type.getClassName(hostComponentKey);
		}
		else
		{
			return Type.getClassName(Type.getClass(hostComponentKey));
		}
    }
    
    /**
	* 获取指定类映射的实例
	* @param hostComponentKey 组件实例,类定义或完全限定类名
	* @param named 可选参数，若在调用mapClass()映射时设置了这个值，则要传入同样的字符串才能获取对应的实例
	*/
    public function getSkinName(hostComponentKey : Dynamic, named : String = "") : Dynamic
    {
        var requestName : String = getKey(hostComponentKey) + "#" + named;
        if (skinNameDic != null) 
        {
            return skinNameDic.get(requestName);
        }
        return null;
    }
}
