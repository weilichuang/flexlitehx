package flexlite.components;



import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.events.ElementExistenceEvent;
import flexlite.layouts.supportclasses.LayoutBase;



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
* 可设置外观的容器的基类
* @author weilichuang
*/
class SkinnableContainer extends SkinnableComponent implements IVisualElementContainer
{
    private var currentContentGroup(get, never) : Group;
    public var elementsContent(never, set) : Array<IVisualElement>;
    public var numElements(get, never) : Int;
    public var layout(get, set) : LayoutBase;

    public function new()
    {
        super();
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return SkinnableContainer;
    }
    
    /**
	* [SkinPart]实体容器
	*/
	@SkinPart
    public var contentGroup : Group;
    
    /**
	* 实体容器实例化之前缓存子对象的容器 
	*/
    private var _placeHolderGroup : Group;
    
    /**
	* 获取当前的实体容器
	*/
    private function get_currentContentGroup() : Group
    {
        if (contentGroup == null) 
        {
            if (_placeHolderGroup == null) 
            {
                _placeHolderGroup = new Group();
                _placeHolderGroup.visible = false;
                addToDisplayList(_placeHolderGroup);
            }
            _placeHolderGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
            _placeHolderGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
            return _placeHolderGroup;
        }
        else 
        {
            return contentGroup;
        }
    }
    
    /**
	* 设置容器子对象数组 。数组包含要添加到容器的子项列表，之前的已存在于容器中的子项列表被全部移除后添加列表里的每一项到容器。 
	* 设置该属性时会对您输入的数组进行一次浅复制操作，所以您之后对该数组的操作不会影响到添加到容器的子项列表数量。
	*/
    private function set_elementsContent(value : Array<IVisualElement>) : Array<IVisualElement>
    {
        return currentContentGroup.elementsContent = value;
    }
    /**
	* @inheritDoc
	*/
    private function get_numElements() : Int
    {
        return currentContentGroup.numElements;
    }
    /**
	* @inheritDoc
	*/
    public function getElementAt(index : Int) : IVisualElement
    {
        return currentContentGroup.getElementAt(index);
    }
    /**
	* @inheritDoc
	*/
    public function addElement(element : IVisualElement) : IVisualElement
    {
        return currentContentGroup.addElement(element);
    }
    /**
	* @inheritDoc
	*/
    public function addElementAt(element : IVisualElement, index : Int) : IVisualElement
    {
        return currentContentGroup.addElementAt(element, index);
    }
    /**
	* @inheritDoc
	*/
    public function removeElement(element : IVisualElement) : IVisualElement
    {
        return currentContentGroup.removeElement(element);
    }
    /**
	* @inheritDoc
	*/
    public function removeElementAt(index : Int) : IVisualElement
    {
        return currentContentGroup.removeElementAt(index);
    }
    /**
	* @inheritDoc
	*/
    public function removeAllElements() : Void
    {
        currentContentGroup.removeAllElements();
    }
    /**
	* @inheritDoc
	*/
    public function getElementIndex(element : IVisualElement) : Int
    {
        return currentContentGroup.getElementIndex(element);
    }
    /**
	* @inheritDoc
	*/
    public function setElementIndex(element : IVisualElement, index : Int) : Void
    {
        currentContentGroup.setElementIndex(element, index);
    }
    /**
	* @inheritDoc
	*/
    public function swapElements(element1 : IVisualElement, element2 : IVisualElement) : Void
    {
        currentContentGroup.swapElements(element1, element2);
    }
    /**
	* @inheritDoc
	*/
    public function swapElementsAt(index1 : Int, index2 : Int) : Void
    {
        currentContentGroup.swapElementsAt(index1, index2);
    }
    /**
	* @inheritDoc
	*/
    public function containsElement(element : IVisualElement) : Bool
    {
        return currentContentGroup.containsElement(element);
    }
    
    
    /**
	* contentGroup发生改变时传递的参数
	*/
    private var contentGroupProperties : Dynamic = { };
    
    /**
	* 此容器的布局对象
	*/
    private function get_layout() : LayoutBase
    {
        return contentGroup != null ? contentGroup.layout : contentGroupProperties.layout;
    }
    
    private function set_layout(value : LayoutBase) : LayoutBase
    {
        if (contentGroup != null) 
        {
            contentGroup.layout = value;
        }
        else 
        {
            contentGroupProperties.layout = value;
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
		
        if (instance == contentGroup) 
        {
            if (contentGroupProperties.layout != null) 
            {
                contentGroup.layout = contentGroupProperties.layout;
                contentGroupProperties = { };
            }
			
            if (_placeHolderGroup != null) 
            {
                _placeHolderGroup.removeEventListener(
                        ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
                _placeHolderGroup.removeEventListener(
                        ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
						
                var sourceContent : Array<IVisualElement> = _placeHolderGroup.getElementsContent().concat([]);
				
				var element : IVisualElement;
                var i : Int = _placeHolderGroup.numElements;
                while (i > 0)
				{
                    element = _placeHolderGroup.removeElementAt(0);
                    element.ownerChanged(null);
                    i--;
                }
                removeFromDisplayList(_placeHolderGroup);
                contentGroup.elementsContent = sourceContent;
                i = sourceContent.length - 1;
                while (i >= 0)
				{
                    element = sourceContent[i];
                    element.ownerChanged(this);
                    i--;
                }
                _placeHolderGroup = null;
            }
            contentGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
            contentGroup.addEventListener(
                    ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        if (instance == contentGroup) 
        {
            contentGroup.removeEventListener(
                    ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
            contentGroup.removeEventListener(
                    ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
            contentGroupProperties.layout = contentGroup.layout;
            contentGroup.layout = null;
            if (contentGroup.numElements > 0) 
            {
                _placeHolderGroup = new Group();
                
                while (contentGroup.numElements > 0)
                {
                    _placeHolderGroup.addElement(contentGroup.getElementAt(0));
                }
                _placeHolderGroup.addEventListener(
                        ElementExistenceEvent.ELEMENT_ADD, contentGroup_elementAddedHandler);
                _placeHolderGroup.addEventListener(
                        ElementExistenceEvent.ELEMENT_REMOVE, contentGroup_elementRemovedHandler);
            }
        }
    }
    
    /**
	* 容器添加元素事件
	*/
    private function contentGroup_elementAddedHandler(event : ElementExistenceEvent) : Void
    {
        event.element.ownerChanged(this);
        dispatchEvent(event);
    }
    /**
	* 容器移除元素事件
	*/
    private function contentGroup_elementRemovedHandler(event : ElementExistenceEvent) : Void
    {
        event.element.ownerChanged(null);
        dispatchEvent(event);
    }
    
    /**
	* @inheritDoc
	*/
    override private function createSkinParts() : Void
    {
        contentGroup = new Group();
        contentGroup.percentWidth = 100;
        contentGroup.percentHeight = 100;
        addToDisplayList(contentGroup);
        partAdded("contentGroup", contentGroup);
    }
    
    /**
	* @inheritDoc
	*/
    override private function removeSkinParts() : Void
    {
        partRemoved("contentGroup", contentGroup);
        removeFromDisplayList(contentGroup);
        contentGroup = null;
    }
}
