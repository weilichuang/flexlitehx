package flexlite.managers.impl;


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.Lib;
import flash.utils.Dictionary;
import haxe.ds.ObjectMap;
import haxe.ds.WeakMap;

import flexlite.components.Rect;
import flexlite.core.FlexLiteGlobals;
import flexlite.core.IContainer;
import flexlite.core.IInvalidating;
import flexlite.core.IUIComponent;
import flexlite.core.IVisualElement;
import flexlite.core.IVisualElementContainer;
import flexlite.managers.IPopUpManager;
import flexlite.managers.ISystemManager;

@:meta(ExcludeClass())


/**
* 窗口弹出管理器实现类
* @author weilichuang
*/



class PopUpManagerImpl extends EventDispatcher implements IPopUpManager
{
    public var popUpList(get, never) : Array<IVisualElement>;
    public var modalColor(get, set) : Int;
    public var modalAlpha(get, set) : Float;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        
    }
    
    private var _popUpList : Array<IVisualElement> = [];
    /**
	* 已经弹出的窗口列表
	*/
    private function get_popUpList() : Array<IVisualElement>
    {
        return _popUpList.concat([]);
    }
    /**
	* 模态窗口列表
	*/
    private var popUpDataList : Array<PopUpData> = new Array<PopUpData>();
    /**
	* 根据popUp获取对应的popUpData
	*/
    private function findPopUpData(popUp : IVisualElement) : PopUpData
    {
        for (data in popUpDataList)
        {
            if (data.popUp == popUp) 
                return data;
        }
        return null;
    }
    
    private static inline var REMOVE_FROM_SYSTEMMANAGER : String = "removeFromSystemManager";
    /**
	* 弹出一个窗口。<br/>
	* @param popUp 要弹出的窗口
	* @param modal 是否启用模态。即禁用弹出窗口所在层以下的鼠标事件。默认false。
	* @param center 是否居中窗口。等效于在外部调用centerPopUp()来居中。默认true。
	* @param systemManager 要弹出到的系统管理器。若项目中只含有一个系统管理器，则可以留空。
	*/
    public function addPopUp(popUp : IVisualElement, modal : Bool = false,
            center : Bool = true, systemManager : ISystemManager = null) : Void
    {
        if (systemManager == null) 
            systemManager = FlexLiteGlobals.systemManager;
        if (systemManager == null) 
            return;
			
        var data : PopUpData = findPopUpData(popUp);
        if (data != null) 
        {
            data.modal = modal;
            popUp.removeEventListener(REMOVE_FROM_SYSTEMMANAGER, onRemoved);
        }
        else 
        {
            data = new PopUpData(popUp, modal);
            popUpDataList.push(data);
            _popUpList.push(popUp);
        }
        systemManager.popUpContainer.addElement(popUp);
        if (center) 
            centerPopUp(popUp);
			
        if (Std.is(popUp, IUIComponent)) 
            cast(popUp, IUIComponent).isPopUp = true;
			
        if (modal) 
        {
            invalidateModal(systemManager);
        }
        popUp.addEventListener(REMOVE_FROM_SYSTEMMANAGER, onRemoved);
    }
    
    /**
	* 从舞台移除
	*/
    private function onRemoved(event : Event) : Void
    {
        var index : Int = 0;
        for (data in popUpDataList)
        {
            if (data.popUp == event.target) 
            {
                if (Std.is(data.popUp, IUIComponent)) 
                    cast(data.popUp, IUIComponent).isPopUp = false;
                data.popUp.removeEventListener(REMOVE_FROM_SYSTEMMANAGER, onRemoved);
                popUpDataList.splice(index, 1);
                _popUpList.splice(index, 1);
                invalidateModal(cast data.popUp.parent);
                break;
            }
            index++;
        }
    }
    
    
    private var _modalColor : Int = 0x000000;
    /**
	* 模态遮罩的填充颜色
	*/
    private function get_modalColor() : Int
    {
        return _modalColor;
    }
    private function set_modalColor(value : Int) : Int
    {
        if (_modalColor == value) 
            return value;
        _modalColor = value;
        invalidateModal(FlexLiteGlobals.systemManager);
        return value;
    }
    
    private var _modalAlpha : Float = 0.5;
    /**
	* 模态遮罩的透明度
	*/
    private function get_modalAlpha() : Float
    {
        return _modalAlpha;
    }
    private function set_modalAlpha(value : Float) : Float
    {
        if (_modalAlpha == value) 
            return value;
        _modalAlpha = value;
        invalidateModal(FlexLiteGlobals.systemManager);
        return value;
    }
    
    /**
	* 模态层失效的SystemManager列表
	*/
    private var invalidateModalList : Array<ISystemManager> = new Array<ISystemManager>();
    
    private var invalidateModalFlag : Bool = false;
    /**
	* 标记一个SystemManager的模态层失效
	*/
    private function invalidateModal(systemManager : ISystemManager) : Void
    {
        if (systemManager == null) 
            return;
        if (invalidateModalList.indexOf(systemManager) == -1) 
            invalidateModalList.push(systemManager);
        if (!invalidateModalFlag) 
        {
            invalidateModalFlag = true;
            FlexLiteGlobals.stage.addEventListener(Event.ENTER_FRAME, validateModal);
            FlexLiteGlobals.stage.addEventListener(Event.RENDER, validateModal);
            FlexLiteGlobals.stage.invalidate();
        }
    }
    
    private function validateModal(event : Event) : Void
    {
        invalidateModalFlag = false;
        FlexLiteGlobals.stage.removeEventListener(Event.ENTER_FRAME, validateModal);
        FlexLiteGlobals.stage.removeEventListener(Event.RENDER, validateModal);
        for (sm in invalidateModalList)
        {
            updateModal(sm);
        }
        invalidateModalList = [];
    }
    
    private var modalMaskDic : WeakMap<ISystemManager,Rect> = new WeakMap<ISystemManager,Rect>();
    /**
	* 更新窗口模态效果
	*/
    private function updateModal(systemManager : ISystemManager) : Void
    {
        var popUpContainer : IContainer = systemManager.popUpContainer;
        var found : Bool = false;
        var i : Int = popUpContainer.numElements - 1;
        while (i >= 0){
            var element : IVisualElement = popUpContainer.getElementAt(i);
            var data : PopUpData = findPopUpData(element);
            if (data != null && data.modal) 
            {
                found = true;
                break;
            }
            i--;
        }
        var modalMask : Rect = modalMaskDic.get(systemManager);
        if (found) 
        {
            if (modalMask == null) 
			{
				modalMask = new Rect();
				modalMaskDic.set(systemManager, modalMask);
				modalMask.top = modalMask.left = modalMask.right = modalMask.bottom = 0;
			}
			(cast(modalMask, Rect)).fillColor = _modalColor;
            modalMask.alpha = _modalAlpha;
            if (modalMask.parent == (cast systemManager)) 
            {
                if (popUpContainer.getElementIndex(modalMask) < i) 
                    i--;
                popUpContainer.setElementIndex(modalMask, i);
            }
            else 
            {
                popUpContainer.addElementAt(modalMask, i);
            }
        }
        else if (modalMask != null && modalMask.parent == (cast systemManager)) 
        {
            popUpContainer.removeElement(modalMask);
        }
    }
    
    /**
	* 移除由addPopUp()方法弹出的窗口。
	* @param popUp 要移除的窗口
	*/
    public function removePopUp(popUp : IVisualElement) : Void
    {
        if (popUp != null && popUp.parent != null && findPopUpData(popUp) != null) 
        {
            if (Std.is(popUp.parent, IVisualElementContainer)) 
                Lib.as(popUp.parent, IVisualElementContainer).removeElement(popUp)
            else if (Std.is(popUp, DisplayObject)) 
                popUp.parent.removeChild(cast((popUp), DisplayObject));
        }
    }
    
    /**
	* 将指定窗口居中显示
	* @param popUp 要居中显示的窗口
	*/
    public function centerPopUp(popUp : IVisualElement) : Void
    {
        popUp.top = popUp.bottom = popUp.left = popUp.right = Math.NaN;
        popUp.verticalCenter = popUp.horizontalCenter = 0;
        var parent : DisplayObjectContainer = popUp.parent;
        if (parent != null) 
        {
            if (Std.is(popUp, IInvalidating)) 
                Lib.as(popUp, IInvalidating).validateNow();
            popUp.x = (parent.width - popUp.layoutBoundsWidth) * 0.5;
            popUp.y = (parent.height - popUp.layoutBoundsHeight) * 0.5;
        }
    }
    
    /**
	* 将指定窗口的层级调至最前
	* @param popUp 要最前显示的窗口
	*/
    public function bringToFront(popUp : IVisualElement) : Void
    {
        var data : PopUpData = findPopUpData(popUp);
        if (data != null && Std.is(popUp.parent, ISystemManager)) 
        {
            var sm : ISystemManager = Lib.as(popUp.parent, ISystemManager);
            sm.popUpContainer.setElementIndex(popUp, sm.popUpContainer.numElements - 1);
            invalidateModal(sm);
        }
    }
}


class PopUpData
{
    public function new(popUp : IVisualElement, modal : Bool)
    {
        this.popUp = popUp;
        this.modal = modal;
    }
    
    public var popUp : IVisualElement;
    
    public var modal : Bool;
}
