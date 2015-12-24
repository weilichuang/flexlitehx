package flexlite.dxr;

import flexlite.dxr.DxrData;
import flexlite.dxr.IDxrDisplay;
import flexlite.utils.MathUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;

import flexlite.core.IBitmapAsset;


/**
* DXR位图显示对象。
* 请根据实际需求选择最佳的IDxrDisplay呈现DxrData。
* DxrBitmap为最轻量级的IDxrDisplay。不具有位图九宫格缩放和鼠标事件响应功能。
* 注意：DxrBitmap需要在外部手动添加起始坐标偏移量。
* @author weilichuang
*/
class DxrBitmap extends Bitmap implements IBitmapAsset implements IDxrDisplay
{
    public var dxrData(get, set) : DxrData;
    public var measuredWidth(get, never) : Float;
    public var measuredHeight(get, never) : Float;

    /**
	* 构造函数,注意：DxrBitmap需要在外部手动添加起始坐标偏移量。
	* @param data 被引用的DxrData对象
	*/
    public function new(data : DxrData = null)
    {
        super();
        if (data != null) 
            dxrData = data;
    }
    
    private var _dxrData : DxrData;
    /**
	* 被引用的DxrData对象
	*/
    private function get_dxrData() : DxrData
    {
        return _dxrData;
    }
    
    private function set_dxrData(value : DxrData) : DxrData
    {
        if (value == _dxrData) 
            return value;
        _dxrData = value;
        if (value != null) 
        {
            var sizeOffset : Point = dxrData.getFilterOffset(0);
            if (sizeOffset == null) 
                sizeOffset = new Point();
            filterWidth = sizeOffset.x;
            filterHeight = sizeOffset.y;
            super.bitmapData = dxrData.getBitmapData(0);
            smoothing = true;
            if (widthExplicitSet) 
                super.width = _width == (0) ? 0 : _width + filterWidth
            else 
            _width = super.bitmapData.width - filterWidth;
            if (heightExplicitSet) 
                super.height = _height == (0) ? 0 : _height + filterHeight
            else 
            _height = super.bitmapData.height - filterHeight;
        }
        else 
        {
            filterWidth = 0;
            filterHeight = 0;
            if (!widthExplicitSet) 
                _width = Math.NaN;
            if (!heightExplicitSet) 
                _height = Math.NaN;
            super.bitmapData = null;
        }
        return value;
    }
    /**
	* 滤镜宽度
	*/
    private var filterWidth : Float = 0;
    /**
	* 宽度显式设置标记
	*/
    private var widthExplicitSet : Bool = false;
    
    private var _width : Float;
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
        return MathUtil.escapeNaN(_width);
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(width) private function set_width(value : Float) : Void
    {
        if (value == _width) 
            return;
        _width = value;
        widthExplicitSet = !Math.isNaN(value);
        if (dxrData != null) 
        {
            if (_width == 0) 
                super.width = 0
            else 
            super.width = MathUtil.escapeNaN(_width) + filterWidth;
        }
    }
	#else
	override private function set_width(value : Float) : Float
    {
        if (value == _width) 
            return value;
        _width = value;
        widthExplicitSet = !Math.isNaN(value);
        if (dxrData != null) 
        {
            if (_width == 0) 
                super.width = 0
            else 
            super.width = MathUtil.escapeNaN(_width) + filterWidth;
        }
        return value;
    } 
	#end
    
    
    /**
	* 素材的默认宽度（以像素为单位）。
	*/
    private function get_measuredWidth() : Float
    {
        if (bitmapData != null) 
            return bitmapData.width - filterWidth;
        return 0;
    }
    /**
	* 素材的默认高度（以像素为单位）。
	*/
    private function get_measuredHeight() : Float
    {
        if (bitmapData != null) 
            return bitmapData.height - filterHeight;
        return 0;
    }
    
    /**
	* 滤镜高度
	*/
    private var filterHeight : Float = 0;
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
        return MathUtil.escapeNaN(_height);
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(height) private function set_height(value : Float) : Void
    {
        if (_height == value) 
            return;
        _height = value;
        heightExplicitSet = !Math.isNaN(value);
        if (dxrData != null) 
        {
            if (_height == 0) 
                super.height = 0
            else 
            super.height = MathUtil.escapeNaN(_height) + filterHeight;
        }
    }
	#else
	override private function set_height(value : Float) : Float
    {
        if (_height == value) 
            return value;
        _height = value;
        heightExplicitSet = !Math.isNaN(value);
        if (dxrData != null) 
        {
            if (_height == 0) 
                super.height = 0
            else 
            super.height = MathUtil.escapeNaN(_height) + filterHeight;
        }
        return value;
    } 
	#end
    
    /**
	* 被引用的BitmapData对象。注意:此属性被改为只读，对其赋值无效。
	* IDxrDisplay只能通过设置dxrData属性来显示位图数据。
	*/
	#if flash
	@:getter(bitmapData) 
	#else
	override 
	#end
     private function get_bitmapData() : BitmapData
    {
        return super.bitmapData;
    }
	
	public function getBitmapData():BitmapData
	{
		return this.bitmapData;
	}
	
	#if flash
	@:setter(bitmapData) private function set_bitmapData(value : BitmapData) : Void
    {
    } 
	#else
	override private function set_bitmapData(value : BitmapData) : BitmapData
    {
        return value;
    }
	#end
    
}
