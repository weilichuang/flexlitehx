package flexlite.components;

import flash.filters.DropShadowFilter;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flexlite.core.IToolTip;
import flexlite.core.UIComponent;
import flexlite.core.UITextField;


/**
* 工具提示组件
* @author weilichuang
*/
class ToolTip extends UIComponent implements IToolTip
{
	/**
	* 组件最大宽度
	*/
    public static var MAX_WIDTH : Float = 300;
	
	/**
	* @inheritDoc
	*/
    public var toolTipData(get, set) : Dynamic;
    
	private var _toolTipData : Dynamic;
	
    /**
	* toolTipData发生改变标志
	*/
    private var toolTipDataChanged : Bool;
	
	/**
	* 文本显示对象
	*/
    private var textField : UITextField;
	
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        mouseEnabled = false;
        mouseChildren = false;
    }
    
    private function get_toolTipData() : Dynamic
    {
        return _toolTipData;
    }
    private function set_toolTipData(value : Dynamic) : Dynamic
    {
        _toolTipData = value;
        toolTipDataChanged = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        drawBackground();
        createTextField(-1);
        this.filters = [new DropShadowFilter(1, 45, 0, 0.7, 2, 2, 1, 1)];
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (toolTipDataChanged) 
        {
            var textFormat : TextFormat = textField.getTextFormat();
            textFormat.leftMargin = 0;
            textFormat.rightMargin = 0;
            textField.defaultTextFormat = textFormat;
            
            textField.text = Std.string(_toolTipData);
            toolTipDataChanged = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function measure() : Void
    {
        super.measure();
        
        var widthSlop : Float = 10;
        var heightSlop : Float = 10;
        
        textField.wordWrap = false;
        
        if (textField.textWidth + widthSlop > ToolTip.MAX_WIDTH) 
        {
            textField.width = ToolTip.MAX_WIDTH - widthSlop;
            textField.wordWrap = true;
        }
        
        measuredWidth = textField.width + widthSlop;
        measuredHeight = textField.height + heightSlop;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var widthSlop : Float = 10;
        var heightSlop : Float = 10;
        
        textField.x = 5;
        textField.y = 5;
        textField.width = unscaledWidth - widthSlop;
        textField.height = unscaledHeight - heightSlop;
        drawBackground();
    }
    /**
	* 创建文字
	*/
    private function createTextField(childIndex : Int) : Void
    {
        if (textField == null) 
        {
            textField = new UITextField();
            
            textField.autoSize = TextFieldAutoSize.LEFT;
            textField.mouseEnabled = false;
            textField.multiline = true;
            textField.selectable = false;
            textField.wordWrap = false;
            var tf : TextFormat = textField.getTextFormat();
            tf.font = "SimSun";
            tf.color = 0xFFFFFF;
            tf.leading = 2;
            textField.defaultTextFormat = tf;
            
            if (childIndex == -1) 
                addToDisplayList(textField)
            else 
            addToDisplayListAt(textField, childIndex);
        }
    }
	
    /**
	* 移除文字
	*/
    private function removeTextField() : Void
    {
        if (textField != null) 
        {
            removeFromDisplayList(textField);
            textField = null;
        }
    }
	
    /**
	* 绘制背景
	*/
    private function drawBackground() : Void
    {
        graphics.clear();
        graphics.beginFill(0x000000, 0.7);
        var w : Float = Math.isNaN(width) ? 0 : width;
        var h : Float = Math.isNaN(height) ? 0 : height;
        graphics.drawRoundRect(0, 0, w, h, 5, 5);
        graphics.endFill();
    }
}


