package lolo.effects.drag
{
	import flash.events.Event;
	
	/**
	 * 拖放事件
	 * @author LOLO
	 */
	public class DragDropEvent extends Event
	{
		/**开始拖动*/
		public static const DRAG_START:String = "dragStart";
		/**拖动中（移动）*/
		public static const DRAG_MOVE:String = "dragMove";
		/**移入某个停放目标*/
		public static const DRAG_IN:String = "dragIn";
		/**从某个停放目标上移开*/
		public static const DRAG_OUT:String = "dragOut";
		/**拖动停止*/
		public static const DRAG_END:String = "dragEnd";
		/**拖动停放到某个停放目标上*/
		public static const DRAG_DROP:String = "dragDrop";
		
		
		/**拖动的目标*/
		public var dragTarget:IDragTarget;
		/**停放的目标*/
		public var dropTarget:IDropTarget;
		
		
		
		public function DragDropEvent(type:String, dragTarget:IDragTarget, dropTarget:IDropTarget=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.dragTarget = dragTarget;
			this.dropTarget = dropTarget;
		}
		//
	}
}