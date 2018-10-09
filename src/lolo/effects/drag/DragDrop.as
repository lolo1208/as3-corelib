package lolo.effects.drag
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.effects.AsEffect;
	
	/**
	 * 拖放效果
	 * @author LOLO
	 */
	public class DragDrop extends Bitmap
	{
		/**拖动的目标*/
		private var _dragTarget:IDragTarget;
		/**当前移入的停放目标*/
		private var _dropTarget:IDropTarget;
		/**鼠标按下的点*/
		private var _mouseDownPoint:Point = new Point();
		
		/**拖动开始时，拖动目标的属性{filters:Array, alpha:Number}。在拖动过程中，拖动目标相关属性的改变，在拖动结束时，将会被忽略*/
		private var _dragTargetProp:Object;
		
		/**是否在拖动开始时，自动改变拖动对象的属性，达到区别的效果*/
		private var _autoChangeDragTarget:Boolean = true;
		
		/**绘制时的矩形信息*/
		private var _drawRect:Rectangle;
		
		
		public function DragDrop(dragTarget:IDragTarget=null)
		{
			super();
			this.dragTarget = dragTarget;
			this.alpha = 0.8;
		}
		
		
		
		/**
		 * 鼠标按下拖动目标
		 * @param event
		 */
		private function dragTarget_mouseDownHandler(event:MouseEvent):void
		{
			if(!_dragTarget.dragEnabled) {
				if(bitmapData != null) {
					bitmapData.dispose();
					bitmapData = null;
				}
				return;
			}
			
			if(_dragTarget.source == null || _dragTarget.source.width == 0 || _dragTarget.source.height == 0) return;
			
			_mouseDownPoint.setTo(_dragTarget.source.mouseX, _dragTarget.source.mouseY);
			Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		
		/**
		 * 鼠标在舞台移动
		 * @param event
		 */
		private function stage_mouseMoveHandler(event:MouseEvent):void
		{
			if(!event.buttonDown) return;
			
			var dropTarget:IDropTarget = getDropTarget();
			//开始拖动
			if(bitmapData == null) {
				drawDragTarget();
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_START, _dragTarget, dropTarget));
				
				//记录拖动目标的属性，然后改变
				if(_autoChangeDragTarget) {
					var dt:DisplayObject = _dragTarget as DisplayObject;
					_dragTargetProp = { filters:dt.filters, alpha:dt.alpha };
					dt.alpha = 0.6;
					dt.filters = [AsEffect.GRAY_FILTER];
				}
			}
			else {
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_MOVE, _dragTarget, dropTarget));
			}
			
			this.x = event.stageX - _mouseDownPoint.x + _drawRect.x;
			this.y = event.stageY - _mouseDownPoint.y + _drawRect.y;
		}
		
		/**
		 * 鼠标在舞台释放
		 * @param event
		 */
		private function stage_mouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			
			
			//还原拖动目标的属性到拖动前的状态
			if(_dragTargetProp != null) {
				var dt:DisplayObject = _dragTarget as DisplayObject;
				dt.alpha = _dragTargetProp.alpha;
				dt.filters = _dragTargetProp.filters;
			}
			
			
			Common.ui.removeChildToLayer(this, Constants.LAYER_NAME_ALERT);
			if(bitmapData != null) {
				bitmapData.dispose();
				bitmapData = null;
			}
			
			var dropTarget:IDropTarget = getDropTarget();
			//是在停放目标上释放鼠标的
			if(dropTarget != null) {
				_dropTarget = null;
				
				//调用移入停放目标的【移开】方法
				dropTarget.dragOut(_dragTarget);
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_OUT, _dragTarget, dropTarget));
				
				//向停放目标【申请停放】
				dropTarget.applyDrop(_dragTarget);
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_DROP, _dragTarget, dropTarget));
			}
			else {
				dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_END, _dragTarget));	
			}
		}
		
		
		
		/**
		 * 获取当前鼠标指针下，可以停放的目标，并记录该目标
		 * @return 
		 */
		private function getDropTarget():IDropTarget
		{
			//从最上层开始取出显示对象
			var childs:Array = Common.stage.getObjectsUnderPoint(new Point(Common.stage.mouseX, Common.stage.mouseY));
			childs.reverse();
			
			var dropTarget:IDropTarget;
			var parent:DisplayObjectContainer;
			for(var i:int = 0; i < childs.length; i++)
			{
				//显示对象是停放目标
				if(childs[i] is IDropTarget && (childs[i] as IDropTarget).dropEnabled) {
					dropTarget = childs[i];
				}
				else {
					//查找他的父级是否为停放目标
					parent = childs[i].parent as DisplayObjectContainer;
					while(parent != null)
					{
						if(parent is IDropTarget && (parent as IDropTarget).dropEnabled) {
							dropTarget = parent as IDropTarget;
							break;
						}
						parent = parent.parent;
					}
				}
				
				//已经找到了停放目标
				if(dropTarget != null) break;
			}
			
			//停放目标有改变
			if(dropTarget != _dropTarget) {
				//调用上次移入停放目标的【移开】方法
				if(_dropTarget != null) {
					_dropTarget.dragOut(_dragTarget);
					dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_OUT, _dragTarget, _dropTarget));
				}
				
				_dropTarget = dropTarget;
				//调用移入停放目标的【移入】方法
				if(_dropTarget != null) {
					_dropTarget.dragIn(_dragTarget);
					dispatchEvent(new DragDropEvent(DragDropEvent.DRAG_IN, _dragTarget, _dropTarget));
				}
			}
			
			return dropTarget;
		}
		
		/**
		 * 设置鼠标按下时的位置（拖动图像的偏移值）
		 * @param value
		 */
		public function set mouseDownPoint(value:Point):void
		{
			_mouseDownPoint = value;
		}
		
		
		/**
		 * 绘制拖动的目标
		 * @param source
		 */
		public function drawDragTarget():void
		{
			if(bitmapData != null) bitmapData.dispose();
			
			_drawRect = _dragTarget.source.getBounds(_dragTarget.source);
			bitmapData = new BitmapData(_drawRect.width, _drawRect.height, true, 0);
			bitmapData.draw(_dragTarget.source, new Matrix(1, 0, 0, 1, -_drawRect.x, -_drawRect.y));
			
			Common.ui.addChildToLayer(this, Constants.LAYER_NAME_ALERT);
		}
		
		
		/**
		 * 拖动的目标
		 */
		public function set dragTarget(value:IDragTarget):void
		{
			if(_dragTarget != null) {
				(_dragTarget as IEventDispatcher).removeEventListener(MouseEvent.MOUSE_DOWN, dragTarget_mouseDownHandler);
			}
			
			_dragTarget = value;
			if(_dragTarget != null) {
				(_dragTarget as IEventDispatcher).addEventListener(MouseEvent.MOUSE_DOWN, dragTarget_mouseDownHandler);
			}
		}
		public function get dragTarget():IDragTarget { return _dragTarget; }
		
		
		
		
		/**
		 * 是否在拖动开始时，自动改变拖动对象的属性，达到区别的效果
		 */
		public function set autoChangeDragTarget(value:Boolean):void { _autoChangeDragTarget = value; }
		public function get autoChangeDragTarget():Boolean { return _autoChangeDragTarget; }
		
		
		
		
		/**
		 * 用于清理引用，释放内存
		 * 在丢弃该对象时，需要主动调用该方法
		 */
		public function dispose():void
		{
			if(bitmapData != null) {
				bitmapData.dispose();
				bitmapData = null;
			}
			
			_dragTargetProp = null;
			dragTarget = null;
			
			if(_dragTarget != null) {
				(_dragTarget as IEventDispatcher).removeEventListener(MouseEvent.MOUSE_DOWN, dragTarget_mouseDownHandler);
			}
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		//
	}
}