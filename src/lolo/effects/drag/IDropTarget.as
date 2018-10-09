package lolo.effects.drag
{
	import flash.events.IEventDispatcher;
	
	/**
	 * 停放目标接口
	 * @author LOLO
	 */
	public interface IDropTarget extends IEventDispatcher
	{
		/**
		 * 是否可以停放
		 */
		function get dropEnabled():Boolean;
		
		
		/**
		 * 停放目标附带的数据
		 */
		function get dropTargetData():*;
		
		
		
		/**
		 * 拖动目标从移进来了
		 * @param dragTarget
		 */
		function dragIn(dragTarget:IDragTarget):void;
		
		/**
		 * 拖动目标从身上移开
		 * @param dragTarget
		 */
		function dragOut(dragTarget:IDragTarget):void;
		
		/**
		 * 有拖动目标申请停放
		 * @param dragTarget
		 */
		function applyDrop(dragTarget:IDragTarget):void;
		//
	}
}