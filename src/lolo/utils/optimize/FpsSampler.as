package lolo.utils.optimize
{
	import flash.events.Event;
	
	import lolo.core.Common;
	import lolo.utils.TimeUtil;

	/**
	 * 帧频采样统计器（一秒统计一次）
	 * @author LOLO
	 */
	public class FpsSampler
	{
		/**最近统计的fps列表（最多10次）*/
		public static const FPS:Vector.<uint> = new Vector.<uint>();
		
		/**间隔多少帧计算一次*/
		private static var _durationFrame:uint;
		/**上次开始记录的时间*/
		private static var _time:Number;
		/**上次开始记录到现在，已运行的帧数*/
		private static var _count:int;
		
		/**帧频采样统计器是否正在运行中*/
		private static var _running:Boolean;
		/**最近一次统计的帧频*/
		private static var _fps:uint;
		/**采样过程中，达到过的最高帧频*/
		private static var _maxFPS:uint;
		/**启动统计器的key列表，必须所有key的终止了，才会真正停止统计器*/
		private static var _startKeys:Array = [];
		
		
		
		/**
		 * 开始统计帧频
		 * @param key
		 */
		public static function start(key:String="public"):void
		{
			if(_startKeys.indexOf(key) == -1) _startKeys.push(key);
			if(_running) return;
			_running = true;
			
			_fps = _durationFrame = Common.stage.frameRate;
			_count = 0;
			_time = TimeUtil.getTime();
			Common.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * 帧刷新
		 * @param event
		 */
		private static function enterFrameHandler(event:Event):void
		{
			_count++;
			if(_count < _durationFrame) return;
			
			var time:Number = TimeUtil.getTime();
			_fps = Math.round(1000 / ((time - _time) / _count));
			_maxFPS = Math.max(_fps, _maxFPS);
			
			_time = time;
			_count = 0;
			
			FPS.push(_fps);
			if(FPS.length > 9) FPS.shift();
		}
		
		
		
		/**
		 * 停止统计帧频
		 * @param key
		 */
		public static function stop(key:String="public"):void
		{
			if(!_running) return;
			
			for(var i:int=0; i < _startKeys.length; i++) {
				if(_startKeys[i] == key) {
					_startKeys.splice(i, 1);
					break;
				}
			}
			if(_startKeys.length > 0) return;
			
			_running = false;
			Common.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		
		
		/**
		 * 最近一次统计的fps。如果从未统计过，将返回stage.frameRate
		 */
		public static function get fps():uint { return _fps; }
		
		
		/**
		 * 采样过程中，达到过的最高帧频
		 */
		public static function get maxFPS():uint { return _maxFPS; }
		
		
		/**
		 * 帧频采样统计器是否正在运行中
		 */
		public static function get running():Boolean { return _running; }
		//
	}
}