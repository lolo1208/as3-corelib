package lolo.events.components
{
	import flash.events.Event;
	/**
	 * 富显示文本事件
	 * @author LOLO
	 */
	public class RichTextEvent extends Event
	{
		/**点击了文本中的链接*/
		public static const CLICK_LINK:String = "clickLink";
		
		/**附带的数据*/
		public var data:*;
		
		
		public function RichTextEvent(type:String, data:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		//
	}
}