package flexlite.layouts;


import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import flexlite.core.ILayoutElement;
import flexlite.layouts.supportclasses.LayoutBase;
import flexlite.utils.MathUtil;


@:meta(DXML(show="false"))


/**
* 格子布局
* @author weilichuang
*/
class TileLayout extends LayoutBase
{
    public var horizontalGap(get, set) : Float;
    public var verticalGap(get, set) : Float;
    public var columnCount(get, never) : Int;
    public var requestedColumnCount(get, set) : Int;
    public var rowCount(get, never) : Int;
    public var requestedRowCount(get, set) : Int;
    public var columnWidth(get, set) : Float;
    public var rowHeight(get, set) : Float;
    public var padding(get, set) : Float;
    public var paddingLeft(get, set) : Float;
    public var paddingRight(get, set) : Float;
    public var paddingTop(get, set) : Float;
    public var paddingBottom(get, set) : Float;
    public var horizontalAlign(get, set) : String;
    public var verticalAlign(get, set) : String;
    public var columnAlign(get, set) : String;
    public var rowAlign(get, set) : String;
    public var orientation(get, set) : String;
	
	/**
	* 标记horizontalGap被显式指定过 
	*/
    private var explicitHorizontalGap : Float = Math.NaN;
    
    private var _horizontalGap : Float = 6;

	/**
	* 标记verticalGap被显式指定过 
	*/
    private var explicitVerticalGap : Float = Math.NaN;
    
    private var _verticalGap : Float = 6;
	
	private var _columnCount : Int = -1;
    private var _requestedColumnCount : Int = 0;
    private var _rowCount : Int = -1;
    private var _requestedRowCount : Int = 0;
	
	/**
	* 外部显式指定的列宽
	*/
    private var explicitColumnWidth : Float = Math.NaN;
    
    private var _columnWidth : Float = Math.NaN;
    /**
	* 外部显式指定的行高 
	*/
    private var explicitRowHeight : Float = Math.NaN;
    
    private var _rowHeight : Float = Math.NaN;
    private var _padding : Float = 0;
    private var _paddingLeft : Float = Math.NaN;
    private var _paddingRight : Float = Math.NaN;
    private var _paddingTop : Float = Math.NaN;
	
	private var _paddingBottom : Float = Math.NaN;
    private var _horizontalAlign : String = HorizontalAlign.JUSTIFY;
    private var _verticalAlign : String = VerticalAlign.JUSTIFY;
    private var _columnAlign : String = ColumnAlign.LEFT;
    private var _rowAlign : String = RowAlign.TOP;
	private var _orientation : String = TileOrientation.ROWS;
	
	/**
	* 缓存的最大子对象宽度
	*/
    private var maxElementWidth : Float = 0;
    /**
	* 缓存的最大子对象高度 
	*/
    private var maxElementHeight : Float = 0;
	
	/**
	* 当前视图中的第一个元素索引
	*/
    private var startIndex : Int = -1;
    /**
	* 当前视图中的最后一个元素的索引
	*/
    private var endIndex : Int = -1;
    /**
	* 视图的第一个和最后一个元素的索引值已经计算好的标志 
	*/
    private var indexInViewCalculated : Bool = false;
	
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    /**
	* 列之间的水平空间（以像素为单位）。
	*/
    private function get_horizontalGap() : Float
    {
        return _horizontalGap;
    }
    
    private function set_horizontalGap(value : Float) : Float
    {
        if (value == _horizontalGap) 
            return value;
        explicitHorizontalGap = value;
        
        _horizontalGap = value;
        invalidateTargetSizeAndDisplayList();
        if (hasEventListener("gapChanged")) 
            dispatchEvent(new Event("gapChanged"));
        return value;
    }
    
    
    
    /**
	* 行之间的垂直空间（以像素为单位）。
	*/
    private function get_verticalGap() : Float
    {
        return _verticalGap;
    }
    
    private function set_verticalGap(value : Float) : Float
    {
        if (value == _verticalGap) 
            return value;
        explicitVerticalGap = value;
        
        _verticalGap = value;
        invalidateTargetSizeAndDisplayList();
        if (hasEventListener("gapChanged")) 
            dispatchEvent(new Event("gapChanged"));
        return value;
    }
    
    
    
    /**
	* 实际列计数。
	*/
    private function get_columnCount() : Int
    {
        return _columnCount;
    }
    
	
    /**
	* 要显示的列数。设置为0表示自动确定列计数,默认值0。<br/>
	* 注意:当orientation为TileOrientation.COLUMNS(逐列排列元素)且taget被显式设置宽度时，此属性无效。
	*/
    private function get_requestedColumnCount() : Int
    {
        return _requestedColumnCount;
    }
    
    private function set_requestedColumnCount(value : Int) : Int
    {
        if (_requestedColumnCount == value) 
            return value;
        _requestedColumnCount = value;
        _columnCount = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* 实际行计数。
	*/
    private function get_rowCount() : Int
    {
        return _rowCount;
    }
    
    /**
	* 要显示的行数。设置为0表示自动确定行计数,默认值0。<br/>
	* 注意:当orientation为TileOrientation.ROWS(即逐行排列元素,此为默认值)且target被显式设置高度时，此属性无效。
	*/
    private function get_requestedRowCount() : Int
    {
        return _requestedRowCount;
    }
    
    private function set_requestedRowCount(value : Int) : Int
    {
        if (_requestedRowCount == value) 
            return  value;
        _requestedRowCount = value;
        _rowCount = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    
    /**
	* 实际列宽（以像素为单位）。 若未显式设置，则从根据最宽的元素的宽度确定列宽度。
	*/
    private function get_columnWidth() : Float
    {
        return _columnWidth;
    }
    
    /**
	*  @private
	*/
    private function set_columnWidth(value : Float) : Float
    {
        if (value == _columnWidth) 
            return  value;
        explicitColumnWidth = value;
        _columnWidth = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
	
    /**
	* 行高（以像素为单位）。 如果未显式设置，则从元素的高度的最大值确定行高度。
	*/
    private function get_rowHeight() : Float
    {
        return _rowHeight;
    }
    
    /**
	*  @private
	*/
    private function set_rowHeight(value : Float) : Float
    {
        if (value == _rowHeight) 
            return  value;
        explicitRowHeight = value;
        _rowHeight = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
	
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
            return  value;
        _padding = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* 容器的左边缘与布局元素的左边缘之间的最少像素数,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingLeft() : Float
    {
        return _paddingLeft;
    }
    
    private function set_paddingLeft(value : Float) : Float
    {
        if (_paddingLeft == value) 
            return  value;
        
        _paddingLeft = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    /**
	* 容器的右边缘与布局元素的右边缘之间的最少像素数,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingRight() : Float
    {
        return _paddingRight;
    }
    
    private function set_paddingRight(value : Float) : Float
    {
        if (_paddingRight == value) 
            return  value;
        
        _paddingRight = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    /**
	* 容器的顶边缘与第一个布局元素的顶边缘之间的像素数,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingTop() : Float
    {
        return _paddingTop;
    }
    
    private function set_paddingTop(value : Float) : Float
    {
        if (_paddingTop == value) 
            return  value;
        
        _paddingTop = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* 容器的底边缘与最后一个布局元素的底边缘之间的像素数,若为NaN将使用padding的值，默认值：NaN。
	*/
    private function get_paddingBottom() : Float
    {
        return _paddingBottom;
    }
    
    private function set_paddingBottom(value : Float) : Float
    {
        if (_paddingBottom == value) 
            return  value;
        
        _paddingBottom = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* 指定如何在水平方向上对齐单元格内的元素。
	* 支持的值有 HorizontalAlign.LEFT、HorizontalAlign.CENTER、
	* HorizontalAlign.RIGHT、HorizontalAlign.JUSTIFY。
	* 默认值：HorizontalAlign.JUSTIFY
	*/
    private function get_horizontalAlign() : String
    {
        return _horizontalAlign;
    }
    
    private function set_horizontalAlign(value : String) : String
    {
        if (_horizontalAlign == value) 
            return  value;
        
        _horizontalAlign = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* 指定如何在垂直方向上对齐单元格内的元素。
	* 支持的值有 VerticalAlign.TOP、VerticalAlign.MIDDLE、
	* VerticalAlign.BOTTOM、VerticalAlign.JUSTIFY。 
	* 默认值：VerticalAlign.JUSTIFY。
	*/
    private function get_verticalAlign() : String
    {
        return _verticalAlign;
    }
    
    private function set_verticalAlign(value : String) : String
    {
        if (_verticalAlign == value) 
            return  value;
        
        _verticalAlign = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* 指定如何将完全可见列与容器宽度对齐。
	* 设置为 ColumnAlign.LEFT 时，它会关闭列两端对齐。在容器的最后一列和右边缘之间可能存在部分可见的列或空白。这是默认值。
	* 
	* 设置为 ColumnAlign.JUSTIFY_USING_GAP 时，horizontalGap 的实际值将增大，
	* 这样最后一个完全可见列右边缘会与容器的右边缘对齐。仅存在一个完全可见列时，
	* horizontalGap 的实际值将增大，这样它会将任何部分可见列推到容器的右边缘之外。
	* 请注意显式设置 horizontalGap 属性不会关闭两端对齐。它仅确定初始间隙值。两端对齐可能会增大它。
	* 
	* 设置为 ColumnAlign.JUSTIFY_USING_WIDTH 时，columnWidth 的实际值将增大，
	* 这样最后一个完全可见列右边缘会与容器的右边缘对齐。请注意显式设置 columnWidth 属性不会关闭两端对齐。
	* 它仅确定初始列宽度值。两端对齐可能会增大它。
	*/
    private function get_columnAlign() : String
    {
        return _columnAlign;
    }
    
    private function set_columnAlign(value : String) : String
    {
        if (_columnAlign == value) 
            return  value;
        
        _columnAlign = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    private function get_rowAlign() : String
    {
        return _rowAlign;
    }
    /**
	* 指定如何将完全可见行与容器高度对齐。
	* 设置为 RowAlign.TOP 时，它会关闭列两端对齐。在容器的最后一行和底边缘之间可能存在部分可见的行或空白。这是默认值。
	* 
	* 设置为 RowAlign.JUSTIFY_USING_GAP 时，verticalGap 的实际值会增大，
	* 这样最后一个完全可见行底边缘会与容器的底边缘对齐。仅存在一个完全可见行时，verticalGap 的值会增大，
	* 这样它会将任何部分可见行推到容器的底边缘之外。请注意，显式设置 verticalGap
	* 不会关闭两端对齐，而只是确定初始间隙值。两端对齐接着可以增大它。
	* 
	* 设置为 RowAlign.JUSTIFY_USING_HEIGHT 时，rowHeight 的实际值会增大，
	* 这样最后一个完全可见行底边缘会与容器的底边缘对齐。请注意，显式设置 rowHeight 
	* 不会关闭两端对齐，而只是确定初始行高度值。两端对齐接着可以增大它。
	*/
    private function set_rowAlign(value : String) : String
    {
        if (_rowAlign == value) 
            return  value;
        
        _rowAlign = value;
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* 指定是逐行还是逐列排列元素。
	*/
    private function get_orientation() : String
    {
        return _orientation;
    }
    
    private function set_orientation(value : String) : String
    {
        if (_orientation == value) 
            return  value;
        
        _orientation = value;
        invalidateTargetSizeAndDisplayList();
        if (hasEventListener("orientationChanged")) 
            dispatchEvent(new Event("orientationChanged"));
        return value;
    }
    
    /**
	* 标记目标容器的尺寸和显示列表失效
	*/
    private function invalidateTargetSizeAndDisplayList() : Void
    {
        if (target != null) 
        {
            target.invalidateSize();
            target.invalidateDisplayList();
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function measure() : Void
    {
        if (target == null) 
            return;
        
        var savedColumnCount : Int = _columnCount;
        var savedRowCount : Int = _rowCount;
        var savedColumnWidth : Float = _columnWidth;
        var savedRowHeight : Float = _rowHeight;
        
        var measuredWidth : Float = 0;
        var measuredHeight : Float = 0;
        
        calculateRowAndColumn(target.explicitWidth, target.explicitHeight);
        var columnCount : Int = _requestedColumnCount > (0) ? _requestedColumnCount : _columnCount;
        var rowCount : Int = _requestedRowCount > (0) ? _requestedRowCount : _rowCount;
        var horizontalGap : Float = (Math.isNaN(_horizontalGap)) ? 0 : _horizontalGap;
        var verticalGap : Float = (Math.isNaN(_verticalGap)) ? 0 : _verticalGap;
        if (columnCount > 0) 
        {
            measuredWidth = columnCount * (_columnWidth + horizontalGap) - horizontalGap;
        }
        
        if (rowCount > 0) 
        {
            measuredHeight = rowCount * (_rowHeight + verticalGap) - verticalGap;
        }
        
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingL : Float = (Math.isNaN(_paddingLeft)) ? padding : _paddingLeft;
        var paddingR : Float = (Math.isNaN(_paddingRight)) ? padding : _paddingRight;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        
        var hPadding : Float = paddingL + paddingR;
        var vPadding : Float = paddingT + paddingB;
        
        target.measuredWidth = Math.ceil(measuredWidth + hPadding);
        target.measuredHeight = Math.ceil(measuredHeight + vPadding);
        
        _columnCount = savedColumnCount;
        _rowCount = savedRowCount;
        _columnWidth = savedColumnWidth;
        _rowHeight = savedRowHeight;
    }
    
    /**
	* 计算行和列的尺寸及数量
	*/
    private function calculateRowAndColumn(explicitWidth : Float, explicitHeight : Float) : Void
    {
        var horizontalGap : Float = (Math.isNaN(_horizontalGap)) ? 0 : _horizontalGap;
        var verticalGap : Float = (Math.isNaN(_verticalGap)) ? 0 : _verticalGap;
        _rowCount = _columnCount = -1;
        var numElements : Int = target.numElements;
        var count : Int = numElements;
        for (index in 0...count)
		{
            var elt : ILayoutElement = Lib.as(target.getElementAt(index), ILayoutElement);
            if (elt != null && !elt.includeInLayout) 
            {
                numElements--;
            }
        }
        if (numElements == 0) 
        {
            _rowCount = _columnCount = 0;
            return;
        }
        
        if (Math.isNaN(explicitColumnWidth) || Math.isNaN(explicitRowHeight)) 
            updateMaxElementSize();
        
        if (Math.isNaN(explicitColumnWidth)) 
        {
            _columnWidth = maxElementWidth;
        }
        else 
        {
            _columnWidth = explicitColumnWidth;
        }
        if (Math.isNaN(explicitRowHeight)) 
        {
            _rowHeight = maxElementHeight;
        }
        else 
        {
            _rowHeight = explicitRowHeight;
        }
        
        var itemWidth : Float = _columnWidth + horizontalGap;
        //防止出现除数为零的情况
        if (itemWidth <= 0) 
            itemWidth = 1;
        var itemHeight : Float = _rowHeight + verticalGap;
        if (itemHeight <= 0) 
            itemHeight = 1;
        
        var orientedByColumns : Bool = (orientation == TileOrientation.COLUMNS);
        var widthHasSet : Bool = !Math.isNaN(explicitWidth);
        var heightHasSet : Bool = !Math.isNaN(explicitHeight);
        
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingL : Float = (Math.isNaN(_paddingLeft)) ? padding : _paddingLeft;
        var paddingR : Float = (Math.isNaN(_paddingRight)) ? padding : _paddingRight;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        
        if (_requestedColumnCount > 0 || _requestedRowCount > 0) 
        {
            if (_requestedRowCount > 0) 
                _rowCount = MathUtil.minInt(_requestedRowCount, numElements);
            
            if (_requestedColumnCount > 0) 
                _columnCount = MathUtil.minInt(_requestedColumnCount, numElements);
        }
        else if (!widthHasSet && !heightHasSet) 
        {
            var side : Float = Math.sqrt(numElements * itemWidth * itemHeight);
            if (orientedByColumns) 
            {
                _rowCount = MathUtil.maxInt(1, Math.round(side / itemHeight));
            }
            else 
            {
                _columnCount = MathUtil.maxInt(1, Math.round(side / itemWidth));
            }
        }
        else if (widthHasSet && (!heightHasSet || !orientedByColumns)) 
        {
            var targetWidth : Float = Math.max(0,
                    explicitWidth - paddingL - paddingR);
            _columnCount = Math.floor((targetWidth + horizontalGap) / itemWidth);
            _columnCount = MathUtil.maxInt(1, MathUtil.minInt(_columnCount, numElements));
        }
        else 
        {
            var targetHeight : Float = Math.max(0,
                    explicitHeight - paddingT - paddingB);
            _rowCount = Math.floor((targetHeight + verticalGap) / itemHeight);
            _rowCount = MathUtil.maxInt(1, MathUtil.minInt(_rowCount, numElements));
        }
        if (_rowCount == -1) 
            _rowCount = MathUtil.maxInt(1, Math.ceil(numElements / _columnCount));
        if (_columnCount == -1) 
            _columnCount = MathUtil.maxInt(1, Math.ceil(numElements / _rowCount));
        if (_requestedColumnCount > 0 && _requestedRowCount > 0) 
        {
            if (orientation == TileOrientation.ROWS) 
                _rowCount = MathUtil.maxInt(1, Math.ceil(numElements / _requestedColumnCount))
            else 
            _columnCount = MathUtil.maxInt(1, Math.ceil(numElements / _requestedRowCount));
        }
    }
    
    /**
	* 更新最大子对象尺寸
	*/
    private function updateMaxElementSize() : Void
    {
        if (target == null) 
            return;
        if (useVirtualLayout) 
            updateMaxElementSizeVirtual()
        else 
        updateMaxElementSizeReal();
    }
    /**
	* 更新虚拟布局的最大子对象尺寸
	*/
    private function updateMaxElementSizeVirtual() : Void
    {
        var typicalHeight : Float = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
        var typicalWidth : Float = (typicalLayoutRect != null) ? typicalLayoutRect.width : 22;
        maxElementWidth = Math.max(maxElementWidth, typicalWidth);
        maxElementHeight = Math.max(maxElementHeight, typicalHeight);
        
        if ((startIndex != -1) && (endIndex != -1)) 
        {
			var index:Int = startIndex;
            while (index < endIndex)
			{
                var elt : ILayoutElement = Lib.as(target.getVirtualElementAt(index), ILayoutElement);
                if (elt == null || !elt.includeInLayout) 
                {
					index++;
					continue;
                };
                maxElementWidth = Math.max(maxElementWidth, elt.preferredWidth);
                maxElementHeight = Math.max(maxElementHeight, elt.preferredHeight);
				
				index++;
            }
        }
    }
    /**
	* 更新真实布局的最大子对象尺寸
	*/
    private function updateMaxElementSizeReal() : Void
    {
        var numElements : Int = target.numElements;
		var index:Int = 0;
        while( index < numElements)
		{
            var elt : ILayoutElement = Lib.as(target.getElementAt(index), ILayoutElement);
            if (elt == null || !elt.includeInLayout) 
            {
				index++;
				continue;
            };
            maxElementWidth = Math.max(maxElementWidth, elt.preferredWidth);
            maxElementHeight = Math.max(maxElementHeight, elt.preferredHeight);
			index++;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function clearVirtualLayoutCache() : Void
    {
        super.clearVirtualLayoutCache();
        maxElementWidth = 0;
        maxElementHeight = 0;
    }
    
    
    
    /**
	* @inheritDoc
	*/
    override private function scrollPositionChanged() : Void
    {
        super.scrollPositionChanged();
        if (useVirtualLayout) 
        {
            var changed : Bool = getIndexInView();
            if (changed) 
            {
                indexInViewCalculated = true;
                target.invalidateDisplayList();
            }
        }
    }
    
    /**
	* 获取视图中第一个和最后一个元素的索引,返回是否发生改变
	*/
    private function getIndexInView() : Bool
    {
        if (target == null || target.numElements == 0) 
        {
            startIndex = endIndex = -1;
            return false;
        }
        
        var numElements : Int = target.numElements;
        if (!useVirtualLayout) 
        {
            startIndex = 0;
            endIndex = numElements - 1;
            return false;
        }
        
        if (Math.isNaN(target.width) || target.width == 0 || Math.isNaN(target.height) || target.height == 0) 
        {
            startIndex = endIndex = -1;
            return false;
        }
        var oldStartIndex : Int = startIndex;
        var oldEndIndex : Int = endIndex;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var horizontalGap : Float = Math.isNaN(_horizontalGap) ? 0 : _horizontalGap;
        var verticalGap : Float = Math.isNaN(_verticalGap) ? 0 : _verticalGap;
        if (orientation == TileOrientation.COLUMNS) 
        {
            var itemWidth : Float = _columnWidth + horizontalGap;
            if (itemWidth <= 0) 
            {
                startIndex = 0;
                endIndex = numElements - 1;
                return false;
            }
            var minVisibleX : Float = target.horizontalScrollPosition;
            var maxVisibleX : Float = target.horizontalScrollPosition + target.width;
            var startColumn : Int = Math.floor((minVisibleX - paddingL) / itemWidth);
            if (startColumn < 0) 
                startColumn = 0;
            var endColumn : Int = Math.ceil((maxVisibleX - paddingL) / itemWidth);
            if (endColumn < 0) 
                endColumn = 0;
            startIndex = MathUtil.minInt(numElements - 1, MathUtil.maxInt(0, startColumn * _rowCount));
            endIndex = MathUtil.minInt(numElements - 1, MathUtil.maxInt(0, endColumn * _rowCount - 1));
        }
        else 
        {
            var itemHeight : Float = _rowHeight + verticalGap;
            if (itemHeight <= 0) 
            {
                startIndex = 0;
                endIndex = numElements - 1;
                return false;
            }
            var minVisibleY : Float = target.verticalScrollPosition;
            var maxVisibleY : Float = target.verticalScrollPosition + target.height;
            var startRow : Int = Math.floor((minVisibleY - paddingT) / itemHeight);
            if (startRow < 0) 
                startRow = 0;
            var endRow : Int = Math.ceil((maxVisibleY - paddingT) / itemHeight);
            if (endRow < 0) 
                endRow = 0;
            startIndex = MathUtil.minInt(numElements - 1, MathUtil.maxInt(0, startRow * _columnCount));
            endIndex = MathUtil.minInt(numElements - 1, MathUtil.maxInt(0, endRow * _columnCount - 1));
        }
        
        return startIndex != oldStartIndex || endIndex != oldEndIndex;
    }
    
    /**
	* @inheritDoc
	*/
    override public function updateDisplayList(width : Float, height : Float) : Void
    {
        super.updateDisplayList(width, height);
        if (target == null) 
            return;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        
        if (indexInViewCalculated) 
        {
            indexInViewCalculated = false;
        }
        else 
        {
            calculateRowAndColumn(width, height);
            if (_rowCount == 0 || _columnCount == 0) 
            {
                target.setContentSize(paddingL + paddingR, paddingT + paddingB);
                return;
            }
            adjustForJustify(width, height);
            getIndexInView();
        }
        if (useVirtualLayout) 
        {
            calculateRowAndColumn(width, height);
            adjustForJustify(width, height);
        }
        
        if (startIndex == -1 || endIndex == -1) 
        {
            target.setContentSize(0, 0);
            return;
        }
        target.setVirtualElementIndicesInView(startIndex, endIndex);
        var elt : ILayoutElement;
        var x : Float;
        var y : Float;
        var columnIndex : Int;
        var rowIndex : Int;
        var orientedByColumns : Bool = (orientation == TileOrientation.COLUMNS);
        var index : Int = startIndex;
        var horizontalGap : Float = (Math.isNaN(_horizontalGap)) ? 0 : _horizontalGap;
        var verticalGap : Float = (Math.isNaN(_verticalGap)) ? 0 : _verticalGap;
		
		var i:Int = startIndex;
        while(i <= endIndex)
		{
            if (useVirtualLayout) 
                elt = Lib.as(target.getVirtualElementAt(i), ILayoutElement)
            else 
				elt = Lib.as(target.getElementAt(i), ILayoutElement);
				
            if (elt == null || !elt.includeInLayout) 
            {
				i++;
				continue;
            }
            
            if (orientedByColumns) 
            {
                columnIndex = Math.ceil((index + 1) / _rowCount) - 1;
                rowIndex = Math.ceil((index + 1) % _rowCount) - 1;
                if (rowIndex == -1) 
                    rowIndex = _rowCount - 1;
            }
            else 
            {
                columnIndex = Math.ceil((index + 1) % _columnCount) - 1;
                if (columnIndex == -1) 
                    columnIndex = _columnCount - 1;
                rowIndex = Math.ceil((index + 1) / _columnCount) - 1;
            }
            x = columnIndex * (_columnWidth + horizontalGap) + paddingL;
            y = rowIndex * (_rowHeight + verticalGap) + paddingT;
            sizeAndPositionElement(elt, Std.int(x), Std.int(y), Std.int(_columnWidth), Std.int(rowHeight));
            index++;
			
			i++;
        }
        
        var hPadding : Float = paddingL + paddingR;
        var vPadding : Float = paddingT + paddingB;
        var contentWidth : Float = (_columnWidth + horizontalGap) * _columnCount - horizontalGap;
        var contentHeight : Float = (_rowHeight + verticalGap) * _rowCount - verticalGap;
        target.setContentSize(Math.ceil(contentWidth + hPadding), Math.ceil(contentHeight + vPadding));
    }
    
    /**
	* 为单个元素布局
	*/
    private function sizeAndPositionElement(element : ILayoutElement, cellX : Int, cellY : Int,
            cellWidth : Int, cellHeight : Int) : Void
    {
        var elementWidth : Float = Math.NaN;
        var elementHeight : Float = Math.NaN;
        
        if (horizontalAlign == HorizontalAlign.JUSTIFY) 
            elementWidth = cellWidth
        else if (!Math.isNaN(element.percentWidth)) 
            elementWidth = cellWidth * element.percentWidth * 0.01;
        
        if (verticalAlign == VerticalAlign.JUSTIFY) 
            elementHeight = cellHeight
        else if (!Math.isNaN(element.percentHeight)) 
            elementHeight = cellHeight * element.percentHeight * 0.01;
        
        
        element.setLayoutBoundsSize(Math.round(elementWidth), Math.round(elementHeight));
        
        var x : Float = cellX;
        switch (horizontalAlign)
        {
            case HorizontalAlign.RIGHT:
                x += cellWidth - element.layoutBoundsWidth;
            case HorizontalAlign.CENTER:
                x = cellX + (cellWidth - element.layoutBoundsWidth) / 2;
        }
        
        var y : Float = cellY;
        switch (verticalAlign)
        {
            case VerticalAlign.BOTTOM:
                y += cellHeight - element.layoutBoundsHeight;
            case VerticalAlign.MIDDLE:
                y += (cellHeight - element.layoutBoundsHeight) / 2;
        }
        element.setLayoutBoundsPosition(Math.round(x), Math.round(y));
    }
    
    
    /**
	* 为两端对齐调整间隔或格子尺寸
	*/
    private function adjustForJustify(width : Float, height : Float) : Void
    {
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        
        var targetWidth : Float = Math.max(0,
                width - paddingL - paddingR);
        var targetHeight : Float = Math.max(0,
                height - paddingT - paddingB);
        if (!Math.isNaN(explicitVerticalGap)) 
            _verticalGap = explicitVerticalGap;
        if (!Math.isNaN(explicitHorizontalGap)) 
            _horizontalGap = explicitHorizontalGap;
        _verticalGap = (Math.isNaN(_verticalGap)) ? 0 : _verticalGap;
        _horizontalGap = (Math.isNaN(_horizontalGap)) ? 0 : _horizontalGap;
        
        var itemWidth : Float = _columnWidth + _horizontalGap;
        if (itemWidth <= 0) 
            itemWidth = 1;
        var itemHeight : Float = _rowHeight + _verticalGap;
        if (itemHeight <= 0) 
            itemHeight = 1;
        
        var offsetY : Float = targetHeight - _rowHeight * _rowCount;
        var offsetX : Float = targetWidth - _columnWidth * _columnCount;
        var gapCount : Int;
        if (offsetY > 0) 
        {
            if (rowAlign == RowAlign.JUSTIFY_USING_GAP) 
            {
                gapCount = MathUtil.maxInt(1, _rowCount - 1);
                _verticalGap = offsetY / gapCount;
            }
            else if (rowAlign == RowAlign.JUSTIFY_USING_HEIGHT) 
            {
                if (_rowCount > 0) 
                {
                    _rowHeight += (offsetY - (_rowCount - 1) * _verticalGap) / _rowCount;
                }
            }
        }
        if (offsetX > 0) 
        {
            if (columnAlign == ColumnAlign.JUSTIFY_USING_GAP) 
            {
                gapCount = MathUtil.maxInt(1, _columnCount - 1);
                _horizontalGap = offsetX / gapCount;
            }
            else if (columnAlign == ColumnAlign.JUSTIFY_USING_WIDTH) 
            {
                if (_columnCount > 0) 
                {
                    _columnWidth += (offsetX - (_columnCount - 1) * _horizontalGap) / _columnCount;
                }
            }
        }
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsLeftOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var horizontalGap : Float = Math.isNaN(_horizontalGap) ? 0 : _horizontalGap;
        if (scrollRect.left > target.contentWidth - paddingR) 
        {
            bounds.left = target.contentWidth - paddingR;
            bounds.right = target.contentWidth;
        }
        else if (scrollRect.left > paddingL) 
        {
            var column : Int = Math.floor((scrollRect.left - 1 - paddingL) / (_columnWidth + horizontalGap));
            bounds.left = leftEdge(column);
            bounds.right = rightEdge(column);
        }
        else 
        {
            bounds.left = 0;
            bounds.right = paddingL;
        }
        return bounds;
    }
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsRightOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var horizontalGap : Float = Math.isNaN(_horizontalGap) ? 0 : _horizontalGap;
        var bounds : Rectangle = new Rectangle();
        if (scrollRect.right < paddingL) 
        {
            bounds.left = 0;
            bounds.right = paddingL;
        }
        else if (scrollRect.right < target.contentWidth - paddingR) 
        {
            var column : Int = Math.floor(((scrollRect.right + 1 + horizontalGap) - paddingL) / (_columnWidth + horizontalGap));
            bounds.left = leftEdge(column);
            bounds.right = rightEdge(column);
        }
        else 
        {
            bounds.left = target.contentWidth - paddingR;
            bounds.right = target.contentWidth;
        }
        return bounds;
    }
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsAboveScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        var verticalGap : Float = Math.isNaN(_verticalGap) ? 0 : _verticalGap;
        var bounds : Rectangle = new Rectangle();
        if (scrollRect.top > target.contentHeight - paddingB) 
        {
            bounds.top = target.contentHeight - paddingB;
            bounds.bottom = target.contentHeight;
        }
        else if (scrollRect.top > paddingT) 
        {
            var row : Int = Math.floor((scrollRect.top - 1 - paddingT) / (_rowHeight + verticalGap));
            bounds.top = topEdge(row);
            bounds.bottom = bottomEdge(row);
        }
        else 
        {
            bounds.top = 0;
            bounds.bottom = paddingT;
        }
        return bounds;
    }
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsBelowScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        var verticalGap : Float = Math.isNaN(_verticalGap) ? 0 : _verticalGap;
        var bounds : Rectangle = new Rectangle();
        if (scrollRect.bottom < paddingT) 
        {
            bounds.top = 0;
            bounds.bottom = paddingT;
        }
        else if (scrollRect.bottom < target.contentHeight - paddingB) 
        {
            var row : Int = Math.floor(((scrollRect.bottom + 1 + verticalGap) - paddingT) / (_rowHeight + verticalGap));
            bounds.top = topEdge(row);
            bounds.bottom = bottomEdge(row);
        }
        else 
        {
            bounds.top = target.contentHeight - paddingB;
            bounds.bottom = target.contentHeight;
        }
        
        return bounds;
    }
    
    private function leftEdge(columnIndex : Int) : Float
    {
        if (columnIndex < 0) 
            return 0;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var horizontalGap : Float = Math.isNaN(_horizontalGap) ? 0 : _horizontalGap;
        return Math.max(0, columnIndex * (_columnWidth + horizontalGap)) + paddingL;
    }
    
    private function rightEdge(columnIndex : Int) : Float
    {
        if (columnIndex < 0) 
            return 0;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var horizontalGap : Float = Math.isNaN(_horizontalGap) ? 0 : _horizontalGap;
        return Math.min(target.contentWidth, columnIndex * (_columnWidth + horizontalGap) +
                _columnWidth) + paddingL;
    }
    
    @:final private function topEdge(rowIndex : Int) : Float
    {
        if (rowIndex < 0) 
            return 0;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var verticalGap : Float = Math.isNaN(_verticalGap) ? 0 : _verticalGap;
        return Math.max(0, rowIndex * (_rowHeight + verticalGap)) + paddingT;
    }
    
    @:final private function bottomEdge(rowIndex : Int) : Float
    {
        if (rowIndex < 0) 
            return 0;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var verticalGap : Float = Math.isNaN(_verticalGap) ? 0 : _verticalGap;
        return Math.min(target.contentHeight, rowIndex * (_rowHeight + verticalGap) +
                _rowHeight) + paddingT;
    }
}
