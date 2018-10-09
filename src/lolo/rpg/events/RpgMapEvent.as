package lolo.rpg.events
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * RPG地图相关事件
	 * @author LOLO
	 */
	public class RpgMapEvent extends Event
	{
		/**鼠标在地图背景上按下*/
		public static const MOUSE_DOWN:String = "rpgMap_mouseDown";
		/**屏幕中心位置发生了变化*/
		public static const SCREEN_CENTER_CHANGED:String = "screenCenterChanged";
		/**Avatar已经进行了一次排序*/
		public static const AVATAR_SORTED:String = "avatarSorted";
		
		
		/**事件发生的区块点*/
		public var tile:Point;
		
		
		
		
		public function RpgMapEvent(type:String, tile:Point=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.tile = tile;
		}
		//
	}
}