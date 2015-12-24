package flexlite.dxr;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flexlite.utils.MathUtil;

import flexlite.core.IInvalidateDisplay;



/**
* 具有九宫格缩放功能的位图显示对象
* 注意：此类不具有鼠标事件
* @author weilichuang
*/
class Scale9GridBitmap extends Shape implements IInvalidateDisplay
{
    public var smoothing(get, set) : Bool;
    public var bitmapData(get, set) : BitmapData;
    public var offsetPoint(get, set) : Point;

    /**
	* 构造函数
	* @param bitmapData 被引用的BitmapData对象。
	* @param target 要绘制到的目标Graphics对象，若不传入，则绘制到自身。
	* @param smoothing 在缩放时是否对位图进行平滑处理。
	*/
    public function new(bitmapData : BitmapData = null, target : Graphics = null, smoothing : Bool = false)
    {
        super();
        if (target != null) 
            this.target = target;
        else 
			this.target = graphics;
        this._smoothing = smoothing;
        if (bitmapData != null) 
            this.bitmapData = bitmapData;
    }
    /**
	* smoothing改变标志
	*/
    private var smoothingChanged : Bool = false;
    
    private var _smoothing : Bool;
    /**
	* 在缩放时是否对位图进行平滑处理。
	*/
    private function get_smoothing() : Bool
    {
        return _smoothing;
    }
    private function set_smoothing(value : Bool) : Bool
    {
        if (_smoothing == value) 
            return value;
        _smoothing = value;
        smoothingChanged = true;
        invalidateProperties();
        return value;
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
        cachedSourceGrid = null;
        cachedDestGrid = null;
        if (value != null) 
        {
            if (!widthExplicitSet) 
                _width = _bitmapData.width - filterWidth;
            if (!heightExplicitSet) 
                _height = _bitmapData.height - filterHeight;
            bitmapDataChanged = true;
            invalidateProperties();
        }
        else 
        {
            target.clear();
            if (!widthExplicitSet) 
                _width = Math.NaN;
            if (!heightExplicitSet) 
                _height = Math.NaN;
        }
        return value;
    }
    
    private var scale9GridChanged : Bool = false;
    
    private var _scale9Grid : Rectangle;
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:getter(scale9Grid) 
	#else
	override 
	#end
    private function get_scale9Grid() : Rectangle
    {
        return _scale9Grid;
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(scale9Grid) private function set_scale9Grid(value : Rectangle) : Void
    {
        if (value != null && _scale9Grid != null && value.equals(_scale9Grid)) 
            return;
        cachedDestGrid = null;
        cachedSourceGrid = null;
        _scale9Grid = value;
        scale9GridChanged = true;
        invalidateProperties();
    }
	#else
	override private function set_scale9Grid(value : Rectangle) : Rectangle
    {
        if (value != null && _scale9Grid != null && value.equals(_scale9Grid)) 
            return value;
        cachedDestGrid = null;
        cachedSourceGrid = null;
        _scale9Grid = value;
        scale9GridChanged = true;
        invalidateProperties();
        return value;
    } 
	#end
    
    
    private var offsetPointChanged : Bool = false;
    
    private var _offsetPoint : Point;
    
    /**
	* 位图起始位置偏移量。
	* 注意：如果同时设置了scale9Grid属性，将会影响九宫格绘制的结果。
	* 这与直接设置xy效果不同，后者只是先应用了scale9Grid再平移一次。
	*/
    private function get_offsetPoint() : Point
    {
        return _offsetPoint;
    }
    
    /**
	* @private
	*/
    private function set_offsetPoint(value : Point) : Point
    {
        if (_offsetPoint == value) 
            return value;
        _offsetPoint = value;
        offsetPointChanged = true;
        invalidateProperties();
        return value;
    }
    
    private var widthChanged : Bool = false;
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
        widthChanged = true;
        invalidateProperties();
    }
	#else
	override private function set_width(value : Float) : Float
    {
        if (value == _width) 
            return value;
        _width = value;
        widthExplicitSet = !Math.isNaN(value);
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
        widthChanged = true;
        invalidateProperties();
    }
	#else
	override private function set_height(value : Float) : Float
    {
        if (_height == value) 
            return value;
        _height = value;
        heightExplicitSet = !Math.isNaN(value);
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
        if (bitmapDataChanged || widthChanged || heightChanged ||
            scale9GridChanged || offsetPointChanged || smoothingChanged) 
        {
            if (_bitmapData != null) 
                applyBitmapData();
            scale9GridChanged = false;
            offsetPointChanged = false;
            smoothingChanged = false;
        }
    }
    
    /**
	* 滤镜宽度,在子类中赋值
	*/
    private var filterWidth : Float = 0;
    /**
	* 滤镜高度,在子类中赋值
	*/
    private var filterHeight : Float = 0;
    /**
	* 缓存的源九宫格网格坐标数据
	*/
    private var cachedSourceGrid : Array<Dynamic>;
    /**
	* 缓存的目标九宫格网格坐标数据
	*/
    private var cachedDestGrid : Array<Dynamic>;
    /**
	* 应用bitmapData属性
	*/
    private function applyBitmapData() : Void
    {
        target.clear();
        if (_scale9Grid != null) 
        {
            if (widthChanged || heightChanged) 
            {
                cachedDestGrid = null;
                widthChanged = false;
                heightChanged = false;
            }
            if (_height == 0 || _width == 0) 
                return;
            applyScaledBitmapData(this);
        }
        else 
        {
            if (_height == 0 || _width == 0) 
                return;
            var offset : Point = _offsetPoint;
            if (offset == null) 
                offset = new Point();
            matrix.identity();
            matrix.scale((_width + filterWidth) / _bitmapData.width, (_height + filterHeight) / _bitmapData.height);
            matrix.translate(offset.x, offset.y);
            
            target.beginBitmapFill(bitmapData, matrix, false, _smoothing);
            target.drawRect(offset.x, offset.x, (_width + filterWidth), (_height + filterHeight));
            target.endFill();
        }
    }
    
    private static var matrix : Matrix = new Matrix();
    /**
	* 应用具有九宫格缩放规则的位图数据
	*/
    private static function applyScaledBitmapData(target : Scale9GridBitmap) : Void
    {
        var bitmapData : BitmapData = target.bitmapData;
        var width : Float = target.width + target.filterWidth;
        var height : Float = target.height + target.filterHeight;
        var offset : Point = target.offsetPoint;
        if (offset == null) 
        {
            offset = new Point();
        }
        var roundedDrawX : Float = Math.round(offset.x * width / bitmapData.width);
        var roundedDrawY : Float = Math.round(offset.y * height / bitmapData.height);
        var s9g : Rectangle = new Rectangle(
        target.scale9Grid.x - Math.round(offset.x), target.scale9Grid.y - Math.round(offset.y), 
        target.scale9Grid.width, target.scale9Grid.height);
        //防止空心的情况出现。
        if (s9g.top == s9g.bottom) 
        {
            if (s9g.bottom < bitmapData.height) 
                s9g.bottom++
            else 
				s9g.top--;
        }
        if (s9g.left == s9g.right) 
        {
            if (s9g.right < bitmapData.width) 
                s9g.right++
            else 
				s9g.left--;
        }
        var cachedSourceGrid : Array<Dynamic> = target.cachedSourceGrid;
        if (cachedSourceGrid == null) 
        {
            cachedSourceGrid = target.cachedSourceGrid = [];
            cachedSourceGrid.push([new Point(0, 0), new Point(s9g.left, 0), 
                    new Point(s9g.right, 0), new Point(bitmapData.width, 0)]);
            cachedSourceGrid.push([new Point(0, s9g.top), new Point(s9g.left, s9g.top), 
                    new Point(s9g.right, s9g.top), new Point(bitmapData.width, s9g.top)]);
            cachedSourceGrid.push([new Point(0, s9g.bottom), new Point(s9g.left, s9g.bottom), 
                    new Point(s9g.right, s9g.bottom), new Point(bitmapData.width, s9g.bottom)]);
            cachedSourceGrid.push([new Point(0, bitmapData.height), new Point(s9g.left, bitmapData.height), 
                    new Point(s9g.right, bitmapData.height), new Point(bitmapData.width, bitmapData.height)]);
        }
        
        var cachedDestGrid : Array<Dynamic> = target.cachedDestGrid;
        if (cachedDestGrid == null) 
        {
            var destScaleGridBottom : Float = height - (bitmapData.height - s9g.bottom);
            var destScaleGridRight : Float = width - (bitmapData.width - s9g.right);
            if (bitmapData.width - s9g.width > width) 
            {
                var a : Float = (bitmapData.width - s9g.right) / s9g.left;
                var center : Float = width / (1 + a);
                destScaleGridRight = s9g.left = s9g.right = Math.round((Math.isNaN(center)) ? 0 : center);
            }
            if (bitmapData.height - s9g.height > height) 
            {
                var b : Float = (bitmapData.height - s9g.bottom) / s9g.top;
                var middle : Float = height / (1 + b);
                destScaleGridBottom = s9g.top = s9g.bottom = Math.round((Math.isNaN(middle)) ? 0 : middle);
            }
            cachedDestGrid = target.cachedDestGrid = [];
            cachedDestGrid.push([new Point(0, 0), new Point(s9g.left, 0), 
                    new Point(destScaleGridRight, 0), new Point(width, 0)]);
            cachedDestGrid.push([new Point(0, s9g.top), new Point(s9g.left, s9g.top), 
                    new Point(destScaleGridRight, s9g.top), new Point(width, s9g.top)]);
            cachedDestGrid.push([new Point(0, destScaleGridBottom), new Point(s9g.left, destScaleGridBottom), 
                    new Point(destScaleGridRight, destScaleGridBottom), new Point(width, destScaleGridBottom)]);
            cachedDestGrid.push([new Point(0, height), new Point(s9g.left, height), 
                    new Point(destScaleGridRight, height), new Point(width, height)]);
        }
        
        var sourceSection : Rectangle = new Rectangle();
        var destSection : Rectangle = new Rectangle();
        
        var g : Graphics = target.target;
        g.clear();
        
        for (rowIndex in 0...3)
		{
			var colIndex:Int = 0;
            while (colIndex < 3)
			{
                sourceSection.topLeft = cachedSourceGrid[rowIndex][colIndex];
                sourceSection.bottomRight = cachedSourceGrid[rowIndex + 1][colIndex + 1];
                
                destSection.topLeft = cachedDestGrid[rowIndex][colIndex];
                destSection.bottomRight = cachedDestGrid[rowIndex + 1][colIndex + 1];
                if (destSection.width == 0 || destSection.height == 0 ||
                    sourceSection.width == 0 || sourceSection.height == 0) 
				{
					colIndex++;
					continue;
                }
                matrix.identity();
                matrix.scale(destSection.width / sourceSection.width, destSection.height / sourceSection.height);
                matrix.translate(destSection.x - sourceSection.x * matrix.a, destSection.y - sourceSection.y * matrix.d);
                matrix.translate(roundedDrawX, roundedDrawY);
                
                g.beginBitmapFill(bitmapData, matrix, false, target._smoothing);
                g.drawRect(destSection.x + roundedDrawX, destSection.y + roundedDrawY, destSection.width, destSection.height);
                g.endFill();
				
				colIndex++;
            }
        }
    }
}
