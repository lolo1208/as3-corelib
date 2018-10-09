package lolo.utils.bind
{
	import flash.events.Event;
	
	
	/**
	 * 数据值改变事件
	 * @author LOLO
	 */
	public class ValueChangeEvent extends Event
	{
		/**数据值改变*/
		public static const VALUE_CHANGE:String = "valueChange";
		
		
		/**值的名称*/
		public var valueName:String;
		/**原值*/
		public var oldValue:*;
		/**新值*/
		public var newValue:*;
		
		
		
		/**
		 * 构造一个新的数据值改变事件
		 * @param type 事件类型
		 * @param valueName 值的名称
		 * @param oldValue 原值
		 * @param newValue 新值
		 */		
		public function ValueChangeEvent(type:String, valueName:String="", oldValue:*=null, newValue:*=null)
		{
			super(type);
			
			this.valueName = valueName;
			this.oldValue = oldValue;
			this.newValue = newValue;
		}
		//
	}
}