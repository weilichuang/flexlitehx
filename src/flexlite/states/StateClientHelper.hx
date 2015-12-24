package flexlite.states;



import flash.Lib;
import flexlite.core.IContainer;
import flexlite.core.IStateClient;
import flexlite.events.StateChangeEvent;



@:meta(ExcludeClass())


/**
* 视图状态组件辅助工具类
* @author weilichuang
*/
class StateClientHelper
{
    public var states(get, set) : Array<Dynamic>;
    public var currentStateChanged(get, never) : Bool;
    public var currentState(get, set) : String;

    /**
	* 构造函数
	*/
    public function new(target : IStateClient)
    {
        this.target = target;
    }
    
    /**
	* 具有视图状态功能的目标实例
	*/
    private var target : IStateClient;
    
    private var _states : Array<Dynamic> = [];
    /**
	* 为此组件定义的视图状态。
	*/
    private function get_states() : Array<Dynamic>
    {
        return _states;
    }
    private function set_states(value : Array<Dynamic>) : Array<Dynamic>
    {
        if (_states == value) 
            return value;
        _states = value;
        _currentStateChanged = true;
        requestedCurrentState = _currentState;
        if (!hasState(requestedCurrentState)) 
        {
            requestedCurrentState = getDefaultState();
        }
        return value;
    }
    
    
    private var _currentStateChanged : Bool;
    /**
	* 当前视图状态发生改变的标志
	*/
    private function get_currentStateChanged() : Bool
    {
        return _currentStateChanged;
    }
    
    
    private var _currentState : String;
    /**
	* 存储还未验证的视图状态 
	*/
    private var requestedCurrentState : String;
    /**
	* 组件的当前视图状态。将其设置为 "" 或 null 可将组件重置回其基本状态。 
	*/
    private function get_currentState() : String
    {
        if (_currentStateChanged) 
            return requestedCurrentState;
        return (_currentState != null) ? _currentState : getDefaultState();
    }
    
    private function set_currentState(value : String) : String
    {
        if (value == null) 
            value = getDefaultState();
        if (value != currentState && value != null && currentState != null) 
        {
            requestedCurrentState = value;
            _currentStateChanged = true;
        }
        return value;
    }
    
    /**
	* 返回是否含有指定名称的视图状态
	* @param stateName 要检测的视图状态名称
	*/
    public function hasState(stateName : String) : Bool
    {
        if (_states == null) 
            return false;
			
        if (Std.is(_states[0], String)) 
            return _states.indexOf(stateName) != -1;
			
        return getState(stateName) != null;
    }
    
    /**
	* 返回默认状态
	*/
    private function getDefaultState() : String
    {
        if (_states != null && _states.length > 0) 
        {
            var state : Dynamic = _states[0];
            if (Std.is(state, String)) 
                return state;
            return state.name;
        }
        return null;
    }
    /**
	* 应用当前的视图状态
	*/
    public function commitCurrentState() : Void
    {
        if (!currentStateChanged) 
            return;
        _currentStateChanged = false;
        if (states != null && Std.is(states[0], String)) 
        {
            if (states.indexOf(requestedCurrentState) == -1) 
                _currentState = getDefaultState()
            else 
				_currentState = requestedCurrentState;
            return;
        }
        var destination : State = getState(requestedCurrentState);
        if (destination == null) 
        {
            requestedCurrentState = getDefaultState();
        }
        var commonBaseState : String = findCommonBaseState(_currentState, requestedCurrentState);
        var event : StateChangeEvent;
        var oldState : String = (_currentState != null) ? _currentState : "";
        if (target.hasEventListener(StateChangeEvent.CURRENT_STATE_CHANGING)) 
        {
            event = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGING);
            event.oldState = oldState;
            event.newState = (requestedCurrentState != null) ? requestedCurrentState : "";
            target.dispatchEvent(event);
        }
        
        removeState(_currentState, commonBaseState);
        _currentState = requestedCurrentState;
        
        if (_currentState != null) 
        {
            applyState(_currentState, commonBaseState);
        }
        
        if (target.hasEventListener(StateChangeEvent.CURRENT_STATE_CHANGE)) 
        {
            event = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGE);
            event.oldState = oldState;
            event.newState = (_currentState != null) ? _currentState : "";
            target.dispatchEvent(event);
        }
    }
    
    
    /**
	* 通过名称返回视图状态
	*/
    private function getState(stateName : String) : State
    {
        if (_states == null || stateName == null) 
            return null;
        
        for (i in 0..._states.length)
		{
            if (_states[i].name == stateName) 
                return _states[i];
        }
        
        return null;
    }
    
    /**
	* 返回两个视图状态的共同父级状态
	*/
    private function findCommonBaseState(state1 : String, state2 : String) : String
    {
        var firstState : State = getState(state1);
        var secondState : State = getState(state2);
        
        if (firstState == null || secondState == null) 
            return "";
        
        if (firstState.basedOn == null && secondState.basedOn == null) 
            return "";
        
        var firstBaseStates : Array<Dynamic> = getBaseStates(firstState);
        var secondBaseStates : Array<Dynamic> = getBaseStates(secondState);
        var commonBase : String = "";
        
        while (firstBaseStates[firstBaseStates.length - 1] ==
        secondBaseStates[secondBaseStates.length - 1])
        {
            commonBase = firstBaseStates.pop();
            secondBaseStates.pop();
            
            if (firstBaseStates.length == 0 || secondBaseStates.length == 0) 
                break;
        }
        
        if (firstBaseStates.length != 0 &&
            firstBaseStates[firstBaseStates.length - 1] == secondState.name) 
        {
            commonBase = secondState.name;
        }
        else if (secondBaseStates.length != 0 &&
            secondBaseStates[secondBaseStates.length - 1] == firstState.name) 
        {
            commonBase = firstState.name;
        }
        
        return commonBase;
    }
    
    /**
	* 获取指定视图状态的所有父级状态列表
	*/
    private function getBaseStates(state : State) : Array<Dynamic>
    {
        var baseStates : Array<Dynamic> = [];
        
        while (state != null && state.basedOn != null)
        {
            baseStates.push(state.basedOn);
            state = getState(state.basedOn);
        }
        
        return baseStates;
    }
    
    /**
	* 移除指定的视图状态以及所依赖的所有父级状态，除了与新状态的共同状态外
	*/
    private function removeState(stateName : String, lastState : String) : Void
    {
        var state : State = getState(stateName);
        
        if (stateName == lastState) 
            return;
        
        if (state != null) 
        {
            state.dispatchExitState();
            
            var overrides : Array<Dynamic> = state.overrides;
            
            var i : Int = overrides.length;
            while (i != 0)
			{
				overrides[i - 1].remove(target);
                i--;
            }
            
            if (state.basedOn != lastState) 
                removeState(state.basedOn, lastState);
        }
    }
    
    /**
	* 应用新状态
	*/
    private function applyState(stateName : String, lastState : String) : Void
    {
        var state : State = getState(stateName);
        
        if (stateName == lastState) 
            return;
        
        if (state != null) 
        {
            if (state.basedOn != lastState) 
                applyState(state.basedOn, lastState);
            
            var overrides : Array<Dynamic> = state.overrides;
            
            for (i in 0...overrides.length)
			{
				overrides[i].apply(Lib.as(target, IContainer));
            }
            
            state.dispatchEnterState();
        }
    }
    
    private var initialized : Bool = false;
    /**
	* 初始化所有视图状态
	*/
    public function initializeStates() : Void
    {
        if (initialized) 
            return;
        initialized = true;
        for (i in 0..._states.length)
		{
            var state : State = Std.instance(_states[i], State);
            if (state == null) 
                break;
            state.initialize(target);
        }
    }
}
