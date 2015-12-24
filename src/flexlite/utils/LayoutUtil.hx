package flexlite.utils;


import flash.display.DisplayObjectContainer;

import flexlite.core.IVisualElement;

/**
* 布局工具类
* @author weilichuang
*/
class LayoutUtil
{
    /**
	* 根据对象当前的xy坐标调整其相对位置属性，使其在下一次的父级布局中过程中保持当前位置不变。
	* @param element 要调整相对位置属性的对象
	* @param parent element的父级容器。若不设置，则取element.parent的值。若两者的值都为空，则放弃调整。
	*/
    public static function adjustRelativeByXY(element : IVisualElement, parent : DisplayObjectContainer = null) : Void
    {
        if (element == null) 
            return;
        if (parent == null) 
            parent = element.parent;
			
        if (parent == null) 
            return;
			
        var x : Float = element.x;
        var y : Float = element.y;
        var h : Float = element.layoutBoundsHeight;
        var w : Float = element.layoutBoundsWidth;
        var parentW : Float = parent.width;
        var parentH : Float = parent.height;
        if (!Math.isNaN(element.left)) 
        {
            element.left = x;
        }
        if (!Math.isNaN(element.right)) 
        {
            element.right = parentW - x - w;
        }
        if (!Math.isNaN(element.horizontalCenter)) 
        {
            element.horizontalCenter = x + w * 0.5 - parentW * 0.5;
        }
        
        if (!Math.isNaN(element.top)) 
        {
            element.top = y;
        }
        if (!Math.isNaN(element.bottom)) 
        {
            element.bottom = parentH - y - h;
        }
        if (!Math.isNaN(element.verticalCenter)) 
        {
            element.verticalCenter = h * 0.5 - parentH * 0.5 + y;
        }
    }
}
