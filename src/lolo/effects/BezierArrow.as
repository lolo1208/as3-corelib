package lolo.effects
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import lolo.display.IAnimation;
	import lolo.utils.optimize.CachePool;

	/**
	 * 贝塞尔箭矢（炮弹）飞行动画
	 * @author LOLO
	 */
	public class BezierArrow
	{
		/**飞行开始点*/
		public var pStrat:Point;
		/**飞行结束点*/
		public var pEnd:Point;
		/**贝塞尔取点距离（值越大，曲线幅度越大）*/
		public var bezierDistance:Number = 0.4;
		
		/**飞行的箭矢*/
		public var arrow:DisplayObject;
		/**飞行时长（秒，默认值：0）。值为 0 时，将会根据<b>飞行距离</b> 和 <b>autuDuration</b>，动态计算飞行时长*/
		public var duration:Number = 0;
		/**动态时长的计算参数，值越大，数度越快（需配合 duration 一起使用）*/
		public var autoDuration:uint = 800;
		/**箭矢是否跟随贝塞尔曲线旋转*/
		public var orientToBezier:Boolean;
		/**飞行动画播放完成的回调*/
		public var callback:Function;
		/**回调的参数*/
		public var callbackArgs:Array;
		
		
		
		/**
		 * 构造函数
		 * @param pStrat
		 * @param pEnd
		 * @param arrow
		 * @param orientToBezier
		 */
		public function BezierArrow(pStrat:Point=null, pEnd:Point=null, arrow:DisplayObject=null, orientToBezier:Boolean=true)
		{
			this.pStrat = pStrat;
			this.pEnd = pEnd;
			this.arrow = arrow;
			this.orientToBezier = orientToBezier;
		}
		
		
		/**
		 * 播放飞行动画
		 */
		public function play(callback:Function=null, ...callbackArgs):void
		{
			end();
			if(callback != null) {
				this.callback = callback;
				this.callbackArgs = callbackArgs;
			}
			
			arrow.x = pStrat.x;
			arrow.y = pStrat.y;
			
			var pCenter:Point = Point.interpolate(pStrat, pEnd, 0.5);
			pCenter.y -= Math.abs(pCenter.x - pStrat.x) * bezierDistance;
			
			var d:Number = duration;
			if(d <= 0) d = Point.distance(pStrat, pEnd) / autoDuration;
			
			TweenMax.to(arrow, d, {
				ease:Linear.easeNone, orientToBezier:orientToBezier,
				bezier:[ {x:pCenter.x, y:pCenter.y}, {x:pEnd.x, y:pEnd.y} ],
				onComplete:playComplete
			});
			
			CachePool.recover(pCenter);
		}
		
		private function playComplete():void
		{
			if(arrow is IAnimation) (arrow as IAnimation).stop();
			if(callback != null) {
				callback.apply(null, callbackArgs);
				callback = null;
			}
		}
		
		
		/**
		 * 停止飞行动画
		 */
		public function end():void
		{
			TweenMax.killTweensOf(arrow);
		}
		//
	}
}