package lolo.effects.float
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import lolo.utils.optimize.CachePool;

	/**
	 * <b>先向上浮动，停留一会，再浮动到某一点</b></br>
	 * - step1: 从 alpha=0 到 alpha=1 ，并向上浮动目标</br>
	 * - step2: 停留指定时间后，移动到目标位置，并缓动更新 scaleX、scaleY</br>
	 * - step3: 浮动结束后，将目标从父容器中移除，并将 alpha、scaleX、scaleY 设置为1
	 * @author LOLO
	 */
	public class FloatToPosition implements IFloat
	{
		/**应用该效果的目标*/
		private var _target:DisplayObject;
		/**浮动结束后的回调函数*/
		private var _onComplete:Function;
		/**是否正在浮动中*/
		private var _floating:Boolean;
		
		
		/**step1 的持续时长（秒）*/
		public var step1_duration:Number = 0.4;
		/**step1 的移动距离（Y）*/
		public var step1_y:int = -10;
		
		/**step2 的停留时长（秒）*/
		public var step2_delay:Number = 0.2;
		/**step2 的持续时长（秒）*/
		public var step2_duration:Number = 0.6;
		/**step2 的 scaleX*/
		public var step2_scaleX:Number = 0.5;
		/**step2 的 scaleY*/
		public var step2_scaleY:Number = 0.5;
		
		/**step2 的目标位置*/
		public var step2_p:Point;
		
		
		
		/**
		 * 构造函数
		 * @param target 应用该效果的目标
		 * @param p 最终移动到该位置
		 * @param onComplete 浮动结束后的回调函数。onComplete(complete:Boolean, float:IFloat)
		 */
		public function FloatToPosition(target:DisplayObject=null, p:Point=null, onComplete:Function=null)
		{
			this.target = target;
			this.onComplete = onComplete;
			step2_p = (p != null) ? p : CachePool.getPoint();
			
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
				delay:step2_delay,
				x:step2_p.x, y:step2_p.y,
				scaleX:step2_scaleX, scaleY:step2_scaleY,
				ease:Linear.easeNone, onComplete:step3
			});
		}
		
		private function step3():void
		{
			_target.alpha = 1;
			_target.scaleX = 1;
			_target.scaleY = 1;
			
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