package lolo.utils.optimize
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import lolo.core.Common;
	import lolo.utils.DisplayUtil;

	/**
	 * 用于管理场景与鼠标的交互
	 * @author LOLO
	 */
	public class InteractiveScene
	{
		/**与鼠标交互的目标（通常为背景图）*/
		private var _target:InteractiveObject;
		/**拖动的容器*/
		private var _dragContainer:InteractiveObject;
		
		/**是否启用与鼠标交互*/
		private var _mouseEnabled:Boolean;
		/**是否可以拖动*/
		private var _dragEnabled:Boolean;
		
		/**当前正在和鼠标交互的对象*/
		private var _mouseObj:IInteractiveObject;
		/**鼠标在该对象上按下*/
		private var _mouseDownObj:IInteractiveObject;
		
		/**鼠标拖拽相关信息{ x/y:鼠标上次更新位置, t:鼠标按下那刻的时间 }*/
		private var _mouseInfo:Object;
		
		/**鼠标拖动容器时，回调的函数。draggingHandler(x:int, y:int)*/
		public var draggingHandler:Function;
		/**鼠标在target上按下鼠标时（没有点到IInteractiveObject）的回调*/
		public var targetMouseDownHandler:Function;
		
		
		
		
		/**
		 * 构造函数
		 * @param target 与鼠标交互的目标（通常为背景图）
		 * @param dragContainer 拖动的容器
		 * @param draggingHandler 鼠标拖动容器时，回调的函数。draggingHandler(x:int, y:int)
		 * @param targetMouseDownHandler 鼠标在target上按下鼠标时（没有点到IInteractiveObject）的回调
		 */
		public function InteractiveScene(target:InteractiveObject,
										 dragContainer:InteractiveObject = null,
										 draggingHandler:Function = null,
										 targetMouseDownHandler:Function=null):void
		{
			_target = target;
			_dragContainer = dragContainer;
			this.draggingHandler = draggingHandler;
			this.targetMouseDownHandler = targetMouseDownHandler;
			
			_mouseEnabled = (target != null);
			_dragEnabled = (dragContainer != null);
			_mouseInfo = { x:0, y:0, t:0 };
		}
		
		
		
		
		/**
		 * 鼠标在目标（背景）上移动
		 * @param event
		 */
		private function target_mouseMoveHandler(event:MouseEvent):void
		{
			PrerenderScheduler.addCallback(checkObjectFromMousePoint);
		}
		
		/**
		 * 在鼠标位置检查是有IInteractiveObject
		 */
		private function checkObjectFromMousePoint():void
		{
			//拿到鼠标下的所有显示对象
			var p:Point = CachePool.getPoint(Common.stage.mouseX, Common.stage.mouseY);
			var disObjList:Array = Common.stage.getObjectsUnderPoint(p);
			CachePool.recover(p);
			disObjList.reverse();
			
			//取出IInteractiveObject列表
			var list:Vector.<IInteractiveObject> = new Vector.<IInteractiveObject>();
			var i:int, disObj:DisplayObject, obj:IInteractiveObject;
			for(i = 0; i < disObjList.length; i++)
			{
				//从显示对象开始，往父级一直找，直到找到Avatar对象或舞台为止
				disObj = disObjList[i] as DisplayObject;
				
				while(disObj != null)
				{
					obj = disObj as IInteractiveObject;
					if(obj != null) {
						list.push(obj);
						break;
					}
					disObj = disObj.parent;
				}
			}
			
			for(i = 0; i < list.length; i++)
			{
				obj = list[i];
				if(!obj.interactiveEnabled) continue;
				if(obj.isTransparent && DisplayUtil.fullTransparent(obj as DisplayObject)) continue;
				
				if(obj != _mouseObj) {
					if(_mouseObj != null) _mouseObj.onMoveOut();
					_mouseObj = obj;
					_mouseObj.onMoveOver();
				}
				return;
			}
			
			target_mouseOutHandler();
		}
		
		
		/**
		 * 鼠标从目标（背景）上移开
		 * @param event
		 */
		private function target_mouseOutHandler(event:MouseEvent=null):void
		{
			PrerenderScheduler.removeCallback(checkObjectFromMousePoint);
			if(_mouseObj != null) {
				_mouseObj.onMoveOut();
				_mouseObj = null;
			}
		}
		
		
		/**
		 * 鼠标在目标（背景）上按下
		 * @param event
		 */
		private function target_mouseDownHandler(event:MouseEvent):void
		{
			checkObjectFromMousePoint();//检查 _mouseObj 是否还存在
			
			if(_mouseObj != null) {
				_mouseDownObj = _mouseObj;//标记好鼠标按下时的对象
				Common.stage.addEventListener(MouseEvent.MOUSE_UP, checkObjectClickHandler);
				_mouseObj.onMoveDown();
			}
			else {
				if(targetMouseDownHandler != null) targetMouseDownHandler();
			}
		}
		
		
		/**
		 * 鼠标在舞台释放，检测是否触发了 CLICK 事件
		 * @param event
		 */
		private function checkObjectClickHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, checkObjectClickHandler);
			if(_mouseObj == null && _mouseDownObj == null) return;
			
			if(_mouseObj == _mouseDownObj) {
				_mouseDownObj.onClick();
				if(_mouseDownObj != null) _mouseDownObj.onMoveOver();
				_mouseDownObj = null;
			}
			else {
				_mouseDownObj.onMoveOut();
				_mouseObj = _mouseDownObj = null;
			}
		}
		
		
		
		
		/**
		 * 鼠标拖动容器相关处理
		 * @param event
		 */
		private function dragContainer_mouseEventHandler(event:MouseEvent):void
		{
			switch(event.type)
			{
				case MouseEvent.MOUSE_DOWN:
					if(_mouseDownObj != null && _mouseDownObj.isCancelDrag) return;
					
					_mouseInfo.x = _dragContainer.mouseX;
					_mouseInfo.y = _dragContainer.mouseY;
					_mouseInfo.t = getTimer();
					_dragContainer.addEventListener(MouseEvent.MOUSE_MOVE, dragContainer_mouseEventHandler);
					Common.stage.addEventListener(MouseEvent.MOUSE_UP, dragContainer_mouseEventHandler);
					break;
				
				case MouseEvent.MOUSE_MOVE:
					PrerenderScheduler.addCallback(dragging, -1);
					break;
				
				case MouseEvent.MOUSE_UP:
					PrerenderScheduler.removeCallback(dragging);
					_dragContainer.removeEventListener(MouseEvent.MOUSE_MOVE, dragContainer_mouseEventHandler);
					Common.stage.removeEventListener(MouseEvent.MOUSE_UP, dragContainer_mouseEventHandler);
					break;
			}
		}
		
		
		/**
		 * 鼠标拖拽中
		 */
		private function dragging():void
		{
			//避免误拖
			if((getTimer() - _mouseInfo.t) < 300
				&& Math.abs(_mouseInfo.x) < 10
				&& Math.abs(_mouseInfo.y) < 10)
			{
				return;
			}
			
			if(_mouseDownObj != null && _mouseDownObj.isCancelEvent)
			{
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, checkObjectClickHandler);
				(_mouseDownObj == _mouseObj) ? _mouseDownObj.onMoveOver() : _mouseDownObj.onMoveOut();
				_mouseDownObj = null;
			}
			
			if(draggingHandler != null) {
				draggingHandler(
					_dragContainer.mouseX - _mouseInfo.x,
					_dragContainer.mouseY - _mouseInfo.y
				);
			}
			
			_mouseInfo.x = _dragContainer.mouseX;
			_mouseInfo.y = _dragContainer.mouseY;
		}
		
		
		
		/**
		 * 是否启用检测与target（背景）交互的IInteractiveObject
		 * @param value
		 */
		public function set mouseEnabled(value:Boolean):void
		{
			_mouseEnabled = value;
			
			if(value) {
				_target.addEventListener(MouseEvent.MOUSE_MOVE, target_mouseMoveHandler);
				_target.addEventListener(MouseEvent.MOUSE_OUT, target_mouseOutHandler);
			}
			else {
				_target.removeEventListener(MouseEvent.MOUSE_MOVE, target_mouseMoveHandler);
				_target.removeEventListener(MouseEvent.MOUSE_OUT, target_mouseOutHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, checkObjectClickHandler);
				target_mouseOutHandler();
			}
		}
		public function get mouseEnabled():Boolean { return _mouseEnabled; }
		
		
		
		/**
		 * 是否启用拖动 dragContainer
		 */
		public function set dragEnabled(value:Boolean):void
		{
			_dragEnabled = value;
			if(value) {
				_dragContainer.addEventListener(MouseEvent.MOUSE_DOWN, dragContainer_mouseEventHandler);
			}
			else {
				_dragContainer.removeEventListener(MouseEvent.MOUSE_DOWN, dragContainer_mouseEventHandler);
				_dragContainer.removeEventListener(MouseEvent.MOUSE_MOVE, dragContainer_mouseEventHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, dragContainer_mouseEventHandler);
			}
		}
		public function get dragEnabled():Boolean { return _dragEnabled; }
		
		
		
		
		/**
		 * 当前正在和鼠标交互的对象
		 */
		public function set mouseObj(value:IInteractiveObject):void { _mouseObj = value; }
		public function get mouseObj():IInteractiveObject { return _mouseObj; }
		
		
		
		
		/**
		 * 启动
		 */
		public function startup():void
		{
			_target.addEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
			mouseEnabled = _mouseEnabled;
			dragEnabled = _dragEnabled;
		}
		
		
		/**
		 * 重置
		 */
		public function reset():void
		{
			_target.removeEventListener(MouseEvent.MOUSE_DOWN, target_mouseDownHandler);
			PrerenderScheduler.removeCallback(checkObjectFromMousePoint);
			PrerenderScheduler.removeCallback(dragging);
			
			if(_mouseObj != null) {
				_mouseObj.onMoveOut();
				_mouseObj = null;
			}
			if(_mouseDownObj != null) {
				_mouseDownObj.onMoveOut();
				_mouseDownObj = null;
			}
			
			if(_mouseEnabled) {
				this.mouseEnabled = false;
				_mouseEnabled = true;
			}
			
			if(_dragEnabled) {
				this.dragEnabled = false;
				_dragEnabled = true;
			}
		}
		//
	}
}