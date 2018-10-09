package lolo.rpg.events
{
	import flash.events.Event;
	
	/**
	 * 角色相关事件
	 * @author LOLO
	 */
	public class AvatarEvent extends Event
	{
		/**角色所在的区块已经改变*/
		public static const TILE_CHANGED:String = "avatar_tileChanged";
		/**角色移动中（像素坐标有改变）*/
		public static const MOVEING:String = "avatar_moveing";
		/**角色移动结束*/
		public static const MOVE_END:String = "avatar_moveEnd";
		
		
		/**鼠标移到角色上*/
		public static const MOUSE_OVER:String = "avatar_mouseOver";
		/**鼠标从角色上移开*/
		public static const MOUSE_OUT:String = "avatar_mouseOut";
		/**鼠标在角色身上按下*/
		public static const MOUSE_DOWN:String = "avatar_mouseDown";
		/**鼠标点击角色*/
		public static const CLICK:String = "avatar_click";
		
		
		/**角色开始执行某个动作*/
		public static const ACTION_START:String = "avatar_actionStart";
		/**角色执行某个动作完成（不包含无限执行的动作，idle、run 等）*/
		public static const ACTION_END:String = "avatar_actionEnd";
		
		
		
		
		public function AvatarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		//
	}
}