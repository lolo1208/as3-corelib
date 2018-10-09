package lolo.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.ILRUCache;
	import lolo.data.LRUCache;
	import lolo.data.LoadItemModel;
	import lolo.events.LoadEvent;
	import lolo.utils.logging.Logger;
	import lolo.utils.optimize.CachePool;
	import lolo.utils.optimize.ConsumeBalancer;
	
	
	
	/**
	 * 位图显示对象，支持九切片。<br/>
	 * 在位图数据还未加载前，将会绘制一个半透明的矩形作为替代
	 * @author LOLO
	 */
	public class BitmapSprite extends Sprite
	{
		/**默认是否平滑锯齿*/
		public static var defaultSmoothing:Boolean = false;
		
		/**在图像数据还没加载前，默认显示的位图数据*/
		private static const DEFAULT_BITMAP_DATA:BitmapData = new BitmapData(1, 1, true, 0x33FF9900);
		/**loader为key，value为对应的、还未解析的图片描述信息(ByteArray)*/
		private static var _loaderList:Dictionary;
		
		/**LRU缓存*/
		private static var _cache:LRUCache;
		/**配置信息列表*/
		private static var _config:Dictionary;
		
		
		/**像素数据相对注册点的x坐标偏移值*/
		private var _offsetX:int;
		/**像素数据相对注册点的y坐标偏移值*/
		private var _offsetY:int;
		/**宽*/
		private var _width:uint;
		/**高*/
		private var _height:uint;
		/**图像的源名称*/
		private var _sourceName:String = "";
		/**普通位图图像*/
		private var _bitmap:Bitmap;
		/**九切片图像*/
		private var _scale9Bitmap:Scale9Bitmap;
		/**是否为九切片图像*/
		private var _isScale9:Boolean;
		/**是否平滑锯齿 @see lolo.display.BitmapSprite.defaultSmoothing*/
		private var _smoothing:Boolean;
		
		/**在sourceName改变时，是否需要自动重置宽高*/
		public var autoResetSize:Boolean = true;
		
		
		
		
		/**
		 * 初始化
		 */
		public static function initialize():void
		{
			if(_cache != null) return;
			
			_loaderList = new Dictionary();
			
			//解析配置文件
			_config = new Dictionary();
			var xml:XML = Common.loader.getResByConfigName("bitmapSpriteConfig", true);
			for each(var item:XML in xml.item)
			{
				var url:String = item.@url;
				for each(var bs:XML in item.*)
				{
					var bsInfo:Object = {
						offsetX	: int(bs.@x),
						offsetY	: int(bs.@y),
						width	: int(bs.@w),
						height	: int(bs.@h),
						url		: url
					};
					var gStr:String = bs.@g;
					if(gStr != "") {
						var gArr:Array = gStr.split(",");
						bsInfo.scale9Grid = new Rectangle(gArr[0], gArr[1], gArr[2], gArr[3]);
					}
					_config[String(bs.name())] = bsInfo;
				}
			}
			
			_cache = new LRUCache();
			_cache.maxMemorySize = 300 * 1024 * 1024;
			_cache.disposeCallback = disposeCallback;
			Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadItemCompleteHandler);
		}
		
		
		/**
		 * 缓存对象被清理时，调用的回调函数。
		 * @param data 要被清理的对象（BitmapData或Scale9BitmapData）
		 */
		private static function disposeCallback(sourceName:String, data:*):void
		{
			//for each(var frame:BitmapMovieClipData in frameList) frame.dispose();
		}
		
		
		/**
		 * 加载单个文件完成，解析图像包数据
		 * @param event
		 */
		private static function loadItemCompleteHandler(event:LoadEvent):void
		{
			if(event.lim.extension != Constants.EXTENSION_LD) return;//不是自定义数据
			var bytes:ByteArray = event.lim.data;
			if(bytes.length == 0) return;//是其他类型的自定义数据，已经被清空了
			bytes.position = 0;
			var flag:uint = bytes.readUnsignedByte();
			if(flag != Constants.FLAG_IDP && flag != Constants.FLAG_LIDP) return;
			
			//加载图像字节数据
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			_loaderList[loader] = bytes;
			
			var pos:uint = bytes.readUnsignedInt();
			bytes.position = pos;
			
			var len:uint = bytes.readUnsignedInt();
			var bigBitmapBytes:ByteArray = new ByteArray();
			bytes.readBytes(bigBitmapBytes, 0, len);
			
			loader.loadBytes(bigBitmapBytes);
		}
		
		
		/**
		 * 加载图像字节数据完成
		 * @param event
		 */
		private static function loader_completeHandler(event:Event):void
		{
			var loader:Loader = (event.target as LoaderInfo).loader;
			var bigBitmapData:BitmapData = (loader.content as Bitmap).bitmapData;
			var bytes:ByteArray = _loaderList[loader];
			delete _loaderList[loader];
			loader.unload();
			
			bytes.position = 5;
			var num:uint = bytes.readUnsignedShort();//包内包含的图像的数量
			for(var i:int=0; i < num; i++)
			{
				var name:String = bytes.readUTF();//图像的源名称
				
				//图像在 bigBitmapData 中的位置，宽高
				var x:uint = bytes.readUnsignedShort();
				var y:uint = bytes.readUnsignedShort();
				var width:uint = bytes.readUnsignedShort();
				var height:uint = bytes.readUnsignedShort();
				
				bytes.readShort();//图像的X偏移
				bytes.readShort();//图像的Y偏移
				
				//是九切片图像
				if(bytes.readUnsignedByte() == 1) {
					bytes.readUnsignedShort();//x
					bytes.readUnsignedShort();//y
					bytes.readUnsignedShort();//width
					bytes.readUnsignedShort();//height
				}
				
				ConsumeBalancer.addCallback(copyBitmapPixels, name, bigBitmapData, CachePool.getRectangle(x, y, width, height));
			}
			bytes.clear();
		}
		
		
		/**
		 * 在 bigBitmap 中拷贝图像的数据<br/>
		 * 在合适的时候，由 ConsumeBalancer 调用，均衡每帧CPU消耗。
		 * @param name 图像的源名称
		 * @param frameData 图像的数据
		 */
		private static function copyBitmapPixels(name:String, bigBitmapData:BitmapData, rect:Rectangle):void
		{
			//if(_cache.hasAdded(name)) return;
			
			//设置图像数据
			var p:Point = CachePool.getPoint();
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bitmapData.copyPixels(bigBitmapData, rect, p);
			CachePool.recover([ p, rect ]);
			
			//是九切片图像
			var info:Object = getConfigInfo(name);
			if(info.scale9Grid != null) {
				_cache.add(name, new Scale9BitmapData(bitmapData, info.scale9Grid), info.width * info.height * 4);
			}
			else {
				_cache.add(name, bitmapData, info.width * info.height * 4);
			}
			
			//回调
			if(info.callbacks) {
				for each(var callback:Function in info.callbacks) callback();
			}
			info.callbacks = null;
		}
		
		
		/**
		 * 获取指定源名称的图像在配置中的信息
		 * @param sourceName
		 * @return 
		 */
		public static function getConfigInfo(sourceName:String):Object
		{
			return _config[sourceName];
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
		 * 设置默认位图的颜色
		 * @param color ARGB颜色值
		 */
		public static function setDefaultBitmapDataColor(color:uint):void
		{
			DEFAULT_BITMAP_DATA.setPixel32(0, 0, color);
		}
		
		
		
		
		/**
		 * 构造一个位图显示对象
		 * @param sourceName 图像的源名称
		 */
		public function BitmapSprite(sourceName:String="")
		{
			super();
			_bitmap = new Bitmap();
			_scale9Bitmap = new Scale9Bitmap();
			_smoothing = defaultSmoothing;
			
			this.sourceName = sourceName;
			this.mouseEnabled = this.mouseChildren = false;
		}
		
		
		
		/**
		 * 图像的源名称
		 */
		public function set sourceName(value:String):void
		{
			//动画的源名称没有改变
			if(value == _sourceName) return;
			
			//删除之前的回调
			var info:Object = getConfigInfo(_sourceName);
			if(info != null && info.callbacks) delete info.callbacks[this];
			
			//清空内容
			while(numChildren > 0) removeChildAt(0);
			
			//新的源名称有误
			_sourceName = value;
			if(_sourceName == "" || _sourceName == null) return;
			
			//配置文件中不存在该资源
			info = getConfigInfo(_sourceName);
			if(info == null) {
				Logger.addLog("[LFW] BitmapSprite.sourceName: " + _sourceName + " 是不存在的资源！", Logger.LOG_TYPE_WARN);
				return;
			}
			
			//图像的属性
			_isScale9 = info.scale9Grid != null;
			_offsetX = info.offsetX;
			_offsetY = info.offsetY;
			if(autoResetSize) {
				_width = info.width;
				_height = info.height;
			}
			
			//有缓存，直接显示
			if(_cache.hasAdded(_sourceName))
			{
				render();
			}
			else
			{
				//无缓存，显示一个替代的半透矩形
				_bitmap.bitmapData = DEFAULT_BITMAP_DATA;
				_bitmap.x = _offsetX;
				_bitmap.y = _offsetY;
				_bitmap.width = _width;
				_bitmap.height = _height;
				this.addChildAt(_bitmap, 0);
				
				//加载UI图像包
				var lim:LoadItemModel = new LoadItemModel();
				lim.type = Constants.RES_TYPE_BINARY;
				lim.isSecretly = true;
				lim.parseUrl("assets/{resVersion}/ui/" + info.url);
				Common.loader.getResByUrl(lim.url, true);//可能已经加载过了
				Common.loader.add(lim);
				Common.loader.start();
				
				//等待加载完成的回调
				if(info.callbacks == null) info.callbacks = new Dictionary();
				info.callbacks[this] = render;
			}
		}
		public function get sourceName():String { return _sourceName; }
		
		
		/**
		 * 在加载完成后，显示当前图像
		 */
		private function render():void
		{
			//九切片图像
			if(_isScale9) {
				var s9bd:Scale9BitmapData = _cache.getValue(_sourceName);
				_scale9Bitmap.width = _width;
				_scale9Bitmap.height = _height;
				_scale9Bitmap.data = s9bd;
				
				for(var i:int; i < _scale9Bitmap.bitmaps.length; i++)
					this.addChildAt(_scale9Bitmap.bitmaps[i], 0);
				
				_bitmap.bitmapData = null;
			}
			else {
				var bitmapData:BitmapData = _cache.getValue(_sourceName);
				_bitmap.bitmapData = bitmapData;
				_bitmap.x = _offsetX;
				_bitmap.y = _offsetY;
				_bitmap.width = _width;
				_bitmap.height = _height;
				_bitmap.smoothing = _smoothing;
				this.addChildAt(_bitmap, 0);
				
				_scale9Bitmap.data = null;
			}
		}
		
		
		
		/**
		 * 重置宽高（将会置成当前图像的默认宽高）
		 */
		public function resetSize():void
		{
			if(_sourceName == "" || _sourceName == null) return;
			
			var info:Object = getConfigInfo(_sourceName);
			width = info.width;
			height = info.height;
		}
		
		
		
		/**
		 * 图像的宽<br/>
		 * 设置该值时，小数位将会被四舍五入
		 */
		override public function set width(value:Number):void
		{
			_width = Math.round(value);
			_scale9Bitmap.width = _width;
			_bitmap.width = _width;
		}
		
		/**
		 * 图像的高<br/>
		 * 设置该值时，小数位将会被四舍五入
		 */
		override public function set height(value:Number):void
		{
			_height = Math.round(value);
			_scale9Bitmap.height = _height;
			_bitmap.height = _height;
		}
		
		
		
		/**
		 * 是否为九切片图像
		 */
		public function get isScale9():Boolean { return _isScale9; }
		
		
		/**
		 * 位图图像（九切片图像并不会使用bitmap）
		 */
		public function get bitmap():Bitmap { return _bitmap; }
		
		
		/**
		 * 是否平滑锯齿 @see lolo.display.BitmapSprite.defaultSmoothing
		 */
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
			_bitmap.smoothing = value;
		}
		public function get smoothing():Boolean { return _smoothing; }
		
		
		/**
		 * <font color="#FF0000">注意：该属性仅供测试，请勿在实际项目中使用</font>
		 */
		public static function set cache(value:ILRUCache):void { _cache = value as LRUCache; }
		public static function get cache():ILRUCache { return _cache; }
		
		/**
		 * <font color="#FF0000">注意：该属性仅供测试，请勿在实际项目中使用</font>
		 */
		public static function set config(value:Dictionary):void { _config = value; }
		public static function get config():Dictionary { return _config; }
		//
	}
}