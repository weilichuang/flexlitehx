package flexlite.components;

import flexlite.components.supportclasses.ToggleButtonBase;

/**
* 切换按钮
* @author weilichuang
*/
@:meta(DXML(show="true"))
class ToggleButton extends ToggleButtonBase
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
        return ToggleButton;
    }
}

