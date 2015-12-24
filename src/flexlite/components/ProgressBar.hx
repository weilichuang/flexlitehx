package flexlite.components;


import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

import flexlite.components.supportclasses.Range;
import flexlite.core.UIComponent;
import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.easing.IEaser;
import flexlite.effects.easing.Sine;
import flexlite.events.MoveEvent;
import flexlite.events.ResizeEvent;

@:meta(DXML(show="true"))


/**
* 进度条控件。
* @author chenglong
*/
class ProgressBar extends Range
{
    public var labelFunction(get, set) : Float->Float->String;
    public var slideDuration(get, set) : Float;
    public var direction(get, set) : String;

    public function new()
    {
        super();
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return ProgressBar;
    }
    
    /**
	* [SkinPart]进度高亮显示对象。
	*/
	@SkinPart
    public var thumb : DisplayObject;
    /**
	* [SkinPart]轨道显示对象，用于确定thumb要覆盖的区域。
	*/
	@SkinPart
    public var track : DisplayObject;
    /**
	* [SkinPart]进度条文本
	*/
	@SkinPart
    public var labelDisplay : Label;
    
    private var _labelFunction : Float->Float->String;
    /**
	* 进度条文本格式化回调函数。示例：labelFunction(value:Number,maximum:Number):String;
	*/
    private function get_labelFunction() : Float->Float->String
    {
        return _labelFunction;
    }
    private function set_labelFunction(value : Float->Float->String) : Float->Float->String
    {
        if (_labelFunction == value) 
            return value;
        _labelFunction = value;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* 将当前value转换成文本
	*/
    private function valueToLabel(value : Float, maximum : Float) : String
    {
        if (labelFunction != null) 
        {
            return labelFunction(value, maximum);
        }
        return value + " / " + maximum;
    }
    
    private var _slideDuration : Float = 500;
    
    /**
	* value改变时调整thumb长度的缓动动画时间，单位毫秒。设置为0则不执行缓动。默认值500。
	*/
    private function get_slideDuration() : Float
    {
        return _slideDuration;
    }
    
    private function set_slideDuration(value : Float) : Float
    {
        if (_slideDuration == value) 
            return value;
        _slideDuration = value;
        if (animator != null && animator.isPlaying) 
        {
            animator.stop();
            super.value = slideToValue;
        }
        return value;
    }
    
    private var _direction : String = ProgressBarDirection.LEFT_TO_RIGHT;
    /**
	* 进度条增长方向。请使用ProgressBarDirection定义的常量。默认值：ProgressBarDirection.LEFT_TO_RIGHT。
	*/
    private function get_direction() : String
    {
        return _direction;
    }
    
    private function set_direction(value : String) : String
    {
        if (_direction == value) 
            return value;
        _direction = value;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* 动画实例
	*/
    private var animator : Animation = null;
    /**
	* 动画播放结束时要到达的value。
	*/
    private var slideToValue : Float;
    
    /**
	* 进度条的当前值。
	* 注意：当组件添加到显示列表后，若slideDuration不为0。设置此属性，并不会立即应用。而是作为目标值，开启缓动动画缓慢接近。
	* 若需要立即重置属性，请先设置slideDuration为0，或者把组件从显示列表移除。
	*/
    override private function get_value() : Float
    {
        return super.value;
    }
    override private function set_value(newValue : Float) : Float
    {
        if (super.value == newValue) 
            return newValue;
        if (_slideDuration == 0 || stage == null) 
        {
            super.value = newValue;
        }
        else 
        {
            validateProperties();  //最大值最小值发生改变时要立即应用，防止当前起始值不正确。  
            slideToValue = nearestValidValue(newValue, snapInterval);
            if (slideToValue == super.value) 
                return slideToValue;
            if (animator == null) 
            {
                animator = new Animation(animationUpdateHandler);
                animator.easer = null;
            }
            if (animator.isPlaying) 
            {
                setValue(nearestValidValue(animator.motionPaths[0].valueTo, snapInterval));
                animator.stop();
            }
            var duration : Float = _slideDuration *
            (Math.abs(super.value - slideToValue) / (maximum - minimum));
            animator.duration = duration == Math.POSITIVE_INFINITY ? 0 : duration;
            animator.motionPaths = [
                            new MotionPath("value", super.value, slideToValue)];
            animator.play();
        }
        return newValue;
    }
    
    /**
	* 动画播放更新数值
	*/
    private function animationUpdateHandler(animation : Animation) : Void
    {
        setValue(nearestValidValue(animation.currentValue.value, snapInterval));
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
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        updateSkinDisplayList();
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        if (instance == track) 
        {
            if (Std.is(track, UIComponent)) 
            {
                track.addEventListener(ResizeEvent.RESIZE, onTrackResizeOrMove);
                track.addEventListener(MoveEvent.MOVE, onTrackResizeOrMove);
            }
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        if (instance == track) 
        {
            if (Std.is(track, UIComponent)) 
            {
                track.removeEventListener(ResizeEvent.RESIZE, onTrackResizeOrMove);
                track.removeEventListener(MoveEvent.MOVE, onTrackResizeOrMove);
            }
        }
    }
    
    private var trackResizedOrMoved : Bool = false;
    /**
	* track的位置或尺寸发生改变
	*/
    private function onTrackResizeOrMove(event : Event) : Void
    {
        trackResizedOrMoved = true;
        invalidateProperties();
    }
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (trackResizedOrMoved) 
        {
            trackResizedOrMoved = false;
            updateSkinDisplayList();
        }
    }
    /**
	* 更新皮肤部件大小和可见性。
	*/
    private function updateSkinDisplayList() : Void
    {
        trackResizedOrMoved = false;
        var currentValue : Float = (Math.isNaN(value)) ? 0 : value;
        var maxValue : Float = (Math.isNaN(maximum)) ? 0 : maximum;
        if (thumb != null && track != null) 
        {
            var trackWidth : Float = (Math.isNaN(track.width)) ? 0 : track.width;
            trackWidth *= track.scaleX;
            var trackHeight : Float = (Math.isNaN(track.height)) ? 0 : track.height;
            trackHeight *= track.scaleY;
            var thumbWidth : Float = Math.round((currentValue / maxValue) * trackWidth);
            if (Math.isNaN(thumbWidth) || thumbWidth < 0 || thumbWidth == Math.POSITIVE_INFINITY) 
                thumbWidth = 0;
            var thumbHeight : Float = Math.round((currentValue / maxValue) * trackHeight);
            if (Math.isNaN(thumbHeight) || thumbHeight < 0 || thumbHeight == Math.POSITIVE_INFINITY) 
                thumbHeight = 0;
            var thumbPos : Point = globalToLocal(track.localToGlobal(new Point()));
            switch (_direction)
            {
                case ProgressBarDirection.LEFT_TO_RIGHT:
                    thumb.width = thumbWidth;
                    thumb.x = thumbPos.x;
                case ProgressBarDirection.RIGHT_TO_LEFT:
                    thumb.width = thumbWidth;
                    thumb.x = thumbPos.x + trackWidth - thumbWidth;
                case ProgressBarDirection.TOP_TO_BOTTOM:
                    thumb.height = thumbHeight;
                    thumb.y = thumbPos.y;
                case ProgressBarDirection.BOTTOM_TO_TOP:
                    thumb.height = thumbHeight;
                    thumb.y = thumbPos.y + trackHeight - thumbHeight;
            }
        }
        if (labelDisplay != null) 
        {
            labelDisplay.text = valueToLabel(currentValue, maxValue);
        }
    }
}
