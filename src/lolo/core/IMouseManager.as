package lolo.core
{
	import flash.display.DisplayObject;
	import flash.ui.ContextMenu;
	
	import lolo.display.IAnimation;

	/**
	 * 鼠标管理（自定义动画源名称为 “ui.mouse.样式.状态”）
	 * @author LOLO
	 */
	public interface IMouseManager
	{
		
		/**
		 * 默认样式
		 */
		function set defaultStyle(value:String):void;
		function get defaultStyle():String;
		
		/**
		 * 当前样式
		 */
		function set style(value:String):void;
		function get style():String;
		
		/**
		 * 当前状态
		 */
		function set state(value:String):void;
		function get state():String;
		
		
		
		
		
		/**
		 * 是否启用自定义鼠标样式
		 */
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
		
		/**
		 * 是否自动切换状态
		 */
		function set autoSwitchState(value:Boolean):void;
		function get autoSwitchState():Boolean;
		
		/**
		 * 是否自动隐藏默认鼠标指针
		 */
		function set autoHideDefaultCursor(value:Boolean):void;
		function get autoHideDefaultCursor():Boolean;
		
		
		
		
		/**
		 * 显示更新
		 */		
		function update():void;
		
		/**
		 * 替代鼠标指针的动画
		 */
		function get cursor():IAnimation;
		
		/**
		 * 右键菜单
		 */
		function get contextMenu():ContextMenu;
		
		
		
		
		/**
		 * 绑定样式
		 * 当绑定目标发生鼠标事件时，将会切换到对应的样式
		 * @param target 要绑定样式的目标
		 * @param style 对应的样式
		 * @param overEventType 鼠标移到目标上的事件类型（默认为MouseEvent.ROLL_OVER）
		 * @param outEventType 鼠标从目标上移开的事件类型（默认为MouseEvent.ROLL_OUT）
		 */
		function bindStyle(target:DisplayObject, style:String, overEventType:String=null, outEventType:String=null):void;
		
		/**
		 * 解除样式绑定
		 * @param target 已绑定样式的目标
		 * @param overEventType 鼠标移到目标上的事件类型（默认为MouseEvent.ROLL_OVER）
		 * @param outEventType 鼠标从目标上移开的事件类型（默认为MouseEvent.ROLL_OUT）
		 */
		function unbindStyle(target:DisplayObject, overEventType:String=null, outEventType:String=null):void;
		//
	}
}