package lolo.utils.logging
{
	import flash.system.System;
	
	import lolo.core.Common;
	import lolo.data.LoadItemModel;
	import lolo.data.SO;
	import lolo.utils.ExternalUtil;
	import lolo.utils.FrameTimer;
	import lolo.utils.optimize.FpsSampler;

	/**
	 * 日志采样收集器
	 * @author LOLO
	 */
	public class LogSampler
	{
		/**单例的实例*/
		private static var _instance:LogSampler;
		
		/**最近一次网络通信的耗时*/
		public static var rtt:uint = 0;
		/**最近一次网络通信的接口名称*/
		public static var command:String = "";
		
		
		/**是否启用采样器*/
		private var _enabled:Boolean;
		/**用于启动采样器*/
		private var _startupTimer:FrameTimer;
		/**采样器在该定时器回调时进行采样*/
		private var _sampleTimer:FrameTimer;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():LogSampler
		{
			if(_instance == null) _instance = new LogSampler(new Enforcer());
			return _instance;
		}
		
		
		public function LogSampler(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过 LogSampler.getInstance() 获取实例");
				return;
			}
			
			_startupTimer = new FrameTimer(1000, startupTimerHandler);
			_sampleTimer = new FrameTimer(1000 * 12, sampleTimerHandler);
		}
		
		
		/**
		 * 是否启用采样器
		 */
		public static function set enabled(value:Boolean):void { getInstance().enabled = value; }
		public static function get enabled():Boolean { return getInstance().enabled; }
		
		/**
		 * 采样器是否正在采样中
		 */
		public static function get sampleing():Boolean { return getInstance().sampleing; }
		
		
		
		/**
		 * 是否启用采样器
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			
			if(_enabled) {
				startup();
			}
			else {
				_startupTimer.reset();
				_sampleTimer.reset();
			}
		}
		public function get enabled():Boolean { return _enabled; }
		
		/**
		 * 采样器是否正在采样中
		 */
		public function get sampleing():Boolean { return _sampleTimer.running; }
		
		
		
		
		
		/**
		 * 设定间隔准备启动采样（0-60分钟后启动）
		 */
		private function startup():void
		{
			var delay:uint = Math.random() * 60 * 1000 * 60;
			_startupTimer.delay = (delay == 0) ? 1 : delay;
			_startupTimer.start();
		}
		
		
		/**
		 * 启动采样器
		 */
		private function startupTimerHandler():void
		{
			_startupTimer.reset();
			_sampleTimer.start();
			FpsSampler.start("sampler");
		}
		
		
		/**
		 * 进行采样
		 */
		private function sampleTimerHandler():void
		{
			_sampleTimer.reset();
			FpsSampler.stop("sampler");
			
			//记录log
			var average:Number = 0;
			var len:uint = FpsSampler.FPS.length;
			for(var i:int = 0; i < len; i++) average += FpsSampler.FPS[i];
			average = Math.round(average / len);
			if(average > 2)//浏览器最小化时，帧频会<=2
				Logger.addSampleLog("fpsAndMemorySampler", average, FpsSampler.maxFPS, Common.stage.frameRate, System.totalMemory);
			
			//继续准备采样
			startup();
		}
		
		
		
		
		
		
		/**
		 * 添加一条网络通信的采样日志
		 * @param time 网络通信耗时
		 * @param type 服务器类型
		 * @param command 命令
		 * @param token 代号
		 */
		public static function addNetworkSampleLog(time:Number, type:String, command:String, token:uint):void
		{
			LogSampler.rtt = time;
			LogSampler.command = command;
			if(command != "system@heartbeat") return;//只采集心跳包信息
			
			Logger.addSampleLog("networkSampler", time, type, command, token);
		}
		
		
		/**
		 * 添加一条加载文件的采样日志
		 * @param lim 加载项数据模型
		 */
		public static function addLoadFileSampleLog(lim:LoadItemModel):void
		{
			if(lim.bytesTotal / 1024 < 500) return;//不统计小于500KB的文件
			if(lim.loadTime < 100) return;//可能是浏览器缓存的文件
			if(lim.loadTime > 300000) return;//加载耗时太长
			
			Logger.addSampleLog("loadFileSampler", lim.loadTime, lim.bytesTotal, lim.isSecretly, Common.getResUrl(lim.url));
		}
		
		
		/**
		 * 添加一条文件加载错误日志
		 * @param lim 加载项数据模型
		 * @param errorType 错误类型 [ notFound, timeout ]
		 */
		public static function addLoadErrorLog(lim:LoadItemModel, errorType:String):void
		{
			var url:String = Common.getResUrl(lim.url);
			Logger.addSampleLog("loadFileErrorSampler", errorType, lim.status, lim.isSecretly, ExternalUtil.getCdnNodeInfo(url), url);
		}
		
		
		/**
		 * 添加一条系统信息采样日志
		 */
		public static function addSystemInfoSampleLog():void
		{
			var log:String = Common.stage.stageWidth + "#" + Common.stage.stageHeight;
			if(log != SO.data.systemInfoSampleLog) {
				Logger.addSampleLog("systemInfoSampler", log);
				SO.data.systemInfoSampleLog = log;
				SO.save();
			}
		}
		//
	}
}


class Enforcer {}