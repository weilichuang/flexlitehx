package flexlite.dll.core;

import flexlite.dll.core.IResolver;
import flexlite.utils.MathUtil;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.utils.Dictionary;


import flexlite.core.Injector;

import flexlite.dll.events.DllEvent;


/**
* 队列加载进度事件
*/
@:meta(Event(name="groupProgress",type="org.flexlite.domDll.events.DllEvent"))

/**
* 队列加载完成事件
*/
@:meta(Event(name="groupComplete",type="org.flexlite.domDll.events.DllEvent"))

/**
* 一个加载项加载结束事件，可能是加载成功也可能是加载失败。
*/
@:meta(Event(name="itemLoadFinished",type="org.flexlite.domDll.events.DllEvent"))

/**
* 多文件队列加载器
* @author weilichuang
*/
class DllLoader extends EventDispatcher
{
    /**
	* 构造函数
	* @param thread 最大同时加载数
	*/
    public function new(thread : Int = 2, retryTimes : Int = 3)
    {
        super();
        this.thread = thread;
        this.retryTimes = retryTimes;
    }
    
    /**
	* 最大并发加载数 
	*/
    private var thread : Int = 2;
    /**
	* 加载失败的重试次数
	*/
    private var retryTimes : Int = 3;
    
    private var _version : String;
    /**
	* 设置当前的资源版本号
	*/
    public function setVersion(value : String) : Void
    {
        _version = value;
    }
    
    
    /**
	* 当前队列文件字节流总大小,key为groupName
	*/
    private var totalSizeDic : StringMap<Int> = new StringMap<Int>();
    /**
	* 已经加载的字节数,key为groupName
	*/
    private var loadedSizeDic : StringMap<Int> = new StringMap<Int>();
    /**
	* 当前组加载的项总个数,key为groupName
	*/
    private var groupTotalDic : StringMap<Int> = new StringMap<Int>();
    /**
	* 已经加载的项个数,key为groupName
	*/
    private var numLoadedDic : StringMap<Int> = new StringMap<Int>();
    /**
	* 正在加载的组列表,key为groupName
	*/
    private var itemListDic : StringMap<Array<DllItem>> = new StringMap<Array<DllItem>>();
    
    /**
	* 优先级队列,key为priority，value为groupName列表
	*/
    private var priorityQueue : IntMap<Array<String>> = new IntMap<Array<String>>();
    /**
	* 加载失败的项列表
	*/
    private var retryTimesDic : ObjectMap<DllItem,Int> = new ObjectMap<DllItem,Int>();
    /**
	* 加载失败的项列表
	*/
    private var failedList : Array<DllItem> = new Array<DllItem>();
    /**
	* 检查指定的组是否正在加载中
	*/
    public function isGroupInLoading(groupName : String) : Bool
    {
        return itemListDic.get(groupName) != null;
    }
    /**
	* 开始加载一组文件
	* @param list 加载项列表
	* @param groupName 组名
	* @param priority 加载优先级
	*/
    public function loadGroup(list : Array<DllItem>, groupName : String, priority : Int = 0) : Void
    {
        if (itemListDic.exists(groupName) || groupName == null) 
            return;
			
        if (list == null || list.length == 0) 
        {
            var event : DllEvent = new DllEvent(DllEvent.GROUP_COMPLETE);
            event.groupName = groupName;
            dispatchEvent(event);
            return;
        }
        if (priorityQueue.exists(priority)) 
            priorityQueue.get(priority).push(groupName);
        else 
			priorityQueue.set(priority, [groupName]);
			
        itemListDic.set(groupName, list);
		
        var totalSize : Int = 0;
        for (dllItem in list)
        {
            @:privateAccess dllItem._groupName = groupName;
            dllItem.bytesLoaded = 0;
            totalSize += dllItem.size;
        }
        totalSizeDic.set(groupName, totalSize);
        loadedSizeDic.set(groupName, 0);
        groupTotalDic.set(groupName, list.length);
        numLoadedDic.set(groupName, 0);
        next();
    }
    /**
	* 延迟加载队列
	*/
    private var lazyLoadList : Array<DllItem> = new Array<DllItem>();
    /**
	* 加载一个文件
	* @param dllItem 要加载的项
	*/
    public function loadItem(dllItem : DllItem) : Void
    {
        lazyLoadList.push(dllItem);
		@:privateAccess dllItem._groupName = "";
        next();
    }
    /**
	* 资源解析库字典类
	*/
    private var resolverDic : StringMap<IResolver> = new StringMap<IResolver>();
    /**
	* 正在加载的线程计数
	*/
    private var loadingCount : Int = 0;
    /**
	* 加载下一项
	*/
    private function next() : Void
    {
        while (loadingCount < thread)
        {
            var dllItem : DllItem = getOneDllItem();
            if (dllItem == null) 
                break;
            loadingCount++;
            dllItem.startTime = Math.round(haxe.Timer.stamp() * 1000);
            if (dllItem.loaded) 
            {
                onItemProgress(dllItem.size, dllItem);
                onItemComplete(dllItem);
            }
            else 
            {
                var resolver : IResolver = resolverDic.get(dllItem.type);
                if (resolver == null) 
                {
                    resolver =  Injector.getInstance(IResolver, dllItem.type);
					resolverDic.set(dllItem.type, resolver);
                }
                var url : String = dllItem.url;
                if (_version != null && url.indexOf("?v=") == -1) 
                {
                    if (url.indexOf("?") == -1) 
                        url += "?v=" + _version
                    else 
                    url += "&v=" + _version;
                    dllItem.url = url;
                }
                resolver.loadFile(dllItem, onItemComplete, onItemProgress);
            }
        }
    }
    
    /**
	* 当前应该加载同优先级队列的第几列
	*/
    private var queueIndex : Int = 0;
    /**
	* 获取下一个待加载项
	*/
    private function getOneDllItem() : DllItem
    {
        if (failedList.length > 0) 
            return failedList.shift();
        var maxPriority : Int = MathUtil.INT_MIN_VALUE;
		
		var keys = priorityQueue.keys();
        for (p in keys)
        {
            maxPriority = MathUtil.maxInt(maxPriority, p);
        }
        var queue : Array<String> = priorityQueue.get(maxPriority);
        if (queue == null || queue.length == 0) 
        {
            if (lazyLoadList.length == 0) 
                return null;  //后请求的先加载，以便更快获取当前需要的资源  ;
            
            return lazyLoadList.pop();
        }
        var length : Int = queue.length;
        var list : Array<DllItem> = null;
        for (i in 0...length)
		{
            if (queueIndex >= length) 
                queueIndex = 0;
            list = itemListDic.get(queue[queueIndex]);
            if (list.length > 0) 
                break;
            queueIndex++;
        }
        if (list == null || list.length == 0) 
            return null;
        return list.shift();
    }
    /**
	* 加载进度更新
	*/
    private function onItemProgress(bytesLoaded : Int, dllItem : DllItem) : Void
    {
        if (dllItem.groupName == null) 
            return;
        var groupName : String = dllItem.groupName;
		
        loadedSizeDic.set(groupName, loadedSizeDic.get(groupName) + bytesLoaded - dllItem.bytesLoaded);
        dllItem.bytesLoaded = bytesLoaded;
        var progressEvent : DllEvent = new DllEvent(DllEvent.GROUP_PROGRESS);
        progressEvent.groupName = groupName;
        progressEvent.bytesLoaded = loadedSizeDic.get(groupName);
        progressEvent.bytesTotal = totalSizeDic.get(groupName);
        dispatchEvent(progressEvent);
    }
    /**
	* 加载结束
	*/
    private function onItemComplete(dllItem : DllItem) : Void
    {
        loadingCount--;
        if (!dllItem.loaded) 
        {
            if (!retryTimesDic.exist(dllItem)) 
                retryTimesDic.set(dllItem, 0);
				
            retryTimesDic.set(dllItem, retryTimesDic.get(dllItem) + 1);
			
            if (retryTimesDic.get(dllItem) <= retryTimes) 
            {
                failedList.push(dllItem);
                next();
                return;
            }
            else 
            {
                retryTimesDic.remove(dllItem);
            }
        }
        dllItem.loadTime = Math.round(haxe.Timer.stamp() * 1000) - dllItem.startTime;
        var groupName : String = dllItem.groupName;
        var itemLoadEvent : DllEvent = new DllEvent(DllEvent.ITEM_LOAD_FINISHED);
        itemLoadEvent.groupName = groupName;
        itemLoadEvent.dllItem = dllItem;
        dispatchEvent(itemLoadEvent);
        if (dllItem.compFunc != null) 
            dllItem.compFunc(dllItem);
        if (groupName != null) 
        {
            numLoadedDic.set(groupName, numLoadedDic.get(groupName) + 1);
            if (!dllItem.loaded) 
                loadedSizeDic.set(groupName, loadedSizeDic.get(groupName) + dllItem.size);
            var progressEvent : DllEvent = new DllEvent(DllEvent.GROUP_PROGRESS);
            progressEvent.groupName = groupName;
            progressEvent.bytesLoaded = loadedSizeDic.get(groupName);
            progressEvent.bytesTotal = totalSizeDic.get(groupName);
            dispatchEvent(progressEvent);
            if (numLoadedDic.get(groupName) == groupTotalDic.get(groupName)) 
            {
                removeGroupName(groupName);
				totalSizeDic.remove(groupName);
				loadedSizeDic.remove(groupName);
				groupTotalDic.remove(groupName);
				numLoadedDic.remove(groupName);
				itemListDic.remove(groupName);
                
                var event : DllEvent = new DllEvent(DllEvent.GROUP_COMPLETE);
                event.groupName = groupName;
                dispatchEvent(event);
            }
        }
        next();
    }
    /**
	* 从优先级队列中移除指定的组名
	*/
    private function removeGroupName(groupName : String) : Void
    {
		var keys = priorityQueue.keys();
        for (p in keys)
        {
            var queue : Array<Dynamic> = priorityQueue.get(p);
            var length : Int = queue.length;
            var index : Int = 0;
            var found : Bool = false;
            for (name in queue)
            {
                if (name == groupName) 
                {
                    queue.splice(index, 1);
                    found = true;
                    break;
                }
                index++;
            }
            if (found) 
            {
                if (queue.length == 0) 
                {
                    priorityQueue.remove(p);
                }
                break;
            }
        }
    }
}
