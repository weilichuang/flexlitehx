package flexlite.layouts;


import flash.geom.Rectangle;
import flash.Lib;
import flexlite.components.supportclasses.GroupBase;

import flexlite.core.ILayoutElement;
import flexlite.layouts.supportclasses.LayoutBase;

@:meta(DXML(show="false"))


/**
* 基本布局
* @author weilichuang
*/
class BasicLayout extends LayoutBase
{
    public var mouseWheelSpeed(get, set) : Int;
	
	private var _mouseWheelSpeed : Int = 20;

    public function new()
    {
        super();
    }
    
    /**
	* 此布局不支持虚拟布局，设置这个属性无效
	*/
    override private function set_useVirtualLayout(value : Bool) : Bool
    {
        
        return value;
    }
    
    
    /**
	* 鼠标滚轮每次滚动时目标容器的verticalScrollPosition
	* 或horizontalScrollPosition改变的像素距离。必须大于0， 默认值20。
	*/
    private function get_mouseWheelSpeed() : Int
    {
        return _mouseWheelSpeed;
    }
	
    private function set_mouseWheelSpeed(value : Int) : Int
    {
        if (value <= 0) 
            value = 1;
        return _mouseWheelSpeed = value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsLeftOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.left = scrollRect.left - _mouseWheelSpeed;
        bounds.right = scrollRect.left;
        return bounds;
    }
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsRightOfScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.left = scrollRect.right;
        bounds.right = scrollRect.right + _mouseWheelSpeed;
        return bounds;
    }
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsAboveScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.top = scrollRect.top - _mouseWheelSpeed;
        bounds.bottom = scrollRect.top;
        return bounds;
    }
    /**
	* @inheritDoc
	*/
    override private function getElementBoundsBelowScrollRect(scrollRect : Rectangle) : Rectangle
    {
        var bounds : Rectangle = new Rectangle();
        bounds.top = scrollRect.bottom;
        bounds.bottom = scrollRect.bottom + _mouseWheelSpeed;
        return bounds;
    }
    
    /**
	* @inheritDoc
	*/
    override public function measure() : Void
    {
        super.measure();
        
        if (target == null) 
            return;
        
        var width : Float = 0;
        var height : Float = 0;
        
        var count : Int = target.numElements;
		var i:Int = 0;
        while (i < count)
		{
            var layoutElement : ILayoutElement = Lib.as(target.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
            {
				i++;
				continue;
            }
            
            var hCenter : Float = layoutElement.horizontalCenter;
            var vCenter : Float = layoutElement.verticalCenter;
            var left : Float = layoutElement.left;
            var right : Float = layoutElement.right;
            var top : Float = layoutElement.top;
            var bottom : Float = layoutElement.bottom;
            
            var extX : Float;
            var extY : Float;
            
            if (!Math.isNaN(left) && !Math.isNaN(right)) 
            {
                extX = left + right;
            }
            else if (!Math.isNaN(hCenter)) 
            {
                extX = Math.abs(hCenter) * 2;
            }
            else if (!Math.isNaN(left) || !Math.isNaN(right)) 
            {
                extX = Math.isNaN(left) ? 0 : left;
                extX += Math.isNaN(right) ? 0 : right;
            }
            else 
            {
                extX = layoutElement.preferredX;
            }
            
            if (!Math.isNaN(top) && !Math.isNaN(bottom)) 
            {
                extY = top + bottom;
            }
            else if (!Math.isNaN(vCenter)) 
            {
                extY = Math.abs(vCenter) * 2;
            }
            else if (!Math.isNaN(top) || !Math.isNaN(bottom)) 
            {
                extY = Math.isNaN(top) ? 0 : top;
                extY += Math.isNaN(bottom) ? 0 : bottom;
            }
            else 
            {
                extY = layoutElement.preferredY;
            }
            
            var preferredWidth : Float = layoutElement.preferredWidth;
            var preferredHeight : Float = layoutElement.preferredHeight;
            
            width = Math.ceil(Math.max(width, extX + preferredWidth));
            height = Math.ceil(Math.max(height, extY + preferredHeight));
			
			i++;
        }
        
        target.measuredWidth = width;
        target.measuredHeight = height;
    }
    
    
    /**
	* @inheritDoc
	*/
    override public function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
		var targetGroup:GroupBase = target;
        if (targetGroup == null) 
            return;

        var count : Int = targetGroup.numElements;
        
        var maxX : Float = 0;
        var maxY : Float = 0;
		var i:Int = 0;
        while (i < count)
		{
            var layoutElement : ILayoutElement = Lib.as(targetGroup.getElementAt(i), ILayoutElement);
            if (layoutElement == null || !layoutElement.includeInLayout) 
            {
				i++;
				continue;
            }
            
            var hCenter : Float = layoutElement.horizontalCenter;
            var vCenter : Float = layoutElement.verticalCenter;
            var left : Float = layoutElement.left;
            var right : Float = layoutElement.right;
            var top : Float = layoutElement.top;
            var bottom : Float = layoutElement.bottom;
            var percentWidth : Float = layoutElement.percentWidth;
            var percentHeight : Float = layoutElement.percentHeight;
            
            var childWidth : Float = Math.NaN;
            var childHeight : Float = Math.NaN;
            
            if (!Math.isNaN(left) && !Math.isNaN(right)) 
            {
                childWidth = unscaledWidth - right - left;
            }
            else if (!Math.isNaN(percentWidth)) 
            {
                childWidth = Math.round(unscaledWidth * Math.min(percentWidth * 0.01, 1));
            }
            
            if (!Math.isNaN(top) && !Math.isNaN(bottom)) 
            {
                childHeight = unscaledHeight - bottom - top;
            }
            else if (!Math.isNaN(percentHeight)) 
            {
                childHeight = Math.round(unscaledHeight * Math.min(percentHeight * 0.01, 1));
            }
            
            layoutElement.setLayoutBoundsSize(childWidth, childHeight);
            
            var elementWidth : Float = layoutElement.layoutBoundsWidth;
            var elementHeight : Float = layoutElement.layoutBoundsHeight;
            
            
            var childX : Float = Math.NaN;
            var childY : Float = Math.NaN;
            
            if (!Math.isNaN(hCenter)) 
                childX = Math.round((unscaledWidth - elementWidth) / 2 + hCenter);
            else if (!Math.isNaN(left)) 
                childX = left;
            else if (!Math.isNaN(right)) 
                childX = unscaledWidth - elementWidth - right;
            else 
				childX = layoutElement.layoutBoundsX;
            
            if (!Math.isNaN(vCenter)) 
                childY = Math.round((unscaledHeight - elementHeight) / 2 + vCenter);
            else if (!Math.isNaN(top)) 
                childY = top;
            else if (!Math.isNaN(bottom)) 
                childY = unscaledHeight - elementHeight - bottom;
            else 
				childY = layoutElement.layoutBoundsY;
            
            layoutElement.setLayoutBoundsPosition(childX, childY);
            
            maxX = Math.max(maxX, childX + elementWidth);
            maxY = Math.max(maxY, childY + elementHeight);
			
			i++;
        }
        targetGroup.setContentSize(maxX, maxY);
    }
}
