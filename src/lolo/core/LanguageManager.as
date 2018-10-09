package lolo.core
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import lolo.utils.StringUtil;

	/**
	 * 语言包管理
	 * @author LOLO
	 */
	public class LanguageManager extends EventDispatcher implements ILanguageManager
	{
		/**单例的实例*/
		private static var _instance:LanguageManager;
		
		/**提取完成的语言包储存在此*/
		private var _language:Dictionary;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():LanguageManager
		{
			if(_instance == null) _instance = new LanguageManager(new Enforcer());
			return _instance;
		}
		
		
		public function LanguageManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过 Common.language 获取实例");
				return;
			}
		}
		
		
		
		public function initialize(config:XML=null):void
		{
			if(config == null) config = Common.loader.getResByConfigName("language", true);
			_language = new Dictionary();
			var children:XMLList = config.item;
			for each(var item:XML in children)
			{
				_language[String(item.@id)] = item.toString().replace(/\[br\]/g, "\n");
			}
		}
		
		
		
		public function getLanguage(id:String, ...args):String
		{
			var str:String = _language[id];
			if(args.length > 0) str = StringUtil.substitute(str, args);
			return str;
		}
		//
	}
}


class Enforcer {}