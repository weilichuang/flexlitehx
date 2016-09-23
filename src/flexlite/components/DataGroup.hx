package flexlite.components;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.utils.Timer;
import flexlite.collections.ICollection;
import flexlite.components.IItemRenderer;
import flexlite.components.IItemRendererOwner;
import flexlite.components.SkinnableComponent;
import flexlite.components.supportclasses.GroupBase;
import flexlite.components.supportclasses.ItemRenderer;
import flexlite.core.IInvalidating;
import flexlite.core.ISkinnableClient;
import flexlite.core.IVisualElement;
import flexlite.events.CollectionEvent;
import flexlite.events.CollectionEventKind;
import flexlite.events.RendererExistenceEvent;
import flexlite.layouts.HorizontalAlign;
import flexlite.layouts.supportclasses.LayoutBase;
import flexlite.layouts.VerticalLayout;
import haxe.ds.ObjectMap;
import haxe.ds.WeakMap;
@:meta(DXML(show="true"))
@:meta(DefaultProperty(name="dataProvider",array="false"))
/**
* 添加了项呈示器
*/
@:meta(Event(name="rendererAdd",type="flexlite.events.RendererExistenceEvent"))

/**
* 移除了项呈示器
*/
@:meta(Event(name="rendererRemove",type="flexlite.events.RendererExistenceEvent"))
/**
* 数据项目的容器基类
* 将数据项目转换为可视元素以进行显示。
* @author weilichuang
*/
class DataGroup extends GroupBase
{
	public var rendererOwner(get, set) : IItemRendererOwner;
	public var dataProvider(get, set) : ICollection;
	public var itemRenderer(get, set) : Class<Dynamic>;
	public var itemRendererSkinName(get, set) : Dynamic;
	public var itemRendererFunction(get, set) : Dynamic->Class<Dynamic>;

	private var _rendererOwner : IItemRendererOwner;

	private var useVirtualLayoutChanged : Bool = false;

	/**
	* 存储当前可见的项呈示器索引列表
	*/
	private var virtualRendererIndices : Array<Int>;

	private var rendererToClassMap : ObjectMap<IItemRenderer,Class<Dynamic>> = new ObjectMap<IItemRenderer,Class<Dynamic>>();
	private var freeRenderers : ObjectMap<Dynamic,Array<IItemRenderer>> = new ObjectMap<Dynamic,Array<IItemRenderer>>();

	/**
	* 是否创建了新的项呈示器标志
	*/
	private var createNewRendererFlag : Bool = false;

	private var cleanTimer : Timer;

	private var dataProviderChanged : Bool = false;

	private var _dataProvider : ICollection;

	/**
	* 对象池字典
	*/
	private var recyclerDic : ObjectMap<Dynamic,WeakMap<IItemRenderer,Bool>> = new ObjectMap<Dynamic,WeakMap<IItemRenderer,Bool>>();

	/**
	* 项呈示器改变
	*/
	private var itemRendererChanged : Bool;

	private var _itemRenderer : Class<Dynamic>;

	private var itemRendererSkinNameChange : Bool = false;

	private var _itemRendererSkinName : Dynamic;

	private var _itemRendererFunction : Dynamic->Class<Dynamic>;

	/**
	* 正在进行虚拟布局阶段
	*/
	private var virtualLayoutUnderway : Bool = false;

	/**
	* 用于测试默认大小的数据
	*/
	private var typicalItem : Dynamic;

	private var typicalItemChanged : Bool = false;

	/**
	* 项呈示器的默认尺寸
	*/
	private var typicalLayoutRect : Rectangle;

	/**
	* 索引到项呈示器的转换数组
	*/
	private var indexToRenderer : Array<IItemRenderer> = [];
	/**
	* 清理freeRenderer标志
	*/
	private var cleanFreeRenderer : Bool = false;

	/**
	* 正在更新数据项的标志
	*/
	private var renderersBeingUpdated : Bool = false;

	/**
	* 构造函数
	*/
	public function new()
	{
		super();
	}
	/**
	* 项呈示器的主机组件
	*/
	private function get_rendererOwner() : IItemRendererOwner
	{
		return _rendererOwner;
	}

	private function set_rendererOwner(value : IItemRendererOwner) : IItemRendererOwner
	{
		_rendererOwner = value;
		return value;
	}
	/**
	* @inheritDoc
	*/
	override private function set_layout(value : LayoutBase) : LayoutBase
	{
		if (value == layout)
			return value;

		if (layout != null)
		{
			layout.typicalLayoutRect = null;
			layout.removeEventListener("useVirtualLayoutChanged", layout_useVirtualLayoutChangedHandler);
		}

		if (layout != null && value != null && (layout.useVirtualLayout != value.useVirtualLayout))
			changeUseVirtualLayout();
		super.layout = value;
		if (value != null)
		{
			value.typicalLayoutRect = typicalLayoutRect;
			value.addEventListener("useVirtualLayoutChanged", layout_useVirtualLayoutChangedHandler);
		}
		return value;
	}

	/**
	* 是否使用虚拟布局标记改变
	*/
	private function layout_useVirtualLayoutChangedHandler(event : Event) : Void
	{
		changeUseVirtualLayout();
	}
	override public function setVirtualElementIndicesInView(startIndex : Int, endIndex : Int) : Void
	{
		if (layout == null || !layout.useVirtualLayout)
			return;

		virtualRendererIndices = new Array<Int>();
		for (i in startIndex...endIndex + 1)
		{
			virtualRendererIndices.push(i);
		}

		for (index in 0...indexToRenderer.length)
		{
			if (indexToRenderer[index] != null)
			{
				freeRendererByIndex(index);
			}
		}
	}

	/**
	* @inheritDoc
	*/
	override public function getVirtualElementAt(index : Int) : IVisualElement
	{
		if (index < 0 || index >= dataProvider.length)
			return null;
		var element : IVisualElement = cast indexToRenderer[index];
		if (element == null)
		{
			var item : Dynamic = dataProvider.getItemAt(index);
			var renderer : IItemRenderer = createVirtualRenderer(index);
			indexToRenderer[index] = renderer;
			updateRenderer(renderer, index, item);
			if (createNewRendererFlag)
			{
				if (Std.is(renderer, IInvalidating))
					Lib.as(renderer, IInvalidating).validateNow();
				createNewRendererFlag = false;
				dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD,
				false, false, renderer, index, item));
			}
			element = Lib.as(renderer, IVisualElement);
		}
		return element;
	}
	/**
	* 释放指定索引处的项呈示器
	*/
	private function freeRendererByIndex(index : Int) : Void
	{
		if (indexToRenderer[index] == null)
			return;

		var renderer : IItemRenderer = Lib.as(indexToRenderer[index], IItemRenderer);

		indexToRenderer[index] = null;

		if (renderer != null && Std.is(renderer, DisplayObject))
		{
			doFreeRenderer(renderer);
		}
	}
	/**
	* 释放指定的项呈示器
	*/
	private function doFreeRenderer(renderer : IItemRenderer) : Void
	{
		var rendererClass : Class<Dynamic> = Reflect.field(rendererToClassMap, Std.string(renderer));
		if (!freeRenderers.exists(rendererClass))
		{
			freeRenderers.set(rendererClass, new Array<IItemRenderer>());
		}
		freeRenderers.get(rendererClass).push(renderer);
		cast(renderer, DisplayObject).visible = false;
	}
	/**
	* @inheritDoc
	*/
	override public function invalidateSize() : Void
	{
		if (!createNewRendererFlag)               //虚拟布局时创建子项不需要重新验证
			super.invalidateSize();
	}

	/**
	* 为指定索引创建虚拟的项呈示器
	*/
	private function createVirtualRenderer(index : Int) : IItemRenderer
	{
		var item : Dynamic = dataProvider.getItemAt(index);
		var renderer : IItemRenderer;
		var rendererClass : Class<Dynamic> = itemToRendererClass(item);

		if (freeRenderers.exists(rendererClass) && freeRenderers.get(rendererClass).length > 0)
		{
			renderer = freeRenderers.get(rendererClass).pop();
			cast(renderer, DisplayObject).visible = true;
			return renderer;
		}
		createNewRendererFlag = true;
		return createOneRenderer(rendererClass);
	}
	/**
	* 根据rendererClass创建一个Renderer,并添加到显示列表
	*/
	private function createOneRenderer(rendererClass : Class<Dynamic>) : IItemRenderer
	{
		var renderer : IItemRenderer = null;
		if (recyclerDic.exists(rendererClass))
		{
			var hasExtra : Bool = false;
			var keys = recyclerDic.get(rendererClass);
			for (key in keys)
			{
				if (renderer == null)
				{
					renderer = Lib.as(key, IItemRenderer);
				}
				else
				{
					hasExtra = true;
					break;
				}
			}
			recyclerDic.get(rendererClass).remove(renderer);
			if (!hasExtra)
				recyclerDic.remove(rendererClass);
		}
		if (renderer == null)
		{
			renderer = Lib.as(Type.createInstance(rendererClass, []), IItemRenderer);
			rendererToClassMap.set(renderer, rendererClass);
		}
		if (renderer == null || !(Std.is(renderer, DisplayObject)))
			return null;

		if (_itemRendererSkinName)
		{
			setItemRenderSkinName(renderer);
		}
		addToDisplayList(cast renderer);
		renderer.setLayoutBoundsSize(Math.NaN, Math.NaN);
		return renderer;
	}
	/**
	* 设置项呈示器的默认皮肤
	*/
	private function setItemRenderSkinName(renderer : IItemRenderer) : Void
	{
		if (renderer == null)
			return;
		var comp : SkinnableComponent = cast(renderer, SkinnableComponent);
		if (comp != null)
		{
			if (!comp.skinNameExplicitlySet)
				comp.skinName = _itemRendererSkinName;
		}
		else
		{
			var client : ISkinnableClient = Lib.as(renderer, ISkinnableClient);
			if (client != null && !client.skinName)
				client.skinName = _itemRendererSkinName;
		}
	}
	/**
	* 虚拟布局结束清理不可见的项呈示器
	*/
	private function finishVirtualLayout() : Void
	{
		if (!virtualLayoutUnderway)
			return;
		virtualLayoutUnderway = false;
		var found : Bool = false;

		var keys = freeRenderers.keys();
		for (clazz in keys)
		{
			if (freeRenderers.get(clazz).length > 0)
			{
				found = true;
				break;
			}
		}
		if (!found)
			return;
		if (cleanTimer == null)
		{
			cleanTimer = new Timer(3000, 1);
			cleanTimer.addEventListener(TimerEvent.TIMER, cleanAllFreeRenderer);
		}  //为了提高持续滚动过程中的性能，防止反复地添加移除子项，这里不直接清理而是延迟后在滚动停止时清理一次。

		cleanTimer.reset();
		cleanTimer.start();
	}
	/**
	* 延迟清理多余的在显示列表中的ItemRenderer。
	*/
	private function cleanAllFreeRenderer(event : TimerEvent = null) : Void
	{
		var renderer : IItemRenderer;

		var keys = freeRenderers.keys();
		for (key in keys)
		{
			var list:Array<IItemRenderer> = freeRenderers.get(key);
			for (renderer in list)
			{
				cast(renderer, DisplayObject).visible = true;
				recycle(renderer);
			}
		}
		freeRenderers = new ObjectMap<Dynamic,Array<IItemRenderer>>();
		cleanFreeRenderer = false;
	}

	/**
	* @inheritDoc
	*/
	override public function getElementIndicesInView() : Array<Int>
	{
		if (layout != null && layout.useVirtualLayout)
			return (virtualRendererIndices != null) ?
			virtualRendererIndices : new Array<Int>();
		return super.getElementIndicesInView();
	}

	/**
	* 更改是否使用虚拟布局
	*/
	private function changeUseVirtualLayout() : Void
	{
		useVirtualLayoutChanged = true;
		cleanFreeRenderer = true;
		removeDataProviderListener();
		invalidateProperties();
	}
	/**
	* 列表数据源，请使用实现了ICollection接口的数据类型，例如ArrayCollection
	*/
	private function get_dataProvider() : ICollection
	{
		return _dataProvider;
	}

	private function set_dataProvider(value : ICollection) : ICollection
	{
		if (_dataProvider == value)
			return value;
		removeDataProviderListener();
		_dataProvider = value;
		dataProviderChanged = true;
		cleanFreeRenderer = true;
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
		return value;
	}
	/**
	* 移除数据源监听
	*/
	private function removeDataProviderListener() : Void
	{
		if (_dataProvider != null)
			_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
	}
	/**
	* 数据源改变事件处理
	*/
	private function onCollectionChange(event : CollectionEvent) : Void
	{
		var _sw1_ = (event.kind);

		switch (_sw1_)
		{
			case CollectionEventKind.ADD:
				itemAddedHandler(event.items, event.location);
			case CollectionEventKind.MOVE:
				itemMovedHandler(event.items[0], event.location, event.oldLocation);
			case CollectionEventKind.REMOVE:
				itemRemovedHandler(event.items, event.location);
			case CollectionEventKind.UPDATE:
				itemUpdatedHandler(event.items[0], event.location);
			case CollectionEventKind.REPLACE:
				itemRemoved(event.oldItems[0], event.location);
				itemAdded(event.items[0], event.location);
			case CollectionEventKind.RESET, CollectionEventKind.REFRESH:
				if (layout != null && layout.useVirtualLayout)
				{
					for (i in 0...indexToRenderer.length)
					{
						if (indexToRenderer[i] != null)
						{
							freeRendererByIndex(i);
						}
					}
				}
				dataProviderChanged = true;
				invalidateProperties();
		}
		invalidateSize();
		invalidateDisplayList();
	}

	/**
	* 数据源添加项目事件处理
	*/
	private function itemAddedHandler(items : Array<Dynamic>, index : Int) : Void
	{
		var length : Int = items.length;
		for (i in 0...length)
		{
			itemAdded(items[i], index + i);
		}
		resetRenderersIndices();
	}
	/**
	* 数据源移动项目事件处理
	*/
	private function itemMovedHandler(item : Dynamic, location : Int, oldLocation : Int) : Void
	{
		itemRemoved(item, oldLocation);
		itemAdded(item, location);
		resetRenderersIndices();
	}
	/**
	* 数据源移除项目事件处理
	*/
	private function itemRemovedHandler(items : Array<Dynamic>, location : Int) : Void
	{
		var length : Int = items.length;
		var i : Int = length - 1;
		while (i >= 0)
		{
			itemRemoved(items[i], location + i);
			i--;
		}

		resetRenderersIndices();
	}
	/**
	* 添加一项
	*/
	private function itemAdded(item : Dynamic, index : Int) : Void
	{
		if (layout != null)
			layout.elementAdded(index);

		if (layout != null && layout.useVirtualLayout)
		{
			if (virtualRendererIndices != null)
			{
				var virtualRendererIndicesLength : Int = virtualRendererIndices.length;
				for (i in 0...virtualRendererIndicesLength)
				{
					var vrIndex : Int = virtualRendererIndices[i];
					if (vrIndex >= index)
						virtualRendererIndices[i] = vrIndex + 1;
				}
				indexToRenderer.insert(index, null);
			}
			return;
		}
		var rendererClass : Class<Dynamic> = itemToRendererClass(item);
		var renderer : IItemRenderer = createOneRenderer(rendererClass);
		indexToRenderer.insert(index, renderer);
		if (renderer == null)
			return;
		updateRenderer(renderer, index, item);
		dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD,
					  false, false, renderer, index, item));
	}

	/**
	* 移除一项
	*/
	private function itemRemoved(item : Dynamic, index : Int) : Void
	{
		if (layout != null)
			layout.elementRemoved(index);
		if (virtualRendererIndices != null && (virtualRendererIndices.length > 0))
		{
			var vrItemIndex : Int = -1;
			var virtualRendererIndicesLength : Int = virtualRendererIndices.length;
			for (i in 0...virtualRendererIndicesLength)
			{
				var vrIndex : Int = virtualRendererIndices[i];
				if (vrIndex == index)
					vrItemIndex = i
					else if (vrIndex > index)
						virtualRendererIndices[i] = vrIndex - 1;
			}
			if (vrItemIndex != -1)
				virtualRendererIndices.splice(vrItemIndex, 1);
		}
		var oldRenderer : IItemRenderer = indexToRenderer[index];

		if (indexToRenderer.length > index)
			indexToRenderer.splice(index, 1);

		dispatchEvent(new RendererExistenceEvent(
						  RendererExistenceEvent.RENDERER_REMOVE, false, false, oldRenderer, index, item));

		if (oldRenderer != null && Std.is(oldRenderer, DisplayObject))
		{
			recycle(oldRenderer);
		}
	}
	/**
	* 回收一个ItemRenderer实例
	*/
	private function recycle(renderer : IItemRenderer) : Void
	{
		removeFromDisplayList(cast(renderer, DisplayObject));
		if (Std.is(renderer, IVisualElement))
		{
			Lib.as(renderer, IVisualElement).ownerChanged(null);
		}

		var rendererClass : Class<Dynamic> = rendererToClassMap.get(renderer);
		if (!recyclerDic.exists(rendererClass))
		{
			recyclerDic.set(rendererClass, new WeakMap<IItemRenderer,Bool>());
		}

		recyclerDic.get(rendererClass).set(renderer, true);
	}
	/**
	* 更新当前所有项的索引
	*/
	private function resetRenderersIndices() : Void
	{
		if (indexToRenderer.length == 0)
			return;

		if (layout != null && layout.useVirtualLayout)
		{
			for (index in virtualRendererIndices)
				resetRendererItemIndex(index);
		}
		else
		{
			var indexToRendererLength : Int = indexToRenderer.length;
			for (index in 0...indexToRendererLength)
			{
				resetRendererItemIndex(index);
			}
		}
	}
	/**
	* 数据源更新或替换项目事件处理
	*/
	private function itemUpdatedHandler(item : Dynamic, location : Int) : Void
	{
		if (renderersBeingUpdated)
			return;  //防止无限循环

		var itemRenderer : IItemRenderer = indexToRenderer[location];
		if (itemRenderer != null)
			updateRenderer(itemRenderer, location, item);
	}
	/**
	* 调整指定项呈示器的索引值
	*/
	private function resetRendererItemIndex(index : Int) : Void
	{
		var renderer : IItemRenderer = Lib.as(indexToRenderer[index], IItemRenderer);
		if (renderer != null)
			renderer.itemIndex = index;
	}
	/**
	* 用于数据项目的项呈示器。该类必须实现 IItemRenderer 接口。<br/>
	* rendererClass获取顺序：itemRendererFunction > itemRenderer > 默认ItemRenerer。
	*/
	private function get_itemRenderer() : Class<Dynamic>
	{
		return _itemRenderer;
	}

	private function set_itemRenderer(value : Class<Dynamic>) : Class<Dynamic>
	{
		if (_itemRenderer == value)
			return value;
		_itemRenderer = value;
		itemRendererChanged = true;
		typicalItemChanged = true;
		cleanFreeRenderer = true;
		removeDataProviderListener();
		invalidateProperties();
		return value;
	}
	/**
	* 条目渲染器的可选皮肤标识符。在实例化itemRenderer时，若其内部没有设置过skinName,则将此属性的值赋值给它的skinName。
	* 注意:若itemRenderer不是ISkinnableClient，则此属性无效。
	*/
	private function get_itemRendererSkinName() : Dynamic
	{
		return _itemRendererSkinName;
	}
	private function set_itemRendererSkinName(value : Dynamic) : Dynamic
	{
		if (_itemRendererSkinName == value)
			return value;
		_itemRendererSkinName = value;
		if (_itemRendererSkinName != null && initialized)
		{
			itemRendererSkinNameChange = true;
			invalidateProperties();
		}
		return value;
	}
	/**
	* 为某个特定项目返回一个项呈示器Class的函数。<br/>
	* rendererClass获取顺序：itemRendererFunction > itemRenderer > 默认ItemRenerer。<br/>
	* 应该定义一个与此示例函数类似的呈示器函数： <br/>
	* function myItemRendererFunction(item:Object):Class
	*/
	private function get_itemRendererFunction() : Dynamic->Class<Dynamic>
	{
		return _itemRendererFunction;
	}

	private function set_itemRendererFunction(value : Dynamic->Class<Dynamic>) : Dynamic->Class<Dynamic>
	{
		if (_itemRendererFunction == value)
			return value;
		_itemRendererFunction = value;

		itemRendererChanged = true;
		typicalItemChanged = true;
		removeDataProviderListener();
		invalidateProperties();
		return value;
	}
	/**
	* 为特定的数据项返回项呈示器类定义
	*/
	private function itemToRendererClass(item : Dynamic) : Class<Dynamic>
	{
		var rendererClass : Class<Dynamic>;
		if (_itemRendererFunction != null)
		{
			rendererClass = _itemRendererFunction(item);
			if (rendererClass == null)
				rendererClass = _itemRenderer;
		}
		else
		{
			rendererClass = _itemRenderer;
		}
		return (rendererClass != null) ? rendererClass : ItemRenderer;
	}

	/**
	* @private
	* 设置默认的ItemRenderer
	*/
	override private function createChildren() : Void
	{
		if (layout == null)
		{
			var _layout : VerticalLayout = new VerticalLayout();
			_layout.gap = 0;
			_layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			layout = _layout;
		}
		super.createChildren();
	}
	/**
	* @inheritDoc
	*/
	override private function commitProperties() : Void
	{
		if (itemRendererChanged || dataProviderChanged || useVirtualLayoutChanged)
		{
			removeAllRenderers();
			if (layout != null)
				layout.clearVirtualLayoutCache();
			setTypicalLayoutRect(null);
			useVirtualLayoutChanged = false;
			itemRendererChanged = false;
			if (_dataProvider != null)
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
			if (layout != null && layout.useVirtualLayout)
			{
				invalidateSize();
				invalidateDisplayList();
			}
			else
			{
				createRenderers();
			}
			if (dataProviderChanged)
			{
				dataProviderChanged = false;
				verticalScrollPosition = horizontalScrollPosition = 0;
			}
		}

		super.commitProperties();

		if (typicalItemChanged)
		{
			typicalItemChanged = false;
			if (_dataProvider != null && _dataProvider.length > 0)
			{
				typicalItem = _dataProvider.getItemAt(0);
				measureRendererSize();
			}
		}
		if (itemRendererSkinNameChange)
		{
			itemRendererSkinNameChange = false;
			var length : Int = indexToRenderer.length;
			var client : ISkinnableClient;
			var comp : SkinnableComponent;
			for (i in 0...length)
			{
				setItemRenderSkinName(indexToRenderer[i]);
			}
			for (clazz in Reflect.fields(freeRenderers))
			{
				var list : Array<IItemRenderer> = Reflect.field(freeRenderers, clazz);
				if (list != null)
				{
					length = list.length;
					for (i in 0...length)
					{
						setItemRenderSkinName(list[i]);
					}
				}
			}
		}
	}

	/**
	* @inheritDoc
	*/
	override private function measure() : Void
	{
		if (layout != null && layout.useVirtualLayout)
		{
			ensureTypicalLayoutElement();
		}
		super.measure();
	}
	/**
	* @inheritDoc
	*/
	override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
	{
		if (layoutInvalidateDisplayListFlag && layout != null && layout.useVirtualLayout)
		{
			virtualLayoutUnderway = true;
			ensureTypicalLayoutElement();
		}
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		if (virtualLayoutUnderway)
			finishVirtualLayout();
	}
	/**
	* 确保测量过默认条目大小。
	*/
	private function ensureTypicalLayoutElement() : Void
	{
		if (layout.typicalLayoutRect != null)
			return;

		if (_dataProvider != null && _dataProvider.length > 0)
		{
			typicalItem = _dataProvider.getItemAt(0);
			measureRendererSize();
		}
	}

	/**
	* 测量项呈示器默认尺寸
	*/
	private function measureRendererSize() : Void
	{
		if (typicalItem == null)
		{
			setTypicalLayoutRect(null);
			return;
		}
		var rendererClass : Class<Dynamic> = itemToRendererClass(typicalItem);
		var typicalRenderer : IItemRenderer = createOneRenderer(rendererClass);
		if (typicalRenderer == null)
		{
			setTypicalLayoutRect(null);
			return;
		}
		createNewRendererFlag = true;
		updateRenderer(typicalRenderer, 0, typicalItem);
		if (Std.is(typicalRenderer, IInvalidating))
			Lib.as(typicalRenderer, IInvalidating).validateNow();
		var rect : Rectangle = new Rectangle(0, 0, typicalRenderer.preferredWidth,
		typicalRenderer.preferredHeight);
		recycle(typicalRenderer);
		setTypicalLayoutRect(rect);
		createNewRendererFlag = false;
	}
	/**
	* 设置项目默认大小
	*/
	private function setTypicalLayoutRect(rect : Rectangle) : Void
	{
		typicalLayoutRect = rect;
		if (layout != null)
			layout.typicalLayoutRect = rect;
	}
	/**
	* 移除所有项呈示器
	*/
	private function removeAllRenderers() : Void
	{
		var length : Int = indexToRenderer.length;
		var renderer : IItemRenderer;
		for (i in 0...length)
		{
			renderer = indexToRenderer[i];
			if (renderer != null)
			{
				recycle(renderer);
				dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_REMOVE,
				false, false, renderer, renderer.itemIndex, renderer.data));
			}
		}
		indexToRenderer = [];
		virtualRendererIndices = null;
		if (!cleanFreeRenderer)
			return;
		cleanAllFreeRenderer();
	}

	/**
	* 为数据项创建项呈示器
	*/
	private function createRenderers() : Void
	{
		if (_dataProvider == null)
			return;
		var index : Int = 0;
		var length : Int = _dataProvider.length;
		var i:Int = 0;
		while (i < length)
		{
			var item : Dynamic = _dataProvider.getItemAt(i);
			var rendererClass : Class<Dynamic> = itemToRendererClass(item);
			var renderer : IItemRenderer = createOneRenderer(rendererClass);
			if (renderer == null)
			{
				i++;
				continue;
			}
			indexToRenderer[index] = renderer;
			updateRenderer(renderer, index, item);
			dispatchEvent(new RendererExistenceEvent(RendererExistenceEvent.RENDERER_ADD,
						  false, false, renderer, index, item));
			index++;
			i++;
		}
	}
	/**
	* 更新项呈示器
	*/
	private function updateRenderer(renderer : IItemRenderer, itemIndex : Int, data : Dynamic) : IItemRenderer
	{
		renderersBeingUpdated = true;

		if (_rendererOwner != null)
		{
			renderer = _rendererOwner.updateRenderer(renderer, itemIndex, data);
		}
		else
		{
			if (Std.is(renderer, IVisualElement))
			{
				Lib.as(renderer, IVisualElement).ownerChanged(this);
			}
			renderer.itemIndex = itemIndex;
			renderer.label = itemToLabel(data);
			renderer.data = data;
		}

		renderersBeingUpdated = false;
		return renderer;
	}

	/**
	* 返回可在项呈示器中显示的 String。
	* 若DataGroup被作为SkinnableDataContainer的皮肤组件,此方法将不会执行，被SkinnableDataContainer.itemToLabel()所替代。
	*/
	private function itemToLabel(item : Dynamic) : String
	{
		if (item != null)
			return Std.string(item)
			else return " ";
	}

	/**
	* @inheritDoc
	*/
	override public function getElementAt(index : Int) : IVisualElement
	{
		return cast indexToRenderer[index];
	}

	/**
	* @inheritDoc
	*/
	override public function getElementIndex(element : IVisualElement) : Int
	{
		if (element == null)
			return -1;
		return indexToRenderer.indexOf(cast element);
	}

	/**
	* @inheritDoc
	*/
	override private function get_numElements() : Int
	{
		if (_dataProvider == null)
			return 0;
		return _dataProvider.length;
	}

	private static inline var errorStr : String = "在此组件中不可用，若此组件为容器类，请使用";

	/**
	* addChild()在此组件中不可用，若此组件为容器类，请使用addElement()代替
	*/
	@:meta(Deprecated())
	override public function addChild(child : DisplayObject) : DisplayObject
	{
		throw ("addChild()" + errorStr + "addElement()代替");
	}
	/**
	* addChildAt()在此组件中不可用，若此组件为容器类，请使用addElementAt()代替
	*/
	@:meta(Deprecated())
	override public function addChildAt(child : DisplayObject, index : Int) : DisplayObject
	{
		throw (("addChildAt()" + errorStr + "addElementAt()代替"));
		return null;
	}
	/**
	* removeChild()在此组件中不可用，若此组件为容器类，请使用removeElement()代替
	*/
	@:meta(Deprecated())
	override public function removeChild(child : DisplayObject) : DisplayObject
	{
		throw (("removeChild()" + errorStr + "removeElement()代替"));
		return null;
	}
	/**
	* removeChildAt()在此组件中不可用，若此组件为容器类，请使用removeElementAt()代替
	*/
	@:meta(Deprecated())
	override public function removeChildAt(index : Int) : DisplayObject
	{
		throw (("removeChildAt()" + errorStr + "removeElementAt()代替"));
	}
	/**
	* setChildIndex()在此组件中不可用，若此组件为容器类，请使用setElementIndex()代替
	*/
	@:meta(Deprecated())
	override public function setChildIndex(child : DisplayObject, index : Int) : Void
	{
		throw (("setChildIndex()" + errorStr + "setElementIndex()代替"));
	}
	/**
	* swapChildren()在此组件中不可用，若此组件为容器类，请使用swapElements()代替
	*/
	@:meta(Deprecated())
	override public function swapChildren(child1 : DisplayObject, child2 : DisplayObject) : Void
	{
		throw (("swapChildren()" + errorStr + "swapElements()代替"));
	}
	/**
	* swapChildrenAt()在此组件中不可用，若此组件为容器类，请使用swapElementsAt()代替
	*/
	@:meta(Deprecated())
	override public function swapChildrenAt(index1 : Int, index2 : Int) : Void
	{
		throw (("swapChildrenAt()" + errorStr + "swapElementsAt()代替"));
	}
}
