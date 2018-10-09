package lolo.utils
{
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.events.LoadEvent;

	/**
	 * 加载器（LoadManager）的相关扩展工具类
	 * @author LOLO
	 */
	public class LoaderUtil
	{
		/**加载单个文件完成时，对应的回调列表*/
		private static var _completeHandlers:Dictionary = new Dictionary();
		
		
		/**
		 * 添加一个加载文件完成时的回调
		 * @param key 可重复的key
		 * @param url 文件的url
		 * @param callback （参数1:LoadItemModel 可以省略）
		 */
		public static function addCompleteHandler(key:*, url:String, callback:Function):void
		{
			//文件已经加载完成了
			if(Common.loader.hasResLoaded(url)) {
				try { callback(Common.loader.getLoadItemModelByUrl(url)); }
				catch(error:Error) { callback(); }
				return;
			}
			
			//加入到回调列表中，等待文件加载完成
			if(_completeHandlers[url] == null) _completeHandlers[url] = [];
			_completeHandlers[url].push({ key:key, callback:callback });
			Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadItemCompleteHandler);
		}
		
		
		/**
		 * 加载单个文件完成
		 * @param event
		 */
		private static function loadItemCompleteHandler(event:LoadEvent):void
		{
			var list:Array = _completeHandlers[event.lim.url];
			if(list == null) return;
			
			//执行回调
			for(var i:int = 0; i < list.length; i++) {
				try { list[i].callback(event.lim); }
				catch(error:Error) { list[i].callback(); }
			}
			delete _completeHandlers[event.lim.url];
			
			removeLoadItemCompleteEventListener();
		}
		
		/**
		 * 尝试移除加载文件的事件侦听
		 */
		private static function removeLoadItemCompleteEventListener():void
		{
			for(var url:String in _completeHandlers) return;
			Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loadItemCompleteHandler);
		}
		
		
		/**
		 * 移除加载完成的回调
		 * @param key
		 * @param url 如果该值为null，将移除所有key符合的回调
		 */
		public static function removeCompleteHandler(key:*, url:String=null):void
		{
			var u:String, i:int, list:Array;
			var handlers:Dictionary = new Dictionary();
			for(u in _completeHandlers) {
				handlers[u] = _completeHandlers[u];
			}
			
			for(u in handlers) {
				if(url == null || u == url) {
					list = handlers[u];
					for(i = 0; i < list.length; i++) {
						//移除相同key的回调
						if(list[i].key == key) {
							list.splice(i , 1);
							i--;
						}
					}
					//已经没有与这个url相关的回调了
					if(list.length == 0) delete _completeHandlers[u];
				}
			}
			
			removeLoadItemCompleteEventListener();
		}
		//
	}
}