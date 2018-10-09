package lolo.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.ILRUCache;
	import lolo.data.LRUCache;
	import lolo.events.LoadEvent;
	import lolo.utils.logging.Logger;
	
	/**
	 * 图像加载器<br/>
	 * 文件可以是：.png, .jpg, .gif
	 * @author LOLO
	 */
	public class ImageLoader extends Sprite
	{
		/**
		 * 默认平滑锯齿策略：<br/>
		 *   Constants.POLICY_AUTO : 在宽高有变化时，自动启用平滑锯齿（默认）。<br/>
		 *   Constants.POLICY_ON   : 始终平滑锯齿。<br/>
		 *   Constants.POLICY_OFF  : 从不平滑锯齿。
		 */
		public static var defaultSmoothingPolicy:String = "auto";
		
		/**用于图像的LRU缓存*/
		private static var _cache:ILRUCache;
		/**等待被加载(loader=null)和正在加载的信息列表 { loader:用于加载的Loader, url:未格式化的URL, callbackList:加载完成后的回调列表 }*/
		private static var _loadList:Array;
		
		/**文件所在目录*/
		private var _directory:String;
		/**文件的名称*/
		private var _fileName:String;
		/**文件的扩展名*/
		private var _extension:String;
		/**当前文件的完整路径（未格式化）*/
		private var _url:String;
		
		/**设置的宽度*/
		private var _width:uint;
		/**设置的高度*/
		private var _height:uint;
		
		/**显示内容*/
		private var _content:Bitmap;
		/**是否已经加载完成*/
		private var _hasLoaded:Boolean;
		
		/**平滑锯齿策略。@see lolo.components.ImageLoader.defaultSmoothingPolicy*/
		private var _smoothingPolicy:String;
		
		/**
		 * 加载完成（成功或者失败）的回调<br/>
		 * 回调可以有两种形式：callback(success) 或 callback(success, this)
		 */
		public var callback:Function;
		
		
		
		
		/**
		 * 初始化
		 */
		public static function initialize():void
		{
			if(_cache == null) {
				_cache = new LRUCache();
				_cache.disposeCallback = disposeCallback;
				Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadItemCompleteHandler);
				
				_loadList = [];
			}
		}
		
		/**
		 * 加载单个文件完成
		 * @param event
		 */
		private static function loadItemCompleteHandler(event:LoadEvent):void
		{
			//图像资源会放入LRUCache中（并且会被LRUCache清理）
			if(event.lim.type == Constants.RES_TYPE_IMG) {
				if(!_cache.hasAdded(event.lim.url))
					_cache.add(event.lim.url, event.lim.data, event.lim.data.width * event.lim.data.height * 4);
			}
		}
		
		/**
		 * 缓存对象被清理时，调用的回调函数。
		 * @param bitmapData 要被清理的对象
		 */
		private static function disposeCallback(url:String, bitmapData:BitmapData):void
		{
			//bitmapData.dispose();
			Common.loader.getResByUrl(url, true);
		}
		
		/**
		 * 日志和状态信息
		 * @see LRUCache.log
		 */
		public static function get log():Object
		{
			return _cache.log;
		}
		
		
		/**
		 * 加载队列中的下一个文件
		 */
		private static function loadNext():void
		{
			//没有文件需要被加载
			if(_loadList.length == 0) return;
			
			var num:int = 0;//正在加载的文件数量
			var info:Object;//需要被加载的文件
			for(var i:int = 0; i < _loadList.length; i++)
			{
				if(_loadList[i].loader == null) {
					if(info == null) info = _loadList[i];
				}
				else {
					num++;
					if(num == 2) return;//最多2个文件同时加载
				}
			}
			
			//队列中没有文件需要被加载
			if(info == null) return;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadHandler);
			loader.load(new URLRequest(Common.getResUrl(info.url)), new LoaderContext(true));
			info.loader = loader;
		}
		
		
		/**
		 * 加载完成或失败
		 * @param event
		 */
		private static function loadHandler(event:Event):void
		{
			var loader:Loader = event.target.loader;
			var success:Boolean = event.type == Event.COMPLETE;
			var bitmapData:BitmapData;
			if(success) bitmapData = (loader.content as Bitmap).bitmapData;
			
			for(var i:int = 0; i < _loadList.length; i++)
			{
				var info:Object = _loadList[i];
				if(info.loader == loader) {
					//将图像缓存起来
					if(success) _cache.add(info.url, bitmapData, bitmapData.width * bitmapData.height * 4);
					
					for(var n:int = 0; n < info.callbackList.length; n++) {
						info.callbackList[n](info.url, success);
					}
					
					_loadList.splice(i, 1);
					break;
				}
			}
			
			if(!success) {
				Logger.addLog("[LFW] ImageLoader: " + (event as IOErrorEvent).text, Logger.LOG_TYPE_INFO);
			}
			
			loadNext();
			(event.target as LoaderInfo).loader.unload();
		}
		
		
		
		
		
		
		public function ImageLoader()
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			_smoothingPolicy = defaultSmoothingPolicy;
			_extension = Constants.EXTENSION_PNG;
		}
		
		
		
		/**
		 * 文件所在目录
		 */
		public function set directory(value:String):void
		{
			_directory = value;
		}
		public function get directory():String { return _directory; }
		
		
		/**
		 * 文件的名称
		 */
		public function set fileName(value:String):void
		{
			loadFile(value);
		}
		public function get fileName():String { return _fileName; }
		
		
		/**
		 * 文件的扩展名
		 */
		public function set extension(value:String):void
		{
			_extension = value;
		}
		public function get extension():String { return _extension; }
		
		
		
		/**
		 * 加载文件
		 */
		public function loadFile(fileName:String=null):void
		{
			if(fileName != null) _fileName = fileName;
			if(_directory == null || _directory == "" || _fileName == null || _fileName == "") return;
			
			var url:String = "assets/{resVersion}/img/" + _directory + "/" + _fileName + "." + _extension;
			if(url != _url)
			{
				_url = url;
				_hasLoaded = false;
				
				//图像已被缓存了
				var bitmapData:BitmapData = _cache.getValue(_url);
				if(bitmapData != null)
				{
					render(_url, true);
				}
				else
				{
					//先尝试从加载列表中拿到加载信息
					for(var i:int = 0; i < _loadList.length; i++) {
						var info:Object = _loadList[i];
						if(info.url == _url) break;
						info = null;
					}
					
					//还没这个url的加载信息
					if(info == null) {
						info = { url:_url, callbackList:[] };
						_loadList.push(info);
						loadNext();
					}
					
					info.callbackList.push(render);
				}
			}
		}
		
		
		/**
		 * 重新加载该图像
		 */
		public function reload():void
		{
			_url = null;
			loadFile();
		}
		
		
		/**
		 * 加载完成后的回调
		 * @param url
		 * @param success
		 */
		private function render(url:String, success:Boolean):void
		{
			//加载的这段时间内，URL已经改变了
			if(url != _url) return;
			
			if(_content == null) _content = new Bitmap();
			_content.bitmapData = _cache.getValue(_url);
			this.addChildAt(_content, 0);
			
			setWHS();
			_hasLoaded = true;
			
			var cb:Function = callback;
			callback = null;
			if(cb != null) {
				try {
					cb(success);
				}
				catch(error:Error) {
					cb(success, this);
				}
			}
		}
		
		
		/**
		 * 设置内容的宽高，并根据宽高设置是否使用像素平滑
		 */
		private function setWHS():void
		{
			if(_content == null) return;
			if(_width > 0) _content.width = _width;
			if(_height > 0) _content.height = _height;
			
			if(_smoothingPolicy == Constants.POLICY_ON)
				_content.smoothing = true;
			else if(_smoothingPolicy == Constants.POLICY_OFF)
				_content.smoothing = false;
			else
				_content.smoothing = _content.scaleX != 1 || _content.scaleY != 1;
		}
		
		
		/**
		 * <font color="red">已作废！</font>改为使用 <b>smoothingPolicy</b> 属性
		 */
		public function set smoothingType(value:int):void
		{
			if(value == 1) this.smoothingPolicy = Constants.POLICY_ON;
			else if(value == 2) this.smoothingPolicy = Constants.POLICY_OFF;
			else this.smoothingPolicy = Constants.POLICY_AUTO;
		}
		public function get smoothingType():int { return 0; }
		
		
		/**
		 * 平滑锯齿策略。
		 * @see lolo.components.ImageLoader.defaultSmoothingPolicy
		 */
		public function set smoothingPolicy(value:String):void
		{
			_smoothingPolicy = value;
			setWHS();
		}
		public function get smoothingPolicy():String { return _smoothingPolicy; }
		
		
		/**
		 * 是否已经加载完成
		 */
		public function get hasLoaded():Boolean
		{
			return _hasLoaded;
		}
		
		
		/**
		 * 显示内容
		 */
		public function get content():Bitmap
		{
			return _content;
		}
		
		
		override public function set width(value:Number):void
		{
			_width = value;
			setWHS();
		}
		override public function get width():Number
		{
			return _width > 0 ? _width : super.width;
		}
		
		
		override public function set height(value:Number):void
		{
			_height = value;
			setWHS();
		}
		override public function get height():Number
		{
			return _height > 0 ? _height : super.height;
		}
		
		
		
		/**
		 * 销毁<br/>
		 * 在丢弃该组件时，并不需要调用该方法
		 */
		public function dispose():void
		{
			_url = null;
			callback = null;
			
			if(_content && _content.parent == this) this.removeChild(_content);
		}
		
		
		
		/**
		 * <font color="#FF0000">注意：该属性仅供测试，请勿在实际项目中使用</font>
		 */
		public static function set cache(value:ILRUCache):void { _cache = value as LRUCache; }
		public static function get cache():ILRUCache { return _cache; }
		//
	}
}