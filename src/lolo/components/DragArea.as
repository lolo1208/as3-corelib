package lolo.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.core.Common;

	/**
	 * 拖动区域
	 * @author LOLO
	 */
	public class DragArea extends Sprite
	{
		/**要拖动的目标*/
		private var _target:Sprite;
		
		
		public function DragArea(target:Sprite=null)
		{
			super();
			
			this.target = target;
			
			this.graphics.beginFill(0, 0.001);
			this.graphics.drawRect(0, 0, 10, 10);
			this.graphics.endFill();
		}
		
		
		
		/**
		 * 要拖动的目标
		 */
		public function set target(value:Sprite):void
		{
			if(_target != null) this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			_target = value;
			if(_target != null) this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		public function get target():Sprite { return _target; }
		
		
		
		/**
		 * 鼠标在拖动区域上按下
		 * @param event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(_target != null)
			{
				Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
				Common.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				_target.startDrag();
			}
		}
		
		/**
		 * 鼠标在舞台上移动
		 * @param event
		 */
		private function stageMouseMoveHandler(event:MouseEvent):void
		{
			//event.updateAfterEvent();
		}
		
		
		/**
		 * 鼠标在舞台上释放
		 * @param event
		 */
		private function stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			if(_target != null) _target.stopDrag();
		}
		//
	}
}