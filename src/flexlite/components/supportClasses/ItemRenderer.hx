package flexlite.components.supportclasses;




import flexlite.components.IItemRenderer;

@:meta(DXML(show="false"))


/**
* 项呈示器基类
* @author weilichuang
*/
class ItemRenderer extends ButtonBase implements IItemRenderer
{
    public var data(get, set) : Dynamic;
    public var selected(get, set) : Bool;
    public var itemIndex(get, set) : Int;

    public function new()
    {
        super();
        mouseChildren = true;
        buttonMode = false;
        useHandCursor = false;
    }
    
    /**
	* @inheritDoc
	*/
    override private function get_hostComponentKey() : Dynamic
    {
        return ItemRenderer;
    }
    
    private var dataChangedFlag : Bool = false;
    private var _data : Dynamic;
    /**
	* @inheritDoc
	*/
    private function get_data() : Dynamic
    {
        return _data;
    }
    /**
	* @inheritDoc
	*/
    private function set_data(value : Dynamic) : Dynamic
    {
        //这里不能加if(_data==value)return;的判断，会导致数据源无法刷新的问题
        _data = value;
        if (initialized || parent != null) 
        {
            dataChangedFlag = false;
            dataChanged();
        }
        else 
        {
            dataChangedFlag = true;
            invalidateProperties();
        }
        return value;
    }
    /**
	* 子类复写此方法以在data数据源发生改变时跟新显示列表。
	* 与直接复写data的setter方法不同，它会确保在皮肤已经附加完成后再被调用。
	*/
    private function dataChanged() : Void
    {
        
        
    }
    
    private var _selected : Bool = false;
    /**
	* @inheritDoc
	*/
    private function get_selected() : Bool
    {
        return _selected;
    }
    
    private function set_selected(value : Bool) : Bool
    {
        if (_selected == value) 
            return value;
        _selected = value;
        invalidateSkinState();
        return value;
    }
    
    private var _itemIndex : Int = -1;
    /**
	* @inheritDoc
	*/
    private function get_itemIndex() : Int
    {
        return _itemIndex;
    }
    
    private function set_itemIndex(value : Int) : Int
    {
        _itemIndex = value;
        return value;
    }
    
    /**
	* @inheritDoc
	*/
    override private function commitProperties() : Void
    {
        super.commitProperties();
        if (dataChangedFlag) 
        {
            dataChangedFlag = false;
            dataChanged();
        }
    }
    
    /**
	* @inheritDoc
	*/
    override private function getCurrentSkinState() : String
    {
        if (_selected) 
            return "selected";
        return super.getCurrentSkinState();
    }
}
