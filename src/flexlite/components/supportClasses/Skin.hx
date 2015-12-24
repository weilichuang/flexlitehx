package flexlite.components.supportclasses;



import flexlite.components.Group;
import flexlite.components.SkinnableComponent;
import flexlite.core.ISkin;
import flexlite.core.IStateClient;
import flexlite.states.StateClientHelper;



@:meta(DXML(show="false"))


/**
* 皮肤布局基类<br/>
* Skin及其子类中定义的公开属性,会在初始化完成后被直接当做SkinPart并将引用赋值到宿主组件的同名属性上，
* 若有延迟创建的部件，请在加载完成后手动调用hostComponent.findSkinParts()方法应用部件。<br/>
* @author weilichuang
*/
class Skin extends Group implements IStateClient implements ISkin
{
    public var hostComponent(get, set) : SkinnableComponent;
    public var states(get, set) : Array<Dynamic>;
    public var currentState(get, set) : String;

    public function new()
    {
        super();
        stateClientHelper = new StateClientHelper(this);
    }
    
    private var _hostComponent : SkinnableComponent;
    
    /**
	* 主机组件引用,仅当皮肤被应用后才会对此属性赋值 
	*/
    private function get_hostComponent() : SkinnableComponent
    {
        return _hostComponent;
    }
    
    private function set_hostComponent(value : SkinnableComponent) : SkinnableComponent
    {
        _hostComponent = value;
        return value;
    }
    
    override private function createChildren() : Void
    {
        super.createChildren();
        stateClientHelper.initializeStates();
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (stateClientHelper.currentStateChanged) 
        {
            stateClientHelper.commitCurrentState();
            commitCurrentState();
        }
    }
    
    //========================state相关函数===============start=========================
    
    private var stateClientHelper : StateClientHelper;
    /**
	* 为此组件定义的视图状态。
	*/
    private function get_states() : Array<Dynamic>
    {
        return stateClientHelper.states;
    }
    
    private function set_states(value : Array<Dynamic>) : Array<Dynamic>
    {
        stateClientHelper.states = value;
        return value;
    }
    
    /**
	* 组件的当前视图状态。
	*/
    private function get_currentState() : String
    {
        return stateClientHelper.currentState;
    }
    private function set_currentState(value : String) : String
    {
        stateClientHelper.currentState = value;
        
        if (stateClientHelper.currentStateChanged) 
        {
            if (initialized || parent != null) 
            {
                stateClientHelper.commitCurrentState();
                commitCurrentState();
            }
            else 
            {
                invalidateProperties();
            }
        }
        return value;
    }
    
    /**
	* 返回是否含有指定名称的视图状态
	* @param stateName 要检测的视图状态名称
	*/
    public function hasState(stateName : String) : Bool
    {
        return stateClientHelper.hasState(stateName);
    }
    
    /**
	* 应用当前的视图状态
	*/
    private function commitCurrentState() : Void
    {
        
        
    }
}

