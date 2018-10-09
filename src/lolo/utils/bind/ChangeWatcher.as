package lolo.utils.bind
{
	import flash.events.IEventDispatcher;

	/**
	 * 用于监听（可控制）数据值的改变
	 * @author LOLO
	 */
	public class ChangeWatcher
	{
		/**数据源 宿主*/
		private var _sHost:IEventDispatcher;
		/**数据源 宿主的属性*/
		private var _sProp:String;
		
		/**要绑定数据的宿主*/
		private var _tHost:Object;
		/**要绑定数据的宿主的属性*/
		private var _tProp:String;
		
		/**数据改变时，调用的函数*/
		private var _handler:Function;
		
		/**当前是否正在监听数据的改变*/
		private var _isWatching:Boolean;
		
		
		
		
		public function ChangeWatcher(sHost:IEventDispatcher,
									  sProp:String,
									  handler:Function=null,
									  tHost:Object=null,
									  tProp:String="")
		{
			_sHost = sHost;
			_sProp = sProp;
			_handler = handler;
			_tHost = tHost;
			_tProp = tProp;
			
			watch();
		}
		
		
		
		/**
		 * 数据值有改变
		 * @param event
		 */
		private function valueChangeHandler(event:ValueChangeEvent):void
		{
			//如果是绑定的属性，并且值有改变
			if(event.valueName == _sProp && event.newValue != event.oldValue)
			{
				if(_handler != null) _handler(event.newValue);
				else if(_tHost != null) _tHost[_tProp] = event.newValue;
			}
		}
		
		
		
		/**
		 * 启动并监听数据的改变
		 */
		public function watch():void
		{
			if(_isWatching) return;
			_isWatching = true;
			_sHost.addEventListener(ValueChangeEvent.VALUE_CHANGE, valueChangeHandler);
		}
		
		
		/**
		 * 停止监听数据的改变。<br/>
		 * 停止后，您可以调用 watch() 方法，再次启用侦听
		 */
		public function unwatch():void
		{
			if(!_isWatching) return;
			_isWatching = false;
			_sHost.removeEventListener(ValueChangeEvent.VALUE_CHANGE, valueChangeHandler);
		}
		
		
		
		/**
		 * 当前是否正在监听数据的改变
		 */
		public function get isWatching():Boolean { return _isWatching; }
		//
	}
}