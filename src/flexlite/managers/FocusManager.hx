package flexlite.managers;

import flash.Lib;
import flash.text.TextFieldType;
import flexlite.managers.IFocusManager;

import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.text.TextField;

import flexlite.core.IUIComponent;

/**
* 焦点管理器，设置了stage属性后，开始管理全局的焦点。
* @author weilichuang
*/
class FocusManager implements IFocusManager
{
    public var stage(get, set) : Stage;

    /**
	* 构造函数
	*/
    public function new()
    {
        
    }
    
    private var _stage : Stage;
    /**
	* 舞台引用
	*/
    private function get_stage() : Stage
    {
        return _stage;
    }
    private function set_stage(value : Stage) : Stage
    {
        if (_stage == value) 
            return value;
			
        var s : Stage = (_stage != null) ? stage : value;
        if (value != null) 
        {
            s.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            s.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
            s.addEventListener(Event.ACTIVATE, activateHandler);
            s.addEventListener(FocusEvent.FOCUS_IN, focusInHandler, true);
        }
        else 
        {
            s.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
            s.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
            s.removeEventListener(Event.ACTIVATE, activateHandler);
            s.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler, true);
        }
        _stage = value;
        return value;
    }
    
    /**
	* 屏蔽FP原始的焦点处理过程
	*/
    private function mouseFocusChangeHandler(event : FocusEvent) : Void
    {
        if (event.isDefaultPrevented()) 
            return;
        
        if (Std.is(event.relatedObject, TextField)) 
        {
            var tf : TextField = cast(event.relatedObject, TextField);
            if (tf.type == TextFieldType.INPUT || tf.selectable ||
                (tf.htmlText != null && tf.htmlText.indexOf("</A>") != -1)) 
            {
                return;
            }
        }
        event.preventDefault();
    }
    
    /**
	* 当前的焦点对象。
	*/
    private var currentFocus : IUIComponent;
    /**
	* 鼠标按下事件
	*/
    private function onMouseDown(event : MouseEvent) : Void
    {
        var focus : IUIComponent = getTopLevelFocusTarget(cast event.target);
        if (focus == null) 
            return;
        
        if (focus != currentFocus && !(Std.is(focus, TextField))) 
        {
            focus.setFocus();
        }
    }
    /**
	* 焦点改变时更新currentFocus
	*/
    private function focusInHandler(event : FocusEvent) : Void
    {
        currentFocus = getTopLevelFocusTarget(cast event.target);
    }
    /**
	* 获取鼠标按下点的焦点对象
	*/
    private function getTopLevelFocusTarget(target : InteractiveObject) : IUIComponent
    {
        while (target != null)
        {
            if (Std.is(target, IUIComponent) &&
                Lib.as(target, IUIComponent).focusEnabled &&
                Lib.as(target, IUIComponent).enabled) 
            {
                return Lib.as(target, IUIComponent);
            }
            target = target.parent;
        }
        return null;
    }
    
    /**
	* 窗口激活时重新设置焦点
	*/
    private function activateHandler(event : Event) : Void
    {
        if (currentFocus != null) 
            currentFocus.setFocus();
    }
}
