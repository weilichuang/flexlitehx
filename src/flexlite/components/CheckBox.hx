package flexlite.components;


import flexlite.components.supportclasses.ToggleButtonBase;

@:meta(DXML(show="true"))


/**
* 复选框
* @author weilichuang
*/
class CheckBox extends ToggleButtonBase
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
    override private function get_hostComponentKey() : Dynamic
    {
        return CheckBox;
    }
}


