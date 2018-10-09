package lolo.components
{
	import com.greensock.TweenMax;
	
	import lolo.core.Common;
	
	/**
	 * 显示数字的文本
	 * 在值上升或下降时，闪动颜色
	 * @author LOLO
	 */
	public class NumberText extends Label
	{
		/**值增加时，切换的颜色*/
		public var upColor:uint;
		/**值减少时，切换的颜色*/
		public var downColor:uint;
		/**每次切换的间隔（秒）*/
		public var delay:Number;
		
		/**动画播放完成后，更新成新值时的回调函数*/
		public var callback:Function;
		
		/**文本正常的颜色*/
		private var _normalColor:uint;
		/**当前值*/
		private var _value:Number;
		/**新值*/
		private var _newValue:Number;
		
		
		public function NumberText()
		{
			super();
			this.style = Common.config.getStyle("numberText");
		}
		
		
		override public function set style(value:Object):void
		{
			super.style = value;
			
			if(value.color != null) color = _normalColor = value.color;
			if(value.upColor != null) upColor = value.upColor;
			if(value.downColor != null) downColor = value.downColor;
			if(value.delay != null) delay = value.delay;
		}
		
		
		
		/**
		 * 当前值
		 */
		public function set value(value:Number):void
		{
			if(value == _value) return;
			TweenMax.killDelayedCallsTo(playEffect);
			
			_newValue = value;
			if(isNaN(_value)) {
				effectEnd();
			}
			else {
				var color:uint = (_newValue > _value) ? upColor : downColor;
				playEffect(color, 0);
			}
		}
		public function get value():Number { return _newValue; }
		
		
		
		
		/**
		 * 播放上升或下降效果
		 * @param color 上升或下降的颜色值
		 * @param count 已经播放的次数
		 */
		private function playEffect(color:uint, count:uint):void
		{
			count++;
			super.color = (count % 2) == 1 ? color : _normalColor;
			
			if(count < 10) {
				TweenMax.delayedCall(delay, playEffect, [color, count]);
			}
			else {
				effectEnd();
			}
		}
		
		/**
		 * 效果结束
		 */
		private function effectEnd():void
		{
			_value = _newValue;
			this.text = _value.toString();//设置成value
			
			if(callback != null) {
				callback();
				callback = null;
			}
		}
		
		
		
		override public function set color(value:uint):void
		{
			super.color = value;
			_normalColor = value;
		}
		//
	}
}