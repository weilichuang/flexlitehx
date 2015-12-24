package flexlite.states;



import flash.events.Event;
import flash.events.EventDispatcher;
import flexlite.core.IStateClient;


@:meta(DXML(show="false"))


@:meta(DefaultProperty(name="overrides",array="true"))


/**
* State 类定义视图状态，即组件的特定视图。
* @author weilichuang
*/
class State extends EventDispatcher
{
    public function new(properties : Dynamic = null)
    {
        super();
		
		if (properties != null)
		{
			var fields:Array<String> = Reflect.fields(properties);
			for (p in fields)
			{
				Reflect.setField(this, p, Reflect.field(properties,p));
			}
		}
    }
    /**
	* 已经初始化标志 
	*/
    private var initialized : Bool = false;
    /**
	* 该视图状态所基于的视图状态的名称；
	* 如果该视图状态不是基于已命名的视图状态，则为 null。
	* 如果该值为 null，则该视图状态基于根状态（包括不是使用 State 类为组件定义的属性、样式、事件处理函数和子项）。 
	*/
    public var basedOn : String;
    
    /**
	* 视图状态的名称。给定组件的状态名称必须唯一。必须设置此属性。
	*/
    public var name : String;
    
    /**
	* 该视图状态的覆盖，表现为实现 IOverride 接口的对象的数组。
	* 这些覆盖在进入状态时按顺序应用，在退出状态时按相反的顺序删除。 
	*/
    public var overrides : Array<IOverride> = [];
    /**
	* 此视图状态作为 String 数组所属的状态组。 
	*/
    public var stateGroups : Array<Dynamic> = [];
    /**
	* 初始化视图
	*/
    public function initialize(parent : IStateClient) : Void
    {
        if (!initialized) 
        {
            initialized = true;
            for (i in 0...overrides.length)
			{
                overrides[i].initialize(parent);
            }
        }
    }
    /**
	* 抛出进入视图状态事件
	*/
    public function dispatchEnterState() : Void
    {
        if (hasEventListener("enterState")) 
            dispatchEvent(new Event("enterState"));
    }
    /**
	* 抛出即将退出视图状态事件
	*/
    public function dispatchExitState() : Void
    {
        if (hasEventListener("exitState")) 
            dispatchEvent(new Event("exitState"));
    }
}


