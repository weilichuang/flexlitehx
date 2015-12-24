package flexlite.components;

import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.Lib;

import flexlite.core.IBitmapAsset;
import flexlite.core.IInvalidateDisplay;
import flexlite.core.Injector;
import flexlite.components.supportclasses.DefaultSkinAdapter;
import flexlite.core.ILayoutElement;
import flexlite.core.ISkinAdapter;
import flexlite.core.ISkinnableClient;
import flexlite.core.UIComponent;
import flexlite.events.UIEvent;



/**
* 皮肤发生改变事件。当给skinName赋值之后，皮肤有可能是异步获取的，在赋值之前监听此事件，可以确保在皮肤解析完成时回调。
*/
@:meta(Event(name="skinChanged",type="flexlite.events.UIEvent"))


@:meta(DXML(show="true"))


/**
* 素材包装器。<p/>
* 注意：UIAsset仅在添skin时测量一次初始尺寸， 请不要在外部直接修改skin尺寸，
* 若做了引起skin尺寸发生变化的操作, 需手动调用UIAsset的invalidateSize()进行重新测量。
* @author weilichuang
*/
class UIAsset extends UIComponent implements ISkinnableClient
{
	private static inline var errorStr : String = "在此组件中不可用，若此组件为容器类，请使用";
	/**
	* 皮肤解析适配器
	*/
    private static var skinAdapter : ISkinAdapter;
    /**
	* 默认的皮肤解析适配器
	*/
    private static var defaultSkinAdapter : DefaultSkinAdapter;
	
	/**
	* 皮肤标识符。可以为Class,String,或DisplayObject实例等任意类型，具体规则由项目注入的素材适配器决定，
	* 适配器根据此属性值解析获取对应的显示对象，并赋值给skin属性。
	*/
    public var skinName(get, set) : Dynamic;
	
	/**
	* 显示对象皮肤。
	*/
    public var skin(get, never) : DisplayObject;
	
	/**
	* 是否保持皮肤的宽高比,默认为false。
	*/
    public var maintainAspectRatio(get, set) : Bool;
	
	/**
	* 是否缩放皮肤
	*/
    public var scaleSkin : Bool = true;
	
	/**
	* 外部显式设置了皮肤名
	*/
    public var skinNameExplicitlySet : Bool = false;
	
	private var skinNameChanged : Bool = false;
    
    private var _skinName : Dynamic;
	
	private var _skin : DisplayObject;
    private var createChildrenCalled : Bool = false;
    
    private var skinReused : Bool = false;
	
	private var _maintainAspectRatio : Bool = false;
    /**
	* 皮肤宽高比
	*/
    private var aspectRatio : Float = Math.NaN;

    public function new()
    {
        super();
        mouseChildren = false;
    }
    
    
    private function get_skinName() : Dynamic
    {
        return _skinName;
    }
    
    private function set_skinName(value : Dynamic) : Dynamic
    {
        if (_skinName == value) 
            return value;
			
        _skinName = value;
        skinNameExplicitlySet = true;
        if (createChildrenCalled) 
        {
            parseSkinName();
        }
        else 
        {
            skinNameChanged = true;
        }
        return value;
    }
    
    private function get_skin() : DisplayObject
    {
        return _skin;
    }
    
    /**
	* 皮肤适配器解析skinName后回调函数
	* @param skin 皮肤显示对象
	* @param skinName 皮肤标识符
	*/
    private function onGetSkin(skin : Dynamic, skinName : Dynamic) : Void
    {
		//如果皮肤是重用的，就不用执行添加和移除操作。
        if (_skin != skin)     
        {
            if (_skin != null && _skin.parent == this) 
            {
                removeFromDisplayList(_skin);
            }
            _skin = Lib.as(skin, DisplayObject);
            if (_skin != null) 
            {
                addToDisplayListAt(_skin, 0);
            }
        }
        aspectRatio = Math.NaN;
        invalidateSize();
        invalidateDisplayList();
        if (stage != null) 
            validateNow();
    }
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        super.createChildren();
        if (skinNameChanged) 
        {
            parseSkinName();
        }
        createChildrenCalled = true;
    }
    
    /**
	* 解析skinName
	*/
    private function parseSkinName() : Void
    {
        skinNameChanged = false;
        var adapter : ISkinAdapter = skinAdapter;
        if (adapter == null) 
        {
            try
            {
                adapter = skinAdapter = Injector.getInstance(ISkinAdapter);
            }            
			catch (e : String)
            {
                if (defaultSkinAdapter == null) 
                    defaultSkinAdapter = new DefaultSkinAdapter();
                adapter = defaultSkinAdapter;
            }
        }
        if (_skinName == null) 
        {
            skinChanged(null, _skinName);
        }
        else 
        {
            var reuseSkin : DisplayObject = skinReused ? null : _skin;
            skinReused = true;
            adapter.getSkin(_skinName, skinChanged, reuseSkin);
        }
    }
    /**
	* 皮肤发生改变
	*/
    private function skinChanged(skin : Dynamic, skinName : Dynamic) : Void
    {
        if (skinName != _skinName) 
            return;
        onGetSkin(skin, skinName);
        skinReused = false;
        if (hasEventListener(UIEvent.SKIN_CHANGED)) 
        {
            var event : UIEvent = new UIEvent(UIEvent.SKIN_CHANGED);
            dispatchEvent(event);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function measure() : Void
    {
        super.measure();
        if (_skin == null) 
            return;
        if (Std.is(_skin, ILayoutElement) && !Lib.as(_skin, ILayoutElement).includeInLayout) 
            return;
        var rect : Rectangle = getMeasuredSize();
        this.measuredWidth = rect.width;
        this.measuredHeight = rect.height;
    }
    
    /**
	* 获取测量大小
	*/
    private function getMeasuredSize() : Rectangle
    {
        var rect : Rectangle = new Rectangle();
        if (Std.is(_skin, ILayoutElement)) 
        {
            rect.width = Lib.as(_skin, ILayoutElement).preferredWidth;
            rect.height = Lib.as(_skin, ILayoutElement).preferredHeight;
        }
        else if (Std.is(_skin, IBitmapAsset)) 
        {
            rect.width = Lib.as(_skin, IBitmapAsset).measuredWidth;
            rect.height = Lib.as(_skin, IBitmapAsset).measuredHeight;
        }
        else 
        {
            var oldScaleX : Float = _skin.scaleX;
            var oldScaleY : Float = _skin.scaleY;
            _skin.scaleX = 1;
            _skin.scaleY = 1;
            rect.width = _skin.width;
            rect.height = _skin.height;
            _skin.scaleX = oldScaleX;
            _skin.scaleY = oldScaleY;
        }
        return rect;
    }
    
    
    
    private function get_maintainAspectRatio() : Bool
    {
        return _maintainAspectRatio;
    }
    
    private function set_maintainAspectRatio(value : Bool) : Bool
    {
        if (_maintainAspectRatio == value) 
            return value;
        _maintainAspectRatio = value;
        invalidateDisplayList();
        return value;
    }
    
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if (_skin != null && scaleSkin) 
        {
            if (_maintainAspectRatio) 
            {
                var layoutBoundsX : Float = 0;
                var layoutBoundsY : Float = 0;
                if (Math.isNaN(aspectRatio)) 
                {
                    var rect : Rectangle = getMeasuredSize();
                    if (rect.width == 0 || rect.height == 0) 
                        aspectRatio = 0;
                    else 
						aspectRatio = rect.width / rect.height;
                }
				
                if (aspectRatio > 0 && unscaledHeight > 0 && unscaledWidth > 0) 
                {
                    var ratio : Float = unscaledWidth / unscaledHeight;
                    if (ratio > aspectRatio) 
                    {
                        var newWidth : Float = unscaledHeight * aspectRatio;
                        layoutBoundsX = Math.round((unscaledWidth - newWidth) * 0.5);
                        unscaledWidth = newWidth;
                    }
                    else 
                    {
                        var newHeight : Float = unscaledWidth / aspectRatio;
                        layoutBoundsY = Math.round((unscaledHeight - newHeight) * 0.5);
                        unscaledHeight = newHeight;
                    }
                    
                    if (Std.is(_skin, ILayoutElement)) 
                    {
						var layoutElement:ILayoutElement = Lib.as(_skin, ILayoutElement);
                        if (layoutElement.includeInLayout) 
                        {
                            layoutElement.setLayoutBoundsPosition(layoutBoundsX, layoutBoundsY);
                        }
                    }
                    else 
                    {
                        _skin.x = layoutBoundsX;
                        _skin.y = layoutBoundsY;
                    }
                }
            }
            if (Std.is(_skin, ILayoutElement)) 
            {
				var layoutElement:ILayoutElement = Lib.as(_skin, ILayoutElement);
                if (layoutElement.includeInLayout) 
                {
                    layoutElement.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
                }
            }
            else 
            {
                _skin.width = unscaledWidth;
                _skin.height = unscaledHeight;
                if (Std.is(_skin, IInvalidateDisplay)) 
                    Lib.as(_skin, IInvalidateDisplay).validateNow();
            }
        }
    }
    
    /**
	* @copy flexlite.components.Group#addChild()
	*/
	@:meta(Deprecated())
    override public function addChild(child : DisplayObject) : DisplayObject
    {
        throw ("addChild()" + errorStr + "addElement()代替");
		return super.addChild(child);
    }
	
    
    /**
	* @copy flexlite.components.Group#addChildAt()
	*/
	@:meta(Deprecated())
    override public function addChildAt(child : DisplayObject, index : Int) : DisplayObject
    {
        throw ("addChildAt()" + errorStr + "addElementAt()代替");
		return super.addChildAt(child,index);
    }
	
    
    /**
	* @copy flexlite.components.Group#removeChild()
	*/
	@:meta(Deprecated())
    override public function removeChild(child : DisplayObject) : DisplayObject
    {
        throw ("removeChild()" + errorStr + "removeElement()代替");
		return super.removeChild(child);
    }
	
    
    /**
	* @copy flexlite.components.Group#removeChildAt()
	*/
	@:meta(Deprecated())
    override public function removeChildAt(index : Int) : DisplayObject
    {
        throw ("removeChildAt()" + errorStr + "removeElementAt()代替");
		return super.removeChildAt(index);
    }
	
    
    /**
	* @copy flexlite.components.Group#setChildIndex()
	*/
	@:meta(Deprecated())
    override public function setChildIndex(child : DisplayObject, index : Int) : Void
    {
        throw ("setChildIndex()" + errorStr + "setElementIndex()代替");
    }
	
    
    /**
	* @copy flexlite.components.Group#swapChildren()
	*/
	@:meta(Deprecated())
    override public function swapChildren(child1 : DisplayObject, child2 : DisplayObject) : Void
    {
        throw ("swapChildren()" + errorStr + "swapElements()代替");
    }
	
    
    /**
	* @copy flexlite.components.Group#swapChildrenAt()
	*/
	@:meta(Deprecated())
    override public function swapChildrenAt(index1 : Int, index2 : Int) : Void
    {
        throw ("swapChildrenAt()" + errorStr + "swapElementsAt()代替");
    }
}
