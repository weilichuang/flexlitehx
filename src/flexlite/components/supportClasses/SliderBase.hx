package flexlite.components.supportclasses;

import flexlite.components.supportclasses.TrackBase;


import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import flexlite.core.FlexLiteGlobals;

import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.easing.Sine;
import flexlite.events.TrackBaseEvent;
import flexlite.events.UIEvent;



@:meta(DXML(show="false"))

/**
* 滑块控件基类
* @author weilichuang
*/
class SliderBase extends TrackBase
{
    public var showTrackHighlight(get, set) : Bool;
    private var pendingValue(get, set) : Float;
    public var liveDragging(get, set) : Bool;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        maximum = 10;
    }
    
    /**
	* [SkinPart]轨道高亮显示对象
	*/
	@SkinPart
    public var trackHighlight : InteractiveObject;
    
    private var _showTrackHighlight : Bool = true;
    
    /**
	* 是否启用轨道高亮效果。默认值为true。
	* 注意，皮肤里的子部件trackHighlight要同时为非空才能显示高亮效果。
	*/
    private function get_showTrackHighlight() : Bool
    {
        return _showTrackHighlight;
    }
    
    private function set_showTrackHighlight(value : Bool) : Bool
    {
        if (_showTrackHighlight == value) 
            return value;
        _showTrackHighlight = value;
        if (trackHighlight != null) 
            trackHighlight.visible = value;
        invalidateDisplayList();
        return value;
    }
    
    
    /**
	* 动画实例
	*/
    private var animator : Animation = null;
    
    /**
	* @inheritDoc
	*/
    override private function get_maximum() : Float
    {
        return super.maximum;
    }
    
    private var _pendingValue : Float = 0;
    /**
	* 释放鼠标按键时滑块将具有的值。无论liveDragging是否为true，在滑块拖动期间始终更新此属性。
	* 而value属性在当liveDragging为false时，只在鼠标释放时更新一次。
	*/
    private function get_pendingValue() : Float
    {
        return _pendingValue;
    }
    private function set_pendingValue(value : Float) : Float
    {
        if (value == _pendingValue) 
            return value;
        _pendingValue = value;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function setValue(value : Float) : Void
    {
        _pendingValue = value;
        
        super.setValue(value);
    }
    /**
	* 动画播放更新数值
	*/
    private function animationUpdateHandler(animation : Animation) : Void
    {
        pendingValue = Reflect.getProperty(animation.currentValue, "value");
    }
    /**
	* 动画播放结束时要到达的value。
	*/
    private var slideToValue : Float;
    /**
	* 动画播放完毕
	*/
    private function animationEndHandler(animation : Animation) : Void
    {
        setValue(slideToValue);
        
        dispatchEvent(new Event(Event.CHANGE));
        dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
    }
    /**
	* 停止播放动画
	*/
    private function stopAnimation() : Void
    {
        animator.stop();
        
        setValue(nearestValidValue(pendingValue, snapInterval));
        
        dispatchEvent(new Event(Event.CHANGE));
        dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
    }
    
    /**
	* @inheritDoc
	*/
    override private function thumb_mouseDownHandler(event : MouseEvent) : Void
    {
        if (animator != null && animator.isPlaying) 
            stopAnimation();
        
        super.thumb_mouseDownHandler(event);
    }
    
    private var _liveDragging : Bool = true;
    /**
	* 如果为 true，则将在沿着轨道拖动滑块时，而不是在释放滑块按钮时，提交此滑块的值。
	*/
    private function get_liveDragging() : Bool
    {
        return _liveDragging;
    }
    
    private function set_liveDragging(value : Bool) : Bool
    {
        _liveDragging = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateWhenMouseMove(event:Event) : Void
    {
        if (track == null) 
            return;
        
        var pos : Point = track.globalToLocal(new Point(FlexLiteGlobals.stage.mouseX, FlexLiteGlobals.stage.mouseY));
        var newValue : Float = pointToValue(pos.x - clickOffset.x, pos.y - clickOffset.y);
        newValue = nearestValidValue(newValue, snapInterval);
        
        if (newValue != pendingValue) 
        {
            dispatchEvent(new TrackBaseEvent(TrackBaseEvent.THUMB_DRAG));
            if (liveDragging == true) 
            {
                setValue(newValue);
                dispatchEvent(new Event(Event.CHANGE));
            }
            else 
            {
                pendingValue = newValue;
            }
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function stage_mouseUpHandler(event : Event) : Void
    {
        super.stage_mouseUpHandler(event);
        if ((liveDragging == false) && (value != pendingValue)) 
        {
            setValue(pendingValue);
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function track_mouseDownHandler(event : MouseEvent) : Void
    {
        if (!enabled) 
            return;
        var thumbW : Float = (thumb != null) ? thumb.width : 0;
        var thumbH : Float = (thumb != null) ? thumb.height : 0;
        var offsetX : Float = event.stageX - (thumbW / 2);
        var offsetY : Float = event.stageY - (thumbH / 2);
        var p : Point = track.globalToLocal(new Point(offsetX, offsetY));
        
        var newValue : Float = pointToValue(p.x, p.y);
        newValue = nearestValidValue(newValue, snapInterval);
        
        if (newValue != pendingValue) 
        {
            if (slideDuration != 0) 
            {
                if (animator == null) 
                {
                    animator = new Animation(animationUpdateHandler);
                    animator.endFunction = animationEndHandler;
                    
                    animator.easer = new Sine(0);
                }
                if (animator.isPlaying) 
                    stopAnimation();
                slideToValue = newValue;
                animator.duration = slideDuration *
                        (Math.abs(pendingValue - slideToValue) / (maximum - minimum));
                animator.motionPaths = [
                                new MotionPath("value", pendingValue, slideToValue)];
                
                dispatchEvent(new UIEvent(UIEvent.CHANGE_START));
                animator.play();
            }
            else 
            {
                setValue(newValue);
                dispatchEvent(new Event(Event.CHANGE));
            }
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        if (instance == trackHighlight) 
        {
            trackHighlight.mouseEnabled = false;
            if (Std.is(trackHighlight, DisplayObjectContainer)) 
                (cast(trackHighlight, DisplayObjectContainer)).mouseChildren = false;
            trackHighlight.visible = _showTrackHighlight;
        }
    }
}


