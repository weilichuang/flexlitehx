package flexlite.components;

import flexlite.components.ViewStack;


import flexlite.core.IViewStack;
import flexlite.core.IVisualElement;
import flexlite.events.ElementExistenceEvent;
import flexlite.events.IndexChangeEvent;



@:meta(DXML(show="true"))


/**
* 指示索引即将更改,可以通过调用preventDefault()方法阻止索引发生更改
*/
@:meta(Event(name="changing",type="flexlite.events.IndexChangeEvent"))

/**
* 指示索引已更改  
*/
@:meta(Event(name="change",type="flexlite.events.IndexChangeEvent"))

/**
* Tab导航容器。<br/>
* 使用子项的name属性作为选项卡上显示的字符串。
* @author weilichuang
*/
class TabNavigator extends SkinnableContainer implements IViewStack
{
    private var viewStack(get, never) : ViewStack;
    public var createAllChildren(get, set) : Bool;
    public var selectedChild(get, set) : IVisualElement;
    public var selectedIndex(get, set) : Int;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    override private function get_hostComponentKey() : Dynamic
    {
        return TabNavigator;
    }
    /**
	* [SkinPart]选项卡组件
	*/
	@SkinPart
    public var tabBar : TabBar;
    /**
	* viewStack引用
	*/
    private function get_viewStack() : ViewStack
    {
        return cast(contentGroup, ViewStack);
    }
    /**
	* @inheritDoc
	*/
    override private function get_currentContentGroup() : Group
    {
        if (contentGroup == null) 
        {
            if (_placeHolderGroup == null) 
            {
                _placeHolderGroup = new ViewStack();
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
    
    private var viewStackProperties : Dynamic = { };
    
    private var _createAllChildren : Bool = false;
    /**
	* 是否立即初始化化所有子项。false表示当子项第一次被显示时再初始化它。默认值false。
	*/
    private function get_createAllChildren() : Bool
    {
        return (viewStack != null) ? viewStack.createAllChildren : 
        viewStackProperties.createAllChildren;
    }
    
    private function set_createAllChildren(value : Bool) : Bool
    {
        if (viewStack != null) 
        {
            viewStack.createAllChildren = value;
        }
        else 
        {
            viewStackProperties.createAllChildren = value;
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_selectedChild() : IVisualElement
    {
        return (viewStack != null) ? viewStack.selectedChild : 
        viewStackProperties.selectedChild;
    }
    private function set_selectedChild(value : IVisualElement) : IVisualElement
    {
        if (viewStack != null) 
        {
            viewStack.selectedChild = value;
        }
        else 
        {
            //delete viewStackProperties.selectedIndex;
            viewStackProperties.selectedChild = value;
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    private function get_selectedIndex() : Int
    {
        if (viewStack != null) 
            return viewStack.selectedIndex;
        if (viewStackProperties.selectedIndex != null) 
            return viewStackProperties.selectedIndex;
        return -1;
    }
    private function set_selectedIndex(value : Int) : Int
    {
        if (viewStack != null) 
        {
            viewStack.selectedIndex = value;
        }
        else 
        {
            //delete viewStackProperties.selectedChild;
            viewStackProperties.selectedIndex = value;
        }
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        if (instance == tabBar) 
        {
            if (viewStack != null && tabBar.dataProvider != viewStack) 
                tabBar.dataProvider = viewStack;
            tabBar.selectedIndex = (viewStack != null) ? viewStack.selectedIndex : -1;
            tabBar.addEventListener(IndexChangeEvent.CHANGE, dispatchEvent);
            tabBar.addEventListener(IndexChangeEvent.CHANGING, onTabBarIndexChanging);
        }
        else if (instance == viewStack) 
        {
            if (tabBar != null && tabBar.dataProvider != viewStack) 
                tabBar.dataProvider = viewStack;
            if (viewStackProperties.selectedIndex != null) 
            {
                viewStack.selectedIndex = viewStackProperties.selectedIndex;
            }
            else if (viewStackProperties.selectedChild != null) 
            {
                viewStack.selectedChild = viewStackProperties.selectedChild;
            }
            else if (viewStackProperties.createAllChildren != null) 
            {
                viewStack.createAllChildren = viewStackProperties.createAllChildren;
            }
            viewStackProperties = { };
        }
    }
    
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        if (instance == tabBar) 
        {
            tabBar.dataProvider = null;
            tabBar.removeEventListener(IndexChangeEvent.CHANGE, dispatchEvent);
            tabBar.removeEventListener(IndexChangeEvent.CHANGING, onTabBarIndexChanging);
        }
        else if (instance == viewStack) 
        {
            viewStackProperties.selectedIndex = viewStack.selectedIndex;
        }
    }
    
    /**
	* 传递TabBar的IndexChanging事件
	*/
    private function onTabBarIndexChanging(event : IndexChangeEvent) : Void
    {
        if (!dispatchEvent(event)) 
            event.preventDefault();
    }
    
    /**
	* @inheritDoc
	*/
    override private function createSkinParts() : Void{
    }
    /**
	* @inheritDoc
	*/
    override private function removeSkinParts() : Void{
    }
}
