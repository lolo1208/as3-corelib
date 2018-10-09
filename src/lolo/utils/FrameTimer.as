package lolo.utils
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.utils.logging.Logger;
	
	
	/**
	 * 基于帧频的定时器<br/>
	 * 解决丢帧和加速的情况
	 * @author LOLO
	 */
	public class FrameTimer
	{
		/**可移除标记的最大次数*/
		private static const MAX_REMOVE_MARK:uint = 5;
		/**定时器列表（以delay为key， _list[delay] = { list:已启动的定时器列表, removeMark:被标记了可以移除的次数 } ）*/
		private static var _list:Dictionary = new Dictionary();
		/**不重复的key*/
		private static var _onlyKey:uint = 0;
		
		/**需要被添加到运行列表的定时器列表*/
		private static var _startingList:Array = [];
		/**需要从运行列表中移除的定时器列表*/
		private static var _stoppingList:Array = [];
		
		
		/**在列表中的key（ _list[delay].list[_key] = this ）*/
		private var _key:uint;
		/**定时器间隔*/
		private var _delay:uint = 0;
		/**定时器是否正在运行中*/
		private var _running:Boolean;
		
		/**定时器当前已运行次数*/
		public var currentCount:uint;
		/**定时器的总运行次数，默认值0，表示无限运行*/
		public var repeatCount:uint;
		
		/**定时器上次触发的时间*/
		public var lastUpdateTime:Number;
		/**每次达到间隔时的回调*/
		public var timerHander:Function;
		/**定时器达到总运行次数时的回调*/
		public var timerCompleteHandler:Function;
		
		
		
		
		
		
		/**
		 * 帧刷新
		 * @param event
		 */
		private static function enterFrameHandler(event:Event):void
		{
			var timer:FrameTimer, i:int, delay:*, key:*, timerList:Dictionary, errMsg:String;
			var timerRunning:Boolean, ignorable:Boolean;
			var delayChangedList:Array;//在回调中，delay有改变的定时器列表
			
			//添加应该启动的定时器，以及移除该停止的定时器。
			//	上一帧将这些操作延迟到现在来处理的目的，是为了防止循环和回调时造成的问题
			while(_startingList.length > 0)
			{
				timer = _startingList.pop();
				if(_list[timer.delay] == null) _list[timer.delay] = { list:new Dictionary(), removeMark:0 };
				_list[timer.delay].markCount = 0;
				_list[timer.delay].list[timer.key] = timer;
			}
			
			while(_stoppingList.length > 0)
			{
				timer = _stoppingList.pop();
				if(_list[timer.delay] != null) delete _list[timer.delay].list[timer.key];
			}
			
			//处理回调
			var time:Number = TimeUtil.getTime();
			var removedList:Array = [];//需要被移除的定时器列表
			for(delay in _list)
			{
				delayChangedList = [];
				timerList = _list[delay].list;
				timerRunning = false;
				for(key in timerList)
				{
					timer = timerList[key];
					if(!timer.running) continue;//这个定时器已经被停止了（可能是被之前处理的定时器回调停止的）
					
					//在FP失去焦点后，帧频会降低。使用加速工具，帧频会加快。计算次数可以解决丢帧以及加速问题
					var count:int = (time - timer.lastUpdateTime) / timer.delay;
					//次数过多，忽略掉（可能是系统休眠后恢复）
					if(count > 1000) {
						ignorable = true;
						count = 1;
					}
					else ignorable = false;
					
					for(i = 0; i < count; i++)
					{
						//定时器在回调中被停止了
						if(!timer.running) break;
						
						//定时器在回调中更改了delay
						if(timer.delay != delay) {
							delayChangedList.push(key);
							break;
						}
						
						timer.currentCount++;
						if(timer.timerHander != null) {
							if(Common.isDebug) {
								timer.timerHander();
							}
							else {
								try {
									timer.timerHander();//加 try 是为了不影响后续定时器的执行
								}
								catch(error:Error) {
									Logger.addErrorLog(null, error);
								}
							}
						}
						
						//定时器已到达允许运行的最大次数
						if(timer.repeatCount != 0 && timer.currentCount >= timer.repeatCount) {
							timer.stop();
							if(timer.timerCompleteHandler != null) {
								if(Common.isDebug) {
									timer.timerCompleteHandler();
								}
								else {
									try {
										timer.timerCompleteHandler();//加 try 是为了不影响后续定时器的执行
									}
									catch(error:Error) {
										Logger.addErrorLog(null, error);
									}
								}
							}
							break;
						}
					}
					
					//根据回调次数，更新 上次触发的时间（在回调中没有更改delay）
					if(count > 0 && timer.delay == delay) {
						timer.lastUpdateTime = ignorable ? time : (timer.lastUpdateTime + timer.delay * count);
					}
					
					if(timer.running) timerRunning = true;
				}
				
				while(delayChangedList.length > 0)
				{
					delete timerList[delayChangedList.pop()];
				}
				
				//当前 delay，已经没有定时器在运行状态了
				if(!timerRunning)
				{
					if(_list[delay].removeMark > MAX_REMOVE_MARK) {
						removedList.push(delay);
					}
					else {
						_list[delay].removeMark++;
					}
				}
				else {
					_list[delay].removeMark = 0;
				}
			}
			
			while(removedList.length > 0)
			{
				delay = removedList.pop();
				if(_list[delay].removeMark > MAX_REMOVE_MARK) delete _list[delay];
			}
			
			if(_startingList.length == 0)
			{
				for(delay in _list) return;
				Common.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		
		
		/**
		 * 从 添加 或 移除 列表中移除指定的定时器
		 * @param list
		 * @param timer
		 */
		private static function removeTimer(list:Array, timer:FrameTimer):void
		{
			for(var i:int = 0; i < list.length; i++)
			{
				if(list[i] == timer) {
					list.splice(i, 1);
					return;
				}
			}
		}
		
		
		
		/**
		 * 创建一个FrameTimer实例
		 * @param delay 定时器间隔
		 * @param timerHander 每次达到间隔时的回调
		 * @param repeatCount 定时器的总运行次数，默认值0，表示无限运行
		 * @param timerCompleteHandler 定时器达到总运行次数时的回调
		 * @return 
		 */
		public function FrameTimer(delay:uint = 1000,
								   timerHander:Function=null,
								   repeatCount:uint=0,
								   timerCompleteHandler:Function=null)
		{
			_key = ++_onlyKey;
			this.delay = delay;
			
			this.repeatCount = repeatCount;
			this.timerHander = timerHander;
			this.timerCompleteHandler = timerCompleteHandler;
		}
		
		
		/**
		 * 定时器间隔
		 */
		public function set delay(value:uint):void
		{
			if(value == 0) {
				stop();
				throw new Error("定时器的间隔不能为 0");
				return;
			}
			if(_delay == value) return;
			
			var running:Boolean = _running;
			if(_delay != 0) reset();//之前被设置或启动过，重置定时器
			
			//创建当前间隔的定时器
			_delay = value;
			
			if(running) start();
		}
		public function get delay():uint { return _delay; }
		
		
		/**
		 * 开始定时器
		 */
		public function start():void
		{
			if(_running) return;
			
			//没达到设置的运行最大次数
			if(repeatCount == 0 || currentCount < repeatCount)
			{
				_running = true;
				lastUpdateTime = TimeUtil.getTime();
				
				removeTimer(_stoppingList, this);
				removeTimer(_startingList, this);
				_startingList.push(this);
				
				Common.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler, false, 9999);
			}
		}
		
		
		/**
		 * 如果定时器正在运行，则停止定时器
		 */
		public function stop():void
		{
			if(!_running) return;
			_running = false;
			
			removeTimer(_startingList, this);
			removeTimer(_stoppingList, this);
			_stoppingList.push(this);
		}
		
		
		/**
		 * 如果定时器正在运行，则停止定时器，并将currentCount设为0
		 */
		public function reset():void
		{
			currentCount = 0;
			stop();
		}
		
		
		
		/**定时器是否正在运行中*/
		public function get running():Boolean { return _running; }
		
		
		/**
		 * 在列表中的key（_list[delay].list[key]=this）
		 */
		public function get key():uint { return _key; }
		
		
		
		/**
		 * 释放对象（只是停止定时器，还能继续使用）<br/>
		 * <font color="#FF0000">注意：在丢弃该对象时</font>，并不强制您调用该方法，您<font color="#FF0000">只需停止定时器（调用stop()方法）</font>即可
		 */
		public function dispose():void
		{
			stop();
		}
		//
	}
}