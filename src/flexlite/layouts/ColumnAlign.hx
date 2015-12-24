package flexlite.layouts;


/**
* ColumnAlign 类为 TileLayout 类的 columnAlign 属性定义可能的值。
* @author weilichuang
*/
class ColumnAlign
{
    /**
	* 不将行两端对齐。 
	*/
    public static inline var LEFT : String = "left";
    
    /**
	* 通过增大水平间隙将行两端对齐。
	*/
    public static inline var JUSTIFY_USING_GAP : String = "justifyUsingGap";
    
    /**
	* 通过增大行高度将行两端对齐。 
	*/
    public static inline var JUSTIFY_USING_WIDTH : String = "justifyUsingWidth";
}
