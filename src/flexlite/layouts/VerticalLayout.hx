package flexlite.layouts;


import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;

import flexlite.core.ILayoutElement;
import flexlite.core.IVisualElement;
import flexlite.layouts.supportclasses.LayoutBase;

@:meta(DXML(show="false"))


/**
* 垂直布局
* @author weilichuang
*/



class VerticalLayout extends LayoutBase
{
    public var horizontalAlign(get, set) : String;
    public var verticalAlign(get, set) : String;
    public var gap(get, set) : Float;
    public var padding(get, set) : Float;
    public var paddingLeft(get, set) : Float;
    public var paddingRight(get, set) : Float;
    public var paddingTop(get, set) : Float;
    public var paddingBottom(get, set) : Float;

    public function new()
    {
        super();
    }
    
    private var _horizontalAlign : String = HorizontalAlign.LEFT;
    /**
	* 布局元素的水平对齐策略。参考HorizontalAlign定义的常量。
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
    
    private var _verticalAlign : String = VerticalAlign.TOP;
    /**
	* 布局元素的竖直对齐策略。参考VerticalAlign定义的常量。
	* 注意：此属性设置为CONTENT_JUSTIFY始终无效。当useVirtualLayout为true时，设置JUSTIFY也无效。
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
    
    private var _gap : Float = 6;
    /**
	* 布局元素之间的垂直空间（以像素为单位）
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
        invalidateTargetSizeAndDisplayList();
        return value;
    }
    
    
    private var _paddingLeft : Float = Math.NaN;
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
    
    private var _paddingRight : Float = Math.NaN;
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
    
    private var _paddingTop : Float = Math.NaN;
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
    
    private var _paddingBottom : Float = Math.NaN;
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
        var measuredWidth : Float = Math.max(maxElementWidth, typicalWidth);
        var measuredHeight : Float = getElementTotalSize();
        
        var visibleIndices : Array<Int> = target.getElementIndicesInView();
        for (i in visibleIndices)
        {
            var layoutElement : ILayoutElement = Lib.as(target.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
                continue;
            
            var preferredWidth : Float = layoutElement.preferredWidth;
            var preferredHeight : Float = layoutElement.preferredHeight;
            measuredHeight += preferredHeight;
            measuredHeight -= (Math.isNaN(elementSizeTable[i])) ? typicalHeight : elementSizeTable[i];
            measuredWidth = Math.max(measuredWidth, preferredWidth);
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
            measuredHeight += preferredHeight;
            measuredWidth = Math.max(measuredWidth, preferredWidth);
			
			i++;
        }
        var gap : Float = (Math.isNaN(_gap)) ? 0 : _gap;
        measuredHeight += (numElements - 1) * gap;
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingL : Float = (Math.isNaN(_paddingLeft)) ? padding : _paddingLeft;
        var paddingR : Float = (Math.isNaN(_paddingRight)) ? padding : _paddingRight;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
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
	* 虚拟布局使用的子对象尺寸缓存 
	*/
    private var elementSizeTable : Array<Float> = [];
    
    /**
	* 获取指定索引的起始位置
	*/
    private function getStartPosition(index : Int) : Float
    {
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var gap : Float = (Math.isNaN(_gap)) ? 0 : _gap;
        if (!useVirtualLayout) 
        {
            var element : IVisualElement = null;
            if (target != null) 
            {
                element = target.getElementAt(index);
            }
            return (element != null) ? element.y : paddingT;
        }
        var typicalHeight : Float = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
        var startPos : Float = paddingT;
        for (i in 0...index){
            var eltHeight : Float = elementSizeTable[i];
            if (Math.isNaN(eltHeight)) 
            {
                eltHeight = typicalHeight;
            }
            startPos += eltHeight + gap;
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
                size = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
            }
            return size;
        }
        if (target != null) 
        {
            return target.getElementAt(index).height;
        }
        return 0;
    }
    
    /**
	* 获取缓存的子对象尺寸总和
	*/
    private function getElementTotalSize() : Float
    {
        var gap : Float = (Math.isNaN(_gap)) ? 0 : _gap;
        var typicalHeight : Float = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
        var totalSize : Float = 0;
        var length : Int = target.numElements;
        for (i in 0...length){
            var eltHeight : Float = elementSizeTable[i];
            if (Math.isNaN(eltHeight)) 
            {
                eltHeight = typicalHeight;
            }
            totalSize += eltHeight + gap;
        }
        totalSize -= gap;
        return totalSize;
    }
    
    /**
	* @inheritDoc
	*/
    override public function elementAdded(index : Int) : Void
    {
        super.elementAdded(index);
        var typicalHeight : Float = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
        elementSizeTable.insert(index, typicalHeight);
    }
    
    /**
	* @inheritDoc
	*/
    override public function elementRemoved(index : Int) : Void
    {
        super.elementRemoved(index);
        elementSizeTable.splice(index, 1);
    }
    
    /**
	* @inheritDoc
	*/
    override public function clearVirtualLayoutCache() : Void
    {
        super.clearVirtualLayoutCache();
        elementSizeTable = [];
        maxElementWidth = 0;
    }
    
    
    
    /**
	* 折半查找法寻找指定位置的显示对象索引
	*/
    private function findIndexAt(y : Float, i0 : Int, i1 : Int) : Int
    {
        var index : Int = Std.int((i0 + i1) / 2);
        var elementY : Float = getStartPosition(index);
        var elementHeight : Float = getElementSize(index);
        var gap : Float = (Math.isNaN(_gap)) ? 0 : _gap;
        if ((y >= elementY) && (y < elementY + elementHeight + gap)) 
            return index
        else if (i0 == i1) 
            return -1
        else if (y < elementY) 
            return findIndexAt(y, i0, Std.int(Math.max(i0, index - 1)));
        else 
        return findIndexAt(y, Std.int(Math.min(index + 1, i1)), i1);
    }
    
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
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        var numElements : Int = target.numElements;
        var contentHeight : Float = getStartPosition(numElements - 1) +
        elementSizeTable[numElements - 1] + paddingB;
        var minVisibleY : Float = target.verticalScrollPosition;
        if (minVisibleY > contentHeight - paddingB) 
        {
            startIndex = -1;
            endIndex = -1;
            return false;
        }
        var maxVisibleY : Float = target.verticalScrollPosition + target.height;
        if (maxVisibleY < paddingT) 
        {
            startIndex = -1;
            endIndex = -1;
            return false;
        }
        var oldStartIndex : Int = startIndex;
        var oldEndIndex : Int = endIndex;
        startIndex = findIndexAt(minVisibleY, 0, numElements - 1);
        if (startIndex == -1) 
            startIndex = 0;
        endIndex = findIndexAt(maxVisibleY, 0, numElements - 1);
        if (endIndex == -1) 
            endIndex = numElements - 1;
        return oldStartIndex != startIndex || oldEndIndex != endIndex;
    }
    
    /**
	* 子对象最大宽度 
	*/
    private var maxElementWidth : Float = 0;
    
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
        var paddingL : Float = (Math.isNaN(_paddingLeft)) ? padding : _paddingLeft;
        var paddingR : Float = (Math.isNaN(_paddingRight)) ? padding : _paddingRight;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        var gap : Float = (Math.isNaN(_gap)) ? 0 : _gap;
        var contentHeight : Float;
        var numElements : Int = target.numElements;
        if (startIndex == -1 || endIndex == -1) 
        {
            contentHeight = getStartPosition(numElements) - gap + paddingB;
            target.setContentSize(target.contentWidth, Math.ceil(contentHeight));
            return;
        }
        target.setVirtualElementIndicesInView(startIndex, endIndex);
        //获取水平布局参数
        var justify : Bool = _horizontalAlign == HorizontalAlign.JUSTIFY || _horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY;
        var contentJustify : Bool = _horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY;
        var hAlign : Float = 0;
        if (!justify) 
        {
            if (_horizontalAlign == HorizontalAlign.CENTER) 
            {
                hAlign = 0.5;
            }
            else if (_horizontalAlign == HorizontalAlign.RIGHT) 
            {
                hAlign = 1;
            }
        }
        
        var targetWidth : Float = Math.max(0, width - paddingL - paddingR);
        var justifyWidth : Float = Math.ceil(targetWidth);
        var layoutElement : ILayoutElement;
        var typicalHeight : Float = (typicalLayoutRect != null) ? typicalLayoutRect.height : 22;
        var typicalWidth : Float = (typicalLayoutRect != null) ? typicalLayoutRect.width : 71;
        var oldMaxW : Float = Math.max(typicalWidth, maxElementWidth);
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
                maxElementWidth = Math.max(maxElementWidth, layoutElement.preferredWidth);
				
				index++;
            }
            justifyWidth = Math.ceil(Math.max(targetWidth, maxElementWidth));
        }
        var x : Float = 0;
        var y : Float = 0;
        var contentWidth : Float = 0;
        var oldElementSize : Float;
        var needInvalidateSize : Bool = false;
        //对可见区域进行布局
		var i:Int = startIndex;
        while (i <= endIndex)
		{
            var exceesWidth : Float = 0;
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
                x = paddingL;
                layoutElement.setLayoutBoundsSize(justifyWidth, Math.NaN);
            }
            else 
            {
                exceesWidth = (targetWidth - layoutElement.layoutBoundsWidth) * hAlign;
                exceesWidth = exceesWidth > (0) ? exceesWidth : 0;
                x = paddingL + exceesWidth;
            }
            if (!contentJustify) 
                maxElementWidth = Math.max(maxElementWidth, layoutElement.preferredWidth);
            contentWidth = Math.max(contentWidth, layoutElement.layoutBoundsWidth);
            if (!needInvalidateSize) 
            {
                oldElementSize = (Math.isNaN(elementSizeTable[i])) ? typicalHeight : elementSizeTable[i];
                if (oldElementSize != layoutElement.layoutBoundsHeight) 
                    needInvalidateSize = true;
            }
            if (i == 0 && elementSizeTable.length > 0 && elementSizeTable[i] != layoutElement.layoutBoundsHeight) 
                typicalLayoutRect = null;
            elementSizeTable[i] = layoutElement.layoutBoundsHeight;
            y = getStartPosition(i);
            layoutElement.setLayoutBoundsPosition(Math.round(x), Math.round(y));
			
			i++;
        }
        contentWidth += paddingL + paddingR;
        contentHeight = getStartPosition(numElements) - gap + paddingB;
        target.setContentSize(Math.ceil(contentWidth), Math.ceil(contentHeight));
        if (needInvalidateSize || oldMaxW < maxElementWidth) 
        {
            target.invalidateSize();
        }
    }
    
    
    
    
    /**
	* 更新使用真实布局的显示列表
	*/
    private function updateDisplayListReal(width : Float, height : Float) : Void
    {
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingL : Float = (Math.isNaN(_paddingLeft)) ? padding : _paddingLeft;
        var paddingR : Float = (Math.isNaN(_paddingRight)) ? padding : _paddingRight;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        var gap : Float = (Math.isNaN(_gap)) ? 0 : _gap;
        var targetWidth : Float = Math.max(0, width - paddingL - paddingR);
        var targetHeight : Float = Math.max(0, height - paddingT - paddingB);
        // 获取水平布局参数
        var vJustify : Bool = _verticalAlign == VerticalAlign.JUSTIFY;
        var hJustify : Bool = _horizontalAlign == HorizontalAlign.JUSTIFY || _horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY;
        var hAlign : Float = 0;
        if (!hJustify) 
        {
            if (_horizontalAlign == HorizontalAlign.CENTER) 
            {
                hAlign = 0.5;
            }
            else if (_horizontalAlign == HorizontalAlign.RIGHT) 
            {
                hAlign = 1;
            }
        }
        
        var count : Int = target.numElements;
        var numElements : Int = count;
        var x : Float = paddingL;
        var y : Float = paddingT;
        var i : Int;
        var layoutElement : ILayoutElement;
        
        var totalPreferredHeight : Float = 0;
        var totalPercentHeight : Float = 0;
        var childInfoArray : Array<VerticalChildInfo> = [];
        var childInfo : VerticalChildInfo;
        var heightToDistribute : Float = targetHeight;
		
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
            maxElementWidth = Math.max(maxElementWidth, layoutElement.preferredWidth);
            if (vJustify) 
            {
                totalPreferredHeight += layoutElement.preferredHeight;
            }
            else 
            {
                if (!Math.isNaN(layoutElement.percentHeight)) 
                {
                    totalPercentHeight += layoutElement.percentHeight;
                    
                    childInfo = new VerticalChildInfo();
                    childInfo.layoutElement = layoutElement;
                    childInfo.percent = layoutElement.percentHeight;
                    childInfo.min = layoutElement.minHeight;
                    childInfo.max = layoutElement.maxHeight;
                    childInfoArray.push(childInfo);
                }
                else 
                {
                    heightToDistribute -= layoutElement.preferredHeight;
                }
            }
			
			i++;
        }
        
        heightToDistribute -= (numElements - 1) * gap;
        heightToDistribute = heightToDistribute > (0) ? heightToDistribute : 0;
        var excessSpace : Float = targetHeight - totalPreferredHeight - gap * (numElements - 1);
        var roundOff : Float;
        var averageHeight : Float = 0;
        var largeChildrenCount : Int = numElements;
        var heightDic : ObjectMap<ILayoutElement,Int> = new ObjectMap<ILayoutElement,Int>();
        if (vJustify) 
        {
            if (excessSpace < 0) 
            {
                averageHeight = heightToDistribute / numElements;
				var i:Int = 0;
                while (i < count)
				{
                    layoutElement = target.getElementAt(i);
                    if (layoutElement == null || !layoutElement.includeInLayout) 
                    {
						i++;
						continue;
                    }
                    
                    var preferredHeight : Float = layoutElement.preferredHeight;
                    if (preferredHeight <= averageHeight) 
                    {
                        heightToDistribute -= preferredHeight;
                        largeChildrenCount--;
                        
						i++;
						continue;
                    }
					
					i++;
                }
                heightToDistribute = heightToDistribute > 0 ? heightToDistribute : 0;
            }
        }
        else 
        {
            if (totalPercentHeight > 0) 
            {
                flexChildrenProportionally(targetHeight, heightToDistribute,
                        totalPercentHeight, childInfoArray);
                var roundOff : Float = 0;
                for (childInfo in childInfoArray)
                {
                    var childSize : Int = Math.round(childInfo.size + roundOff);
                    roundOff += childInfo.size - childSize;
                    
                    heightDic.set(childInfo.layoutElement,childSize);
                    heightToDistribute -= childSize;
                }
                heightToDistribute = heightToDistribute > (0) ? heightToDistribute : 0;
            }
        }
        
        if (_verticalAlign == VerticalAlign.MIDDLE) 
        {
            y = paddingT + heightToDistribute * 0.5;
        }
        //开始对所有元素布局
        else if (_verticalAlign == VerticalAlign.BOTTOM) 
        {
            y = paddingT + heightToDistribute;
        }
        
        
        
        var maxX : Float = paddingL;
        var maxY : Float = paddingT;
        var dx : Float = 0;
        var dy : Float = 0;
        var justifyWidth : Float = Math.ceil(targetWidth);
        if (_horizontalAlign == HorizontalAlign.CONTENT_JUSTIFY) 
            justifyWidth = Math.ceil(Math.max(targetWidth, maxElementWidth));
        roundOff = 0;
        var layoutElementHeight : Float = Math.NaN;
        var childHeight : Float;
		
		var i:Int = 0;
        while (i < count)
		{
            var exceesWidth : Float = 0;
            layoutElement = Lib.as(target.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
			{
				i++;
				continue;
            }
            layoutElementHeight = Math.NaN;
            if (vJustify) 
            {
                childHeight = Math.NaN;
                if (excessSpace > 0) 
                {
                    childHeight = heightToDistribute * layoutElement.preferredHeight / totalPreferredHeight;
                }
                else if (excessSpace < 0 && layoutElement.preferredHeight > averageHeight) 
                {
                    childHeight = heightToDistribute / largeChildrenCount;
                }
                if (!Math.isNaN(childHeight)) 
                {
                    layoutElementHeight = Math.round(childHeight + roundOff);
                    roundOff += childHeight - layoutElementHeight;
                }
            }
            else 
            {
                layoutElementHeight = Reflect.field(heightDic, Std.string(layoutElement));
            }
            if (hJustify) 
            {
                x = paddingL;
                layoutElement.setLayoutBoundsSize(justifyWidth, layoutElementHeight);
            }
            else 
            {
                var layoutElementWidth : Float = Math.NaN;
                if (!Math.isNaN(layoutElement.percentWidth)) 
                {
                    var percent : Float = Math.min(100, layoutElement.percentWidth);
                    layoutElementWidth = Math.round(targetWidth * percent * 0.01);
                }
                layoutElement.setLayoutBoundsSize(layoutElementWidth, layoutElementHeight);
                exceesWidth = (targetWidth - layoutElement.layoutBoundsWidth) * hAlign;
                exceesWidth = exceesWidth > (0) ? exceesWidth : 0;
                x = paddingL + exceesWidth;
            }
            layoutElement.setLayoutBoundsPosition(Math.round(x), Math.round(y));
            dx = Math.ceil(layoutElement.layoutBoundsWidth);
            dy = Math.ceil(layoutElement.layoutBoundsHeight);
            maxX = Math.max(maxX, x + dx);
            maxY = Math.max(maxY, y + dy);
            y += dy + gap;
			
			i++;
        }
        target.setContentSize(Math.ceil(maxX + paddingR), Math.ceil(maxY + paddingB));
    }
    
    /**
	* 为每个可变尺寸的子项分配空白区域
	*/
    public static function flexChildrenProportionally(spaceForChildren : Float, spaceToDistribute : Float,
            totalPercent : Float, childInfoArray : Array<VerticalChildInfo>) : Void
    {
        
        var numChildren : Int = childInfoArray.length;
        var done : Bool;
        
        do
        {
            done = true;
            
            var unused : Float = spaceToDistribute -
            (spaceForChildren * totalPercent / 100);
            if (unused > 0) 
                spaceToDistribute -= unused
            else 
				unused = 0;
            
            var spacePerPercent : Float = spaceToDistribute / totalPercent;
            
            for (i in 0...numChildren)
			{
                var childInfo : VerticalChildInfo = childInfoArray[i];
                
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
        }while (!done);
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsAboveScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var rect : Rectangle = new Rectangle();
        if (target == null) 
            return rect;
        var firstIndex : Int = findIndexAt(scrollRect.top, 0, target.numElements - 1);
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        if (firstIndex == -1) 
        {
            if (scrollRect.top > target.contentHeight - paddingB) 
            {
                rect.top = target.contentHeight - paddingB;
                rect.bottom = target.contentHeight;
            }
            else 
            {
                rect.top = 0;
                rect.bottom = paddingT;
            }
            return rect;
        }
        rect.top = getStartPosition(firstIndex);
        rect.bottom = getElementSize(firstIndex) + rect.top;
        if (rect.top == scrollRect.top) 
        {
            firstIndex--;
            if (firstIndex != -1) 
            {
                rect.top = getStartPosition(firstIndex);
                rect.bottom = getElementSize(firstIndex) + rect.top;
            }
            else 
            {
                rect.top = 0;
                rect.bottom = paddingT;
            }
        }
        return rect;
    }
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsBelowScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var rect : Rectangle = new Rectangle();
        if (target == null) 
            return rect;
        var numElements : Int = target.numElements;
        var lastIndex : Int = findIndexAt(scrollRect.bottom, 0, numElements - 1);
        var padding : Float = (Math.isNaN(_padding)) ? 0 : _padding;
        var paddingT : Float = (Math.isNaN(_paddingTop)) ? padding : _paddingTop;
        var paddingB : Float = (Math.isNaN(_paddingBottom)) ? padding : _paddingBottom;
        if (lastIndex == -1) 
        {
            if (scrollRect.right < paddingT) 
            {
                rect.top = 0;
                rect.bottom = paddingT;
            }
            else 
            {
                rect.top = target.contentHeight - paddingB;
                rect.bottom = target.contentHeight;
            }
            return rect;
        }
        rect.top = getStartPosition(lastIndex);
        rect.bottom = getElementSize(lastIndex) + rect.top;
        if (rect.bottom <= scrollRect.bottom) 
        {
            lastIndex++;
            if (lastIndex < numElements) 
            {
                rect.top = getStartPosition(lastIndex);
                rect.bottom = getElementSize(lastIndex) + rect.top;
            }
            else 
            {
                rect.top = target.contentHeight - paddingB;
                rect.bottom = target.contentHeight;
            }
        }
        return rect;
    }
}



class VerticalChildInfo
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