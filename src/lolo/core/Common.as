package lolo.core
{
	import flash.display.Stage;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.net.IService;
	import lolo.utils.logging.Logger;

	/**
	 * 公用接口、方法、引用集合
	 * @author LOLO
	 */
	public class Common
	{
		/**舞台*/
		public static var stage:Stage;
		
		/**后台通信服务*/
		public static var service:IService;
		
		/**用户界面管理*/
		public static var ui:IUIManager;
		/**布局管理*/
		public static var layout:ILayoutManager;
		/**资源加载、管理*/
		public static var loader:ILoadManager;
		/**配置信息管理*/
		public static var config:IConfigManager;
		/**语言包管理*/
		public static var language:ILanguageManager;
		
		/**音频管理*/
		public static var sound:ISoundManager;
		/**鼠标管理*/
		public static var mouse:IMouseManager;
		
		
		/**程序的版本号*/
		public static var version:String;
		/**资源库的语言、版本*/
		public static var resVersion:String;
		/**后台服务器的网络地址*/
		public static var serviceUrl:String = "";
		/**当前后台服务类型*/
		public static var serviceType:String = "";
		/**资源服务器的网络地址*/
		public static var resServerUrl:String = "";
		/**初始数据，由FlashVars传人*/
		public static var initData:Object;
		/**当前是否是调试环境*/
		public static var isDebug:Boolean;
		
		
		/**将资源地址转换成正确的网络地址[ 参数1：资源的url ]*/
		public static var getResUrl:Function = getResUrlFun;
		/**资源是否不是程序模块[ 参数1：资源的url ]*/
		public static var notModule:Function = notModuleFun;
		
		
		/**资源映射列表*/
		private static var _resList:Dictionary;
		
		
		
		
		/**
		 * 强制内存回收
		 */
		public static function gc():void
		{
			try {
				new LocalConnection().connect("gc");
				new LocalConnection().connect("gc");
			}
			catch(err:Error) {}
		}
		
		
		
		/**
		 * 初始化资源映射列表
		 * @param resListUrl
		 */
		public static function initResList(resListUrl:String):void
		{
			var bytes:ByteArray = Common.loader.getResByUrl(resListUrl, true);
			try {
				bytes.uncompress();
			}
			catch(error:Error) {}
			var str:String = bytes.toString();
			
			_resList = new Dictionary();
			var list:Array = str.split(";");
			var i:int, n:int, arr1:Array, arr2:Array, arr3:Array, url:String, name:String;
			for(i = 0; i < list.length; i++)
			{
				arr1 = list[i].split(":");
				arr2 = arr1[0].split("/");
				arr3 = arr2[arr2.length - 1].split(".");
				name = "";
				if(arr3.length > 1)//有后缀
				{
					for(n = 0; n < arr3.length-1; n++) {
						if(name != "") name += ".";
						name += arr3[n];
					}
					name += "_" + arr1[1];//md5短码
					name += "." + arr3[arr3.length - 1];//后缀
				}
				else {
					name = arr3[0] + "_" + arr1[1];//文件名 + md5短码
				}
				
				url = "";
				for(n = 0; n < arr2.length-1; n++) url += arr2[n] + "/";
				url += name;
				
				_resList[arr1[0]] = url;
			}
		}
		
		
		
		/**
		 * 将资源地址转换成正确的网络地址
		 * @param url 资源的url
		 * return 
		 */
		private static function getResUrlFun(url:String):String
		{
			url = url.replace(/\{resVersion\}/g, resVersion);//将url中的字符“{resVersion}”，转换成当前资源库的语言、版本
			if(_resList != null) {
				if(_resList[url] == null) {
					Logger.addLog("[LFW] 在resList中找不到资源: " + url, Logger.LOG_TYPE_WARN);
				}
				else {
					url = _resList[url];
				}
			}
			url = resServerUrl + url;//加上资源服务器的网络地址
			
			if(isDebug && notModule(url)) {
				url = url.replace("assets/", "");
				url = Common.config.getConfig("resUrl") + url;
			}
			
			return url;
		}
		
		
		/**
		 * 资源是否不是程序模块
		 * @param url 资源的url
		 * @return 
		 */
		private static function notModuleFun(url:String):Boolean
		{
			return url.indexOf("game/module/") == -1 && url.indexOf("Game.swf") == -1;
		}
		
		
		
		/**
		 * 通过key来获取初始数据，如果没有该数据，或者数据为空（空字符串），将会返回null
		 * @param key
		 * @return 
		 */
		public static function getInitDataByKey(key:String):String
		{
			var value:String = initData[key];
			if(value == "") value = null;
			return value;
		}
		//
	}
}