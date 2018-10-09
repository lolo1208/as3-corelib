package lolo.utils.bind
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * 数据类，用于简化数据绑定功能。<br/>
	 * 在数据绑定结构中，数据源可以不必继承该类，但必须实现 IEventDispatcher 接口，
	 * 并且在值有改变时，调度 ValueChangeEvent.VALUE_CHANGE 事件
	 * @author LOLO
	 */
	public class Data extends EventDispatcher
	{
		/**可绑定的数据列表*/
		private var _data:Dictionary;
		
		
		
		public function Data()
		{
			super();
			_data = new Dictionary();
		}
		
		
		
		/**
		 * 根据名称，获取可绑定属性的值
		 * @param name
		 * @return 
		 */
		protected function getProperty(name:String):*
		{
			return _data[name];
		}
		
		
		/**
		 * 根据名称，设置可绑定属性的值。<br/>
		 * 当值有改变时，将会抛出 ValueChangeEvent.VALUE_CHANGE 事件
		 * @param name
		 * @param value
		 */
		protected function setProperty(name:String, value:*):void
		{
			var oldValue:* = _data[name];
			if(value != oldValue) {
				_data[name] = value;
				dispatchEvent(new ValueChangeEvent(ValueChangeEvent.VALUE_CHANGE, name, oldValue, value));
			}
		}
		//
	}
}