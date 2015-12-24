package flexlite.managers.layoutClass;


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.Lib;
import haxe.ds.ObjectMap;

import flexlite.managers.ILayoutManagerClient;

@:meta(ExcludeClass())

/**
* 显示列表嵌套深度排序队列
* @author weilichuang
*/

class DepthQueue
{
    public function new()
    {
        
    }
    
    /**
	* 深度队列
	*/
    private var depthBins : Array<DepthBin> = [];
    
    /**
	* 最小深度
	*/
    private var minDepth : Int = 0;
    
    /**
	* 最大深度
	*/
    private var maxDepth : Int = -1;
	
    /**
	* 插入一个元素
	*/
    public function insert(client : ILayoutManagerClient) : Void
    {
        var depth : Int = client.nestLevel;
        if (maxDepth < minDepth) 
        {
            minDepth = maxDepth = depth;
        }
        else 
        {
            if (depth < minDepth) 
                minDepth = depth;
            if (depth > maxDepth) 
                maxDepth = depth;
        }
        
        var bin : DepthBin = depthBins[depth];
        
        if (bin == null) 
        {
            bin = new DepthBin();
            depthBins[depth] = bin;
            bin.items.set(client,true);
            bin.length++;
        }
        else 
        {
            if (!bin.items.exists(client)) 
            {
                bin.items.set(client,true);
                bin.length++;
            }
        }
    }
    /**
	* 从队列尾弹出深度最大的一个对象
	*/
    public function pop() : ILayoutManagerClient
    {
        var client : ILayoutManagerClient = null;
        
        if (minDepth <= maxDepth) 
        {
            var bin : DepthBin = depthBins[maxDepth];
            while (bin == null || bin.length == 0)
            {
                maxDepth--;
                if (maxDepth < minDepth) 
                    return null;
                bin = depthBins[maxDepth];
            }
            
			var keys = bin.items.keys();
            for (key in keys)
            {
                client = Lib.as(key, ILayoutManagerClient);
                remove(client, maxDepth);
                break;
            }
            
            while (bin == null || bin.length == 0)
            {
                maxDepth--;
                if (maxDepth < minDepth) 
                    break;
                bin = depthBins[maxDepth];
            }
        }
        
        return client;
    }
    /**
	* 从队列首弹出深度最小的一个对象
	*/
    public function shift() : ILayoutManagerClient
    {
        var client : ILayoutManagerClient = null;
        
        if (minDepth <= maxDepth) 
        {
            var bin : DepthBin = depthBins[minDepth];
            while (bin == null || bin.length == 0)
            {
                minDepth++;
                if (minDepth > maxDepth) 
                    return null;
                bin = depthBins[minDepth];
            }
            
            var keys = bin.items.keys();
            for (key in keys)
            {
                client = Lib.as(key, ILayoutManagerClient);
                remove(client, minDepth);
                break;
            }
            
            while (bin == null || bin.length == 0)
            {
                minDepth++;
                if (minDepth > maxDepth) 
                    break;
                bin = depthBins[minDepth];
            }
        }
        
        return client;
    }
    
    /**
	* 移除大于等于指定组件层级的元素中最大的元素
	*/
    public function removeLargestChild(client : ILayoutManagerClient) : Dynamic
    {
        var max : Int = maxDepth;
        var min : Int = client.nestLevel;
        
        while (min <= max)
        {
            var bin : DepthBin = depthBins[max];
            if (bin != null && bin.length > 0) 
            {
                if (max == client.nestLevel) 
                {
                    if (bin.items.exists(client)) 
                    {
                        remove(client, max);
                        return client;
                    }
                }
                else 
                {
                    var keys = bin.items.keys();
					for (key in keys)
                    {
                        if (Std.is(key, DisplayObject) && 
							Std.is(client, DisplayObjectContainer) && 
							cast(client, DisplayObjectContainer).contains(cast key))
                        {
                            remove(key, max);
                            return key;
                        }
                    }
                }
                
                max--;
            }
            else 
            {
                if (max == maxDepth) 
                    maxDepth--;
                max--;
                if (max < min) 
                    break;
            }
        }
        
        return null;
    }
    
    /**
	* 移除大于等于指定组件层级的元素中最小的元素
	*/
    public function removeSmallestChild(client : ILayoutManagerClient) : Dynamic
    {
        var min : Int = client.nestLevel;
        
        while (min <= maxDepth)
        {
            var bin : DepthBin = depthBins[min];
            if (bin != null && bin.length > 0) 
            {
                if (min == client.nestLevel) 
                {
                    if (bin.items.exists(client)) 
                    {
                        remove(client, min);
                        return client;
                    }
                }
                else 
                {
					var keys = bin.items.keys();
                    for (key in keys)
                    {
                        if (Std.is(key, DisplayObject) && 
							Std.is(client, DisplayObjectContainer) && 
							cast(client, DisplayObjectContainer).contains(cast key))
                        {
                            remove(key, min);
                            return key;
                        }
                    }
                }
                
                min++;
            }
            else 
            {
                if (min == minDepth) 
                    minDepth++;
                min++;
                if (min > maxDepth) 
                    break;
            }
        }
        
        return null;
    }
    
    /**
	* 移除一个元素
	*/
    public function remove(client : ILayoutManagerClient, level : Int = -1) : ILayoutManagerClient
    {
        var depth : Int = (level >= 0) ? level : client.nestLevel;
        var bin : DepthBin = depthBins[depth];
        if (bin != null && bin.items.exists(client)) 
        {
			bin.items.remove(client);
            bin.length--;
            return client;
        }
        return null;
    }
    
    /**
	* 清空队列
	*/
    public function removeAll() : Void
    {
        depthBins = [];
        minDepth = 0;
        maxDepth = -1;
    }
    /**
	* 队列是否为空
	*/
    public function isEmpty() : Bool
    {
        return minDepth > maxDepth;
    }
}


/**
 * 列表项
 */
class DepthBin
{
	public var length : Int;
    public var items :ObjectMap<ILayoutManagerClient,Bool> = new ObjectMap<ILayoutManagerClient,Bool>();
	
    public function new()
    {
    }
}