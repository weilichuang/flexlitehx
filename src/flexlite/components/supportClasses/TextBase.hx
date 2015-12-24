package flexlite.components.supportclasses;


import flash.events.Event;
import flash.text.AntiAliasType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextLineMetrics;


import flexlite.core.FlexLiteGlobals;
import flexlite.core.IDisplayText;
import flexlite.core.UIComponent;
import flexlite.core.UITextField;



@:meta(DXML(show="false"))


/**
* 文本基类,实现对文本的自动布局，样式属性设置。
* @author weilichuang
*/
class TextBase extends UIComponent implements IDisplayText
{
    public var condenseWhite(get, set) : Bool;
    public var fontFamily(get, set) : String;
    public var size(get, set) : Int;
    public var bold(get, set) : Bool;
    public var italic(get, set) : Bool;
    public var underline(get, set) : Bool;
    public var textAlign(get, set) : TextFormatAlign;
    public var leading(get, set) : Int;
    private var realLeading(get, never) : Int;
    public var textColor(get, set) : Int;
    public var disabledColor(get, set) : Int;
    public var letterSpacing(get, set) : Float;
    private var defaultTextFormat(get, never) : TextFormat;
    public var htmlText(get, set) : String;
    private var isHTML(get, never) : Bool;
    public var selectable(get, set) : Bool;
    public var text(get, set) : String;
    public var textHeight(get, never) : Float;
    public var textWidth(get, never) : Float;

    public function new()
    {
        super();
    }
    
    /**
	* 默认的文本测量宽度 
	*/
    public static inline var DEFAULT_MEASURED_WIDTH : Float = 160;
    /**
	* 默认的文本测量高度
	*/
    public static inline var DEFAULT_MEASURED_HEIGHT : Float = 22;
    
    /**
	* 呈示此文本的内部 TextField 
	*/
    private var textField : UITextField;
    
    private var _condenseWhite : Bool = false;
    
    private var condenseWhiteChanged : Bool = false;
    
    /**
	* 一个布尔值，指定是否删除具有 HTML 文本的文本字段中的额外空白（空格、换行符等等）。
	* 默认值为 false。condenseWhite 属性只影响使用 htmlText 属性（而非 text 属性）设置的文本。
	* 如果使用 text 属性设置文本，则忽略 condenseWhite。 <p/>
	* 如果 condenseWhite 设置为 true，请使用标准 HTML 命令（如 <BR> 和 <P>），将换行符放在文本字段中。<p/>
	* 在设置 htmlText 属性之前设置 condenseWhite 属性。
	*/
    private function get_condenseWhite() : Bool
    {
        return _condenseWhite;
    }
    
    private function set_condenseWhite(value : Bool) : Bool
    {
        if (value == _condenseWhite) 
            return value;
        
        _condenseWhite = value;
        condenseWhiteChanged = true;
        
        if (isHTML) 
            htmlTextChanged = true;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        
        dispatchEvent(new Event("condenseWhiteChanged"));
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_enabled(value : Bool) : Bool
    {
        if (super.enabled == value) 
            return value;
        super.enabled = value;
        if (enabled) 
        {
            if (_selectable != pendingSelectable) 
                selectableChanged = true;
            if (_textColor != pendingColor) 
                defaultStyleChanged = true;
            _selectable = pendingSelectable;
            _textColor = pendingColor;
        }
        else 
        {
            if (_selectable) 
                selectableChanged = true;
            if (_textColor != disabledColor) 
                defaultStyleChanged = true;
            pendingSelectable = _selectable;
            pendingColor = _textColor;
            _selectable = false;
            _textColor = _disabledColor;
        }
        invalidateProperties();
        return value;
    }
    
    //===========================字体样式=====================start==========================
    
    private var defaultStyleChanged : Bool = true;
    /**
	* 是否使用嵌入字体
	*/
    private var embedFonts : Bool = false;
    
    private var _fontFamily : String = "SimSun";
    
    /**
	* 字体名称 。默认值：SimSun
	*/
    private function get_fontFamily() : String
    {
        return _fontFamily;
    }
    
    private function set_fontFamily(value : String) : String
    {
        if (_fontFamily == value) 
            return value;
        _fontFamily = value;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _size : Int = 12;
    
    /**
	* 字号大小,默认值12 。
	*/
    private function get_size() : Int
    {
        return _size;
    }
    
    private function set_size(value : Int) : Int
    {
        if (_size == value) 
            return value;
        _size = value;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _bold : Bool = false;
    
    /**
	* 是否为粗体,默认false。
	*/
    private function get_bold() : Bool
    {
        return _bold;
    }
    
    private function set_bold(value : Bool) : Bool
    {
        if (_bold == value) 
            return value;
        _bold = value;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _italic : Bool = false;
    
    /**
	* 是否为斜体,默认false。
	*/
    private function get_italic() : Bool
    {
        return _italic;
    }
    
    private function set_italic(value : Bool) : Bool
    {
        if (_italic == value) 
            return value;
        _italic = value;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _underline : Bool = false;
    
    /**
	* 是否有下划线,默认false。
	*/
    private function get_underline() : Bool
    {
        return _underline;
    }
    
    private function set_underline(value : Bool) : Bool
    {
        if (_underline == value) 
            return value;
        _underline = value;
        defaultStyleChanged = true;
        invalidateProperties();
        return value;
    }
    
    private var _textAlign : TextFormatAlign = TextFormatAlign.LEFT;
    
    /**
	* 文字的水平对齐方式 ,请使用TextFormatAlign中定义的常量。
	* 默认值：TextFormatAlign.LEFT。
	*/
    private function get_textAlign() : TextFormatAlign
    {
        return _textAlign;
    }
    
    private function set_textAlign(value : TextFormatAlign) : TextFormatAlign
    {
        if (_textAlign == value) 
            return value;
        _textAlign = value;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    
    private var _leading : Int = 2;
    
    /**
	* 行距,默认值为2。
	*/
    private function get_leading() : Int
    {
        return _leading;
    }
    
    private function set_leading(value : Int) : Int
    {
        if (_leading == value) 
            return value;
        _leading = value;
        if (textField != null) 
            textField.leading = realLeading;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private function get_realLeading() : Int
    {
        return _leading;
    }
    
    /**
	* 在enabled属性为false时记录的颜色值 
	*/
    private var pendingColor : Int = 0x000000;
    
    private var _textColor : Int = 0x000000;
    /**
	* @inheritDoc
	*/
    private function get_textColor() : Int
    {
        if (enabled) 
            return _textColor;
        return pendingColor;
    }
    
    private function set_textColor(value : Int) : Int
    {
        if (_textColor == value) 
            return value;
        if (enabled) 
        {
            _textColor = value;
            defaultStyleChanged = true;
            invalidateProperties();
        }
        else 
        {
            pendingColor = value;
        }
        return value;
    }
    
    private var _disabledColor : Int = 0xaab3b3;
    /**
	* 被禁用时的文字颜色,默认0xaab3b3。
	*/
    private function get_disabledColor() : Int
    {
        return _disabledColor;
    }
    
    private function set_disabledColor(value : Int) : Int
    {
        if (_disabledColor == value) 
            return value;
        _disabledColor = value;
        if (!enabled) 
        {
            _textColor = value;
            defaultStyleChanged = true;
            invalidateProperties();
        }
        return value;
    }
    
    
    private var _letterSpacing : Float = Math.NaN;
    
    /**
	* 字符间距,默认值为NaN。
	*/
    private function get_letterSpacing() : Float
    {
        return _letterSpacing;
    }
    
    private function set_letterSpacing(value : Float) : Float
    {
        if (_letterSpacing == value) 
            return value;
        _letterSpacing = value;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _textFormat : TextFormat;
    
    /**
	* 应用到所有文字的默认文字格式设置信息对象
	*/
    private function get_defaultTextFormat() : TextFormat
    {
        if (defaultStyleChanged) 
        {
            _textFormat = getDefaultTextFormat();
            defaultStyleChanged = false;
        }
        return _textFormat;
    }
    /**
	* 由于设置了默认文本格式后，是延迟一帧才集中应用的，若需要立即应用文本样式，可以手动调用此方法。
	*/
    public function applyTextFormatNow() : Void
    {
        if (defaultStyleChanged) 
        {
            textField.native_setTextFormat(defaultTextFormat);
            textField.defaultTextFormat = defaultTextFormat;
        }
    }
    
    /**
	* 从另外一个文本组件复制默认文字格式信息到自身。<br/>
	* 复制的值包含：<br/>
	* fontFamily，size，textColor，bold，italic，underline，textAlign，<br/>
	* leading，letterSpacing，disabledColor
	*/
    public function copyDefaultFormatFrom(textBase : TextBase) : Void
    {
        fontFamily = textBase.fontFamily;
        size = textBase.size;
        textColor = textBase.textColor;
        bold = textBase.bold;
        italic = textBase.italic;
        underline = textBase.underline;
        textAlign = textBase.textAlign;
        leading = textBase.leading;
        letterSpacing = textBase.letterSpacing;
        disabledColor = textBase.disabledColor;
    }
    
    /**
	* 获取文字的默认格式设置信息对象。
	*/
    public function getDefaultTextFormat() : TextFormat
    {
        var textFormat : TextFormat = new TextFormat(_fontFamily, _size, _textColor, _bold, _italic, _underline, 
        "", "", _textAlign, 0, 0, 0, _leading);
        if (!Math.isNaN(letterSpacing)) 
        {
            textFormat.kerning = true;
            textFormat.letterSpacing = letterSpacing;
        }
        else 
        {
            textFormat.kerning = false;
            textFormat.letterSpacing = null;
        }
        return textFormat;
    }
    
    //===========================字体样式======================end===========================
    
    
    
    
    private var _htmlText : String = "";
    
    private var htmlTextChanged : Bool = false;
    
    private var explicitHTMLText : String = null;
    
    /**
	*　HTML文本
	*/
    private function get_htmlText() : String
    {
        return _htmlText;
    }
    
    private function set_htmlText(value : String) : String
    {
        if (value == null) 
            value = "";
        
        if (isHTML && value == explicitHTMLText) 
            return value;
        
        _htmlText = value;
        if (textField != null) 
            textField.nativeHtmlText = _htmlText;
        htmlTextChanged = true;
        _text = null;
        
        explicitHTMLText = value;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    /**
	* 当前是否为html文本
	*/
    private function get_isHTML() : Bool
    {
        return cast explicitHTMLText;
    }
    
    private var pendingSelectable : Bool = false;
    
    private var _selectable : Bool = false;
    
    private var selectableChanged : Bool;
    
    /**
	* 指定是否可以选择文本。允许选择文本将使您能够从控件中复制文本。 
	*/
    private function get_selectable() : Bool
    {
        if (enabled) 
            return _selectable;
        return pendingSelectable;
    }
    
    private function set_selectable(value : Bool) : Bool
    {
        if (value == selectable) 
            return value;
        if (enabled) 
        {
            _selectable = value;
            selectableChanged = true;
            invalidateProperties();
        }
        else 
        {
            pendingSelectable = value;
        }
        return value;
    }
    
    private var _text : String = "";
    
    private var textChanged : Bool = false;
    
    private function get_text() : String
    {
        return _text;
    }
    
    private function set_text(value : String) : String
    {
        if (value == null) 
            value = "";
        
        if (!isHTML && value == _text) 
            return value;
        
        _text = value;
        if (textField != null) 
            textField.nativeText = _text;
        textChanged = true;
        _htmlText = null;
        
        explicitHTMLText = null;
        
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _textHeight : Float;
    
    /**
	* 文本高度
	*/
    private function get_textHeight() : Float
    {
        validateNowIfNeed();
        return _textHeight;
    }
    
    private var _textWidth : Float;
    
    /**
	* 文本宽度
	*/
    private function get_textWidth() : Float
    {
        validateNowIfNeed();
        return _textWidth;
    }
    
    /**
	* 由于组件是延迟应用属性的，若需要在改变文本属性后立即获得正确的值，要先调用validateNow()方法。
	*/
    private function validateNowIfNeed() : Void
    {
        if (invalidatePropertiesFlag || invalidateSizeFlag || invalidateDisplayListFlag) 
            validateNow();
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        
        if (textField == null) 
        {
            checkTextField();
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (textField == null) 
        {
            checkTextField();
        }
        
        if (condenseWhiteChanged) 
        {
            textField.condenseWhite = _condenseWhite;
            
            condenseWhiteChanged = false;
        }
        
        
        if (selectableChanged) 
        {
            textField.selectable = _selectable;
            
            selectableChanged = false;
        }
        
        if (defaultStyleChanged) 
        {
            textField.native_setTextFormat(defaultTextFormat);
            textField.defaultTextFormat = defaultTextFormat;
            textField.embedFonts = embedFonts;
            if (isHTML) 
                textField.nativeHtmlText = explicitHTMLText;
        }
        
        if (textChanged || htmlTextChanged) 
        {
            textFieldChanged(true);
            textChanged = false;
            htmlTextChanged = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function setFocus() : Void
    {
        if (textField != null && FlexLiteGlobals.stage != null) 
        {
            FlexLiteGlobals.stage.focus = textField;
        }
    }
    /**
	* 检查是否创建了textField对象，没有就创建一个。
	*/
    private function checkTextField() : Void
    {
        if (textField == null) 
        {
            createTextField();
            if (isHTML) 
                textField.nativeHtmlText = explicitHTMLText
            else 
            textField.nativeText = _text;
            textField.leading = realLeading;
            condenseWhiteChanged = true;
            selectableChanged = true;
            textChanged = true;
            defaultStyleChanged = true;
            invalidateProperties();
        }
    }
    
    /**
	* 创建文本显示对象
	*/
    private function createTextField() : Void
    {
        textField = new UITextField();
        textField.selectable = selectable;
        textField.antiAliasType = AntiAliasType.ADVANCED;
        textField.mouseWheelEnabled = false;
        
        textField.addEventListener("textChanged",
                textField_textModifiedHandler);
        textField.addEventListener("widthChanged",
                textField_textFieldSizeChangeHandler);
        textField.addEventListener("heightChanged",
                textField_textFieldSizeChangeHandler);
        textField.addEventListener("textFormatChanged",
                textField_textFormatChangeHandler);
        addToDisplayList(textField);
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function measure() : Void
    {
        super.measure();
        
        measuredWidth = DEFAULT_MEASURED_WIDTH;
        measuredHeight = DEFAULT_MEASURED_HEIGHT;
    }
    
    /**
	* 更新显示列表
	*/
    @:final private function _updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        textField.x = 0;
        textField.y = 0;
        textField.nativeWidth = unscaledWidth;
        textField.nativeHeight = unscaledHeight;
        _textWidth = textField.textWidth;
        _textHeight = textField.textHeight;
    }
    
    /**
	* 返回 TextLineMetrics 对象，其中包含控件中文本位置和文本行度量值的相关信息。
	* @param lineIndex 要获得其度量值的行的索引（从零开始）。
	*/
    public function getLineMetrics(lineIndex : Int) : TextLineMetrics
    {
        validateNowIfNeed();
        return (textField != null) ? textField.getLineMetrics(lineIndex) : null;
    }
    
    /**
	* 文本显示对象属性改变
	*/
    private function textFieldChanged(styleChangeOnly : Bool) : Void
    {
        if (!styleChangeOnly) 
        {
            _text = textField.text;
        }
        
        _htmlText = textField.htmlText;
        
        _textWidth = textField.textWidth;
        _textHeight = textField.textHeight;
    }
    
    /**
	* 文字内容发生改变
	*/
    private function textField_textModifiedHandler(event : Event) : Void
    {
        textFieldChanged(false);
        invalidateSize();
        invalidateDisplayList();
    }
    /**
	* 标签尺寸发生改变
	*/
    private function textField_textFieldSizeChangeHandler(event : Event) : Void
    {
        textFieldChanged(true);
        invalidateSize();
        invalidateDisplayList();
    }
    /**
	* 文字格式发生改变
	*/
    private function textField_textFormatChangeHandler(event : Event) : Void
    {
        textFieldChanged(true);
        invalidateSize();
        invalidateDisplayList();
    }
}
