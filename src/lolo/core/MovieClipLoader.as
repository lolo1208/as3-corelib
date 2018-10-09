package lolo.core
{
	import flash.utils.Dictionary;
	
	import lolo.data.LoadItemModel;
	import lolo.display.IAnimation;
	import lolo.events.LoadEvent;
	import lolo.utils.logging.Logger;
	
	
	
	/**
	 * 动画加载器（不包含 lolo.display.Animation）
	 * @author LOLO
	 */
	public class MovieClipLoader
	{
		/**BitmapMovieClip类型动画的配置信息*/
		private static var _bmc:Dictionary;
		/**ControlledMovieClip类型动画的配置信息*/
		private static var _cmc:Dictionary;
		
		/**在加载完成后，需要异步初始化的动画*/
		private static var _mcList:Dictionary;
		
		
		
		/**
		 * 初始化
		 */
		public static function initialize():void
		{
			if(_mcList != null) return;
			
			_bmc = new Dictionary();
			_cmc = new Dictionary();
			_mcList = new Dictionary();
			
			var xml:XML = Common.loader.getResByConfigName("movieClipConfig", true);
			parseConfig(xml.bitmapMovieClip.item, _bmc);
			parseConfig(xml.controlledMovieClip.item, _cmc);
		}
		
		
		/**
		 * 解析一段Config
		 * @param items
		 * @param list
		 */
		private static function parseConfig(items:XMLList, list:Dictionary):void
		{
			for each(var item:XML in items)
			{
				var url:String = item.@url;
				var children:XMLList = item.*;
				for each(var ani:XML in children)
				{
					list[String(ani.name())] = { url:url };
				}
			}
		}
		
		
		
		/**
		 * 获取动画对应的文件url
		 * @param sourceName
		 * @param type [ 2:bmc, 3:cmc ]
		 * @return 
		 */
		public static function getURL(sourceName:String, type:int):String
		{
			var list:Dictionary;
			if(type == 2) list = _bmc;
			else list = _cmc;
			if(list[sourceName] == null) return null;
			return list[sourceName].url;
		}
		
		
		
		/**
		 * 异步加载某个动画
		 * @param sourceName
		 * @param type [ 2:bmc, 3:cmc ]
		 * @param ani 异步加载完成后，需要进行异步初始化的实例
		 * @return 是否成功开始异步加载该动画
		 */
		public static function asyncLoad(sourceName:String, type:int, ani:IAnimation):Boolean
		{
			var url:String = getURL(sourceName, type);
			
			//没有这个动画的配置信息
			if(url == null) {
				Logger.addLog("[LFW] 异步加载动画错误，没有动画 " + sourceName + " 的配置信息，动画类型：" + ani, Logger.LOG_TYPE_WARN);
				return false;
			}
			
			//将实例添加到异步初始化列表
			if(_mcList[url] == null) _mcList[url] = [];
			_mcList[url].push({ ani:ani, sourceName:sourceName });
			
			//开始异步加载
			var lim:LoadItemModel = new LoadItemModel();
			lim.type = Constants.RES_TYPE_CLA;
			lim.parseUrl(url);
			lim.isSecretly = true;
			lim.newAppDomain = true;//默认加载到新域
			Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadItemCompleteHandler);
			Common.loader.add(lim);
			Common.loader.start();
			return true;
		}
		
		
		/**
		 * 加载单个文件完成
		 * @param event
		 */
		private static function loadItemCompleteHandler(event:LoadEvent):void
		{
			//没有加载这个动画
			if(_mcList[event.lim.url] == null) return;
			
			//异步初始化
			for each(var info:Object in _mcList[event.lim.url])
			{
				(info.ani as IAnimation).asyncInitialize(info.sourceName);
			}
			
			//动画是否已经全部加载完毕了
			for(var url:String in _mcList) return;
			Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loadItemCompleteHandler);
		}
		//
	}
}