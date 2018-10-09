package lolo.ui
{
	/**
	 * 可以以窗口形式进行布局的显示对象
	 * @author LOLO
	 */
	public interface IWindowLayout
	{
		/**
		 * 布局宽度
		 */
		function get layoutWidth():uint;
		
		/**
		 * 布局高度
		 */
		function get layoutHeight():uint;
		
		/**
		 * 布局方向。 <br/>
		 * 可选值 [ horizontal:从左到右水平方向布局（默认）, vertical:从上至下垂直方向布局 ]
		 */
		function set layoutDirection(value:String):void;
		function get layoutDirection():String;
		
		/**
		 * 布局索引。该值越小就越靠左或靠上
		 */
		function set layoutIndex(value:int):void;
		function get layoutIndex():int;
		
		/**
		 * 组合布局时，与下一个窗口的间距
		 */
		function set layoutGap(value:int):void;
		function get layoutGap():int;
		
		
		/**
		 * 水平x坐标
		 */
		function set x(value:Number):void;
		function get x():Number;
		
		/**
		 * 垂直y坐标
		 */
		function set y(value:Number):void;
		function get y():Number;
		//
	}
}