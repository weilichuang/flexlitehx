package flexlite.components;


import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import flexlite.core.UIComponent;

@:meta(DXML(show="false"))

/**
* 矩形投影显示元素。<br/>
* 此类通常用于替代DropShadowFilter，优化投影性能。
* 当需要对矩形显示对象应用投影时，请尽可能使用此类来替代投影滤镜，以获取更高的性能。
* @author weilichuang
*/
class RectangularDropShadow extends UIComponent
{
    public var angle(get, set) : Float;
    public var color(get, set) : Int;
    public var distance(get, set) : Float;
    public var tlRadius(get, set) : Float;
    public var trRadius(get, set) : Float;
    public var blRadius(get, set) : Float;
    public var brRadius(get, set) : Float;
    public var blurX(get, set) : Float;
    public var blurY(get, set) : Float;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        mouseEnabled = false;
        mouseChildren = false;
    }
    
    /**
	* 投影属性改变标志
	*/
    private var shadowChanged : Bool = false;
    
    private var _alpha : Float = 0.4;
	
    /**
	* @inheritDoc
	*/
	#if flash
	@:getter(alpha)
	#else
	override
	#end
     private function get_alpha() : Float
    {
        return _alpha;
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(alpha) private function set_alpha(value : Float) : Void
    {
        if (_alpha == value) 
            return;
        _alpha = value;
        shadowChanged = true;
        invalidateDisplayList();
    }
	#else
	override private function set_alpha(value : Float) : Float
    {
        if (_alpha == value) 
            return value;
        _alpha = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
	#end
    
    private var _angle : Float = 45.0;
    /**
	* 斜角的角度。有效值为 0 到 360 度。角度值表示理论上的光源落在对象上的角度，
	* 它决定了效果相对于该对象的位置。如果 distance 属性设置为 0，
	* 则效果相对于对象没有偏移，因此 angle 属性不起作用。
	*/
    private function get_angle() : Float
    {
        return _angle;
    }
    
    private function set_angle(value : Float) : Float
    {
        if (_angle == value) 
            return value;
        _angle = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _color : Int = 0;
    /**
	* 光晕颜色。有效值采用十六进制格式 0xRRGGBB。
	*/
    private function get_color() : Int
    {
        return _color;
    }
    
    private function set_color(value : Int) : Int
    {
        if (_color == value) 
            return value;
        _color = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _distance : Float = 4.0;
    /**
	* 阴影的偏移距离，以像素为单位。默认值为 4.0（浮点）。
	*/
    private function get_distance() : Float
    {
        return _distance;
    }
    
    private function set_distance(value : Float) : Float
    {
        if (_distance == value) 
            return value;
        _distance = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _tlRadius : Float = 0;
    /**
	* 投射阴影的圆角矩形左上角的顶点半径。
	*/
    private function get_tlRadius() : Float
    {
        return _tlRadius;
    }
    
    private function set_tlRadius(value : Float) : Float
    {
        if (_tlRadius == value) 
            return value;
        _tlRadius = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _trRadius : Float = 0;
    /**
	* 投射阴影的圆角矩形右上角的顶点半径。
	*/
    private function get_trRadius() : Float
    {
        return _trRadius;
    }
    
    private function set_trRadius(value : Float) : Float
    {
        if (_trRadius == value) 
            return value;
        _trRadius = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _blRadius : Float = 0;
    /**
	* 投射阴影的圆角矩形左下角的顶点半径。
	*/
    private function get_blRadius() : Float
    {
        return _blRadius;
    }
    
    private function set_blRadius(value : Float) : Float
    {
        if (_blRadius == value) 
            return value;
        _blRadius = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _brRadius : Float = 0;
    /**
	* 投射阴影的圆角矩形右下角的顶点半径。
	*/
    private function get_brRadius() : Float
    {
        return _brRadius;
    }
    
    private function set_brRadius(value : Float) : Float
    {
        if (brRadius == value) 
            return value;
        _brRadius = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _blurX : Float = 4;
    /**
	* 水平模糊量。有效值为 0 到 255.0（浮点）。默认值为 4.0。
	*/
    private function get_blurX() : Float
    {
        return _blurX;
    }
    
    private function set_blurX(value : Float) : Float
    {
        if (_blurX == value) 
            return value;
        _blurX = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    private var _blurY : Float = 4;
    /**
	* 垂直模糊量。有效值为 0 到 255.0（浮点）。默认值为 4.0。
	*/
    private function get_blurY() : Float
    {
        return _blurY;
    }
    
    private function set_blurY(value : Float) : Float
    {
        if (_blurY == value) 
            return value;
        _blurY = value;
        shadowChanged = true;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float,
            unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        graphics.clear();
        
        if (shadowChanged) 
        {
            shadowChanged = false;
            createShadowBitmaps();
        }
        drawShadow(0, 0, unscaledWidth, unscaledHeight);
    }
    
    /**
	* 绘制阴影。 
	* @param x 投影位置的水平偏移量。
	* @param y 投影位置的垂直偏移量。
	* @param width 阴影的宽度。
	* @param height 阴影的高度。
	*/
    private function drawShadow(x : Float, y : Float, width : Float, height : Float) : Void
    {
        var g : Graphics = graphics;
        width = Math.ceil(width);
        height = Math.ceil(height);
        var leftThickness : Int = (leftShadow != null) ? leftShadow.width : 0;
        var rightThickness : Int = (rightShadow != null) ? rightShadow.width : 0;
        var topThickness : Int = (topShadow != null) ? topShadow.height : 0;
        var bottomThickness : Int = (bottomShadow != null) ? bottomShadow.height : 0;
        
        var widthThickness : Int = leftThickness + rightThickness;
        var heightThickness : Int = topThickness + bottomThickness;
        var maxCornerHeight : Float = (height + heightThickness) / 2;
        var maxCornerWidth : Float = (width + widthThickness) / 2;
        
		var tlWidth : Float = 0;
		var tlHeight : Float = 0;
        var matrix : Matrix = new Matrix();
        if (leftShadow != null || topShadow != null) 
        {
            tlWidth  = Math.min(tlRadius + widthThickness,
                    maxCornerWidth);
            tlHeight = Math.min(tlRadius + heightThickness,
                    maxCornerHeight);
            
            matrix.tx = x - leftThickness;
            matrix.ty = y - topThickness;
            g.beginBitmapFill(shadow, matrix, false);
            g.drawRect(x - leftThickness, y - topThickness, tlWidth, tlHeight);
            g.endFill();
        }
        
		var trWidth : Float = 0;
		var trHeight : Float = 0;
        if (rightShadow != null || topShadow != null) 
        {
            trWidth = Math.min(trRadius + widthThickness,
                    maxCornerWidth);
            trHeight = Math.min(trRadius + heightThickness,
                    maxCornerHeight);
            
            matrix.tx = x + width + rightThickness - shadow.width;
            matrix.ty = y - topThickness;
            
            g.beginBitmapFill(shadow, matrix, false);
            g.drawRect(x + width + rightThickness - trWidth,
                    y - topThickness,
                    trWidth, trHeight);
            g.endFill();
        }
        
		var blWidth : Float = 0;
		var blHeight : Float = 0;
        if (leftShadow != null || bottomShadow != null) 
        {
            blWidth = Math.min(blRadius + widthThickness,
                    maxCornerWidth);
            blHeight  = Math.min(blRadius + heightThickness,
                    maxCornerHeight);
            
            matrix.tx = x - leftThickness;
            matrix.ty = y + height + bottomThickness - shadow.height;
            
            g.beginBitmapFill(shadow, matrix, false);
            g.drawRect(x - leftThickness,
                    y + height + bottomThickness - blHeight,
                    blWidth, blHeight);
            g.endFill();
        }
        
		var brWidth : Float = 0;
		var brHeight : Float = 0;
        if (rightShadow != null || bottomShadow != null) 
        {
            brWidth = Math.min(brRadius + widthThickness,
                    maxCornerWidth);
            brHeight = Math.min(brRadius + heightThickness,
                    maxCornerHeight);
            
            matrix.tx = x + width + rightThickness - shadow.width;
            matrix.ty = y + height + bottomThickness - shadow.height;
            
            g.beginBitmapFill(shadow, matrix, false);
            g.drawRect(x + width + rightThickness - brWidth,
                    y + height + bottomThickness - brHeight,
                    brWidth, brHeight);
            g.endFill();
        }
        if (leftShadow != null) 
        {
            matrix.tx = x - leftThickness;
            matrix.ty = 0;
            
            g.beginBitmapFill(leftShadow, matrix, false);
            g.drawRect(x - leftThickness,
                    y - topThickness + tlHeight,
                    leftThickness,
                    height + topThickness +
                    bottomThickness - tlHeight - blHeight);
            g.endFill();
        }
        
        if (rightShadow != null) 
        {
            matrix.tx = x + width;
            matrix.ty = 0;
            
            g.beginBitmapFill(rightShadow, matrix, false);
            g.drawRect(x + width,
                    y - topThickness + trHeight,
                    rightThickness,
                    height + topThickness +
                    bottomThickness - trHeight - brHeight);
            g.endFill();
        }
        
        if (topShadow != null) 
        {
            matrix.tx = 0;
            matrix.ty = y - topThickness;
            
            g.beginBitmapFill(topShadow, matrix, false);
            g.drawRect(x - leftThickness + tlWidth,
                    y - topThickness,
                    width + leftThickness +
                    rightThickness - tlWidth - trWidth,
                    topThickness);
            g.endFill();
        }
        
        if (bottomShadow != null) 
        {
            matrix.tx = 0;
            matrix.ty = y + height;
            
            g.beginBitmapFill(bottomShadow, matrix, false);
            g.drawRect(x - leftThickness + blWidth,
                    y + height,
                    width + leftThickness +
                    rightThickness - blWidth - brWidth,
                    bottomThickness);
            g.endFill();
        }
    }
    
    private var shadow : BitmapData;
    
    private var leftShadow : BitmapData;
    
    private var rightShadow : BitmapData;
    
    private var topShadow : BitmapData;
    
    private var bottomShadow : BitmapData;
    /**
	* 创建四个方向缓存的投影位图数据
	*/
    private function createShadowBitmaps() : Void
    {
        var roundRectWidth : Float = Math.max(tlRadius, blRadius) +
        3 * Math.max(Math.abs(distance), 2) +
        Math.max(trRadius, brRadius);
        var roundRectHeight : Float = Math.max(tlRadius, trRadius) +
        3 * Math.max(Math.abs(distance), 2) +
        Math.max(blRadius, brRadius);
        
        if (roundRectWidth < 0 || roundRectHeight < 0) 
            return;
        
        var roundRect : Shape = new Shape();
        var g : Graphics = roundRect.graphics;
        g.beginFill(0xFFFFFF);
        drawRoundRectComplex(
                g, 0, 0, roundRectWidth, roundRectHeight,
                tlRadius, trRadius, blRadius, brRadius);
        g.endFill();
        var roundRectBitmap : BitmapData = new BitmapData(Std.int(roundRectWidth), Std.int(roundRectHeight), true, 0x00000000);
        roundRectBitmap.draw(roundRect, new Matrix());
        var filter : DropShadowFilter = 
        new DropShadowFilter(distance, angle, color, alpha, blurX, blurY);
        filter.knockout = true;
        var inputRect : Rectangle = new Rectangle(0, 0, 
        roundRectWidth, roundRectHeight);
        var outputRect : Rectangle = 
        roundRectBitmap.generateFilterRect(inputRect, filter);
        var leftThickness : Float = inputRect.left - outputRect.left;
        var rightThickness : Float = outputRect.right - inputRect.right;
        var topThickness : Float = inputRect.top - outputRect.top;
        var bottomThickness : Float = outputRect.bottom - inputRect.bottom;
        shadow = new BitmapData(Std.int(outputRect.width), Std.int(outputRect.height));
        shadow.applyFilter(roundRectBitmap, inputRect,
                new Point(leftThickness, topThickness),
                filter);
        var origin : Point = new Point(0, 0);
        var rect : Rectangle = new Rectangle();
        
        if (leftThickness > 0) 
        {
            rect.x = 0;
            rect.y = tlRadius + topThickness + bottomThickness;
            rect.width = leftThickness;
            rect.height = 1;
            
            leftShadow = new BitmapData(leftThickness < 1 ? 1 : Std.int(leftThickness), 1);
            leftShadow.copyPixels(shadow, rect, origin);
        }
        else 
        {
            leftShadow = null;
        }
        
        if (rightThickness > 0) 
        {
            rect.x = shadow.width - rightThickness;
            rect.y = trRadius + topThickness + bottomThickness;
            rect.width = rightThickness;
            rect.height = 1;
            
            rightShadow = new BitmapData(rightThickness < 1 ? 1 : Std.int(rightThickness), 1);
            rightShadow.copyPixels(shadow, rect, origin);
        }
        else 
        {
            rightShadow = null;
        }
        
        if (topThickness > 0) 
        {
            rect.x = tlRadius + leftThickness + rightThickness;
            rect.y = 0;
            rect.width = 1;
            rect.height = topThickness;
            
            topShadow = new BitmapData(1, Std.int(topThickness));
            topShadow.copyPixels(shadow, rect, origin);
        }
        else 
        {
            topShadow = null;
        }
        
        if (bottomThickness > 0) 
        {
            rect.x = blRadius + leftThickness + rightThickness;
            rect.y = shadow.height - bottomThickness;
            rect.width = 1;
            rect.height = bottomThickness;
            
            bottomShadow = new BitmapData(1, bottomThickness < 1 ? 1 : Std.int(bottomThickness));
            bottomShadow.copyPixels(shadow, rect, origin);
        }
        else 
        {
            bottomShadow = null;
        }
    }
    /**
	* 绘制四个角圆角值不同的矩形。
	*/
    private static function drawRoundRectComplex(graphics : Graphics, x : Float, y : Float,
            width : Float, height : Float,
            topLeftRadius : Float, topRightRadius : Float,
            bottomLeftRadius : Float, bottomRightRadius : Float) : Void
    {
        var xw : Float = x + width;
        var yh : Float = y + height;
        var minSize : Float = width < height  ? width * 2 : height * 2;
        topLeftRadius = topLeftRadius < minSize ? topLeftRadius : minSize;
        topRightRadius = topRightRadius < minSize ? topRightRadius : minSize;
        bottomLeftRadius = bottomLeftRadius < minSize ? bottomLeftRadius : minSize;
        bottomRightRadius = bottomRightRadius < minSize ? bottomRightRadius : minSize;
        var a : Float = bottomRightRadius * 0.292893218813453;
        var s : Float = bottomRightRadius * 0.585786437626905;
        graphics.moveTo(xw, yh - bottomRightRadius);
        graphics.curveTo(xw, yh - s, xw - a, yh - a);
        graphics.curveTo(xw - s, yh, xw - bottomRightRadius, yh);
        a = bottomLeftRadius * 0.292893218813453;
        s = bottomLeftRadius * 0.585786437626905;
        graphics.lineTo(x + bottomLeftRadius, yh);
        graphics.curveTo(x + s, yh, x + a, yh - a);
        graphics.curveTo(x, yh - s, x, yh - bottomLeftRadius);
        a = topLeftRadius * 0.292893218813453;
        s = topLeftRadius * 0.585786437626905;
        graphics.lineTo(x, y + topLeftRadius);
        graphics.curveTo(x, y + s, x + a, y + a);
        graphics.curveTo(x + s, y, x + topLeftRadius, y);
        a = topRightRadius * 0.292893218813453;
        s = topRightRadius * 0.585786437626905;
        graphics.lineTo(xw - topRightRadius, y);
        graphics.curveTo(xw - s, y, xw - a, y + a);
        graphics.curveTo(xw, y + s, xw, y + topRightRadius);
        graphics.lineTo(xw, yh - bottomRightRadius);
    }
}
