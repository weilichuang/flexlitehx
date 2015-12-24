package flexlite.effects.supportclasses;


import flash.events.EventDispatcher;


import flexlite.core.IEffect;
import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.effects.easing.IEaser;
import flexlite.events.EffectEvent;



/**
* 在动画完成播放时（既可以是正常完成播放时，也可以是通过调用end()或stop()方法提前结束播放时）分派。
*/
@:meta(Event(name="effectEnd",type="flexlite.events.EffectEvent"))

/**
* 在动画被停止播放时分派，即当该动画的stop()方法被调用时。还将分派 EFFECT_END事件以指示已结束该动画。将首先发送此EFFECT_STOP事件，作为对动画未正常播放完的指示。
*/
@:meta(Event(name="effectStop",type="flexlite.events.EffectEvent"))

/**
* 当动画开始播放时分派。
*/
@:meta(Event(name="effectStart",type="flexlite.events.EffectEvent"))

/**
* 对于任何重复次数超过一次的动画，当动画开始新的一次重复时分派。
*/
@:meta(Event(name="effectRepeat",type="flexlite.events.EffectEvent"))



/**
* 动画特效基类
* @author weilichuang
*/
class Effect extends EventDispatcher implements IEffect
{
    public var target(get, set) : Dynamic;
    public var targets(get, set) : Array<Dynamic>;
    public var easer(get, set) : IEaser;
    public var isPlaying(get, never) : Bool;
    public var started(get, never) : Bool;
    public var duration(get, set) : Float;
    public var startDelay(get, set) : Float;
    public var repeatBehavior(get, set) : String;
    public var repeatCount(get, set) : Int;
    public var repeatDelay(get, set) : Float;
    public var isReverse(get, never) : Bool;
    public var isPaused(get, never) : Bool;

    /**
	* 构造函数
	* @param target 要应用此动画特效的对象
	*/
    public function new(target : Dynamic = null)
    {
        super();
        animator = new Animation(animationUpdateHandler);
        animator.startFunction = animationStartHandler;
        animator.endFunction = animationEndHandler;
        animator.repeatFunction = animationRepeatHandler;
        animator.stopFunction = animationStopHandler;
        if (target != null) 
        {
            this.target = target;
        }
    }
    
    /**
	* 要应用此动画特效的对象。若要将特效同时应用到多个对象，请使用targets属性。
	*/
    private function get_target() : Dynamic
    {
        if (_targets.length > 0) 
            return _targets[0]
        else 
			return null;
    }
    /**
	* @inheritDoc
	*/
    private function set_target(value : Dynamic) : Dynamic
    {
        _targets.splice(0,_targets.length);
        
        if (value != null) 
            _targets[0] = value;
        return value;
    }
    
    private var _targets : Array<Dynamic> = [];
    
    /**
	* @inheritDoc
	*/
    private function get_targets() : Array<Dynamic>
    {
        return _targets;
    }
    
    private function set_targets(value : Array<Dynamic>) : Array<Dynamic>
    {
        var n : Int = value.length;
        var i : Int = n - 1;
        while (i >= 0)
		{
            if (value[i] == null) 
                value.splice(i, 1);
            i--;
        }
        _targets = value;
        return value;
    }
    
    /**
	* 动画类实例
	*/
    private var animator : Animation;
    /**
	* 动画播放更新
	*/
    private function animationUpdateHandler(animation : Animation) : Void
    {
        
        
    }
    /**
	* 动画播放开始,只会触发一次，若有重复，之后触发animationRepeatHandler()
	*/
    private function animationStartHandler(animation : Animation) : Void
    {
        var event : EffectEvent = new EffectEvent(EffectEvent.EFFECT_START);
        dispatchEvent(event);
    }
    /**
	* 动画播放结束
	*/
    private function animationEndHandler(animation : Animation) : Void
    {
        var event : EffectEvent = new EffectEvent(EffectEvent.EFFECT_END);
        dispatchEvent(event);
    }
    /**
	* 动画播放开始一次新的重复
	*/
    private function animationRepeatHandler(animation : Animation) : Void
    {
        var event : EffectEvent = new EffectEvent(EffectEvent.EFFECT_REPEAT);
        dispatchEvent(event);
    }
    /**
	* 动画被停止
	*/
    private function animationStopHandler(animation : Animation) : Void
    {
        var event : EffectEvent = new EffectEvent(EffectEvent.EFFECT_STOP);
        dispatchEvent(event);
    }
    
    /**
	* @inheritDoc
	*/
    private function get_easer() : IEaser
    {
        return animator.easer;
    }
    
    private function set_easer(value : IEaser) : IEaser
    {
        animator.easer = value;
        return value;
    }
    
    
    /**
	* @inheritDoc
	*/
    private function get_isPlaying() : Bool
    {
        return animator.isPlaying;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_started() : Bool
    {
        return animator.started;
    }
    
    
    /**
	* @inheritDoc
	*/
    private function get_duration() : Float
    {
        return animator.duration;
    }
    
    private function set_duration(value : Float) : Float
    {
        animator.duration = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_startDelay() : Float
    {
        return animator.startDelay;
    }
    
    private function set_startDelay(value : Float) : Float
    {
        animator.startDelay = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_repeatBehavior() : String
    {
        return animator.repeatBehavior;
    }
    
    private function set_repeatBehavior(value : String) : String
    {
        animator.repeatBehavior = value;
        return value;
    }
    
    
    /**
	* @inheritDoc
	*/
    private function get_repeatCount() : Int
    {
        return animator.repeatCount;
    }
    
    private function set_repeatCount(value : Int) : Int
    {
        animator.repeatCount = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_repeatDelay() : Float
    {
        return animator.repeatDelay;
    }
    
    private function set_repeatDelay(value : Float) : Float
    {
        animator.repeatDelay = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    public function play(targets : Array<Dynamic> = null) : Void
    {
        if (targets != null) 
        {
            this.targets = targets;
        }
        if (this.targets == null) 
            return;
        animator.motionPaths = createMotionPath();
        animator.play();
    }
    
    /**
	* 创建motionPath对象列表
	*/
    private function createMotionPath() : Array<MotionPath>
    {
        return [];
    }
    
    /**
	* @inheritDoc
	*/
    private function get_isReverse() : Bool
    {
        return animator.isReverse;
    }
    
    
    /**
	* @inheritDoc
	*/
    public function reverse() : Void
    {
        if (this.targets == null) 
            return;
        animator.reverse();
    }
    /**
	* @inheritDoc
	*/
    public function end() : Void
    {
        animator.end();
    }
    
    /**
	* @inheritDoc
	*/
    public function stop() : Void
    {
        animator.stop();
        var event : EffectEvent = new EffectEvent(EffectEvent.EFFECT_END);
        dispatchEvent(event);
    }
    
    /**
	* @inheritDoc
	*/
    private function get_isPaused() : Bool
    {
        return animator.isPaused;
    }
    
    /**
	* @inheritDoc
	*/
    public function pause() : Void
    {
        animator.pause();
    }
    /**
	* @inheritDoc
	*/
    public function resume() : Void
    {
        animator.resume();
    }
    /**
	* @inheritDoc
	*/
    public function reset() : Void
    {
        animator.stop();
        _targets = [];
    }
}
