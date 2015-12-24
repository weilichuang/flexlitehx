package flexlite.components.supportclasses;



import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.Lib;


import flexlite.collections.ICollection;
import flexlite.components.IItemRenderer;
import flexlite.components.List;
import flexlite.events.CollectionEvent;
import flexlite.events.ListEvent;
import flexlite.events.UIEvent;



/**
* 下拉框打开事件
* @eventType flexlite.events.UIEvent.OPEN
*/
@:meta(Event(name="open",type="flexlite.events.UIEvent"))

/**
* 下来框关闭事件
*/
@:meta(Event(name="close",type="flexlite.events.UIEvent"))


@:meta(DXML(show="false"))


@:meta(SkinState(name="normal"))

@:meta(SkinState(name="open"))

@:meta(SkinState(name="disabled"))


/**
* 下拉列表控件基类
* @author weilichuang
*/
class DropDownListBase extends List
{
    private var dropDownController(get, set) : DropDownController;
    public var isDropDownOpen(get, never) : Bool;
    private var userProposedSelectedIndex(get, set) : Int;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        captureItemRenderer = false;
        dropDownController = new DropDownController();
    }
    
    /**
	* [SkinPart]下拉区域显示对象
	*/
	@SkinPart
    public var dropDown : DisplayObject;
    /**
	* [SkinPart]下拉触发按钮
	*/
	@SkinPart
    public var openButton : ButtonBase;
    
    
    private static var PAGE_SIZE : Int = 5;
    
    /**
	* 文本改变标志
	*/
    private var labelChanged : Bool = false;
    
    /**
	* @inheritDoc
	*/
    override private function set_dataProvider(value : ICollection) : ICollection
    {
        if (dataProvider == value) 
            return value;
        
        super.dataProvider = value;
        labelChanged = true;
        invalidateProperties();
        return value;
    }
    /**
	* @inheritDoc
	*/
    override private function set_labelField(value : String) : String
    {
        if (labelField == value) 
            return value;
        
        super.labelField = value;
        labelChanged = true;
        invalidateProperties();
        return value;
    }
    /**
	* @inheritDoc
	*/
    override private function set_labelFunction(value : Dynamic->String) : Dynamic->String
    {
        if (labelFunction == value) 
            return value;
        
        super.labelFunction = value;
        labelChanged = true;
        invalidateProperties();
        return value;
    }
    
    private var _dropDownController : DropDownController;
    /**
	* 下拉控制器
	*/
    private function get_dropDownController() : DropDownController
    {
        return _dropDownController;
    }
    
    private function set_dropDownController(value : DropDownController) : DropDownController
    {
        if (_dropDownController == value) 
            return value;
        
        _dropDownController = value;
        
        _dropDownController.addEventListener(UIEvent.OPEN, dropDownController_openHandler);
        _dropDownController.addEventListener(UIEvent.CLOSE, dropDownController_closeHandler);
        
        if (openButton != null) 
            _dropDownController.openButton = openButton;
        if (dropDown != null) 
            _dropDownController.dropDown = dropDown;
        return value;
    }
    /**
	* 下拉列表是否已经已打开
	*/
    private function get_isDropDownOpen() : Bool
    {
        if (dropDownController != null) 
            return dropDownController.isOpen
        else 
        return false;
    }
    
    private var _userProposedSelectedIndex : Int = ListBase.NO_SELECTION;
    
    private function set_userProposedSelectedIndex(value : Int) : Int
    {
        _userProposedSelectedIndex = value;
        return value;
    }
    
    private function get_userProposedSelectedIndex() : Int
    {
        return _userProposedSelectedIndex;
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (labelChanged) 
        {
            labelChanged = false;
            updateLabelDisplay();
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        
        if (instance == openButton) 
        {
            if (dropDownController != null) 
                dropDownController.openButton = openButton;
        }
        else if (instance == dropDown && dropDownController != null) 
        {
            dropDownController.dropDown = dropDown;
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        if (dropDownController != null) 
        {
            if (instance == openButton) 
                dropDownController.openButton = null;
            
            if (instance == dropDown) 
                dropDownController.dropDown = null;
        }
        
        super.partRemoved(partName, instance);
    }
    
    /**
	* @inheritDoc
	*/
    override private function getCurrentSkinState() : String
    {
        return !(enabled) ? "disabled" : (isDropDownOpen) ? "open" : "normal";
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitSelection(dispatchChangedEvents : Bool = true) : Bool
    {
        var retVal : Bool = super.commitSelection(dispatchChangedEvents);
        updateLabelDisplay();
        return retVal;
    }
    
    /**
	* @inheritDoc
	*/
    override private function isItemIndexSelected(index : Int) : Bool
    {
        return userProposedSelectedIndex == index;
    }
    /**
	* 打开下拉列表并抛出UIEvent.OPEN事件。
	*/
    public function openDropDown() : Void
    {
        dropDownController.openDropDown();
    }
    /**
	* 关闭下拉列表并抛出UIEvent.CLOSE事件。
	*/
    public function closeDropDown(commit : Bool) : Void
    {
        dropDownController.closeDropDown(commit);
    }
    /**
	* 更新选中项的提示文本
	*/
    private function updateLabelDisplay(displayItem : Dynamic = null) : Void
    {
        
        
    }
    /**
	* 改变高亮的选中项
	*/
    private function changeHighlightedSelection(newIndex : Int, scrollToTop : Bool = false) : Void
    {
        itemSelected(userProposedSelectedIndex, false);
        userProposedSelectedIndex = newIndex;
        itemSelected(userProposedSelectedIndex, true);
    }
    
    /**
	* @inheritDoc
	*/
    override private function dataProvider_collectionChangeHandler(event : CollectionEvent) : Void
    {
        super.dataProvider_collectionChangeHandler(event);
        
        labelChanged = true;
        invalidateProperties();
    }
    
    /**
	* @inheritDoc
	*/
    override private function item_mouseDownHandler(event : MouseEvent) : Void
    {
        super.item_mouseDownHandler(event);
        
        var itemRenderer : IItemRenderer = Lib.as(event.currentTarget, IItemRenderer);
        dispatchListEvent(event, ListEvent.ITEM_CLICK, itemRenderer);
        
        userProposedSelectedIndex = selectedIndex;
        closeDropDown(true);
    }
    /**
	* 控制器抛出打开列表事件
	*/
    private function dropDownController_openHandler(event : UIEvent) : Void
    {
        addEventListener(UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
        userProposedSelectedIndex = selectedIndex;
        invalidateSkinState();
    }
    /**
	* 打开列表后组件一次失效验证全部完成
	*/
    private function open_updateCompleteHandler(event : UIEvent) : Void
    {
        removeEventListener(UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
        
        dispatchEvent(new UIEvent(UIEvent.OPEN));
    }
    /**
	* 控制器抛出关闭列表事件
	*/
    private function dropDownController_closeHandler(event : UIEvent) : Void
    {
        addEventListener(UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
        invalidateSkinState();
        
        if (!event.isDefaultPrevented()) 
        {
            setSelectedIndex(userProposedSelectedIndex, true);
        }
        else 
        {
            changeHighlightedSelection(selectedIndex);
        }
    }
    /**
	* 关闭列表后组件一次失效验证全部完成
	*/
    private function close_updateCompleteHandler(event : UIEvent) : Void
    {
        removeEventListener(UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
        
        dispatchEvent(new UIEvent(UIEvent.CLOSE));
    }
}


