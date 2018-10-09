package lolo.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	
	import lolo.core.MovieClipLoader;
	import lolo.data.LRUCache;
	import lolo.events.AnimationEvent;
	import lolo.utils.AutoUtil;
	import lolo.utils.FrameTimer;
	import lolo.utils.optimize.ConsumeBalancer;
	
	/**
	 * 位图影片剪辑
	 * @author LOLO
	 */
	public class BitmapMovieClip extends Sprite implements IAnimation
	{
		/**LRU缓存*/
		private static var _cache:LRUCache;
		
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
		
		/**动画的源名称（类的完整定义）*/
		private var _sourceName:String = "";
		
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
			
			_cache = new LRUCache();
			_cache.disposeCallback = disposeCallback;
			_cache.maxMemorySize = 200 * 1024 * 1024;
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
		 * 构造一个位图影片剪辑
		 * @param sourceName 动画的源名称（类的完整定义）
		 * @param fps 动画的帧频
		 * @param bitmapData
		 * @param pixelSnapping
		 * @param smoothing
		 */
		public function BitmapMovieClip(sourceName:String="", fps:uint=12, bitmapData:BitmapData=null, pixelSnapping:String="auto", smoothing:Boolean=false)
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			
			_bitmap = new Bitmap(bitmapData, pixelSnapping, smoothing);
			this.addChild(_bitmap);
			
			_timer = new FrameTimer(1000, timerHandler);
			
			this.fps = fps;
			this.sourceName = sourceName;
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
			if(_timer != null) _timer.stop();
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
			
			if(_dispatchEnterFrame) dispatchEvent(new AnimationEvent(AnimationEvent.ENTER_FRAME));
		}
		
		
		
		
		/**
		 * 动画的源名称（类的完整定义）
		 */
		public function set sourceName(value:String):void
		{
			//动画的源名称没有改变
			if(value == _sourceName) return;
			
			//停止动画，并记录动画播放状态
			var playing:Boolean = _playing;
			stop();
			_playing = playing;
			_bitmap.bitmapData = null;
			
			//新的源名称有误
			_sourceName = value;
			if(_sourceName == "" || _sourceName == null) return;
			
			
			_frameList = _cache.getValue(_sourceName);
			
			//新动画数据不存在，创建新动画
			if(_frameList == null)
			{
				//新动画不存在
				if(!ApplicationDomain.currentDomain.hasDefinition(_sourceName)) {
					MovieClipLoader.asyncLoad(_sourceName, 2, this);
					return;
				}
				
				//提取新动画的数据
				var mc:MovieClip = AutoUtil.getInstance(_sourceName);
				var i:int;
				var memory:Number = 0;
				var rect:Rectangle;
				var bmcData:BitmapMovieClipData;
				_frameList = new Vector.<BitmapMovieClipData>();
				for(i = 1; i <= mc.totalFrames; i++) {
					mc.gotoAndStop(i);
					rect = mc.getBounds(mc);
					if(rect.width < 1) rect.width = 1;//有可能是空帧
					if(rect.height < 1) rect.height = 1;
					
					bmcData = new BitmapMovieClipData(rect.width, rect.height, rect.x, rect.y);
					_frameList.push(bmcData);
					memory += rect.width * rect.height * 4;
					
					ConsumeBalancer.addCallback(drawFrame, _sourceName, i-1, mc);
				}
				
				//LRU缓存
				_cache.add(_sourceName, _frameList, memory);
			}
			
			//立即显示当前帧，如果动画是在播放中，继续播放
			_playing ? play(_currentFrame) : showFrame(_currentFrame);
		}
		public function get sourceName():String { return _sourceName; }
		
		
		public function asyncInitialize(sourceName:String):void
		{
			//在异步加载这段时间内，动画的源名称已经改变了
			if(sourceName != _sourceName) return;
			
			//显示动画
			_sourceName = null;
			this.sourceName = sourceName;
		}
		
		
		public static function drawFrame(name:String, index:uint, mc:MovieClip):void
		{
			var frameList:Vector.<BitmapMovieClipData> = _cache.getValue(name);
			mc.gotoAndStop(index + 1);
			frameList[index].draw(mc, new Matrix(1, 0, 0, 1, -frameList[index].offsetX, -frameList[index].offsetY));
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
		//
	}
}