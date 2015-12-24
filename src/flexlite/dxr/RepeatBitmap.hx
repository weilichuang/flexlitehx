package flexlite.dxr;


import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.Event;

import flexlite.core.IInvalidateDisplay;


/**
* 具有平铺功能的位图显示对象
* 注意：此类不具有鼠标事件
* @author weilichuang
*/
class RepeatBitmap extends Shape implements IInvalidateDisplay
{
    public var bitmapData(get, set) : BitmapData;

    /**
	* 构造函数
	* @param bitmapData 被引用的BitmapData对象。
	* @param target 要绘制到的目标Graphics对象，若不传入，则绘制到自身。
	*/
    public function new(bitmapData : BitmapData = null, target : Graphics = null)
    {
        super();
        if (target != null) 
            this.target = target
        else 
			this.target = graphics;
        if (bitmapData != null) 
            this.bitmapData = bitmapData;
    }
    /**
	* 要绘制到的目标Graphics对象。
	*/
    private var target : Graphics;
    /**
	* bitmapData发生改变
	*/
    private var bitmapDataChanged : Bool = false;
    
    private var _bitmapData : BitmapData;
    /**
	* 被引用的BitmapData对象。
	*/
    private function get_bitmapData() : BitmapData
    {
        return _bitmapData;
    }
    
    private function set_bitmapData(value : BitmapData) : BitmapData
    {
        if (_bitmapData == value) 
            return value;
			
        _bitmapData = value;
        if (value != null) 
        {
            if (!widthExplicitSet) 
                _width = _bitmapData.width;
            if (!heightExplicitSet) 
                _height = _bitmapData.height;
            bitmapDataChanged = true;
            invalidateProperties();
        }
        else 
        {
            target.clear();
            if (!widthExplicitSet) 
                _width = 0;
            if (!heightExplicitSet) 
                _height = 0;
        }
        return value;
    }
    
    private var widthChanged : Bool = false;
    /**
	* 宽度显式设置标记
	*/
    private var widthExplicitSet : Bool = false;
    
    private var _width : Float = 0;
	
    /**
	* @inheritDoc
	*/
	#if flash
	@:getter(width) 
	#else
	override 
	#end
     private function get_width() : Float
    {
        return _width;
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(width) private function set_width(value : Float) : Void
    {
        if (value == _width) 
            return;
			
        if (Math.isNaN(value)) 
        {
            widthExplicitSet = false;
            _width = (_bitmapData != null) ? _bitmapData.width : 0;
        }
        else 
        {
            widthExplicitSet = true;
            _width = value;
        }
        widthChanged = true;
        invalidateProperties();
    }
	#else
	override private function set_width(value : Float) : Float
    {
        if (value == _width) 
            return value;
			
        if (Math.isNaN(value)) 
        {
            widthExplicitSet = false;
            _width = (_bitmapData != null) ? _bitmapData.width : 0;
        }
        else 
        {
            widthExplicitSet = true;
            _width = value;
        }
        widthChanged = true;
        invalidateProperties();
        return value;
    } 
	#end
    
    
    private var heightChanged : Bool = false;
    /**
	* 高度显式设置标志
	*/
    private var heightExplicitSet : Bool = false;
    
    private var _height : Float;
    
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
        return _height;
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(height) private function set_height(value : Float) : Void
    {
        if (_height == value) 
            return;
        if (Math.isNaN(value)) 
        {
            heightExplicitSet = false;
            _height = (_bitmapData != null) ? _bitmapData.height : 0;
        }
        else 
        {
            heightExplicitSet = true;
            _height = value;
        }
        widthChanged = true;
        invalidateProperties();
    }
	#else
	override private function set_height(value : Float) : Float
    {
        if (_height == value) 
            return value;
        if (Math.isNaN(value)) 
        {
            heightExplicitSet = false;
            _height = (_bitmapData != null) ? _bitmapData.height : 0;
        }
        else 
        {
            heightExplicitSet = true;
            _height = value;
        }
        widthChanged = true;
        invalidateProperties();
        return value;
    } 
	#end
    
    
    private var invalidateFlag : Bool = false;
    /**
	* 标记有属性变化需要延迟应用
	*/
    private function invalidateProperties() : Void
    {
        if (!invalidateFlag) 
        {
            invalidateFlag = true;
            addEventListener(Event.ENTER_FRAME, validateProperties);
            if (stage != null) 
            {
                addEventListener(Event.RENDER, validateProperties);
                stage.invalidate();
            }
        }
    }
    /**
	* 延迟应用属性事件
	*/
    private function validateProperties(event : Event = null) : Void
    {
        removeEventListener(Event.ENTER_FRAME, validateProperties);
        removeEventListener(Event.RENDER, validateProperties);
        commitProperties();
        invalidateFlag = false;
    }
    
    /**
	* 立即应用所有标记为延迟验证的属性
	*/
    public function validateNow() : Void
    {
        if (invalidateFlag) 
            validateProperties();
    }
    
    /**
	* 延迟应用属性
	*/
    private function commitProperties() : Void
    {
        if (bitmapDataChanged || widthChanged || heightChanged) 
        {
            var g : Graphics = target;
            g.clear();
            if (_bitmapData != null) 
            {
                g.beginBitmapFill(_bitmapData, null, true);
                g.drawRect(0, 0, _width, _height);
                g.endFill();
            }
            bitmapDataChanged = false;
            widthChanged = false;
            heightChanged = false;
        }
    }
}
