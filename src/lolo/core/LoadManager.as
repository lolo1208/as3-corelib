package lolo.core
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import lolo.data.HashMap;
	import lolo.data.LoadItemModel;
	import lolo.events.LoadEvent;
	import lolo.utils.FrameTimer;
	import lolo.utils.StringUtil;
	import lolo.utils.TimeUtil;
	import lolo.utils.logging.LogSampler;
	import lolo.utils.logging.Logger;
	import lolo.utils.zip.ZipReader;
	
	/**
	 * 加载管理器
	 * @author LOLO
	 */
	public class LoadManager extends EventDispatcher implements ILoadManager
	{
		/**允许并发加载的最大数量*/
		private static const MAX_LOAD_COUNT:uint = 3;
		/**暗中加载时，允许并发加载的最大数量*/
		private static const SECRETLY_LOAD_COUNT:uint = 2;
		/**判定加载超时的时间（毫秒）*/
		private static const TIMEOUT:uint = 1000 * 60;
		/**单例的实例*/
		private static var _instance:LoadManager;
		
		/**需要加载的加载项队列*/
		private var _loadList:HashMap;
		/**正在加载的加载项列表*/
		private var _loadingList:HashMap;
		/**已经加载好的加载项队列*/
		private var _resList:HashMap;
		/**临时保存loader的引用列表（防止loader被GC）*/
		private var _tempLoaderList:Dictionary;
		/**显示加载项全部加载完成时的回调列表*/
		private var _callbackList:Vector.<Function>;
		/**所有加载项全部加载完毕时的回调列表*/
		private var _allCallbackList:Vector.<Function>;
		
		/**加载超时计时器*/
		private var _timeoutTimer:FrameTimer;
		
		/**是否被主动停止了*/
		private var _isStop:Boolean = true;
		/**当前显示加载文件的编号*/
		private var _numCurrent:uint = 0;
		/**当前正在监听加载的item*/
		private var _currentLim:LoadItemModel;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():LoadManager
		{
			if(_instance == null) _instance = new LoadManager(new Enforcer());
			return _instance;
		}
		
		
		
		public function LoadManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Common.loader获取实例");
				return;
			}
			
			_loadList = new HashMap();
			_loadingList = new HashMap();
			_resList = new HashMap();
			_tempLoaderList = new Dictionary();
			_callbackList = new Vector.<Function>();
			_allCallbackList = new Vector.<Function>();
			
			_timeoutTimer = new FrameTimer(1000, timeoutTimerHandler);
		}
		
		
		public function add(lim:LoadItemModel):LoadItemModel
		{
			var oldLim:LoadItemModel = _loadList.getValueByKey(lim.url);//已经在加载队列中了
			if(oldLim == null) oldLim = _loadingList.getValueByKey(lim.url);//正在加载中
			if(oldLim == null) oldLim = _resList.getValueByKey(lim.url);//已经加载完毕了
			
			if(oldLim != null) {
				oldLim.isSecretly = lim.isSecretly;
				oldLim.priority = lim.priority;
				if(oldLim.name == "" || oldLim.name == null) oldLim.name = lim.name;
				lim = oldLim;
			}
			else {
				_loadList.add(lim, lim.url);
			}
			
			sortLoadList();
			return lim;
		}
		
		public function sortLoadList():void
		{
			var list:Array = _loadList.values.sort(limPrioritySort);
			_loadList.clear();
			for(var i:int=0; i < list.length; i++) _loadList.add(list[i], list[i].url);
		}
		
		/**
		 * 加载项数据模型的加载优先级排序方法
		 * @param lim1
		 * @param lim2
		 * @return 
		 */
		private function limPrioritySort(lim1:LoadItemModel, lim2:LoadItemModel):int
		{
			if(lim1.isSecretly && !lim2.isSecretly) return 1;
			if(lim2.isSecretly && !lim1.isSecretly) return -1;
			if(lim1.priority > lim2.priority) return -1;
			if(lim2.priority > lim1.priority) return 1;
			return 0;
		}
		
		
		public function start(callback:Function=null, allCompleteCallback:Function=null):void
		{
			if(isSecretly) {
				if(callback != null) callback();
				dispatchEvent(new LoadEvent(LoadEvent.COMPLETE, new LoadItemModel(null)));
			}
			else {
				if(callback != null && _callbackList.indexOf(callback) == -1)
					_callbackList.push(callback);
			}
			
			if(_loadList.length > 0 || _loadingList.length > 0) {
				_isStop = false;
				if(allCompleteCallback != null && _allCallbackList.indexOf(allCompleteCallback) == -1)
					_allCallbackList.push(allCompleteCallback);
				loadNext();
			}
			else {
				if(allCompleteCallback != null) allCompleteCallback();
				dispatchEvent(new LoadEvent(LoadEvent.ALL_COMPLETE, new LoadItemModel(null)));
			}
		}
		
		
		/**
		 * 加载下一个文件
		 */
		private function loadNext():void
		{
			if(_isStop) return;//已经被停止了
			if(_loadList.length == 0) return;//没有需要加载的资源
			if(_loadingList.length >= MAX_LOAD_COUNT) return;//达到了允许的最大并发加载数
			
			var lim:LoadItemModel, prevLim:LoadItemModel, tempLim:LoadItemModel;
			var i:int, n:int;
			
			//按顺序拿一个可加载的文件
			for(i = 0; i < _loadList.length; i++) {
				tempLim = _loadList.getValueByIndex(i);
				if(getCanLoad(tempLim)) {
					lim = tempLim;
					break;
				}
			}
			
			//接下来要加载的文件是暗中加载项
			if(lim != null && lim.isSecretly) {
				tempLim = canLoadNormalLim;
				if(tempLim != null) {
					lim = tempLim;
				}
				else {
					if(_loadingList.length >= SECRETLY_LOAD_COUNT) return;
				}
			}
			
			//完全没文件可加载
			if(lim == null) return;
			
			_loadList.removeByKey(lim.url);
			_loadingList.add(lim, lim.url);
			dispatchEvent(new LoadEvent(LoadEvent.START, lim));
			
			//创建loader，并侦听事件
			var loader:EventDispatcher;
			if(lim.type == Constants.RES_TYPE_ZIP || lim.type == Constants.RES_TYPE_XML || lim.type == Constants.RES_TYPE_BINARY) {
				lim.loader = new URLLoader();
				loader = lim.loader;
			}
			else {
				lim.loader = new Loader();
				loader = lim.loader.contentLoaderInfo;
				(loader as LoaderInfo).uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, Logger.uncaughtErrorHandler);
			}
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler);
			
			lim.lastUpdateTime = lim.loadTime = TimeUtil.getTime();
			_timeoutTimer.start();
			
			//解析出文件的url
			var resUrl:String = lim.needToFormatUrl ? Common.getResUrl(lim.url) : lim.url;
			
			//根据类型，开始加载
			switch(lim.type)
			{
				case Constants.RES_TYPE_CLA: case Constants.RES_TYPE_SWF: case Constants.RES_TYPE_FONT:
					var appDomain:ApplicationDomain = lim.newAppDomain
						? new ApplicationDomain()
						: ApplicationDomain.currentDomain;
					lim.loader.load(new URLRequest(resUrl), new LoaderContext(true, appDomain));
					break;
				case Constants.RES_TYPE_XML: case Constants.RES_TYPE_ZIP: case Constants.RES_TYPE_BINARY:
					lim.loader.dataFormat = URLLoaderDataFormat.BINARY;
					lim.loader.load(new URLRequest(resUrl));
					break;
				case Constants.RES_TYPE_IMG:
					lim.loader.load(new URLRequest(resUrl), new LoaderContext(true));
					break;
				
				default:
					Logger.addLog("[LFW] 资源类型: " + lim.type + " 无法识别", Logger.LOG_TYPE_WARN);
			}
			
			if(_loadingList.length < MAX_LOAD_COUNT) loadNext();
		}
		
		/**
		 * 获取该文件是否可以加载了（所依赖的文件是否全部加载完毕了）
		 * @param lim
		 * @return 
		 */
		private function getCanLoad(lim:LoadItemModel):Boolean
		{
			for(var i:int = 0; i < lim.urlList.length; i++) {
				if(_resList.getValueByKey(lim.urlList[i]) == null) return false;
			}
			return true;
		}
		
		/**
		 * 获取一个可以加载的正常项（不是暗中加载项）
		 * @return 
		 */
		private function get canLoadNormalLim():LoadItemModel
		{
			for(var i:int = 0; i < _loadList.length; i++) {
				var lim:LoadItemModel = _loadList.getValueByIndex(i);
				if(!lim.isSecretly && getCanLoad(lim)) return lim;
			}
			return null;
		}
		
		
		/**
		 * 加载中
		 * @param event
		 */
		private function progressHandler(event:ProgressEvent):void
		{
			var lim:LoadItemModel = getLimByLoader(event.target);
			lim.bytesLoaded = event.bytesLoaded;
			lim.bytesTotal = event.bytesTotal;
			lim.lastUpdateTime = TimeUtil.getTime();
			
			if(_currentLim == null) _currentLim = lim;
			if(lim == _currentLim) dispatchEvent(new LoadEvent(LoadEvent.PROGRESS, lim));
		}
		
		
		/**
		 * 收到HTTP状态码
		 * @param event
		 */
		private function httpStatusHandler(event:HTTPStatusEvent):void
		{
			var lim:LoadItemModel = getLimByLoader(event.target);
			lim.status = event.status;
		}
		
		
		/**
		 * 加载完成
		 * @param event
		 */
		private function completeHandler(event:Event):void
		{
			var lim:LoadItemModel = getLimByLoader(event.target);
			switch(lim.type)
			{
				case Constants.RES_TYPE_XML:
					var bytes:ByteArray = event.target.data;
					try {
						bytes.uncompress();
					}
					catch(error:Error) {}
					
					try {
						lim.data = new XML(bytes.toString());
					}
					catch(error:Error) {
						throw new Error("[LFW] 转换成XML失败！XML格式错误：" + lim.url);
					}
					break;
				case Constants.RES_TYPE_IMG:
					lim.data = (lim.loader.content as Bitmap).bitmapData.clone();
					break;
				case Constants.RES_TYPE_SWF:
					lim.data = lim.loader.content;
					break;
				case Constants.RES_TYPE_ZIP:
					lim.data = new ZipReader(event.target.data);
					break;
				case Constants.RES_TYPE_BINARY:
					lim.data = event.target.data;
					if(lim.extension == Constants.EXTENSION_LD) {
						try { lim.data.uncompress(); } catch(error:Error) {}
					}
					break;
			}
			if(lim.type == Constants.RES_TYPE_CLA || lim.type == Constants.RES_TYPE_FONT) {
				//调试环境，不是程序模块，并且需要加载到当前程序域
				if(Common.isDebug && Common.notModule(lim.url) && !lim.newAppDomain)
				{
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadClassBytesCompleteHandler);
					loader.loadBytes(
						lim.loader.contentLoaderInfo.bytes,
						new LoaderContext(false, ApplicationDomain.currentDomain)
					);
					_tempLoaderList[loader] = lim;
				}
				else {
					loadClassBytesCompleteHandler(null, lim);
				}
			}
			else {
				loadItemComplete(lim);
			}
		}
		
		/**
		 * bytes方式加载class资源成功
		 */
		private function loadClassBytesCompleteHandler(event:Event, lim:LoadItemModel=null):void
		{
			if(event != null) {
				var loader:Loader = (event.target as LoaderInfo).loader;
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadClassBytesCompleteHandler);
				lim = _tempLoaderList[loader];
				delete _tempLoaderList[loader];
				loader.unload();
			}
			
			//如果被停止了，或者已经被再次创建了（debug环境才会有这异步问题）
			if(_isStop || _loadList.getValueByKey(lim.url) != null || _resList.getValueByKey(lim.url) != null) return;
			
			lim.data = lim.newAppDomain
				? lim.loader.contentLoaderInfo.applicationDomain
				: ApplicationDomain.currentDomain;
			
			loadItemComplete(lim);
		}
		
		
		/**
		 * 加载单个文件完成
		 * @param lim
		 */
		private function loadItemComplete(lim:LoadItemModel):void
		{
			if(lim.loader is Loader) (lim.loader as Loader).unload();
			
			lim.loadTime = TimeUtil.getTime() - lim.loadTime;
			LogSampler.addLoadFileSampleLog(lim);
			
			if(!lim.isSecretly) _numCurrent++;
			
			_resList.add(lim, lim.url);
			removeLoader(lim);
			lim.hasLoaded = true;
			lim.bytesLoaded = lim.bytesTotal;
			dispatchEvent(new LoadEvent(LoadEvent.ITEM_COMPLETE, lim));
			
			//显示加载项都已经加载完成了
			var list:Array = _loadList.values.concat(_loadingList.values.concat());
			var cbList:Vector.<Function> = _callbackList.concat();
			var acbList:Vector.<Function> = _allCallbackList.concat();
			if(list.length == 0) _allCallbackList.length = 0;
			
			var notDisplay:Boolean = true;
			var i:int;
			for(i = 0; i < list.length; i++) {
				if(!list[i].isSecretly) {
					notDisplay = false;
					break;
				}
			}
			if(notDisplay) {
				_numCurrent = 0;
				_callbackList.length = 0;
				for(i = 0; i < cbList.length; i++) cbList[i]();
				dispatchEvent(new LoadEvent(LoadEvent.COMPLETE, lim));
			}
			
			//已经没有文件需要加载了
			if(list.length == 0) {
				for(i = 0; i < acbList.length; i++) acbList[i]();
				dispatchEvent(new LoadEvent(LoadEvent.ALL_COMPLETE, lim));
			}
			
			loadNext();
		}
		
		
		/**
		 * 加载失败
		 * @param event
		 */
		private function errorHandler(event:Event):void
		{
			var lim:LoadItemModel = getLimByLoader(event.target);
			
			Logger.addLog("[LFW] 加载错误: " + lim.url + "  " + event.type, Logger.LOG_TYPE_INFO);
			LogSampler.addLoadErrorLog(lim, "notFound");
			
			dispatchEvent(new LoadEvent(LoadEvent.ERROR, lim));
			addToReload(lim);
		}
		
		/**
		 * 加载超时计时器
		 */
		private function timeoutTimerHandler():void
		{
			if(_loadingList.length == 0) {
				_timeoutTimer.reset();
			}
			else {
				var lim:LoadItemModel;
				for(var i:int; i < _loadingList.length; i++) {
					lim = _loadingList.getValueByIndex(i);
					if(TimeUtil.getTime() - lim.lastUpdateTime >= TIMEOUT) {
						Logger.addLog("[LFW] 加载超时: " + lim.url, Logger.LOG_TYPE_INFO);
						LogSampler.addLoadErrorLog(lim, "timeout");
						
						dispatchEvent(new LoadEvent(LoadEvent.TIMEOUT, lim));
						addToReload(lim);
					}
				}
			}
		}
		
		
		/**
		 * 添加到加载列表，重新进行加载
		 * @param lim
		 */
		private function addToReload(lim:LoadItemModel):void
		{
			removeLoader(lim);
			
			lim.reloadCount--;
			if(lim.reloadCount > 0) {
				lim.priority = LoadItemModel.nextPriority;//优先级延后
				add(lim);
				if(!running) setTimeout(loadNext, Common.isDebug ? 100 : 4000);
			}
			else {
				Common.ui.loadBar.hide();
			}
		}
		
		
		
		/**
		 * 根据loader来获取加载项数据模型
		 * @param loader
		 * @return 
		 */
		private function getLimByLoader(loader:Object):LoadItemModel
		{
			if(loader is LoaderInfo) loader = loader.loader;
			for(var i:int = 0; i < _loadingList.length; i++) {
				var tempLim:LoadItemModel = _loadingList.getValueByIndex(i);
				if(tempLim.loader == loader) return tempLim;
			}
			return null;
		}
		
		
		/**
		 * 从正在加载队列中移除加载项，并移除加载项的所有加载事件、清除loader
		 * @param lim
		 */
		private function removeLoader(lim:LoadItemModel):void
		{
			if(lim == _currentLim) _currentLim = null;
			if(lim.loader == null) return;//已经被清理过了
			var loader:Object
				= (lim.type == Constants.RES_TYPE_ZIP || lim.type == Constants.RES_TYPE_XML || lim.type == Constants.RES_TYPE_BINARY)
				? lim.loader
				: lim.loader.contentLoaderInfo;
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			
			try { loader.close(); }
			catch(error:Error) {}
			try { loader.unload(); }
			catch(error:Error) {}
			lim.loader = null;
			
			_loadingList.removeByKey(lim.url);
		}
		
		
		public function stop():void
		{
			_isStop = true;
			while(_loadingList.values.length > 0)
			{
				var lim:LoadItemModel = _loadingList.getValueByIndex(0);
				_loadList.add(lim, lim.url);
				removeLoader(lim);
			}
			_loadingList.clear();
		}
		
		
		public function clearLoadList(type:uint=0):void
		{
			var list:Array = _loadList.values.concat(_loadingList.values.concat());
			for(var i:int = 0; i < list.length; i++)
			{
				var lim:LoadItemModel = list[i];
				var clearMark:Boolean = (type == 0);
				if(!clearMark) {
					clearMark = lim.isSecretly ? (type == 2) : (type == 1);
				}
				if(clearMark) {
					removeLoader(lim);
					_loadList.removeByKey(lim.url);
				}
			}
			_callbackList.length = 0;
			_allCallbackList.length = 0;
			loadNext();
		}
		
		
		public function remove(lim:LoadItemModel):void
		{
			var list:Array = _loadList.values.concat(_loadingList.values.concat());
			if(list.indexOf(lim) != -1) {
				removeLoader(lim);
				_loadList.removeByKey(lim.url);
			}
		}
		
		
		public function getResByUrl(url:String, clear:Boolean=false):*
		{
			var lim:LoadItemModel = _resList.getValueByKey(url);
			if(lim == null) return null;
			if(clear) _resList.removeByKey(url);
			if(lim.data is ByteArray) (lim.data as ByteArray).position = 0;
			return lim.data;
		}
		
		public function getResByConfigName(configName:String, clear:Boolean=false, urlArgs:Array=null):*
		{
			var config:Object = Common.config.getResConfig(configName);
			var url:String = (urlArgs != null) ? StringUtil.substitute(config.url, urlArgs) : config.url;
			return getResByUrl(url, clear);
		}
		
		
		public function getLoadItemModelByUrl(url:String):LoadItemModel
		{
			var lim:LoadItemModel = _resList.getValueByKey(url);
			if(lim != null) return lim;
			
			lim = _loadList.getValueByKey(url);
			if(lim != null) return lim;
			
			lim = _loadingList.getValueByKey(url);
			if(lim != null) return lim;
			
			return null;
		}
		
		
		public function getLoadItemModelByRes(res:*):LoadItemModel
		{
			for(var i:int = 0; i < _resList.length; i++) {
				var lim:LoadItemModel = _resList.getValueByIndex(i);
				if(lim.data == res) return lim;
			}
			return null;
		}
		
		
		
		public function hasResLoaded(url:String):Boolean
		{
			return _resList.getValueByKey(url) != null;
		}
		
		public function get running():Boolean
		{
			return _loadingList.length > 0 && !_isStop;
		}
		
		public function get isSecretly():Boolean
		{
			var list:Array = _loadList.values.concat(_loadingList.values.concat());
			for(var i:int = 0; i < list.length; i++) {
				if(!list[i].isSecretly) return false;
			}
			return true;
		}
		
		public function get numCurrent():uint { return _numCurrent; }
		
		public function get numTotal():uint
		{
			var num:int = _numCurrent;
			for(var i:int = 0; i < _loadingList.values.length; i++) {
				var lim:LoadItemModel = _loadingList.values[i];
				if(!lim.isSecretly) num++;
			}
			return num;
		}
		//
	}
}

class Enforcer {}