package lolo.events.components
{
	import flash.events.Event;

	/**
	 * 关闭事件
	 * @author LOLO
	 */
	public class CloseEvent extends Event
	{
		/**关闭*/
		public static const CLOSE:String = "close";
		
		
		
		/**详情（触发事件的子项的值）*/
		public var detail:*;
		
		
		
		public function CloseEvent(type:String, detail:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.detail = detail;
		}
		//
	}
}