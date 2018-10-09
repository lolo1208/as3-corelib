package lolo.ui
{
	import lolo.display.IContainer;
	/**
	 * 加载条
	 * @author LOLO
	 */
	public interface ILoadBar extends IContainer
	{
		/**
		 * 是否侦听Common.loader资源加载事件
		 */
		function set isListener(value:Boolean):void;
		function get isListener():Boolean;
		
		
		/**
		 * 是否自动显示或隐藏
		 */
		function set autoShow(value:Boolean):void;
		function get autoShow():Boolean;
		
		
		/**
		 * 显示文本的内容
		 */
		function set text(value:String):void;
		function get text():String;
		
		
		/**
		 * 进度，0~1
		 */
		function set progress(value:Number):void;
		function get progress():Number;
		
		
		/**
		 * 模态背景的透明度，0~1
		 */
		function set modalTransparency(value:Number):void;
		function get modalTransparency():Number;
		//
	}
}