package lolo.effects
{
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * 闪烁快照工具<br/>
	 * 闪烁的过程为：透明度从 minAlpha→maxAlpha，然后 maxAlpha→minAlpha，这个过程算闪烁了两次。接下来继续重复该步骤，直到满足count。
	 * @author LOLO
	 */
	public class FlickerSnapshot extends Bitmap
	{
		/**已闪烁次数*/
		private var _currentCount:int = 0;
		/**目标显示对象*/
		private var _target:DisplayObject;
		
		/**闪烁时最低的透明度*/
		public var minAlpha:Number = 0.4;
		/**闪烁时最高的透明度*/
		public var maxAlpha:Number = 0.9;
		/**每次闪烁的持续时间（秒）*/
		public var duration:Number;
		/**每次闪烁的延迟时间（秒）*/
		public var delay:Number;
		/**闪烁重复次数（次数为0时，无限重复）*/
		public var count:uint;
		/**闪烁结束后的回调函数*/
		public var callback:Function;
		
		
		/**
		 * 对目标显示对象提取快照，并进行闪烁
		 * @param target 目标显示对象
		 * @return
		 */
		public function FlickerSnapshot(target:DisplayObject=null)
		{
			super();
			_target = target;
		}
		
		
		
		/**
		 * 开始闪烁
		 * @param color 快照的颜色
		 * @param callback 闪烁结束后的回调函数
		 * @param duration 每次闪烁的持续时间（秒）
		 * @param delay 每次闪烁的延迟时间（秒）
		 * @param count 闪烁重复次数
		 */		
		public function flicker(color:uint=0x005500, callback:Function=null, duration:Number=0.3, delay:Number=0.1, count:uint=7):void
		{
			if(_target == null || _target.parent == null) return;
			
			reset();
			
			this.callback = callback;
			this.duration = duration;
			this.delay = delay;
			this.count = count;
			
			//绘制快照
			var rect:Rectangle = _target.getBounds(_target);
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bitmapData.draw(_target, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
			this.bitmapData = bitmapData;
			
			//设置快照颜色
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = color;
			colorTransform.redMultiplier = 1;
			colorTransform.greenMultiplier = 1;
			colorTransform.blueMultiplier = 1;
			this.transform.colorTransform = colorTransform;
			
			//添加到目标的父级
			this.x = _target.x + rect.x;
			this.y = _target.y + rect.y;
			_target.parent.addChildAt(this, _target.parent.getChildIndex(_target) + 1);
			
			//开始闪烁
			this.alpha = minAlpha;
			_currentCount = -1;
			continueFlicker();
		}
		
		/**
		 * 继续闪烁
		 */
		private function continueFlicker():void
		{
			_currentCount++;
			
			//次数达到上限，或者目标不可见
			if( (_currentCount > count && count != 0) || !_target.visible || _target.alpha == 0 || _target.parent == null)
			{
				if(_currentCount > count && callback != null) callback();
				reset();
				return;
			}
			
			var alpha:Number = (this.alpha > minAlpha) ? minAlpha : maxAlpha;
			TweenMax.to(this, duration, { delay:delay, alpha:alpha, onComplete:continueFlicker });
		}
		
		
		
		/**
		 * 闪烁的目标显示对象（在闪烁过程中修改 target，并不会更新快照，需要重新调用 flicker() 方法才能生效）
		 */
		public function set target(value:DisplayObject):void
		{
			_target = value;
		}
		public function get target():DisplayObject { return _target; }
		
		
		
		/**
		 * 重置
		 */
		public function reset():void
		{
			TweenMax.killTweensOf(this);
			if(bitmapData != null) {
				bitmapData.dispose();
				bitmapData = null;
			}
			if(this.parent) this.parent.removeChild(this);
			callback = null;
		}
		//
	}
}