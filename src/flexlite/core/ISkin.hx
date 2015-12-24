package flexlite.core;


import flexlite.components.SkinnableComponent;

/**
* 皮肤对象接口。只有实现此接口的皮肤会被匹配公开同名变量,并注入到主机组件上。
* @author weilichuang
*/
interface ISkin
{
    
    
    /**
	* 主机组件引用,仅当皮肤被应用后才会对此属性赋值 
	*/
    var hostComponent(get, set) : SkinnableComponent;

}
