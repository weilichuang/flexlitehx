package flexlite.dll.resolvers;

import flexlite.dll.resolvers.SwfResolver;


/**
* RSL文件解析器,通常是将共享代码库加载到当前程序域。
* @author weilichuang
*/
class RslResolver extends SwfResolver
{
    /**
	* 构造函数
	*/
    public function new()
    {
        super();
        loadInCurrentDomain = true;
    }
}
