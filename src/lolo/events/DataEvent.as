package lolo.events
{
	import flash.events.Event;

	/**
	 * 数据相关事件
	 * @author LOLO
	 */
	public class DataEvent extends Event
	{
		/**数据已改变*/
		public static const DATA_CHANGED:String = "dataChanged";
		
		
		/**值在HashMap中的索引*/
		public var index:int;
		/**原值*/
		public var oldValue:*;
		/**新值*/
		public var newValue:*;
		
		
		
		public function DataEvent(type:String, index:int=-1, oldValue:*=null, newValue:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.index = index;
			this.oldValue = oldValue;
			this.newValue = newValue;
		}
		//
	}
}