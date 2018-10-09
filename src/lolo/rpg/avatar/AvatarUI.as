package lolo.rpg.avatar
{
	import flash.display.Sprite;
	
	/**
	 * RPG角色身上的UI
	 * @author LOLO
	 */
	public class AvatarUI extends Sprite implements IAvatarUI
	{
		/**对应的角色*/
		protected var _avatar:IAvatar;
		
		
		public function AvatarUI()
		{
			super();
		}
		
		
		public function set avatar(value:IAvatar):void
		{
			_avatar = value;
		}
		
		
		public function get avatar():IAvatar
		{
			return _avatar;
		}
		
		
		public function dispose():void
		{
			_avatar = null;
		}
		//
	}
}