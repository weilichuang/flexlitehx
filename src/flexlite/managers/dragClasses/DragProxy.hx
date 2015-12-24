package flexlite.managers.dragClasses;




import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.Lib;


import flexlite.core.FlexLiteGlobals;
import flexlite.core.DragSource;
import flexlite.core.IUIComponent;
import flexlite.core.UIComponent;
import flexlite.effects.Move;
import flexlite.effects.Scale;
import flexlite.events.DragEvent;
import flexlite.events.EffectEvent;
import flexlite.managers.DragManager;



@:meta(ExcludeClass())


/**
* 拖拽过程中显示的图标
* @author weilichuang
*/
class DragProxy extends UIComponent
{
    /**
	* 构造函数
	* @param dragInitiator 启动拖拽的组件
	* @param dragSource 拖拽的数据源
	*/
    public function new(dragInitiator : InteractiveObject, dragSource : DragSource)
    {
        super();
        mouseChildren = false;
        mouseEnabled = false;
        this.dragInitiator = dragInitiator;
        this.dragSource = dragSource;
        
        var ed : IEventDispatcher = stageRoot = FlexLiteGlobals.stage;
        ed.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
        ed.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
        ed.addEventListener(Event.MOUSE_LEAVE,mouseLeaveHandler);
    }
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        if (stageRoot.focus == null) 
            setFocus();
    }
    /**
	* 上一次的鼠标事件对象
	*/
    private var lastMouseEvent : MouseEvent;
    /**
	* 舞台引用
	*/
    private var stageRoot : Stage;
    /**
	* 启动拖拽的组件
	*/
    public var dragInitiator : InteractiveObject;
    /**
	* 拖拽的数据源
	*/
    public var dragSource : DragSource;
    /**
	* 移动过程中自身的x偏移量
	*/
    public var xOffset : Float;
    /**
	* 移动过程中自身的y偏移量
	*/
    public var yOffset : Float;
    /**
	* 拖拽起始点x坐标
	*/
    public var startX : Float;
    /**
	* 拖拽起始点y坐标
	*/
    public var startY : Float;
    /**
	* 接受当前拖拽数据的目标对象
	*/
    public var target : DisplayObject = null;
    /**
	* 抛出拖拽事件
	*/
    private function dispatchDragEvent(type : String, mouseEvent : MouseEvent, eventTarget : Dynamic) : Void
    {
        var dragEvent : DragEvent = new DragEvent(type);
        var pt : Point = new Point();
        
        dragEvent.dragInitiator = dragInitiator;
        dragEvent.dragSource = dragSource;
        dragEvent.ctrlKey = mouseEvent.ctrlKey;
        dragEvent.altKey = mouseEvent.altKey;
        dragEvent.shiftKey = mouseEvent.shiftKey;
        pt.x = lastMouseEvent.localX;
        pt.y = lastMouseEvent.localY;
        pt = cast(lastMouseEvent.target, DisplayObject).localToGlobal(pt);
        pt = cast(eventTarget, DisplayObject).globalToLocal(pt);
        dragEvent.localX = pt.x;
        dragEvent.localY = pt.y;
        Lib.as(eventTarget, IEventDispatcher).dispatchEvent(dragEvent);
    }
    /**
	* 处理鼠标移动事件
	*/
    private function mouseMoveHandler(event : MouseEvent) : Void
    {
        var dragEvent : DragEvent;
        var dropTarget : DisplayObject;

        lastMouseEvent = event;
        
        var pt : Point = new Point();
        var point : Point = new Point(event.localX, event.localY);
        var stagePoint : Point = cast((event.target), DisplayObject).localToGlobal(point);
        point = parent.globalToLocal(stagePoint);
        var mouseX : Float = point.x;
        var mouseY : Float = point.y;
        x = mouseX - xOffset;
        y = mouseY - yOffset;
        if (event == null) 
        {
            return;
        }
        
        var targetList : Array<Dynamic>;
        targetList = [];
        DragProxy.GetObjectsUnderPoint(stageRoot, stagePoint, targetList);
        
        var newTarget : DisplayObject = null;
        var targetIndex : Int = targetList.length - 1;
        while (targetIndex >= 0)
        {
            newTarget = targetList[targetIndex];
            if (newTarget != this && !contains(newTarget)) 
                break;
            targetIndex--;
        }
        if (target != null) 
        {
            var foundIt : Bool = false;
            var oldTarget : DisplayObject = target;
            
            dropTarget = newTarget;
            
            while (dropTarget != null)
            {
                if (dropTarget == target) 
                {
                    dispatchDragEvent(DragEvent.DRAG_OVER, event, dropTarget);
                    foundIt = true;
                    break;
                }
                else 
                {
                    dispatchDragEvent(DragEvent.DRAG_ENTER, event, dropTarget);
                    if (target == dropTarget) 
                    {
                        foundIt = false;
                        break;
                    }
                }
                dropTarget = dropTarget.parent;
            }
            
            if (!foundIt) 
            {
                dispatchDragEvent(DragEvent.DRAG_EXIT, event, oldTarget);
                
                if (target == oldTarget) 
                    target = null;
            }
        }
        if (target == null) 
        {
            dropTarget = newTarget;
            while (dropTarget != null)
            {
                if (dropTarget != this) 
                {
                    dispatchDragEvent(DragEvent.DRAG_ENTER, event, dropTarget);
                    if (target != null) 
                        break;
                }
                dropTarget = dropTarget.parent;
            }
        }
        if (FlexLiteGlobals.useUpdateAfterEvent) 
            event.updateAfterEvent();
    }
    /**
	* 鼠标移出舞台事件
	*/
    private function mouseLeaveHandler(event : Event) : Void
    {
        mouseUpHandler(lastMouseEvent);
    }
    /**
	* 处理鼠标弹起事件
	*/
    private function mouseUpHandler(event : MouseEvent) : Void
    {
        var ed : IEventDispatcher = stageRoot;
        ed.removeEventListener(MouseEvent.MOUSE_MOVE,
                mouseMoveHandler);
        ed.removeEventListener(MouseEvent.MOUSE_UP,
                mouseUpHandler);
        ed.removeEventListener(Event.MOUSE_LEAVE,
                mouseLeaveHandler);
        
        var dragEvent : DragEvent;
        if (target != null) 
        {
            dragEvent = new DragEvent(DragEvent.DRAG_DROP);
            dragEvent.dragInitiator = dragInitiator;
            dragEvent.dragSource = dragSource;
            if (event != null) 
            {
                dragEvent.ctrlKey = event.ctrlKey;
                dragEvent.altKey = event.altKey;
                dragEvent.shiftKey = event.shiftKey;
            }
            var pt : Point = new Point();
            pt.x = lastMouseEvent.localX;
            pt.y = lastMouseEvent.localY;
            pt = cast((lastMouseEvent.target), DisplayObject).localToGlobal(pt);
            pt = cast((target), DisplayObject).globalToLocal(pt);
            dragEvent.localX = pt.x;
            dragEvent.localY = pt.y;
            target.dispatchEvent(dragEvent);
            
            var scale : Scale = new Scale(this);
            scale.scaleXFrom = scale.scaleYFrom = 1.0;
            scale.scaleXTo = scale.scaleYTo = 0;
            scale.duration = 200;
            scale.play();
            
            var m : Move = new Move(this);
            m.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
            m.xFrom = x;
            m.yFrom = y;
            m.xTo = parent.mouseX;
            m.yTo = parent.mouseY;
            m.duration = 200;
            m.play();
        }
        else 
        {
            
            var move : Move = new Move(this);
            move.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
            move.xFrom = x;
            move.yFrom = y;
            move.xTo = startX;
            move.yTo = startY;
            move.duration = 200;
            move.play();
        }
        
        dragEvent = new DragEvent(DragEvent.DRAG_COMPLETE);
        dragEvent.dragInitiator = dragInitiator;
        dragEvent.dragSource = dragSource;
        dragEvent.relatedObject = cast((target), InteractiveObject);
        if (event != null) 
        {
            dragEvent.ctrlKey = event.ctrlKey;
            dragEvent.altKey = event.altKey;
            dragEvent.shiftKey = event.shiftKey;
        }
        dragInitiator.dispatchEvent(dragEvent);
        
        this.lastMouseEvent = null;
    }
    /**
	* 特效播放完成，结束拖拽。
	*/
    private function effectEndHandler(event : EffectEvent) : Void
    {
        DragManager.endDrag();
    }
    /**
	* 获取舞台下有鼠标事件的显示对象
	*/
    private static function GetObjectsUnderPoint(obj : DisplayObject, pt : Point, arr : Array<Dynamic>) : Void
    {
        if (!obj.visible) 
            return;
        
        if (Std.is(obj, Stage) || obj.hitTestPoint(pt.x, pt.y, true)) 
        {
            if (Std.is(obj, InteractiveObject) && cast((obj), InteractiveObject).mouseEnabled) 
                arr.push(obj);
            if (Std.is(obj, DisplayObjectContainer)) 
            {
                var doc : DisplayObjectContainer = cast(obj, DisplayObjectContainer);
                if (doc.mouseChildren && doc.numChildren != 0) 
                {
                    var n : Int = doc.numChildren;
                    for (i in 0...n){
                        try
                        {
                            var child : DisplayObject = doc.getChildAt(i);
                            GetObjectsUnderPoint(child, pt, arr);
                        }                       
						catch (e : String)
                        {
                            
                            
                        }
                    }
                }
            }
        }
    }
}


