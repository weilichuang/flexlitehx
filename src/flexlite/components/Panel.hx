package flexlite.components;

import flexlite.components.SkinnableContainer;


import flexlite.core.IDisplayText;

@:meta(DXML(show="true"))


/**
* 带有标题，内容区域的面板组件
* @author weilichuang
*/
class Panel extends SkinnableContainer
{
    public var title(get, set) : String;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        mouseEnabled = false;
        //当面板覆盖在会运动的场景上时，将会导致不断被触发重绘，而如果含有较多矢量子项，
        //就会消耗非常多的渲染时间。设置位图缓存将能极大提高这种情况下的性能。
        cacheAsBitmap = true;
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return Panel;
    }
    
    /**
	* [SkinPart]标题显示对象 
	*/
	@SkinPart
    public var titleDisplay : IDisplayText;
    
    private var _title : String = "";
    /**
	* 标题内容改变 
	*/
    private var titleChanged : Bool;
    /**
	* 标题文本内容
	*/
    private function get_title() : String
    {
        return _title;
    }
    
    private function set_title(value : String) : String
    {
        _title = value;
        
        if (titleDisplay != null) 
            titleDisplay.text = title;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == titleDisplay) 
        {
            titleDisplay.text = title;
        }
    }
}
