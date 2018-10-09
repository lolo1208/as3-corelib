package lolo.utils.optimize
{
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import lolo.core.Common;

	/**
	 * CPU消耗均衡工具。</br>
	 * 实现的原理就是将瞬间消耗CPU过高的处理，分摊到每帧。</br>
	 * 避免出现画面卡住、假死的情况
	 * @author LOLO
	 */
	public class ConsumeBalancer
	{
		/**每帧最多消耗的时间*/
		private static const MAX_FRAME_TIME:uint = 15;
		
		/**待处理的回调函数，以及参数列表*/
		private static var _callbacks:Array = [];
		
		
		
		
		/**
		 * 添加一个回调函数，程序将会在消耗未达到峰值的时候调用它
		 * @param callback
		 * @param args
		 */
		public static function addCallback(callback:Function, ...args):void
		{
			_callbacks.push({ callback:callback, args:args });
			Common.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		/**
		 * 移除一个回调函数（匹配函数和参数）
		 * @param callback
		 * @param args
		 */
		public static function removeCallback(callback:Function, ...args):void
		{
			var differ:Boolean;//是否不匹配
			var i:int, n:int;
			for(i = 0; i < _callbacks.length; i++)
			{
				if(_callbacks[i].callback == callback && _callbacks[i].args.length == args.length)
				{
					differ = false;
					
					for(n = 0; n < args.length; n++)
					{
						if(_callbacks[i].args[n] != args[n]) {
							differ = true;
							break;
						}
					}
					
					if(!differ) {
						_callbacks.splice(i, 1);
						return;
					}
				}
			}
		}
		
		
		/**
		 * 每帧只处理适量的回调，将压力分摊到各帧
		 * @param event
		 */
		private static function enterFrameHandler(event:Event):void
		{
			var startTime:Number = getTimer();
			
			while(_callbacks.length > 0)
			{
				var info:Object = _callbacks.shift();
				info.callback.apply(null, info.args);
				if(getTimer() - startTime >= MAX_FRAME_TIME) break;
			}
			
			if(_callbacks.length == 0) Common.stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		//
	}
}