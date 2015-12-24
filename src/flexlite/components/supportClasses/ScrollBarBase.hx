package flexlite.components.supportclasses;

import flexlite.components.supportclasses.TrackBase;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Timer;


import flexlite.components.Button;
import flexlite.core.FlexLiteGlobals;
import flexlite.core.IViewport;
import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.easing.IEaser;
import flexlite.effects.easing.Linear;
import flexlite.effects.easing.Sine;
import flexlite.events.PropertyChangeEvent;
import flexlite.events.ResizeEvent;
import flexlite.events.UIEvent;



@:meta(DXML(show="false"))


@:meta(DefaultProperty(name="viewport",array="false"))

/**
* 滚动条基类
* @author weilichuang
*/
class ScrollBarBase extends TrackBase
{
    private var animator(get, never) : Animation;
    public var pageSize(get, set) : Float;
    public var smoothScrolling(get, set) : Bool;
    public var repeatInterval(get, set) : Float;
    public var fixedThumbSize(get, set) : Bool;
    public var repeatDelay(get, set) : Float;
    public var autoThumbVisibility(get, set) : Bool;
    public var viewport(get, set) : IViewport;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    /**
	* [SkinPart]减小滚动条值的按钮
	*/
	@SkinPart
    public var decrementButton : Button;
    
    /**
	* [SkinPart]增大滚动条值的按钮
	*/
	@SkinPart
    public var incrementButton : Button;
    
    
    private var _animator : Animation = null;
    /**
	* 动画类实例
	*/
    private function get_animator() : Animation
    {
        if (_animator != null) 
            return _animator;
        _animator = new Animation(animationUpdateHandler);
        _animator.endFunction = animationEndHandler;
        return _animator;
    }
    
    /**
	* 用户在操作系统中可以设置将鼠标滚轮每滚动一个单位应滚动多少行。
	* 当使用鼠标滚轮滚动此组件的目标容器时，true表示根据用户系统设置的值滚动对应的行数。
	* false则忽略系统设置，始终只滚动一行。默认值为true。
	*/
    public var useMouseWheelDelta : Bool;
    
    /**
	* 正在步进增大值的标志
	*/
    private var steppingDown : Bool;
    /**
	* 正在步进减小值的标志
	*/
    private var steppingUp : Bool;
    
    /**
	* 正在步进改变值的标志
	*/
    private var isStepping : Bool;
    
    private var animatingOnce : Bool;
    
    /**
	* 滚动动画用到的缓动类
	*/
    private static var linearEaser : IEaser = new Linear();
    private static var easyInLinearEaser : IEaser = new Linear(.1);
    private static var deceleratingSineEaser : IEaser = new Sine(0);
    
    /**
	* 记录当前滚动方向的标志
	*/
    private var trackScrollDown : Bool;
    
    /**
	* 当鼠标按住轨道时用于循环滚动的计时器
	*/
    private var trackScrollTimer : Timer;
    
    /**
	* 在鼠标按住轨道的滚动过程中记录滚动的位置
	*/
    private var trackPosition : Point = new Point();
    
    /**
	* 正在进行鼠标按住轨道滚动过程的标志
	*/
    private var trackScrolling : Bool = false;
    
    /**
	* @inheritDoc
	*/
    override private function set_minimum(value : Float) : Float
    {
        if (value == super.minimum) 
            return value;
        
        super.minimum = value;
        invalidateSkinState();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_maximum(value : Float) : Float
    {
        if (value == super.maximum) 
            return value;
        
        super.maximum = value;
        invalidateSkinState();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function set_snapInterval(value : Float) : Float
    {
        super.snapInterval = value;
        pageSizeChanged = true;
        return value;
    }
    
    private var _pageSize : Float = 20;
    
    /**
	* 翻页大小改变标志
	*/
    private var pageSizeChanged : Bool = false;
    
    /**
	* 翻页大小,调用 changeValueByPage() 方法时 value 属性值的改变量。
	*/
    private function get_pageSize() : Float
    {
        return _pageSize;
    }
    
    private function set_pageSize(value : Float) : Float
    {
        if (value == _pageSize) 
            return value;
        
        _pageSize = value;
        pageSizeChanged = true;
        
        invalidateProperties();
        invalidateDisplayList();
        return value;
    }
    
    
    private var _smoothScrolling : Bool = true;
    
    /**
	* 翻页和步进时滚动条是否播放平滑的动画。
	*/
    private function get_smoothScrolling() : Bool
    {
        return _smoothScrolling;
    }
    
    private function set_smoothScrolling(value : Bool) : Bool
    {
        _smoothScrolling = value;
        return value;
    }
    
    
    private var _repeatInterval : Float = 35;
    
    /**
	* 用户在轨道上按住鼠标时，page 事件之间相隔的毫秒数。
	*/
    private function get_repeatInterval() : Float
    {
        return _repeatInterval;
    }
    
    private function set_repeatInterval(value : Float) : Float
    {
        _repeatInterval = value;
        return value;
    }
    
    
    private var _fixedThumbSize : Bool = false;
    
    /**
	* 如果为 true，则沿着滚动条的滑块的大小将不随滚动条最大值改变。
	*/
    private function get_fixedThumbSize() : Bool
    {
        return _fixedThumbSize;
    }
    
    private function set_fixedThumbSize(value : Bool) : Bool
    {
        if (_fixedThumbSize == value) 
            return value;
        _fixedThumbSize = value;
        invalidateDisplayList();
        return value;
    }
    
    
    private var _repeatDelay : Float = 500;
    
    /**
	* 在第一个 page 事件之后直到后续的 page 事件发生之间相隔的毫秒数。
	*/
    private function get_repeatDelay() : Float
    {
        return _repeatDelay;
    }
    
    private function set_repeatDelay(value : Float) : Float
    {
        _repeatDelay = value;
        return value;
    }
    
    
    private var _autoThumbVisibility : Bool = true;
    
    /**
	* 如果为 true（默认值），则无论何时更新滑块的大小，都将重置滑块的可见性。
	*/
    private function get_autoThumbVisibility() : Bool
    {
        return _autoThumbVisibility;
    }
    
    private function set_autoThumbVisibility(value : Bool) : Bool
    {
        if (_autoThumbVisibility == value) 
            return value;
        _autoThumbVisibility = value;
        invalidateDisplayList();
        return value;
    }
    
    
    private var _viewport : IViewport;
    
    /**
	* 由此滚动条控制的可滚动组件。
	*/
    private function get_viewport() : IViewport
    {
        return _viewport;
    }
    private function set_viewport(value : IViewport) : IViewport
    {
        if (value == _viewport) 
            return value;
        
        if (_viewport != null) 
        {
            _viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
            _viewport.removeEventListener(ResizeEvent.RESIZE, viewportResizeHandler);
            _viewport.clipAndEnableScrolling = false;
        }
        
        _viewport = value;
        
        if (_viewport != null) 
        {
            _viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
            _viewport.addEventListener(ResizeEvent.RESIZE, viewportResizeHandler);
            _viewport.clipAndEnableScrolling = true;
        }
        return value;
    }
    
    /**
	* 开始播放动画
	*/
    private function startAnimation(duration : Float, valueTo : Float,
            easer : IEaser, startDelay : Float = 0) : Void
    {
        animator.stop();
        animator.duration = duration;
        animator.easer = easer;
        animator.motionPaths = [
                        new MotionPath("value", value, valueTo)];
        animator.startDelay = startDelay;
        animator.play();
    }
    
    /**
	* 根据指定数值返回最接近snapInterval的整数倍的数值
	*/
    override private function nearestValidSize(size : Float) : Float
    {
        var interval : Float = snapInterval;
        if (interval == 0) 
            return size;
        
        var validSize : Float = Math.round(size / interval) * interval;
        return ((Math.abs(validSize) < interval)) ? interval : validSize;
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (pageSizeChanged) 
        {
            _pageSize = nearestValidSize(_pageSize);
            pageSizeChanged = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == decrementButton) 
        {
            decrementButton.addEventListener(UIEvent.BUTTON_DOWN,
                    button_buttonDownHandler);
            decrementButton.addEventListener(MouseEvent.ROLL_OVER,
                    button_rollOverHandler);
            decrementButton.addEventListener(MouseEvent.ROLL_OUT,
                    button_rollOutHandler);
            decrementButton.autoRepeat = true;
        }
        else if (instance == incrementButton) 
        {
            incrementButton.addEventListener(UIEvent.BUTTON_DOWN,
                    button_buttonDownHandler);
            incrementButton.addEventListener(MouseEvent.ROLL_OVER,
                    button_rollOverHandler);
            incrementButton.addEventListener(MouseEvent.ROLL_OUT,
                    button_rollOutHandler);
            incrementButton.autoRepeat = true;
        }
        else if (instance == track) 
        {
            track.addEventListener(MouseEvent.ROLL_OVER,
                    track_rollOverHandler);
            track.addEventListener(MouseEvent.ROLL_OUT,
                    track_rollOutHandler);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        
        if (instance == decrementButton) 
        {
            decrementButton.removeEventListener(UIEvent.BUTTON_DOWN,
                    button_buttonDownHandler);
            decrementButton.removeEventListener(MouseEvent.ROLL_OVER,
                    button_rollOverHandler);
            decrementButton.removeEventListener(MouseEvent.ROLL_OUT,
                    button_rollOutHandler);
        }
        else if (instance == incrementButton) 
        {
            incrementButton.removeEventListener(UIEvent.BUTTON_DOWN,
                    button_buttonDownHandler);
            incrementButton.removeEventListener(MouseEvent.ROLL_OVER,
                    button_rollOverHandler);
            incrementButton.removeEventListener(MouseEvent.ROLL_OUT,
                    button_rollOutHandler);
        }
        else if (instance == track) 
        {
            track.removeEventListener(MouseEvent.ROLL_OVER,
                    track_rollOverHandler);
            track.removeEventListener(MouseEvent.ROLL_OUT,
                    track_rollOutHandler);
        }
    }
    
    /**
	* 从 value 增加或减去 pageSize。每次增加后，新的 value 是大于当前 value 的 pageSize 的最接近倍数。<br/>
	* 每次减去后，新的 value 是小于当前 value 的 pageSize 的最接近倍数。value 的最小值是 pageSize。
	* @param increase 翻页操作是增加 (true) 还是减少 (false) value。
	*/
    public function changeValueByPage(increase : Bool = true) : Void
    {
        var val : Float;
        if (increase) 
            val = Math.min(value + pageSize, maximum)
        else 
        val = Math.max(value - pageSize, minimum);
        if (_smoothScrolling) 
        {
            startAnimation(_repeatInterval, val, linearEaser);
        }
        else 
        {
            setValue(val);
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    /**
	* 目标视域组件属性发生改变
	*/
    private function viewport_propertyChangeHandler(event : PropertyChangeEvent) : Void
    {
        var _sw2_ = (event.property);        

        switch (_sw2_)
        {
            case "contentWidth":
                viewportContentWidthChangeHandler(event);
            
            case "contentHeight":
                viewportContentHeightChangeHandler(event);
            
            case "horizontalScrollPosition":
                viewportHorizontalScrollPositionChangeHandler(event);
            
            case "verticalScrollPosition":
                viewportVerticalScrollPositionChangeHandler(event);
        }
    }
    
    /**
	* 目标视域组件尺寸发生改变
	*/
    private function viewportResizeHandler(event : ResizeEvent) : Void
    {
        
    }
    
    /**
	* 目标视域组件的内容宽度发生改变。
	*/
    private function viewportContentWidthChangeHandler(event : PropertyChangeEvent) : Void
    {
        
    }
    
    /**
	* 目标视域组件的内容高度发生改变。
	*/
    private function viewportContentHeightChangeHandler(event : PropertyChangeEvent) : Void
    {
        
    }
    
    /**
	* 目标视域组件的水平方向滚动条位置发生改变
	*/
    private function viewportHorizontalScrollPositionChangeHandler(event : PropertyChangeEvent) : Void
    {
        
    }
    
    /**
	* 目标视域组件的垂直方向滚动条位置发生改变
	*/
    private function viewportVerticalScrollPositionChangeHandler(event : PropertyChangeEvent) : Void
    {
        
    }
    
    /**
	* 鼠标在滑块按下事件
	*/
    override private function thumb_mouseDownHandler(event : MouseEvent) : Void
    {
        
        stopAnimation();
        
        super.thumb_mouseDownHandler(event);
    }
    
    /**
	* 鼠标在两端按钮上按住不放的事件
	*/
    private function button_buttonDownHandler(event : Event) : Void
    {
        if (!isStepping) 
            stopAnimation();
        var increment : Bool = (event.target == incrementButton);
        if (!isStepping &&
            ((increment && value < maximum) ||
            (!increment && value > minimum))) 
        {
            dispatchEvent(new UIEvent(UIEvent.CHANGE_START));
            isStepping = true;
            FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP,
                    button_buttonUpHandler, false, 0, true);
            FlexLiteGlobals.stage.addEventListener(
                    Event.MOUSE_LEAVE, button_buttonUpHandler, false, 0, true);
        }
        if (!steppingDown && !steppingUp) 
        {
            changeValueByStep(increment);
            if (_smoothScrolling &&
                ((increment && value < maximum) ||
                (!increment && value > minimum))) 
            {
                animateStepping((increment) ? maximum : minimum,
                        Math.max(pageSize / 10, stepSize));
            }
            return;
        }
    }
    
    /**
	* 鼠标在两端按钮上弹起的事件
	*/
    private function button_buttonUpHandler(event : Event) : Void
    {
        if (steppingDown || steppingUp) 
        {
            
            stopAnimation();
            
            dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
            
            steppingUp = steppingDown = false;
            isStepping = false;
        }
        else if (isStepping) 
        {
            
            dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
            isStepping = false;
        }
        
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP,
                button_buttonUpHandler);
        FlexLiteGlobals.stage.removeEventListener(
                Event.MOUSE_LEAVE, button_buttonUpHandler);
    }
    
    /**
	* @inheritDoc
	*/
    override private function track_mouseDownHandler(event : MouseEvent) : Void
    {
        if (!enabled) 
            return;
        stopAnimation();
        trackPosition = track.globalToLocal(new Point(event.stageX, event.stageY));
        if (event.shiftKey) 
        {
            var thumbW : Float = thumb != null ? thumb.layoutBoundsWidth : 0;
            var thumbH : Float = thumb != null ? thumb.layoutBoundsHeight : 0;
            trackPosition.x -= (thumbW / 2);
            trackPosition.y -= (thumbH / 2);
        }
        
        var newScrollValue : Float = pointToValue(trackPosition.x, trackPosition.y);
        trackScrollDown = (newScrollValue > value);
        
        if (event.shiftKey) 
        {
            var adjustedValue : Float = nearestValidValue(newScrollValue, snapInterval);
            if (_smoothScrolling &&
                slideDuration != 0 &&
                (maximum - minimum) != 0) 
            {
                dispatchEvent(new UIEvent(UIEvent.CHANGE_START));
                
                startAnimation(slideDuration *
                        (Math.abs(value - newScrollValue) / (maximum - minimum)),
                        adjustedValue, deceleratingSineEaser);
                animatingOnce = true;
            }
            else 
            {
                setValue(adjustedValue);
                dispatchEvent(new Event(Event.CHANGE));
            }
            return;
        }
        
        dispatchEvent(new UIEvent(UIEvent.CHANGE_START));
        
        animatingOnce = false;
        
        changeValueByPage(trackScrollDown);
        
        trackScrolling = true;
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_MOVE,
                track_mouseMoveHandler, false, 0, true);
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP,
                track_mouseUpHandler, false, 0, true);
        FlexLiteGlobals.stage.addEventListener(Event.MOUSE_LEAVE,
                track_mouseUpHandler, false, 0, true);
        if (trackScrollTimer == null) 
        {
            trackScrollTimer = new Timer(_repeatDelay, 1);
            trackScrollTimer.addEventListener(TimerEvent.TIMER,
                    trackScrollTimerHandler);
        }
        else 
        {
            trackScrollTimer.delay = _repeatDelay;
            trackScrollTimer.repeatCount = 1;
        }
        trackScrollTimer.start();
    }
    
    /**
	* 计算并播放翻页动画
	*/
    private function animatePaging(newValue : Float, pageSize : Float) : Void
    {
        animatingOnce = false;
        
        startAnimation(
                _repeatInterval * (Math.abs(newValue - value) / pageSize),
                newValue, linearEaser);
    }
    
    /**
	* 播放步进动画
	*/
    private function animateStepping(newValue : Float, stepSize : Float) : Void
    {
        steppingDown = (newValue > value);
        steppingUp = !steppingDown;
        var denominator : Float = ((stepSize != 0)) ? stepSize : 1;
        var duration : Float = _repeatInterval *
        (Math.abs(newValue - value) / denominator);
        
        var easer : IEaser;
        if (duration > 5000) 
            easer = new Linear(500 / duration)
        else 
        easer = easyInLinearEaser;
        startAnimation(duration, newValue, easer, _repeatDelay);
    }
    
    /**
	* 动画播放过程中触发的更新数值函数
	*/
    private function animationUpdateHandler(animation : Animation) : Void
    {
        setValue(animation.currentValue.value);
    }
    
    /**
	* 动画播放完成触发的函数
	*/
    private function animationEndHandler(animation : Animation) : Void
    {
        if (trackScrolling) 
            trackScrolling = false;
        if (steppingDown || steppingUp) 
        {
            changeValueByStep(steppingDown);
            
            animator.startDelay = 0;
            return;
        }
        setValue(nearestValidValue(this.value, snapInterval));
        dispatchEvent(new Event(Event.CHANGE));
        if (animatingOnce) 
        {
            dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
            animatingOnce = false;
        }
    }
    
    /**
	* 立即停止动画的播放
	*/
    private function stopAnimation() : Void
    {
        if (animator.isPlaying) 
            animationEndHandler(animator);
        animator.stop();
    }
    
    /**
	* 在轨道上按住shift并按下鼠标后，滑块滑动到按下点的计时器触发函数
	*/
    private function trackScrollTimerHandler(event : Event) : Void
    {
        var newScrollValue : Float = pointToValue(trackPosition.x, trackPosition.y);
        if (newScrollValue == value) 
            return;
        var fixedThumbSize : Bool = _fixedThumbSize != false;
        if (trackScrollDown) 
        {
            var range : Float = maximum - minimum;
            if (range == 0) 
                return;
            
            if ((value + pageSize) > newScrollValue &&
                (!fixedThumbSize || nearestValidValue(newScrollValue, pageSize) != maximum)) 
                return;
        }
        else if (newScrollValue > value) 
        {
            return;
        }
        
        if (_smoothScrolling) 
        {
            var valueDelta : Float = Math.abs(value - newScrollValue);
            var pages : Int;
            var pageToVal : Float;
            if (newScrollValue > value) 
            {
                pages = pageSize != (0) ? 
                        Std.int(valueDelta / pageSize) : 
                        Std.int(valueDelta);
                if (fixedThumbSize && nearestValidValue(newScrollValue, pageSize) == maximum) 
                    pageToVal = maximum
                else 
                pageToVal = value + (pages * pageSize);
            }
            else 
            {
                pages = pageSize != (0) ? 
                        Std.int(Math.ceil(valueDelta / pageSize)) : 
                        Std.int(valueDelta);
                pageToVal = Math.max(minimum, value - (pages * pageSize));
            }
            animatePaging(pageToVal, pageSize);
            return;
        }
        
        var oldValue : Float = value;
        
        changeValueByPage(trackScrollDown);
        
        if (trackScrollTimer != null && trackScrollTimer.repeatCount == 1) 
        {
            trackScrollTimer.delay = _repeatInterval;
            trackScrollTimer.repeatCount = 0;
        }
    }
    
    /**
	* 轨道上鼠标移动事件
	*/
    private function track_mouseMoveHandler(event : MouseEvent) : Void
    {
        if (trackScrolling) 
        {
            var pt : Point = new Point(event.stageX, event.stageY);
            
            trackPosition = track.globalToLocal(pt);
        }
    }
    
    /**
	* 轨道上鼠标弹起事件
	*/
    private function track_mouseUpHandler(event : Event) : Void
    {
        trackScrolling = false;
        
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_MOVE,
                track_mouseMoveHandler);
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP,
                track_mouseUpHandler);
        FlexLiteGlobals.stage.removeEventListener(Event.MOUSE_LEAVE,
                track_mouseUpHandler);
        if (_smoothScrolling) 
        {
            if (!animatingOnce) 
            {
                if (trackScrollTimer != null && trackScrollTimer.running) 
                {
                    if (animator.isPlaying) 
                        animatingOnce = true
                    else 
                    dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
                }
                else 
                {
                    stopAnimation();
                    dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
                }
            }
        }
        else 
        {
            dispatchEvent(new UIEvent(UIEvent.CHANGE_END));
        }
        
        if (trackScrollTimer != null) 
            trackScrollTimer.reset();
    }
    
    /**
	* 鼠标经过轨道触发函数
	*/
    private function track_rollOverHandler(event : MouseEvent) : Void
    {
        if (trackScrolling && trackScrollTimer != null) 
            trackScrollTimer.start();
    }
    
    /**
	* 鼠标移出轨道时触发的函数
	*/
    private function track_rollOutHandler(event : MouseEvent) : Void
    {
        if (trackScrolling && trackScrollTimer != null) 
            trackScrollTimer.stop();
    }
    
    /**
	* 鼠标经过两端按钮时触发函数
	*/
    private function button_rollOverHandler(event : MouseEvent) : Void
    {
        if (steppingUp || steppingDown) 
            animator.resume();
    }
    
    /**
	* 鼠标移出两端按钮是触发函数
	*/
    private function button_rollOutHandler(event : MouseEvent) : Void
    {
        if (steppingUp || steppingDown) 
            animator.pause();
    }
}

