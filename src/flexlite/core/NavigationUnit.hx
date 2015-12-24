package flexlite.core;


import flash.ui.Keyboard;

/**
* NavigationUnit 类为 IViewport 类的getVerticalScrollPositionDelta() 
* 和 getHorizontalScrollPositionDelta() 方法定义可能的值。 
* @author weilichuang
*/
@:final class NavigationUnit
{
    /**
	* 导航到文档的开头。 
	*/
    public static var HOME : Int = Keyboard.HOME;
    /**
	* 导航到文档的末尾。 
	*/
    public static var END : Int = Keyboard.END;
    /**
	* 向上导航一行或向上“步进”。 
	*/
    public static var UP : Int = Keyboard.UP;
    /**
	* 向上导航一行或向上“步进”。
	*/
    public static var DOWN : Int = Keyboard.DOWN;
    /**
	* 向上导航一行或向上“步进”。 
	*/
    public static var LEFT : Int = Keyboard.LEFT;
    /**
	* 向右导航一行或向右“步进”。
	*/
    public static var RIGHT : Int = Keyboard.RIGHT;
    /**
	* 向上导航一页。
	*/
    public static var PAGE_UP : Int = Keyboard.PAGE_UP;
    /**
	* 向下导航一页。
	*/
    public static var PAGE_DOWN : Int = Keyboard.PAGE_DOWN;
    /**
	* 向左导航一页。
	*/
    public static inline var PAGE_LEFT : Int = 0x2397;
    /**
	* 向左导航一页。
	*/
    public static inline var PAGE_RIGHT : Int = 0x2398;
}

