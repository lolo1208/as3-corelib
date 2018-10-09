package lolo.components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import lolo.core.Common;
	import lolo.utils.optimize.CachePool;
	import lolo.utils.optimize.PrerenderScheduler;

	/**
	 * 模态背景
	 * @author LOLO
	 */
	public class ModalBackground extends Sprite
	{
		/**颜色*/
		private var _color:uint = 0x0;
		
		
		
		/**
		 * 构造函数
		 * @param parent 父级容器
		 */
		public function ModalBackground(parent:DisplayObjectContainer)
		{
			super();
			this.alpha = 0.1;
			parent.addChildAt(this, 0);
			draw();
			
			Common.stage.addEventListener(Event.RESIZE, eventHandler);
			parent.addEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
		}
		
		
		
		/**
		 * 事件处理
		 * @param event
		 */
		private function eventHandler(event:Event):void
		{
			switch(event.type)
			{
				case Event.RESIZE:
					break;
				
				case MouseEvent.MOUSE_DOWN:
					Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, eventHandler);
					Common.stage.addEventListener(MouseEvent.MOUSE_UP, eventHandler);
					break;
				
				case MouseEvent.MOUSE_MOVE:
					break;
				
				case MouseEvent.MOUSE_UP:
					Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, eventHandler);
					Common.stage.removeEventListener(MouseEvent.MOUSE_UP, eventHandler);
					break;
			}
			draw();
		}
		
		
		
		
		/**
		 * 绘制矩形模态背景
		 */
		public function draw():void
		{
			PrerenderScheduler.addCallback(prerender, -9999);
		}
		
		
		/**
		 * 即将进入渲染时的回调
		 */
		private function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			if(parent == null) return;
			
			var p:Point = CachePool.getPoint();
			p = parent.globalToLocal(p);
			this.graphics.clear();
			this.graphics.beginFill(_color);
			this.graphics.drawRect(
				p.x - 50, p.y - 50,//在周围多绘制50像素的缓冲区
				Common.ui.stageWidth + 100,
				Common.ui.stageHeight + 100
			);
			this.graphics.endFill();
			CachePool.recover(p);
		}
		
		
		
		/**
		 * 颜色
		 */
		public function set color(value:uint):void
		{
			_color = value;
			draw();
		}
		public function get color():uint { return _color; }
		
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		public function dispose():void
		{
			PrerenderScheduler.removeCallback(prerender);
			Common.stage.removeEventListener(Event.RESIZE, eventHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, eventHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, eventHandler);
			
			if(parent != null) {
				parent.removeEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
				parent.removeChild(this);
			}
		}
		//
	}
}