package flexlite.managers;

import flash.utils.QName;
import flexlite.core.IContainer;
import flexlite.core.IVisualElement;



@:meta(ExcludeClass())


/**
* SystemManager的虚拟子容器
* @author weilichuang
*/
class SystemContainer implements IContainer
{
    public var numElements(get, never) : Int;

    /**
	* 构造函数
	*/
    public function new(owner : ISystemManager, lowerBoundReference : String, upperBoundReference : String)
    {
        this.owner = owner;
        this.lowerBoundReference = lowerBoundReference;
        this.upperBoundReference = upperBoundReference;
    }
    /**
	* 实体容器
	*/
    private var owner : ISystemManager;
    
    /**
	* 容器下边界属性
	*/
    private var lowerBoundReference : String;
    
    /**
	* 容器上边界属性
	*/
    private var upperBoundReference : String;
    /**
	* @inheritDoc
	*/
    private function get_numElements() : Int
    {
		var up:Int = Reflect.getProperty(owner, upperBoundReference);
		var lower:Int = Reflect.getProperty(owner, lowerBoundReference);
        return up - lower;
    }
	
	private inline function getUpperBoundIndex():Int
	{
		return Reflect.getProperty(owner, upperBoundReference);
	}
	
	private inline function getLowerBoundIndex():Int
	{
		return Reflect.getProperty(owner, lowerBoundReference);
	}
    
    /**
	* @inheritDoc
	*/
    public function getElementAt(index : Int) : IVisualElement
    {
        var retval : IVisualElement = owner.raw_getElementAt(Reflect.getProperty(owner, lowerBoundReference)+ index);
        return retval;
    }
    /**
	* @inheritDoc
	*/
    public function addElement(element : IVisualElement) : IVisualElement
    {
        var index : Int = Reflect.getProperty(owner, Std.string(upperBoundReference));
        if (element.parent == cast owner) 
            index--;
			
		Reflect.setProperty(owner, upperBoundReference,getUpperBoundIndex() + 1);
		
		owner.raw_addElementAt(element, index);

        element.ownerChanged(this);
        return element;
    }
    /**
	* @inheritDoc
	*/
    public function addElementAt(element : IVisualElement, index : Int) : IVisualElement
    {
		Reflect.setProperty(owner, upperBoundReference,getUpperBoundIndex() + 1);
		
		owner.raw_addElementAt(element, getLowerBoundIndex() + index);

        element.ownerChanged(this);
        return element;
    }
    /**
	* @inheritDoc
	*/
    public function removeElement(element : IVisualElement) : IVisualElement
    {
        var index : Int = owner.raw_getElementIndex(element);
        if (getLowerBoundIndex() <= index && index < getUpperBoundIndex()) 
        {
			owner.raw_removeElement(element);
			
			Reflect.setProperty(owner, upperBoundReference,getUpperBoundIndex() - 1);
        }
        element.ownerChanged(null);
        return element;
    }
    /**
	* @inheritDoc
	*/
    public function removeElementAt(index : Int) : IVisualElement
    {
        index += Reflect.getProperty(owner, lowerBoundReference);
		
        var element : IVisualElement = null;
        if (Reflect.getProperty(owner, lowerBoundReference) <= index &&
			index < Reflect.getProperty(owner, upperBoundReference)) 
        {
            element = owner.raw_removeElementAt(index);
			
			Reflect.setProperty(owner, upperBoundReference, getUpperBoundIndex() - 1);
			
			element.ownerChanged(null);
        }
        return element;
    }
    /**
	* @inheritDoc
	*/
    public function getElementIndex(element : IVisualElement) : Int
    {
        var retval : Int = owner.raw_getElementIndex(element);
        retval -= getLowerBoundIndex();
        return retval;
    }
    /**
	* @inheritDoc
	*/
    public function setElementIndex(element : IVisualElement, index : Int) : Void
    {
		owner.raw_setElementIndex(element, Reflect.getProperty(owner, lowerBoundReference) + index);
    }
}
