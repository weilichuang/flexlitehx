package flexlite.managers;



import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.UncaughtErrorEvent;
import flash.Lib;
import flexlite.utils.MathUtil;


import flexlite.core.FlexLiteGlobals;
import flexlite.events.UIEvent;
import flexlite.managers.layoutClass.DepthQueue;



/**
* 所有组件的一次三个延迟验证渲染阶段全部完成 
*/
@:meta(Event(name="updateComplete",type="flexlite.events.UIEvent"))

/**
* 布局管理器
* @author weilichuang
*/
class LayoutManager extends EventDispatcher
{
	private var targetLevel : Int = MathUtil.INT_MAX_VALUE;
	
    /**
	* 需要抛出组件初始化完成事件的对象 
	*/
    private var updateCompleteQueue : DepthQueue = new DepthQueue();
    
    private var invalidatePropertiesFlag : Bool = false;
    private var invalidateClientPropertiesFlag : Bool = false;
    private var invalidatePropertiesQueue : DepthQueue = new DepthQueue();
	
	private var invalidateDisplayListFlag : Bool = false;
    private var invalidateDisplayListQueue : DepthQueue = new DepthQueue();
	
	private var invalidateSizeFlag : Bool = false;
    private var invalidateClientSizeFlag : Bool = false;
    private var invalidateSizeQueue : DepthQueue = new DepthQueue();
	
	/** 
	* 是否已经添加了事件监听
	*/
    private var listenersAttached : Bool = false;
	
    public function new()
    {
        super();
    }
    
    /**
	* 标记组件提交过属性
	*/
    public function invalidateProperties(client : ILayoutManagerClient) : Void
    {
        if (!invalidatePropertiesFlag) 
        {
            invalidatePropertiesFlag = true;
            if (!listenersAttached) 
                attachListeners();
        }
        if (targetLevel <= client.nestLevel) 
            invalidateClientPropertiesFlag = true;
        invalidatePropertiesQueue.insert(client);
    }
    
    /**
	* 使提交的属性生效
	*/
    private function validateProperties() : Void
    {
        var client : ILayoutManagerClient = invalidatePropertiesQueue.shift();
        while (client != null)
        {
            if (client.parent != null) 
            {
                client.validateProperties();
                if (!client.updateCompletePendingFlag) 
                {
                    updateCompleteQueue.insert(client);
                    client.updateCompletePendingFlag = true;
                }
            }
            client = invalidatePropertiesQueue.shift();
        }
        if (invalidatePropertiesQueue.isEmpty()) 
            invalidatePropertiesFlag = false;
    }
    
    
    /**
	* 标记需要重新测量尺寸
	*/
    public function invalidateSize(client : ILayoutManagerClient) : Void
    {
        if (!invalidateSizeFlag) 
        {
            invalidateSizeFlag = true;
            if (!listenersAttached) 
                attachListeners();
        }
        if (targetLevel <= client.nestLevel) 
            invalidateClientSizeFlag = true;
        invalidateSizeQueue.insert(client);
    }
    /**
	* 测量属性
	*/
    private function validateSize() : Void
    {
        var client : ILayoutManagerClient = invalidateSizeQueue.pop();
        while (client != null)
        {
            if (client.parent != null) 
            {
                client.validateSize();
                if (!client.updateCompletePendingFlag) 
                {
                    updateCompleteQueue.insert(client);
                    client.updateCompletePendingFlag = true;
                }
            }
            client = invalidateSizeQueue.pop();
        }
        if (invalidateSizeQueue.isEmpty()) 
            invalidateSizeFlag = false;
    }
    
    
    
    /**
	* 标记需要重新测量尺寸
	*/
    public function invalidateDisplayList(client : ILayoutManagerClient) : Void
    {
        if (!invalidateDisplayListFlag) 
        {
            invalidateDisplayListFlag = true;
            if (!listenersAttached) 
                attachListeners();
        }
        invalidateDisplayListQueue.insert(client);
    }
    /**
	* 测量属性
	*/
    private function validateDisplayList() : Void
    {
        var client : ILayoutManagerClient = invalidateDisplayListQueue.shift();
        while (client != null)
        {
            if (client.parent != null) 
            {
                client.validateDisplayList();
                if (!client.updateCompletePendingFlag) 
                {
                    updateCompleteQueue.insert(client);
                    client.updateCompletePendingFlag = true;
                }
            }
            client = invalidateDisplayListQueue.shift();
        }
        if (invalidateDisplayListQueue.isEmpty()) 
            invalidateDisplayListFlag = false;
    }
    
    /**
	* 添加事件监听
	*/
    private function attachListeners() : Void
    {
        FlexLiteGlobals.stage.addEventListener(Event.ENTER_FRAME, doPhasedInstantiationCallBack);
        FlexLiteGlobals.stage.addEventListener(Event.RENDER, doPhasedInstantiationCallBack);
        FlexLiteGlobals.stage.invalidate();
        listenersAttached = true;
    }
    
    /**
	* 执行属性应用
	*/
    private function doPhasedInstantiationCallBack(event : Event = null) : Void
    {
        FlexLiteGlobals.stage.removeEventListener(Event.ENTER_FRAME, doPhasedInstantiationCallBack);
        FlexLiteGlobals.stage.removeEventListener(Event.RENDER, doPhasedInstantiationCallBack);
        if (FlexLiteGlobals.catchCallLaterExceptions) 
        {
            try
            {
                doPhasedInstantiation();
            }            
			catch (e : Dynamic)
            {
                var errorEvent : UncaughtErrorEvent = new UncaughtErrorEvent("callLaterError", false, true, e.getStackTrace());
                FlexLiteGlobals.stage.dispatchEvent(errorEvent);
            }
        }
        else 
        {
            doPhasedInstantiation();
        }
    }
    
    private function doPhasedInstantiation() : Void
    {
        if (invalidatePropertiesFlag) 
        {
            validateProperties();
        }
		
        if (invalidateSizeFlag) 
        {
            validateSize();
        }
        
        if (invalidateDisplayListFlag) 
        {
            validateDisplayList();
        }
        
        if (invalidatePropertiesFlag ||
            invalidateSizeFlag ||
            invalidateDisplayListFlag) 
        {
            attachListeners();
        }
        else 
        {
            listenersAttached = false;
            var client : ILayoutManagerClient = updateCompleteQueue.pop();
            while (client != null)
            {
                if (!client.initialized) 
                    client.initialized = true;
                if (client.hasEventListener(UIEvent.UPDATE_COMPLETE)) 
                    client.dispatchEvent(new UIEvent(UIEvent.UPDATE_COMPLETE));
                client.updateCompletePendingFlag = false;
                client = updateCompleteQueue.pop();
            }
            
            dispatchEvent(new UIEvent(UIEvent.UPDATE_COMPLETE));
        }
    }
	
    /**
	* 立即应用所有延迟的属性
	*/
    public function validateNow() : Void
    {
        var infiniteLoopGuard : Int = 0;
        while (listenersAttached && infiniteLoopGuard++ < 100)
			doPhasedInstantiationCallBack();
    }
	
    /**
	* 使大于等于指定组件层级的元素立即应用属性 
	* @param target 要立即应用属性的组件
	* @param skipDisplayList 是否跳过更新显示列表阶段
	*/
    public function validateClient(target : ILayoutManagerClient, skipDisplayList : Bool = false) : Void
    {
        var obj : ILayoutManagerClient;
        var done : Bool = false;
        var oldTargetLevel : Int = targetLevel;
        
        if (targetLevel >= MathUtil.INT_MAX_VALUE) 
            targetLevel = target.nestLevel;
        
        while (!done)
        {
            done = true;
            
            obj = Lib.as(invalidatePropertiesQueue.removeSmallestChild(target), ILayoutManagerClient);
            while (obj != null)
            {
                if (obj.parent != null) 
                {
                    obj.validateProperties();
                    if (!obj.updateCompletePendingFlag) 
                    {
                        updateCompleteQueue.insert(obj);
                        obj.updateCompletePendingFlag = true;
                    }
                }
                obj = Lib.as((invalidatePropertiesQueue.removeSmallestChild(target)), ILayoutManagerClient);
            }
            
            if (invalidatePropertiesQueue.isEmpty()) 
            {
                invalidatePropertiesFlag = false;
            }
            invalidateClientPropertiesFlag = false;
            
            obj = Lib.as(invalidateSizeQueue.removeLargestChild(target), ILayoutManagerClient);
            while (obj != null)
            {
                if (obj.parent != null) 
                {
                    obj.validateSize();
                    if (!obj.updateCompletePendingFlag) 
                    {
                        updateCompleteQueue.insert(obj);
                        obj.updateCompletePendingFlag = true;
                    }
                }
                if (invalidateClientPropertiesFlag) 
                {
                    obj = Lib.as(invalidatePropertiesQueue.removeSmallestChild(target), ILayoutManagerClient);
                    if (obj != null) 
                    {
                        invalidatePropertiesQueue.insert(obj);
                        done = false;
                        break;
                    }
                }
                
                obj = Lib.as(invalidateSizeQueue.removeLargestChild(target), ILayoutManagerClient);
            }
            
            if (invalidateSizeQueue.isEmpty()) 
            {
                invalidateSizeFlag = false;
            }
            invalidateClientPropertiesFlag = false;
            invalidateClientSizeFlag = false;
            
            if (!skipDisplayList) 
            {
                obj = Lib.as(invalidateDisplayListQueue.removeSmallestChild(target), ILayoutManagerClient);
                while (obj != null)
                {
                    if (obj.parent != null) 
                    {
                        obj.validateDisplayList();
                        if (!obj.updateCompletePendingFlag) 
                        {
                            updateCompleteQueue.insert(obj);
                            obj.updateCompletePendingFlag = true;
                        }
                    }
                    if (invalidateClientPropertiesFlag) 
                    {
                        obj = Lib.as(invalidatePropertiesQueue.removeSmallestChild(target), ILayoutManagerClient);
                        if (obj != null) 
                        {
                            invalidatePropertiesQueue.insert(obj);
                            done = false;
                            break;
                        }
                    }
                    
                    if (invalidateClientSizeFlag) 
                    {
                        obj = Lib.as(invalidateSizeQueue.removeLargestChild(target), ILayoutManagerClient);
                        if (obj != null) 
                        {
                            invalidateSizeQueue.insert(obj);
                            done = false;
                            break;
                        }
                    }
                    
                    obj = Lib.as(invalidateDisplayListQueue.removeSmallestChild(target), ILayoutManagerClient);
                }
                
                
                if (invalidateDisplayListQueue.isEmpty()) 
                {
                    invalidateDisplayListFlag = false;
                }
            }
        }
        
        if (oldTargetLevel == MathUtil.INT_MAX_VALUE) 
        {
            targetLevel = MathUtil.INT_MAX_VALUE;
            if (!skipDisplayList) 
            {
                obj = Lib.as(updateCompleteQueue.removeLargestChild(target), ILayoutManagerClient);
                while (obj != null)
                {
                    if (!obj.initialized) 
                        obj.initialized = true;
                    
                    if (obj.hasEventListener(UIEvent.UPDATE_COMPLETE)) 
                        obj.dispatchEvent(new UIEvent(UIEvent.UPDATE_COMPLETE));
                    obj.updateCompletePendingFlag = false;
                    obj = Lib.as(updateCompleteQueue.removeLargestChild(target), ILayoutManagerClient);
                }
            }
        }
    }
}
