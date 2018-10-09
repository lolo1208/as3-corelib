package lolo.effects.float
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObject;

	/**
	 * <b>向下浮动效果</b></br>
	 * - step1: 从 alpha=0 到 alpha=1 ，并向上浮动目标</br>
	 * - step2: 向下浮动目标</br>
	 * - step3: 停留指定时间后，再向下浮动目标，并将 alpha 设置为0</br>
	 * - step4: 浮动结束后，将目标从父容器中移除，并将 alpha 设置为1
	 * @author LOLO
	 */
	public class DownFloat implements IFloat
	{
		/**应用该效果的目标*/
		private var _target:DisplayObject;
		/**浮动结束后的回调函数*/
		private var _onComplete:Function;
		/**是否正在浮动中*/
		private var _floating:Boolean;
		
		
		/**step1 的持续时长（秒）*/
		public var step1_duration:Number = 0.1;
		/**step1 的移动距离（Y）*/
		public var step1_y:int = 10;
		
		/**step2 的持续时长（秒）*/
		public var step2_duration:Number = 0.05;
		/**step2 的移动距离（Y）*/
		public var step2_y:int = 5;
		
		/**step3 的持续时长（秒）*/
		public var step3_duration:Number = 0.65;
		/**step3 的停留时长（秒）*/
		public var step3_delay:Number = 0.3;
		/**step3 的移动距离（Y）*/
		public var step3_y:int = 35;
		
		
		
		
		/**
		 * 构造函数
		 * @param target 应用该效果的目标
		 * @param onComplete 浮动结束后的回调函数。onComplete(complete:Boolean, float:IFloat)
		 */
		public function DownFloat(target:DisplayObject=null, onComplete:Function=null)
		{
			this.target = target;
			this.onComplete = onComplete;
			
			if(target != null) start();
		}
		
		
		
		
		private function step1():void
		{
			_target.alpha = 0;
			TweenMax.to(_target, step1_duration, {
				y:_target.y + step1_y, alpha:1,
				ease:Linear.easeNone, onComplete:step2
			});
		}
		
		private function step2():void
		{
			TweenMax.to(_target, step2_duration, {
				y:_target.y + step2_y,
				ease:Linear.easeNone, onComplete:step3
			});
		}
		
		private function step3():void
		{
			TweenMax.to(_target, step3_duration, {
				y:_target.y + step3_y, alpha:0, delay:step3_delay,
				ease:Linear.easeNone, onComplete:step4
			});
		}
		
		private function step4():void
		{
			_target.alpha = 1;
			if(_target.parent != null) _target.parent.removeChild(_target);
			end(true);
		}
		
		
		
		
		
		public function start():void
		{
			TweenMax.killTweensOf(_target);
			_floating = true;
			step1();
		}
		
		
		public function end(complete:Boolean=false):void
		{
			_floating = false;
			TweenMax.killTweensOf(_target);
			
			if(_onComplete != null) {
				_onComplete(complete, this);
				_onComplete = null;
			}
		}
		
		
		public function set target(value:DisplayObject):void
		{
			_target = value;
			if(_floating) end(false);
		}
		public function get target():DisplayObject { return _target; }
		
		
		public function set onComplete(value:Function):void
		{
			_onComplete = value;
		}
		public function get onComplete():Function { return _onComplete; }
		
		
		public function get floating():Boolean { return _floating; }
		//
	}
}