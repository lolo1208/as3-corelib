package lolo.components
{
	/**
	 * 滚动列表接口
	 * @author LOLO
	 */
	public interface IScrollList extends IList
	{
		/**
		 * 对应的滚动条
		 */
		function set scrollBar(value:IScrollBar):void;
		function get scrollBar():IScrollBar;
		
		
		/**
		 * 在布局时，默认的 item 宽度<br/>
		 * 如果值为0，在布局时，将取第一个（data[0]）item 的 itemWidth 作为该值
		 */
		function set itemWidth(value:uint):void;
		function get itemWidth():uint;
		
		/**
		 * 在布局时，默认的 item 高度<br/>
		 * 如果值为0，在布局时，将取第一个（data[0]）item 的 itemHeight 作为该值
		 */
		function set itemHeight(value:uint):void;
		function get itemHeight():uint;
		//
	}
}