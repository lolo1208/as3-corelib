package lolo.mvc.control
{
	import flash.events.EventDispatcher;
	/**
	 * mvc事件侦听、调度器
	 * @author LOLO
	 */
	public class MvcEventDispatcher
	{
		/**事件调度器列表*/
		private static var _dispatchers:Object = {};
		
		
		
		/**
		 * 通过名称获取事件调度器
		 * @param name 调度器的名称
		 * @return 
		 */
		public static function getInstance(name:String):EventDispatcher
		{
			if(!_dispatchers[name]) {
				_dispatchers[name] = new EventDispatcher();
			}
			return _dispatchers[name];
		}
		
		
		
		/**
		 * 通过指定名称，获取调度器，并派发指定事件
		 * @param name 调度器的名称
		 * @param event 要派发的事件
		 */
		public static function dispatch(name:String, event:MvcEvent):void
		{
			getInstance(name).dispatchEvent(event);
		}
		//
	}
}