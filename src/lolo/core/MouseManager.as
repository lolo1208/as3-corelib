package lolo.core
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	import lolo.display.Animation;
	import lolo.display.IAnimation;
	import lolo.utils.optimize.PrerenderScheduler;

	/**
	 * 鼠标管理
	 * @author LOLO
	 */
	public class MouseManager implements IMouseManager
	{
		/**单例的实例*/
		private static var _instance:MouseManager;
		
		/**鼠标指针动画的帧频配置列表（默认为12）*/
		private var _fpsList:Dictionary;
		
		/**绑定样式的显示对象列表，以实例为key*/
		private var _bindStyleList:Dictionary;
		/**替代鼠标指针的动画*/
		private var _cursor:Animation;
		/**默认样式*/
		private var _defaultStyle:String;
		
		/**当前正在显示样式的目标*/
		private var _currentTarget:DisplayObject;
		/**当前样式*/
		private var _style:String;
		/**当前状态*/
		private var _state:String;
		
		/**是否启用自定义鼠标样式*/
		private var _enabled:Boolean;
		/**是否自动切换状态*/
		private var _autoSwitchState:Boolean = true;
		/**是否自动隐藏默认鼠标指针*/
		private var _autoHideDefaultCursor:Boolean = true;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():MouseManager
		{
			if(_instance == null) _instance = new MouseManager(new Enforcer());
			return _instance;
		}
		
		
		
		public function MouseManager(enforcer:Enforcer)
		{
			super();
			
			if(!enforcer) {
				throw new Error("请通过Common.mouse获取实例");
				return;
			}
			
			_fpsList = new Dictionary();
			var arr:Array = Common.config.getUIConfig("cursorAniFps").split(",");
			for(var i:int=0; i < arr.length; i++) {
				var arr2:Array = arr[i].split(":");
				_fpsList[arr2[0]] = uint(arr2[1]);
			}
			
			_bindStyleList = new Dictionary();
			_state = Constants.MOUSE_STATE_NORMAL;
			_cursor = new Animation();
			
			(Common.stage.getChildAt(0) as InteractiveObject).contextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
		}
		
		
		
		public function set defaultStyle(value:String):void
		{
			if(_style == _defaultStyle) style = value;//更新当前样式
			_defaultStyle = value;
		}
		
		public function get defaultStyle():String { return _defaultStyle; }
		
		
		
		public function set style(value:String):void
		{
			_style = value;
			update();
		}
		public function get style():String { return _style; }
		
		
		public function set state(value:String):void
		{
			_state = value;
			update();
		}
		public function get state():String { return _state; }
		
		
		
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			autoSwitchState = _autoSwitchState;
			
			if(_enabled) {
				if(_autoHideDefaultCursor) {
					Mouse.hide();
					stage_mouseMoveHandler();
					contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, stage_contextMenuSelectHandler);
				}
				update();
				Common.ui.addChildToLayer(_cursor, Constants.LAYER_NAME_ADORN);
			}
			else {
				Mouse.show();
				contextMenu.removeEventListener(ContextMenuEvent.MENU_SELECT, stage_contextMenuSelectHandler);
				Common.ui.removeChildToLayer(_cursor, Constants.LAYER_NAME_ADORN);
				_cursor.stop();
			}
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		
		
		/**
		 * 是否自动切换状态
		 */
		public function set autoSwitchState(value:Boolean):void
		{
			_autoSwitchState = value;
			
			if(_enabled && _autoSwitchState)
			{
				Common.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
				Common.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
				Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
				if(_state == null) stage_mouseUpHandler();
			}
			else
			{
				Common.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
				stage_mouseUpHandler();
			}
		}
		public function get autoSwitchState():Boolean { return _autoSwitchState; }
		
		
		
		
		
		public function get contextMenu():ContextMenu
		{
			return (Common.stage.getChildAt(0) as InteractiveObject).contextMenu;
		}
		
		/**
		 * 打开右键菜单事件
		 * @param event
		 */
		private function stage_contextMenuSelectHandler(event:ContextMenuEvent):void
		{
			if(_enabled && _autoHideDefaultCursor) Mouse.hide();
		}
		
		
		
		
		/**
		 * 更新显示内容（在 PrerenderScheduler 的回调中）
		 */		
		public function update():void
		{
			PrerenderScheduler.addCallback(prerender);
		}
		
		
		/**
		 * 即将进入渲染时的回调
		 */
		private function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			if(_enabled)
			{
				_cursor.sourceName = "ui.mouse." + _style + "." + _state;
				_cursor.play();
				
				var fps:uint = _fpsList[_cursor.sourceName];
				if(fps == 0) fps = 12;
				_cursor.fps = fps;
				
				if(!Animation.hasAnimation(_cursor.sourceName)) Mouse.show();
			}
			else {
				Mouse.show();
			}
		}
		
		
		
		/**
		 * 鼠标在舞台上按下
		 * @param event
		 */
		private function stage_mouseDownHandler(event:MouseEvent):void
		{
			_state = Constants.MOUSE_STATE_PRESS;
			update();
		}
		
		/**
		 * 鼠标在舞台上释放
		 * @param event
		 */
		private function stage_mouseUpHandler(event:MouseEvent=null):void
		{
			_state = Constants.MOUSE_STATE_NORMAL;
			update();
		}
		
		/**
		 * 鼠标在舞台上移动
		 * @param event
		 */
		private function stage_mouseMoveHandler(event:MouseEvent=null):void
		{
			_cursor.x = Common.stage.mouseX;
			_cursor.y = Common.stage.mouseY;
		}
		
		
		
		
		/**
		 * 绑定样式
		 * 当绑定目标发生对应的鼠标事件时，将会切换到对应的样式
		 * @param target 要绑定样式的目标
		 * @param style 对应的样式
		 * @param overEventType 鼠标移到目标上的事件类型
		 * @param outEventType 鼠标从目标上移开的事件类型
		 */
		public function bindStyle(target:DisplayObject, style:String, overEventType:String=null, outEventType:String=null):void
		{
			target.addEventListener((overEventType == null) ? MouseEvent.ROLL_OVER : overEventType, styleBingTarget_rollOverHandler);
			target.addEventListener((outEventType == null) ? MouseEvent.ROLL_OUT : outEventType, styleBingTarget_rollOutHandler);
			_bindStyleList[target] = style;
		}
		
		/**
		 * 解除样式绑定
		 * @param target 已绑定样式的目标
		 * @param overEventType 鼠标移到目标上的事件类型
		 * @param outEventType 鼠标从目标上移开的事件类型
		 */
		public function unbindStyle(target:DisplayObject, overEventType:String=null, outEventType:String=null):void
		{
			if(_currentTarget == target) {
				style = _defaultStyle;
				_currentTarget = null;
			}
			
			target.removeEventListener((overEventType == null) ? MouseEvent.ROLL_OVER : overEventType, styleBingTarget_rollOverHandler);
			target.removeEventListener((outEventType == null) ? MouseEvent.ROLL_OUT : outEventType, styleBingTarget_rollOutHandler);
			delete _bindStyleList[target];
		}
		
		
		/**
		 * 鼠标移到已绑定样式的目标上
		 * @param event
		 */
		private function styleBingTarget_rollOverHandler(event:MouseEvent):void
		{
			_currentTarget = event.currentTarget as DisplayObject;
			style = _bindStyleList[event.currentTarget];
		}
		
		/**
		 * 鼠标从已绑定样式的目标上移开
		 * @param event
		 */
		private function styleBingTarget_rollOutHandler(event:MouseEvent):void
		{
			_currentTarget = null;
			style = _defaultStyle;
		}
		
		
		
		
		public function set autoHideDefaultCursor(value:Boolean):void { _autoHideDefaultCursor = value; }
		public function get autoHideDefaultCursor():Boolean { return _autoHideDefaultCursor; }
		
		
		public function get cursor():IAnimation { return _cursor; }
		//
	}
}


class Enforcer {}