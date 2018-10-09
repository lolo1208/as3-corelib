package lolo.effects.interactive
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import lolo.core.Common;

	/**
	 * 与鼠标交互时的浮动按钮效果<br/>
	 * rollOver 时，在浮动区域内绘制看不见的矩形（防止意外收到 rollOut 事件），<br/>
	 * rollOut 将会自动 clear()
	 * @author LOLO
	 */
	public class FloatButton
	{
		/**交互时，浮动的X距离*/
		public var floatX:int;
		/**交互时，浮动的Y距离*/
		public var floatY:int;
		/**浮动目标的宽度，默认值 0 表示 target.width*/
		public var width:uint;
		/**浮动目标的高度，默认值 0 表示 target.height*/
		public var height:uint;
		/**是否自动将鼠标指针设置成按钮手形光标*/
		public var autoMouseCursor:Boolean;
		
		/**要浮动的目标*/
		private var _target:Sprite;
		/**是否启用（默认：true）*/
		private var _enabled:Boolean;
		
		/**正常时的X位置*/
		private var _normalX:int;
		/**正常时的Y位置*/
		private var _normalY:int;
		
		
		
		
		/**
		 * 构造函数
		 * @param target 要浮动的目标
		 * @param floatX 交互时，浮动的X距离
		 * @param floatY 交互时，浮动的Y距离
		 * @param autoMouseCursor 是否自动将鼠标指针设置成按钮手形光标
		 * @param width 浮动目标的宽度，默认值 0 表示 target.width
		 * @param height 浮动目标的高度，默认值 0 表示 target.height
		 */
		public function FloatButton(target:Sprite=null,
									floatX:int=0, floatY:int=-3,
									autoMouseCursor:Boolean=false,
									width:uint=0, height:uint=0
		) {
			this.target = target;
			this.floatX = floatX;
			this.floatY = floatY;
			this.autoMouseCursor = autoMouseCursor;
			this.width = width;
			this.height = height;
			this.enabled = true;
		}
		
		
		
		/**
		 * 要浮动的目标
		 */
		public function set target(value:Sprite):void
		{
			var e:Boolean = _enabled;
			enabled = false;
			
			_target = value;
			enabled = e;
			updateNormalPoint();
		}
		public function get target():Sprite { return _target; }
		
		
		/**
		 * 立即更新（重新记录）target 的默认位置
		 */
		public function updateNormalPoint():void
		{
			if(_target != null) {
				_normalX = _target.x;
				_normalY = _target.y;
			}
		}
		
		
		
		/**
		 * 是否启用（默认：true）
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			if(_target == null) return;
			if(_enabled) {
				_target.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				_target.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				_target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
			else {
				_target.graphics.clear();
				_target.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				_target.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				_target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				rollOutHandler();
			}
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		
		
		private function rollOverHandler(event:MouseEvent=null):void
		{
			_target.graphics.clear();
			_target.graphics.beginFill(0, 0);
			_target.graphics.drawRect(-floatX, -floatY,
				(width == 0) ? _target.width : width,
				(height == 0) ? _target.height : height);
			_target.graphics.endFill();
			
			if(floatX != 0) _target.x += floatX;
			if(floatY != 0) _target.y += floatY;
			
			if(autoMouseCursor) Mouse.cursor = MouseCursor.BUTTON;
		}
		
		
		private function rollOutHandler(event:MouseEvent=null):void
		{
			_target.graphics.clear();
			if(floatX != 0) _target.x = _normalX;
			if(floatY != 0) _target.y = _normalY;
			
			if(autoMouseCursor) Mouse.cursor = MouseCursor.AUTO;
		}
		
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			
			_target.graphics.clear();
			if(floatX != 0) _target.x = _normalX;
			if(floatY != 0) _target.y = _normalY;
		}
		
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			(event.target == _target) ? rollOverHandler() : rollOutHandler();
		}
		//
	}
}