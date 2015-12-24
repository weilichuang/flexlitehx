package flexlite.dll.resolvers;



import flash.utils.ByteArray;

import flexlite.dxr.DxrData;
import flexlite.dxr.DxrFile;

/**
* DXR文件解析器
* @author weilichuang
*/
class DxrResolver extends BinResolver
{
    public function new()
    {
        super();
    }
    
    /**
	* @inheritDoc
	*/
    override public function loadBytes(bytes : ByteArray, name : String) : Void
    {
        if (Reflect.field(fileDic, name) || bytes == null) 
            return;
        try
        {
            bytes.uncompress();
        }      
		catch (e : String)
		{ 
			
		}
        fileDic.set(name, new DxrFile(bytes, name));
    }
    
    /**
	* @inheritDoc
	*/
    override public function getRes(key : String) : Dynamic
    {
        var res : Dynamic = Reflect.field(fileDic, key);
        if (res != null) 
            return res;
        if (sharedMap.has(key)) 
            return sharedMap.get(key);
        return null;
    }
    
    /**
	* @inheritDoc
	*/
    override public function getResAsync(key : String, compFunc : Dynamic) : Void
    {
        if (compFunc == null) 
            return;
        var res : Dynamic = getRes(key);
        if (res != null) 
        {
            compFunc(res);
        }
        else 
        {
            var file : DxrFile = null;
            var found : Bool = false;
            for (file in fileDic)
            {
                if (file.hasKey(key)) 
                {
                    found = true;
                    break;
                }
            }
            if (found) 
            {
                file.getDxrData(key, function(data : DxrData) : Void{
                            sharedMap.set(key, data);
                            compFunc(data);
                        });
            }
            else 
            {
                compFunc(null);
            }
        }
    }
}
