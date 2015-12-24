package flexlite.components;


import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;

import flexlite.core.UIComponent;
import flexlite.utils.GraphicsUtil;

@:meta(DXML(show="true"))


/**
* 矩形绘图元素。矩形的角可以是圆角,此组件可响应鼠标事件。
* @author weilichuang
*/
class Rect extends UIComponent
{
    public var fillColor(get, set) : Int;
    public var fillAlpha(get, set) : Float;
    public var strokeColor(get, set) : Int;
    public var strokeAlpha(get, set) : Float;
    public var strokeWeight(get, set) : Float;
    public var radius(get, set) : Float;
    public var topLeftRadius(get, set) : Float;
    public var topRightRadius(get, set) : Float;
    public var bottomLeftRadius(get, set) : Float;
    public var bottomRightRadius(get, set) : Float;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        mouseChildren = false;
    }
    
    private var _fillColor : Int = 0xFFFFFF;
    /**
	* 填充颜色
	*/
    private function get_fillColor() : Int
    {
        return _fillColor;
    }
    private function set_fillColor(value : Int) : Int
    {
        if (_fillColor == value) 
            return value;
        _fillColor = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _fillAlpha : Float = 1;
    /**
	* 填充透明度,默认值为0。
	*/
    private function get_fillAlpha() : Float
    {
        return _fillAlpha;
    }
    private function set_fillAlpha(value : Float) : Float
    {
        if (_fillAlpha == value) 
            return value;
        _fillAlpha = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _strokeColor : Int = 0x444444;
    /**
	* 边框颜色,注意：当strokeAlpha为0时，不显示边框。
	*/
    private function get_strokeColor() : Int
    {
        return _strokeColor;
    }
    
    private function set_strokeColor(value : Int) : Int
    {
        if (_strokeColor == value) 
            return value;
        _strokeColor = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _strokeAlpha : Float = 0;
    /**
	* 边框透明度，默认值为0。
	*/
    private function get_strokeAlpha() : Float
    {
        return _strokeAlpha;
    }
    private function set_strokeAlpha(value : Float) : Float
    {
        if (_strokeAlpha == value) 
            return value;
        _strokeAlpha = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _strokeWeight : Float = 1;
    /**
	* 边框粗细(像素),注意：当strokeAlpha为0时，不显示边框。
	*/
    private function get_strokeWeight() : Float
    {
        return _strokeWeight;
    }
    private function set_strokeWeight(value : Float) : Float
    {
        if (_strokeWeight == value) 
            return value;
        _strokeWeight = value;
        invalidateDisplayList();
        return value;
    }
    
    
    private var _radius : Float = 0;
    /**
	* 设置四个角的为相同的圆角半径。您也可以分别对每个角设置半径，
	* 但若此属性不为0，则分别设置每个角的半径无效。默认值为0。
	*/
    private function get_radius() : Float
    {
        return _radius;
    }
    private function set_radius(value : Float) : Float
    {
        if (value < 0) 
            value = 0;
        if (_radius == value) 
            return value;
        _radius = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _topLeftRadius : Float = 0;
    /**
	* 左上角圆角半径，若设置了radius不为0，则此属性无效。
	*/
    private function get_topLeftRadius() : Float
    {
        return _topLeftRadius;
    }
    private function set_topLeftRadius(value : Float) : Float
    {
        if (value < 0) 
            value = 0;
        if (_topLeftRadius == value) 
            return value;
        _topLeftRadius = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _topRightRadius : Float = 0;
    /**
	* 右上角圆角半径，若设置了radius不为0，则此属性无效。
	*/
    private function get_topRightRadius() : Float
    {
        return _topRightRadius;
    }
    private function set_topRightRadius(value : Float) : Float
    {
        if (value < 0) 
            value = 0;
        if (_topRightRadius == value) 
            return value;
        _topRightRadius = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _bottomLeftRadius : Float = 0;
    /**
	* 左下角圆角半径，若设置了radius不为0，则此属性无效。
	*/
    private function get_bottomLeftRadius() : Float
    {
        return _bottomLeftRadius;
    }
    private function set_bottomLeftRadius(value : Float) : Float
    {
        if (value < 0) 
            value = 0;
        if (_bottomLeftRadius == value) 
            return value;
        _bottomLeftRadius = value;
        invalidateDisplayList();
        return value;
    }
    
    private var _bottomRightRadius : Float = 0;
    /**
	* 右下角圆角半径，若设置了radius不为0，则此属性无效。
	*/
    private function get_bottomRightRadius() : Float
    {
        return _bottomRightRadius;
    }
    private function set_bottomRightRadius(value : Float) : Float
    {
        if (value < 0) 
            value = 0;
        if (_bottomRightRadius == value) 
            return value;
        _bottomRightRadius = value;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledWidth);
        var g : Graphics = graphics;
        g.clear();
        g.beginFill(_fillColor, _fillAlpha);
        if (_strokeAlpha > 0) 
        {
            g.lineStyle(_strokeWeight, _strokeColor, _strokeAlpha, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
        }
        if (_radius > 0) 
        {
            var ellipseSize : Float = _radius * 2;
            g.drawRoundRect(0, 0, unscaledWidth, unscaledHeight,
                    ellipseSize, ellipseSize);
        }
        else if (_topLeftRadius > 0 || _topRightRadius > 0 || _bottomLeftRadius > 0 || _bottomRightRadius > 0) 
        {
            GraphicsUtil.drawRoundRectComplex(g,
                    0, 0, unscaledWidth, unscaledHeight,
                    _topLeftRadius, _topRightRadius,
                    _bottomLeftRadius, _bottomRightRadius);
        }
        else 
        {
            g.drawRect(0, 0, unscaledWidth, unscaledHeight);
        }
        g.endFill();
    }
}
