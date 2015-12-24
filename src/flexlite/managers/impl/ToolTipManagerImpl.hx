package flexlite.managers.impl;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.utils.Timer;



import flexlite.components.ToolTip;
import flexlite.core.FlexLiteGlobals;
import flexlite.core.IContainer;
import flexlite.core.IInvalidating;
import flexlite.core.IToolTip;
import flexlite.core.IUIComponent;
import flexlite.core.IVisualElementContainer;
import flexlite.core.PopUpPosition;
import flexlite.events.ToolTipEvent;
import flexlite.managers.ILayoutManagerClient;
import flexlite.managers.ISystemManager;
import flexlite.managers.IToolTipManager;
import flexlite.managers.IToolTipManagerClient;
import flexlite.utils.SharedMap;



//@:meta(ExcludeClass())


/**
* 工具提示管理器实现类
* @author weilichuang
*/
class ToolTipManagerImpl implements IToolTipManager
{
    public var currentTarget(get, set) : IToolTipManagerClient;
    public var currentToolTip(get, set) : IToolTip;
    public var enabled(get, set) : Bool;
    public var hideDelay(get, set) : Float;
    public var scrubDelay(get, set) : Float;
    public var showDelay(get, set) : Float;
    public var toolTipClass(get, set) : Class<IToolTip>;
    private var toolTipContainer(get, never) : IContainer;

    /**
	* 构造函数
	*/
    public function new()
    {
    }
    /**
	* 初始化完成的标志
	*/
    private var initialized : Bool = false;
    /**
	* 用于鼠标经过一个对象后计时一段时间开始显示ToolTip
	*/
    private var showTimer : Timer;
    /**
	* 用于ToolTip显示后计时一段时间自动隐藏。
	*/
    private var hideTimer : Timer;
    /**
	* 用于当已经显示了一个ToolTip，鼠标快速经过多个显示对象时立即切换显示ToolTip。
	*/
    private var scrubTimer : Timer;
    /**
	* 当前的toolTipData
	*/
    private var currentTipData : Dynamic;
    /**
	* 上一个ToolTip显示对象
	*/
    private var previousTarget : IToolTipManagerClient;
    
    private var _currentTarget : IToolTipManagerClient;
    /**
	* 当前的IToolTipManagerClient组件
	*/
    private function get_currentTarget() : IToolTipManagerClient
    {
        return _currentTarget;
    }
    
    private function set_currentTarget(value : IToolTipManagerClient) : IToolTipManagerClient
    {
        _currentTarget = value;
        return value;
    }
    
    private var _currentToolTip : DisplayObject;
    /**
	* 当前的ToolTip显示对象；如果未显示ToolTip，则为 null。
	*/
    private function get_currentToolTip() : IToolTip
    {
        return Lib.as(_currentToolTip, IToolTip);
    }
    
    private function set_currentToolTip(value : IToolTip) : IToolTip
    {
        _currentToolTip = cast(value, DisplayObject);
        return value;
    }
    
    private var _enabled : Bool = true;
    /**
	* 如果为 true，则当用户将鼠标指针移至组件上方时，ToolTipManager 会自动显示工具提示。
	* 如果为 false，则不会显示任何工具提示。
	*/
    private function get_enabled() : Bool
    {
        return _enabled;
    }
    
    private function set_enabled(value : Bool) : Bool
    {
        if (_enabled == value) 
            return value;
        _enabled = value;
        if (!_enabled && currentTarget != null) 
        {
            currentTarget = null;
            targetChanged();
            previousTarget = currentTarget;
        }
        return value;
    }
    
    private var _hideDelay : Float = 10000;
    /**
	* 自工具提示出现时起，ToolTipManager要隐藏此提示前所需等待的时间量（以毫秒为单位）。默认值：10000。
	*/
    private function get_hideDelay() : Float
    {
        return _hideDelay;
    }
    
    private function set_hideDelay(value : Float) : Float
    {
        _hideDelay = value;
        return value;
    }
    
    private var _scrubDelay : Float = 100;
    /**
	* 当第一个ToolTip显示完毕后，若在此时间间隔内快速移动到下一个组件上，就直接显示ToolTip而不延迟一段时间。默认值：100。
	*/
    private function get_scrubDelay() : Float
    {
        return _scrubDelay;
    }
    
    private function set_scrubDelay(value : Float) : Float
    {
        _scrubDelay = value;
        return value;
    }
    
    private var _showDelay : Float = 200;
    /**
	* 当用户将鼠标移至具有工具提示的组件上方时，等待 ToolTip框出现所需的时间（以毫秒为单位）。
	* 若要立即显示ToolTip框，请将toolTipShowDelay设为0。默认值：200。
	*/
    private function get_showDelay() : Float
    {
        return _showDelay;
    }
    private function set_showDelay(value : Float) : Float
    {
        _showDelay = value;
        return value;
    }
    
    private var _toolTipClass : Class<IToolTip> = ToolTip;
    /**
	* 全局默认的创建工具提示要用到的类。
	*/
    private function get_toolTipClass() : Class<IToolTip>
    {
        return _toolTipClass;
    }
    
    private function set_toolTipClass(value : Class<IToolTip>) : Class<IToolTip>
    {
        _toolTipClass = value;
        return value;
    }
    /**
	* 初始化
	*/
    private function initialize() : Void
    {
        if (showTimer == null) 
        {
            showTimer = new Timer(0, 1);
            showTimer.addEventListener(TimerEvent.TIMER,
                    showTimer_timerHandler);
        }
        
        if (hideTimer == null) 
        {
            hideTimer = new Timer(0, 1);
            hideTimer.addEventListener(TimerEvent.TIMER,
                    hideTimer_timerHandler);
        }
        
        if (scrubTimer == null) 
            scrubTimer = new Timer(0, 1);
        
        initialized = true;
    }
    /**
	* 注册需要显示ToolTip的组件
	* @param target 目标组件
	* @param oldToolTip 之前的ToolTip数据
	* @param newToolTip 现在的ToolTip数据
	*/
    public function registerToolTip(target : DisplayObject,
            oldToolTip : Dynamic,
            newToolTip : Dynamic) : Void
    {
        var hasOld : Bool = oldToolTip != null && oldToolTip != "";
        var hasNew : Bool = newToolTip != null && newToolTip != "";
        if (!hasOld && hasNew) 
        {
            target.addEventListener(MouseEvent.MOUSE_OVER,
                    toolTipMouseOverHandler);
            target.addEventListener(MouseEvent.MOUSE_OUT,
                    toolTipMouseOutHandler);
            if (mouseIsOver(target)) 
                showImmediately(target);
        }
        else if (hasOld && !hasNew) 
        {
            target.removeEventListener(MouseEvent.MOUSE_OVER,
                    toolTipMouseOverHandler);
            target.removeEventListener(MouseEvent.MOUSE_OUT,
                    toolTipMouseOutHandler);
            if (mouseIsOver(target)) 
                hideImmediately(target);
        }
        else if (hasNew && currentToolTip != null && 
				(Std.is(target,IToolTipManagerClient) && currentTarget == Lib.as(target,IToolTipManagerClient))) 
        {
            currentTipData = newToolTip;
            initializeTip();
        }
    }
    /**
	* 检测鼠标是否处于目标对象上
	*/
    private function mouseIsOver(target : DisplayObject) : Bool
    {
        if (target == null || target.stage == null) 
            return false;
        if ((target.stage.mouseX == 0) && (target.stage.mouseY == 0)) 
            return false;
        
        if (Std.is(target, ILayoutManagerClient) && !Lib.as((target), ILayoutManagerClient).initialized) 
            return false;
        
        return target.hitTestPoint(target.stage.mouseX,
                target.stage.mouseY, true);
    }
    /**
	* 立即显示ToolTip标志
	*/
    private var showImmediatelyFlag : Bool = false;
    /**
	* 立即显示目标组件的ToolTip
	*/
    private function showImmediately(target : DisplayObject) : Void
    {
        showImmediatelyFlag = true;
        checkIfTargetChanged(target);
        showImmediatelyFlag = false;
    }
    /**
	* 立即隐藏目标组件的ToolTip
	*/
    private function hideImmediately(target : DisplayObject) : Void
    {
        checkIfTargetChanged(null);
    }
    /**
	* 检查当前的鼠标下的IToolTipManagerClient组件是否发生改变
	*/
    private function checkIfTargetChanged(displayObject : DisplayObject) : Void
    {
        if (!enabled) 
            return;
        
        findTarget(displayObject);
        
        if (currentTarget != previousTarget) 
        {
            targetChanged();
            previousTarget = currentTarget;
        }
    }
    /**
	* 向上遍历查询，直到找到第一个当前鼠标下的IToolTipManagerClient组件。
	*/
    private function findTarget(displayObject : DisplayObject) : Void
    {
        while (displayObject != null)
        {
            if (Std.is(displayObject, IToolTipManagerClient)) 
            {
                currentTipData = cast((displayObject), IToolTipManagerClient).toolTip;
                if (currentTipData != null) 
                {
                    currentTarget = cast displayObject;
                    return;
                }
            }
            
            displayObject = displayObject.parent;
        }
        
        currentTipData = null;
        currentTarget = null;
    }
    
    /**
	* 当前的IToolTipManagerClient组件发生改变
	*/
    private function targetChanged() : Void
    {
        
        if (!initialized) 
            initialize();
        
        var event : ToolTipEvent;
        
        if (previousTarget != null && currentToolTip != null) 
        {
            event = new ToolTipEvent(ToolTipEvent.TOOL_TIP_HIDE);
            event.toolTip = currentToolTip;
            previousTarget.dispatchEvent(event);
        }
        
        reset();
        
        if (currentTarget != null) 
        {
            
            if (currentTipData == null) 
                return;
            
            if (_showDelay == 0 || showImmediatelyFlag || scrubTimer.running) 
            {
                createTip();
                initializeTip();
                positionTip();
                showTip();
            }
            else 
            {
                showTimer.delay = _showDelay;
                showTimer.start();
            }
        }
    }
    /**
	* toolTip实例缓存表
	*/
    private var toolTipCacheMap : SharedMap = new SharedMap();
    /**
	* 创建ToolTip显示对象
	*/
    private function createTip() : Void
    {
        var tipClass : Class<Dynamic> = currentTarget.toolTipClass;
        if (tipClass == null) 
        {
            tipClass = toolTipClass;
        }
        var key : String = Type.getClassName(tipClass);
        currentToolTip = toolTipCacheMap.get(key);
        if (currentToolTip == null) 
        {
            currentToolTip = Type.createInstance(tipClass, []);
            toolTipCacheMap.set(key, currentToolTip);
            if (Std.is(currentToolTip, InteractiveObject)) 
                cast((currentToolTip), InteractiveObject).mouseEnabled = false;
            if (Std.is(currentToolTip, DisplayObjectContainer)) 
                cast((currentToolTip), DisplayObjectContainer).mouseChildren = false;
        }
        toolTipContainer.addElement(currentToolTip);
    }
    /**
	* 获取工具提示弹出层
	*/
    private function get_toolTipContainer() : IContainer
    {
        var sm : ISystemManager = null;
        if (Std.is(_currentTarget, IUIComponent)) 
            sm = Lib.as((_currentTarget), IUIComponent).systemManager;
        if (sm == null) 
            sm = FlexLiteGlobals.systemManager;
        return sm.toolTipContainer;
    }
    /**
	* 初始化ToolTip显示对象
	*/
    private function initializeTip() : Void
    {
        currentToolTip.toolTipData = currentTipData;
        
        if (Std.is(currentToolTip, IInvalidating)) 
            Lib.as((currentToolTip), IInvalidating).validateNow();
    }
    /**
	* 设置ToolTip位置
	*/
    private function positionTip() : Void
    {
        var x : Float;
        var y : Float;
        var sm : DisplayObjectContainer = currentToolTip.parent;
        var toolTipWidth : Float = currentToolTip.layoutBoundsWidth;
        var toolTipHeight : Float = currentToolTip.layoutBoundsHeight;
        var rect : Rectangle = cast((currentTarget), DisplayObject).getRect(sm);
        var centerX : Float = rect.left + (rect.width - toolTipWidth) * 0.5;
        var centetY : Float = rect.top + (rect.height - toolTipHeight) * 0.5;
        var _sw0_ = (currentTarget.toolTipPosition);        

        switch (_sw0_)
        {
            case PopUpPosition.BELOW:
                x = centerX;
                y = rect.bottom;
            case PopUpPosition.ABOVE:
                x = centerX;
                y = rect.top - toolTipHeight;
            case PopUpPosition.LEFT:
                x = rect.left - toolTipWidth;
                y = centetY;
            case PopUpPosition.RIGHT:
                x = rect.right;
                y = centetY;
            case PopUpPosition.CENTER:
                x = centerX;
                y = centetY;
            case PopUpPosition.TOP_LEFT:
                x = rect.left;
                y = rect.top;
            default:
                x = sm.mouseX + 10;
                y = sm.mouseY + 20;
        }
        var offset : Point = currentTarget.toolTipOffset;
        if (offset != null) 
        {
            x += offset.x;
            y = offset.y;
        }
        var screenWidth : Float = sm.width;
        var screenHeight : Float = sm.height;
        if (x + toolTipWidth > screenWidth) 
            x = screenWidth - toolTipWidth;
        if (y + toolTipHeight > screenHeight) 
            y = screenHeight - toolTipHeight;
        if (x < 0) 
            x = 0;
        if (y < 0) 
            y = 0;
        currentToolTip.x = x;
        currentToolTip.y = y;
    }
    /**
	* 显示ToolTip
	*/
    private function showTip() : Void
    {
        var event : ToolTipEvent = 
        new ToolTipEvent(ToolTipEvent.TOOL_TIP_SHOW);
        event.toolTip = currentToolTip;
        currentTarget.dispatchEvent(event);
        
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_DOWN,
                stage_mouseDownHandler);
        if (_hideDelay == 0) 
        {
            hideTip();
        }
        else if (_hideDelay < Math.POSITIVE_INFINITY) 
        {
            hideTimer.delay = _hideDelay;
            hideTimer.start();
        }
    }
    /**
	* 隐藏ToolTip
	*/
    private function hideTip() : Void
    {
        if (previousTarget != null && currentToolTip != null) 
        {
            var event : ToolTipEvent = 
            new ToolTipEvent(ToolTipEvent.TOOL_TIP_HIDE);
            event.toolTip = currentToolTip;
            previousTarget.dispatchEvent(event);
        }
        
        if (previousTarget != null) 
        {
            FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_DOWN,
                    stage_mouseDownHandler);
        }
        reset();
    }
    
    /**
	* 移除当前的ToolTip对象并重置所有计时器。
	*/
    private function reset() : Void
    {
        showTimer.reset();
        hideTimer.reset();
        if (currentToolTip != null) 
        {
            var tipParent : DisplayObjectContainer = currentToolTip.parent;
            if (Std.is(tipParent, IVisualElementContainer)) 
                Lib.as((tipParent), IVisualElementContainer).removeElement(currentToolTip)
            else if (tipParent != null) 
                tipParent.removeChild(_currentToolTip);
            
            currentToolTip = null;
            
            scrubTimer.delay = scrubDelay;
            scrubTimer.reset();
            if (scrubDelay > 0) 
            {
                scrubTimer.delay = scrubDelay;
                scrubTimer.start();
            }
        }
    }
    /**
	* 使用指定的ToolTip数据,创建默认的ToolTip类的实例，然后在舞台坐标中的指定位置显示此实例。
	* 保存此方法返回的对 ToolTip 的引用，以便将其传递给destroyToolTip()方法销毁实例。
	* @param toolTipData ToolTip数据
	* @param x 舞台坐标x
	* @param y 舞台坐标y
	* @return 创建的ToolTip实例引用
	*/
    public function createToolTip(toolTipData : String, x : Float, y : Float) : IToolTip
    {
        var toolTip : IToolTip = Lib.as(Type.createInstance(toolTipClass, []), IToolTip);
        
        toolTipContainer.addElement(toolTip);
        
        toolTip.toolTipData = toolTipData;
        
        if (Std.is(currentToolTip, IInvalidating)) 
            Lib.as(currentToolTip, IInvalidating).validateNow();
        var pos : Point = toolTip.parent.globalToLocal(new Point(x, y));
        toolTip.x = pos.x;
        toolTip.y = pos.y;
        return toolTip;
    }
    
    /**
	* 销毁由createToolTip()方法创建的ToolTip实例。 
	* @param toolTip 要销毁的ToolTip实例
	*/
    public function destroyToolTip(toolTip : IToolTip) : Void
    {
        var tipParent : DisplayObjectContainer = toolTip.parent;
        if (Std.is(tipParent, IVisualElementContainer)) 
            Lib.as(tipParent, IVisualElementContainer).removeElement(toolTip)
        else if (tipParent != null && Std.is(toolTip, DisplayObject)) 
            tipParent.removeChild(cast toolTip);
    }
    
    /**
	* 鼠标经过IToolTipManagerClient组件
	*/
    private function toolTipMouseOverHandler(event : MouseEvent) : Void
    {
        checkIfTargetChanged(cast event.target);
    }
    /**
	* 鼠标移出IToolTipManagerClient组件
	*/
    private function toolTipMouseOutHandler(event : MouseEvent) : Void
    {
        checkIfTargetChanged(event.relatedObject);
    }
    
    /**
	* 显示ToolTip的计时器触发。
	*/
    private function showTimer_timerHandler(event : TimerEvent) : Void
    {
        if (currentTarget != null) 
        {
            createTip();
            initializeTip();
            positionTip();
            showTip();
        }
    }
    /**
	* 隐藏ToolTip的计时器触发
	*/
    private function hideTimer_timerHandler(event : TimerEvent) : Void
    {
        hideTip();
    }
    /**
	* 舞台上按下鼠标
	*/
    private function stage_mouseDownHandler(event : MouseEvent) : Void
    {
        reset();
    }
}


