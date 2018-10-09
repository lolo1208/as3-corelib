package lolo.data
{
	import lolo.core.Common;
	import lolo.utils.StringUtil;
	
	/**
	 * 加载项数据模型
	 * @author LOLO
	 */
	public class LoadItemModel
	{
		/**优先级为0时，默认递增的优先级*/
		private static var _priority:int = 0;
		
		/**在配置文件(ResConfig)中的名称*/
		public var configName:String;
		/**url的替换参数*/
		public var urlArgs:Array;
		
		/**文件的url（未格式化的url）*/
		public var url:String;
		/**文件的类型*/
		public var type:String;
		/**文件的名称（不是必填，可重复）*/
		public var name:String;
		/**在加载该文件之前，需要加载好的文件url列表（未格式化的url）*/
		public var urlList:Array;
		/**是否将资源加载到新的应用程序域中*/
		public var newAppDomain:Boolean;
		
		/**是否为暗中加载项*/
		public var isSecretly:Boolean;
		/**加载优先级，数字越大，优先级越高（正常加载项的优先级高于一切暗中加载项）*/
		public var priority:int;
		
		/**文件的后缀名（全小写）*/
		public var extension:String;
		
		/**是否需要格式化文件的url*/
		public var needToFormatUrl:Boolean;
		/**文件是否已经加载完毕*/
		public var hasLoaded:Boolean;
		
		/**总字节数*/
		public var bytesTotal:Number = 1;
		/**已加载的字节数*/
		public var bytesLoaded:Number = 0;
		/**获得的HTTP状态码*/
		public var status:int;
		
		/**所使用的加载器[Loader 或  URLLoader]*/
		public var loader:*;
		/**已经加载好的数据*/
		public var data:*;
		/**上次加载更新的时间*/
		public var lastUpdateTime:Number;
		/**剩余重新加载的次数*/
		public var reloadCount:int = 5;
		
		/**加载耗时（毫秒）*/
		public var loadTime:Number;
		
		
		
		/**
		 * 下一个默认的优先级
		 */
		public static function get nextPriority():int
		{
			return --_priority;
		}
		
		
		
		
		public function LoadItemModel(	configName:String=null,
										isSecretly:Boolean=false, priority:int=0,
										urlArgs:Array=null, urlList:Array=null,
										url:String=null, type:String="class", name:String="",
										needToFormatUrl:Boolean=true
		) {
			this.type = type;
			this.name = name;
			this.isSecretly = isSecretly;
			this.priority = (priority == 0) ? nextPriority : priority;
			this.urlList = (urlList == null) ? [] : urlList;
			this.needToFormatUrl = needToFormatUrl;
			
			if(configName) {
				setConfigName(configName, urlArgs);
			}
			else {
				parseUrl(url, urlArgs);
			}
		}
		
		
		/**
		 * 在配置文件(ResConfig)中的名称。可配参数{ url, type, name }，至少应包含url
		 * @param configName
		 */
		public function setConfigName(configName:String, urlArgs:Array=null):void
		{
			this.configName = configName;
			
			if(configName) {
				var config:Object = Common.config.getResConfig(configName);
				this.type = config.type;
				this.newAppDomain = config.newAppDomain;
				parseUrl(config.url, urlArgs);
				if(config.nameID != "") this.name = Common.language.getLanguage(config.nameID);
			}
		}
		
		
		
		/**
		 * 解析（后缀名）和组合URL
		 * @param url
		 */
		public function parseUrl(url:String, urlArgs:Array=null):void
		{
			if(!url) return;
			
			this.urlArgs = urlArgs;
			this.url = (urlArgs == null) ? url : StringUtil.substitute(url, urlArgs);
			var arr:Array = this.url.split(".");
			extension = arr[arr.length - 1].toLocaleLowerCase();
		}
		
		
		
		/**
		 * 添加urlList(通过在Config中的名称列表)。如果url还没加载完成或没在加载队列中，将会自动添加到加载队列。
		 * @param rest
		 * @return 
		 */
		public function addUrlListByCN(...rest):LoadItemModel
		{
			var args:Array = (rest.length == 1 && rest[0] is Array) ? rest[0] : rest;
			
			for(var i:int=0; i < args.length; i++)
			{
				Common.loader.add(new LoadItemModel(args[i], isSecretly));
				urlList.push(Common.config.getResConfig(args[i]).url);
			}
			return this;
		}
		//
	}
}