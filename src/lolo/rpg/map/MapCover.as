package lolo.rpg.map
{
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.rpg.RpgConstants;
	import lolo.utils.optimize.CachePool;
	
	/**
	 * 地图遮挡物
	 * @author LOLO
	 */
	public class MapCover extends Sprite
	{
		/**所在的地图*/
		private var _map:IRpgMap;
		/**正在加载的loader列表*/
		private var _loaderList:Array = [];
		/**加载失败的遮挡物的标记*/
		private var _loadErrorTags:Dictionary;
		
		/**屏幕显示区域*/
		private var _screenArea:Rectangle;
		
		
		
		public function MapCover(map:IRpgMap)
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			this.alpha = 0.4;
			
			_map = map;
			_screenArea = _map.getScreenArea();
		}
		
		
		/**
		 * 初始化
		 */
		public function init():void
		{
			clear();
			
			_loaderList = [];
			_loadErrorTags = new Dictionary();
			
			for(var i:int = 0; i < _map.info.covers.length; i++) {
				createLoader(_map.info.covers[i].id, _map.info.covers[i].point.x, _map.info.covers[i].point.y);
			}
		}
		
		
		/**
		 * 更新遮挡物状态，显示在屏幕内的遮挡物，隐藏超出屏幕的遮挡物
		 */
		public function updateCover():void
		{
			/*
			_screenArea = _map.getScreenArea();
			for(var i:int = 0; i < this.numChildren; i++) {
				setCoverVisible(this.getChildAt(i));
			}
			*/
		}
		
		
		/**
		 * 创建一个加载器
		 * @param id
		 */
		private function createLoader(id:int, x:int, y:int):void
		{
			var loader:Loader = new Loader();
			_loaderList.push(loader);
			loader.name = "c_" + id + "_" + x + "_" + y;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(new URLRequest(Common.getResUrl(Common.config.getUIConfig(RpgConstants.CN_MAP_COVER, _map.id, id))));
		}
		
		/**
		 * 清除一个加载器
		 * @param loader
		 */
		private function removeLoader(loader:Loader):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			try { loader.close(); }
			catch(error:Error) {}
			try { loader.unload(); }
			catch(error:Error) {}
			
			for(var i:int = 0; i < _loaderList.length; i++) {
				if(_loaderList[i] == loader) {
					_loaderList.splice(i, 1);
					return;
				}
			}
		}
		
		
		/**
		 * 加载成功
		 * @param event
		 */
		private function completeHandler(event:Event):void
		{
			var loader:Loader = event.target.loader;
			var bitmapData:BitmapData = (loader.content as Bitmap).bitmapData.clone();
			var arr:Array = loader.name.split("_");
			
			var cover:Bitmap = new Bitmap(bitmapData);
			cover.x = int(arr[2]);
			cover.y = int(arr[3]);
			this.addChild(cover);
			cover.name = "c" + arr[1];
			
			//setCoverVisible(cover);
			removeLoader(loader);
		}
		
		/**
		 * 加载错误
		 * @param event
		 */
		private function errorHandler(event:Event):void
		{
			var loader:Loader = event.target.loader;
			var name:String = loader.name;
			var arr:Array = name.split("_");
			removeLoader(loader);
			if(_loadErrorTags[name] == null) _loadErrorTags[name] = 1;
			if(_loadErrorTags[name] < 5) {
				TweenMax.delayedCall(5, createLoader, [arr[1], arr[2], arr[3]]);
			}
		}
		
		
		/**
		 * 设置遮挡物是否可见
		 * @param cover
		 */
		private function setCoverVisible(cover:DisplayObject):void
		{
			var rect:Rectangle = CachePool.getRectangle(cover.x, cover.y , cover.width, cover.height);
			cover.visible = _screenArea.intersects(rect);
			CachePool.recover(rect);
		}
		
		
		/**
		 * 清理
		 */
		public function clear():void
		{
			TweenMax.killDelayedCallsTo(createLoader);
			
			if(_loaderList != null) {
				var i:int;
				for(i = 0; i < _loaderList.length; i++) removeLoader(_loaderList[i]);
				_loaderList = null;
			}
			
			while(this.numChildren > 0) {
				(this.getChildAt(i) as Bitmap).bitmapData.dispose();
				this.removeChildAt(0);
			}
			
			_loadErrorTags = null;
		}
		//
	}
}