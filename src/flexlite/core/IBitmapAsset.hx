package flexlite.core;


import flash.display.BitmapData;


/**
* 位图素材显示对象接口
* @author weilichuang
*/
interface IBitmapAsset
{
    
    /**
	* 当前显示的BitmapData对象
	*/
    function getBitmapData() : BitmapData;  
    /**
	* 素材的默认宽度（以像素为单位）。
	*/
    var measuredWidth(get, never) : Float;    
    /**
	* 素材的默认高度（以像素为单位）。
	*/
    var measuredHeight(get, never) : Float;

}
