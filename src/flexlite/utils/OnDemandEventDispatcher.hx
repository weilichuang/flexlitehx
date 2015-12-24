package flexlite.utils;


import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

/**
* 对于分派事件但期望侦听器不常用的类，OnDemandEventDispatcher 用作其基类。
* 只有在附加了监听器时才会初始化一个EventDispatcher实例，而不是每次都实例化一个。
* @author weilichuang
*/
class OnDemandEventDispatcher implements IEventDispatcher
{
    private var _dispatcher : EventDispatcher;
    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    /**
	* @inheritDoc
	*/
    public function addEventListener(type : String, listener : Dynamic->Void, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        if (_dispatcher == null) 
        {
            _dispatcher = new EventDispatcher(this);
        }
        _dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    /**
	* @inheritDoc
	*/
    public function dispatchEvent(event : Event) : Bool
    {
        if (_dispatcher != null) 
            return _dispatcher.dispatchEvent(event);
        return true;
    }
    /**
	* @inheritDoc
	*/
    public function hasEventListener(type : String) : Bool
    {
        if (_dispatcher != null) 
            return _dispatcher.hasEventListener(type);
        return false;
    }
    /**
	* @inheritDoc
	*/
    public function removeEventListener(type : String, listener : Dynamic->Void, useCapture : Bool = false) : Void
    {
        if (_dispatcher != null) 
            _dispatcher.removeEventListener(type, listener, useCapture);
    }
    /**
	* @inheritDoc
	*/
    public function willTrigger(type : String) : Bool
    {
        if (_dispatcher != null) 
            return _dispatcher.willTrigger(type);
        return false;
    }
}
