package flexlite.components;

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLLoader;
import flexlite.components.supportclasses.GroupBase;
import flexlite.core.IContainer;
import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.events.DragEvent;
import flexlite.events.ElementExistenceEvent;

/**
* 元素添加事件
*/
@:meta(Event(name="elementAdd",type="flexlite.events.ElementExistenceEvent"))

/**
* 元素移除事件
*/
@:meta(Event(name="elementRemove",type="flexlite.events.ElementExistenceEvent"))

@:meta(DXML(show="true"))

@:meta(DefaultProperty(name="elementsContent",array="true"))
/**
* 自动布局容器
* @author weilichuang
*/
class Group extends GroupBase implements IVisualElementContainer
{
	public var mouseEnabledWhereTransparent(get, set) : Bool;
	public var elementsContent(never, set) : Array<IVisualElement>;
	private var hasMouseListeners(never, set) : Bool;

	private var _hasMouseListeners : Bool = false;

	/**
	* 鼠标事件的监听个数
	*/
	private var mouseEventReferenceCount : Int;

	private var _mouseEnabledWhereTransparent : Bool = true;

	/**
	* createChildren()方法已经执行过的标志
	*/
	private var createChildrenCalled : Bool = false;

	/**
	* elementsContent改变标志
	*/
	private var elementsContentChanged : Bool = false;

	private var _elementsContent : Array<IVisualElement> = [];

	public function new()
	{
		super();
	}

	/**
	* 是否添加过鼠标事件监听
	*/
	private function set_hasMouseListeners(value : Bool) : Bool
	{
		if (_mouseEnabledWhereTransparent)
		{
			invalidateDisplayListExceptLayout();
		}
		_hasMouseListeners = value;
		return value;
	}

	/**
	*  是否允许透明区域也响应鼠标事件,默认true
	*/
	private function get_mouseEnabledWhereTransparent() : Bool
	{
		return _mouseEnabledWhereTransparent;
	}

	private function set_mouseEnabledWhereTransparent(value : Bool) : Bool
	{
		if (value == _mouseEnabledWhereTransparent)
			return value;

		_mouseEnabledWhereTransparent = value;

		if (_hasMouseListeners)
			invalidateDisplayListExceptLayout();
		return value;
	}

	/**
	* @inheritDoc
	*/
	override public function addEventListener(type : String, listener : Dynamic->Void,
			useCapture : Bool = false, priority : Int = 0,
			useWeakReference : Bool = false) : Void
	{
		super.addEventListener(type, listener, useCapture, priority,
		useWeakReference);
		switch (type)
		{
			case MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.ROLL_OUT, MouseEvent.ROLL_OVER, MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL, DragEvent.DRAG_ENTER, DragEvent.DRAG_OVER, DragEvent.DRAG_DROP, DragEvent.DRAG_EXIT:
				if (++mouseEventReferenceCount > 0)
					hasMouseListeners = true;
		}
	}

	/**
	* @inheritDoc
	*/
	override public function removeEventListener(type : String, listener : Dynamic->Void,
			useCapture : Bool = false) : Void
	{
		super.removeEventListener(type, listener, useCapture);

		switch (type)
		{
			case MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_OUT, MouseEvent.ROLL_OUT, MouseEvent.ROLL_OVER, MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL:
				if (--mouseEventReferenceCount == 0)
					hasMouseListeners = false;
		}
	}

	/**
	* @inheritDoc
	*/
	override private function updateDisplayList(unscaledWidth : Float, unscaledHeight : Float) : Void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		drawBackground();
	}
	/**
	* 绘制鼠标点击区域
	*/
	private function drawBackground() : Void
	{
		if (!_mouseEnabledWhereTransparent || !_hasMouseListeners)
			return;
		graphics.clear();
		if (width == 0 || height == 0)
			return;
		graphics.beginFill(0xFFFFFF, 0);
		if (layout != null && layout.clipAndEnableScrolling)
			graphics.drawRect(layout.horizontalScrollPosition, layout.verticalScrollPosition, width, height)
			else
			{
				var tileSize : Int = 4096;
				var x : Int = 0;
				while (x < width)
				{
					var y : Int = 0;
					while (y < height)
					{
						var tileWidth : Int = Std.int(Math.min(width - x, tileSize));
						var tileHeight : Int = Std.int(Math.min(height - y, tileSize));
						graphics.drawRect(x, y, tileWidth, tileHeight);
						y += tileSize;
					}
					x += tileSize;
				}
			}

		graphics.endFill();
	}
	/**
	* @inheritDoc
	*/
	override private function createChildren() : Void
	{
		super.createChildren();
		createChildrenCalled = true;
		if (elementsContentChanged)
		{
			elementsContentChanged = false;
			setElementsContent(_elementsContent);
		}
	}
	/**
	* 返回子元素列表
	*/
	public function getElementsContent() : Array<IVisualElement>
	{
		return _elementsContent;
	}

	/**
	* 设置容器子对象数组 。数组包含要添加到容器的子项列表，之前的已存在于容器中的子项列表被全部移除后添加列表里的每一项到容器。
	* 设置该属性时会对您输入的数组进行一次浅复制操作，所以您之后对该数组的操作不会影响到添加到容器的子项列表数量。
	*/
	private function set_elementsContent(value : Array<IVisualElement>) : Array<IVisualElement>
	{
		if (value == null)
			value = [];
		if (value == _elementsContent)
			return value;
		if (createChildrenCalled)
		{
			setElementsContent(value);
		}
		else
		{
			elementsContentChanged = true;
			var i : Int = _elementsContent.length - 1;
			while (i >= 0)
			{
				elementRemoved(_elementsContent[i], i);
				i--;
			}
			_elementsContent = value;
		}
		return value;
	}

	/**
	* 设置容器子对象列表
	*/
	private function setElementsContent(value : Array<IVisualElement>) : Void
	{
		var i : Int = _elementsContent.length - 1;
		while (i >= 0)
		{
			elementRemoved(_elementsContent[i], i);
			i--;
		}

		_elementsContent = value.concat([]);

		var n : Int = _elementsContent.length;
		for (i in 0...n)
		{
			var elt : IVisualElement = _elementsContent[i];
			if (Std.is(elt.parent, IVisualElementContainer))
				Lib.as(elt.parent, IVisualElementContainer).removeElement(elt)
				else if (Std.is(elt.owner, IContainer))
					Lib.as(elt.owner, IContainer).removeElement(elt);
			elementAdded(elt, i);
		}
	}
	/**
	* @inheritDoc
	*/
	override private function get_numElements() : Int
	{
		return _elementsContent.length;
	}

	/**
	* @inheritDoc
	*/
	override public function getElementAt(index : Int) : IVisualElement
	{
		#if debug
		checkForRangeError(index);
		#end
		return _elementsContent[index];
	}

	#if debug
	private function checkForRangeError(index : Int, addingElement : Bool = false) : Void
	{
		var maxIndex : Int = _elementsContent.length - 1;

		if (addingElement)
			maxIndex++;

		if (index < 0 || index > maxIndex)
			throw ("索引:\"" + index + "\"超出可视元素索引范围");
	}
	#end

	/**
	* @inheritDoc
	*/
	public function addElement(element : IVisualElement) : IVisualElement
	{
		var index : Int = numElements;

		if (element.parent == this)
			index = numElements - 1;

		return addElementAt(element, index);
	}
	/**
	* @inheritDoc
	*/
	public function addElementAt(element : IVisualElement, index : Int) : IVisualElement
	{
		if (element == this)
			return element;

		#if debug
		checkForRangeError(index, true);
		#end

		var host : Dynamic = element.owner;
		if (host == this)
		{
			setElementIndex(element, index);
			return element;
		}
		else if (Std.is(host, IContainer))
		{
			Lib.as(host, IContainer).removeElement(element);
		}

		_elementsContent.insert(index, element);

		if (!elementsContentChanged)
			elementAdded(element, index);

		return element;
	}
	/**
	* @inheritDoc
	*/
	public function removeElement(element : IVisualElement) : IVisualElement
	{
		return removeElementAt(getElementIndex(element));
	}
	/**
	* @inheritDoc
	*/
	public function removeElementAt(index : Int) : IVisualElement
	{
		#if debug
		checkForRangeError(index);
		#end

		var element : IVisualElement = _elementsContent[index];

		if (!elementsContentChanged)
			elementRemoved(element, index);

		_elementsContent.splice(index, 1);

		return element;
	}
	/**
	* @inheritDoc
	*/
	public function removeAllElements() : Void
	{
		var i : Int = numElements - 1;
		while (i >= 0)
		{
			removeElementAt(i);
			i--;
		}
	}

	/**
	* @inheritDoc
	*/
	override public function getElementIndex(element : IVisualElement) : Int
	{
		return _elementsContent.indexOf(element);
	}
	/**
	* @inheritDoc
	*/
	public function setElementIndex(element : IVisualElement, index : Int) : Void
	{
		#if debug
		checkForRangeError(index);
		#end

		var oldIndex : Int = getElementIndex(element);
		if (oldIndex == -1 || oldIndex == index)
			return;

		if (!elementsContentChanged)
			elementRemoved(element, oldIndex, false);

		_elementsContent.splice(oldIndex, 1);
		_elementsContent.insert(index, element);

		if (!elementsContentChanged)
			elementAdded(element, index, false);
	}
	/**
	* @inheritDoc
	*/
	public function swapElements(element1 : IVisualElement, element2 : IVisualElement) : Void
	{
		swapElementsAt(getElementIndex(element1), getElementIndex(element2));
	}
	/**
	* @inheritDoc
	*/
	public function swapElementsAt(index1 : Int, index2 : Int) : Void
	{
		#if debug
		checkForRangeError(index1);
		checkForRangeError(index2);
		#end

		if (index1 > index2)
		{
			var temp : Int = index2;
			index2 = index1;
			index1 = temp;
		}
		else if (index1 == index2)
			return;

		var element1 : IVisualElement = _elementsContent[index1];
		var element2 : IVisualElement = _elementsContent[index2];
		if (!elementsContentChanged)
		{
			elementRemoved(element1, index1, false);
			elementRemoved(element2, index2, false);
		}

		_elementsContent.splice(index2, 1);
		_elementsContent.splice(index1, 1);

		_elementsContent.insert(index1, element2);
		_elementsContent.insert(index2, element1);

		if (!elementsContentChanged)
		{
			elementAdded(element2, index1, false);
			elementAdded(element1, index2, false);
		}
	}
	/**
	* 添加一个显示元素到容器
	*/
	private function elementAdded(element : IVisualElement, index : Int, notifyListeners : Bool = true) : Void
	{
		if (Std.is(element, DisplayObject))
			addToDisplayListAt(cast element, index);

		if (notifyListeners)
		{
			if (hasEventListener(ElementExistenceEvent.ELEMENT_ADD))
				dispatchEvent(new ElementExistenceEvent(
					ElementExistenceEvent.ELEMENT_ADD, false, false, element, index));
		}

		invalidateSize();
		invalidateDisplayList();
		var loader : URLLoader;
	}
	/**
	* 从容器移除一个显示元素
	*/
	private function elementRemoved(element : IVisualElement, index : Int, notifyListeners : Bool = true) : Void
	{
		if (notifyListeners)
		{
			if (hasEventListener(ElementExistenceEvent.ELEMENT_REMOVE))
				dispatchEvent(new ElementExistenceEvent(
					ElementExistenceEvent.ELEMENT_REMOVE, false, false, element, index));
		}

		var childDO : DisplayObject = cast(element, DisplayObject);
		if (childDO != null && childDO.parent == this)
		{
			removeFromDisplayList(childDO);
		}

		invalidateSize();
		invalidateDisplayList();
	}
	private static inline var errorStr : String = "在此组件中不可用，若此组件为容器类，请使用";
	/**
	* addChild()在此组件中不可用，若此组件为容器类，请使用addElement()代替
	*/
	@:meta(Deprecated())
	override public function addChild(child : DisplayObject) : DisplayObject
	{
		throw (("addChild()" + errorStr + "addElement()代替"));
		return super.addChild(child);
	}
	/**
	* addChildAt()在此组件中不可用，若此组件为容器类，请使用addElementAt()代替
	*/
	@:meta(Deprecated())
	override public function addChildAt(child : DisplayObject, index : Int) : DisplayObject
	{
		throw (("addChildAt()" + errorStr + "addElementAt()代替"));
		return super.addChildAt(child,index);
	}
	/**
	* removeChild()在此组件中不可用，若此组件为容器类，请使用removeElement()代替
	*/
	@:meta(Deprecated())
	override public function removeChild(child : DisplayObject) : DisplayObject
	{
		throw (("removeChild()" + errorStr + "removeElement()代替"));
		return super.removeChild(child);
	}
	/**
	* removeChildAt()在此组件中不可用，若此组件为容器类，请使用removeElementAt()代替
	*/
	@:meta(Deprecated())
	override public function removeChildAt(index : Int) : DisplayObject
	{
		throw (("removeChildAt()" + errorStr + "removeElementAt()代替"));
		return super.removeChildAt(index);
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
