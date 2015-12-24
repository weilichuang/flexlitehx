package flexlite.utils;

/**
 * ...
 * @author 
 */
class MathUtil
{

	public static inline var INT_MAX_VALUE:Int = 2147483647;
	public static inline var INT_MIN_VALUE:Int = -2147483647;
	
	public static inline function maxInt(a:Int, b:Int):Int 
	{
		return a > b ? a : b;
	}
	
	public static inline function minInt(a:Int, b:Int):Int 
	{
		return a < b ? a : b;
	}
	
	public static inline function absInt(a:Int):Int
	{
		return Std.int(Math.abs(a));
	}
	
	/**
	* 过滤NaN数字
	*/
    public static inline function escapeNaN(value : Float) : Float
    {
        return !Math.isNaN(value) ? value : 0;
    }
}