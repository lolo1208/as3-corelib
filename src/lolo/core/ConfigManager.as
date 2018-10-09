package lolo.core
{
	import flash.utils.Dictionary;
	
	import lolo.utils.StringUtil;

	/**
	 * 配置信息管理
	 * @author LOLO
	 */
	public class ConfigManager implements IConfigManager
	{
		/**单例的实例*/
		private static var _instance:ConfigManager;
		
		/**网页目录下的Config.xml*/
		private var _config:Dictionary;
		/**资源配置*/
		private var _resConfig:Dictionary;
		/**界面配置*/
		private var _uiConfig:Dictionary;
		/**音频配置*/
		private var _soundConfig:Dictionary;
		/**样式列表配置*/
		private var _styleList:Dictionary;
		/**皮肤配置 _skinConfig[skinName]=[{state, souceName}]*/
		private var _skinConfig:Dictionary;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():ConfigManager
		{
			if(_instance == null) _instance = new ConfigManager(new Enforcer());
			return _instance;
		}
		
		
		public function ConfigManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Common.config获取实例");
				return;
			}
		}
		
		
		
		public function initConfig():void
		{
			_config = new Dictionary();
			var config:XML = Common.loader.getResByUrl("Config.xml", true);
			var children:XMLList = config.children();
			for each(var item:XML in children)
			{
				_config[String(item.name())] = String(item.@value);
			}
			
			Common.resVersion = getConfig("resVersion");
			Common.serviceUrl = getConfig("socketServiceUrl");
			Common.isDebug = getConfig("bin") == "debug";
		}
		
		
		public function initResConfig(url:String):void
		{
			_resConfig = new Dictionary();
			var config:XML = Common.loader.getResByUrl(url, true);
			var children:XMLList = config.children();
			for each(var item:XML in children)
			{
				_resConfig[String(item.name())] = {
					url		: String(item.@url),
					type	: String(item.@type),
					nameID	: String(item.@nameID),
					newAppDomain : String(item.@newAppDomain) == "true"
				}
			}
		}
		
		
		public function initUIConfig():void
		{
			_uiConfig = new Dictionary();
			var config:XML = Common.loader.getResByConfigName("uiConfig", true);
			var children:XMLList = config.children();
			for each(var item:XML in children)
			{
				var value:String = String(item.@value);
				_uiConfig[String(item.name())] = (value == "") ? String(item) : value;
			}
		}
		
		
		public function initStyleConfig(config:XML=null):void
		{
			_styleList = new Dictionary();
			if(config == null) config = Common.loader.getResByConfigName("style", true);
			var children:XMLList = config.children();
			for each(var item:XML in children)
			{
				_styleList[String(item.@name)] = JSON.parse(item.@style);
			}
		}
		
		
		public function initSkinConfig(config:XML=null):void
		{
			_skinConfig = new Dictionary();
			if(config == null) config = Common.loader.getResByConfigName("skin", true);
			var children:XMLList = config.children();
			for each(var item:XML in children)
			{
				var list:Array = [];
				var attributes:XMLList = item.@*;
				for(var i:int=0; i < attributes.length(); i++)
				{
					list.push({
						state		: String(attributes[i].name()), 
						sourceName	: String(attributes[i])
					});
				}
				_skinConfig[String(item.name())] = list;
			}
		}
		
		
		
		
		
		public function getConfig(name:String):String
		{
			if(_config == null) return "";
			return _config[name];
		}
		
		
		public function getResConfig(name:String):Object
		{
			return _resConfig[name];
		}
		
		
		public function getUIConfig(name:String, ...rest):String
		{
			return StringUtil.substitute(_uiConfig[name], rest);
		}
		
		
		public function getStyle(name:String):Object
		{
			return _styleList[name];
		}
		
		
		public function getSkin(skinName:String):Array
		{
			return _skinConfig[skinName];
		}
		//
	}
}


class Enforcer {}