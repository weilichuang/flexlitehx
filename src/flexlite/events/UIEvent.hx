package flexlite.events;


import flash.events.Event;

/**
* UI事件
* @author weilichuang
*/
class UIEvent extends Event
{
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
    /**
	* 组件初始化开始 
	*/
    public static inline var INITIALIZE : String = "initialize";
    /**
	* 组件创建完成 
	*/
    public static inline var CREATION_COMPLETE : String = "creationComplete";
    /**
	* 组件的一次三个延迟验证渲染阶段全部完成 
	*/
    public static inline var UPDATE_COMPLETE : String = "updateComplete";
    /**
	* 当用户按下ButtonBase控件时分派。如果 autoRepeat属性为 true，则只要按钮处于按下状态，就将重复分派此事件。
	*/
    public static inline var BUTTON_DOWN : String = "buttonDown";
    /**
	* 改变结束
	*/
    public static inline var CHANGE_END : String = "changeEnd";
    
    /**
	* 改变开始
	*/
    public static inline var CHANGE_START : String = "changeStart";
    
    /**
	* 正在改变中
	*/
    public static inline var CHANGING : String = "changing";
    /**
	* 值发生改变
	*/
    public static inline var VALUE_COMMIT : String = "valueCommit";
    /**
	* 皮肤发生改变
	*/
    public static inline var SKIN_CHANGED : String = "skinChanged";
    
    /**
	* 下拉框弹出事件
	*/
    public static inline var OPEN : String = "open";
    /**
	* 下拉框关闭事件
	*/
    public static inline var CLOSE : String = "close";
    
    /**
	* UIMoveClip一次播放完成事件。仅当UIMovieClip.totalFrames>1时会抛出此事件。 
	*/
    public static inline var PLAY_COMPLETE : String = "playComplete";
}
