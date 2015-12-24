package flexlite.components;

import nme.errors.RangeError;
import flexlite.components.QName;

import flash.display.DisplayObject;
import flash.events.EventDispatcher;


import flexlite.core.IContainer;
import flexlite.core.ISkin;
import flexlite.core.IStateClient;
import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.events.ElementExistenceEvent;
import flexlite.events.StateChangeEvent;
import flexlite.states.StateClientHelper;



/**
* 元素添加事件
*/
@:meta(Event(name="elementAdd",type="flexlite.events.ElementExistenceEvent"))

/**
* 元素移除事件 
*/
@:meta(Event(name="elementRemove",type="flexlite.events.ElementExistenceEvent"))


/**
* 当前视图状态已经改变 
*/
@:meta(Event(name="currentStateChange",type="flexlite.events.StateChangeEvent"))

/**
* 当前视图状态即将改变 
*/
@:meta(Event(name="currentStateChanging",type="flexlite.events.StateChangeEvent"))


@:meta(DXML(show="false"))


@:meta(DefaultProperty(name="elementsContent",array="true"))


/**
* 含有视图状态功能的皮肤基类。注意：为了减少嵌套层级，此皮肤没有继承显示对象，若需要显示对象版本皮肤，请使用Skin。
* @see flexlite.components.supportclasses.Skin
* @author weilichuang
*/
class StateSkin extends EventDispatcher implements IStateClient implements ISkin implements IContainer
{
    public var states(get, set) : Array<Dynamic>;
    public var currentState(get, set) : String;
    public var hostComponent(get, set) : SkinnableComponent;
    public var elementsContent(never, set) : Array<Dynamic>;
    public var numElements(get, never) : Int;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        stateClientHelper = new StateClientHelper(this);
    }
    
    /**
	* 组件的最大测量宽度,仅影响measuredWidth属性的取值范围。
	*/
    public var maxWidth : Float = 10000;
    /**
	* 组件的最小测量宽度,此属性设置为大于maxWidth的值时无效。仅影响measuredWidth属性的取值范围。
	*/
    public var minWidth : Float = 0;
    /**
	* 组件的最大测量高度,仅影响measuredHeight属性的取值范围。
	*/
    public var maxHeight : Float = 10000;
    /**
	* 组件的最小测量高度,此属性设置为大于maxHeight的值时无效。仅影响measuredHeight属性的取值范围。
	*/
    public var minHeight : Float = 0;
    /**
	* 组件宽度
	*/
    public var width : Float = NaN;
    /**
	* 组件高度
	*/
    public var height : Float = NaN;
    
    /**
	* x坐标
	*/
    public var x : Float = 0;
    /**
	* y坐标 
	*/
    public var y : Float = 0;
    
    //以下这两个属性无效，仅用于防止DXML编译器报错。
    public var percentWidth : Float = NaN;
    public var percentHeight : Float = NaN;
    
    //========================state相关函数===============start=========================
    
    private var stateClientHelper : StateClientHelper;
    
    /**
	* @inheritDoc
	*/
    private function get_states() : Array<Dynamic>
    {
        return stateClientHelper.states;
    }
    
    private function set_states(value : Array<Dynamic>) : Array<Dynamic>
    {
        stateClientHelper.states = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_currentState() : String
    {
        return stateClientHelper.currentState;
    }
    
    private function set_currentState(value : String) : String
    {
        stateClientHelper.currentState = value;
        if (_hostComponent && stateClientHelper.currentStateChanged) 
        {
            stateClientHelper.commitCurrentState();
            commitCurrentState();
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    public function hasState(stateName : String) : Bool
    {
        return stateClientHelper.hasState(stateName);
    }
    
    /**
	* 应用当前的视图状态。子类覆盖此方法在视图状态发生改变时执行相应更新操作。
	*/
    private function commitCurrentState() : Void
    {
        
        
    }
    //========================state相关函数===============end=========================
    private var initialized : Bool = false;
    /**
	* 创建子项,子类覆盖此方法以完成组件子项的初始化操作，
	* 请务必调用super.createChildren()以完成父类组件的初始化
	*/
    private function createChildren() : Void{
        
        
    }
    
    private var _hostComponent : SkinnableComponent;
    /**
	* @inheritDoc
	*/
    private function get_hostComponent() : SkinnableComponent
    {
        return _hostComponent;
    }
    /**
	* @inheritDoc
	*/
    private function set_hostComponent(value : SkinnableComponent) : SkinnableComponent
    {
        if (_hostComponent == value) 
            return;
        var i : Int;
        if (_hostComponent != null) 
        {
            i = _elementsContent.length - 1;
            while (i >= 0){
                elementRemoved(_elementsContent[i], i);
                i--;
            }
        }
        
        _hostComponent = value;
        if (!initialized) {
            initialized = true;
            createChildren();
        }
        if (_hostComponent != null) 
        {
            var n : Int = _elementsContent.length;
            for (i in 0...n){
                elementAdded(_elementsContent[i], i);
            }
            
            stateClientHelper.initializeStates();
            
            if (stateClientHelper.currentStateChanged) 
            {
                stateClientHelper.commitCurrentState();
                commitCurrentState();
            }
        }
        return value;
    }
    
    private var _elementsContent : Array<Dynamic> = [];
    /**
	* 返回子元素列表
	*/
    private function getElementsContent() : Array<Dynamic>
    {
        return _elementsContent;
    }
    
    /**
	* 设置容器子对象数组 。数组包含要添加到容器的子项列表，之前的已存在于容器中的子项列表被全部移除后添加列表里的每一项到容器。
	* 设置该属性时会对您输入的数组进行一次浅复制操作，所以您之后对该数组的操作不会影响到添加到容器的子项列表数量。
	*/
    private function set_alementsContent(value : Array<Dynamic>) : Array<Dynamic>
    {
        if (value == null) 
            value = [];
        if (value == _elementsContent) 
            return;
        if (_hostComponent != null) 
        {
            var i : Int;
            i = _elementsContent.length - 1;
            while (i >= 0){
                elementRemoved(_elementsContent[i], i);
                i--;
            }
            
            _elementsContent = value.concat();
            
            var n : Int = _elementsContent.length;
            for (i in 0...n){
                
                var elt : IVisualElement = _elementsContent[i];
                
                if (Std.is(elt.parent, IVisualElementContainer)) 
                    Lib.as((elt.parent), IVisualElementContainer).removeElement(elt)
                else if (Std.is(elt.owner, IContainer)) 
                    Lib.as((elt.owner), IContainer).removeElement(elt);
                elementAdded(elt, i);
            }
        }
        else 
        {
            _elementsContent = value.concat();
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_numElements() : Int
    {
        return _elementsContent.length;
    }
    
    /**
	* @inheritDoc
	*/
    public function getElementAt(index : Int) : IVisualElement
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
            throw new RangeError("索引:\"" + index + "\"超出可视元素索引范围");
    }
	#end
	
    /**
	* @inheritDoc
	*/
    public function addElement(element : IVisualElement) : IVisualElement
    {
        var index : Int = numElements;
        
        if (element.owner == this) 
            index = numElements - 1;
        
        return addElementAt(element, index);
    }
    /**
	* @inheritDoc
	*/
    public function addElementAt(element : IVisualElement, index : Int) : IVisualElement
    {
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
        
        _elementsContent.splice(index, 0, element);
        
        if (_hostComponent != null) 
            elementAdded(element, index)
        else 
        element.ownerChanged(this);
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
        
        if (_hostComponent != null) 
            elementRemoved(element, index)
        else 
        element.ownerChanged(null);
        _elementsContent.splice(index, 1);
        
        return element;
    }
    
    /**
	* @inheritDoc
	*/
    public function getElementIndex(element : IVisualElement) : Int
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
        
        if (_hostComponent != null) 
            elementRemoved(element, oldIndex, false);
        
        _elementsContent.splice(oldIndex, 1);
        _elementsContent.splice(index, 0, element);
        
        if (_hostComponent != null) 
            elementAdded(element, index, false);
    }
    
    private var addToDisplayListAt : QName = new QName(dx_internal, "addToDisplayListAt");
    private var removeFromDisplayList : QName = new QName(dx_internal, "removeFromDisplayList");
    /**
	* 添加一个显示元素到容器
	*/
    private function elementAdded(element : IVisualElement, index : Int, notifyListeners : Bool = true) : Void
    {
        element.ownerChanged(this);
        if (Std.is(element, DisplayObject)) 
            Reflect.field(_hostComponent, Std.string(addToDisplayListAt))(cast element), index);
        
        if (notifyListeners) 
        {
            if (hasEventListener(ElementExistenceEvent.ELEMENT_ADD)) 
                dispatchEvent(new ElementExistenceEvent(
                    ElementExistenceEvent.ELEMENT_ADD, false, false, element, index));
        }
        
        _hostComponent.invalidateSize();
        _hostComponent.invalidateDisplayList();
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
        if (childDO != null && childDO.parent == _hostComponent) 
        {
            Reflect.field(_hostComponent, Std.string(removeFromDisplayList))(element);
        }
        
        element.ownerChanged(null);
        _hostComponent.invalidateSize();
        _hostComponent.invalidateDisplayList();
    }
}
