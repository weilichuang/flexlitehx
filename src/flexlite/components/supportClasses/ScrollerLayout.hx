package flexlite.components.supportclasses;


import flash.geom.Point;
import flash.Lib;


import flexlite.components.Scroller;
import flexlite.core.ILayoutElement;
import flexlite.core.IViewport;
import flexlite.core.ScrollPolicy;
import flexlite.core.UIComponent;
import flexlite.layouts.supportclasses.LayoutBase;


/**
* 滚动条布局类
* @author weilichuang
*/
class ScrollerLayout extends LayoutBase
{
    public var useMinimalContentSize(get, set) : Bool;
    private var hsbVisible(get, set) : Bool;
    private var vsbVisible(get, set) : Bool;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    private var _useMinimalContentSize : Bool = false;
    /**
	* 使用最小的视域尺寸（排除两端空白区域）来决定是否显示滚动条。设置此属性为true，会由Scroller自行测量视域尺寸，
	* 而不采用viewport提供的视域尺寸。通常用于避免特殊情况下滚动条无限循环问题(viewport含有设置过相对布局属性的子项)。
	*/
    private function get_useMinimalContentSize() : Bool
    {
        return _useMinimalContentSize;
    }
    
    private function set_useMinimalContentSize(value : Bool) : Bool
    {
        if (_useMinimalContentSize == value) 
            return value;
        _useMinimalContentSize = value;
        if (target != null) 
        {
            target.invalidateDisplayList();
        }
        return value;
    }
    
    /**
	* 开始显示滚动条的最小溢出值。例如：contentWidth >= viewport width + SDT时显示水平滚动条。
	*/
    private static inline var SDT : Float = 1.0;
    
    /**
	* 获取滚动条实例
	*/
    private function getScroller() : Scroller
    {
        return cast(target.parent, Scroller);
    }
    
    /**
	* 获取目标视域组件的视域尺寸
	*/
    private function getLayoutContentSize(viewport : IViewport) : Point
    {
        var group : GroupBase = Std.instance(viewport, GroupBase);
        if (group != null && _useMinimalContentSize) 
        {
            return measureContentSize(group);
        }
        var cw : Float = viewport.contentWidth;
        var ch : Float = viewport.contentHeight;
        if (((cw == 0) && (ch == 0)) || (Math.isNaN(cw) || Math.isNaN(ch))) 
            return new Point(0, 0);
        return new Point(cw, ch);
    }
    /**
	* 重新测量viewport的视域尺寸，如果有相对布局属性，排除两端的空白。
	*/
    private function measureContentSize(target : GroupBase) : Point
    {
        var maxX : Float = 0;
        var maxY : Float = 0;
        var minX : Float = 0;
        var minY : Float = 0;
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
            
            var preferredX : Float = layoutElement.preferredX;
            var preferredY : Float = layoutElement.preferredY;
            var preferredWidth : Float = layoutElement.preferredWidth;
            var preferredHeight : Float = layoutElement.preferredHeight;
            minX = Math.floor(Math.min(minX, preferredX));
            minY = Math.floor(Math.min(minY, preferredY));
            maxX = Math.ceil(Math.max(maxX, preferredX + preferredWidth));
            maxY = Math.ceil(Math.max(maxY, preferredY + preferredHeight));
			
			i++;
        }
        return new Point(maxX - minX, maxY - minY);
    }
    
    
    private var hsbScaleX : Float = 1;
    private var hsbScaleY : Float = 1;
    
    /**
	* 水平滚动条是否可见
	*/
    private function get_hsbVisible() : Bool
    {
        var hsb : ScrollBarBase = getScroller().horizontalScrollBar;
        return hsb != null && hsb.visible;
    }
    
    private function set_hsbVisible(value : Bool) : Bool
    {
        var hsb : ScrollBarBase = getScroller().horizontalScrollBar;
        if (hsb == null) 
            return false;
        if (hsb.visible == value) 
            return value;
        hsb.visible = value;
        hsb.includeInLayout = value;
        return value;
    }
    
    /**
	* 返回考虑进水平滚动条后组件所需的最小高度
	*/
    private function hsbRequiredHeight() : Float
    {
        var scroller : Scroller = getScroller();
        var minViewportInset : Float = scroller.minViewportInset;
        var hsb : ScrollBarBase = scroller.horizontalScrollBar;
        return Math.max(minViewportInset, hsb.preferredHeight);
    }
    
    /**
	* 返回指定的尺寸下水平滚动条是否能够放下
	*/
    private function hsbFits(w : Float, h : Float, includeVSB : Bool = true) : Bool
    {
        if (vsbVisible && includeVSB) 
        {
            var vsb : ScrollBarBase = getScroller().verticalScrollBar;
            w -= vsb.preferredWidth;
            h -= vsb.minHeight;
        }
        var hsb : ScrollBarBase = getScroller().horizontalScrollBar;
        return (w >= hsb.minWidth) && (h >= hsb.preferredHeight);
    }
    
    private var vsbScaleX : Float = 1;
    private var vsbScaleY : Float = 1;
    
    /**
	* 垂直滚动条是否可见
	*/
    private function get_vsbVisible() : Bool
    {
        var vsb : ScrollBarBase = getScroller().verticalScrollBar;
        return vsb != null && vsb.visible;
    }
    
    private function set_vsbVisible(value : Bool) : Bool
    {
        var vsb : ScrollBarBase = getScroller().verticalScrollBar;
        if (vsb == null) 
            return false;
        if (vsb.visible == value) 
            return value;
        vsb.visible = value;
        vsb.includeInLayout = value;
        return value;
    }
    
    /**
	* 返回考虑进垂直滚动条后组件所需用的最小宽度
	*/
    private function vsbRequiredWidth() : Float
    {
        var scroller : Scroller = getScroller();
        var minViewportInset : Float = scroller.minViewportInset;
        var vsb : ScrollBarBase = scroller.verticalScrollBar;
        return Math.max(minViewportInset, vsb.preferredWidth);
    }
    
    /**
	* 返回在指定的尺寸下垂直滚动条是否能够放下
	*/
    private function vsbFits(w : Float, h : Float, includeHSB : Bool = true) : Bool
    {
        if (hsbVisible && includeHSB) 
        {
            var hsb : ScrollBarBase = getScroller().horizontalScrollBar;
            w -= hsb.minWidth;
            h -= hsb.preferredHeight;
        }
        var vsb : ScrollBarBase = getScroller().verticalScrollBar;
        return (w >= vsb.preferredWidth) && (h >= vsb.minHeight);
    }
    
    /**
	* @inheritDoc
	*/
    override public function measure() : Void
    {
        var scroller : Scroller = getScroller();
        if (scroller == null) 
            return;
        
        var minViewportInset : Float = scroller.minViewportInset;
        var measuredSizeIncludesScrollBars : Bool = scroller.measuredSizeIncludesScrollBars;
        
        var measuredW : Float = minViewportInset;
        var measuredH : Float = minViewportInset;
        
        var hsb : ScrollBarBase = scroller.horizontalScrollBar;
        var showHSB : Bool = false;
        var hAuto : Bool = false;
		
		var _sw3_:String = null;
        if (measuredSizeIncludesScrollBars) 
            _sw3_ = (scroller.horizontalScrollPolicy);        

        switch (_sw3_)
        {
            case ScrollPolicy.ON:
                if (hsb != null)                    
					showHSB = true;
            case ScrollPolicy.AUTO:
                if (hsb != null)                    
					showHSB = hsb.visible;
                hAuto = true;
        }
        
        var vsb : ScrollBarBase = scroller.verticalScrollBar;
        var showVSB : Bool = false;
        var vAuto : Bool = false;
		
		var _sw4_:String = null;
        if (measuredSizeIncludesScrollBars) 
            _sw4_ = (scroller.verticalScrollPolicy);        

        switch (_sw4_)
        {
            case ScrollPolicy.ON:
                if (vsb != null)                    
					showVSB = true;
            case ScrollPolicy.AUTO:
                if (vsb != null)                    
					showVSB = vsb.visible;
                vAuto = true;
        };
        
        measuredH += ((showHSB)) ? hsbRequiredHeight() : minViewportInset;
        measuredW += ((showVSB)) ? vsbRequiredWidth() : minViewportInset;
        var viewport : IViewport = scroller.viewport;
        if (viewport != null) 
        {
            if (measuredSizeIncludesScrollBars) 
            {
                var viewportPreferredW : Float = viewport.preferredWidth;
                measuredW += Math.max(viewportPreferredW, ((showHSB)) ? hsb.minWidth : 0);
                
                var viewportPreferredH : Float = viewport.preferredHeight;
                measuredH += Math.max(viewportPreferredH, ((showVSB)) ? vsb.minHeight : 0);
            }
            else 
            {
                measuredW += viewport.preferredWidth;
                measuredH += viewport.preferredHeight;
            }
        }
        
        var minW : Float = minViewportInset * 2;
        var minH : Float = minViewportInset * 2;
        var viewportUIC : UIComponent = cast(viewport, UIComponent);
        var explicitViewportW : Float = (viewportUIC != null) ? viewportUIC.explicitWidth : Math.NaN;
        var explicitViewportH : Float = (viewportUIC != null) ? viewportUIC.explicitHeight : Math.NaN;
        
        if (!Math.isNaN(explicitViewportW)) 
            minW += explicitViewportW;
        
        if (!Math.isNaN(explicitViewportH)) 
            minH += explicitViewportH;
        
        var g : GroupBase = target;
        g.measuredWidth = Math.ceil(measuredW);
        g.measuredHeight = Math.ceil(measuredH);
    }
    
    /**
	* 布局计数，防止发生无限循环。
	*/
    private var invalidationCount : Int = 0;
    
    //		Bug备注：
    //		当viewport含有相对布局元素的子项(content尺寸跟随viewport尺寸而变，这是不规范的用法)，
    //		且水平和垂直滚动条同时到达临界显示值时，会出现无限循环验证的情况。
    //		(显示滚动条会导致content尺寸变小，继而导致关闭滚动条，content尺寸又变大，又开启滚动条...)
    //		暂时没有根治的解决方案，只能通过计数检查的方式断开循环。
    
    /**
	* @inheritDoc
	*/
    override public function updateDisplayList(w : Float, h : Float) : Void
    {
        var scroller : Scroller = getScroller();
        if (scroller == null) 
            return;
        var viewport : IViewport = scroller.viewport;
        var hsb : ScrollBarBase = scroller.horizontalScrollBar;
        var vsb : ScrollBarBase = scroller.verticalScrollBar;
        var minViewportInset : Float = scroller.minViewportInset;
        
        var contentW : Float = 0;
        var contentH : Float = 0;
        if (viewport != null) 
        {
            var contentSize : Point = getLayoutContentSize(viewport);
            contentW = contentSize.x;
            contentH = contentSize.y;
        }
        var viewportUIC : UIComponent = cast(viewport, UIComponent);
        var explicitViewportW : Float = (viewportUIC != null) ? viewportUIC.explicitWidth : Math.NaN;
        var explicitViewportH : Float = (viewportUIC != null) ? viewportUIC.explicitHeight : Math.NaN;
        
        var viewportW : Float = (Math.isNaN(explicitViewportW)) ? (w - (minViewportInset * 2)) : explicitViewportW;
        var viewportH : Float = (Math.isNaN(explicitViewportH)) ? (h - (minViewportInset * 2)) : explicitViewportH;
        var oldShowHSB : Bool = hsbVisible;
        var oldShowVSB : Bool = vsbVisible;
        
        var hAuto : Bool = false;
        var _sw5_ = (scroller.horizontalScrollPolicy);        

        switch (_sw5_)
        {
            case ScrollPolicy.ON:
                hsbVisible = true;
            
            case ScrollPolicy.AUTO:
                if (hsb != null && viewport != null) 
                {
                    hAuto = true;
                    hsbVisible = (contentW >= (viewportW + SDT));
                }
            
            default:
                hsbVisible = false;
        }
        
        var vAuto : Bool = false;
        var _sw6_ = (scroller.verticalScrollPolicy);        

        switch (_sw6_)
        {
            case ScrollPolicy.ON:
                vsbVisible = true;
            
            case ScrollPolicy.AUTO:
                if (vsb != null && viewport != null) 
                {
                    vAuto = true;
                    vsbVisible = (contentH >= (viewportH + SDT));
                }
            
            default:
                vsbVisible = false;
        }
        if (Math.isNaN(explicitViewportW)) 
            viewportW = w - (((vsbVisible)) ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2))
        else 
        viewportW = explicitViewportW;
        
        if (Math.isNaN(explicitViewportH)) 
            viewportH = h - (((hsbVisible)) ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2))
        else 
        viewportH = explicitViewportH;
        var hsbIsDependent : Bool = false;
        var vsbIsDependent : Bool = false;
        
        if (vsbVisible && !hsbVisible && hAuto && (contentW >= (viewportW + SDT))) 
            hsbVisible = hsbIsDependent = true
        else if (!vsbVisible && hsbVisible && vAuto && (contentH >= (viewportH + SDT))) 
            vsbVisible = vsbIsDependent = true;
        if (hsbVisible && vsbVisible) 
        {
            if (hsbFits(w, h) && vsbFits(w, h)) 
            {
                
                
            }
            else if (!hsbFits(w, h, false) && !vsbFits(w, h, false)) 
            {
                
                hsbVisible = false;
                vsbVisible = false;
            }
            else 
            {
                if (hsbIsDependent) 
                {
                    if (vsbFits(w, h, false)) 
                        hsbVisible = false
                    else 
                    vsbVisible = hsbVisible = false;
                }
                else if (vsbIsDependent) 
                {
                    if (hsbFits(w, h, false)) 
                        vsbVisible = false
                    else 
                    hsbVisible = vsbVisible = false;
                }
                else if (vsbFits(w, h, false)) 
                    hsbVisible = false
                else 
                vsbVisible = false;
            }
        }
        else if (hsbVisible && !hsbFits(w, h)) 
            hsbVisible = false
        else if (vsbVisible && !vsbFits(w, h)) 
            vsbVisible = false;
        if (Math.isNaN(explicitViewportW)) 
            viewportW = w - (((vsbVisible)) ? (minViewportInset + vsbRequiredWidth()) : (minViewportInset * 2))
        else 
        viewportW = explicitViewportW;
        
        if (Math.isNaN(explicitViewportH)) 
            viewportH = h - (((hsbVisible)) ? (minViewportInset + hsbRequiredHeight()) : (minViewportInset * 2))
        else 
        viewportH = explicitViewportH;
        if (viewport != null) 
        {
            viewport.setLayoutBoundsSize(viewportW, viewportH);
            viewport.setLayoutBoundsPosition(minViewportInset, minViewportInset);
        }
        
        if (hsbVisible) 
        {
            var hsbW : Float = ((vsbVisible)) ? w - vsb.preferredWidth : w;
            var hsbH : Float = hsb.preferredHeight;
            hsb.setLayoutBoundsSize(Math.max(hsb.minWidth, hsbW), hsbH);
            hsb.setLayoutBoundsPosition(0, h - hsbH);
        }
        
        if (vsbVisible) 
        {
            var vsbW : Float = vsb.preferredWidth;
            var vsbH : Float = ((hsbVisible)) ? h - hsb.preferredHeight : h;
            vsb.setLayoutBoundsSize(vsbW, Math.max(vsb.minHeight, vsbH));
            vsb.setLayoutBoundsPosition(w - vsbW, 0);
        }
        if ((invalidationCount < 2) && (((vsbVisible != oldShowVSB) && vAuto) || ((hsbVisible != oldShowHSB) && hAuto))) 
        {
            target.invalidateSize();
            var viewportGroup : GroupBase = cast(viewport, GroupBase);
            if (viewportGroup != null && viewportGroup.layout != null && viewportGroup.layout.useVirtualLayout) 
                viewportGroup.invalidateSize();
            
            invalidationCount += 1;
        }
        else 
        invalidationCount = 0;
        
        target.setContentSize(w, h);
    }
}


