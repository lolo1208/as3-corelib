package lolo.utils.logging
{
	import flash.events.Event;
	
	/**
	 * 日志事件
	 * @author LOLO
	 */
	public class LogEvent extends Event
	{
		/**添加了一条可分类的普通日志*/
		public static const ADDED_LOG:String = "addedLog";
		
		/**添加了一条错误日志*/
		public static const ERROR_LOG:String = "errorLog";
		
		/**添加了一条采样日志*/
		public static const SAMPLE_LOG:String = "sampleLog";
		
		
		
		
		/**日志数据*/
		public var data:Object;
		
		
		public function LogEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		//
	}
}