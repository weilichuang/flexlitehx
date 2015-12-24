package flexlite.states;


import flexlite.components.SkinnableComponent;
import flexlite.core.IContainer;
import flexlite.core.ISkinnableClient;
import flexlite.core.IStateClient;
import flexlite.core.IVisualElement;
import flexlite.states.OverrideBase;
import org.flexlite.domui.states.QName;





/**
* 添加显示元素
* @author weilichuang
*/
class AddItems extends OverrideBase
{
    /**
	* 添加父级容器的底层
	*/
    public static inline var FIRST : String = "first";
    /**
	* 添加在父级容器的顶层 
	*/
    public static inline var LAST : String = "last";
    /**
	* 添加在相对对象之前 
	*/
    public static inline var BEFORE : String = "before";
    /**
	* 添加在相对对象之后 
	*/
    public static inline var AFTER : String = "after";
    
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
    }
    
    /**
	* 要添加到的属性 
	*/
    public var propertyName : String = "";
    
    /**
	* 添加的位置 
	*/
    public var position : String = AddItems.LAST;
    
    /**
	* 相对的显示元素的实例名
	*/
    public var relativeTo : String;
    
    /**
	* 目标实例名
	*/
    public var target : String;
    
    private var INITIALIZE_FUNCTION : QName = new QName(dx_internal, "initialize");
    
    override public function initialize(parent : IStateClient) : Void
    {
        var targetElement : IVisualElement = Lib.as(Reflect.field(parent, target), IVisualElement);
        if (targetElement == null || Std.is(targetElement, SkinnableComponent)) 
            return  //让UIAsset和UIMovieClip等素材组件立即开始初始化，防止延迟闪一下或首次点击失效的问题。  ;
        
        if (Std.is(targetElement, ISkinnableClient)) 
        {
            try
            {
                Reflect.field(targetElement, Std.string(INITIALIZE_FUNCTION))();
            }            catch (e : Error)
            {
                
            }
        }
    }
    
    override public function apply(parent : IContainer) : Void
    {
        var index : Int;
        var relative : IVisualElement;
        try
        {
            relative = Lib.as(Reflect.field(parent, relativeTo), IVisualElement);
        }        catch (e : Error)
        {
            
        }
        var targetElement : IVisualElement = Lib.as(Reflect.field(parent, target), IVisualElement);
        var dest : IContainer = (propertyName != null) ? Reflect.field(parent, propertyName) : Lib.as(parent, IContainer);
        if (targetElement == null || dest == null) 
            return;
        switch (position)
        {
            case FIRST:
                index = 0;
            case LAST:
                index = -1;
            case BEFORE:
                index = dest.getElementIndex(relative);
            case AFTER:
                index = dest.getElementIndex(relative) + 1;
        }
        if (index == -1) 
            index = dest.numElements;
        dest.addElementAt(targetElement, index);
    }
    
    override public function remove(parent : IContainer) : Void
    {
        var dest : IContainer = propertyName == null || propertyName == ("") ? 
        parent : Lib.as(Reflect.field(parent, propertyName), IContainer);
        var targetElement : IVisualElement = Lib.as(Reflect.field(parent, target), IVisualElement);
        if (targetElement == null || dest == null) 
            return;
        if (dest.getElementIndex(targetElement) != -1) 
        {
            dest.removeElement(targetElement);
        }
    }
}


