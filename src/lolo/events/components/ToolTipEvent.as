package lolo.events.components
{
	import flash.events.Event;
	/**
	 * 提示信息事件
	 * @author LOLO
	 */
	public class ToolTipEvent extends Event
	{
		/**显示提示信息*/
		public static const SHOW:String = "showToolTip";
		
		/**提示内容*/
		public var toolTip:String;
		
		
		public function ToolTipEvent(type:String, toolTip:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.toolTip = toolTip;
		}
		//
	}
}