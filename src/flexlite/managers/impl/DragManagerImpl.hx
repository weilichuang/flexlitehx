package flexlite.managers.impl;


import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.geom.Point;
import flash.Lib;


import flexlite.core.FlexLiteGlobals;
import flexlite.core.DragSource;
import flexlite.managers.IDragManager;
import flexlite.managers.ILayoutManagerClient;
import flexlite.managers.dragClasses.DragProxy;



@:meta(ExcludeClass())


/**
* 拖拽管理器实现类
* @author weilichuang
*/
class DragManagerImpl implements IDragManager
{
    public var isDragging(get, never) : Bool;

    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    /**
	* 启动拖拽的组件
	*/
    private var dragInitiator : InteractiveObject;
    /**
	* 拖拽显示的图标
	*/
    private var dragProxy : DragProxy;
    
    private var _isDragging : Bool = false;
    /**
	* 正在拖拽的标志
	*/
    private function get_isDragging() : Bool
    {
        return _isDragging;
    }
    /**
	* 启动拖拽操作。请在MouseDown事件里执行此方法。
	* @param dragInitiator 启动拖拽的组件
	* @param dragSource 拖拽的数据源
	* @param dragImage 拖拽过程中显示的图像
	* @param xOffset dragImage相对dragInitiator的x偏移量,默认0。
	* @param yOffset dragImage相对dragInitiator的y偏移量,默认0。
	* @param imageAlpha dragImage的透明度，默认0.5。
	*/
    public function doDrag(
            dragInitiator : InteractiveObject,
            dragSource : DragSource,
            dragImage : DisplayObject = null,
            xOffset : Float = 0,
            yOffset : Float = 0,
            imageAlpha : Float = 0.5) : Void
    {
        if (_isDragging) 
            return;
        
        _isDragging = true;
        
        this.dragInitiator = dragInitiator;
        
        dragProxy = new DragProxy(dragInitiator, dragSource);
        var stage : Stage = FlexLiteGlobals.stage;
        if (stage == null) 
            return;
        stage.addChild(dragProxy);
        
        if (dragImage != null) 
        {
            dragProxy.addToDisplayList(dragImage);
            if (Std.is(dragImage, ILayoutManagerClient)) 
                FlexLiteGlobals.layoutManager.validateClient(Lib.as(dragImage, ILayoutManagerClient), true);
        }
        
        dragProxy.alpha = imageAlpha;
        
        var mouseX : Float = stage.mouseX;
        var mouseY : Float = stage.mouseY;
        var proxyOrigin : Point = dragInitiator.localToGlobal(new Point(-xOffset, -yOffset));
        dragProxy.xOffset = mouseX - proxyOrigin.x;
        dragProxy.yOffset = mouseY - proxyOrigin.y;
        dragProxy.x = proxyOrigin.x;
        dragProxy.y = proxyOrigin.y;
        dragProxy.startX = dragProxy.x;
        dragProxy.startY = dragProxy.y;
        if (dragImage != null) 
            dragImage.cacheAsBitmap = true;
    }
    /**
	* 接受拖拽的数据源。通常在dragEnter事件处理函数调用此方法。
	* 传入target后，若放下数据源。target将能监听到dragDrop事件。
	*/
    public function acceptDragDrop(target : InteractiveObject) : Void
    {
        if (dragProxy != null) 
            dragProxy.target = target;
    }
    /**
	* 结束拖拽
	*/
    public function endDrag() : Void
    {
        if (dragProxy != null) 
        {
            dragProxy.parent.removeChild(dragProxy);
            
            if (dragProxy.numChildren > 0) 
                dragProxy.removeFromDisplayListAt(0);
            dragProxy = null;
        }
        dragInitiator = null;
        _isDragging = false;
    }
}
