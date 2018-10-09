package lolo.events.components
{
	import flash.events.Event;
	/**
	 * 翻页事件
	 * @author LOLO
	 */
	public class PageEvent extends Event
	{
		/**翻页*/
		public static const FLIP:String = "flip";
		
		
		/**当前页*/
		public var currentPage:uint;
		/**总页数*/
		public var totalPage:uint;
		
		
		public function PageEvent(type:String, currentPage:uint, totalPage:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.currentPage = currentPage;
			this.totalPage = totalPage;
		}
		//
	}
}