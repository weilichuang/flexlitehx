package flexlite.components;



import flash.display.DisplayObject;
import flash.events.Event;
import flexlite.components.supportclasses.SkinnableTextBase;





@:meta(DefaultProperty(name="text",array="false"))


@:meta(DXML(show="true"))


/**
* 可设置外观的多行文本输入控件
* @author weilichuang
*/
class TextArea extends SkinnableTextBase
{
    public var widthInChars(get, set) : Float;
    public var heightInLines(get, set) : Float;
    public var horizontalScrollPolicy(get, set) : String;
    public var verticalScrollPolicy(get, set) : String;

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
        return TextArea;
    }
    
    /**
	* 控件的默认宽度（使用字号：size为单位测量）。 若同时设置了maxChars属性，将会根据两者测量结果的最小值作为测量宽度。
	*/
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
	* 控件的默认高度（以行为单位测量）。 
	*/
    private function get_heightInLines() : Float
    {
        return getHeightInLines();
    }
    
    /**
	*  @private
	*/
    private function set_heightInLines(value : Float) : Float
    {
        setHeightInLines(value);
        return value;
    }
    
    /**
	* 水平滚动条策略改变标志
	*/
    private var horizontalScrollPolicyChanged : Bool = false;
    
    private var _horizontalScrollPolicy : String;
    
    /**
	* 水平滚动条显示策略，参见ScrollPolicy类定义的常量。
	*/
    private function get_horizontalScrollPolicy() : String
    {
        return _horizontalScrollPolicy;
    }
    
    private function set_horizontalScrollPolicy(value : String) : String
    {
        if (_horizontalScrollPolicy == value) 
            return value;
        _horizontalScrollPolicy = value;
        horizontalScrollPolicyChanged = true;
        invalidateProperties();
        return value;
    }
    
    /**
	* 垂直滚动条策略改变标志 
	*/
    private var verticalScrollPolicyChanged : Bool = false;
    
    private var _verticalScrollPolicy : String;
    /**
	* 垂直滚动条显示策略，参见ScrollPolicy类定义的常量。
	*/
    private function get_verticalScrollPolicy() : String
    {
        return _verticalScrollPolicy;
    }
    
    private function set_verticalScrollPolicy(value : String) : String
    {
        if (_verticalScrollPolicy == value) 
            return value;
        _verticalScrollPolicy = value;
        verticalScrollPolicyChanged = true;
        invalidateProperties();
        return value;
    }
    
    
    /**
	* [SkinPart]实体滚动条组件
	*/
	@SkinPart
    public var scroller : Scroller;
    
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
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (horizontalScrollPolicyChanged) 
        {
            if (scroller != null) 
                scroller.horizontalScrollPolicy = horizontalScrollPolicy;
            horizontalScrollPolicyChanged = false;
        }
        
        if (verticalScrollPolicyChanged) 
        {
            if (scroller != null) 
                scroller.verticalScrollPolicy = verticalScrollPolicy;
            verticalScrollPolicyChanged = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == textDisplay) 
        {
            textDisplay.multiline = true;
        }
        else if (instance == scroller) 
        {
            if (scroller.horizontalScrollBar != null) 
                scroller.horizontalScrollBar.snapInterval = 0;
            if (scroller.verticalScrollBar != null) 
                scroller.verticalScrollBar.snapInterval = 0;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function createSkinParts() : Void
    {
        textDisplay = new EditableText();
        textDisplay.widthInChars = 15;
        textDisplay.heightInLines = 10;
        addToDisplayList(cast((textDisplay), DisplayObject));
        partAdded("textDisplay", textDisplay);
    }
}


