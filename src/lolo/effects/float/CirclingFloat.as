package lolo.effects.float
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import lolo.display.IAnimation;
	import lolo.utils.optimize.CachePool;
	
	/**
	 * 回旋浮动效果
	 * @author LOLO
	 */
	public class CirclingFloat implements IFloat
	{
		/**应用该效果的目标*/
		private var _target:DisplayObject;
		/**浮动结束后的回调函数*/
		private var _onComplete:Function;
		/**是否正在浮动中*/
		private var _floating:Boolean;
		
		/**开始点*/
		public var pStart:Point;
		/**结束点*/
		public var pEnd:Point;
		/**效果总时长*/
		public var duration:Number;
		/**目标是否跟随贝塞尔曲线旋转*/
		public var orientToBezier:Boolean;
		
		/**节点1距离*/
		public var distance1:uint = 40;
		/**节点2距离*/
		public var distance2:uint = 25;
		
		
		
		/**
		 * 构造函数
		 * @param target 应用该效果的目标
		 * @param onComplete 浮动结束后的回调函数。onComplete(complete:Boolean, float:IFloat)
		 */
		public function CirclingFloat(target:DisplayObject = null,
									  pStart:Point = null,
									  pEnd:Point = null,
									  duration:Number = 1.5,
									  orientToBezier:Boolean = false,
									  onComplete:Function = null)
		{
			this.target = target;
			this.pStart = pStart;
			this.pEnd = pEnd;
			this.duration = duration;
			this.orientToBezier = orientToBezier;
			this.onComplete = onComplete;
			
			if(target != null && pStart != null && pEnd != null) start();
		}
		
		
		
		private function step1():void
		{
			var tempVal:*;
			
			//节点1
			var p1:Point = Point.interpolate(pEnd, pStart, 0.4);
			//贝塞尔节点1、5
			var atan:Number = Math.atan((pStart.y - p1.y) / (pStart.x - p1.x));
			var bp1:Point = CachePool.getPoint(
				p1.x - distance1 * Math.sin(atan),
				p1.y + distance1 * Math.cos(atan)
			);
			var bp5:Point = CachePool.getPoint(
				p1.x + distance1 * Math.sin(atan),
				p1.y - distance1 * Math.cos(atan)
			);
			if(pStart.x > p1.x) {
				tempVal = bp1;
				bp1 = bp5;
				bp5 = tempVal;
			}
			
			//节点2
			var p2:Point = Point.interpolate(pEnd, p1, 0.8);
			//贝塞尔节点2、4
			atan = Math.atan((p1.y - p2.y) / (p1.x - p2.x));
			var bp2:Point = CachePool.getPoint(
				p2.x - distance2 * Math.sin(atan),
				p2.y + distance2 * Math.cos(atan)
			);
			var bp4:Point = CachePool.getPoint(
				p2.x + distance2 * Math.sin(atan),
				p2.y - distance2 * Math.cos(atan)
			);
			if(p1.x > p2.x) {
				tempVal = bp2;
				bp2 = bp4;
				bp4 = tempVal;
			}
			
			//贝塞尔节点3
			var bp3:Point = Point.interpolate(pEnd, pStart, 1.05);
			
			_target.x = pStart.x;
			_target.y = pStart.y;
			TweenMax.to(_target, duration, {
				ease:Linear.easeNone, orientToBezier:orientToBezier,
				bezier:[
					{x:bp1.x, y:bp1.y},
					{x:bp2.x, y:bp2.y},
					{x:bp3.x, y:bp3.y},
					{x:bp4.x, y:bp4.y},
					{x:bp5.x, y:bp5.y},
					{x:pStart.x, y:pStart.y}//回到起点
				],
				onComplete:step2
			});
			
			CachePool.recover([ p1, p2, bp1, bp2, bp3, bp4, bp5 ]);
		}
		
		private function step2():void
		{
			if(_target is IAnimation) (_target as IAnimation).stop();
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