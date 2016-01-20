package flexlite.components;



import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flexlite.core.FlexLiteGlobals;


import flexlite.core.IInvalidating;
import flexlite.core.IUIComponent;
import flexlite.core.IVisualElement;
import flexlite.core.PopUpPosition;
import flexlite.core.UIComponent;
import flexlite.effects.animation.Animation;
import flexlite.effects.animation.MotionPath;
import flexlite.managers.PopUpManager;
import flexlite.utils.CallLater;



@:meta(DefaultProperty(name="popUp"))


@:meta(DXML(show="true"))

/**
* PopUpAnchor组件用于定位布局中的弹出控件或下拉控件
* @author weilichuang
*/
class PopUpAnchor extends UIComponent
{
    public var popUpHeightMatchesAnchorHeight(get, set) : Bool;
    public var popUpWidthMatchesAnchorWidth(get, set) : Bool;
    public var displayPopUp(get, set) : Bool;
    public var popUp(get, set) : IVisualElement;
    public var popUpPosition(get, set) : String;
    private var animator(get, never) : Animation;
    public var openDuration(get, set) : Float;
    public var closeDuration(get, set) : Float;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
    }
    /**
	* popUp已经弹出的标志
	*/
    private var popUpIsDisplayed : Bool = false;
    /**
	* 自身已经添加到舞台标志
	*/
    private var addedToStage : Bool = false;
	
	private var _checkStageBound : Bool = false;
	
	public var checkStageBound(get, set):Bool;

	private inline function get_checkStageBound() : Bool
	{
		return _checkStageBound;
	}

	private inline function set_checkStageBound( value : Bool ) : Bool
	{
		if ( _checkStageBound == value )
			return value;

		_checkStageBound = value;

		invalidateDisplayList();
		
		return value;
	}
    
    private var _popUpHeightMatchesAnchorHeight : Bool = false;
    /**
	* 如果为 true，则将popUp控件的高度设置为 PopUpAnchor的高度值。
	*/
    private function get_popUpHeightMatchesAnchorHeight() : Bool
    {
        return _popUpHeightMatchesAnchorHeight;
    }
    private function set_popUpHeightMatchesAnchorHeight(value : Bool) : Bool
    {
        if (_popUpHeightMatchesAnchorHeight == value) 
            return value;
        
        _popUpHeightMatchesAnchorHeight = value;
        
        invalidateDisplayList();
        return value;
    }
    
    private var _popUpWidthMatchesAnchorWidth : Bool = false;
    /**
	* 如果为true，则将popUp控件的宽度设置为PopUpAnchor的宽度值。
	*/
    private function get_popUpWidthMatchesAnchorWidth() : Bool
    {
        return _popUpWidthMatchesAnchorWidth;
    }
    private function set_popUpWidthMatchesAnchorWidth(value : Bool) : Bool
    {
        if (_popUpWidthMatchesAnchorWidth == value) 
            return value;
        
        _popUpWidthMatchesAnchorWidth = value;
        
        invalidateDisplayList();
        return value;
    }
    
    private var _displayPopUp : Bool = false;
    /**
	* 如果为 true，则将popUp对象弹出。若为false，关闭弹出的popUp。
	*/
    private function get_displayPopUp() : Bool
    {
        return _displayPopUp;
    }
    private function set_displayPopUp(value : Bool) : Bool
    {
        if (_displayPopUp == value) 
            return value;
        
        _displayPopUp = value;
        addOrRemovePopUp();
        return value;
    }
    
    
    private var _popUp : IVisualElement;
    /**
	* 要弹出或移除的目标显示对象。
	*/
    private function get_popUp() : IVisualElement
    {
        return _popUp;
    }
    private function set_popUp(value : IVisualElement) : IVisualElement
    {
        if (_popUp == value) 
            return value;
        
        _popUp = value;
        
        dispatchEvent(new Event("popUpChanged"));
        return value;
    }
    
    private var _popUpPosition : String = PopUpPosition.TOP_LEFT;
    /**
	* popUp相对于PopUpAnchor的弹出位置。请使用PopUpPosition里定义的常量。默认值TOP_LEFT。
	* @see flexlite.core.PopUpPosition
	*/
    private function get_popUpPosition() : String
    {
        return _popUpPosition;
    }
    private function set_popUpPosition(value : String) : String
    {
        if (_popUpPosition == value) 
            return value;
        
        _popUpPosition = value;
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        applyPopUpTransform(unscaledWidth, unscaledHeight);
    }
    /**
	* 手动刷新popUp的弹出位置和尺寸。
	*/
    public function updatePopUpTransform() : Void
    {
        applyPopUpTransform(width, height);
    }
    /**
	* 计算popUp的弹出位置
	*/
    private function calculatePopUpPosition() : Point
    {
        var registrationPoint : Point = new Point();
        switch (_popUpPosition)
        {
            case PopUpPosition.BELOW:
                registrationPoint.x = 0;
                registrationPoint.y = height;
            case PopUpPosition.ABOVE:
                registrationPoint.x = 0;
                registrationPoint.y = -popUp.layoutBoundsHeight;
            case PopUpPosition.LEFT:
                registrationPoint.x = -popUp.layoutBoundsWidth;
                registrationPoint.y = 0;
            case PopUpPosition.RIGHT:
                registrationPoint.x = width;
                registrationPoint.y = 0;
            case PopUpPosition.CENTER:
                registrationPoint.x = (width - popUp.layoutBoundsWidth) * 0.5;
                registrationPoint.y = (height - popUp.layoutBoundsHeight) * 0.5;
            case PopUpPosition.TOP_LEFT:
        }
        registrationPoint = localToGlobal(registrationPoint);
        registrationPoint = popUp.parent.globalToLocal(registrationPoint);
        return registrationPoint;
    }
    
    /**
	* 正在播放动画的标志
	*/
    private var inAnimation : Bool = false;
    
    private var _animator : Animation = null;
    /**
	* 动画类实例
	*/
    private function get_animator() : Animation
    {
        if (_animator != null) 
            return _animator;
        _animator = new Animation(animationUpdateHandler);
        _animator.endFunction = animationEndHandler;
        _animator.startFunction = animationStartHandler;
        return _animator;
    }
    
    private var _openDuration : Float = 250;
    /**
	* 窗口弹出的动画时间(以毫秒为单位)，设置为0则直接弹出窗口而不播放动画效果。默认值250。
	*/
    private function get_openDuration() : Float
    {
        return _openDuration;
    }
    
    private function set_openDuration(value : Float) : Float
    {
        _openDuration = value;
        return value;
    }
    
    private var _closeDuration : Float = 150;
    /**
	* 窗口关闭的动画时间(以毫秒为单位)，设置为0则直接关闭窗口而不播放动画效果。默认值150。
	*/
    private function get_closeDuration() : Float
    {
        return _closeDuration;
    }
    
    private function set_closeDuration(value : Float) : Float
    {
        _closeDuration = value;
        return value;
    }
    
    /**
	* 动画开始播放触发的函数
	*/
    private function animationStartHandler(animation : Animation) : Void
    {
        inAnimation = true;
        popUp.addEventListener("scrollRectChange", onScrollRectChange);
        if (Std.is(popUp, IUIComponent)) 
            Lib.as(popUp, IUIComponent).enabled = false;
    }
    /**
	* 防止外部修改popUp的scrollRect属性
	*/
    private function onScrollRectChange(event : Event) : Void
    {
        if (inUpdating) 
            return;
        inUpdating = true;
        (cast(popUp, DisplayObject)).scrollRect = new Rectangle(Math.round(animator.currentValue.x), 
                Math.round(animator.currentValue.y), popUp.width, popUp.height);
        inUpdating = false;
    }
    
    private var inUpdating : Bool = false;
    /**
	* 动画播放过程中触发的更新数值函数
	*/
    private function animationUpdateHandler(animation : Animation) : Void
    {
        inUpdating = true;
        (cast(popUp, DisplayObject)).scrollRect = new Rectangle(Math.round(animation.currentValue.x), 
                Math.round(animation.currentValue.y), popUp.width, popUp.height);
        inUpdating = false;
    }
    
    /**
	* 动画播放完成触发的函数
	*/
    private function animationEndHandler(animation : Animation) : Void
    {
        inAnimation = false;
        popUp.removeEventListener("scrollRectChange", onScrollRectChange);
        if (Std.is(popUp, IUIComponent)) 
            Lib.as(popUp, IUIComponent).enabled = true;
        cast((popUp), DisplayObject).scrollRect = null;
        if (!popUpIsDisplayed) 
        {
            PopUpManager.removePopUp(popUp);
            popUp.ownerChanged(null);
        }
    }
    
    /**
	* 添加或移除popUp
	*/
    private function addOrRemovePopUp() : Void
    {
        if (!addedToStage || popUp == null) 
            return;
        
        if (popUp.parent == null && displayPopUp) 
        {
            PopUpManager.addPopUp(popUp, false, false, systemManager);
            popUp.ownerChanged(this);
            popUpIsDisplayed = true;
            if (inAnimation) 
                animator.end();
            if (initialized) 
            {
                applyPopUpTransform(width, height);
                if (_openDuration > 0) 
                    startAnimation();
            }
            else 
            {
                ClassForCallLater.callLater(function() : Void{
                            if (_openDuration > 0) 
                                startAnimation();
                        });
            }
        }
        else if (popUp.parent != null && !displayPopUp) 
        {
            removeAndResetPopUp();
        }
    }
    /**
	* 移除并重置popUp
	*/
    private function removeAndResetPopUp() : Void
    {
        if (inAnimation) 
            animator.end();
        popUpIsDisplayed = false;
        if (_closeDuration > 0) 
        {
            startAnimation();
        }
        else 
        {
            PopUpManager.removePopUp(popUp);
            popUp.ownerChanged(null);
        }
    }
    /**
	* 对popUp应用尺寸和位置调整
	*/
    private function applyPopUpTransform(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        if (!popUpIsDisplayed) 
            return;
        if (popUpWidthMatchesAnchorWidth) 
            popUp.width = unscaledWidth;
        if (popUpHeightMatchesAnchorHeight) 
            popUp.height = unscaledHeight;
        if (Std.is(popUp, IInvalidating)) 
            Lib.as(popUp, IInvalidating).validateNow();
        var popUpPoint : Point = calculatePopUpPosition();
        popUp.x = popUpPoint.x;
        popUp.y = popUpPoint.y;
		
		if ( checkStageBound )
		{
			if ( popUp.x < 0 )
				popUp.x = 0;
			if ( popUp.y < 0 )
				popUp.y = 0;
			if ( popUp.x + popUp.width > FlexLiteGlobals.stage.stageWidth )
				popUp.x = FlexLiteGlobals.stage.stageWidth - popUp.width;
			if ( popUp.y + popUp.height > FlexLiteGlobals.stage.stageHeight )
				popUp.y = FlexLiteGlobals.stage.stageHeight - popUp.height;
		}
    }
    /**
	* 开始播放动画
	*/
    private function startAnimation() : Void
    {
        animator.motionPaths = createMotionPath();
        if (popUpIsDisplayed) 
        {
            animator.duration = _openDuration;
        }
        else 
        {
            animator.duration = _closeDuration;
        }
        animator.play();
    }
    
    private var valueRange : Float = 1;
    /**
	* 创建动画轨迹
	*/
    private function createMotionPath() : Array<MotionPath>
    {
        var xPath : MotionPath = new MotionPath("x");
        var yPath : MotionPath = new MotionPath("y");
        var path : Array<MotionPath> = [xPath, yPath];
        switch (_popUpPosition)
        {
            case PopUpPosition.TOP_LEFT, PopUpPosition.CENTER, PopUpPosition.BELOW:
                xPath.valueFrom = xPath.valueTo = 0;
                yPath.valueFrom = popUp.height;
                yPath.valueTo = 0;
                valueRange = popUp.height;
            case PopUpPosition.ABOVE:
                xPath.valueFrom = xPath.valueTo = 0;
                yPath.valueFrom = -popUp.height;
                yPath.valueTo = 0;
                valueRange = popUp.height;
            case PopUpPosition.LEFT:
                yPath.valueFrom = yPath.valueTo = 0;
                xPath.valueFrom = -popUp.width;
                xPath.valueTo = 0;
                valueRange = popUp.width;
            case PopUpPosition.RIGHT:
                yPath.valueFrom = yPath.valueTo = 0;
                xPath.valueFrom = popUp.width;
                xPath.valueTo = 0;
                valueRange = popUp.width;
            default:
                valueRange = 1;
        }
        valueRange = Math.abs(valueRange);
        if (!popUpIsDisplayed) 
        {
            var tempValue : Float = xPath.valueFrom;
            xPath.valueFrom = xPath.valueTo;
            xPath.valueTo = tempValue;
            tempValue = yPath.valueFrom;
            yPath.valueFrom = yPath.valueTo;
            yPath.valueTo = tempValue;
        }
        return path;
    }
    /**
	* 添加到舞台事件
	*/
    private function addedToStageHandler(event : Event) : Void
    {
        addedToStage = true;
        ClassForCallLater.callLater(checkPopUpState);
    }
    
    /**
	* 延迟检查弹出状态，防止堆栈溢出。
	*/
    private function checkPopUpState() : Void
    {
        if (addedToStage) 
        {
            addOrRemovePopUp();
        }
        else 
        {
            if (popUp != null && cast((popUp), DisplayObject).parent != null) 
                removeAndResetPopUp();
        }
    }
    
    /**
	* 从舞台移除事件
	*/
    private function removedFromStageHandler(event : Event) : Void
    {
        addedToStage = false;
        ClassForCallLater.callLater(checkPopUpState);
    }
}

