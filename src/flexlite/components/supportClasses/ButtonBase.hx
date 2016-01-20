package flexlite.components.supportclasses;


import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextFormatAlign;
import flash.utils.Timer;


import flexlite.components.Label;
import flexlite.components.SkinnableComponent;
import flexlite.core.FlexLiteGlobals;
import flexlite.core.IDisplayText;

import flexlite.events.UIEvent;
import flexlite.layouts.VerticalAlign;



/**
* 当用户按下ButtonBase控件时分派。如果 autoRepeat属性为 true，则只要按钮处于按下状态，就将重复分派此事件。 
*/
@:meta(Event(name="buttonDown",type="flexlite.events.UIEvent"))

@:meta(DXML(show="false"))

@:meta(DefaultProperty(name="label",array="false"))

@:meta(SkinState(name="up"))

@:meta(SkinState(name="over"))

@:meta(SkinState(name="down"))

@:meta(SkinState(name="disabled"))


/**
* 按钮组件基类
* @author weilichuang
*/
class ButtonBase extends SkinnableComponent
{
	/**
	* 指定在用户按住鼠标按键时是否重复分派 buttonDown 事件。
	*/
    public var autoRepeat(get, set) : Bool;
	/**
	* 在第一个 buttonDown 事件之后，以及相隔每个 repeatInterval 重复一次 buttonDown 事件之前，需要等待的毫秒数。
	*/
    public var repeatDelay(get, set) : Float;
	/**
	* 用户在按钮上按住鼠标时，buttonDown 事件之间相隔的毫秒数。
	*/
    public var repeatInterval(get, set) : Float;
	/**
	* 指示鼠标指针是否位于按钮上。
	*/
    private var hovered(get, set) : Bool;
	
	/**
	* 要在按钮上显示的文本
	*/
    public var label(get, set) : String;
	
	/**
	* 指示第一次分派 MouseEvent.MOUSE_DOWN 时，是否按下鼠标以及鼠标指针是否在按钮上。
	*/
    private var mouseCaptured(get, set) : Bool;
	
	/**
	* 如果为 false，则按钮会在用户按下它时显示其鼠标按下时的外观，但在用户将鼠标拖离它时将改为显示鼠标经过的外观。
	* 如果为 true，则按钮会在用户按下它时显示其鼠标按下时的外观，并在用户将鼠标拖离时继续显示此外观。
	*/
    public var stickyHighlighting(get, set) : Bool;
	
	/**
	* 如果皮肤不提供labelDisplay子项，自己是否创建一个，默认为true。
	*/
    public var createLabelIfNeed(get, set) : Bool;
	
	/**
	* [SkinPart]按钮上的文本标签
	*/
	@SkinPart
    public var labelDisplay : IDisplayText;
	
	
	/**
	* 已经开始过不断抛出buttonDown事件的标志
	*/
    private var _downEventFired : Bool = false;
    
    /**
	* 重发buttonDown事件计时器 
	*/
    private var autoRepeatTimer : Timer;

    private var _autoRepeat : Bool = false;
	
	private var _repeatDelay : Float = 35;
    private var _repeatInterval : Float = 35;
    private var _hovered : Bool = false;
    private var _keepDown : Bool = false;
    private var _label : String = "";
    private var _mouseCaptured : Bool = false;
    private var _stickyHighlighting : Bool = false;
	
	private var _createLabelIfNeed : Bool = true;
    
    private var createLabelIfNeedChanged : Bool = false;
    /**
	* 创建过label的标志
	*/
    private var hasCreatedLabel : Bool = false;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        mouseChildren = false;
        buttonMode = true;
        useHandCursor = true;
        focusEnabled = true;
        autoMouseEnabled = false;
		tabEnabled = false;
        addHandlers();
    }
    
    
    
    private function get_autoRepeat() : Bool
    {
        return _autoRepeat;
    }
    
    private function set_autoRepeat(value : Bool) : Bool
    {
        if (value == _autoRepeat) 
            return value;
        
        _autoRepeat = value;
        checkAutoRepeatTimerConditions(isDown());
        return value;
    }
    
    
    
    private function get_repeatDelay() : Float
    {
        return _repeatDelay;
    }
    
    private function set_repeatDelay(value : Float) : Float
    {
        _repeatDelay = value;
        return value;
    }
    
    
    
    private function get_repeatInterval() : Float
    {
        return _repeatInterval;
    }
    
    private function set_repeatInterval(value : Float) : Float
    {
        _repeatInterval = value;
        return value;
    }
    
    
    
    private function get_hovered() : Bool
    {
        return _hovered;
    }
    
    private function set_hovered(value : Bool) : Bool
    {
        if (value == _hovered) 
            return value;
        _hovered = value;
        invalidateSkinState();
        checkButtonDownConditions();
        return value;
    }
    
    
    /**
	* 强制让按钮停在鼠标按下状态,此方法不会导致重复抛出buttonDown事件,仅影响皮肤State。
	* @param down 是否按下
	*/
    public function keepDown(down : Bool) : Void
    {
        if (_keepDown == down) 
            return;
        _keepDown = down;
        invalidateSkinState();
    }
    
    
    
    private function set_label(value : String) : String
    {
        _label = value;
        if (labelDisplay != null) 
        {
            labelDisplay.text = value;
        }
        return value;
    }
    
    private function get_label() : String
    {
        if (labelDisplay != null) 
        {
            return labelDisplay.text;
        }
        else 
        {
            return _label;
        }
    }
    
    
    private function get_mouseCaptured() : Bool
    {
        return _mouseCaptured;
    }
    
    private function set_mouseCaptured(value : Bool) : Bool
    {
        if (value == _mouseCaptured) 
            return value;
        
        _mouseCaptured = value;
        invalidateSkinState();
        if (!value) 
            removeStageMouseHandlers();
        checkButtonDownConditions();
        return value;
    }
    
    
    private function get_stickyHighlighting() : Bool
    {
        return _stickyHighlighting;
    }
    
    private function set_stickyHighlighting(value : Bool) : Bool
    {
        if (value == _stickyHighlighting) 
            return value;
        
        _stickyHighlighting = value;
        invalidateSkinState();
        checkButtonDownConditions();
        return value;
    }
    
    
    /**
	* 开始抛出buttonDown事件
	*/
    private function checkButtonDownConditions() : Void
    {
        var isCurrentlyDown : Bool = isDown();
        if (_downEventFired != isCurrentlyDown) 
        {
            if (isCurrentlyDown) 
            {
                dispatchEvent(new UIEvent(UIEvent.BUTTON_DOWN));
            }
            
            _downEventFired = isCurrentlyDown;
            checkAutoRepeatTimerConditions(isCurrentlyDown);
        }
    }
    
    /**
	* 添加鼠标事件监听
	*/
    private function addHandlers() : Void
    {
        addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
        addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
        addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
        addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
        addEventListener(MouseEvent.CLICK, mouseEventHandler);
    }
    
    /**
	* 添加舞台鼠标弹起事件监听
	*/
    private function addStageMouseHandlers() : Void
    {
        FlexLiteGlobals.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, false, 0, true);
        
        FlexLiteGlobals.stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler, false, 0, true);
    }
    
    /**
	* 移除舞台鼠标弹起事件监听
	*/
    private function removeStageMouseHandlers() : Void
    {
        FlexLiteGlobals.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
        
        FlexLiteGlobals.stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseUpHandler);
    }
    
    /**
	* 按钮是否是按下的状态
	*/
    private function isDown() : Bool
    {
        if (!enabled) 
            return false;
        
        if (mouseCaptured && (hovered || stickyHighlighting)) 
            return true;
        return false;
    }
    
    
    /**
	* 检查需要启用还是关闭重发计时器
	*/
    private function checkAutoRepeatTimerConditions(buttonDown : Bool) : Void
    {
        var needsTimer : Bool = autoRepeat && buttonDown;
        var hasTimer : Bool = autoRepeatTimer != null;
        
        if (needsTimer == hasTimer) 
            return;
        
        if (needsTimer) 
            startTimer()
        else 
        stopTimer();
    }
    
    /**
	* 启动重发计时器
	*/
    private function startTimer() : Void
    {
        autoRepeatTimer = new Timer(1);
        autoRepeatTimer.delay = _repeatDelay;
        autoRepeatTimer.addEventListener(TimerEvent.TIMER, autoRepeat_timerDelayHandler);
        autoRepeatTimer.start();
    }
    
    /**
	* 停止重发计时器
	*/
    private function stopTimer() : Void
    {
        autoRepeatTimer.stop();
        autoRepeatTimer = null;
    }
    
    
    /**
	* 鼠标事件处理
	*/
    private function mouseEventHandler(event : Event) : Void
    {
        var mouseEvent : MouseEvent = cast(event, MouseEvent);
        var _sw0_:String = (event.type);        

        switch (_sw0_)
        {
            case MouseEvent.ROLL_OVER:
            {
                if (mouseEvent.buttonDown && !mouseCaptured) 
                    return;
                hovered = true;
            }
            
            case MouseEvent.ROLL_OUT:
            {
                hovered = false;
            }
            
            case MouseEvent.MOUSE_DOWN:
            {
                addStageMouseHandlers();
                mouseCaptured = true;
            }
            
            case MouseEvent.MOUSE_UP:
            {
                if (event.target == this) 
                {
                    hovered = true;
                    
                    if (mouseCaptured) 
                    {
                        buttonReleased();
                        mouseCaptured = false;
                    }
                }
            }
            case MouseEvent.CLICK:
            {
                if (!enabled) 
                    event.stopImmediatePropagation()
                else 
                clickHandler(cast((event), MouseEvent));
                return;
            }
        }
    }
    
    /**
	* 按钮弹起事件
	*/
    private function buttonReleased() : Void
    {
        
    }
    
    /**
	* 按钮点击事件
	*/
    private function clickHandler(event : MouseEvent) : Void
    {
        
    }
    
    /**
	* 舞台上鼠标弹起事件
	*/
    private function stage_mouseUpHandler(event : Event) : Void
    {
        if (event.target == this) 
            return;
        
        mouseCaptured = false;
    }
    
    /**
	* 自动重发计时器首次延迟结束事件
	*/
    private function autoRepeat_timerDelayHandler(event : TimerEvent) : Void
    {
        autoRepeatTimer.reset();
        autoRepeatTimer.removeEventListener(TimerEvent.TIMER, autoRepeat_timerDelayHandler);
        
        autoRepeatTimer.delay = _repeatInterval;
        autoRepeatTimer.addEventListener(TimerEvent.TIMER, autoRepeat_timerHandler);
        autoRepeatTimer.start();
    }
    
    /**
	* 自动重发buttonDown事件
	*/
    private function autoRepeat_timerHandler(event : TimerEvent) : Void
    {
        dispatchEvent(new UIEvent(UIEvent.BUTTON_DOWN));
    }
    
    /**
	* @inheritDoc
	*/
    override private function getCurrentSkinState() : String
    {
        if (!enabled) 
            return super.getCurrentSkinState();
        
        if (isDown() || _keepDown) 
            return "down";
        
        if (hovered || mouseCaptured) 
            return "over";
        
        return "up";
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == labelDisplay) 
        {
            labelDisplay.text = _label;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (createLabelIfNeedChanged) 
        {
            createLabelIfNeedChanged = false;
            if (createLabelIfNeed) 
            {
                createSkinParts();
                invalidateSize();
                invalidateDisplayList();
            }
            else 
            {
                removeSkinParts();
            }
        }
    }
    
    
    
    private function get_createLabelIfNeed() : Bool
    {
        return _createLabelIfNeed;
    }
    
    private function set_createLabelIfNeed(value : Bool) : Bool
    {
        if (value == _createLabelIfNeed) 
            return value;
        _createLabelIfNeed = value;
        createLabelIfNeedChanged = true;
        invalidateProperties();
        return value;
    }
	
	
    
    /**
	* @inheritDoc
	*/
    override private function createSkinParts() : Void
    {
        if (hasCreatedLabel || !_createLabelIfNeed) 
            return;
        hasCreatedLabel = true;
        var text : Label = new Label();
        text.textAlign = TextFormatAlign.CENTER;
        text.verticalAlign = VerticalAlign.MIDDLE;
        text.maxDisplayedLines = 1;
        text.left = 10;
        text.right = 10;
        text.top = 2;
        text.bottom = 2;
        addToDisplayList(text);
        labelDisplay = text;
        partAdded("labelDisplay", labelDisplay);
    }
    
    /**
	* @inheritDoc
	*/
    override private function removeSkinParts() : Void
    {
        if (!hasCreatedLabel) 
            return;
        hasCreatedLabel = false;
        if (labelDisplay == null) 
            return;
        _label = labelDisplay.text;
        partRemoved("labelDisplay", labelDisplay);
        removeFromDisplayList(cast(labelDisplay, DisplayObject));
        labelDisplay = null;
    }
	
	override public function set_enabled( value : Bool ) : Bool
	{
		super.set_enabled(value);
		this.buttonMode = this.enabled;
		
		return value;
	}
}


