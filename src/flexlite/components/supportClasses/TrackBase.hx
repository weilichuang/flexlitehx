package flexlite.components.supportclasses;


import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import flexlite.components.Button;
import flexlite.core.FlexLiteGlobals;

import flexlite.events.ResizeEvent;
import flexlite.events.TrackBaseEvent;
import flexlite.events.UIEvent;



/**
* 当控件的值由于用户交互操作而发生更改时分派。 
*/
@:meta(Event(name="change",type="flash.events.Event"))

/**
* 改变结束
*/
@:meta(Event(name="changeEnd",type="flexlite.events.UIEvent"))

/**
* 改变开始
*/
@:meta(Event(name="changeStart",type="flexlite.events.UIEvent"))


/**
* 按下滑块并使用鼠标移动滑块时分派。此事件始终发生在 thumbPress 事件之后。
*/
@:meta(Event(name="thumbDrag",type="flexlite.events.TrackBaseEvent"))


/**
* 按下滑块（即用户在滑块上按下鼠标按钮）时分派。
*/
@:meta(Event(name="thumbPress",type="flexlite.events.TrackBaseEvent"))


/**
* 放开滑块（即用户在滑块上弹起鼠标按钮）时分派。
*/
@:meta(Event(name="thumbRelease",type="flexlite.events.TrackBaseEvent"))


@:meta(DXML(show="false"))


/**
* TrackBase类是具有一个轨道和一个或多个滑块按钮的组件的一个基类，如 Slider 和 ScrollBar。
* @author weilichuang
*/
class TrackBase extends Range
{
    public var slideDuration(get, set) : Float;

    public function new()
    {
        super();
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }
    
    private var _slideDuration : Float = 300;
    
    /**
	* 在轨道上单击以移动滑块时，滑动动画持续的时间（以毫秒为单位）。<br/>
	* 此属性用于 Slider 和 ScrollBar。对于 Slider，在轨道上的任何单击将导致生成使用此样式的一个动画，同时滑块将移到单击的位置。<br/>
	* 对于 ScrollBar，仅当按住 Shift 键并单击轨道时才使用此样式，这会导致滑块移到单击的位置。<br/>
	* 未按下 Shift 键时单击 ScrollBar 轨道将导致出现分页行为。<br/>
	* 按住 Shift 键并单击时，必须也对 ScrollBar 设置 smoothScrolling 属性才可以实现动画行为。<br/>
	* 此持续时间是整个滑过轨道的总时间，实际滚动会根据距离相应缩短。
	*/
    private function get_slideDuration() : Float
    {
        return _slideDuration;
    }
    
    private function set_slideDuration(value : Float) : Float
    {
        _slideDuration = value;
        return value;
    }
    
    
    /**
	* [SkinPart]实体滑块组件
	*/
	@SkinPart
    public var thumb : Button;
    
    /**
	* [SkinPart]实体轨道组件
	*/
	@SkinPart
    public var track : Button;
    
    /**
	* @inheritDoc
	*/
    override private function set_maximum(value : Float) : Float
    {
        if (value == super.maximum) 
            return value;
        
        super.maximum = value;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_minimum(value : Float) : Float
    {
        if (value == super.minimum) 
            return value;
        
        super.minimum = value;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_value(newValue : Float) : Float
    {
        if (newValue == super.value) 
            return value;
        
        super.value = newValue;
        invalidateDisplayList();
        return newValue;
    }
    
    /**
	* @inheritDoc
	*/
    override private function setValue(value : Float) : Void
    {
        super.setValue(value);
        invalidateDisplayList();
    }
    
    /**
	* 将相对于轨道的 x,y 像素位置转换为介于最小值和最大值（包括两者）之间的一个值。 
	* @param x 相对于轨道原点的位置的x坐标。
	* @param y 相对于轨道原点的位置的y坐标。
	*/
    private function pointToValue(x : Float, y : Float) : Float
    {
        return minimum;
    }
    
    
    /**
	* @inheritDoc
	*/
    override public function changeValueByStep(increase : Bool = true) : Void
    {
        var prevValue : Float = this.value;
        
        super.changeValueByStep(increase);
        
        if (value != prevValue) 
            dispatchEvent(new Event(Event.CHANGE));
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == thumb) 
        {
            thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
            thumb.addEventListener(ResizeEvent.RESIZE, thumb_resizeHandler);
            thumb.addEventListener(UIEvent.UPDATE_COMPLETE, thumb_updateCompleteHandler);
            thumb.stickyHighlighting = true;
        }
        else if (instance == track) 
        {
            track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
            track.addEventListener(ResizeEvent.RESIZE, track_resizeHandler);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        
        if (instance == thumb) 
        {
            thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
            thumb.removeEventListener(ResizeEvent.RESIZE, thumb_resizeHandler);
            thumb.removeEventListener(UIEvent.UPDATE_COMPLETE, thumb_updateCompleteHandler);
        }
        else if (instance == track) 
        {
            track.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
            track.removeEventListener(ResizeEvent.RESIZE, track_resizeHandler);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(w : Float, h : Float) : Void
    {
        super.updateDisplayList(w, h);
        updateSkinDisplayList();
    }
    
    /**
	* 记录鼠标在thumb上按下的位置
	*/
    private var clickOffset : Point;
    
    /**
	* 更新皮肤部件（通常为滑块）的大小和可见性。<br/>
	* 子类覆盖此方法以基于 minimum、maximum 和 value 属性更新滑块的大小、位置和可见性。 
	*/
    private function updateSkinDisplayList() : Void
    {
        
    }
    
    /**
	* 添加到舞台时
	*/
    private function addedToStageHandler(event : Event) : Void
    {
        updateSkinDisplayList();
    }
    
    /**
	* 轨道尺寸改变事件
	*/
    private function track_resizeHandler(event : Event) : Void
    {
        updateSkinDisplayList();
    }
    
    /**
	* 滑块尺寸改变事件
	*/
    private function thumb_resizeHandler(event : Event) : Void
    {
        updateSkinDisplayList();
    }
    
    /**
	* 滑块三个阶段的延迟布局更新完毕事件
	*/
    private function thumb_updateCompleteHandler(event : Event) : Void
    {
        updateSkinDisplayList();
        thumb.removeEventListener(UIEvent.UPDATE_COMPLETE, thumb_updateCompleteHandler);
    }
    
    
    /**
	* 滑块按下事件
	*/
    private function thumb_mouseDownHandler(event : MouseEvent) : Void
    {
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_MOVE,
                stage_mouseMoveHandler, false, 0, true);
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP,
                stage_mouseUpHandler, false, 0, true);
        FlexLiteGlobals.stage.addEventListener(Event.MOUSE_LEAVE,
                stage_mouseUpHandler, false, 0, true);
        addEventListener(Event.ENTER_FRAME, onEnterFrame);
        
        clickOffset = thumb.globalToLocal(new Point(event.stageX, event.stageY));
        
        dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_PRESS));
        dispatchEvent(new UIEvent(UIEvent.CHANGE_START));
    }
    
    /**
	* 当鼠标拖动thumb时，需要更新value的标记。
	*/
    private var needUpdateValue : Bool = false;
    /**
	* 拖动thumb过程中触发的EnterFrame事件
	*/
    private function onEnterFrame(event : Event) : Void
    {
        if (!needUpdateValue || track == null) 
            return;
        updateWhenMouseMove(null);
        needUpdateValue = false;
    }
    
    /**
	* 当thumb被拖动时更新值，此方法每帧只被调用一次，比直接在鼠标移动事件里更新性能更高。
	*/
    private function updateWhenMouseMove(event:Event) : Void
    {
        if (track == null) 
            return;
        var p : Point = track.globalToLocal(new Point(FlexLiteGlobals.stage.mouseX, FlexLiteGlobals.stage.mouseY));
        var newValue : Float = pointToValue(p.x - clickOffset.x, p.y - clickOffset.y);
        newValue = nearestValidValue(newValue, snapInterval);
        
        if (newValue != value) 
        {
            setValue(newValue);
            validateDisplayList();
            dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_DRAG));
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    /**
	* 鼠标移动事件
	*/
    private function stage_mouseMoveHandler(event : MouseEvent) : Void
    {
        if (needUpdateValue) 
            return;
        needUpdateValue = true;
    }
    
    /**
	* 鼠标弹起事件
	*/
    private function stage_mouseUpHandler(event : Event) : Void
    {
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_MOVE,
                stage_mouseMoveHandler);
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP,
                stage_mouseUpHandler);
        FlexLiteGlobals.stage.removeEventListener(Event.MOUSE_LEAVE,
                stage_mouseUpHandler);
        removeEventListener(Event.ENTER_FRAME, updateWhenMouseMove);
        if (needUpdateValue) 
        {
            updateWhenMouseMove(null);
            needUpdateValue = false;
        }
        dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_RELEASE));
        dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
    }
    
    /**
	* 轨道被按下事件
	*/
    private function track_mouseDownHandler(event : MouseEvent) : Void
    {
        
    }
    
    private var mouseDownTarget : DisplayObject;
    
    /**
	* 当在组件上按下鼠标时记录被按下的子显示对象
	*/
    private function mouseDownHandler(event : MouseEvent) : Void
    {
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP,
                system_mouseUpSomewhereHandler, false, 0, true);
        FlexLiteGlobals.stage.addEventListener(Event.MOUSE_LEAVE,
                system_mouseUpSomewhereHandler, false, 0, true);
        
        mouseDownTarget = cast(event.target, DisplayObject);
    }
    
    /**
	* 当鼠标弹起时，若不是在mouseDownTarget上弹起，而是另外的子显示对象上弹起时，额外抛出一个鼠标单击事件。
	*/
    private function system_mouseUpSomewhereHandler(event : Event) : Void
    {
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP,
                system_mouseUpSomewhereHandler);
        FlexLiteGlobals.stage.removeEventListener(Event.MOUSE_LEAVE,
                system_mouseUpSomewhereHandler);
        if (mouseDownTarget != event.target && Std.is(event, MouseEvent) && contains(cast(event.target, DisplayObject))) 
        {
            var mEvent : MouseEvent = cast(event, MouseEvent);
            
            var mousePoint : Point = new Point(mEvent.localX, mEvent.localY);
            mousePoint = globalToLocal(cast(event.target, DisplayObject).localToGlobal(mousePoint));
            
            dispatchEvent(new MouseEvent(MouseEvent.CLICK, mEvent.bubbles, mEvent.cancelable, mousePoint.x, 
                    mousePoint.y, mEvent.relatedObject, mEvent.ctrlKey, mEvent.altKey, 
                    mEvent.shiftKey, mEvent.buttonDown, mEvent.delta));
        }
        
        mouseDownTarget = null;
    }
}


