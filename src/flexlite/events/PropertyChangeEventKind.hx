package flexlite.events;


/**
* PropertyChangeEventKind 类定义 PropertyChangeEvent 类的 kind 属性的常量值。
* @author weilichuang
*/
class PropertyChangeEventKind
{
    /**
	* 指示该属性的值已更改。 
	*/
    public static inline var UPDATE : String = "update";
    
    /**
	* 指示该属性已从此对象中删除。
	*/
    public static inline var DELETE : String = "delete";

    public function new()
    {
    }
}
