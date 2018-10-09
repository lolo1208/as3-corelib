package lolo.effects.float
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import lolo.utils.optimize.CachePool;

	/**
	 * <b>向背后浮动效果</b></br>
	 * - step1: 向背后浮动目标，并且 alpha 从0 至 1（duration为持续时间的一半）</br>
	 * - step2: 向背后再移动一段距离，并将 alpha 设置为0</br>
	 * - step3: 浮动结束后，将目标从父容器中移除，并将 alpha 设置为1
	 * @author LOLO
	 */
	public class BehindFloat implements IFloat
	{
		/**应用该效果的目标*/
		private var _target:DisplayObject;
		/**浮动结束后的回调函数*/
		private var _onComplete:Function;
		/**是否正在浮动中*/
		private var _floating:Boolean;
		
		/**作用点（正面的位置）*/
		public var actionPoint:Point;
		/**根据作用点计算出的距离偏移值*/
		private var _offsetPoint:Point;
		
		/**step1 的持续时长（秒）*/
		public var step1_duration:Number = 0.3;
		/**step1 的移动距离*/
		public var step1_distance:uint = 50;
		
		/**step2 的延迟时长（秒）*/
		public var step2_delay:Number = 0.2;
		/**step2 的持续时长（秒）*/
		public var step2_duration:Number = 0.8;
		/**step2 的移动距离*/
		public var step2_distance:uint = 30;
		
		
		
		
		/**
		 * 构造函数
		 * @param target 应用该效果的目标
		 * @param actionPoint 作用点（正面的位置）
		 * @param onComplete 浮动结束后的回调函数。onComplete(complete:Boolean, float:IFloat)
		 */
		public function BehindFloat(target:DisplayObject=null, actionPoint:Point=null, onComplete:Function=null)
		{
			this.target = target;
			this.actionPoint = actionPoint;
			this.onComplete = onComplete;
			
			if(target != null || actionPoint != null) start();
		}
		
		
		
		
		private function step1():void
		{
			//得出偏移位置
			_offsetPoint = CachePool.getPoint(_target.x - actionPoint.x, _target.y - actionPoint.y);
			
			//取较小的偏移倍数
			var mx:Number = Math.abs(1 / _offsetPoint.x);
			var my:Number = Math.abs(1 / _offsetPoint.y);
			var m:Number = Math.min(mx, my);
			
			//得出距离偏移值
			_offsetPoint.x *= m;
			_offsetPoint.y *= m;
			
			_target.alpha = 0;
			TweenMax.to(_target, step1_duration, {
				x:_target.x + _offsetPoint.x * step1_distance,
				y:_target.y + _offsetPoint.y * step1_distance,
				onComplete:step2
			});
			TweenMax.to(_target, step1_duration >> 1, { alpha:1 });
		}
		
		private function step2():void
		{
			TweenMax.to(_target, step2_duration, {
				x:_target.x + _offsetPoint.x * step2_distance,
				y:_target.y + _offsetPoint.y * step2_distance,
				alpha:0, delay:step2_delay,
				onComplete:step3
			});
		}
		
		private function step3():void
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
			CachePool.recover(_offsetPoint);
			_offsetPoint = null;
			
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