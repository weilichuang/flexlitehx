package flexlite.components.supportclasses;


import flash.display.DisplayObject;
import flash.Lib;
import flexlite.components.SkinnableComponent;
import flexlite.core.ILayoutElement;

/**
* 皮肤简单布局类。当SkinnableComponent的皮肤不是ISkinPartHost对象时启用。以提供子项的简单布局。
* @author weilichuang
*/
class SkinBasicLayout
{
    public var target(get, set) : SkinnableComponent;

    public function new()
    {
    }
    
    private var _target : SkinnableComponent;
    
    /**
	* 目标布局对象
	*/
    private function get_target() : SkinnableComponent
    {
        return _target;
    }
    
    private function set_target(value : SkinnableComponent) : SkinnableComponent
    {
        _target = value;
        return value;
    }
    
    
    /**
	* 测量组件尺寸大小
	*/
    public function measure() : Void
    {
        if (target == null) 
            return;
        
        var measureW : Float = 0;
        var measureH : Float = 0;
        
        var count : Int = target.numChildren;
		var i:Int = 0;
		while (i < count)
		{
            var layoutElement : ILayoutElement = Lib.as(target.getChildAt(i), ILayoutElement);
            if (layoutElement == null || 
				(Std.is(layoutElement,DisplayObject) && cast(layoutElement,DisplayObject) == target.skin) || 
				!layoutElement.includeInLayout) 
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
                extX = (Math.isNaN(left)) ? 0 : left;
                extX += (Math.isNaN(right)) ? 0 : right;
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
                extY = (Math.isNaN(top)) ? 0 : top;
                extY += (Math.isNaN(bottom)) ? 0 : bottom;
            }
            else 
            {
                extY = layoutElement.preferredY;
            }
            
            var preferredWidth : Float = layoutElement.preferredWidth;
            var preferredHeight : Float = layoutElement.preferredHeight;
            
            measureW = Math.ceil(Math.max(measureW, extX + preferredWidth));
            measureH = Math.ceil(Math.max(measureH, extY + preferredHeight));
			
			i++;
        }
        
        target.measuredWidth = Math.max(measureW, target.measuredWidth);
        target.measuredHeight = Math.max(measureH, target.measuredHeight);
    }
    
    /**
	* 更新显示列表
	*/
    public function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        if (target == null) 
            return;
        
        var count : Int = target.numChildren;
        
        var i:Int = 0;
		while (i < count)
		{
            var layoutElement : ILayoutElement = Lib.as(target.getChildAt(i), ILayoutElement);
            if (layoutElement == null || 
				(Std.is(layoutElement,DisplayObject) && cast(layoutElement,DisplayObject) == target.skin) || 
				!layoutElement.includeInLayout) 
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
                childX = Math.round((unscaledWidth - elementWidth) / 2 + hCenter)
            else if (!Math.isNaN(left)) 
                childX = left
            else if (!Math.isNaN(right)) 
                childX = unscaledWidth - elementWidth - right
            else 
            childX = layoutElement.layoutBoundsX;
            
            if (!Math.isNaN(vCenter)) 
                childY = Math.round((unscaledHeight - elementHeight) / 2 + vCenter)
            else if (!Math.isNaN(top)) 
                childY = top
            else if (!Math.isNaN(bottom)) 
                childY = unscaledHeight - elementHeight - bottom
            else 
            childY = layoutElement.layoutBoundsY;
            
            layoutElement.setLayoutBoundsPosition(childX, childY);
			
			i++;
        }
    }
}
