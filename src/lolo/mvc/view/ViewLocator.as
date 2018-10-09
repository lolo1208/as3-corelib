package lolo.mvc.view
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;

	/**
	 * 视图注册、访问
	 * @author LOLO
	 */
	public class ViewLocator
	{
		private static var _views:Dictionary = new Dictionary();
		
		
		/**
		 * 注册视图
		 * @param viewName 视图的注册名称
		 * @param view 视图的实例
		 */
		public static function register(viewName:String, view:DisplayObject):void
		{
			_views[viewName] = view;
		}
		
		
		/**
		 * 注销已注册的视图
		 * @param viewName 视图的注册名称
		 */
		public static function unregister(viewName:String):void
		{
			delete _views[viewName];
		}
		
		
		/**
		 * 获取视图的实例
		 * @param viewName 视图的注册名称
		 */
		public static function getView(viewName:String):DisplayObject
		{
			return _views[viewName];
		}
		
		
		/**
		 * 检查指定名称的视图是否已经注册
		 * @param viewName 视图的注册名称
		 * @return 
		 */		
		public function registerationExistsFor(viewName:String):Boolean
		{
			return _views[viewName] != undefined && _views[viewName] != null; 
		}
		//
	}
}