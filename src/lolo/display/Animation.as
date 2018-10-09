package lolo.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
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
	import lolo.events.AnimationEvent;
	import lolo.events.LoadEvent;
	import lolo.utils.FrameTimer;
	import lolo.utils.logging.Logger;
	import lolo.utils.optimize.CachePool;
	import lolo.utils.optimize.ConsumeBalancer;
	
	/**
	 * 以位图形式播放的动画
	 * @author LOLO
	 */
	public class Animation extends Sprite implements IAnimation
	{
		/**在动画数据还没加载前，动画每帧显示的位图数据（空帧）*/
		private static const EMPTY_FRAME:BitmapMovieClipData = new BitmapMovieClipData(1, 1);
		/**当配置信息中没有sourceName对应的动画时，防止后续报错，将使用该空帧列表*/
		private static const EMPTY_FRAME_LIST:Vector.<BitmapMovieClipData> = new Vector.<BitmapMovieClipData>([EMPTY_FRAME, EMPTY_FRAME]);
		
		/**loader为key，value为对应的、还未解析的动画描述信息*/
		private static var _aniInfoList:Dictionary;
		
		/**LRU缓存*/
		private static var _cache:LRUCache;
		/**配置信息列表*/
		private static var _config:Dictionary;
		
		/**用于呈现位图*/
		private var _bitmap:Bitmap;
		/**帧序列动画*/
		private var _frameList:Vector.<BitmapMovieClipData>;
		
		/**动画的帧频*/
		private var _fps:uint;
		/**动画是否正在播放中*/
		private var _playing:Boolean;
		/**当前帧编号*/
		private var _currentFrame:uint;
		/**是否反向播放动画*/
		private var _reverse:Boolean;
		
		/**动画的源名称*/
		private var _sourceName:String = "";
		
		/**是否对位图进行平滑处理。默认：false<br/><font color="red">注意：启用平滑处理将会降低渲染效率</font>*/
		private var _smoothing:Boolean;
		
		/**动画的重复播放次数（值为0时，表示无限循环）*/
		private var _repeatCount:uint;
		/**动画当前已重复播放的次数*/
		private var _currentRepeatCount:uint;
		/**动画达到重复播放次数时的停止帧*/
		private var _stopFrame:uint;
		/**动画在完成了指定重复次数，并到达了停止帧时的回调（异常情况将不会触发回调，如：位图数据包还未初始化，帧数为0，以及重复次数为0）*/
		private var _callback:Function;
		/**是否需要抛出AnimationEvent.ENTER_FRAME事件*/
		private var _dispatchEnterFrame:Boolean;
		
		/**用于播放动画*/
		private var _timer:FrameTimer;
		
		
		
		/**
		 * 初始化
		 */
		public static function initialize():void
		{
			if(_cache != null) return;
			
			_aniInfoList = new Dictionary();
			
			//解析配置文件
			_config = new Dictionary();
			var xml:XML = Common.loader.getResByConfigName("animationConfig", true);
			for each(var item:XML in xml.item)
			{
				var url:String = item.@url;
				for each(var ani:XML in item.*)
				{
					_config[String(ani.name())] = {
						url			: url,
						totalFrames	: uint(ani.@tf),
						fps			: uint(ani.@fps)
					};
				}
			}
			
			_cache = new LRUCache();
			_cache.maxMemorySize = 300 * 1024 * 1024;
			_cache.disposeCallback = disposeCallback;
			Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadItemCompleteHandler);
		}
		
		
		/**
		 * 缓存对象被清理时，调用的回调函数。
		 * @param bitmapData 要被清理的对象
		 */
		private static function disposeCallback(sourceName:String, frameList:Vector.<BitmapMovieClipData>):void
		{
			//for each(var frame:BitmapMovieClipData in frameList) frame.dispose();
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
		 * 加载单个文件完成
		 * @param event
		 */
		private static function loadItemCompleteHandler(event:LoadEvent):void
		{
			if(event.lim.extension != Constants.EXTENSION_LD) return;//不是自定义数据
			var bytes:ByteArray = event.lim.data;
			if(bytes.length == 0) return;//是其他类型的自定义数据，已经被清空了
			bytes.position = 0;
			if(bytes.readUnsignedByte() != Constants.FLAG_AD) return;
			
			//加载图像字节数据
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			_aniInfoList[loader] = bytes;
			
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
			var loader:Loader = event.target.loader;
			var bigBitmapData:BitmapData = (loader.content as Bitmap).bitmapData;
			var bytes:ByteArray = _aniInfoList[loader];
			delete _aniInfoList[loader];
			loader.unload();
			
			bytes.position = 5;
			var num:uint = bytes.readUnsignedByte();//动画数量
			for(var i:int=0; i < num; i++)
			{
				var name:String = bytes.readUTF();//动画名称
				var hasCache:Boolean = _cache.hasAdded(name);
				var totalFrames:uint = bytes.readUnsignedShort();//动画总帧数
				var fps:uint = bytes.readUnsignedByte();//默认帧频
				var frameList:Vector.<BitmapMovieClipData> = new Vector.<BitmapMovieClipData>();
				var memory:Number = 0;
				for(var n:int=0; n < totalFrames; n++)
				{
					var x:int = bytes.readShort();//在 bigBitmapData 中的位置
					var y:int = bytes.readShort();
					var width:uint = bytes.readUnsignedShort();//帧宽高
					var height:uint = bytes.readUnsignedShort();
					var offsetX:int = bytes.readShort();//帧偏移
					var offsetY:int = bytes.readShort();
					
					if(!hasCache) {
						var bmcData:BitmapMovieClipData = new BitmapMovieClipData(width, height, offsetX, offsetY);
						frameList.push(bmcData);
						ConsumeBalancer.addCallback(copyFramePixels, name, n, bigBitmapData, CachePool.getRectangle(x, y, width, height));
						memory += width * height * 4;
					}
				}
				
				if(!hasCache) _cache.add(name, frameList, memory);
			}
			bytes.clear();
		}
		
		
		/**
		 * 拷贝帧的数据<br/>
		 * 在合适的时候，由 ConsumeBalancer 调用，均衡每帧CPU消耗。
		 * @param name 动画的名称
		 * @param index 帧的索引
		 * @param frameData 帧数据
		 */
		private static function copyFramePixels(name:String, index:uint, bigBitmapData:BitmapData, rect:Rectangle):void
		{
			var p:Point = CachePool.getPoint();
			var frameList:Vector.<BitmapMovieClipData> = _cache.getValue(name);
			frameList[index].copyPixels(bigBitmapData, rect, p);
			CachePool.recover([ p, rect ]);
			
			//这个动画的帧数据都已经设置好了，执行加载回调
			if(index == frameList.length - 1) {
				var info:Object = getConfigInfo(name);
				if(info.callbacks) {
					for each(var callback:Function in info.callbacks) callback(name);
				}
				info.callbacks = null;
			}
		}
		
		
		
		/**
		 * 缓存中是否有指定 sourceName 的动画
		 * @param sourceName
		 * @return 
		 */
		public static function hasAnimation(sourceName:String):Boolean
		{
			return _cache.hasAdded(sourceName);
		}
		
		/**
		 * 获取一个动画对应的动画包的url
		 * @param sourceName
		 * @return 
		 */
		public static function getUrl(sourceName:String):String
		{
			var info:Object = getConfigInfo(sourceName);
			if(info == null) return null;
			return "assets/{resVersion}/ani/" + info.url;
		}
		
		/**
		 * 获取指定源名称的动画在配置中的信息
		 * @param sourceName
		 * @return 
		 */
		public static function getConfigInfo(sourceName:String):Object
		{
			return _config[sourceName];
		}
		
		
		
		
		
		/**
		 * 构造一个位图动画<br/>
		 * @param sourceName 动画的源名称
		 * @param fps 动画的帧频（默认值：0，表示使用打包时的设置的帧频）
		 */
		public function Animation(sourceName:String="", fps:uint=0)
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			
			_bitmap = new Bitmap();
			this.addChildAt(_bitmap, 0);
			
			_timer = new FrameTimer(1000, timerHandler);
			
			this.sourceName = sourceName;
			if(fps != 0) this.fps = fps;
		}
		
		
		
		public function play(startFrame:uint=0, repeatCount:uint=0, stopFrame:uint=0, callback:Function=null):void
		{
			if(startFrame == 0) startFrame = _currentFrame;
			showFrame(startFrame);
			
			_currentRepeatCount = 0;
			_repeatCount = repeatCount;
			_stopFrame = stopFrame;
			_callback = callback;
			_playing = true;
			
			if(_frameList != null) _timer.start();
		}
		
		
		public function stop():void
		{
			_timer.stop();
			_playing = false;
		}
		
		
		public function gotoAndPlay(value:uint, repeatCount:uint=0, stopFrame:uint=0, callback:Function=null):void
		{
			play(value, repeatCount, stopFrame, callback);
		}
		
		
		public function gotoAndStop(value:uint):void
		{
			stop();
			showFrame(value);
		}
		
		
		public function nextFrame():void
		{
			stop();
			showFrame(_reverse ? _currentFrame - 1 : _currentFrame + 1);
		}
		
		
		public function prevFrame():void
		{
			stop();
			showFrame(_reverse ? _currentFrame + 1 : _currentFrame - 1);
		}
		
		
		
		/**
		 * 显示指定帧的图像
		 * @param value
		 */
		private function showFrame(frame:int):void
		{
			if(_frameList == null || _frameList.length == 0) return;
			
			if(frame > _frameList.length) frame = _frameList.length;
			else if(frame < 1) frame = 1;
			
			_currentFrame = frame;
			var bmcData:BitmapMovieClipData = _frameList[_currentFrame - 1];
			_bitmap.bitmapData = bmcData;
			_bitmap.x = bmcData.offsetX;
			_bitmap.y = bmcData.offsetY;
			_bitmap.smoothing = _smoothing;
			
			if(_dispatchEnterFrame) dispatchEvent(new AnimationEvent(AnimationEvent.ENTER_FRAME));
		}
		
		
		
		
		/**
		 * 动画的源名称
		 */
		public function set sourceName(value:String):void
		{
			//动画的源名称没有改变
			if(value == _sourceName) return;
			
			//删除之前的回调
			var info:Object = getConfigInfo(_sourceName);
			if(info != null && info.callbacks) delete info.callbacks[this];
			
			//清空显示
			_bitmap.bitmapData = null;
			_frameList = null;
			
			//新的源名称有误
			_sourceName = value;
			if(_sourceName == "" || _sourceName == null) {
				Logger.addLog("[LFW] Animation.sourceName 不能为 null ！", Logger.LOG_TYPE_WARN);
				return;
			}
			
			info = getConfigInfo(_sourceName);
			if(info != null) {
				_frameList = _cache.getValue(_sourceName);
				fps = info.fps;
			}
			else {
				_frameList = EMPTY_FRAME_LIST;
				if(_fps == 0) this.fps = 60;
				Logger.addLog("[LFW] Animation.sourceName: " + _sourceName + " 是不存在的资源！", Logger.LOG_TYPE_WARN);
			}
			
			
			//动画数据不存在
			if(_frameList == null)
			{
				//创建一样帧数的，全部是空帧的动画
				_frameList = new Vector.<BitmapMovieClipData>();
				for(var i:int=0; i < info.totalFrames; i++) _frameList.push(EMPTY_FRAME);
				
				//加载该动画的数据包
				var lim:LoadItemModel = new LoadItemModel();
				lim.type = Constants.RES_TYPE_BINARY;
				lim.isSecretly = true;
				lim.parseUrl(getUrl(_sourceName));
				Common.loader.getResByUrl(lim.url, true);//可能已经加载过了
				Common.loader.add(lim);
				Common.loader.start();
				
				//等待加载完成的回调
				if(info.callbacks == null) info.callbacks = new Dictionary();
				info.callbacks[this] = render;
			}
			else {
				//立即显示当前帧
				showFrame(_currentFrame);
			}
		}
		public function get sourceName():String { return _sourceName; }
		
		
		/**
		 * 在加载完成后，显示当前帧
		 * @param sn 触发回调的sourceName
		 */
		private function render(sn:String):void
		{
			if(sn != _sourceName) return;
			_frameList = _cache.getValue(_sourceName);
			showFrame(_currentFrame);
		}
		
		
		
		public function asyncInitialize(sourceName:String):void
		{
			throw new Error("Animation 不需要实现该方法！");
		}
		
		
		
		
		/**
		 * 计时器回调（帧刷新）
		 */
		private function timerHandler():void
		{
			var frame:uint;
			if(_reverse) {
				frame = (_currentFrame == 1) ? _frameList.length : _currentFrame - 1;
			}
			else {
				frame = (_currentFrame == _frameList.length) ? 1 : _currentFrame + 1;
			}
			showFrame(frame);
			
			//只有一帧，或没有帧
			if(_frameList.length <= 1) {
				stop();
				dispatchEvent(new AnimationEvent(AnimationEvent.ENTER_STOP_FRAME));
				dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_END));
				return;
			}
			
			//有指定重复播放次数
			if(_repeatCount > 0) {
				//到达停止帧
				var stopFrame:uint = (_stopFrame == 0) ? _frameList.length : _stopFrame;
				if(_currentFrame == stopFrame)
				{
					dispatchEvent(new AnimationEvent(AnimationEvent.ENTER_STOP_FRAME));
					
					_currentRepeatCount++;
					//达到了重复播放次数
					if(_currentRepeatCount >= _repeatCount) {
						stop();
						
						var cb:Function = _callback;
						_callback = null;
						if(cb != null) cb();
						
						dispatchEvent(new AnimationEvent(AnimationEvent.ANIMATION_END));
					}
				}
			}
		}
		
		
		
		public function set fps(value:uint):void
		{
			if(value == _fps) return;
			_fps = value;
			_timer.delay = 1000 / _fps;
		}
		public function get fps():uint { return _fps; }
		
		
		public function set playing(value:Boolean):void
		{
			value ? play() : stop();
		}
		public function get playing():Boolean { return _playing; }
		
		
		public function set currentFrame(value:uint):void
		{
			gotoAndStop(value);
		}
		public function get currentFrame():uint { return _currentFrame; }
		
		
		public function get totalFrames():uint
		{
			if(_frameList == null) return 0;
			return _frameList.length;
		}
		
		
		public function set reverse(value:Boolean):void { _reverse = value; }
		public function get reverse():Boolean { return _reverse; }
		
		
		public function set repeatCount(value:uint):void { _repeatCount = value; }
		public function get repeatCount():uint { return _repeatCount; }
		
		
		public function get currentRepeatCount():uint { return _currentRepeatCount; }
		
		
		public function set stopFrame(value:uint):void { _stopFrame = value; }
		public function get stopFrame():uint { return _stopFrame; }
		
		
		public function set callback(value:Function):void { _callback = value; }
		public function get callback():Function { return _callback; }
		
		
		public function set dispatchEnterFrame(value:Boolean):void { _dispatchEnterFrame = value; }
		public function get dispatchEnterFrame():Boolean { return _dispatchEnterFrame; }
		
		
		
		
		/**
		 * 位图图像（当前帧内容）
		 */
		public function get bitmap():Bitmap { return _bitmap; }
		
		
		/**
		 * 是否对位图进行平滑处理。默认：false<br/>
		 * <font color="red">注意：启用平滑处理将会降低渲染效率</font>
		 */
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
			_bitmap.smoothing = value;
		}
		public function get smoothing():Boolean { return _smoothing; }
		
		
		
		public function dispose():void
		{
			stop();
			if(parent != null) parent.removeChild(this);
		}
		
		
		
		/**
		 * <font color="#FF0000">注意：该属性仅供测试，请勿在实际项目中使用</font>
		 */
		public function set frameList(value:Vector.<BitmapMovieClipData>):void { _frameList = value; }
		public function get frameList():Vector.<BitmapMovieClipData> { return _frameList; }
		
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