package lolo.utils.optimize
{
	/**
	 * 可以与鼠标交互的对象
	 * @author LOLO
	 */
	public interface IInteractiveObject
	{
		
		/**
		 * 是否启用与鼠标交互
		 */
		function get interactiveEnabled():Boolean;
		
		/**
		 * 交互时需要检查鼠标是否在该对象的透明区域
		 */
		function get isTransparent():Boolean;
		
		/**
		 * 鼠标拖动容器时，是否取消该对象的后续事件
		 */
		function get isCancelEvent():Boolean;
		
		/**
		 * 鼠标在该对象上按下时，是否取消拖动
		 */
		function get isCancelDrag():Boolean;
		
		
		/**
		 * 鼠标移动到该对象上
		 */
		function onMoveOver():void;
		
		/**
		 * 鼠标从该对象上移开
		 */
		function onMoveOut():void;
		
		/**
		 * 鼠标在该对象上按下
		 */
		function onMoveDown():void;
		
		/**
		 * 鼠标在该对象上点击
		 */
		function onClick():void;
		
		
		//
	}
}