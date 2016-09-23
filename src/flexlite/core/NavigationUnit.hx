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
    public static inline var HOME : Int = 36;
    /**
	* 导航到文档的末尾。 
	*/
    public static inline var END : Int = 35;
    /**
	* 向上导航一行或向上“步进”。 
	*/
    public static inline var UP : Int = 38;
    /**
	* 向上导航一行或向上“步进”。
	*/
    public static inline var DOWN : Int = 40;
    /**
	* 向上导航一行或向上“步进”。 
	*/
    public static inline var LEFT : Int = 37;
    /**
	* 向右导航一行或向右“步进”。
	*/
    public static inline var RIGHT : Int = 39;
    /**
	* 向上导航一页。
	*/
    public static inline var PAGE_UP : Int = 33;
    /**
	* 向下导航一页。
	*/
    public static inline var PAGE_DOWN : Int = 34;
    /**
	* 向左导航一页。
	*/
    public static inline var PAGE_LEFT : Int = 0x2397;
    /**
	* 向左导航一页。
	*/
    public static inline var PAGE_RIGHT : Int = 0x2398;
}

