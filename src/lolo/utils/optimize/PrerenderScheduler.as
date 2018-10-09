package lolo.utils.optimize
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;

	/**
	 * 即将进入渲染时的事件回调器
	 * @author LOLO
	 */
	public class PrerenderScheduler
	{
		/**待处理的回调函数和对应参数列表*/
		private static var _callbacks:Dictionary = new Dictionary();
		/**当前正在处理的回调列表*/
		private static var _curCallbacks:Dictionary = new Dictionary();
		/**当前是否正在处理回调中（在处理的过程中有可能再次触发exitFrame事件）*/
		private static var _executing:Boolean;
		
		
		
		/**
		 * 添加一个回调函数，程序将会在即将进入渲染时调用它<br/>
		 * 	- 该函数只会被调用一次。<br/>
		 *  - 同一个函数只能被添加一次，再次添加将会覆盖之前的 priority 和 args
		 * @param callback 回调函数
		 * @param priority 调度的优先级
		 * @param args 对应参数
		 */
		public static function addCallback(callback:Function, priority:int=0, ...args):void
		{
			_callbacks[callback] = { priority:priority, callback:callback, args:args };
			Common.stage.addEventListener(Event.EXIT_FRAME, exitFrameHandler);
		}
		
		
		/**
		 * 移除一个回调函数
		 * @param callback
		 */
		public static function removeCallback(callback:Function):void
		{
			delete _callbacks[callback];
			delete _curCallbacks[callback];
		}
		
		
		/**
		 * 在帧代码执行都完毕时（Event.RENDER 事件前），执行回调
		 * @param event
		 */
		private static function exitFrameHandler(event:Event=null):void
		{
			Common.stage.removeEventListener(Event.EXIT_FRAME, exitFrameHandler);
			if(_executing) return;
			_executing = true;
			
			var info:Object;
			var list:Array = [];
			for each(info in _callbacks) list.push(info);
			_curCallbacks = _callbacks;
			_callbacks = new Dictionary();
			
			list.sortOn("priority", Array.NUMERIC | Array.DESCENDING);
			for(var i:int = 0; i < list.length; i++)
			{
				info = list[i];
				//回调函数不为空，并且没有在回调中被移除
				if(info.callback != null && _curCallbacks[info.callback] != null) {
					info.callback.apply(null, info.args);
				}
			}
			
			_executing = false;
			//callback中新加的回调，在这一帧继续处理
			for each(info in _callbacks) {
				exitFrameHandler();
				break;
			}
		}
		//
	}
}