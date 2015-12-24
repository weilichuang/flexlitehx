package flexlite.components;


import flash.display.DisplayObject;
import flash.events.Event;
import flash.Lib;

import flexlite.components.supportclasses.SkinnableTextBase;
import flexlite.core.IViewport;




@:meta(DefaultProperty(name="text",array="false"))


@:meta(DXML(show="true"))


/**
* 可设置外观的单行文本输入控件
* @author weilichuang
*/
class TextInput extends SkinnableTextBase
{
	/**
	* 控件的默认宽度（使用字号：size为单位测量）。 若同时设置了maxChars属性，将会根据两者测量结果的最小值作为测量宽度。
	*/
    public var widthInChars(get, set) : Float;

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
        return TextInput;
    }
    
    
    private function get_widthInChars() : Float
    {
        return getWidthInChars();
    }
    
    private function set_widthInChars(value : Float) : Float
    {
        setWidthInChars(value);
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_text(value : String) : String
    {
        super.text = value;
        dispatchEvent(new Event("textChanged"));
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == textDisplay) 
        {
            textDisplay.multiline = false;
            if (Std.is(textDisplay, IViewport)) 
                (Lib.as(textDisplay, IViewport)).clipAndEnableScrolling = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function createSkinParts() : Void
    {
        textDisplay = new EditableText();
        textDisplay.widthInChars = 10;
        textDisplay.left = 1;
        textDisplay.right = 1;
        textDisplay.top = 1;
        textDisplay.bottom = 1;
        addToDisplayList(Lib.as(textDisplay, DisplayObject));
        partAdded("textDisplay", textDisplay);
    }
}


