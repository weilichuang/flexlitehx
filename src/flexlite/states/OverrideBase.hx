package flexlite.states;


import flexlite.core.IContainer;
import flexlite.core.IStateClient;
import flexlite.utils.OnDemandEventDispatcher;

/**
* OverrideBase 类是视图状态所用的 override 类的基类。
* @author weilichuang
*/
class OverrideBase extends OnDemandEventDispatcher implements IOverride
{
    public function new()
    {
        super();
    }
    
    public function initialize(parent : IStateClient) : Void
    {
        
    }
    
    public function apply(parent : IContainer) : Void
    {
        
        
    }
    
    public function remove(parent : IContainer) : Void
    {
        
        
    }
    /**
	* 从对象初始化，这是一个便利方法
	*/
    public function initializeFromObject(properties : Dynamic) : Dynamic
    {
		var fields:Array<Dynamic> = Reflect.fields(properties);
        for (p in fields)
        {
			Reflect.setField(this, p, Reflect.field(properties, p));
        }
        
        return this;
    }
}

