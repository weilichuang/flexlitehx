package flexlite.dxr;

import flash.display.BitmapData;
import flash.geom.Point;
import flexlite.core.IBitmapAsset;
import flexlite.dxr.IDxrDisplay;
import flexlite.dxr.Scale9GridBitmap;


/**
* DXR形状。
* 请根据实际需求选择最佳的IDxrDisplay呈现DxrData。
* DxrShape具有位图九宫格缩放功能，但不具有鼠标事件响应。
* @author weilichuang
*/
class DxrShape extends Scale9GridBitmap implements IDxrDisplay implements IBitmapAsset
{
    public var dxrData(get, set) : DxrData;
    public var measuredWidth(get, never) : Float;
    public var measuredHeight(get, never) : Float;

    /**
	* 构造函数
	* @param data 被引用的DxrData对象
	* @param smoothing 在缩放时是否对位图进行平滑处理。
	*/
    public function new(data : DxrData = null, smoothing : Bool = true)
    {
        super(null, null, smoothing);
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
            scale9Grid = dxrData.scale9Grid;
            _offsetPoint = dxrData.getFrameOffset(0);
            var sizeOffset : Point = dxrData.getFilterOffset(0);
            if (sizeOffset == null) 
                sizeOffset = new Point();
            filterWidth = sizeOffset.x;
            filterHeight = sizeOffset.y;
            super.bitmapData = dxrData.getBitmapData(0);
        }
        else 
        {
            scale9Grid = null;
            _offsetPoint = null;
            filterWidth = 0;
            filterHeight = 0;
            super.bitmapData = null;
        }
        return value;
    }
    
    /**
	* 被引用的BitmapData对象。注意:此属性被改为只读，对其赋值无效。
	* IDxrDisplay只能通过设置dxrData属性来显示位图数据。
	*/
    override private function get_bitmapData() : BitmapData
    {
        return super.bitmapData;
    }
    override private function set_bitmapData(value : BitmapData) : BitmapData
    {
        return value;
    }
	
	public function getBitmapData():BitmapData
	{
		return super.bitmapData;
	}
    
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
}
