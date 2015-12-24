package flexlite.components;



import flash.Lib;
import flexlite.collections.ITreeCollection;
import flexlite.components.supportclasses.TreeItemRenderer;
import flexlite.events.CollectionEvent;
import flexlite.events.CollectionEventKind;
import flexlite.events.RendererExistenceEvent;
import flexlite.events.TreeEvent;

/**
* 子节点打开或关闭前一刻分派。可以调用preventDefault()方法阻止节点的状态改变。 
*/
@:meta(Event(name="itemOpening",type="flexlite.events.TreeEvent"))

/**
* 节点打开，注意：只有通过交互操作引起的节点打开才会抛出此事件。
*/
@:meta(Event(name="itemOpen",type="flexlite.events.TreeEvent"))

/**
* 节点关闭,注意：只有通过交互操作引起的节点关闭才会抛出此事件。
*/
@:meta(Event(name="itemClose",type="flexlite.events.TreeEvent"))


@:meta(DXML(show="true"))


/**
* 树状列表组件
* @author weilichuang
*/
class Tree extends List
{
    public var iconField(get, set) : String;
    public var iconFunction(get, set) : Dynamic->Dynamic;

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
    override private function createChildren() : Void
    {
        if (itemRenderer == null) 
            itemRenderer = TreeItemRenderer;
        super.createChildren();
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return Tree;
    }
    
    /**
	* @inheritDoc
	*/
    override public function updateRenderer(renderer : IItemRenderer, itemIndex : Int, data : Dynamic) : IItemRenderer
    {
        if (Std.is(renderer, ITreeItemRenderer) && Std.is(dataProvider, ITreeCollection)) 
        {
            var treeCollection : ITreeCollection = Lib.as(dataProvider, ITreeCollection);
            var treeRenderer : ITreeItemRenderer = Lib.as(renderer, ITreeItemRenderer);
            treeRenderer.hasChildren = treeCollection.hasChildren(data);
            treeRenderer.opened = treeCollection.isItemOpen(data);
            treeRenderer.depth = treeCollection.getDepth(data);
            treeRenderer.iconSkinName = itemToIcon(data);
        }
        return super.updateRenderer(renderer, itemIndex, data);
    }
    /**
	* 根据数据项返回项呈示器中图标的skinName属性值
	*/
    public function itemToIcon(data : Dynamic) : Dynamic
    {
        if (data == null) 
            return null;
        
        if (_iconFunction != null) 
            return _iconFunction(data);
        
        var skinName : Dynamic = null;
		//FIX XML
        //if (Std.is(data, FastXML)) 
        //{
            //try
            //{
                //if (Reflect.field(data, iconField).length() != 0) 
                //{
                    //skinName = Std.string(Reflect.field(data, iconField));
                //}
            //}            
			//catch (e : String)
            //{
                //
            //}
        //}
        //else 
		if (Std.is(data, Dynamic)) 
        {
            try
            {
                if (Reflect.field(data, iconField)) 
                {
                    skinName = Reflect.field(data, iconField);
                }
            }            
			catch (e : String)
            {
                
            }
        }
        return skinName;
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataGroup_rendererAddHandler(event : RendererExistenceEvent) : Void
    {
        super.dataGroup_rendererAddHandler(event);
        if (Std.is(event.renderer, ITreeItemRenderer)) 
            event.renderer.addEventListener(TreeEvent.ITEM_OPENING, onItemOpening);
    }
    /**
	* 节点即将打开
	*/
    private function onItemOpening(event : TreeEvent) : Void
    {
        var renderer : ITreeItemRenderer = event.itemRenderer;
        var item : Dynamic = event.item;
        if (renderer == null || !(Std.is(dataProvider, ITreeCollection))) 
            return;
        if (dispatchEvent(event)) 
        {
            var opend : Bool = !renderer.opened;
            Lib.as(dataProvider, ITreeCollection).expandItem(item, opend);
            var type : String = (opend) ? TreeEvent.ITEM_OPEN : TreeEvent.ITEM_CLOSE;
            var evt : TreeEvent = new TreeEvent(type, false, false, renderer.itemIndex, item, renderer);
            dispatchEvent(evt);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataGroup_rendererRemoveHandler(event : RendererExistenceEvent) : Void
    {
        super.dataGroup_rendererRemoveHandler(event);
        if (Std.is(event.renderer, ITreeItemRenderer)) 
            event.renderer.removeEventListener(TreeEvent.ITEM_OPENING, onItemOpening);
    }
    /**
	* 图标字段或函数改变标志
	*/
    private var iconFieldOrFunctionChanged : Bool = false;
    
    private var _iconField : String;
    /**
	* 数据项中用来确定图标skinName属性值的字段名称。另请参考UIAsset.skinName。
	* 若设置了iconFunction，则设置此属性无效。
	*/
    private function get_iconField() : String
    {
        return _iconField;
    }
    private function set_iconField(value : String) : String
    {
        if (_iconField == value) 
            return value;
        _iconField = value;
        iconFieldOrFunctionChanged = true;
        invalidateProperties();
        return value;
    }
    
    private var _iconFunction : Dynamic->Dynamic;
    /**
	* 用户提供的函数，在每个数据项目上运行以确定其图标的skinName值。另请参考UIAsset.skinName。
	* 示例：iconFunction(item:Object):Object
	*/
    private function get_iconFunction() : Dynamic->Dynamic
    {
        return _iconFunction;
    }
    private function set_iconFunction(value : Dynamic->Dynamic) : Dynamic->Dynamic
    {
        if (_iconFunction == value) 
            return value;
        _iconFunction = value;
        iconFieldOrFunctionChanged = true;
        invalidateProperties();
        return value;
    }
    /**
	* 打开或关闭一个节点,注意，此操作不会抛出open或close事件。
	* @param item 要打开或关闭的节点
	* @param open true表示打开节点，反之关闭。
	*/
    public function expandItem(item : Dynamic, open : Bool = true) : Void
    {
        if (!(Std.is(dataProvider, ITreeCollection))) 
            return;
        Lib.as(dataProvider, ITreeCollection).expandItem(item, open);
    }
    /**
	* 指定的节点是否打开
	*/
    public function isItemOpen(item : Dynamic) : Bool
    {
        if (!(Std.is(dataProvider, ITreeCollection))) 
            return false;
        return Lib.as(dataProvider, ITreeCollection).isItemOpen(item);
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataProvider_collectionChangeHandler(event : CollectionEvent) : Void
    {
        super.dataProvider_collectionChangeHandler(event);
        if (event.kind == CollectionEventKind.OPEN || event.kind == CollectionEventKind.CLOSE) 
        {
            var renderer : ITreeItemRenderer = (dataGroup != null) ? 
            cast(dataGroup.getElementAt(event.location), ITreeItemRenderer) : null;
            if (renderer != null) 
            {
                updateRenderer(renderer, event.location, event.items[0]);
                if (event.kind == CollectionEventKind.CLOSE && layout != null && layout.useVirtualLayout) 
                {
                    layout.clearVirtualLayoutCache();
                    invalidateSize();
                }
            }
        }
    }
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (iconFieldOrFunctionChanged) 
        {
            if (dataGroup != null) 
            {
                var itemIndex : Int;
                if (layout != null && layout.useVirtualLayout) 
                {
                    for (itemIndex/* AS3HX WARNING could not determine type for var: itemIndex exp: ECall(EField(EIdent(dataGroup),getElementIndicesInView),[]) type: null */ in dataGroup.getElementIndicesInView())
                    {
                        updateRendererIconProperty(itemIndex);
                    }
                }
                else 
                {
                    var n : Int = dataGroup.numElements;
                    for (itemIndex in 0...n){
                        updateRendererIconProperty(itemIndex);
                    }
                }
            }
            iconFieldOrFunctionChanged = false;
        }
    }
    /**
	* 更新指定索引项的图标
	*/
    private function updateRendererIconProperty(itemIndex : Int) : Void
    {
        var renderer : ITreeItemRenderer = Lib.as(dataGroup.getElementAt(itemIndex), ITreeItemRenderer);
        if (renderer != null) 
            renderer.iconSkinName = itemToIcon(renderer.data);
    }
}
