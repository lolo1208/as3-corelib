package lolo.display
{
	import flash.events.Event;
	
	import lolo.core.Common;
	
	/**
	 * 窗口
	 * @author LOLO
	 */
	public class Window extends Module implements IWindow
	{
		/**是否自动隐藏*/
		protected var _autoHide:Boolean;
		/**互斥的，不能同时存在的窗口moduleName列表*/
		protected var _excludeList:Array;
		/**可以与该窗口组合的窗口moduleName列表*/
		protected var _comboList:Array;
		
		/**布局方向*/
		protected var _layoutDirection:String = "horizontal";
		/**布局索引*/
		protected var _layoutIndex:int;
		/**组合布局时，与下一个窗口的间距*/
		protected var _layoutGap:int;
		
		
		
		
		public function Window()
		{
			super();
			
			_excludeList = null;
			_comboList = [];
		}
		
		
		
		
		/**
		 * 关闭窗口
		 * @param event
		 */
		protected function closeWindow(event:Event=null):void
		{
			Common.ui.closeWindow(this);
		}
		
		override public function hide():void
		{
			if(!_showed) return;
			super.hide();
			
			closeWindow();
		}
		
		
		public function set autoHide(value:Boolean):void { _autoHide = value; }
		public function get autoHide():Boolean { return _autoHide; }
		
		public function set excludeList(value:Array):void { _excludeList = value; }
		public function get excludeList():Array { return _excludeList; }
		
		public function set comboList(value:Array):void { _comboList = value; }
		public function get comboList():Array { return _comboList; }
		
		
		
		public function get layoutWidth():uint { return width; }
		
		public function get layoutHeight():uint { return height; }
		
		public function set layoutDirection(value:String):void { _layoutDirection = value; }
		public function get layoutDirection():String { return _layoutDirection; }
		
		public function set layoutIndex(value:int):void { _layoutIndex = value; }
		public function get layoutIndex():int { return _layoutIndex; }
		
		public function set layoutGap(value:int):void { _layoutGap = value; }
		public function get layoutGap():int { return _layoutGap; }
		//
	}
}