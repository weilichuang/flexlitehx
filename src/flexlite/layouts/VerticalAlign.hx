package flexlite.layouts;


/**
* 垂直布局策略常量
* @author weilichuang
*/
class VerticalAlign
{
    /**
	* 在容器的中央垂直对齐子项。 
	*/
    public static inline var TOP : String = "top";
    /**
	* 在容器的中央垂直对齐子项。 
	*/
    public static inline var MIDDLE : String = "middle";
    /**
	* 在容器的底部垂直对齐子项。 
	*/
    public static inline var BOTTOM : String = "bottom";
    /**
	* 相对于容器对齐子项。这将会以容器高度为标准，调整所有子项的高度，使其始终填满容器。
	*/
    public static inline var JUSTIFY : String = "justify";
    /**
	* 相对于容器对子项进行内容对齐。这会将所有子项的大小统一调整为容器的内容高度contentHeight。
	* 容器的内容高度是最大子项的大小。如果所有子项都小于容器的高度，则会将所有子项的大小调整为容器的高度。 
	*/
    public static inline var CONTENT_JUSTIFY : String = "contentJustify";

    public function new()
    {
    }
}
