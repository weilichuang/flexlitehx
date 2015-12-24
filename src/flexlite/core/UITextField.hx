package flexlite.core;



import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

import flexlite.core.Injector;


/**
* 框架中所有文本的显示对象使用的文本基类，隔离TextField,
* 对常用属性的改变进行事件封装,以通知父级组件重新验证尺寸和布局。
* @author weilichuang
*/
class UITextField extends TextField
{
	/**
	* 是否是第一个创建的Label实例
	*/
    private static var isFirstTextFiled : Bool = true;
    /**
	* 注入的文本翻译对象
	*/
    private static var translator : ITranslator;
	
    public var nativeWidth(never, set) : Float;
    public var nativeHeight(never, set) : Float;
    public var nativeHtmlText(never, set) : String;
    public var nativeText(never, set) : String;
	
	//用于返回正确的文本高度，去除最后一行的行间距。
    public var leading : Int = 0;

    public function new()
    {
        super();
        if (isFirstTextFiled) 
        {
            isFirstTextFiled = false;
            try
            {
                translator = Injector.getInstance(ITranslator);
            }           
			catch (e : String){ };
        }
    }
    
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(width) private function set_width(value : Float) : Void
    {
        var changed : Bool = super.width != value;
        super.width = value;
        if (changed) 
            dispatchEvent(new Event("widthChanged"));
    }
	#else
	override private function set_width(value : Float) : Float
    {
        var changed : Bool = super.width != value;
        super.width = value;
        if (changed) 
            dispatchEvent(new Event("widthChanged"));
        return value;
    }
	#end
     
    /**
	* @inheritDoc
	*/
	#if flash 
	@:getter(height)
	#else
    override 
	#end
	private function get_height() : Float
    {
        return super.height - leading;
    }
    /**
	* @inheritDoc
	*/
	#if flash 
	@:setter(height) private function set_height(value : Float) : Void
    {
        var changed : Bool = height != value;
        super.height = value + leading;
        if (changed) 
            dispatchEvent(new Event("heightChanged"));
    }
	#else
    override private function set_height(value : Float) : Float
    {
        var changed : Bool = height != value;
        super.height = value + leading;
        if (changed) 
            dispatchEvent(new Event("heightChanged"));
        return value;
    }
	#end
     
    
    /**
	* @inheritDoc
	*/
    override public function setTextFormat(format : TextFormat, beginIndex : Int = -1, endIndex : Int = -1) : Void
    {
        super.setTextFormat(format, beginIndex, endIndex);
        dispatchEvent(new Event("textFormatChanged"));
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(text) private function set_text(value : String) : Void
    {
        if (value == null) 
            value = "";
        var changed : Bool = super.text != value;
        
        if (translator != null) 
            super.text = translator.translate(value)
        else 
			super.text = value;
        
        if (changed) 
            dispatchEvent(new Event("textChanged"));
    }
	#else
	override private function set_text(value : String) : String
    {
        if (value == null) 
            value = "";
        var changed : Bool = super.text != value;
        
        if (translator != null) 
            super.text = translator.translate(value)
        else 
        super.text = value;
        
        if (changed) 
            dispatchEvent(new Event("textChanged"));
        return value;
    }
	#end
     
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(htmlText) private function set_htmlText(value : String) : Void
    {
        if (value == null) 
            value = "";
        var changed : Bool = super.htmlText != value;
        
        super.htmlText = value;
        
        if (changed) 
            dispatchEvent(new Event("textChanged"));
    }
	#else
	override private function set_htmlText(value : String) : String
    {
        if (value == null) 
            value = "";
        var changed : Bool = super.htmlText != value;
        
        super.htmlText = value;
        
        if (changed) 
            dispatchEvent(new Event("textChanged"));
        return value;
    }
	#end
     
    
    /**
	* @inheritDoc
	*/
    override public function insertXMLText(beginIndex : Int, endIndex : Int, richText : String, pasting : Bool = false) : Void
    {
        super.insertXMLText(beginIndex, endIndex, richText, pasting);
        
        dispatchEvent(new Event("textChanged"));
    }
    
    /**
	* @inheritDoc
	*/
    override public function appendText(newText : String) : Void
    {
        super.appendText(newText);
        dispatchEvent(new Event("textChanged"));
    }
    
    /**
	* @inheritDoc
	*/
    override public function replaceSelectedText(value : String) : Void
    {
        super.replaceSelectedText(value);
        dispatchEvent(new Event("textChanged"));
    }
    
    /**
	* @inheritDoc
	*/
    override public function replaceText(beginIndex : Int, endIndex : Int, newText : String) : Void
    {
        super.replaceText(beginIndex, endIndex, newText);
        dispatchEvent(new Event("textChanged"));
    }
    
    
    /**
	* Flash Player在计算TextField.textHeight时，
	* 没有包含空白的4像素,为了方便使用，在这里做了统一处理,
	* 此属性返回的值可以直接赋值给heihgt，不会造成截断
	*/
	#if flash 
	@:getter(textHeight)
	#else
    override 
	#end
    private function get_textHeight() : Float
    {
        return super.textHeight + 4 - leading;
    }
    /**
	* Flash Player在计算TextField.textWidth时，
	* 没有包含空白的5像素,为了方便使用，在这里做了统一处理,
	* 此属性返回的值可以直接赋值给width，不会造成截断
	*/
	#if flash
	@:getter(textWidth) 
	#else
	override 
	#end
    private function get_textWidth() : Float
    {
        return super.textWidth + 5;
    }
    
    /**
	* @copy flash.text.TextField#width
	*/
    @:final private function set_nativeWidth(value : Float) : Float
    {
        if (super.width == value) 
            return value;
        super.width = value;
        return value;
    }
    
    /**
	* @copy flash.text.TextField#height
	*/
    @:final private function set_nativeHeight(value : Float) : Float
    {
        if (height == value) 
            return value;
        super.height = value + leading;
        return value;
    }
    
    /**
	* @copy flash.text.TextField#htmlText
	*/
    @:final private function set_nativeHtmlText(value : String) : String
    {
        if (value == null) 
            value = "";
        super.htmlText = value;
        return value;
    }
    
    /**
	* @copy flash.text.TextField#text
	*/
    @:final private function set_nativeText(value : String) : String
    {
        if (value == null) 
            value = "";
        super.text = value;
        return value;
    }
    
    
    /**
	* @copy flash.text.TextField#setTextFormat()
	*/
    @:final public function native_setTextFormat(format : TextFormat, beginIndex : Int = -1, endIndex : Int = -1) : Void
    {
        super.setTextFormat(format, beginIndex, endIndex);
    }
    /**
	* @copy flash.text.TextField#insertXMLText()
	*/
    @:final public function native_insertXMLText(beginIndex : Int, endIndex : Int, richText : String, pasting : Bool = false) : Void
    {
        super.insertXMLText(beginIndex, endIndex, richText, pasting);
    }
    /**
	* @copy flash.text.TextField#replaceText()
	*/
    public function native_replaceText(beginIndex : Int, endIndex : Int, newText : String) : Void
    {
        super.replaceText(beginIndex, endIndex, newText);
    }
    /**
	* @copy flash.text.TextField#appendText()
	*/
    public function native_appendText(newText : String) : Void
    {
        super.replaceText(text.length, text.length, newText);
    }
    /**
	* @copy flash.text.TextField#replaceSelectedText()
	*/
    public function native_replaceSelectedText(value : String) : Void
    {
        super.replaceSelectedText(value);
    }
}
