package flexlite.utils;

import flash.display.Shape;
import flash.events.Event;
import flash.events.UncaughtErrorEvent;
import haxe.CallStack;

import flexlite.core.FlexLiteGlobals;



/**
 * Class for callLater
 */
@:final class ClassForCallLater
{
    /**
* 延迟函数到屏幕重绘前执行。
* @param method 要延迟执行的函数
* @param args 函数参数列表
* @param delayFrames 延迟的帧数，0表示在当前帧的屏幕重绘前(Render事件)执行；
* 1表示下一帧EnterFrame事件时执行,2表示两帧后的EnterFrame事件时执行，以此类推。默认值0。
*/
    public static function callLater(method : Dynamic, args : Array<Dynamic> = null, delayFrames : Int = 0) : Void
    {
        DelayCall.getInstance().callLater(method, args, delayFrames);
    }
}


/**
 * 延迟执行函数管理类
 * @author weilichuang
 */
class DelayCall extends Shape
{
    
    private static var _instance : DelayCall;
    /**
	* 获取单例
	*/
    public static function getInstance() : DelayCall
    {
        if (_instance == null) 
            _instance = new DelayCall();
        return _instance;
    }
	
    /**
	* 延迟函数队列 
	*/
    private var methodQueue : Array<MethodQueueElement> = new Array<MethodQueueElement>();
    /**
	* 是否添加过EnterFrame事件监听标志 
	*/
    private var listenForEnterFrame : Bool = false;
    /**
	* 是否添加过Render事件监听标志 
	*/
    private var listenForRender : Bool = false;
    
    /**
	* 延迟函数到屏幕重绘前执行。
	* @param method 要延迟执行的函数
	* @param args 函数参数列表
	* @param delayFrames 延迟的帧数，0表示在当前帧的屏幕重绘前(Render事件)执行；
	* 1表示下一帧EnterFrame事件时执行,2表示两帧后的EnterFrame事件时执行，以此类推。默认值0。
	*/
    public function callLater(method : Dynamic, args : Array<Dynamic> = null, delayFrames : Int = 0) : Void
    {
        var element : MethodQueueElement = 
        new MethodQueueElement(method, args, delayFrames, delayFrames == 0);
        methodQueue.push(element);
        if (!listenForEnterFrame) 
        {
            addEventListener(Event.ENTER_FRAME, onCallBack);
            listenForEnterFrame = true;
        }
        if (element.onRender) 
        {
            if (!listenForRender && FlexLiteGlobals.stage != null) 
            {
                FlexLiteGlobals.stage.addEventListener(Event.RENDER, onCallBack, false, -1000);
                FlexLiteGlobals.stage.invalidate();
                listenForRender = true;
            }
        }
    }
    /**
	* 执行延迟函数
	*/
    private function onCallBack(event : Event) : Void
    {
        if (FlexLiteGlobals.catchCallLaterExceptions) 
        {
            try
            {
                doCallBackFunction(event);
            }            
			catch (e : String)
            {
                if (FlexLiteGlobals.stage != null) 
                {
                    var errorEvent : UncaughtErrorEvent = new UncaughtErrorEvent("callLaterError", false, true, CallStack.exceptionStack());
                    FlexLiteGlobals.stage.dispatchEvent(errorEvent);
                }
            }
        }
        else 
        {
            doCallBackFunction(event);
        }
    }
    
    private function doCallBackFunction(event : Event) : Void
    {
        var element : MethodQueueElement;
        var onRender : Bool = event.type == Event.RENDER;
        var startIndex : Int = methodQueue.length - 1;
        var i : Int = startIndex;
        while (i >= 0)
		{
            element = methodQueue[i];
            if (onRender && !element.onRender) 
            {
				i--;
				continue;
            }
            if (!element.onRender) 
                element.delayFrames--;
				
            if (element.delayFrames > 0) 
            {
				i--;
				continue;
            }
            methodQueue.splice(i, 1);
            startIndex--;
            if (element.args == null) 
            {
				Reflect.callMethod(null, element.method, []);
            }
            else 
            {
				Reflect.callMethod(null, element.method, element.args);
            }
            i--;
        }
        var length : Int = methodQueue.length;
        var hasOnRender : Bool = false;
        startIndex = MathUtil.maxInt(0, startIndex);
        for (i in startIndex...length)
		{
            if (methodQueue[i].onRender) 
            {
                hasOnRender = true;
                break;
            }
        }
        if (!hasOnRender && listenForRender) 
        {
            FlexLiteGlobals.stage.removeEventListener(Event.RENDER, onCallBack);
            listenForRender = false;
        }
        if (methodQueue.length == 0) 
        {
            if (listenForEnterFrame) 
            {
                removeEventListener(Event.ENTER_FRAME, onCallBack);
                listenForEnterFrame = false;
            }
        }
    }

    public function new()
    {
        super();
    }
}

/**
 *  延迟执行函数元素
 */
class MethodQueueElement
{
    
    public function new(method : Dynamic, args : Array<Dynamic> = null, delayFrames : Int = 0, onRender : Bool = true)
    {
        this.method = method;
        this.args = args;
        this.delayFrames = delayFrames;
        this.onRender = onRender;
    }
    
    public var method : Dynamic;
    
    public var args : Array<Dynamic>;
    
    public var delayFrames : Int;
    /**
	* 在render事件触发
	*/
    public var onRender : Bool;
}