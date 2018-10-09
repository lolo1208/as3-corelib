package lolo.rpg.avatar
{
	import flash.events.IEventDispatcher;
	
	/**
	 * 角色加载外形时，显示的Loading
	 * @author LOLO
	 */
	public interface IAvatarLoading extends IEventDispatcher
	{
		/**
		 * 加载进度（0~1）
		 */
		function set progress(value:Number):void;
		function get progress():Number;
		
		
		/**
		 * 清除并丢弃该Loading
		 */
		function clear():void;
		//
	}
}