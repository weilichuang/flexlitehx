package flexlite.dll.core;





/**
* 加载项
* @author weilichuang
*/
class DllItem
{
    public var subkeys(get, never) : Array<Dynamic>;
    public var groupName(get, never) : String;
    public var loadTime(get, set) : Int;
    public var loaded(get, set) : Bool;

    /**
	* SWF素材文件
	*/
    public static inline var TYPE_SWF : String = "swf";
    /**
	* RSL文件,对必须加载到当前域的SWF文件,使用这种文件类型。
	*/
    public static inline var TYPE_RSL : String = "rsl";
    /** 
	* XML文件  
	*/
    public static inline var TYPE_XML : String = "xml";
    /** 
	* 图片文件 
	*/
    public static inline var TYPE_IMG : String = "img";
    /** 
	* 二进制流文件
	*/
    public static inline var TYPE_BIN : String = "bin";
    /** 
	* DXR文件 
	*/
    public static inline var TYPE_DXR : String = "dxr";
    /** 
	* 二进制序列化对象 
	*/
    public static inline var TYPE_AMF : String = "amf";
    /** 
	* 文本文件(解析为字符串)
	*/
    public static inline var TYPE_TXT : String = "txt";
    /**
	* 声音文件
	*/
    public static inline var TYPE_SOUND : String = "sound";
    /**
	* 组资源文件,多种类型文件打包合并成的文件。
	*/
    public static inline var TYPE_GRP : String = "grp";
    
    /**
	* 构造函数
	* @param name 加载项名称
	* @param url 要加载的文件地址 
	* @param type 加载项文件类型
	* @param size 加载项文件大小(单位:字节)
	* @param compFunc 加载并解析完成回调函数
	*/
    public function new(name : String, url : String, type : String, size : Int = 0)
    {
        this.name = name;
        this.url = url;
        this.type = type;
        this.size = size;
    }
    
    /**
	* 加载项名称
	*/
    public var name : String;
    /**
	* 要加载的文件地址 
	*/
    public var url : String;
    /**
	* 加载项文件类型
	*/
    public var type : String;
    /**
	* 加载项文件大小(单位:字节)
	*/
    public var size : Int = 0;
    /**
	* 二级键名列表
	*/
    private function get_subkeys() : Array<Dynamic>
    {
        return (data != null) ? data.subkeys : null;
    }
    
    private var _groupName : String;
    /**
	* 所属组名
	*/
    private function get_groupName() : String
    {
        return _groupName;
    }
    
    /**
	* 加载结束回调函数。无论加载成功或者出错都将执行回调函数。示例：compFunc(dllItem:DllItem):void;
	*/
    public var compFunc : Dynamic;
    
    /**
	* 已经加载的字节数
	*/
    public var bytesLoaded : Int = 0;
    /**
	* 开始加载时间
	*/
    public var startTime : Int = 0;
    /**
	* 加载结束时间
	*/
    private var _loadTime : Int = 0;
    /**
	* 加载时间,单位:ms
	*/
    private function get_loadTime() : Int
    {
        return _loadTime;
    }
	
	private function set_loadTime(value:Int):Int
	{
		return _loadTime = value;
	}
    /**
	* 被引用的原始数据对象
	*/
    public var data : Dynamic;
    
    private var _loaded : Bool = false;
    /**
	* 加载完成的标志
	*/
    private function get_loaded() : Bool
    {
        return (data != null) ? data.loaded : _loaded;
    }
    
    private function set_loaded(value : Bool) : Bool
    {
        if (data != null) 
            data.loaded = value;
        _loaded = value;
        return value;
    }
    
    
    public function toString() : String
    {
        return "[DllItem name=\"" + name + "\" url=\"" + url + "\" type=\"" + type + "\" " +
        "size=\"" + size + "\" loadTime=\"" + loadTime + "\" loaded=\"" + loaded + "\"]";
    }
}
