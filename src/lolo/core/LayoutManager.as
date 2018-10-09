package lolo.core
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import lolo.utils.logging.Logger;
	import lolo.utils.optimize.CachePool;
	import lolo.utils.optimize.PrerenderScheduler;
	

	/**
	 * 布局管理
	 * @author LOLO
	 */
	public class LayoutManager implements ILayoutManager
	{
		/**单例的实例*/
		private static var _instance:LayoutManager;
		
		
		/**需要根据舞台尺寸调整位置的显示对象列表*/
		private var _stageLayoutList:Dictionary;
		
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():LayoutManager
		{
			if(_instance == null) _instance = new LayoutManager(new Enforcer());
			return _instance;
		}
		
		
		
		public function LayoutManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过 Common.layout 获取实例");
				return;
			}
			
			_stageLayoutList = new Dictionary();
			Common.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
		}
		
		
		
		/**
		 * 舞台尺寸有改变
		 * @param event
		 */
		private function stage_resizeHandler(event:Event):void
		{
			PrerenderScheduler.addCallback(prerender);
		}
		
		/**
		 * 即将进入渲染时的回调
		 */
		private function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			
			for(var target:* in _stageLayoutList)
				if(_stageLayoutList[target].enabled)
					stageLayout(target, _stageLayoutList[target].args);
		}
		
		
		
		public function addStageLayout(target:DisplayObject, args:Object):void
		{
			_stageLayoutList[target] = { args:args, enabled:true };
			stageLayout(target);
		}
		
		
		public function stageLayout(target:DisplayObject, args:Object=null):void
		{
			var p:Point = getStageLayout(target, args);
			if(p != null) {
				target.x = p.x;
				target.y = p.y;
				CachePool.recover(p);
			}
			else {
				Logger.addLog("[LFW] 指定的target: " + target.toString() + " 并没有在 LayoutManager 中注册", Logger.LOG_TYPE_WARN);
			}
		}
		
		
		public function removeStageLayout(target:DisplayObject):void
		{
			delete _stageLayoutList[target];
		}
		
		
		public function getStageLayout(target:DisplayObject, args:Object=null):Point
		{
			if(args == null) args = _stageLayoutList[target].args;
			if(args == null) return null;
			
			var width:int = (args.width != null) ? args.width : target.width;
			var height:int = (args.height != null) ? args.height : target.height;
			var p:Point = CachePool.getPoint();
			
			if(args.x != null) {//按百分比设置位置
				p.x = Common.ui.stageWidth * args.x;
			}
			else if(args.paddingRight != null) {//靠右边对齐
				p.x = Common.ui.stageWidth - width - args.paddingRight;
			}
			else if(args.cancelH == null) {//居中舞台
				p.x = Common.ui.stageWidth - width >> 1;
				if(args.offsetX != null) p.x += args.offsetX;
			}
			else {//无需改变位置
				p.x = target.x;
			}
			
			if(args.y != null) {
				p.y = Common.ui.stageHeight * args.y;
			}
			else if(args.paddingBottom != null) {
				p.y = Common.ui.stageHeight - height - args.paddingBottom;
			}
			else if(args.cancelV == null) {
				p.y = Common.ui.stageHeight - height >> 1;
				if(args.offsetY != null) p.y += args.offsetY;
			}
			else {
				p.y = target.y;
			}
			
			p.x = Math.round(p.x);
			p.y = Math.round(p.y);
			
			return p;
		}
		
		
		public function setStageLayoutEnabled(target:DisplayObject, enabled:Boolean):void
		{
			_stageLayoutList[target].enabled = enabled;
		}
		
		
		public function toStageCenter(target:DisplayObject, width:uint=0, height:uint=0):void
		{
			if(width == 0) width = target.width;
			if(height == 0) height = target.height;
			target.x = Common.ui.stageWidth - width >> 1;
			target.y = Common.ui.stageHeight - height >> 1;
		}
		//
	}
}


class Enforcer {}