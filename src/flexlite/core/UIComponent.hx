package flexlite.core;


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Point;
import flash.Lib;
import flexlite.core.FlexLiteGlobals;
import flexlite.core.IInvalidating;
import flexlite.core.ILayoutElement;
import flexlite.core.IUIComponent;
import flexlite.core.IVisualElement;
import flexlite.events.MoveEvent;
import flexlite.events.PropertyChangeEvent;
import flexlite.events.ResizeEvent;
import flexlite.events.UIEvent;
import flexlite.managers.ILayoutManagerClient;
import flexlite.managers.ISystemManager;
import flexlite.managers.IToolTipManagerClient;
import flexlite.managers.ToolTipManager;
import flexlite.utils.MathUtil;


/**
* 组件尺寸发生改变 
*/
@:meta(Event(name="resize",type="flexlite.events.ResizeEvent"))

/**
* 组件位置发生改变 
*/
@:meta(Event(name="move",type="flexlite.events.MoveEvent"))

/**
* 组件开始初始化
*/
@:meta(Event(name="initialize",type="flexlite.events.UIEvent"))


/**
* 组件创建完成 
*/
@:meta(Event(name="creationComplete",type="flexlite.events.UIEvent"))

/**
* 组件的一次三个延迟验证渲染阶段全部完成 
*/
@:meta(Event(name="updateComplete",type="flexlite.events.UIEvent"))

/**
* 即将显示ToolTip显示对象
*/
@:meta(Event(name="toolTipShow",type="flexlite.events.ToolTipEvent"))

/**
* 即将隐藏ToolTip显示对象
*/
@:meta(Event(name="toolTipHide",type="flexlite.events.ToolTipEvent"))


/**
* 拖拽开始,此事件由启动拖拽的组件自身抛出。
*/
@:meta(Event(name="dragStart",type="flexlite.events.DragEvent"))

/**
* 拖拽完成，此事件由拖拽管理器在启动拖拽的组件上抛出。
*/
@:meta(Event(name="dragComplete",type="flexlite.events.DragEvent"))

/**
* 在目标区域放下拖拽的数据,此事件由拖拽管理器在经过的目标组件上抛出。
*/
@:meta(Event(name="dragDrop",type="flexlite.events.DragEvent"))

/**
* 拖拽进入目标区域，此事件由拖拽管理器在经过的目标组件上抛出。
*/
@:meta(Event(name="dragEnter",type="flexlite.events.DragEvent"))

/**
* 拖拽移出目标区域，此事件由拖拽管理器在经过的目标组件上抛出。
*/
@:meta(Event(name="dragExit",type="flexlite.events.DragEvent"))

/**
* 拖拽经过目标区域，相当于MouseOver事件，此事件由拖拽管理器在经过的目标组件上抛出。
*/
@:meta(Event(name="dragOver",type="flexlite.events.DragEvent"))


@:meta(DXML(show="false"))


/**
* 显示对象基类
* @author weilichuang
*/
class UIComponent extends Sprite implements IUIComponent 
								implements ILayoutManagerClient 
								implements ILayoutElement 
								implements IInvalidating 
								implements IVisualElement 
								implements IToolTipManagerClient
{
	/**
	* 组件 ID。此值将作为对象的实例名称，因此不应包含任何空格或特殊字符。应用程序中的每个组件都应具有唯一的 ID。 
	*/
    public var id(get, set) : String;
	
	/**
	* @inheritDoc
	*/
    public var toolTip(get, set) : Dynamic;
	
	/**
	* @inheritDoc
	*/
    public var toolTipClass(get, set) : Class<IToolTip>;
	
	/**
	* @inheritDoc
	*/
    public var toolTipOffset(get, set) : Point;
	
	/**
	* @inheritDoc
	*/
    public var toolTipPosition(get, set) : String;
	
	/**
	* @inheritDoc
	*/
    public var isPopUp(get, set) : Bool;
	
	/**
	* @inheritDoc
	*/
    public var owner(get, never) : Dynamic;
	
	/**
	* @inheritDoc
	*/
    public var systemManager(get, set) : ISystemManager;
	
	/**
	* @inheritDoc
	*/
    public var updateCompletePendingFlag(get, set) : Bool;
	
	/**
	* @inheritDoc
	*/
    public var initialized(get, set) : Bool;
	
	/**
	* @inheritDoc
	*/
    public var nestLevel(get, set) : Int;
	/**
	* @inheritDoc
	*/
    public var enabled(get, set) : Bool;
	/**
	* @inheritDoc
	*/
    public var explicitWidth(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var explicitHeight(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var minWidth(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var maxWidth(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var minHeight(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var maxHeight(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var measuredWidth(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var measuredHeight(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var includeInLayout(get, set) : Bool;
	/**
	* @inheritDoc
	*/
    public var left(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var right(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var top(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var bottom(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var horizontalCenter(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var verticalCenter(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var percentWidth(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var percentHeight(get, set) : Float;
	/**
	* @inheritDoc
	*/
    public var preferredWidth(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var preferredHeight(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var preferredX(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var preferredY(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var layoutBoundsX(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var layoutBoundsY(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var layoutBoundsWidth(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var layoutBoundsHeight(get, never) : Float;
	/**
	* @inheritDoc
	*/
    public var focusEnabled(get, set) : Bool;
	
	
	private var _id : String;

    private var _toolTip : Dynamic;
    private var _toolTipClass : Class<IToolTip>;
    private var _toolTipOffset : Point;
    private var _toolTipPosition : String = "mouse";
	
    private var _isPopUp : Bool;
    private var _owner : Dynamic;
    private var _systemManager : ISystemManager;
    private var _updateCompletePendingFlag : Bool = false;
	
	private var _initialized : Bool = false;
    /**
	* initialize()方法被调用过的标志。
	*/
    private var initializeCalled : Bool = false;
    private var _nestLevel : Int = 0;
    private var _enabled : Bool = true;
	
	private var invalidateDisplayListFlag : Bool = false;
    private var validateNowFlag : Bool = false;
	private var invalidatePropertiesFlag : Bool = false;
	private var invalidateSizeFlag : Bool = false;
	
    /**
	* 属性提交前组件旧的宽度
	*/
    private var oldWidth : Float;
    /**
	* 属性提交前组件旧的高度
	*/
    private var oldHeight : Float;
	
	private var _width : Float;
    private var _height : Float;
	
	private var _explicitWidth : Float = Math.NaN;
    private var _explicitHeight : Float = Math.NaN;
	
	private var _minWidth : Float = 0;
    private var _maxWidth : Float = 10000;
	
    private var _minHeight : Float = 0;
    private var _maxHeight : Float = 10000;
	
    private var _measuredWidth : Float = 0;
    private var _measuredHeight : Float = 0;
    /**
	* 属性提交前组件旧的X
	*/
    private var oldX : Float;
    /**
	* 属性提交前组件旧的Y
	*/
    private var oldY : Float;
    
    /**
	* 上一次测量的首选宽度
	*/
    private var oldPreferWidth : Float;
    /**
	* 上一次测量的首选高度
	*/
    private var oldPreferHeight : Float;
	
    private var _includeInLayout : Bool = true;
	
    private var _left : Float;
    private var _right : Float;
    private var _top : Float;
    private var _bottom : Float;
	
    private var _horizontalCenter : Float;
    private var _verticalCenter : Float;
	
    private var _percentWidth : Float;
    private var _percentHeight : Float;
	
	/**
	* 父级布局管理器设置了组件的宽度标志，尺寸设置优先级：自动布局>显式设置>自动测量
	*/
    private var layoutWidthExplicitlySet : Bool = false;
    
    /**
	* 父级布局管理器设置了组件的高度标志，尺寸设置优先级：自动布局>显式设置>自动测量
	*/
    private var layoutHeightExplicitlySet : Bool = false;
	
    private var _focusEnabled : Bool = false;
	
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        focusRect = false;
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        addEventListener(Event.ADDED_TO_STAGE, checkInvalidateFlag);
    }
	
	public function getStage():Stage
	{
		return this.stage;
	}
	
	/**
	* @inheritDoc
	*/
    public function ownerChanged(value : Dynamic) : Void
    {
        _owner = value;
    }
	
	/**
	* @inheritDoc
	*/
    public function setActualSize(w : Float, h : Float) : Void
    {
        var change : Bool = false;
        if (_width != w) 
        {
            _width = w;
            change = true;
        }
        if (_height != h) 
        {
            _height = h;
            change = true;
        }
        if (change) 
        {
            invalidateDisplayList();
            dispatchResizeEvent();
        }
    }
	
	/**
	* @inheritDoc
	*/
    public function setFocus() : Void
    {
        if (FlexLiteGlobals.stage != null) 
        {
            FlexLiteGlobals.stage.focus = this;
        }
    }
	
	/**
	* @inheritDoc
	*/
    public function invalidateProperties() : Void
    {
        if (!invalidatePropertiesFlag) 
        {
            invalidatePropertiesFlag = true;
            
            if (parent != null && FlexLiteGlobals.layoutManager != null) 
                FlexLiteGlobals.layoutManager.invalidateProperties(this);
        }
    }
	
    /**
	* @inheritDoc
	*/
    public function validateProperties() : Void
    {
        if (invalidatePropertiesFlag) 
        {
            commitProperties();
            
            invalidatePropertiesFlag = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    public function invalidateSize() : Void
    {
        if (!invalidateSizeFlag) 
        {
            invalidateSizeFlag = true;
            
            if (parent != null && FlexLiteGlobals.layoutManager != null) 
                FlexLiteGlobals.layoutManager.invalidateSize(this);
        }
    }
    
    /**
	* @inheritDoc
	*/
    public function validateSize(recursive : Bool = false) : Void
    {
        if (recursive) 
        {
            for (i in 0...numChildren)
			{
                var child : DisplayObject = getChildAt(i);
                if (Std.is(child, ILayoutManagerClient)) 
                    Lib.as(child, ILayoutManagerClient).validateSize(true);
            }
        }
        if (invalidateSizeFlag) 
        {
            var changed : Bool = measureSizes();
            if (changed) 
            {
                invalidateDisplayList();
                invalidateParentSizeAndDisplayList();
            }
            invalidateSizeFlag = false;
        }
    }
	
	/**
	* @inheritDoc
	*/
    public function invalidateDisplayList() : Void
    {
        if (!invalidateDisplayListFlag) 
        {
            invalidateDisplayListFlag = true;
            
            if (parent != null && FlexLiteGlobals.layoutManager != null) 
                FlexLiteGlobals.layoutManager.invalidateDisplayList(this);
        }
    }
    
    /**
	* @inheritDoc
	*/
    public function validateDisplayList() : Void
    {
        if (invalidateDisplayListFlag) 
        {
            var unscaledWidth : Float = 0;
            var unscaledHeight : Float = 0;
			
            if (layoutWidthExplicitlySet) 
            {
                unscaledWidth = _width;
            }
            else if (!Math.isNaN(explicitWidth)) 
            {
                unscaledWidth = explicitWidth;
            }
            else 
            {
                unscaledWidth = measuredWidth;
            }
			
            if (layoutHeightExplicitlySet) 
            {
                unscaledHeight = _height;
            }
            else if (!Math.isNaN(explicitHeight)) 
            {
                unscaledHeight = explicitHeight;
            }
            else 
            {
                unscaledHeight = measuredHeight;
            }
			
            if (Math.isNaN(unscaledWidth)) 
                unscaledWidth = 0;
				
            if (Math.isNaN(unscaledHeight)) 
                unscaledHeight = 0;
				
            setActualSize(unscaledWidth, unscaledHeight);
            updateDisplayList(unscaledWidth, unscaledHeight);
            invalidateDisplayListFlag = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
    public function validateNow(skipDisplayList : Bool = false) : Void
    {
        if (!validateNowFlag && FlexLiteGlobals.layoutManager != null) 
            FlexLiteGlobals.layoutManager.validateClient(this, skipDisplayList)
        else 
			validateNowFlag = true;
    }
	
	/**
	* @inheritDoc
	*/
    public function setLayoutBoundsSize(layoutWidth : Float, layoutHeight : Float) : Void
    {
        if (Math.isNaN(layoutWidth)) 
        {
            layoutWidthExplicitlySet = false;
            layoutWidth = preferredWidth;
        }
        else 
        {
            layoutWidthExplicitlySet = true;
        }
		
        if (Math.isNaN(layoutHeight)) 
        {
            layoutHeightExplicitlySet = false;
            layoutHeight = preferredHeight;
        }
        else 
        {
            layoutHeightExplicitlySet = true;
        }
        
        setActualSize(layoutWidth / this.scaleX, layoutHeight / this.scaleY);
    }
	
    /**
	* @inheritDoc
	*/
    public function setLayoutBoundsPosition(x : Float, y : Float) : Void
    {
        if (this.scaleX < 0)
		{
            x += this.layoutBoundsWidth;
        }
        if (this.scaleY < 0) 
		{
            y += this.layoutBoundsHeight;
        }
        var changed : Bool = false;
        if (this.x != x) 
        {
            super.x = x;
            changed = true;
        }
        if (this.y != y) 
        {
            super.y = y;
            changed = true;
        }
        if (changed) 
        {
            dispatchMoveEvent();
        }
    }
	
	/**
	* 添加对象到显示列表,此接口仅预留给框架内部使用
	* 如果需要管理子项，若有，请使用容器的addElement()方法，非法使用有可能造成无法自动布局。
	*/
    @:final public function addToDisplayList(child : DisplayObject) : DisplayObject
    {
        addingChild(child);
        super.addChild(child);
        childAdded(child);
        return child;
    }
    /**
	* 添加对象到显示列表,此接口仅预留给框架内部使用
	* 如果需要管理子项，若有，请使用容器的addElementAt()方法，非法使用有可能造成无法自动布局。
	*/
    @:final public function addToDisplayListAt(child : DisplayObject, index : Int) : DisplayObject
    {
        addingChild(child);
        super.addChildAt(child, index);
        childAdded(child);
        return child;
    }
    /**
	* 添加对象到显示列表,此接口仅预留给框架内部使用
	* 如果需要管理子项，若有，请使用容器的removeElement()方法,非法使用有可能造成无法自动布局。
	*/
    @:final public function removeFromDisplayList(child : DisplayObject) : DisplayObject
    {
        super.removeChild(child);
        childRemoved(child);
        return child;
    }
    /**
	* 从显示列表移除指定索引的子项,此接口仅预留给框架内部使用
	* 如果需要管理子项，若有，请使用容器的removeElementAt()方法,非法使用有可能造成无法自动布局。
	*/
    @:final public function removeFromDisplayListAt(index : Int) : DisplayObject
    {
        var child : DisplayObject = super.removeChildAt(index);
        childRemoved(child);
        return child;
    }
    
    
	//框架范围内不允许调用任何addChild，需要普通显示对象包装器，请使用UIAsset。  
    /**
	* @inheritDoc
	*/
	@:meta(Deprecated())
    override public function addChild(child : DisplayObject) : DisplayObject
    {
        addingChild(child);
        super.addChild(child);
        childAdded(child);
        return child;
    }
    

    /**
	* @inheritDoc
	*/
	@:meta(Deprecated())
    override public function addChildAt(child : DisplayObject, index : Int) : DisplayObject
    {
        addingChild(child);
        super.addChildAt(child, index);
        childAdded(child);
        return child;
    }
	
	/**
	* @inheritDoc
	*/
	@:meta(Deprecated())
    override public function removeChild(child : DisplayObject) : DisplayObject
    {
        super.removeChild(child);
        childRemoved(child);
        return child;
    }
    

    /**
	* @inheritDoc
	*/
	@:meta(Deprecated())
    override public function removeChildAt(index : Int) : DisplayObject
    {
        var child : DisplayObject = super.removeChildAt(index);
        childRemoved(child);
        return child;
    }
    
    /**
	* 添加到舞台
	*/
    private function onAddedToStage(e : Event) : Void
    {
        this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        initialize();
        FlexLiteGlobals.initlize(stage);
        if (_nestLevel > 0) 
            checkInvalidateFlag();
    }
    
    
    private function get_id() : String
    {
        return _id;
    }
    
    private function set_id(value : String) : String
    {
        return _id = value;
    }
    
    private function get_toolTip() : Dynamic
    {
        return _toolTip;
    }
    private function set_toolTip(value : Dynamic) : Dynamic
    {
        if (value == _toolTip) 
            return value;
			
        var oldValue : Dynamic = _toolTip;
        _toolTip = value;
        
        ToolTipManager.registerToolTip(this, oldValue, value);
        
        dispatchEvent(new Event("toolTipChanged"));
        return value;
    }
    
    private function get_toolTipClass() : Class<IToolTip>
    {
        return _toolTipClass;
    }
    private function set_toolTipClass(value : Class<IToolTip>) : Class<IToolTip>
    {
        if (value == _toolTipClass) 
            return value;
        return _toolTipClass = value;
    }
    
    private function get_toolTipOffset() : Point
    {
        return _toolTipOffset;
    }
    
    private function set_toolTipOffset(value : Point) : Point
    {
        _toolTipOffset = value;
        return value;
    }
    
    private function get_toolTipPosition() : String
    {
        return _toolTipPosition;
    }
    
    private function set_toolTipPosition(value : String) : String
    {
        return _toolTipPosition = value;
    }
    
    private function get_isPopUp() : Bool
    {
        return _isPopUp;
    }
    private function set_isPopUp(value : Bool) : Bool
    {
        return _isPopUp = value;
    }
    
    private function get_owner() : Dynamic
    {
        return _owner != null ? _owner : parent;
    }
    
    private function get_systemManager() : ISystemManager
    {
        if (_systemManager == null) 
        {
            if (Std.is(this, ISystemManager)) 
            {
                _systemManager = Lib.as(this, ISystemManager);
            }
            else 
            {
                var o : DisplayObjectContainer = parent;
                while (o != null)
                {
                    var ui : IUIComponent = Lib.as(o, IUIComponent);
                    if (ui != null) 
                    {
                        _systemManager = ui.systemManager;
                        break;
                    }
                    else if (Std.is(o, ISystemManager)) 
                    {
                        _systemManager = Lib.as(o, ISystemManager);
                        break;
                    }
                    o = o.parent;
                }
            }
        }
        return _systemManager;
    }
    private function set_systemManager(value : ISystemManager) : ISystemManager
    {
        _systemManager = value;
        var length : Int = numChildren;
        for (i in 0...length)
		{
            var ui : IUIComponent = Lib.as(getChildAt(i), IUIComponent);
            if (ui != null) 
                ui.systemManager = value;
        }
        return value;
    }
    
    private function get_updateCompletePendingFlag() : Bool
    {
        return _updateCompletePendingFlag;
    }
    private function set_updateCompletePendingFlag(value : Bool) : Bool
    {
        _updateCompletePendingFlag = value;
        return value;
    }
    
    private function get_initialized() : Bool
    {
        return _initialized;
    }
    private function set_initialized(value : Bool) : Bool
    {
        if (_initialized == value) 
            return value;
        _initialized = value;
        if (value) 
        {
            dispatchEvent(new UIEvent(UIEvent.CREATION_COMPLETE));
        }
        return value;
    }
	
	
    /**
	* 初始化组件
	*/
    private function initialize() : Void
    {
        if (initializeCalled) 
            return;
        if (FlexLiteGlobals.stage != null) 
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        initializeCalled = true;
        dispatchEvent(new UIEvent(UIEvent.INITIALIZE));
        createChildren();
        childrenCreated();
    }
	
    /**
	* 创建子项,子类覆盖此方法以完成组件子项的初始化操作，
	* 请务必调用super.createChildren()以完成父类组件的初始化
	*/
    private function createChildren() : Void
    {
        
    }
	
    /**
	* 子项创建完成
	*/
    private function childrenCreated() : Void
    {
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    
    /**
	* @inheritDoc
	*/
    private function get_nestLevel() : Int
    {
        return _nestLevel;
    }
    
    private function set_nestLevel(value : Int) : Int
    {
        if (_nestLevel == value) 
            return value;
        _nestLevel = value;
        
        if (_nestLevel == 0) 
            addEventListener(Event.ADDED_TO_STAGE, checkInvalidateFlag)
        else 
			removeEventListener(Event.ADDED_TO_STAGE, checkInvalidateFlag);
        
        var i : Int = numChildren - 1;
        while (i >= 0)
		{
            var child : ILayoutManagerClient = Lib.as(getChildAt(i), ILayoutManagerClient);
            if (child != null) 
            {
                child.nestLevel = _nestLevel + 1;
            }
            i--;
        }
        return value;
    }
    
    
    
    /**
	* 即将添加一个子项
	*/
    private function addingChild(child : DisplayObject) : Void
    {
        if (Std.is(child, ILayoutManagerClient)) 
        {
            Lib.as(child, ILayoutManagerClient).nestLevel = _nestLevel + 1;
        }
        if (Std.is(child, InteractiveObject)) 
        {
            if (doubleClickEnabled) 
                cast(child, InteractiveObject).doubleClickEnabled = true;
        }
    }
    
    /**
	* 已经添加一个子项
	*/
    private function childAdded(child : DisplayObject) : Void
    {
        if (Std.is(child, UIComponent)) 
        {
            cast(child, UIComponent).initialize();
            cast(child, UIComponent).checkInvalidateFlag();
        }
    }
    
    /**
	* 已经移除一个子项
	*/
    private function childRemoved(child : DisplayObject) : Void
    {
        if (Std.is(child, ILayoutManagerClient)) 
        {
            Lib.as(child, ILayoutManagerClient).nestLevel = 0;
        }
        if (Std.is(child, IUIComponent)) 
        {
            Lib.as(child, IUIComponent).systemManager = null;
        }
    }
    
    /**
	* 检查属性失效标记并应用
	*/
    private function checkInvalidateFlag(event : Event = null) : Void
    {
        if (FlexLiteGlobals.layoutManager == null) 
            return;
			
        if (invalidatePropertiesFlag) 
        {
            FlexLiteGlobals.layoutManager.invalidateProperties(this);
        }
        if (invalidateSizeFlag) 
        {
            FlexLiteGlobals.layoutManager.invalidateSize(this);
        }
        if (invalidateDisplayListFlag) 
        {
            FlexLiteGlobals.layoutManager.invalidateDisplayList(this);
        }
        if (validateNowFlag) 
        {
            FlexLiteGlobals.layoutManager.validateClient(this);
            validateNowFlag = false;
        }
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:getter(doubleClickEnabled) 
	#else
	override 
	#end
     private function get_doubleClickEnabled() : Bool
    {
        return super.doubleClickEnabled;
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(doubleClickEnabled) private function set_doubleClickEnabled(value : Bool) : Void
    {
        super.doubleClickEnabled = value;
        
        for (i in 0...numChildren)
		{
            var child : InteractiveObject = Lib.as(getChildAt(i), InteractiveObject);
            if (child != null) 
                child.doubleClickEnabled = value;
        }
    }
	#else
	override private function set_doubleClickEnabled(value : Bool) : Bool
    {
        super.doubleClickEnabled = value;
        
        for (i in 0...numChildren)
		{
            var child : InteractiveObject = Lib.as(getChildAt(i), InteractiveObject);
            if (child != null) 
                child.doubleClickEnabled = value;
        }
        return value;
    }
	#end
     
    
    /**
	* @inheritDoc
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
        dispatchEvent(new Event("enabledChanged"));
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_explicitWidth() : Float
    {
        return _explicitWidth;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_explicitHeight() : Float
    {
        return _explicitHeight;
    }
	
    /**
	* 组件宽度,默认值为NaN,设置为NaN将使用组件的measure()方法自动计算尺寸
	*/
	#if flash
	@:setter(width) private function set_width(value : Float) : Void
    {
        if (_width == value && _explicitWidth == value) 
            return ;
        _width = value;
        _explicitWidth = value;
        invalidateProperties();
        invalidateDisplayList();
        invalidateParentSizeAndDisplayList();
        if (Math.isNaN(value)) 
            invalidateSize();
    }
	#else
	override private function set_width(value : Float) : Float
    {
        if (_width == value && _explicitWidth == value) 
            return value;
        _width = value;
        _explicitWidth = value;
        invalidateProperties();
        invalidateDisplayList();
        invalidateParentSizeAndDisplayList();
        if (Math.isNaN(value)) 
            invalidateSize();
        return value;
    }
	#end
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:getter(width) 
	#else
	override 
	#end
     private function get_width() : Float
    {
        return MathUtil.escapeNaN(_width);
    }
    
    /**
	* 组件高度,默认值为NaN,设置为NaN将使用组件的measure()方法自动计算尺寸
	*/
	#if flash
	@:setter(height) private function set_height(value : Float) : Void
    {
        if (_height == value && _explicitHeight == value) 
            return;
        _height = value;
        _explicitHeight = value;
        invalidateProperties();
        invalidateDisplayList();
        invalidateParentSizeAndDisplayList();
        if (Math.isNaN(value)) 
            invalidateSize();
    }
	#else
	override private function set_height(value : Float) : Float
    {
        if (_height == value && _explicitHeight == value) 
            return value;
        _height = value;
        _explicitHeight = value;
        invalidateProperties();
        invalidateDisplayList();
        invalidateParentSizeAndDisplayList();
        if (Math.isNaN(value)) 
            invalidateSize();
        return value;
    }
	#end
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:getter(height) 
	#else
	override 
	#end
     private function get_height() : Float
    {
        return MathUtil.escapeNaN(_height);
    }
	
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(scaleX) private function set_scaleX(value : Float) : Void
    {
        if (super.scaleX == value) 
            return;
        super.scaleX = value;
        invalidateParentSizeAndDisplayList();
    }
	#else
	override private function set_scaleX(value : Float) : Float
    {
        if (super.scaleX == value) 
            return value;
        super.scaleX = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
	#end

    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(scaleY) private function set_scaleY(value : Float) : Void
    {
        if (super.scaleY == value) 
            return;
        super.scaleY = value;
        invalidateParentSizeAndDisplayList();
    }
	#else
	override private function set_scaleY(value : Float) : Float
    {
        if (super.scaleY == value) 
            return value;
        super.scaleY = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
	#end
     
    
    
    /**
	* @inheritDoc
	*/
    private function get_minWidth() : Float
    {
        return _minWidth;
    }
    private function set_minWidth(value : Float) : Float
    {
        if (_minWidth == value) 
            return value;
        _minWidth = value;
        invalidateSize();
        return value;
    }
	
    
    /**
	* @inheritDoc
	*/
    private function get_maxWidth() : Float
    {
        return _maxWidth;
    }
    private function set_maxWidth(value : Float) : Float
    {
        if (_maxWidth == value) 
            return value;
        _maxWidth = value;
        invalidateSize();
        return value;
    }
    
	
    /**
	* @inheritDoc
	*/
    private function get_minHeight() : Float
    {
        return _minHeight;
    }
    private function set_minHeight(value : Float) : Float
    {
        if (_minHeight == value) 
            return value;
        _minHeight = value;
        invalidateSize();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_maxHeight() : Float
    {
        return _maxHeight;
    }
    private function set_maxHeight(value : Float) : Float
    {
        if (_maxHeight == value) 
            return value;
        _maxHeight = value;
        invalidateSize();
        return value;
    }
    
    
    
    /**
	* 组件的默认宽度（以像素为单位）。此值由 measure() 方法设置。
	*/
    private function get_measuredWidth() : Float
    {
        return _measuredWidth;
    }
    private function set_measuredWidth(value : Float) : Float
    {
        _measuredWidth = value;
        return value;
    }
    
    /**
	* 组件的默认高度（以像素为单位）。此值由 measure() 方法设置。
	*/
    private function get_measuredHeight() : Float
    {
        return _measuredHeight;
    }
    private function set_measuredHeight(value : Float) : Float
    {
        _measuredHeight = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(x) private function set_x(value : Float) : Void
    {
        if (x == value) 
            return;
        super.x = value;
        invalidateProperties();
        if (_includeInLayout && parent != null && Std.is(parent, UIComponent)) 
            cast(parent, UIComponent).childXYChanged();
    }
	#else
	override private function set_x(value : Float) : Float
    {
        if (x == value) 
            return value;
        super.x = value;
        invalidateProperties();
        if (_includeInLayout && parent != null && Std.is(parent, UIComponent)) 
            cast(parent, UIComponent).childXYChanged();
        return value;
    }
	#end
    
    
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(y) private function set_y(value : Float) : Void
    {
        if (y == value) 
            return;
        super.y = value;
        invalidateProperties();
        if (_includeInLayout && parent != null && Std.is(parent, UIComponent)) 
            cast((parent), UIComponent).childXYChanged();
    }
	#else
	override private function set_y(value : Float) : Float
    {
        if (y == value) 
            return value;
        super.y = value;
        invalidateProperties();
        if (_includeInLayout && parent != null && Std.is(parent, UIComponent)) 
            cast((parent), UIComponent).childXYChanged();
        return value;
    }
	#end
     
    
    
	
	
    /**
	* 测量组件尺寸，返回尺寸是否发生变化
	*/
    private function measureSizes() : Bool
    {
        var changed : Bool = false;
        
        if (!invalidateSizeFlag) 
            return changed;
        
        if (!canSkipMeasurement()) 
        {
            measure();
            if (measuredWidth < minWidth) 
            {
                measuredWidth = minWidth;
            }
            if (measuredWidth > maxWidth) 
            {
                measuredWidth = maxWidth;
            }
            if (measuredHeight < minHeight) 
            {
                measuredHeight = minHeight;
            }
            if (measuredHeight > maxHeight) 
            {
                measuredHeight = maxHeight;
            }
        }
        if (Math.isNaN(oldPreferWidth)) 
        {
            oldPreferWidth = preferredWidth;
            oldPreferHeight = preferredHeight;
            changed = true;
        }
        else 
        {
            if (preferredWidth != oldPreferWidth || preferredHeight != oldPreferHeight) 
                changed = true;
            oldPreferWidth = preferredWidth;
            oldPreferHeight = preferredHeight;
        }
        return changed;
    }
    
	
    
    
    /**
	* 标记父级容器的尺寸和显示列表为失效
	*/
    private function invalidateParentSizeAndDisplayList() : Void
    {
        if (parent == null || !_includeInLayout) 
            return;
			
		if (!Std.is(parent, IInvalidating))
		{
			return;
		}
		
        var p : IInvalidating = Lib.as(parent, IInvalidating);
        if (p == null) 
            return;
        p.invalidateSize();
        p.invalidateDisplayList();
    }
    
    /**
	* 更新显示列表
	*/
    private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        
    }
    
    /**
	* 是否可以跳过测量尺寸阶段,返回true则不执行measure()方法
	*/
    private function canSkipMeasurement() : Bool
    {
        return !Math.isNaN(_explicitWidth) && !Math.isNaN(_explicitHeight);
    }
    
    /**
	* 提交属性，子类在调用完invalidateProperties()方法后，应覆盖此方法以应用属性
	*/
    private function commitProperties() : Void
    {
        if (oldWidth != _width || oldHeight != _height) 
        {
            dispatchResizeEvent();
        }
        if (oldX != x || oldY != y) 
        {
            dispatchMoveEvent();
        }
    }
    /**
	* 测量组件尺寸
	*/
    private function measure() : Void
    {
        _measuredHeight = 0;
        _measuredWidth = 0;
    }
    /**
	*  抛出移动事件
	*/
    private function dispatchMoveEvent() : Void
    {
        if (hasEventListener(MoveEvent.MOVE)) 
        {
            var moveEvent : MoveEvent = new MoveEvent(MoveEvent.MOVE, oldX, oldY);
            dispatchEvent(moveEvent);
        }
        oldX = x;
        oldY = y;
    }
    
    /**
	* 子项的xy位置发生改变
	*/
    private function childXYChanged() : Void
    {
        
        
    }
    
    /**
	*  抛出尺寸改变事件
	*/
    private function dispatchResizeEvent() : Void
    {
        if (hasEventListener(ResizeEvent.RESIZE)) 
        {
            var resizeEvent : ResizeEvent = new ResizeEvent(ResizeEvent.RESIZE, oldWidth, oldHeight);
            dispatchEvent(resizeEvent);
        }
        oldWidth = _width;
        oldHeight = _height;
    }
    
    /**
	* 抛出属性值改变事件
	* @param prop 改变的属性名
	* @param oldValue 属性的原始值
	* @param value 属性的新值
	*/
    private function dispatchPropertyChangeEvent(prop : String, oldValue : Dynamic,
            value : Dynamic) : Void
    {
        if (hasEventListener("propertyChange")) 
            dispatchEvent(PropertyChangeEvent.createUpdateEvent(
                        this, prop, oldValue, value));
    }
    
	
    /**
	* @inheritDoc
	*/
    private function get_includeInLayout() : Bool
    {
        return _includeInLayout;
    }
    private function set_includeInLayout(value : Bool) : Bool
    {
        if (_includeInLayout == value) 
            return value;
        _includeInLayout = true;
        invalidateParentSizeAndDisplayList();
        _includeInLayout = value;
        return value;
    }
    
    
    
    /**
	* @inheritDoc
	*/
    private function get_left() : Float
    {
        return _left;
    }
    private function set_left(value : Float) : Float
    {
        if (_left == value) 
            return value;
        _left = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
	
    /**
	* @inheritDoc
	*/
    private function get_right() : Float
    {
        return _right;
    }
    private function set_right(value : Float) : Float
    {
        if (_right == value) 
            return value;
        _right = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_top() : Float
    {
        return _top;
    }
    private function set_top(value : Float) : Float
    {
        if (_top == value) 
            return value;
        _top = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_bottom() : Float
    {
        return _bottom;
    }
    private function set_bottom(value : Float) : Float
    {
        if (_bottom == value) 
            return value;
        _bottom = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* @inheritDoc
	*/
    private function get_horizontalCenter() : Float
    {
        return _horizontalCenter;
    }
    private function set_horizontalCenter(value : Float) : Float
    {
        if (_horizontalCenter == value) 
            return value;
        _horizontalCenter = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_verticalCenter() : Float
    {
        return _verticalCenter;
    }
    private function set_verticalCenter(value : Float) : Float
    {
        if (_verticalCenter == value) 
            return value;
        _verticalCenter = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
    
    /**
	* @inheritDoc
	*/
    private function get_percentWidth() : Float
    {
        return _percentWidth;
    }
    private function set_percentWidth(value : Float) : Float
    {
        if (_percentWidth == value) 
            return value;
        _percentWidth = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
    
    
    /**
	* @inheritDoc
	*/
    private function get_percentHeight() : Float
    {
        return _percentHeight;
    }
    private function set_percentHeight(value : Float) : Float
    {
        if (_percentHeight == value) 
            return value;
        _percentHeight = value;
        invalidateParentSizeAndDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_preferredWidth() : Float
    {
        var w : Float = (Math.isNaN(_explicitWidth)) ? measuredWidth : _explicitWidth;
        if (Math.isNaN(w)) 
            return 0;
        var scaleX : Float = this.scaleX;
        if (scaleX < 0) 
		{
            scaleX = -scaleX;
        }
        return w * scaleX;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_preferredHeight() : Float
    {
        var h : Float = (Math.isNaN(_explicitHeight)) ? measuredHeight : _explicitHeight;
        if (Math.isNaN(h)) 
            return 0;
        var scaleY : Float = this.scaleY;
        if (scaleY < 0) 
        {
            scaleY = -scaleY;
        }
        return h * scaleY;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_preferredX() : Float
    {
        if (scaleX >= 0) 
            return super.x;
        return super.x - preferredWidth;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_preferredY() : Float
    {
        if (scaleY >= 0) 
            return super.y;
        return super.y - preferredHeight;
    }
    /**
	* @inheritDoc
	*/
    private function get_layoutBoundsX() : Float
    {
        if (scaleX > 0) 
            return super.x;
        return super.x - layoutBoundsWidth;
    }
    /**
	* @inheritDoc
	*/
    private function get_layoutBoundsY() : Float
    {
        if (scaleY >= 0) 
        {
            return super.y;
        }
        return super.y - layoutBoundsHeight;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_layoutBoundsWidth() : Float
    {
        var scaleX : Float = this.scaleX;
        if (scaleX < 0)
		{
            scaleX = -scaleX;
        }
        var w : Float = 0;
        if (layoutWidthExplicitlySet) 
        {
            w = _width;
        }
        else if (!Math.isNaN(explicitWidth)) 
        {
            w = _explicitWidth;
        }
        else 
        {
            w = measuredWidth;
        }
        return MathUtil.escapeNaN(w * scaleX);
    }
    /**
	* 组件的布局高度,常用于父级的updateDisplayList()方法中
	* 按照：布局高度>外部显式设置高度>测量高度 的优先级顺序返回高度
	*/
    private function get_layoutBoundsHeight() : Float
    {
        var scaleY : Float = this.scaleY;
        if (scaleY < 0) 
        {
            scaleY = -scaleY;
        }
        var h : Float = 0;
        if (layoutHeightExplicitlySet) 
        {
            h = _height;
        }
        else if (!Math.isNaN(explicitHeight)) 
        {
            h = _explicitHeight;
        }
        else 
        {
            h = measuredHeight;
        }
        return MathUtil.escapeNaN(h * scaleY);
    }
    
	
    /**
	* @inheritDoc
	*/
    private function get_focusEnabled() : Bool
    {
        return _focusEnabled;
    }
    private function set_focusEnabled(value : Bool) : Bool
    {
        return _focusEnabled = value;
    }
	
	public function dispose():Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        removeEventListener(Event.ADDED_TO_STAGE, checkInvalidateFlag);
	}
    
}
