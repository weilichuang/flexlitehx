package flexlite.components;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.Lib;
import flexlite.components.supportclasses.SkinBasicLayout;
import flexlite.components.UIAsset;
import flexlite.core.Injector;
import flexlite.core.ISkin;
import flexlite.core.IStateClient;
import flexlite.core.Theme;
import flexlite.events.SkinPartEvent;
import flexlite.utils.SkinPartUtil;

/**
* 皮肤部件附加事件 
*/
@:meta(Event(name="partAdded",type="flexlite.events.SkinPartEvent"))

/**
* 皮肤部件卸载事件 
*/
@:meta(Event(name="partRemoved",type="flexlite.events.SkinPartEvent"))


@:meta(DXML(show="false"))


@:meta(SkinState(name="normal"))

@:meta(SkinState(name="disabled"))


/**
* 复杂可设置外观组件的基类，接受ISkin类或任何显示对象作为皮肤。
* 当皮肤为ISkin时，将自动匹配两个实例内同名的公开属性(显示对象)，
* 并将皮肤的属性引用赋值到此类定义的同名属性(必须没有默认值)上,
* 如果要对公共属性添加事件监听或其他操作，
* 请覆盖partAdded()和partRemoved()方法
* @author weilichuang
*/
class SkinnableComponent extends UIAsset
{
	/**
	* 在皮肤注入管理器里标识自身的默认键，可以是类定义，实例，或者是完全限定类名。
	* 子类覆盖此方法，用于获取注入的缺省skinName。
	*/
    public var hostComponentKey(get, never) : Dynamic;
	
	/**
	* 存储皮肤适配器解析skinName得到的原始皮肤对象，包括非显示对象皮肤的实例。
	*/
    public var skinObject(get, never) : Dynamic;
	
	/**
	* 在enabled属性发生改变时是否自动开启或禁用鼠标事件的响应。默认值为true。
	*/
    public var autoMouseEnabled(get, set) : Bool;
	
	/**
	* 启用或禁用组件自身的布局。通常用在当组件的皮肤不是ISkinPartHost，又需要自己创建子项并布局时。
	*/
    public var skinLayoutEnabled(never, set) : Bool;
	
	
	/**
	* 灰度滤镜
	*/
    private static var grayFilters : Array<BitmapFilter> = [new ColorMatrixFilter([0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1])];
	
	private var stateIsDirty : Bool = false;
    /**
	* 旧的滤镜列表
	*/
    private var oldFilters : Array<BitmapFilter>;
    /**
	* 被替换过灰色滤镜的标志
	*/
    private var grayFilterIsSet : Bool = false;
	
	/**
	* 由组件自身创建了SkinPart的标志
	*/
    private var hasCreatedSkinParts : Bool = false;
	
	private var _skinObject : Dynamic = null;
	
	private var _autoMouseEnabled : Bool = true;
	
	
    /**
	* 外部显式设置的mouseChildren属性值 
	*/
    private var explicitMouseChildren : Bool = true;
	
	/**
	* 外部显式设置的mouseEnabled属性值
	*/
    private var explicitMouseEnabled : Bool = true;
	
    private var skinLayout : SkinBasicLayout;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        mouseChildren = true;
    }
    
    /**
	* @inheritDoc
	*/
    override private function createChildren() : Void
    {
        if (defaultTheme == null) 
        {
            try
            {
                defaultTheme = Injector.getInstance(Theme);
            }            
			catch (e:String){ };
        }
		
        if (defaultTheme != null && skinName == null) 
        {
            skinName = defaultTheme.getSkinName(hostComponentKey);
            skinNameExplicitlySet = false;
        }
		
		 //让部分组件在没有皮肤的情况下创建默认的子部件。  
        if (skinName == null) 
        { 
            onGetSkin(null, null);
        }
        super.createChildren();
    }
	
    /**
	* 默认的皮肤解析适配器
	*/
    private static var defaultTheme : Theme;
    
    
    private function get_hostComponentKey() : Dynamic
    {
		return Type.getClass(this);
        //return SkinnableComponent;
    }
    
    
    
    private function get_skinObject() : Dynamic
    {
        return _skinObject;
    }
    
    /**
	* @inheritDoc
	*/
    override private function onGetSkin(skin : Dynamic, skinName : Dynamic) : Void
    {
        var oldSkin : Dynamic = _skinObject;
        detachSkin(oldSkin);
        if (_skin != null && _skin.parent == this) 
        {
			removeFromDisplayList(_skin);
        }
        
        if (Std.is(skin, DisplayObject)) 
        {
            _skin = Lib.as(skin, DisplayObject);
            addToDisplayListAt(_skin, 0);
        }
        else 
        {
            _skin = null;
        }
        _skinObject = skin;
        attachSkin(_skinObject);
        aspectRatio = Math.NaN;
        invalidateSkinState();
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
	* 附加皮肤
	*/
    private function attachSkin(skin : Dynamic) : Void
    {
        if (Std.is(skin, ISkin)) 
        {
            var newSkin : ISkin = Lib.as(skin, ISkin);
            newSkin.hostComponent = this;
            findSkinParts();
        }
        else 
        {
            if (!hasCreatedSkinParts) 
            {
                createSkinParts();
                hasCreatedSkinParts = true;
            }
        }
        if (Std.is(skin, ISkin) && Std.is(skin, DisplayObject)) 
            skinLayoutEnabled = false;
        else 
			skinLayoutEnabled = true;
    }
    /**
	* 匹配皮肤和主机组件的公共变量，并完成实例的注入。此方法在附加皮肤时会自动执行一次。
	* 若皮肤中含有延迟实例化的子部件，在子部件实例化完成时需要从外部再次调用此方法,完成注入。
	*/
    public function findSkinParts() : Void
    {
        var curSkin : Dynamic = _skinObject;
        if (curSkin == null || !(Std.is(curSkin, ISkin))) 
            return;
			
        var skinParts : Array<String> = SkinPartUtil.getSkinParts(this);
        for (partName in skinParts)
        {
            if (Reflect.hasField(curSkin, partName) && 
				Reflect.field(curSkin, partName) != null && 
				Reflect.field(this,partName) == null) 
            {
				var skinPart:Dynamic = Reflect.field(curSkin, partName);
				Reflect.setField(this, partName, skinPart);
				partAdded(partName, skinPart);
            }
        }
    }
    
    
    /**
	* 由组件自身来创建必要的SkinPart，通常是皮肤为空或皮肤不是ISkinPart时调用。
	*/
    private function createSkinParts() : Void
    {
        
    }
    /**
	* 删除组件自身创建的SkinPart
	*/
    private function removeSkinParts() : Void
    {
        
    }
    
    /**
	* 卸载皮肤
	*/
    private function detachSkin(skin : Dynamic) : Void
    {
        if (hasCreatedSkinParts) 
        {
            removeSkinParts();
            hasCreatedSkinParts = false;
        }
		
        if (Std.is(skin, ISkin)) 
        {
            var skinParts : Array<String> = SkinPartUtil.getSkinParts(this);
            for (partName in skinParts)
			{
				if (!Reflect.hasField(this,partName))
					continue;
				
				var part:Dynamic = Reflect.field(this, partName);
				if (part != null) 
				{
					partRemoved(partName, part);
				}
				
				Reflect.setField(this, partName, null);
			}
			Lib.as(skin, ISkin).hostComponent = null;
        }
    }
    
    /**
	* 若皮肤是ISkinPartHost,则调用此方法附加皮肤中的公共部件
	*/
    private function partAdded(partName : String, instance : Dynamic) : Void
    {
        var event : SkinPartEvent = new SkinPartEvent(SkinPartEvent.PART_ADDED);
        event.partName = partName;
        event.instance = instance;
        dispatchEvent(event);
    }
    /**
	* 若皮肤是ISkinPartHost，则调用此方法卸载皮肤之前注入的公共部件
	*/
    private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        var event : SkinPartEvent = new SkinPartEvent(SkinPartEvent.PART_REMOVED);
        event.partName = partName;
        event.instance = instance;
        dispatchEvent(event);
    }
    
    
    
    //========================皮肤视图状态=====================start=======================
    
    
    
    /**
	* 标记当前需要重新验证皮肤状态
	*/
    public function invalidateSkinState() : Void
    {
        if (stateIsDirty) 
            return;
        
        stateIsDirty = true;
        invalidateProperties();
    }
    
    
    
    /**
	* 子类覆盖此方法,应用当前的皮肤状态
	*/
    private function validateSkinState() : Void
    {
        var curState : String = getCurrentSkinState();
        var hasState : Bool = false;
        var curSkin : Dynamic = _skinObject;
        if (Std.is(curSkin, IStateClient)) 
        {
            Lib.as(curSkin, IStateClient).currentState = curState;
            hasState = Lib.as(curSkin, IStateClient).hasState(curState);
        }
		
        if (hasEventListener("stateChanged")) 
            dispatchEvent(new Event("stateChanged"));
			
        if (enabled) 
        {
            if (grayFilterIsSet) 
            {
                filters = oldFilters;
                oldFilters = null;
                grayFilterIsSet = false;
            }
        }
        else 
        {
            if (!hasState && !grayFilterIsSet) 
            {
                oldFilters = filters;
                filters = grayFilters;
                grayFilterIsSet = true;
            }
        }
    }
    
    
    
    private function get_autoMouseEnabled() : Bool
    {
        return _autoMouseEnabled;
    }
    
    private function set_autoMouseEnabled(value : Bool) : Bool
    {
        if (_autoMouseEnabled == value) 
            return value;
        _autoMouseEnabled = value;
        if (_autoMouseEnabled) 
        {
            super.mouseChildren = enabled ? explicitMouseChildren : false;
            super.mouseEnabled = enabled ? explicitMouseEnabled : false;
        }
        else 
        {
            super.mouseChildren = explicitMouseChildren;
            super.mouseEnabled = explicitMouseEnabled;
        }
        return value;
    }
    
	
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(mouseChildren) private function set_mouseChildren(value : Bool) : Void
    {
        if (enabled) 
            super.mouseChildren = value;
        explicitMouseChildren = value;
    }
	#else
	override private function set_mouseChildren(value : Bool) : Bool
    {
        if (enabled) 
            super.mouseChildren = value;
        return explicitMouseChildren = value;
    }
	#end
     
    
    /**
	* @inheritDoc
	*/
	#if flash
	@:setter(mouseEnabled) private function set_mouseEnabled(value : Bool) : Void
    {
        if (enabled) 
            super.mouseEnabled = value;
        explicitMouseEnabled = value;
    }
	#else
	override private function set_mouseEnabled(value : Bool) : Bool
    {
        if (enabled) 
            super.mouseEnabled = value;
        return explicitMouseEnabled = value;
    }
	#end
    
    
    /**
	* @inheritDoc
	*/
    override private function set_enabled(value : Bool) : Bool
    {
        if (super.enabled == value) 
            return value;
        super.enabled = value;
        if (_autoMouseEnabled) 
        {
            super.mouseChildren = (value) ? explicitMouseChildren : false;
            super.mouseEnabled = (value) ? explicitMouseEnabled : false;
        }
        invalidateSkinState();
        return value;
    }
    
    /**
	* 返回组件当前的皮肤状态名称,子类覆盖此方法定义各种状态名
	*/
    private function getCurrentSkinState() : String
    {
        return enabled ? "normal" : "disabled";
    }
    
    //========================皮肤视图状态===================end========================
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (stateIsDirty) 
        {
            stateIsDirty = false;
            validateSkinState();
        }
    }
    
	
    
    private function set_skinLayoutEnabled(value : Bool) : Bool
    {
        var hasLayout : Bool = (skinLayout != null);
        if (hasLayout == value) 
            return value;
        if (value) 
        {
            skinLayout = new SkinBasicLayout();
            skinLayout.target = this;
        }
        else 
        {
            skinLayout.target = null;
            skinLayout = null;
        }
        invalidateSize();
        invalidateDisplayList();
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function childXYChanged() : Void
    {
        if (skinLayout != null) 
        {
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function measure() : Void
    {
        super.measure();
        if (skinLayout != null) 
        {
            skinLayout.measure();
        }
		
        var skinObject : Dynamic = _skinObject;
        if (_skin == null && skinObject != null) 
        { 
			//为非显示对象的皮肤测量  
            var measuredW : Float = this.measuredWidth;
            var measuredH : Float = this.measuredHeight;
            try
            {
                if (!Math.isNaN(skinObject.width)) 
                    measuredW = Math.ceil(skinObject.width);
					
                if (!Math.isNaN(skinObject.height)) 
					measuredH = Math.ceil(skinObject.height);
					
                if (Reflect.hasField(skinObject,"minWidth") && measuredW < skinObject.minWidth) 
                {
                    measuredW = skinObject.minWidth;
                }
                if (Reflect.hasField(skinObject,"maxWidth") && measuredW > skinObject.maxWidth) 
                {
                    measuredW = skinObject.maxWidth;
                }
                if (Reflect.hasField(skinObject,"minHeight") && measuredH < skinObject.minHeight) 
                {
                    measuredH = skinObject.minHeight;
                }
                if (Reflect.hasField(skinObject,"maxHeight") && measuredH > skinObject.maxHeight) 
                {
                    measuredH = skinObject.maxHeight;
                }
                this.measuredWidth = measuredW;
                this.measuredHeight = measuredH;
            }   
			catch (e : String)
			{ 
				
			}
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        if (skinLayout != null) 
        {
            skinLayout.updateDisplayList(unscaledWidth, unscaledHeight);
        }
    }
}
