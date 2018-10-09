package lolo.display
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import lolo.core.Common;
	import lolo.core.MovieClipLoader;
	import lolo.events.AnimationEvent;
	import lolo.utils.AutoUtil;
	import lolo.utils.FrameTimer;
	import lolo.utils.TimeUtil;
	
	/**
	 * 可控制（fps,reverse等）的影片剪辑（flash.display.MovieClip）<br/>
	 * 影片剪辑会自动加入缓存池，以及从池中移除
	 * @author LOLO
	 */
	public class ControlledMovieClip extends Sprite implements IAnimation
	{
		/**缓存池*/
		private static var _cachePool:Dictionary = new Dictionary();
		/**已缓存对象的失效时间，单位：毫秒*/
		private static var _deadline:uint = 5 * 60 * 1000;
		/**用于清除缓存池*/
		private static var _clearTimer:FrameTimer;
		
		/**影片剪辑*/
		private var _mc:MovieClip;
		/**动画的帧频*/
		private var _fps:uint;
		/**动画是否正在播放中*/
		private var _playing:Boolean;
		/**当前帧编号*/
		private var _currentFrame:uint;
		/**是否反向播放动画*/
		private var _reverse:Boolean;
		
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
		
		/**动画的源名称（类的完整定义）*/
		private var _sourceName:String = null;
		/**总帧数*/
		private var _totalFrames:uint;
		
		/**用于播放动画*/
		private var _timer:FrameTimer;
		
		
		
		
		/**
		 * 清除缓存池里超过失效时间的mc。<br/>
		 * 如果mc是被加载到了新的程序域中，将会清除该程序域
		 */
		private static function clearTimerHandler():void
		{
			var sn:String;
			var caches:Dictionary = new Dictionary();
			for(sn in _cachePool) caches[sn] = _cachePool[sn];
			
			var time:Number = TimeUtil.getTime();
			for(sn in caches) {
				if(time - _cachePool[sn].time > _deadline)
				{
					delete _cachePool[sn];
					
					var url:String = MovieClipLoader.getURL(sn, 3);
					if(url != null) Common.loader.getResByUrl(url, true);
				}
			}
		}
		
		/**
		 * 将mc添加到缓存池
		 * @param mc
		 */
		private static function addMcToCachePool(mc:MovieClip):void
		{
			if(mc == null) return;
			
			mc.stop();
			if(mc.parent != null) mc.parent.removeChild(mc);
			
			var sn:String = getSourceName(mc);
			if(_cachePool[sn] == null) {
				//{ time:上次更新时间, list:缓存的实例列表 }
				_cachePool[sn] = { time:0, list:new Vector.<MovieClip>() };
			}
			_cachePool[sn].time = TimeUtil.getTime();
			_cachePool[sn].list.push(mc);
			
			if(_clearTimer == null) {
				_clearTimer = new FrameTimer(1000 * 60 * 2, clearTimerHandler);
				_clearTimer.start();
			}
		}
		
		/**
		 * 冲缓存池拿出一个mc。如果池里没有，将返回null
		 * @param sn sourceName
		 * @return 
		 */
		private static function getMcFromCachePool(sn:String):MovieClip
		{
			if(_cachePool[sn] == null) return null;
			
			_cachePool[sn].time = TimeUtil.getTime();
			if(_cachePool[sn].list.length == 0) return null;
			
			return _cachePool[sn].list.pop();
		}
		
		/**
		 * 获取一个影片剪辑的完整限定类名
		 * @param mc
		 */
		private static function getSourceName(mc:MovieClip):String
		{
			return (mc == null) ? null : getQualifiedClassName(mc).replace("::", ".");
		}
		
		
		
		
		
		/**
		 * 构造一个可控制（fps,reverse等）的影片剪辑
		 * @param sourceName
		 * @param mc
		 * @param fps
		 */
		public function ControlledMovieClip(sourceName:String=null, mc:MovieClip=null, fps:uint=12)
		{
			super();
			_timer = new FrameTimer(1000, timerHandler);
			if(sourceName != null) this.sourceName = sourceName;
			if(mc != null) this.mc = mc;
			this.fps = fps;
		}
		
		
		/**
		 * 影片剪辑
		 */
		public function set mc(value:MovieClip):void
		{
			if(value == _mc) return;
			
			var sn:String = getSourceName(value);
			if(sn == _sourceName) return;
			
			changeMC(value, sn);
		}
		public function get mc():MovieClip { return _mc; }
		
		
		/**
		 * 动画的源名称（类的完整定义）
		 */
		public function set sourceName(value:String):void
		{
			if(value == _sourceName) return;
			
			//先尝试去池里拿实例
			var mc:MovieClip = getMcFromCachePool(value);
			
			//然后尝试在当前程序域中创建新对象
			if(mc == null && ApplicationDomain.currentDomain.hasDefinition(value)) {
				mc = AutoUtil.getInstance(value);
			}
			
			//可能已经加载到新的程序域中了
			if(mc == null) {
				var url:String = MovieClipLoader.getURL(value, 3);
				if(url != null) {
					var appDomain:ApplicationDomain = Common.loader.getResByUrl(url);
					if(appDomain != null) mc = AutoUtil.getInstance(value, appDomain);
				}
			}
			
			//没有这个sourceName，再尝试异步加载
			if(mc == null) MovieClipLoader.asyncLoad(value, 3, this);
			
			changeMC(mc, value);
		}
		public function get sourceName():String { return _sourceName; }
		
		
		private function changeMC(mc:MovieClip, sn:String):void
		{
			//将之前使用的mc放入池中
			addMcToCachePool(_mc);
			
			//使用新的mc
			_mc = mc;
			_sourceName = sn;
			if(_mc != null) {
				this.addChild(_mc);
				_totalFrames = _mc.totalFrames;
				showFrame(_currentFrame);
			}
		}
		
		
		public function asyncInitialize(sourceName:String):void
		{
			//在异步加载这段时间内，动画的源名称已经改变了
			if(sourceName != _sourceName) return;
			
			//显示动画
			_sourceName = null;
			this.sourceName = sourceName;
		}
		
		
		
		/**
		 * 计时器回调（帧刷新）
		 */
		private function timerHandler():void
		{
			//没有动画
			if(_mc == null) return;
			
			var frame:uint;
			if(_reverse) {
				frame = (_currentFrame == 1) ? _totalFrames : _currentFrame - 1;
			}
			else {
				frame = (_currentFrame == _totalFrames) ? 1 : _currentFrame + 1;
			}
			showFrame(frame);
			
			//只有一帧
			if(_totalFrames == 1) {
				stop();
				return;
			}
			
			//有指定重复播放次数
			if(_repeatCount > 0) {
				//到达停止帧
				var stopFrame:uint = (_stopFrame == 0) ? _totalFrames : _stopFrame;
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
		
		
		/**
		 * 显示指定帧的图像
		 * @param value
		 */
		private function showFrame(frame:int):void
		{
			if(frame > _totalFrames) frame = _totalFrames;
			else if(frame < 1) frame = 1;
			_currentFrame = frame;
			
			if(_mc != null) _mc.gotoAndStop(_currentFrame);
			
			if(_dispatchEnterFrame) dispatchEvent(new AnimationEvent(AnimationEvent.ENTER_FRAME));
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
			
			_timer.start();
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
		
		
		/**
		 * 总帧数
		 */
		public function set totalFrames(value:uint):void
		{
			_totalFrames = value;
		}
		public function get totalFrames():uint { return _totalFrames; }
		
		
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
			addMcToCachePool(_mc);
			_mc = null;
			_sourceName = null;
			if(parent != null) parent.removeChild(this);
		}
		//
	}
}