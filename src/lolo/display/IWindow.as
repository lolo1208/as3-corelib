package lolo.display
{
	import lolo.ui.IWindowLayout;

	/**
	 * 窗口
	 * @author LOLO
	 */
	public interface IWindow extends IModule, IWindowLayout
	{
		/**
		 * 是否自动隐藏。<br/>
		 * 如果该 Window 已显示，再次调用 Common.ui.openWindow(this) 时，<br/>
		 * 如果该值为 true，将会自动隐藏；<br/>
		 * 如果该值为 false（默认值），将会把该Window调整至最上层。
		 */
		function set autoHide(value:Boolean):void;
		function get autoHide():Boolean;
		
		
		/**
		 * 互斥的，不能同时存在的窗口 moduleName 列表。<br/>
		 * 如果该值为 <b>null</b>（默认值），表示该窗口与所有窗口都是互斥关系（comboList 中的除外）。<br/>
		 * 如果该值为 <b>[]</b>（空数组），表示该窗口与所有窗口都不是互斥关系。
		 */
		function set excludeList(value:Array):void;
		function get excludeList():Array;
		
		
		/**
		 * 可以与该窗口组合的窗口 moduleName 列表
		 */
		function set comboList(value:Array):void;
		function get comboList():Array;
		//
	}
}