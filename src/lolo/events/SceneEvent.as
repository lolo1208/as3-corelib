package lolo.events
{
	import flash.events.Event;
	
	/**
	 * 场景事件
	 * @author LOLO
	 */
	public class SceneEvent extends Event
	{
		/**进入场景事件*/
		public static const ENTER_SCENE:String = "enterScene";
		
		
		public function SceneEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		//
	}
}