package flexlite.utils;



import flash.utils.ByteArray;
import flash.Vector;

/**
* CRC32工具类
* @author weilichuang
*/
class CRC32Util
{
    /**
	* 计算时用到的CRC缓存数据表
	*/
    private static var crcTable : Vector<Int> = makeCrcTable();
    
    /**
	* 获取CRC缓存数据表
	*/
    private static function makeCrcTable() : Vector<Int>
    {
        var crcTable : Vector<Int> = new Vector<Int>(256);
        for (n in 0...256)
		{
            var c : Int = n;
            var k : Int = 8;
            while (--k >= 0)
			{
                if ((c & 1) != 0) 
                {
                    c = 0xedb88320 ^ (c >>> 1);
                }
                else 
                {
                    c = c >>> 1;
                }
            }
            crcTable[n] = c;
        }
        return crcTable;
    }
    
    /**
	* 从字节流计算CRC32数据
	* @param buf 要计算的字节流
	*/
    public static function getCRC32(buf : ByteArray) : Int
    {
        var crc : Int = 0;
        var off : Int = 0;
        var len : Int = buf.length;
        var c : Int = ~crc;
        while (--len >= 0)
        {
            c = crcTable[(c ^ buf[off++]) & 0xff] ^ (c >>> 8);
        }
        crc = ~c;
        return crc & 0xffffffff;
    }
}


