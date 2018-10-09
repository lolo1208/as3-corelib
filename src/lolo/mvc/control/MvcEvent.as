package lolo.mvc.control
{
	import flash.events.Event;
	/**
	 * mvc事件基类
	 * @author LOLO
	 */
	public class MvcEvent extends Event
	{
		/**携带的数据*/
		public var data:*;
		
		
		public function MvcEvent(type:String, data:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		//
	}
}