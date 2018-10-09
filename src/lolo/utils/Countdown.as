package lolo.utils
{
	/**
	 * 倒计时工具（<i>类中涉及到的时间单位均为<b>毫秒</b></i>）
	 * @author LOLO
	 */
	public class Countdown
	{
		/**倒计时总时间*/
		private var _totalTime:Number;
		/**间隔时间*/
		private var _intervalTime:Number;
		/**倒计时开始时间（设置totalTime的那一刻）*/
		private var _startTime:Number;
		/**定时器运行时的回调函数，回调时会传递一个Boolean类型的参数，表示倒计时是否已经结束*/
		private var _callback:Function;
		/**倒计时工具是否正在运行中*/
		private var _running:Boolean;
		/**用于倒计时*/
		private var _timer:FrameTimer;
		
		
		
		public function Countdown(callback:Function=null, totalTime:Number=0, intervalTime:Number=1000)
		{
			_callback = callback;
			_intervalTime = intervalTime;
			this.totalTime = totalTime;
		}
		
		
		
		/**
		 * 开始运行倒计时工具
		 * @param totalTime 倒计时总时间，0表示未变动
		 */
		public function start(totalTime:Number=0):void
		{
			if(totalTime != 0) this.totalTime = totalTime;
			
			if(_intervalTime <= 0) {
				throw new Error("intervalTime 的值不能为：" + _intervalTime);
				return;
			}
			
			_running = true;
			if(_timer == null) _timer = new FrameTimer(_intervalTime, timerHandler);
			_timer.delay = _intervalTime;
			_timer.start();
			timerHandler();
		}
		
		/**
		 * 计时器回调
		 */
		private function timerHandler():void
		{
			var t:Number = TimeUtil.getTime() - _startTime;
			t = _totalTime - t;
			var end:Boolean = t <= 0;
			if(end) {
				_running = false;
				_timer.reset();
			}
			if(_callback != null) _callback(end);
		}
		
		
		/**
		 * 停止运行倒计时工具
		 */
		public function stop():void
		{
			_running = false;
			if(_timer != null) _timer.stop();
		}
		
		
		
		/**
		 * 倒计时总时间
		 */
		public function set totalTime(value:Number):void
		{
			_totalTime = value;
			_startTime = TimeUtil.getTime();
		}
		public function get totalTime():Number { return _totalTime; }
		
		
		
		/**
		 * 间隔时间
		 */
		public function set intervalTime(value:Number):void
		{
			if(value == _intervalTime) return;
			_intervalTime = value;
			if(_running) start();
		}
		public function get intervalTime():Number { return _intervalTime; }
		
		
		/**
		 * 定时器运行时的回调函数。<br/>
		 * 回调时会传递一个Boolean类型的参数，表示倒计时是否已经结束
		 */
		public function set callback(value:Function):void
		{
			_callback = value;
		}
		public function get callback():Function { return _callback; }
		
		
		
		/**
		 * 倒计时工具是否正在运行中
		 */
		public function get running():Boolean
		{
			return _running;
		}
		
		
		/**
		 * 倒计时开始时间（设置totalTime的那一刻）
		 */
		public function get startTime():Number
		{
			return _startTime;
		}
		
		
		
		/**
		 * 剩余时间（从设置totalTime的那一刻开始计算）
		 */
		public function get time():Number
		{
			if(_totalTime <= 0 || isNaN(_startTime)) return 0;
			var t:Number = TimeUtil.getTime() - _startTime;
			t = _totalTime - t;
			if(t < 0) t = 0;
			return t;
		}
		
		/**
		 * 剩余次数
		 */
		public function get count():uint
		{
			if(_intervalTime > _totalTime) return 0; 
			if(_intervalTime < 0 || _intervalTime < 0) return 0;
			if(_totalTime <= 0 || isNaN(_startTime)) return 0;
			
			var t:Number = TimeUtil.getTime() - _startTime;
			t = _totalTime - t;
			return Math.ceil(t / _intervalTime);
		}
		//
	}
}