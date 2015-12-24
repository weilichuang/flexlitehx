package flexlite.core;


/**
* 定义弹出位置的常量值。
* 该常量决定目标对象相对于父级组件的弹出位置。
* @author weilichuang
*/
@:final class PopUpPosition
{
    /**
	* 在组件上方弹出
	*/
    public static inline var ABOVE : String = "above";
    /**
	* 在组件下方弹出
	*/
    public static inline var BELOW : String = "below";
    /**
	* 在组件中心弹出
	*/
    public static inline var CENTER : String = "center";
    /**
	* 在组件左上角弹出 
	*/
    public static inline var TOP_LEFT : String = "topLeft";
    /**
	* 在组件左边弹出
	*/
    public static inline var LEFT : String = "left";
    /**
	* 在组件右边弹出
	*/
    public static inline var RIGHT : String = "right";
}

