package flexlite.effects.animation;

import flexlite.effects.animation.MotionPath;

import flash.events.TimerEvent;
import flash.utils.Timer;


import flexlite.core.FlexLiteGlobals;
import flexlite.effects.easing.IEaser;
import flexlite.effects.easing.Sine;

using Reflect;

/**
* 数值缓动工具类
* @author weilichuang
*/
class Animation
{
    public var easer(get, set) : IEaser;
    public var isPlaying(get, never) : Bool;
    public var duration(get, set) : Float;
    public var startDelay(get, set) : Float;
    public var repeatBehavior(get, set) : String;
    public var repeatCount(get, set) : Int;
    public var repeatDelay(get, set) : Float;
    public var motionPaths(get, set) : Array<MotionPath>;
    public var currentValue(get, never) : Dynamic;
    public var isReverse(get, never) : Bool;
    public var isPaused(get, never) : Bool;
    public var started(get, never) : Bool;

    /**
	* 构造函数
	* @param updateFunction 动画更新时的回调函数,updateFunction(animation:Animation):void
	*/
    public function new(updateFunction : Animation->Void)
    {
        this.updateFunction = updateFunction;
    }
    
    private static var defaultEaser : IEaser = new Sine(.5);
    
    private var _easer : IEaser = defaultEaser;
    /**
	* 此效果的缓动行为。设置为null意味着不使用缓动，默认值为Sine(.5)
	*/
    private function get_easer() : IEaser
    {
        return _easer;
    }
    
    private function set_easer(value : IEaser) : IEaser
    {
        _easer = value;
        return value;
    }
    
    
    private var _isPlaying : Bool;
    /**
	* 是否正在播放动画，不包括延迟等待和暂停的阶段
	*/
    private function get_isPlaying() : Bool
    {
        return _isPlaying;
    }
    
    
    private var _duration : Float = 500;
    /**
	* 动画持续时间,单位毫秒，默认值500
	*/
    private function get_duration() : Float
    {
        return _duration;
    }
    
    private function set_duration(value : Float) : Float
    {
        _duration = value;
        return value;
    }
    
    private var _startDelay : Float = 0;
    
    /**
	* 动画开始播放前的延时时间,单位毫秒,默认0。
	*/
    private function get_startDelay() : Float
    {
        return _startDelay;
    }
    
    private function set_startDelay(value : Float) : Float
    {
        _startDelay = value;
        return value;
    }
    
    private var _repeatBehavior : String = RepeatBehavior.LOOP;
    /**
	* 设置重复动画的行为。
	* RepeatBehavior.LOOP表示始终重复正向播放动画。
	* RepeatBehavior.REVERSE表示正向和反向播放交替进行。
	*/
    private function get_repeatBehavior() : String
    {
        return _repeatBehavior;
    }
    
    private function set_repeatBehavior(value : String) : String
    {
        _repeatBehavior = value;
        return value;
    }
    
    
    private var _repeatCount : Int = 1;
    /**
	* 动画重复的次数，0代表无限制重复。默认值为1。
	*/
    private function get_repeatCount() : Int
    {
        return _repeatCount;
    }
    
    private function set_repeatCount(value : Int) : Int
    {
        _repeatCount = value;
        return value;
    }
    
    private var _repeatDelay : Float = 0;
    /**
	* 每次重复播放之间的间隔。第二次及以后的播放开始之前的延迟毫秒数。若要设置第一次之前的延迟时间，请使用startDelay属性。
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
    
    
    
    private var _motionPaths : Array<MotionPath>;
    /**
	* 随着时间的推移Animation将设置动画的属性和值的列表。
	*/
    private function get_motionPaths() : Array<MotionPath>
    {
        if (_motionPaths == null) 
            _motionPaths = new Array<MotionPath>();
        return _motionPaths;
    }
    
    private function set_motionPaths(value : Array<MotionPath>) : Array<MotionPath>
    {
        _motionPaths = value;
        return value;
    }
    
    private var _currentValue : Dynamic = { };
    
    /**
	* 动画到当前时间对应的值。以MotionPath.property为键存储各个MotionPath的当前值。
	*/
    private function get_currentValue() : Dynamic
    {
        return _currentValue;
    }
    
    /**
	* 动画开始播放时的回调函数,只会在首次延迟等待结束时触发一次,若有重复播放，之后将触发repeatFunction。startFunction(animation:Animation):void
	*/
    public var startFunction : Animation->Void;
    /**
	* 动画播放结束时的回调函数,可以是正常播放结束，也可以是被调用了end()方法导致结束。注意：stop()方法被调用不会触发这个函数。endFunction(animation:Animation):void
	*/
    public var endFunction : Animation->Void;
    
    /**
	* 动画更新时的回调函数,updateFunction(animation:Animation):void
	*/
    public var updateFunction : Animation->Void;
    
    /**
	* 动画开始一次新的重复播放时的回调函数，repeatFunction(animation:Animation):void
	*/
    public var repeatFunction : Animation->Void;
    
    /**
	* 动画被停止的回调函数，即stop()方法被调用。stopFunction(animation:Animation):void
	*/
    public var stopFunction : Animation->Void;
    
    /**
	* 开始正向播放动画,无论何时调用都重新从零时刻开始，若设置了延迟会首先进行等待。
	*/
    public function play() : Void
    {
        stopAnimation();
        _isReverse = false;
        start();
    }
    
    private var _isReverse : Bool = false;
    /**
	* 正在反向播放。
	*/
    private function get_isReverse() : Bool
    {
        return _isReverse;
    }
    
    /**
	* 仅当动画已经在播放中时有效，从当前位置开始沿motionPaths定义的路径反向播放。
	*/
    public function reverse() : Void
    {
        if (_isReverse || !_isPlaying) 
            return;
        _isReverse = true;
        var runningTime : Float = currentTime - startTime - _startDelay;
        runningTime = Math.min(runningTime, duration);
        seek(duration - runningTime);
    }
    
    /**
	* 立即跳到指定百分比的动画位置
	*/
    private function seek(runningTime : Float) : Void
    {
        runningTime = Math.min(runningTime, duration);
        var fraction : Float = runningTime / duration;
        caculateCurrentValue(fraction);
        startTime = Math.round(haxe.Timer.stamp() * 1000) - runningTime - _startDelay;
        if (updateFunction != null) 
            updateFunction(this);
    }
    
    /**
	* 开始播放动画
	*/
    private function start() : Void
    {
        playedTimes = 0;
        _started = true;
        _isPlaying = false;
        _currentValue = { };
        caculateCurrentValue(0);
        startTime = Math.round(haxe.Timer.stamp() * 1000);
        currentTime = Math.round(haxe.Timer.stamp() * 1000);
        doInterval();
        addAnimation(this);
    }
    
    /**
	* 直接跳到动画结尾
	*/
    public function end() : Void
    {
        if (!_started) 
        {
            caculateCurrentValue(0);
            if (startFunction != null) 
            {
                startFunction(this);
            }
            if (updateFunction != null) 
            {
                updateFunction(this);
            }
        }
        caculateCurrentValue(1);
        if (updateFunction != null) 
        {
            updateFunction(this);
        }
        stopAnimation();
        if (endFunction != null) 
        {
            endFunction(this);
        }
    }
    
    /**
	* 停止播放动画
	*/
    public function stop() : Void
    {
        stopAnimation();
        if (stopFunction != null) 
            stopFunction(this);
    }
    /**
	* 仅停止播放动画，而不调用stopFunction。
	*/
    private function stopAnimation() : Void
    {
        playedTimes = 0;
        _isPlaying = false;
        startTime = 0;
        _started = false;
        removeAnimation(this);
    }
    
    private var pauseTime : Float = 0;
    
    private var _isPaused : Bool = false;
    /**
	* 正在暂停中
	*/
    private function get_isPaused() : Bool
    {
        return _isPaused;
    }
    
    
    
    /**
	* 暂停播放
	*/
    public function pause() : Void
    {
        if (!_started) 
            return;
        _isPaused = true;
        pauseTime = Math.round(haxe.Timer.stamp() * 1000);
        _isPlaying = false;
        removeAnimation(this);
    }
    /**
	* 继续播放
	*/
    public function resume() : Void
    {
        if (!_started || !_isPaused) 
            return;
        _isPaused = false;
        startTime += Math.round(haxe.Timer.stamp() * 1000) - pauseTime;
        pauseTime = -1;
        addAnimation(this);
    }
    
    /**
	* 动画启动时刻
	*/
    private var startTime : Float = 0;
    
    private var _started : Bool = false;
    
    /**
	* 动画已经开始的标志，包括延迟等待和暂停的阶段。
	*/
    private function get_started() : Bool
    {
        return _started;
    }
    
    
    /**
	* 已经播放的次数。
	*/
    private var playedTimes : Int = 0;
    /**
	* 计算当前值并返回动画是否结束
	*/
    private function doInterval() : Bool
    {
        var delay : Float = playedTimes > (0) ? _repeatDelay : _startDelay;
        var runningTime : Float = currentTime - startTime - delay;
        if (runningTime < 0) 
        {
            return false;
        }
        if (!_isPlaying) 
        {
            _isPlaying = true;
            if (playedTimes == 0) 
            {
                if (startFunction != null) 
                    startFunction(this);
            }
            else 
            {
                if (repeatFunction != null) 
                    repeatFunction(this);
            }
        }
        var fraction : Float = _duration == (0) ? 1 : Math.min(runningTime, _duration) / _duration;
        caculateCurrentValue(fraction);
        if (updateFunction != null) 
            updateFunction(this);
        var isEnded : Bool = runningTime >= _duration;
        if (isEnded) 
        {
            playedTimes++;
            _isPlaying = false;
            startTime = currentTime;
            if (_repeatCount == 0 || playedTimes < _repeatCount) 
            {
                if (_repeatBehavior == "reverse") 
                {
                    _isReverse = !_isReverse;
                }
                isEnded = false;
            }
            else 
            {
                removeAnimation(this);
                _started = false;
                playedTimes = 0;
            }
        }
        if (isEnded && endFunction != null) 
        {
            endFunction(this);
        }
        return isEnded;
    }
    /**
	* 计算当前值
	*/
    private function caculateCurrentValue(fraction : Float) : Void
    {
        if (_isReverse) 
        {
            fraction = 1 - fraction;
        }
        var finalFraction : Float = fraction;
        if (easer != null) 
            finalFraction = easer.ease(fraction);
			
        for (motionPath in motionPaths)
        {
			currentValue.setProperty(motionPath.property, motionPath.valueFrom + (motionPath.valueTo - motionPath.valueFrom) * finalFraction);
        }
    }
    
    /**
	* 总时间轴的当前时间
	*/
    private static var currentTime : Float = 0;
    
    
    private static var TIMER_RESOLUTION : Float = 1000 / 60;  // 60 fps  
    
    private static var timer : Timer;
    
    /**
	* 正在活动的动画
	*/
    private static var activeAnimations : Array<Animation> = new Array<Animation>();
    
    /**
	* 添加动画到队列
	*/
    private static function addAnimation(animation : Animation) : Void
    {
        if (activeAnimations.indexOf(animation) == -1) 
        {
            activeAnimations.push(animation);
            if (timer == null) 
            {
                timer = new Timer(TIMER_RESOLUTION);
                timer.addEventListener(TimerEvent.TIMER, timerHandler);
            }
            if (!timer.running) 
                timer.start();
        }
    }
    
    /**
	* 从队列移除动画,返回移除前的索引
	*/
    private static function removeAnimation(animation : Animation) : Void
    {
        var index : Int = activeAnimations.indexOf(animation);
        if (index != -1) 
        {
            activeAnimations.splice(index, 1);
            if (index <= currentIntervalIndex) 
                currentIntervalIndex--;
        }
        if (activeAnimations.length == 0 && timer != null && timer.running) 
        {
            timer.stop();
        }
    }
    
    /**
	* 当前正在执行动画的索引
	*/
    private static var currentIntervalIndex : Int = -1;
    
    /**
	* 计时器触发函数
	*/
    private static function timerHandler(event : TimerEvent) : Void
    {
        currentTime = Math.round(haxe.Timer.stamp() * 1000);
        currentIntervalIndex = 0;
        while (currentIntervalIndex < activeAnimations.length)
        {
            var animation : Animation = activeAnimations[currentIntervalIndex];
            var isEnded : Bool = animation.doInterval();
            currentIntervalIndex++;
        }
        currentIntervalIndex = -1;
        if (activeAnimations.length == 0 && timer.running) 
        {
            timer.stop();
        }
        if (FlexLiteGlobals.useUpdateAfterEvent) 
            event.updateAfterEvent();
    }
}
