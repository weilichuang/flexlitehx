package flexlite.layouts;


import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import flexlite.core.ILayoutElement;
import flexlite.core.IVisualElement;
import flexlite.layouts.supportclasses.LayoutBase;
import flexlite.utils.MathUtil;
import haxe.ds.ObjectMap;


@:meta(DXML(show="false"))


/**
* 水平布局
* @author weilichuang
*/
class HorizontalLayout extends LayoutBase
{
    public var horizontalAlign(get, set) : String;
    public var verticalAlign(get, set) : String;
    public var gap(get, set) : Float;
    public var padding(get, set) : Float;
    public var paddingLeft(get, set) : Float;
    public var paddingRight(get, set) : Float;
    public var paddingTop(get, set) : Float;
    public var paddingBottom(get, set) : Float;
	
	private var _horizontalAlign : String = HorizontalAlign.LEFT;
	private var _verticalAlign : String = VerticalAlign.TOP;
	private var _gap : Float = 6;
    private var _padding : Float = 0;
    private var _paddingLeft : Float = Math.NaN;
    private var _paddingRight : Float = Math.NaN;
    private var _paddingTop : Float = Math.NaN;
    private var _paddingBottom : Float = Math.NaN;
	
	/**
	* 虚拟布局使用的当前视图中的第一个元素索引
	*/
    private var startIndex : Int = -1;
    /**
	* 虚拟布局使用的当前视图中的最后一个元素的索引
	*/
    private var endIndex : Int = -1;
    /**
	* 视图的第一个和最后一个元素的索引值已经计算好的标志 
	*/
    private var indexInViewCalculated : Bool = false;
	
	/**
	* 虚拟布局使用的子对象尺寸缓存 
	*/
    private var elementSizeTable : Array<Float> = [];
	
	/**
	* 子对象最大宽度 
	*/
    private var maxElementHeight : Float = 0;

    public function new()
    {
        super();
    }
    
    
    /**
	* 布局元素的水平对齐策略。参考HorizontalAlign定义的常量。
	* 注意：此属性设置为CONTENT_JUSTIFY始终无效。当useVirtualLayout为true时，设置JUSTIFY也无效。
	*/
    private function get_horizontalAlign() : String
    {
        return _horizontalAlign;
    }
    
    private function set_horizontalAlign(value : String) : String
    {
        if (_horizontalAlign == value) 
            return value;
        _horizontalAlign = value;
        if (target != null) 
            target.invalidateDisplayList();
        return value;
    }
    
    
    /**
	* 布局元素的竖直对齐策略。参考VerticalAlign定义的常量。
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
        if (target != null) 
            target.invalidateDisplayList();
        return value;
    }
    
    
    /**
	* 布局元素之间的水平空间（以像素为单位）
	*/
    private function get_gap() : Float
    {
        return _gap;
    }
    
    private function set_gap(value : Float) : Float
    {
        if (_gap == value) 
            return value;
        _gap = value;
        invalidateTargetSizeAndDisplayList();
        if (hasEventListener("gapChanged")) 
            dispatchEvent(new Event("gapChanged"));
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
            return value;
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
            return value;
        
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
            return value;
        
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
            return value;
        
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
            return value;
        
        _paddingBottom = value;
        invalidateTargetSizeAndDisplayList();
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
        super.measure();
        if (target == null) 
            return;
        if (useVirtualLayout) 
        {
            measureVirtual();
        }
        else 
        {
            measureReal();
        }
    }
    
    /**
	* 测量使用虚拟布局的尺寸
	*/
    private function measureVirtual() : Void
    {
        var numElements : Int = target.numElements;
        var typicalHeight : Float = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
        var typicalWidth : Float = (typicalLayoutRect != null) ? typicalLayoutRect.width : 71;
        var measuredWidth : Float = getElementTotalSize();
        var measuredHeight : Float = Math.max(maxElementHeight, typicalHeight);
        
        var visibleIndices : Array<Int> = target.getElementIndicesInView();
        for (i in visibleIndices)
        {
            var layoutElement : ILayoutElement = Lib.as(target.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
                continue;
            
            var preferredWidth : Float = layoutElement.preferredWidth;
            var preferredHeight : Float = layoutElement.preferredHeight;
            measuredWidth += preferredWidth;
            measuredWidth -= Math.isNaN(elementSizeTable[i]) ? typicalWidth : elementSizeTable[i];
            measuredHeight = Math.max(measuredHeight, preferredHeight);
        }
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        
        var hPadding : Float = paddingL + paddingR;
        var vPadding : Float = paddingT + paddingB;
        target.measuredWidth = Math.ceil(measuredWidth + hPadding);
        target.measuredHeight = Math.ceil(measuredHeight + vPadding);
    }
    
    /**
	* 测量使用真实布局的尺寸
	*/
    private function measureReal() : Void
    {
        var count : Int = target.numElements;
        var numElements : Int = count;
        var measuredWidth : Float = 0;
        var measuredHeight : Float = 0;
		var i:Int = 0;
        while (i < count)
		{
            var layoutElement : ILayoutElement = Lib.as(target.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
            {
                numElements--;
                i++;
				continue;
            }
            var preferredWidth : Float = layoutElement.preferredWidth;
            var preferredHeight : Float = layoutElement.preferredHeight;
            measuredWidth += preferredWidth;
            measuredHeight = Math.max(measuredHeight, preferredHeight);
			
			i++;
        }
        var gap : Float = Math.isNaN(_gap) ? 0 : _gap;
        measuredWidth += (numElements - 1) * gap;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        var hPadding : Float = paddingL + paddingR;
        var vPadding : Float = paddingT + paddingB;
        target.measuredWidth = Math.ceil(measuredWidth + hPadding);
        target.measuredHeight = Math.ceil(measuredHeight + vPadding);
    }
    
    /**
	* @inheritDoc
	*/
    override public function updateDisplayList(width : Float, height : Float) : Void
    {
        super.updateDisplayList(width, height);
        if (target == null) 
            return;
        if (useVirtualLayout) 
        {
            updateDisplayListVirtual(width, height);
        }
        else 
        {
            updateDisplayListReal(width, height);
        }
    }
    
    /**
	* 获取指定索引的起始位置
	*/
    private function getStartPosition(index : Int) : Float
    {
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var gap : Float = Math.isNaN(_gap) ? 0 : _gap;
        if (!useVirtualLayout) 
        {
            var element : IVisualElement = null;
            if (target != null) 
            {
                element = target.getElementAt(index);
            }
            return (element != null) ? element.x : paddingL;
        }
        var typicalWidth : Float = (typicalLayoutRect != null) ? typicalLayoutRect.width : 71;
        var startPos : Float = paddingL;
        for (i in 0...index)
		{
            var eltWidth : Float = elementSizeTable[i];
            if (Math.isNaN(eltWidth)) 
            {
                eltWidth = typicalWidth;
            }
            startPos += eltWidth + gap;
        }
        return startPos;
    }
    
    /**
	* 获取指定索引的元素尺寸
	*/
    private function getElementSize(index : Int) : Float
    {
        if (useVirtualLayout) 
        {
            var size : Float = elementSizeTable[index];
            if (Math.isNaN(size)) 
            {
                size = (typicalLayoutRect != null) ? typicalLayoutRect.width : 71;
            }
            return size;
        }
        if (target != null) 
        {
            return target.getElementAt(index).width;
        }
        return 0;
    }
    
    /**
	* 获取缓存的子对象尺寸总和
	*/
    private function getElementTotalSize() : Float
    {
        var typicalWidth : Float = (typicalLayoutRect != null) ? typicalLayoutRect.width : 71;
        var gap : Float = Math.isNaN(_gap) ? 0 : _gap;
        var totalSize : Float = 0;
        var length : Int = target.numElements;
        for (i in 0...length)
		{
            var eltWidth : Float = elementSizeTable[i];
            if (Math.isNaN(eltWidth)) 
            {
                eltWidth = typicalWidth;
            }
            totalSize += eltWidth + gap;
        }
        totalSize -= gap;
        return totalSize;
    }
    
    /**
	* @inheritDoc
	*/
    override public function elementAdded(index : Int) : Void
    {
        if (!useVirtualLayout) 
            return;
        super.elementAdded(index);
        var typicalWidth : Float = (typicalLayoutRect != null) ? typicalLayoutRect.width : 71;
        elementSizeTable.insert(index, typicalWidth);
    }
    
    /**
	* @inheritDoc
	*/
    override public function elementRemoved(index : Int) : Void
    {
        if (!useVirtualLayout) 
            return;
        super.elementRemoved(index);
        elementSizeTable.splice(index, 1);
    }
    
    /**
	* @inheritDoc
	*/
    override public function clearVirtualLayoutCache() : Void
    {
        if (!useVirtualLayout) 
            return;
        super.clearVirtualLayoutCache();
        elementSizeTable = [];
        maxElementHeight = 0;
    }
    
    
    
    /**
	* 折半查找法寻找指定位置的显示对象索引
	*/
    private function findIndexAt(x : Float, i0 : Int, i1 : Int) : Int
    {
        var index : Int = Std.int((i0 + i1) / 2);
        var elementX : Float = getStartPosition(index);
        var elementWidth : Float = getElementSize(index);
        var gap : Float = Math.isNaN(_gap) ? 0 : _gap;
        if ((x >= elementX) && (x < elementX + elementWidth + gap)) 
            return index
        else if (i0 == i1) 
            return -1
        else if (x < elementX) 
            return findIndexAt(x, i0, MathUtil.maxInt(i0, index - 1))
        else 
			return findIndexAt(x, MathUtil.minInt(index + 1, i1), i1);
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
        
        if (Math.isNaN(target.width) || target.width == 0 || Math.isNaN(target.height) || target.height == 0) 
        {
            startIndex = endIndex = -1;
            return false;
        }
        
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        
        var numElements : Int = target.numElements;
        var contentWidth : Float = getStartPosition(numElements - 1) +
									elementSizeTable[numElements - 1] + paddingR;
        var minVisibleX : Float = target.horizontalScrollPosition;
        if (minVisibleX > contentWidth - paddingR) 
        {
            startIndex = -1;
            endIndex = -1;
            return false;
        }
        var maxVisibleX : Float = target.horizontalScrollPosition + target.width;
        if (maxVisibleX < paddingL) 
        {
            startIndex = -1;
            endIndex = -1;
            return false;
        }
        var oldStartIndex : Int = startIndex;
        var oldEndIndex : Int = endIndex;
        startIndex = findIndexAt(minVisibleX, 0, numElements - 1);
        if (startIndex == -1) 
            startIndex = 0;
        endIndex = findIndexAt(maxVisibleX, 0, numElements - 1);
        if (endIndex == -1) 
            endIndex = numElements - 1;
        return oldStartIndex != startIndex || oldEndIndex != endIndex;
    }
    
    
    
    /**
	* 更新使用虚拟布局的显示列表
	*/
    private function updateDisplayListVirtual(width : Float, height : Float) : Void
    {
        if (indexInViewCalculated) 
            indexInViewCalculated = false
        else 
        getIndexInView();
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingR : Float = (Math.isNaN(_paddingRight)) ? padding : _paddingRight;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        var gap : Float = (Math.isNaN(_gap)) ? 0 : _gap;
        var contentWidth : Float;
        var numElements : Int = target.numElements;
        if (startIndex == -1 || endIndex == -1) 
        {
            contentWidth = getStartPosition(numElements) - gap + paddingR;
            target.setContentSize(Math.ceil(contentWidth), target.contentHeight);
            return;
        }
        target.setVirtualElementIndicesInView(startIndex, endIndex);
        //获取垂直布局参数
        var justify : Bool = _verticalAlign == VerticalAlign.JUSTIFY || _verticalAlign == VerticalAlign.CONTENT_JUSTIFY;
        var contentJustify : Bool = _verticalAlign == VerticalAlign.CONTENT_JUSTIFY;
        var vAlign : Float = 0;
        if (!justify) 
        {
            if (_verticalAlign == VerticalAlign.MIDDLE) 
            {
                vAlign = 0.5;
            }
            else if (_verticalAlign == VerticalAlign.BOTTOM) 
            {
                vAlign = 1;
            }
        }
        
        var targetHeight : Float = Math.max(0, height - paddingT - paddingB);
        var justifyHeight : Float = Math.ceil(targetHeight);
        var layoutElement : ILayoutElement;
        var typicalHeight : Float = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
        var typicalWidth : Float = (typicalLayoutRect != null) ? typicalLayoutRect.width : 71;
        var oldMaxH : Float = Math.max(typicalHeight, maxElementHeight);
        if (contentJustify) 
        {
			var index:Int = startIndex;
            while (index <= endIndex)
			{
                layoutElement = Lib.as(target.getVirtualElementAt(index), ILayoutElement);
                if (layoutElement == null || !layoutElement.includeInLayout) 
                {
					index++;
					continue;
                }
                maxElementHeight = Math.max(maxElementHeight, layoutElement.preferredHeight);
				index++;
            }
            justifyHeight = Math.ceil(Math.max(targetHeight, maxElementHeight));
        }
        var x : Float = 0;
        var y : Float = 0;
        var contentHeight : Float = 0;
        var oldElementSize : Float;
        var needInvalidateSize : Bool = false;
        //对可见区域进行布局
		var i:Int = startIndex;
        while (i <= endIndex)
		{
            var exceesHeight : Float = 0;
            layoutElement = Lib.as(target.getVirtualElementAt(i), ILayoutElement);
            if (layoutElement == null) 
            {
                i++;
				continue;
            }
            else if (!layoutElement.includeInLayout) 
            {
                elementSizeTable[i] = 0;
                i++;
				continue;
            }
			
            if (justify) 
            {
                y = paddingT;
                layoutElement.setLayoutBoundsSize(Math.NaN, justifyHeight);
            }
            else 
            {
                exceesHeight = (targetHeight - layoutElement.layoutBoundsHeight) * vAlign;
                exceesHeight = exceesHeight > (0) ? exceesHeight : 0;
                y = paddingT + exceesHeight;
            }
			
            if (!contentJustify) 
                maxElementHeight = Math.max(maxElementHeight, layoutElement.preferredHeight);
				
            contentHeight = Math.max(contentHeight, layoutElement.layoutBoundsHeight);
            if (!needInvalidateSize) 
            {
                oldElementSize = (Math.isNaN(elementSizeTable[i])) ? typicalWidth : elementSizeTable[i];
                if (oldElementSize != layoutElement.layoutBoundsWidth) 
                    needInvalidateSize = true;
            }
            if (i == 0 && elementSizeTable.length > 0 && elementSizeTable[i] != layoutElement.layoutBoundsWidth) 
                typicalLayoutRect = null;
            elementSizeTable[i] = layoutElement.layoutBoundsWidth;
            x = getStartPosition(i);
            layoutElement.setLayoutBoundsPosition(Math.round(x), Math.round(y));
			
			i++;
        }
        
        contentHeight += paddingT + paddingB;
        contentWidth = getStartPosition(numElements) - gap + paddingR;
        target.setContentSize(Math.ceil(contentWidth),
                Math.ceil(contentHeight));
        if (needInvalidateSize || oldMaxH < maxElementHeight) 
        {
            target.invalidateSize();
        }
    }
    
    
    
    
    /**
	* 更新使用真实布局的显示列表
	*/
    private function updateDisplayListReal(width : Float, height : Float) : Void
    {
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var paddingT : Float = Math.isNaN(_paddingTop) ? padding : _paddingTop;
        var paddingB : Float = Math.isNaN(_paddingBottom) ? padding : _paddingBottom;
        var gap : Float = Math.isNaN(_gap) ? 0 : _gap;
        var targetWidth : Float = Math.max(0, width - paddingL - paddingR);
        var targetHeight : Float = Math.max(0, height - paddingT - paddingB);
        
        var hJustify : Bool = _horizontalAlign == HorizontalAlign.JUSTIFY;
        var vJustify : Bool = _verticalAlign == VerticalAlign.JUSTIFY || _verticalAlign == VerticalAlign.CONTENT_JUSTIFY;
        var vAlign : Float = 0;
        if (!vJustify) 
        {
            if (_verticalAlign == VerticalAlign.MIDDLE) 
            {
                vAlign = 0.5;
            }
            else if (_verticalAlign == VerticalAlign.BOTTOM) 
            {
                vAlign = 1;
            }
        }
        
        var count : Int = target.numElements;
        var numElements : Int = count;
        var x : Float = paddingL;
        var y : Float = paddingT;
        var i : Int;
        var layoutElement : ILayoutElement;
        
        var totalPreferredWidth : Float = 0;
        var totalPercentWidth : Float = 0;
        var childInfoArray : Array<HorizontalChildInfo> = [];
        var childInfo : HorizontalChildInfo;
        var widthToDistribute : Float = targetWidth;
		var i:Int = 0;
        while (i < count)
		{
            layoutElement = Lib.as(target.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
            {
                numElements--;
                i++;
				continue;
            }
            maxElementHeight = Math.max(maxElementHeight, layoutElement.preferredHeight);
            if (hJustify) 
            {
                totalPreferredWidth += layoutElement.preferredWidth;
            }
            else 
            {
                if (!Math.isNaN(layoutElement.percentWidth)) 
                {
                    totalPercentWidth += layoutElement.percentWidth;
                    
                    childInfo = new HorizontalChildInfo();
                    childInfo.layoutElement = layoutElement;
                    childInfo.percent = layoutElement.percentWidth;
                    childInfo.min = layoutElement.minWidth;
                    childInfo.max = layoutElement.maxWidth;
                    childInfoArray.push(childInfo);
                }
                else 
                {
                    widthToDistribute -= layoutElement.preferredWidth;
                }
            }
			i++;
        }
        widthToDistribute -= gap * (numElements - 1);
        widthToDistribute = widthToDistribute > (0) ? widthToDistribute : 0;
        var excessSpace : Float = targetWidth - totalPreferredWidth - gap * (numElements - 1);
        
        var averageWidth : Float = 0;
        var largeChildrenCount : Int = numElements;
        var widthDic : ObjectMap<ILayoutElement,Float> = new ObjectMap<ILayoutElement,Float>();
        if (hJustify) 
        {
            if (excessSpace < 0) 
            {
                averageWidth = widthToDistribute / numElements;
                var i:Int = 0;
				while (i < count)
				{
                    layoutElement = target.getElementAt(i);
                    if (layoutElement == null || !layoutElement.includeInLayout) 
                    {
						i++;
						continue;
                    }
                    
                    var preferredWidth : Float = layoutElement.preferredWidth;
                    if (preferredWidth <= averageWidth) 
                    {
                        widthToDistribute -= preferredWidth;
                        largeChildrenCount--;
                        {
							i++;
							continue;
                        }
                    }
					
					i++;
                }
                widthToDistribute = widthToDistribute > (0) ? widthToDistribute : 0;
            }
        }
        else 
        {
            if (totalPercentWidth > 0) 
            {
                flexChildrenProportionally(targetWidth, widthToDistribute,
                        totalPercentWidth, childInfoArray);
                var roundOff : Float = 0;
                for (childInfo in childInfoArray)
                {
                    var childSize : Int = Math.round(childInfo.size + roundOff);
                    roundOff += childInfo.size - childSize;
                    
                    widthDic.set(childInfo.layoutElement,childSize);
                    widthToDistribute -= childSize;
                }
                widthToDistribute = widthToDistribute > 0 ? widthToDistribute : 0;
            }
        }
        
        if (_horizontalAlign == HorizontalAlign.CENTER) 
        {
            x = paddingL + widthToDistribute * 0.5;
        }
        else if (_horizontalAlign == HorizontalAlign.RIGHT) 
        {
            x = paddingL + widthToDistribute;
        }
        
        var maxX : Float = paddingL;
        var maxY : Float = paddingT;
        var dx : Float = 0;
        var dy : Float = 0;
        var justifyHeight : Float = Math.ceil(targetHeight);
        if (_verticalAlign == VerticalAlign.CONTENT_JUSTIFY) 
            justifyHeight = Math.ceil(Math.max(targetHeight, maxElementHeight));
        var roundOff:Float = 0;
        var layoutElementWidth : Float;
        var childWidth : Float;
		var i:Int = 0;
        while (i < count)
		{
            var exceesHeight : Float = 0;
            layoutElement = Lib.as(target.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
            {
				i++;
				continue;
            }
            layoutElementWidth = Math.NaN;
            if (hJustify) 
            {
                childWidth = Math.NaN;
                if (excessSpace > 0) 
                {
                    childWidth = widthToDistribute * layoutElement.preferredWidth / totalPreferredWidth;
                }
                else if (excessSpace < 0 && layoutElement.preferredWidth > averageWidth) 
                {
                    childWidth = widthToDistribute / largeChildrenCount;
                }
                if (!Math.isNaN(childWidth)) 
                {
                    layoutElementWidth = Math.round(childWidth + roundOff);
                    roundOff += childWidth - layoutElementWidth;
                }
            }
            else 
            {
                layoutElementWidth = Reflect.field(widthDic, Std.string(layoutElement));
            }
            if (vJustify) 
            {
                y = paddingT;
                layoutElement.setLayoutBoundsSize(layoutElementWidth, justifyHeight);
            }
            else 
            {
                var layoutElementHeight : Float = Math.NaN;
                if (!Math.isNaN(layoutElement.percentHeight)) 
                {
                    var percent : Float = Math.min(100, layoutElement.percentHeight);
                    layoutElementHeight = Math.round(targetHeight * percent * 0.01);
                }
                layoutElement.setLayoutBoundsSize(layoutElementWidth, layoutElementHeight);
                exceesHeight = (targetHeight - layoutElement.layoutBoundsHeight) * vAlign;
                exceesHeight = exceesHeight > (0) ? exceesHeight : 0;
                y = paddingT + exceesHeight;
            }
            layoutElement.setLayoutBoundsPosition(Math.round(x), Math.round(y));
            dx = Math.ceil(layoutElement.layoutBoundsWidth);
            dy = Math.ceil(layoutElement.layoutBoundsHeight);
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);
            x += dx + gap;
			
			i++;
        }
        target.setContentSize(Math.ceil(maxX + paddingR), Math.ceil(maxY + paddingB));
    }
    
    /**
	* 为每个可变尺寸的子项分配空白区域
	*/
    public static function flexChildrenProportionally(spaceForChildren : Float, spaceToDistribute : Float,
            totalPercent : Float, childInfoArray : Array<HorizontalChildInfo>) : Void
    {
        
        var numChildren : Int = childInfoArray.length;
        var done : Bool;
        
        do
        {
            done = true;
            
            var unused : Float = spaceToDistribute - (spaceForChildren * totalPercent / 100);
            if (unused > 0) 
                spaceToDistribute -= unused;
            else 
				unused = 0;
            
            var spacePerPercent : Float = spaceToDistribute / totalPercent;
            
            for (i in 0...numChildren)
			{
                var childInfo : HorizontalChildInfo = childInfoArray[i];
                
                var size : Float = childInfo.percent * spacePerPercent;
                
                if (size < childInfo.min) 
                {
                    var min : Float = childInfo.min;
                    childInfo.size = min;
                    
                    childInfoArray[i] = childInfoArray[--numChildren];
                    childInfoArray[numChildren] = childInfo;
                    
                    totalPercent -= childInfo.percent;
                    if (unused >= min) 
                    {
                        unused -= min;
                    }
                    else 
                    {
                        spaceToDistribute -= min - unused;
                        unused = 0;
                    }
                    done = false;
                    break;
                }
                else if (size > childInfo.max) 
                {
                    var max : Float = childInfo.max;
                    childInfo.size = max;
                    
                    childInfoArray[i] = childInfoArray[--numChildren];
                    childInfoArray[numChildren] = childInfo;
                    
                    totalPercent -= childInfo.percent;
                    if (unused >= max) 
                    {
                        unused -= max;
                    }
                    else 
                    {
                        spaceToDistribute -= max - unused;
                        unused = 0;
                    }
                    done = false;
                    break;
                }
                else 
                {
                    childInfo.size = size;
                }
            }
        }while ((!done));
    }
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsLeftOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var rect : Rectangle = new Rectangle();
        if (target == null) 
            return rect;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var firstIndex : Int = findIndexAt(scrollRect.left, 0, target.numElements - 1);
        if (firstIndex == -1) 
        {
            
            if (scrollRect.left > target.contentWidth - paddingR) 
            {
                rect.left = target.contentWidth - paddingR;
                rect.right = target.contentWidth;
            }
            else 
            {
                rect.left = 0;
                rect.right = paddingL;
            }
            return rect;
        }
        rect.left = getStartPosition(firstIndex);
        rect.right = getElementSize(firstIndex) + rect.left;
        if (rect.left == scrollRect.left) 
        {
            firstIndex--;
            if (firstIndex != -1) 
            {
                rect.left = getStartPosition(firstIndex);
                rect.right = getElementSize(firstIndex) + rect.left;
            }
            else 
            {
                rect.left = 0;
                rect.right = paddingL;
            }
        }
        return rect;
    }
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsRightOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var rect : Rectangle = new Rectangle();
        if (target == null) 
            return rect;
        var numElements : Int = target.numElements;
        var padding : Float = Math.isNaN(_padding) ? 0 : _padding;
        var paddingL : Float = Math.isNaN(_paddingLeft) ? padding : _paddingLeft;
        var paddingR : Float = Math.isNaN(_paddingRight) ? padding : _paddingRight;
        var lastIndex : Int = findIndexAt(scrollRect.right, 0, numElements - 1);
        if (lastIndex == -1) 
        {
            if (scrollRect.right < paddingL) 
            {
                rect.left = 0;
                rect.right = paddingL;
            }
            else 
            {
                rect.left = target.contentWidth - paddingR;
                rect.right = target.contentWidth;
            }
            return rect;
        }
        rect.left = getStartPosition(lastIndex);
        rect.right = getElementSize(lastIndex) + rect.left;
        if (rect.right <= scrollRect.right) 
        {
            lastIndex++;
            if (lastIndex < numElements) 
            {
                rect.left = getStartPosition(lastIndex);
                rect.right = getElementSize(lastIndex) + rect.left;
            }
            else 
            {
                rect.left = target.contentWidth - paddingR;
                rect.right = target.contentWidth;
            }
        }
        return rect;
    }
}


class HorizontalChildInfo
{
    public function new()
    {
    }
    
    public var layoutElement : ILayoutElement;
    
    public var size : Float = 0;
    
    public var percent : Float;
    
    public var min : Float;
    
    public var max : Float;
}