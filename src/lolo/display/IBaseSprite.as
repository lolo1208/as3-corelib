package lolo.display
{
	/**
	 * 基本显示对象
	 * @author LOLO
	 */
	public interface IBaseSprite
	{
		/**
		 * 显示
		 */
		function show():void;
		
		/**
		 * 隐藏
		 */
		function hide():void;
		
		/**
		 * 当前如果为显示状态，将会切换到隐藏状态。<br/>
		 * 相反，如果为隐藏状态，将会切换到显示状态
		 */		
		function showOrHide():void;
		
		
		
		/**
		 * 当前是否已经显示
		 */
		function get showed():Boolean;
		
		/**
		 * 是否自动添加到显示对象、从显示对象中移除
		 */
		function get autoRemove():Boolean;
		function set autoRemove(value:Boolean):void;
		
		
		
		/**
		 * 实例名称
		 */
		function get name():String;
		function set name(value:String):void;
		//
	}
}