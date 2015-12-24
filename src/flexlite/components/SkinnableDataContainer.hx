package flexlite.components;



import flash.Lib;
import flexlite.collections.ICollection;
import flexlite.core.IVisualElement;
import flexlite.events.RendererExistenceEvent;
import flexlite.layouts.VerticalLayout;
import flexlite.layouts.supportclasses.LayoutBase;



/**
* 添加了项呈示器 
*/
@:meta(Event(name="rendererAdd",type="flexlite.events.RendererExistenceEvent"))

/**
* 移除了项呈示器 
*/
@:meta(Event(name="rendererRemove",type="flexlite.events.RendererExistenceEvent"))


@:meta(DXML(show="true"))


@:meta(DefaultProperty(name="dataProvider",array="false"))


/**
* 可设置外观的数据项目容器基类
* @author weilichuang
*/
class SkinnableDataContainer extends SkinnableComponent implements IItemRendererOwner
{
    public var dataProvider(get, set) : ICollection;
    public var itemRenderer(get, set) : Class<Dynamic>;
    public var itemRendererSkinName(get, set) : Dynamic;
    public var itemRendererFunction(get, set) : Dynamic->Class<Dynamic>;
    public var layout(get, set) : LayoutBase;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return SkinnableDataContainer;
    }
    /**
	* @inheritDoc
	*/
    public function updateRenderer(renderer : IItemRenderer, itemIndex : Int, data : Dynamic) : IItemRenderer
    {
        if (Std.is(renderer, IVisualElement)) 
        {
            Lib.as(renderer, IVisualElement).ownerChanged(this);
        }
        renderer.itemIndex = itemIndex;
        renderer.label = itemToLabel(data);
        renderer.data = data;
        return renderer;
    }
    
    /**
	* 返回可在项呈示器中显示的 String 
	*/
    public function itemToLabel(item : Dynamic) : String
    {
        if (item != null) 
            return Std.string(item)
        else return " ";
    }
    
    /**
	* [SkinPart]数据项目容器实体
	*/
	@SkinPart
    public var dataGroup : DataGroup;
    /**
	* dataGroup发生改变时传递的参数 
	*/
    private var dataGroupProperties : Dynamic = { };
    
    /**
	* 列表数据源，请使用实现了ICollection接口的数据类型，例如ArrayCollection
	*/
    private function get_dataProvider() : ICollection
    {
        return dataGroup != (null) ? dataGroup.dataProvider : dataGroupProperties.dataProvider;
    }
    
    private function set_dataProvider(value : ICollection) : ICollection
    {
        if (dataGroup == null) 
        {
            dataGroupProperties.dataProvider = value;
        }
        else 
        {
            dataGroup.dataProvider = value;
            dataGroupProperties.dataProvider = true;
        }
        return value;
    }
    
    /**
	* 用于数据项目的项呈示器。该类必须实现 IItemRenderer 接口。 <br/>
	* rendererClass获取顺序：itemRendererFunction > itemRenderer > 默认ItemRenerer。
	*/
    private function get_itemRenderer() : Class<Dynamic>
    {
        return ((dataGroup != null)) ? dataGroup.itemRenderer : dataGroupProperties.itemRenderer;
    }
    
    private function set_itemRenderer(value : Class<Dynamic>) : Class<Dynamic>
    {
        if (dataGroup == null) 
        {
            dataGroupProperties.itemRenderer = value;
        }
        else 
        {
            dataGroup.itemRenderer = value;
            dataGroupProperties.itemRenderer = true;
        }
        return value;
    }
    
    /**
	* 条目渲染器的可选皮肤标识符。在实例化itemRenderer时，若其内部没有设置过skinName,则将此属性的值赋值给它的skinName。
	* 注意:若itemRenderer不是ISkinnableClient，则此属性无效。
	*/
    private function get_itemRendererSkinName() : Dynamic
    {
        return ((dataGroup != null)) ? dataGroup.itemRendererSkinName : dataGroupProperties.itemRendererSkinName;
    }
    
    private function set_itemRendererSkinName(value : Dynamic) : Dynamic
    {
        if (dataGroup == null) 
        {
            dataGroupProperties.itemRendererSkinName = value;
        }
        else 
        {
            dataGroup.itemRendererSkinName = value;
            dataGroupProperties.itemRendererSkinName = true;
        }
        return value;
    }
    
    /**
	* 为某个特定项目返回一个项呈示器Class的函数。 <br/>
	* rendererClass获取顺序：itemRendererFunction > itemRenderer > 默认ItemRenerer。 <br/>
	* 应该定义一个与此示例函数类似的呈示器函数： <br/>
	* function myItemRendererFunction(item:Object):Class
	*/
    private function get_itemRendererFunction() : Dynamic->Class<Dynamic>
    {
        return ((dataGroup != null)) ? dataGroup.itemRendererFunction : dataGroupProperties.itemRendererFunction;
    }
    
    private function set_itemRendererFunction(value : Dynamic->Class<Dynamic>) : Dynamic->Class<Dynamic>
    {
        if (dataGroup == null) 
        {
            dataGroupProperties.itemRendererFunction = value;
        }
        else 
        {
            dataGroup.itemRendererFunction = value;
            dataGroupProperties.itemRendererFunction = true;
        }
        return value;
    }
    
    /**
	* 布局对象
	*/
    private function get_layout() : LayoutBase
    {
        return ((dataGroup != null)) ? dataGroup.layout : dataGroupProperties.layout;
    }
    
    private function set_layout(value : LayoutBase) : LayoutBase
    {
        if (dataGroup == null) 
        {
            dataGroupProperties.layout = value;
        }
        else 
        {
            dataGroup.layout = value;
            dataGroupProperties.layout = true;
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == dataGroup) 
        {
            var newDataGroupProperties : Dynamic = { };
            
            if (dataGroupProperties.layout != null) 
            {
                dataGroup.layout = dataGroupProperties.layout;
                newDataGroupProperties.layout = true;
            }
            
            if (dataGroupProperties.dataProvider != null) 
            {
                dataGroup.dataProvider = dataGroupProperties.dataProvider;
                newDataGroupProperties.dataProvider = true;
            }
            
            if (dataGroupProperties.itemRenderer != null) 
            {
                dataGroup.itemRenderer = dataGroupProperties.itemRenderer;
                newDataGroupProperties.itemRenderer = true;
            }
            
            if (dataGroupProperties.itemRendererSkinName != null) 
            {
                dataGroup.itemRendererSkinName = dataGroupProperties.itemRendererSkinName;
                newDataGroupProperties.itemRendererSkinName = true;
            }
            
            if (dataGroupProperties.itemRendererFunction != null) 
            {
                dataGroup.itemRendererFunction = dataGroupProperties.itemRendererFunction;
                newDataGroupProperties.itemRendererFunction = true;
            }
            dataGroup.rendererOwner = this;
            dataGroupProperties = newDataGroupProperties;
            
            if (hasEventListener(RendererExistenceEvent.RENDERER_ADD)) 
            {
                dataGroup.addEventListener(
                        RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
            }
            
            if (hasEventListener(RendererExistenceEvent.RENDERER_REMOVE)) 
            {
                dataGroup.addEventListener(
                        RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
            }
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        
        if (instance == dataGroup) 
        {
            dataGroup.removeEventListener(
                    RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
            dataGroup.removeEventListener(
                    RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
            var newDataGroupProperties : Dynamic = { };
            if (dataGroupProperties.layout) 
                newDataGroupProperties.layout = dataGroup.layout;
            if (dataGroupProperties.dataProvider) 
                newDataGroupProperties.dataProvider = dataGroup.dataProvider;
            if (dataGroupProperties.itemRenderer) 
                newDataGroupProperties.itemRenderer = dataGroup.itemRenderer;
            if (dataGroupProperties.itemRendererSkinName) 
                newDataGroupProperties.itemRendererSkinName = dataGroup.itemRendererSkinName;
            if (dataGroupProperties.itemRendererFunction) 
                newDataGroupProperties.itemRendererFunction = dataGroup.itemRendererFunction;
            dataGroupProperties = newDataGroupProperties;
            dataGroup.rendererOwner = null;
            dataGroup.dataProvider = null;
            dataGroup.layout = null;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function addEventListener(
            type : String, listener : Dynamic -> Void, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        
        if (type == RendererExistenceEvent.RENDERER_ADD && dataGroup != null) 
        {
            dataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
        }
        
        if (type == RendererExistenceEvent.RENDERER_REMOVE && dataGroup != null) 
        {
            dataGroup.addEventListener(
                    RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override public function removeEventListener(type : String, listener : Dynamic -> Void, useCapture : Bool = false) : Void
    {
        super.removeEventListener(type, listener, useCapture);
        
        if (type == RendererExistenceEvent.RENDERER_ADD && dataGroup != null) 
        {
            if (!hasEventListener(RendererExistenceEvent.RENDERER_ADD)) 
            {
                dataGroup.removeEventListener(
                        RendererExistenceEvent.RENDERER_ADD, dispatchEvent);
            }
        }
        
        if (type == RendererExistenceEvent.RENDERER_REMOVE && dataGroup != null) 
        {
            if (!hasEventListener(RendererExistenceEvent.RENDERER_REMOVE)) 
            {
                dataGroup.removeEventListener(
                        RendererExistenceEvent.RENDERER_REMOVE, dispatchEvent);
            }
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function createSkinParts() : Void
    {
        dataGroup = new DataGroup();
        dataGroup.percentHeight = dataGroup.percentWidth = 100;
        dataGroup.clipAndEnableScrolling = true;
        var temp : VerticalLayout = new VerticalLayout();
        dataGroup.layout = temp;
        temp.gap = 0;
        temp.horizontalAlign = "contentJustify";
        addToDisplayList(dataGroup);
        partAdded("dataGroup", dataGroup);
    }
    
    /**
	* @inheritDoc
	*/
    override private function removeSkinParts() : Void
    {
        if (dataGroup == null) 
            return;
        partRemoved("dataGroup", dataGroup);
        removeFromDisplayList(dataGroup);
        dataGroup = null;
    }
}
