package flexlite.managers;


import flash.display.Stage;
import flash.events.IEventDispatcher;
import flexlite.core.IVisualElement;

import flexlite.core.IContainer;

/**
* 
* @author weilichuang
*/
interface ISystemManager extends IEventDispatcher
{
    
    /**
	* 弹出窗口层容器。
	*/
    var popUpContainer(get, never) : IContainer;    
    /**
	* 工具提示层容器。
	*/
    var toolTipContainer(get, never) : IContainer;    
    /**
	* 鼠标样式层容器。
	*/
    var cursorContainer(get, never) : IContainer;    
    /**
	* 舞台引用
	*/
    function getStage() : Stage;

	function get_raw_numElements() : Int;
    function raw_getElementAt(index : Int) : IVisualElement;
    function raw_addElement(element : IVisualElement) : IVisualElement;
    function raw_addElementAt(element : IVisualElement, index : Int) : IVisualElement;
    function raw_removeElement(element : IVisualElement) : IVisualElement;
    function raw_removeElementAt(index : Int) : IVisualElement;
    function raw_removeAllElements() : Void;
    function raw_getElementIndex(element : IVisualElement) : Int;
    function raw_setElementIndex(element : IVisualElement, index : Int) : Void;
    function raw_swapElements(element1 : IVisualElement, element2 : IVisualElement) : Void;
    function raw_swapElementsAt(index1 : Int, index2 : Int) : Void;
    function raw_containsElement(element : IVisualElement) : Bool;
}
