package flexlite.events;


import flash.events.Event;

/**
* 动画特效事件
* @author weilichuang
*/
class EffectEvent extends Event
{
    /**
	* 动画播放结束
	*/
    public static inline var EFFECT_END : String = "effectEnd";
    /**
	* 动画播放被停止
	*/
    public static inline var EFFECT_STOP : String = "effectStop";
    /**
	* 动画播放开始
	*/
    public static inline var EFFECT_START : String = "effectStart";
    /**
	* 动画开始重复播放
	*/
    public static inline var EFFECT_REPEAT : String = "effectRepeat";
    /**
	* 动画播放更新
	*/
    public static inline var EFFECT_UPDATE : String = "effectUpdate";
    
    /**
	* 构造函数
	*/
    public function new(eventType : String, bubbles : Bool = false,
            cancelable : Bool = false)
    {
        super(eventType, bubbles, cancelable);
    }
    
    /**
	* @inheritDoc
	*/
    override public function clone() : Event
    {
        return new EffectEvent(type, bubbles, cancelable);
    }
}


