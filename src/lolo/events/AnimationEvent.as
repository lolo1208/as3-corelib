package lolo.events
{
	import flash.events.Event;
	/**
	 * 动画事件
	 * @author LOLO
	 */
	public class AnimationEvent extends Event
	{
		/**帧刷新（与Event.ENTER_FRAME不同的是，动画只有在播放时，切换帧时才会触发该事件）*/
		public static const ENTER_FRAME:String = "animationEnterFrame";
		
		/**动画进入了停止帧*/
		public static const ENTER_STOP_FRAME:String = "animationEnterStopFrame";
		
		/**动画在完成了指定重复次数，并到达了停止帧*/
		public static const ANIMATION_END:String = "animationEnd";
		
		
		
		
		public function AnimationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		//
	}
}