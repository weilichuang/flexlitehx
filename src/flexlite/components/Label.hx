package flexlite.components;



import flash.events.Event;
import flash.text.Font;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;
import flash.utils.Dictionary;
import haxe.ds.IntMap;

import flexlite.core.Injector;

import flexlite.components.supportclasses.TextBase;
import flexlite.core.ITranslator;
import flexlite.events.UIEvent;
import flexlite.layouts.VerticalAlign;




@:meta(DXML(show="true"))


/**
* 一行或多行不可编辑的文本控件
* @author weilichuang
*/
class Label extends TextBase
{
    public var verticalAlign(get, set) : String;
    public var maxDisplayedLines(get, set) : Int;
    public var padding(get, set) : Float;
    public var paddingLeft(get, set) : Float;
    public var paddingRight(get, set) : Float;
    public var paddingTop(get, set) : Float;
    public var paddingBottom(get, set) : Float;
    public var isTruncated(get, never) : Bool;
    public var truncateToFit(get, set) : Bool;

    public function new()
    {
        super();
        addEventListener(UIEvent.UPDATE_COMPLETE, updateCompleteHandler);
        if (isFirstLabel) 
        {
            isFirstLabel = false;
            try
            {
                translator = Injector.getInstance(ITranslator);
            }            
			catch (e : String){ };
        }
    }
    /**
	* 是否只显示嵌入的字体。此属性对只所有Label实例有效。true表示如果指定的fontFamily没有被嵌入，
	* 即使用户机上存在该设备字体也不显示。而将使用默认的字体。默认值为false。
	*/
    public static var showEmbedFontsOnly : Bool = false;
    /**
	* 是否是第一个创建的Label实例
	*/
    private static var isFirstLabel : Bool = true;
    /**
	* 注入的文本翻译对象
	*/
    private static var translator : ITranslator;
    /**
	* @inheritDoc
	*/
    override private function set_fontFamily(value : String) : String
    {
        if (fontFamily == value) 
            return value;
			
        var fontList : Array<Font> = Font.enumerateFonts(false);
        embedFonts = false;
        for (font in fontList)
        {
            if (font.fontName == value) 
            {
                embedFonts = true;
                break;
            }
        }
        if (!embedFonts && showEmbedFontsOnly) 
            return  value;
        super.fontFamily = value;
        return value;
    }
    
    private var toolTipSet : Bool = false;
    
    /**
	* @inheritDoc
	*/
    override private function set_toolTip(value : Dynamic) : Dynamic
    {
        super.toolTip = value;
        toolTipSet = (value != null);
        return value;
    }
    
    /**
	* 一个验证阶段完成
	*/
    private function updateCompleteHandler(event : UIEvent) : Void
    {
        lastUnscaledWidth = Math.NaN;
    }
    
    private var _verticalAlign : String = VerticalAlign.TOP;
    /**
	* 垂直对齐方式,支持VerticalAlign.TOP,VerticalAlign.BOTTOM,VerticalAlign.MIDDLE和VerticalAlign.JUSTIFY(两端对齐);
	* 默认值：VerticalAlign.TOP。
	*/
    private function get_verticalAlign() : String
    {
        return _verticalAlign;
    }
    private function set_verticalAlign(value : String) : String
    {
        if (_verticalAlign == value) 
            return value;
        _verticalAlign = value;
        if (textField != null) 
            textField.leading = realLeading;
        defaultStyleChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    override private function get_realLeading() : Int
    {
        return _verticalAlign == (VerticalAlign.JUSTIFY) ? 0 : leading;
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_defaultTextFormat() : TextFormat
    {
        if (defaultStyleChanged) 
        {
            _textFormat = getDefaultTextFormat();
            //当设置了verticalAlign为VerticalAlign.JUSTIFY时将忽略行高
            if (_verticalAlign == VerticalAlign.JUSTIFY) 
                _textFormat.leading = 0;
            defaultStyleChanged = false;
        }
        return _textFormat;
    }
    
    /**
	* 从另外一个文本组件复制默认文字格式信息到自身，不包括对setFormatOfRange()的调用。<br/>
	* 复制的值包含：<br/>
	* fontFamily，size，textColor，bold，italic，underline，textAlign，<br/>
	* leading，letterSpacing，disabledColor,verticalAlign属性。
	*/
    override public function copyDefaultFormatFrom(textBase : TextBase) : Void
    {
        super.copyDefaultFormatFrom(textBase);
        if (Std.is(textBase, Label)) 
        {
            verticalAlign = cast(textBase, Label).verticalAlign;
        }
    }
    
    
    private var _maxDisplayedLines : Int = 0;
    /**
	* 最大显示行数,0或负值代表不限制。
	*/
    private function get_maxDisplayedLines() : Int
    {
        return _maxDisplayedLines;
    }
    
    private function set_maxDisplayedLines(value : Int) : Int
    {
        if (_maxDisplayedLines == value) 
            return value;
        _maxDisplayedLines = value;
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_text(value : String) : String
    {
        if (value == null) 
            value = "";
        if (!isHTML && value == _text) 
            return value;
        if (translator != null) 
            super.text = translator.translate(value);
        else 
			super.text = value;
        rangeFormatDic = null;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_htmlText(value : String) : String
    {
        if (value == null) 
            value = "";
        
        if (isHTML && value == explicitHTMLText) 
            return value;
        
        super.htmlText = value;
        
        rangeFormatDic = null;
        return value;
    }
    /**
	* 上一次测量的宽度 
	*/
    private var lastUnscaledWidth : Float = Math.NaN;
    
    private var _padding : Float = 0;
    /**
	* 四个边缘的共同内边距。若单独设置了任一边缘的内边距，则该边缘的内边距以单独设置的值为准。
	* 此属性主要用于快速设置多个边缘的相同内边距。默认值：0。
	*/
    private function get_padding() : Float
    {
        return _padding;
    }
    private function set_padding(value : Float) : Float
    {
        if (_padding == value) 
            return value;
        _padding = value;
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _paddingLeft : Float = Math.NaN;
    /**
	* 文字距离左边缘的空白像素,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingLeft() : Float
    {
        return _paddingLeft;
    }
    
    private function set_paddingLeft(value : Float) : Float
    {
        if (_paddingLeft == value) 
            return value;
        
        _paddingLeft = value;
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _paddingRight : Float = Math.NaN;
    /**
	* 文字距离右边缘的空白像素,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingRight() : Float
    {
        return _paddingRight;
    }
    
    private function set_paddingRight(value : Float) : Float
    {
        if (_paddingRight == value) 
            return value;
        
        _paddingRight = value;
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _paddingTop : Float = Math.NaN;
    /**
	* 文字距离顶部边缘的空白像素,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingTop() : Float
    {
        return _paddingTop;
    }
    
    private function set_paddingTop(value : Float) : Float
    {
        if (_paddingTop == value) 
            return value;
        
        _paddingTop = value;
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    private var _paddingBottom : Float = Math.NaN;
    /**
	* 文字距离底部边缘的空白像素,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingBottom() : Float
    {
        return _paddingBottom;
    }
    
    private function set_paddingBottom(value : Float) : Float
    {
        if (_paddingBottom == value) 
            return value;
        
        _paddingBottom = value;
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        var needSetDefaultFormat : Bool = defaultStyleChanged || textChanged || htmlTextChanged;
        rangeFormatChanged = needSetDefaultFormat || rangeFormatChanged;
        
        super.commitProperties();
        
        if (rangeFormatChanged) 
        {
			//如果样式发生改变，父级会执行样式刷新的过程。这里就不用重复了。
            if (!needSetDefaultFormat)                     
				textField.native_setTextFormat(defaultTextFormat);
            applyRangeFormat();
            rangeFormatChanged = false;
        }
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function measure() : Void
    {
        //先提交属性，防止样式发生改变导致的测量不准确问题。
        if (invalidatePropertiesFlag) 
            validateProperties();
        if (isSpecialCase()) 
        {
            if (Math.isNaN(lastUnscaledWidth)) 
            {
                oldPreferWidth = Math.NaN;
                oldPreferHeight = Math.NaN;
            }
            else 
            {
                measureUsingWidth(lastUnscaledWidth);
                return;
            }
        }
        
        var availableWidth : Float = 0;
        
        if (!Math.isNaN(explicitWidth)) 
            availableWidth = explicitWidth
        else if (maxWidth != 10000) 
            availableWidth = maxWidth;
        
        measureUsingWidth(availableWidth);
    }
    
    /**
	* 特殊情况，组件尺寸由父级决定，要等到父级UpdateDisplayList的阶段才能测量
	*/
    private function isSpecialCase() : Bool
    {
        return _maxDisplayedLines != 1 &&
        (!Math.isNaN(percentWidth) || (!Math.isNaN(left) && !Math.isNaN(right))) &&
        Math.isNaN(explicitHeight) &&
        Math.isNaN(percentHeight);
    }
    
    /**
	* 使用指定的宽度进行测量
	*/
    private function measureUsingWidth(w : Float) : Void
    {
        var originalText : String = textField.text;
        if (_isTruncated || textChanged || htmlTextChanged) 
        {
            if (isHTML) 
                textField.nativeHtmlText = explicitHTMLText
            else 
				textField.nativeText = _text;
            applyRangeFormat();
        }
        
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        
        textField.autoSize = TextFieldAutoSize.LEFT;
        
        if (!Math.isNaN(w)) 
        {
            textField.nativeWidth = w - paddingL - paddingR;
            measuredWidth = Math.ceil(textField.textWidth);
            measuredHeight = Math.ceil(textField.textHeight);
        }
        else 
        {
            var oldWordWrap : Bool = textField.wordWrap;
            textField.wordWrap = false;
            
            measuredWidth = Math.ceil(textField.textWidth);
            measuredHeight = Math.ceil(textField.textHeight);
            
            textField.wordWrap = oldWordWrap;
        }
        
        textField.autoSize = TextFieldAutoSize.NONE;
        
        if (_maxDisplayedLines > 0 && textField.numLines > _maxDisplayedLines) 
        {
            var lineM : TextLineMetrics = textField.getLineMetrics(0);
            measuredHeight = lineM.height * _maxDisplayedLines - lineM.leading + 4;
        }
        
        measuredWidth += paddingL + paddingR;
        measuredHeight += paddingT + paddingB;
        
        if (_isTruncated) 
        {
            textField.nativeText = originalText;
            applyRangeFormat();
        }
    }
    
    /**
	* 记录不同范围的格式信息 
	*/
    private var rangeFormatDic : IntMap<IntMap<TextFormat>>;
    
    /**
	* 范围格式信息发送改变标志
	*/
    private var rangeFormatChanged : Bool = false;
    
    /**
	* 将指定的格式应用于指定范围中的每个字符。
	* 注意：使用此方法应用的格式只能影响到当前的文字内容，若改变文字内容，所有文字将会被重置为默认格式。
	* @param format 一个包含字符和段落格式设置信息的 TextFormat 对象。
	* @param beginIndex 可选；一个整数，指定所需文本范围内第一个字符的从零开始的索引位置。
	* @param endIndex 可选；一个整数，指定所需文本范围后面的第一个字符。
	* 如果指定 beginIndex 和 endIndex 值，则更新索引从 beginIndex 到 endIndex-1 的文本。
	*/
    public function setFormatOfRange(format : TextFormat, beginIndex : Int = -1, endIndex : Int = -1) : Void
    {
        if (rangeFormatDic == null) 
            rangeFormatDic = new IntMap<IntMap<TextFormat>>();
        if (!rangeFormatDic.exists(beginIndex)) 
            rangeFormatDic.set(beginIndex,new IntMap<TextFormat>());
			
        rangeFormatDic.get(beginIndex).set(endIndex,cloneTextFormat(format));
        
        rangeFormatChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
	* 克隆一个文本格式对象
	*/
    private static function cloneTextFormat(tf : TextFormat) : TextFormat
    {
        return new TextFormat(tf.font, tf.size, tf.color, tf.bold, tf.italic, 
        tf.underline, tf.url, tf.target, tf.align, 
        tf.leftMargin, tf.rightMargin, tf.indent, tf.leading);
    }
    
    
    /**
	* 应用范围格式信息
	*/
    private function applyRangeFormat(expLeading : Dynamic = null) : Void
    {
        rangeFormatChanged = false;
        if (rangeFormatDic == null || textField == null || _text == null) 
            return;
			
        var useLeading : Bool = expLeading != null;
		
		var keys = rangeFormatDic.keys();
        for (beginIndex in keys)
        {
            var endDic : IntMap<TextFormat> = rangeFormatDic.get(beginIndex);
            if (endDic != null) 
            {
				var endKeys = endDic.keys();
                for (index in endKeys)
                {
                    if (!endDic.exists(index)) 
                        continue;
						
                    var oldLeading : Dynamic = null;
                    if (useLeading) 
                    {
                        oldLeading = endDic.get(index).leading;
						endDic.get(index).leading = expLeading;
                    }
					
                    var endIndex : Int = index;
                    if (endIndex > textField.text.length) 
                        endIndex = textField.text.length;
                    try
                    {
                        textField.native_setTextFormat(endDic.get(index), beginIndex, endIndex);
                    }                    
					catch (e : String){ };
                    if (useLeading) 
                    {
						endDic.get(index).leading = oldLeading;
                    }
                }
            }
        }
    }
    
    
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        _updateDisplayList(unscaledWidth, unscaledHeight);
        
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        
        textField.x = paddingL;
        textField.y = paddingT;
        if (isSpecialCase()) 
        {
            var firstTime : Bool = Math.isNaN(lastUnscaledWidth) || lastUnscaledWidth != unscaledWidth;
            lastUnscaledWidth = unscaledWidth;
            if (firstTime) 
            {
                oldPreferWidth = Math.NaN;
                oldPreferHeight = Math.NaN;
                invalidateSize();
                return;
            }
        } 
		
		//防止在父级validateDisplayList()阶段改变的text属性值，
		//接下来直接调用自身的updateDisplayList()而没有经过measu(),使用的测量尺寸是上一次的错误值。      
        if (invalidateSizeFlag) 
            validateSize();
        
		//解决初始化时文本闪烁问题  
        if (!textField.visible)               
			textField.visible = true;
			
        if (_isTruncated) 
        {
            textField.nativeText = _text;
            applyRangeFormat();
        }
        
        textField.scrollH = 0;
        textField.scrollV = 1;
        
        textField.nativeWidth = unscaledWidth - paddingL - paddingR;
        var unscaledTextHeight : Float = unscaledHeight - paddingT - paddingB;
        textField.nativeHeight = unscaledTextHeight;
        
        if (_maxDisplayedLines == 1) 
            textField.wordWrap = false
        else if (Math.floor(width) < Math.floor(measuredWidth)) 
            textField.wordWrap = true;
        
        _textWidth = textField.textWidth;
        _textHeight = textField.textHeight;
        
        if (_maxDisplayedLines > 0 && textField.numLines > _maxDisplayedLines) 
        {
            var lineM : TextLineMetrics = textField.getLineMetrics(0);
            var h : Float = lineM.height * _maxDisplayedLines - lineM.leading + 4;
            textField.nativeHeight = Math.min(unscaledTextHeight, h);
        }
        if (_verticalAlign == VerticalAlign.JUSTIFY) 
        {
            textField.native_setTextFormat(defaultTextFormat);
            applyRangeFormat(0);
        }
        
        if (_truncateToFit) 
        {
            _isTruncated = truncateTextToFit();
            if (!toolTipSet) 
                super.toolTip = (_isTruncated) ? _text : null;
        }
        if (textField.textHeight >= unscaledTextHeight) 
            return;
        if (_verticalAlign == VerticalAlign.JUSTIFY) 
        {
            if (textField.numLines > 1) 
            {
                textField.nativeHeight = unscaledTextHeight;
                var extHeight : Float = Math.max(0, unscaledTextHeight - 4 - textField.textHeight);
                defaultTextFormat.leading = Math.floor(extHeight / (textField.numLines - 1));
                textField.native_setTextFormat(defaultTextFormat);
                applyRangeFormat(defaultTextFormat.leading);
                defaultTextFormat.leading = 0;
            }
        }
        else 
        {
            var valign : Float = 0;
            if (_verticalAlign == VerticalAlign.MIDDLE) 
                valign = 0.5
            else if (_verticalAlign == VerticalAlign.BOTTOM) 
                valign = 1;
            textField.y += Math.floor((unscaledTextHeight - textField.textHeight) * valign);
            textField.nativeHeight = unscaledTextHeight - textField.y;
        }
    }
    
    
    private var _isTruncated : Bool = false;
    
    /**
	* 文本是否已经截断并以...结尾的标志。注意：当使用htmlText显示文本时，始终直接截断文本,不显示...。
	*/
    private function get_isTruncated() : Bool
    {
        return _isTruncated;
    }
    
    private var _truncateToFit : Bool = true;
    /**
	* 如果此属性为true，并且Label控件大小小于其文本大小，则使用"..."截断 Label控件的文本。
	* 反之将直接截断文本。注意：当使用htmlText显示文本或设置maxDisplayedLines=1时，始终直接截断文本,不显示...。
	*/
    private function get_truncateToFit() : Bool
    {
        return _truncateToFit;
    }
    
    private function set_truncateToFit(value : Bool) : Bool
    {
        if (_truncateToFit == value) 
            return value;
        _truncateToFit = value;
        invalidateDisplayList();
        return value;
    }
    
    
    /**
	* 截断超过边界的字符串，使用"..."结尾
	*/
    private function truncateTextToFit() : Bool
    {
        if (isHTML) 
            return false;
        var truncationIndicator : String = "...";
        var originalText : String = text;
        
        var expLeading : Dynamic = verticalAlign == VerticalAlign.JUSTIFY ? 0 : null;
        
		var lastLineIndex : Int = 0;
        try
        {
            var lineM : TextLineMetrics = textField.getLineMetrics(0);
            var realTextHeight : Float = textField.height - 4 + textField.leading;
            lastLineIndex = Std.int(realTextHeight / lineM.height);
        }        
		catch (e : String)
        {
            lastLineIndex = 1;
        }
		
        if (lastLineIndex < 1) 
            lastLineIndex = 1;
        if (textField.numLines > lastLineIndex && textField.textHeight > textField.height) 
        {
            var offset : Int = textField.getLineOffset(lastLineIndex);
            originalText = originalText.substr(0, offset);
            textField.nativeText = originalText + truncationIndicator;
            applyRangeFormat(expLeading);
            while (originalText.length > 1 && textField.numLines > lastLineIndex)
            {
                originalText = originalText.substring(0, -1);
                textField.nativeText = originalText + truncationIndicator;
                applyRangeFormat(expLeading);
            }
            return true;
        }
        return false;
    }
    
    /**
	* @inheritDoc
	*/
    override private function createTextField() : Void
    {
        super.createTextField();
        textField.wordWrap = true;
        textField.multiline = true;
        textField.visible = false;
        textField.mouseWheelEnabled = false;
    }
    
    /**
	* 文字内容发生改变
	*/
    override private function textField_textModifiedHandler(event : Event) : Void
    {
        super.textField_textModifiedHandler(event);
        rangeFormatDic = null;
    }
}
