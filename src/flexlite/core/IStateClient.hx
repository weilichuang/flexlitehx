package flexlite.core;


import flash.events.IEventDispatcher;

/**
* 具有视图状态的组件接口
* @author weilichuang
*/
interface IStateClient extends IEventDispatcher
{
    
    
    
    /**
	* 组件的当前视图状态。将其设置为 "" 或 null 可将组件重置回其基本状态。 
	*/
    var currentState(get, set) : String;    
    
    
    
    /**
	* 为此组件定义的视图状态。
	*/
    var states(get, set) : Array<Dynamic>;

    
    /**
	* 返回是否含有指定名称的视图状态
	* @param stateName 要检测的视图状态名称
	*/
    function hasState(stateName : String) : Bool;
}
