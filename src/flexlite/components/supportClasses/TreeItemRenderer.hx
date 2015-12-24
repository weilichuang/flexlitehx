package flexlite.components.supportclasses;


import flash.display.DisplayObject;
import flash.events.MouseEvent;


import flexlite.components.ITreeItemRenderer;
import flexlite.core.ISkinnableClient;
import flexlite.events.TreeEvent;



@:meta(DXML(show="false"))


/**
* Tree组件的项呈示器基类
* @author weilichuang
*/
class TreeItemRenderer extends ItemRenderer implements ITreeItemRenderer
{
    public var indentation(get, set) : Float;
    public var iconSkinName(get, set) : Dynamic;
    public var depth(get, set) : Int;
    public var hasChildren(get, set) : Bool;
    public var opened(get, set) : Bool;

    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        addEventListener(MouseEvent.MOUSE_DOWN, onItemMouseDown, false, 1000);
    }
    
    private function onItemMouseDown(event : MouseEvent) : Void
    {
        if (event.target == disclosureButton) 
        {
            event.stopImmediatePropagation();
        }
    }
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return TreeItemRenderer;
    }
    
    /**
	* [SkinPart]图标显示对象
	*/
	@SkinPart
    public var iconDisplay : ISkinnableClient;
    /**
	* [SkinPart]子节点开启按钮
	*/
	@SkinPart
    public var disclosureButton : ToggleButtonBase;
    /**
	* [SkinPart]用于调整缩进值的容器对象。
	*/
	@SkinPart
    public var contentGroup : DisplayObject;
    
    private var _indentation : Float = 17;
    /**
	* 子节点相对父节点的缩进值，以像素为单位。默认17。
	*/
    private function get_indentation() : Float
    {
        return _indentation;
    }
    private function set_indentation(value : Float) : Float
    {
        _indentation = value;
        return value;
    }
    
    private var _iconSkinName : Dynamic;
    /**
	* @inheritDoc
	*/
    private function get_iconSkinName() : Dynamic
    {
        return _iconSkinName;
    }
    private function set_iconSkinName(value : Dynamic) : Dynamic
    {
        if (_iconSkinName == value) 
            return value;
        _iconSkinName = value;
        if (iconDisplay != null) 
        {
            iconDisplay.skinName = _iconSkinName;
        }
        return value;
    }
    
    private var _depth : Int = 0;
    /**
	* @inheritDoc
	*/
    private function get_depth() : Int
    {
        return _depth;
    }
    private function set_depth(value : Int) : Int
    {
        if (value == _depth) 
            return value;
        _depth = value;
        if (contentGroup != null) 
        {
            contentGroup.x = _depth * _indentation;
        }
        return value;
    }
    
    private var _hasChildren : Bool = false;
    /**
	* @inheritDoc
	*/
    private function get_hasChildren() : Bool
    {
        return _hasChildren;
    }
    private function set_hasChildren(value : Bool) : Bool
    {
        if (_hasChildren == value) 
            return value;
        _hasChildren = value;
        if (disclosureButton != null) 
        {
            disclosureButton.visible = _hasChildren;
        }
        return value;
    }
    
    private var _isOpen : Bool = false;
    /**
	* @inheritDoc
	*/
    private function get_opened() : Bool
    {
        return _isOpen;
    }
    private function set_opened(value : Bool) : Bool
    {
        if (_isOpen == value) 
            return value;
        _isOpen = value;
        if (disclosureButton != null) 
        {
            disclosureButton.selected = _isOpen;
        }
        return value;
    }
    
    override private function partAdded(partName : String, instance : Dynamic) : Void
    {
        super.partAdded(partName, instance);
        if (instance == iconDisplay) 
        {
            iconDisplay.skinName = _iconSkinName;
        }
        else if (instance == disclosureButton) 
        {
            disclosureButton.visible = _hasChildren;
            disclosureButton.selected = _isOpen;
            disclosureButton.autoSelected = false;
            disclosureButton.addEventListener(MouseEvent.MOUSE_DOWN,
                    disclosureButton_mouseDownHandler);
        }
        else if (instance == contentGroup) 
        {
            contentGroup.x = _depth * _indentation;
        }
    }
    
    override private function partRemoved(partName : String, instance : Dynamic) : Void
    {
        super.partRemoved(partName, instance);
        if (instance == iconDisplay) 
        {
            iconDisplay.skinName = null;
        }
        else if (instance == disclosureButton) 
        {
            disclosureButton.removeEventListener(MouseEvent.MOUSE_DOWN,
                    disclosureButton_mouseDownHandler);
            disclosureButton.autoSelected = true;
            disclosureButton.visible = true;
        }
    }
    /**
	* 鼠标在disclosureButton上按下
	*/
    private function disclosureButton_mouseDownHandler(event : MouseEvent) : Void
    {
        var evt : TreeEvent = new TreeEvent(TreeEvent.ITEM_OPENING, 
        false, true, itemIndex, data, this);
        evt.opening = !_isOpen;
        dispatchEvent(evt);
    }
}
