package flexlite.components;



import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flexlite.core.FlexLiteGlobals;
import flexlite.events.CloseEvent;
import flexlite.managers.PopUpManager;
import flexlite.utils.LayoutUtil;






@:meta(DXML(show="true"))


/**
* 窗口关闭事件
*/
@:meta(Event(name="close",type="flexlite.events.CloseEvent"))


/**
* 可移动窗口组件。注意，此窗口必须使用PopUpManager.addPopUp()弹出之后才能移动。
* @author weilichuang
*/
class TitleWindow extends Panel
{
	/**
	* 是否显示关闭按钮,默认true。
	*/
    public var showCloseButton(get, set) : Bool;
	
	/**
	* 在拖拽窗口时，有可能把窗口完全拖出屏幕外，导致无法点中moveArea而不能拖回屏幕。
	* 此属性为true时，将会在拖拽结束时，自动调整窗口位置，使moveArea可以被再次点中。
	* 反之不调整。默认值为true。
	*/
    public var autoBackToStage(get, set) : Bool;
	
	/**
	* [SkinPart]关闭按钮
	*/
	@SkinPart
    public var closeButton : Button;
    
    /**
	* [SkinPart]可移动区域
	*/
	@SkinPart
    public var moveArea : InteractiveObject;
    
    private var _showCloseButton : Bool = true;
	
	private var _autoBackToStage : Bool = true;
	/**
	* 鼠标按下时的偏移量
	*/
    private var offsetPoint : Point;
    

    public function new()
    {
        super();
        this.addEventListener(MouseEvent.MOUSE_DOWN, onWindowMouseDown, true, 100);
    }
    /**
	* 在窗体上按下时前置窗口
	*/
    private function onWindowMouseDown(event : MouseEvent) : Void
    {
        if (enabled && isPopUp && event.target != closeButton) 
        {
            PopUpManager.bringToFront(this);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return TitleWindow;
    }
    
    private function get_showCloseButton() : Bool
    {
        return _showCloseButton;
    }
    
    private function set_showCloseButton(value : Bool) : Bool
    {
        if (_showCloseButton == value) 
            return value;
        _showCloseButton = value;
        if (closeButton != null) 
            closeButton.visible = _showCloseButton;
        return value;
    }
    
    
    
    private function get_autoBackToStage() : Bool
    {
        return _autoBackToStage;
    }
    private function set_autoBackToStage(value : Bool) : Bool
    {
        _autoBackToStage = value;
        return value;
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == moveArea) 
        {
            moveArea.addEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler);
        }
        else if (instance == closeButton) 
        {
            closeButton.addEventListener(MouseEvent.CLICK, closeButton_clickHandler);
            closeButton.visible = _showCloseButton;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        
        if (instance == moveArea) 
            moveArea.removeEventListener(MouseEvent.MOUSE_DOWN, moveArea_mouseDownHandler)
        else if (instance == closeButton) 
            closeButton.removeEventListener(MouseEvent.CLICK, closeButton_clickHandler);
    }
    
    private function closeButton_clickHandler(event : MouseEvent) : Void
    {
        dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
    }
    
    
    /**
	* 鼠标在可移动区域按下
	*/
    private function moveArea_mouseDownHandler(event : MouseEvent) : Void
    {
        if (enabled && isPopUp) 
        {
            offsetPoint = globalToLocal(new Point(event.stageX, event.stageY));
            _includeInLayout = false;
            FlexLiteGlobals.stage.addEventListener(
                    MouseEvent.MOUSE_MOVE, moveArea_mouseMoveHandler);
            FlexLiteGlobals.stage.addEventListener(
                    MouseEvent.MOUSE_UP, moveArea_mouseUpHandler);
            FlexLiteGlobals.stage.addEventListener(
                    Event.MOUSE_LEAVE, moveArea_mouseUpHandler);
        }
    }
    /**
	* 鼠标拖拽时的移动事件
	*/
    private function moveArea_mouseMoveHandler(event : MouseEvent) : Void
    {
        var pos : Point = globalToLocal(new Point(event.stageX, event.stageY));
        this.x += pos.x - offsetPoint.x;
        this.y += pos.y - offsetPoint.y;
        if (FlexLiteGlobals.useUpdateAfterEvent) 
            event.updateAfterEvent();
    }
    /**
	* 鼠标在舞台上弹起事件
	*/
    private function moveArea_mouseUpHandler(event : Event) : Void
    {
        FlexLiteGlobals.stage.removeEventListener(
                MouseEvent.MOUSE_MOVE, moveArea_mouseMoveHandler);
        FlexLiteGlobals.stage.removeEventListener(
                MouseEvent.MOUSE_UP, moveArea_mouseUpHandler);
        FlexLiteGlobals.stage.removeEventListener(
                Event.MOUSE_LEAVE, moveArea_mouseUpHandler);
        if (_autoBackToStage) 
        {
            adjustPosForStage();
        }
        offsetPoint = null;
        LayoutUtil.adjustRelativeByXY(this);
        includeInLayout = true;
    }
    /**
	* 调整窗口位置，使其可以在舞台中被点中
	*/
    private function adjustPosForStage() : Void
    {
        if (moveArea == null || stage == null) 
            return;
			
        var pos : Point = moveArea.localToGlobal(new Point());
        var stageX : Float = pos.x;
        var stageY : Float = pos.y;
        if (pos.x + moveArea.width < 35) 
        {
            stageX = 35 - moveArea.width;
        }
        if (pos.x > stage.stageWidth - 20) 
        {
            stageX = stage.stageWidth - 20;
        }
        if (pos.y + moveArea.height < 20) 
        {
            stageY = 20 - moveArea.height;
        }
        if (pos.y > stage.stageHeight - 20) 
        {
            stageY = stage.stageHeight - 20;
        }
        this.x += stageX - pos.x;
        this.y += stageY - pos.y;
    }
}

