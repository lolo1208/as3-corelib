package lolo.events
{
	import flash.events.Event;
	
	/**
	 * 控制台事件
	 * @author LOLO
	 */
	public class ConsoleEvent extends Event
	{
		/**控制台有输入内容*/
		public static const INPUT:String = "input";
		
		
		
		/**附带的数据*/
		public var data:String;
		
		
		public function ConsoleEvent(type:String, data:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		//
	}
}