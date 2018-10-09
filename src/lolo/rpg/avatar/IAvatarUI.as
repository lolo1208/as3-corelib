package lolo.rpg.avatar
{
	/**
	 * RPG角色身上UI的接口
	 * @author LOLO
	 */
	public interface IAvatarUI
	{
		
		/**
		 * 该UI的名称
		 */
		function set name(value:String):void;
		function get name():String;
		
		
		
		/**
		 * 该UI对应的角色
		 */
		function set avatar(value:IAvatar):void;
		function get avatar():IAvatar;
		
		
		
		/**
		 * 清除，销毁，释放
		 */
		function dispose():void;
		//
	}
}