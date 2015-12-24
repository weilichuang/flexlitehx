package flexlite.components.supportclasses;


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import flexlite.core.FlexLiteGlobals;

import flexlite.events.UIEvent;




/**
* 下拉框打开事件
*/
@:meta(Event(name="open",type="flexlite.events.UIEvent"))

/**
* 下来框关闭事件
*/
@:meta(Event(name="close",type="flexlite.events.UIEvent"))


@:meta(ExcludeClass())

/**
* 用于处理因用户交互而打开和关闭下拉列表的操作的控制器
* @author weilichuang
*/
class DropDownController extends EventDispatcher
{
    public var openButton(get, set) : ButtonBase;
    public var dropDown(get, set) : DisplayObject;
    public var isOpen(get, never) : Bool;
    public var closeOnResize(get, set) : Bool;
    public var rollOverOpenDelay(get, set) : Float;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    /**
	* 鼠标按下标志
	*/
    private var mouseIsDown : Bool;
    
    private var _openButton : ButtonBase;
    /**
	* 下拉按钮实例
	*/
    private function get_openButton() : ButtonBase
    {
        return _openButton;
    }
    private function set_openButton(value : ButtonBase) : ButtonBase
    {
        if (_openButton == value) 
            return value;
        removeOpenTriggers();
        _openButton = value;
        addOpenTriggers();
        return value;
    }
    /**
	* 要考虑作为下拉列表的点击区域的一部分的显示对象列表。
	* 在包含项列出的任何组件内进行鼠标单击不会自动关闭下拉列表。
	*/
    public var hitAreaAdditions : Array<DisplayObject>;
    
    private var _dropDown : DisplayObject;
    /**
	* 下拉区域显示对象
	*/
    private function get_dropDown() : DisplayObject
    {
        return _dropDown;
    }
    private function set_dropDown(value : DisplayObject) : DisplayObject
    {
        if (_dropDown == value) 
            return value;
        
        _dropDown = value;
        return value;
    }
    
    
    private var _isOpen : Bool = false;
    /**
	* 下拉列表已经打开的标志
	*/
    private function get_isOpen() : Bool
    {
        return _isOpen;
    }
    
    private var _closeOnResize : Bool = true;
    /**
	* 如果为 true，则在调整舞台大小时会关闭下拉列表。
	*/
    private function get_closeOnResize() : Bool
    {
        return _closeOnResize;
    }
    
    private function set_closeOnResize(value : Bool) : Bool
    {
        if (_closeOnResize == value) 
            return value;
        if (isOpen) 
            removeCloseOnResizeTrigger();
        
        _closeOnResize = value;
        
        addCloseOnResizeTrigger();
        return value;
    }
    
    private var _rollOverOpenDelay : Float = Math.NaN;
    
    private var rollOverOpenDelayTimer : Timer;
    /**
	* 指定滑过锚点按钮时打开下拉列表要等待的延迟（以毫秒为单位）。
	* 如果设置为 NaN，则下拉列表会在单击时打开，而不是在滑过时打开。默认值NaN
	*/
    private function get_rollOverOpenDelay() : Float
    {
        return _rollOverOpenDelay;
    }
    
    private function set_rollOverOpenDelay(value : Float) : Float
    {
        if (_rollOverOpenDelay == value) 
            return value;
        
        removeOpenTriggers();
        
        _rollOverOpenDelay = value;
        
        addOpenTriggers();
        return value;
    }
    /**
	* 添加触发下拉列表打开的事件监听
	*/
    private function addOpenTriggers() : Void
    {
        if (openButton != null) 
        {
            if (Math.isNaN(rollOverOpenDelay)) 
                openButton.addEventListener(UIEvent.BUTTON_DOWN, openButton_buttonDownHandler)
            else 
            openButton.addEventListener(MouseEvent.ROLL_OVER, openButton_rollOverHandler);
        }
    }
    /**
	* 移除触发下拉列表打开的事件监听
	*/
    private function removeOpenTriggers() : Void
    {
        if (openButton != null) 
        {
            if (Math.isNaN(rollOverOpenDelay)) 
                openButton.removeEventListener(UIEvent.BUTTON_DOWN, openButton_buttonDownHandler)
            else 
            openButton.removeEventListener(MouseEvent.ROLL_OVER, openButton_rollOverHandler);
        }
    }
    /**
	* 添加触发下拉列表关闭的事件监听
	*/
    private function addCloseTriggers() : Void
    {
        if (FlexLiteGlobals.stage != null) 
        {
            if (Math.isNaN(rollOverOpenDelay)) 
            {
                FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
                FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler_noRollOverOpenDelay);
            }
            else 
            {
                FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
            }
            
            addCloseOnResizeTrigger();
            
            if (openButton != null && openButton.stage != null) 
                FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheelHandler);
        }
    }
    
    /**
	* 移除触发下拉列表关闭的事件监听
	*/
    private function removeCloseTriggers() : Void
    {
        if (FlexLiteGlobals.stage != null) 
        {
            if (Math.isNaN(rollOverOpenDelay)) 
            {
                FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
                FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler_noRollOverOpenDelay);
            }
            else 
            {
                FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
                FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
                FlexLiteGlobals.stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
            }
            
            removeCloseOnResizeTrigger();
            
            if (openButton != null && openButton.stage != null) 
                FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheelHandler);
        }
    }
    /**
	* 添加舞台尺寸改变的事件监听
	*/
    private function addCloseOnResizeTrigger() : Void
    {
        if (closeOnResize) 
            FlexLiteGlobals.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 0, true);
    }
    /**
	* 移除舞台尺寸改变的事件监听
	*/
    private function removeCloseOnResizeTrigger() : Void
    {
        if (closeOnResize) 
            FlexLiteGlobals.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
    }
    /**
	* 检查鼠标是否在DropDown或者openButton区域内。
	*/
    private function isTargetOverDropDownOrOpenButton(target : DisplayObject) : Bool
    {
        if (target != null) 
        {
            
            if (openButton != null && openButton.contains(target)) 
                return true;
            if (hitAreaAdditions != null) 
            {
                for (i in 0...hitAreaAdditions.length){
                    if (hitAreaAdditions[i] == target ||
                        ((Std.is(hitAreaAdditions[i], DisplayObjectContainer)) && cast((hitAreaAdditions[i]), DisplayObjectContainer).contains(cast(target, DisplayObject)))) 
                        return true;
                }
            }
            if (Std.is(dropDown, DisplayObjectContainer)) 
            {
                if (cast((dropDown), DisplayObjectContainer).contains(target)) 
                    return true;
            }
            else 
            {
                if (target == dropDown) 
                    return true;
            }
        }
        
        return false;
    }
    /**
	* 打开下拉列表
	*/
    public function openDropDown() : Void
    {
        openDropDownHelper();
    }
    /**
	* 执行打开下拉列表
	*/
    private function openDropDownHelper() : Void
    {
        if (!isOpen) 
        {
            addCloseTriggers();
            
            _isOpen = true;
            
            if (openButton != null) 
                openButton.keepDown(true);
            
            dispatchEvent(new UIEvent(UIEvent.OPEN));
        }
    }
    /**
	* 关闭下拉列表
	*/
    public function closeDropDown(commit : Bool) : Void
    {
        if (isOpen) 
        {
            _isOpen = false;
            if (openButton != null) 
                openButton.keepDown(false);
            
            var dde : UIEvent = new UIEvent(UIEvent.CLOSE, false, true);
            
            if (!commit) 
                dde.preventDefault();
            
            dispatchEvent(dde);
            
            removeCloseTriggers();
        }
    }
    /**
	* openButton上按下鼠标事件
	*/
    private function openButton_buttonDownHandler(event : Event) : Void
    {
        if (isOpen) 
            closeDropDown(true)
        else 
        {
            mouseIsDown = true;
            openDropDownHelper();
        }
    }
    /**
	* openButton上鼠标经过事件
	*/
    private function openButton_rollOverHandler(event : MouseEvent) : Void
    {
        if (rollOverOpenDelay == 0) 
            openDropDownHelper()
        else 
        {
            openButton.addEventListener(MouseEvent.ROLL_OUT, openButton_rollOutHandler);
            rollOverOpenDelayTimer = new Timer(rollOverOpenDelay, 1);
            rollOverOpenDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, rollOverDelay_timerCompleteHandler);
            rollOverOpenDelayTimer.start();
        }
    }
    /**
	* openButton上鼠标移出事件
	*/
    private function openButton_rollOutHandler(event : MouseEvent) : Void
    {
        if (rollOverOpenDelayTimer != null && rollOverOpenDelayTimer.running) 
        {
            rollOverOpenDelayTimer.stop();
            rollOverOpenDelayTimer = null;
        }
        
        openButton.removeEventListener(MouseEvent.ROLL_OUT, openButton_rollOutHandler);
    }
    /**
	* 到达鼠标移入等待延迟打开的时间。
	*/
    private function rollOverDelay_timerCompleteHandler(event : TimerEvent) : Void
    {
        openButton.removeEventListener(MouseEvent.ROLL_OUT, openButton_rollOutHandler);
        rollOverOpenDelayTimer = null;
        
        openDropDownHelper();
    }
    /**
	* 舞台上鼠标按下事件
	*/
    private function stage_mouseDownHandler(event : Event) : Void
    {
        
        if (mouseIsDown) 
        {
            mouseIsDown = false;
            return;
        }
        
        if (dropDown == null ||
            (dropDown != null &&
            (event.target == dropDown || (Std.is(dropDown, DisplayObjectContainer) &&
            !cast((dropDown), DisplayObjectContainer).contains(cast((event.target), DisplayObject)))))) 
        {
            
            var target : DisplayObject = cast(event.target, DisplayObject);
            if (openButton != null && target != null && openButton.contains(target)) 
                return;
            
            if (hitAreaAdditions != null) 
            {
                for (i in 0...hitAreaAdditions.length){
                    if (hitAreaAdditions[i] == event.target ||
                        ((Std.is(hitAreaAdditions[i], DisplayObjectContainer)) && cast((hitAreaAdditions[i]), DisplayObjectContainer).contains(cast(event.target, DisplayObject)))) 
                        return;
                }
            }
            
            closeDropDown(true);
        }
    }
    /**
	* 舞台上鼠标移动事件
	*/
    private function stage_mouseMoveHandler(event : Event) : Void
    {
        var target : DisplayObject = cast(event.target, DisplayObject);
        var containedTarget : Bool = isTargetOverDropDownOrOpenButton(target);
        
        if (containedTarget) 
            return;
        if (Std.is(event, MouseEvent) && cast((event), MouseEvent).buttonDown) 
        {
            FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
            FlexLiteGlobals.stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
            return;
        }
        closeDropDown(true);
    }
    /**
	* 舞台上鼠标弹起事件
	*/
    private function stage_mouseUpHandler_noRollOverOpenDelay(event : Event) : Void
    {
        
        if (mouseIsDown) 
        {
            mouseIsDown = false;
            return;
        }
    }
    /**
	* 舞台上鼠标弹起事件
	*/
    private function stage_mouseUpHandler(event : Event) : Void
    {
        var target : DisplayObject = cast(event.target, DisplayObject);
        var containedTarget : Bool = isTargetOverDropDownOrOpenButton(target);
        if (containedTarget) 
        {
            FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
            FlexLiteGlobals.stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
            return;
        }
        
        closeDropDown(true);
    }
    /**
	* 舞台尺寸改变事件
	*/
    private function stage_resizeHandler(event : Event) : Void
    {
        closeDropDown(true);
    }
    /**
	* 舞台上鼠标滚轮事件
	*/
    private function stage_mouseWheelHandler(event : MouseEvent) : Void
    {
        
        if (dropDown != null && !(cast((dropDown), DisplayObjectContainer).contains(cast((event.target), DisplayObject)) && event.isDefaultPrevented())) 
            closeDropDown(false);
    }
}

