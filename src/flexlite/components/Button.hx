package flexlite.components;

import flexlite.components.supportclasses.ButtonBase;

/**
* 按钮控件
* @author weilichuang
*/
@:meta(DXML(show="true"))
class Button extends ButtonBase
{
	public function new()
	{
		super();
	}

	/**
	* @inheritDoc
	*/
	override private function get_hostComponentKey() : Dynamic
	{
		return Button;
	}
}

