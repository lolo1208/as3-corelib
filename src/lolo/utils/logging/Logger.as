package lolo.utils.logging
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.UncaughtErrorEvent;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.utils.TimeUtil;
	
	/**
	 * 日志记录
	 * @author LOLO
	 */
	public class Logger
	{
		/**调试的日志类型*/
		public static const LOG_TYPE_DEBUG:String = "debug";
		/**记录信息的日志类型*/
		public static const LOG_TYPE_INFO:String = "info";
		/**警告的日志类型*/
		public static const LOG_TYPE_WARN:String = "warn";
		/**错误的日志类型*/
		public static const LOG_TYPE_ERROR:String = "error";
		/**致命错误的日志类型*/
		public static const LOG_TYPE_FATAL:String = "fatal";
		
		/**网络通信数据的日志类型 - 全部*/
		public static const LOG_TYPE_NETWORK_ALL:String = "networkAll";
		/**网络通信数据的日志类型 - 通信成功*/
		public static const LOG_TYPE_NETWORK_SUCC:String = "networkSucc";
		/**网络通信数据的日志类型 - 通信失败*/
		public static const LOG_TYPE_NETWORK_FAIL:String = "networkFail";
		/**网络通信数据的日志类型 - 后台主动推送*/
		public static const LOG_TYPE_NETWORK_PUSH:String = "networkPush";
		
		
		/**日志的最长记录条数（各类型单独统计）*/
		public static var logCount:uint = 50;
		
		
		/**用于事件注册和调度*/
		private static var _eventDispatcher:EventDispatcher = new EventDispatcher();
		/**日志列表*/
		private static var _logList:Dictionary = new Dictionary();
		
		
		
		
		
		public function Logger()
		{
			super();
			throw new Error("不允许创建该类的实例");
		}
		
		
		
		
		/**
		 * 添加一条分类的普通日志
		 * @param message 日志消息
		 * @param type 日志类型
		 * @param disEvent 是否抛出 LogEvent.ADDED_LOG 事件
		 */
		public static function addLog(message:String, type:String="debug", disEvent:Boolean=false):void
		{
			if(!_logList[type]) _logList[type] = [];
			if(_logList[type].length > logCount) _logList[type].shift();
			_logList[type].push(message);
			
			trace("[LOG:" + type + "] " + message);
			
			if(disEvent) {
				_eventDispatcher.dispatchEvent(new LogEvent(LogEvent.ADDED_LOG, {
					type	: type,
					message	: message,
					date	: TimeUtil.getFormatTime()
				}));
			}
		}
		
		
		/**
		 * 添加一条采样日志
		 * @param type 日志类型
		 * @param args 日志的参数
		 */
		public static function addSampleLog(type:String, ...args):void
		{
			var message:String;
			if(Common.ui == null || Common.ui.currentSceneName == null) {
				message = "none";
			}
			else {
				var arr:Array = Common.ui.currentSceneName.split(".");
				message = arr[arr.length - 1];
			}
			
			for each(var arg:String in args) {
				message += "#";
				message += arg;
			}
			
			addLog(message, type);
			_eventDispatcher.dispatchEvent(new LogEvent(LogEvent.SAMPLE_LOG, {
				type	: type,
				message	: message,
				date	: TimeUtil.getFormatTime()
			}));
		}
		
		
		/**
		 * 添加一条错误日志
		 * @param errorMsg
		 * @param error
		 */
		public static function addErrorLog(errorMsg:String, error:Error=null):void
		{
			if(error != null) {
				errorMsg = error.getStackTrace();
				if(errorMsg == null || errorMsg == "null") errorMsg = error.message;
			}
			
			var log:Object = {
				errorMsg	: errorMsg,
				date		: TimeUtil.getFormatTime()
			};
			
			if(!_logList[LOG_TYPE_ERROR]) _logList[LOG_TYPE_ERROR] = [];
			if(_logList[LOG_TYPE_ERROR].length > logCount) _logList[LOG_TYPE_ERROR].shift();
			_logList[LOG_TYPE_ERROR].push(log);
			
			_eventDispatcher.dispatchEvent(new LogEvent(LogEvent.ERROR_LOG, log));
		}
		
		
		
		/**
		 * 添加一条网络通信日志
		 * @param log
		 */
		public static function addNetworkLog(log:Object, date:Date=null):void
		{
			log.timestamp = "[" + TimeUtil.getFormatTime(date) + "]";
			
			var list:Array = _logList[log.type];
			if(!list) list = _logList[log.type] = [];
			if(list.length > logCount) list.shift();
			list.push(log);
			
			list = _logList[LOG_TYPE_NETWORK_ALL];
			if(!list) list = _logList[LOG_TYPE_NETWORK_ALL] = [];
			if(list.length > logCount) list.shift();
			list.push(log);
		}
		
		
		
		/**
		 * 获取指定类型的普通日志
		 * @param type
		 * @return 
		 */
		public static function getLog(type:String="debug"):Array
		{
			if(!_logList[type]) return [];
			return _logList[type];
		}
		
		
		/**
		 * 解析并记录全局异常（程序运行时产生的错误）
		 * @param event
		 */
		public static function uncaughtErrorHandler(event:UncaughtErrorEvent):void
		{
			var msg:String;
			if(event.error is Error) {
				addErrorLog(null, event.error);
			}
			else if(event.error is ErrorEvent) {
				addErrorLog(event.error.text);
			}
			else {
				addErrorLog(event.error.toString());
			}
			
			if(Common.config.getConfig("throwError") != "true") event.preventDefault();
		}
		
		
		
		
		
		/**
		 * @see flash.events.EventDispatcher.addEventListener()
		 */
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * @see flash.events.EventDispatcher.removeEventListener()
		 */
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * @see flash.events.EventDispatcher.dispatchEvent()
		 */
		public static function dispatchEvent(event:Event):Boolean
		{
			return _eventDispatcher.dispatchEvent(event);
		}
		
		/**
		 * @see flash.events.EventDispatcher.hasEventListener()
		 */
		public static function hasEventListener(type:String):Boolean
		{
			return _eventDispatcher.hasEventListener(type);
		}
		
		/**
		 * @see flash.events.EventDispatcher.willTrigger()
		 */
		public static function willTrigger(type:String):Boolean
		{
			return _eventDispatcher.willTrigger(type);
		}
		//
	}
}