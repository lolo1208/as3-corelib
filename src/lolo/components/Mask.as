package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.Shape;

	/**
	 * 显示对象的遮罩
	 * @author LOLO
	 */
	public class Mask extends Shape
	{
		/**遮罩的目标*/
		private var _target:DisplayObject;
		
		
		public function Mask()
		{
			super();
		}
		
		
		/**
		 * 矩形遮罩
		 * @param value 参数{width:矩形的宽度, height:矩形的高度}
		 */
		public function set rect(value:Object):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0, 0, value.width, value.height);
			this.graphics.endFill();
		}
		
		
		/**
		 * 椭圆遮罩
		 * @param value 参数{width:椭圆的宽度, height:椭圆的高度}
		 */
		public function set ellipse(value:Object):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawEllipse(0, 0, value.width, value.height);
			this.graphics.endFill();
		}
		
		
		/**
		 * 圆角矩形遮罩
		 * @param value 参数{width:圆角矩形的宽度, height:圆角矩形的高度, ellipseWidth:圆角的椭圆的宽度, ellipseHeight:圆角的椭圆的高度}
		 */
		public function set roundRect(value:Object):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRoundRect(0, 0, value.width, value.height, value.ellipseWidth, value.ellipseHeight);
			this.graphics.endFill();
		}
		
		
		
		/**
		 * 遮罩的目标
		 */
		public function set target(value:DisplayObject):void
		{
			_target = value;
			
			if(_target.mask != null) _target.mask.parent.removeChild(_target.mask);
			if(_target.parent != null) _target.parent.addChild(this);
			_target.mask = this;
		}
		
		public function get target():DisplayObject { return _target; }
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		public function dispose():void
		{
			if(_target != null) {
				_target.mask = null;
				_target = null;
			}
			
			if(parent != null) parent.removeChild(this);
		}
		//
	}
}