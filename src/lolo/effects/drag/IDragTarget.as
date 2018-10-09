package lolo.effects.drag
{
	import flash.display.DisplayObject;
	
	/**
	 * 拖动目标接口
	 * @author LOLO
	 */
	public interface IDragTarget
	{
		/**
		 * 获取源（绘制，鼠标点击）
		 * @return 
		 */
		function get source():DisplayObject;
		
		
		/**
		 * 是否可以拖动
		 */
		function get dragEnabled():Boolean;
		
		
		/**
		 * 拖动目标附带的数据
		 */
		function get dragTargetData():*;
		//
	}
}