package flexlite.dxr;



/**
* 能够解析DxrData的显示对象接口
* @author weilichuang
*/
interface IDxrDisplay
{
    
    
    /**
	* 被引用的DxrData对象
	*/
    var dxrData(get, set) : DxrData;

}
