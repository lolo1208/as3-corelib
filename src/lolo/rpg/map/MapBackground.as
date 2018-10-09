package lolo.rpg.map
{
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.display.Animation;
	import lolo.rpg.RpgConstants;
	import lolo.utils.logging.Logger;
	import lolo.utils.optimize.CachePool;
	import lolo.utils.optimize.ConsumeBalancer;
	
	/**
	 * 地图背景
	 * @author LOLO
	 */
	public class MapBackground extends Sprite
	{
		/**在图块完全加载完成前，显示的马赛克缩略图*/
		private var _thumbnail:Bitmap;
		/**所在的地图*/
		private var _map:IRpgMap;
		
		/**正在加载的loader列表*/
		private var _loaderList:Array;
		/**已经加载完毕的图块标记*/
		private var _tags:Dictionary;
		
		/**最终渲染的清晰图*/
		private var _bg:Bitmap;
		
		/**鼠标点击地图时播放的动画*/
		private var _mouseDownAni:Animation;
		
		
		
		public function MapBackground(map:IRpgMap)
		{
			super();
			this.mouseChildren = false;
			
			_map = map;
		}
		
		
		public function init(thumbnailsData:BitmapData):void
		{
			clear();
			
			//创建并显示马赛克缩略图
			_thumbnail = new Bitmap(thumbnailsData);
			_thumbnail.width = _map.info.mapWidth;
			_thumbnail.height = _map.info.mapHeight;
			this.addChild(_thumbnail);
			
			//创建清晰图，等待图块加载
			_bg = new Bitmap();
			_bg.bitmapData = new BitmapData(_map.info.mapWidth, _map.info.mapHeight, true, 0);
			this.addChild(_bg);
			
			_loaderList = [];
			_tags = new Dictionary();
			loadChunk();
		}
		
		
		/**
		 * 加载图块
		 * @param isMax 值为false时，加载当前屏幕范围内的图块，值为true时，加载整个地图的图块
		 */
		private function loadChunk(isMax:Boolean=false):void
		{
			TweenMax.killDelayedCallsTo(loadChunk);
			if(_thumbnail == null || _loaderList == null) return;
			
			var cw:uint = _map.info.chunkWidth;
			var ch:uint = _map.info.chunkHeight;
			
			var screenArea:Rectangle = _map.getScreenArea();
			var x:int;
			var startX:int = isMax ? 0 : int(screenArea.x / cw);
			var maxX:int = Math.ceil((screenArea.x + screenArea.width) / cw);
			if(isMax || maxX > _map.info.hChunkCount) maxX = _map.info.hChunkCount;
			
			var y:int = isMax ? 0 : int(screenArea.y / ch);
			var maxY:int = Math.ceil((screenArea.y + screenArea.height) / ch);
			if(isMax || maxY > _map.info.vChunkCount) maxY = _map.info.vChunkCount;
			
			for(; y < maxY; y++) {
				for(x = startX; x < maxX; x++)
				{
					//最多3个图块同时加载
					if(_loaderList.length >= 2) return;
					
					//一张图块最多加载（失败）5次
					var tag:Object = _tags[x + "_" + y];
					if(tag == null) tag = _tags[x + "_" + y] = { isLoad:false, num:5 };
					if(tag.isLoad) continue;
					
					//尝试5次，仍无法加载，将该图块的马赛克图绘制到清晰图上
					if(tag.num <= 0)
					{
						var ox:int = cw * x;
						var oy:int = ch * y;
						
						var w:int = _map.info.mapWidth - ox;
						if(w > cw) w = cw;
						var h:int = _map.info.mapHeight - oy;
						if(h > ch) h = ch;
						
						var bitmapData:BitmapData = new BitmapData(w, h);
						bitmapData.draw(this, new Matrix(1, 0, 0, 1, -ox, -oy));
						ConsumeBalancer.addCallback(copyPixels, bitmapData, CachePool.getPoint(ox, oy));
						continue;
					}
					
					//加载图块
					tag.isLoad = true;
					tag.num--;
					
					var loader:ChunkLoader = new ChunkLoader(x, y);
					_loaderList.push(loader);
					loader.addEventListener(ChunkLoader.LOAD_COMPLETE, completeHandler);
					loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
					loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
					loader.load(new URLRequest(Common.getResUrl(Common.config.getUIConfig(RpgConstants.CN_MAP_CHUNK, _map.id, x, y))));
				}
			}
			
			if(!isMax) {
				loadChunk(true);
			}
			else if(_loaderList.length == 0) {//全部加载完毕了
				_loaderList = null;
				_tags = null;
				trace("[RPG] 地图[" + _map.id + "]背景图块全部加载完毕！");
				TweenMax.delayedCall(3, delayedRemoveThumbnail);
			}
		}
		
		private function delayedRemoveThumbnail():void
		{
			if(_thumbnail != null) {
				this.removeChild(_thumbnail);
				_thumbnail = null;
			}
		}
		
		
		/**
		 * 加载成功
		 * @param event
		 */
		private function completeHandler(event:Event):void
		{
			var loader:ChunkLoader = event.target as ChunkLoader;
			ConsumeBalancer.addCallback(
				copyPixels, loader.bitmapData,
				CachePool.getPoint(_map.info.chunkWidth * loader.x, _map.info.chunkHeight * loader.y)
			);
			removeLoader(loader);
			loadChunk();
		}
		
		/**
		 * 将图块的像素设置到大背景图上
		 * @param bitmapData
		 * @param offsets
		 */
		private function copyPixels(bitmapData:BitmapData, offsets:Point):void
		{
			if(_bg != null) {
				_bg.bitmapData.copyPixels(bitmapData, bitmapData.rect, offsets);
			}
			CachePool.recover(offsets);
			bitmapData.dispose();
		}
		
		
		/**
		 * 加载错误
		 * @param event
		 */
		private function errorHandler(event:IOErrorEvent):void
		{
			var loader:ChunkLoader = event.target as ChunkLoader;
			_tags[loader.x + "_" + loader.y].isLoad = false;
			
			removeLoader(loader);
			TweenMax.delayedCall(5, loadChunk);
			
			Logger.addLog("[RPG] 加载图块错误！错误信息：\n" + event.text, Logger.LOG_TYPE_INFO);
		}
		
		
		/**
		 * 暂停或继续加载图块
		 * @param pause [ true:暂停加载，false:继续加载 ]
		 */
		public function pauseOrContinueLoadChunk(pause:Boolean):void
		{
			if(_loaderList == null) return;//图块全部已经加载完了
			
			if(pause) {
				TweenMax.killDelayedCallsTo(loadChunk);
				while(_loaderList.length > 0) {
					var loader:ChunkLoader = _loaderList[_loaderList.length - 1];
					_tags[loader.x + "_" + loader.y].isLoad = false;
					removeLoader(loader);
				}
			}
			else {
				loadChunk();
			}
		}
		
		
		/**
		 * 清除一个加载器
		 * @param loader
		 */
		private function removeLoader(loader:ChunkLoader):void
		{
			loader.removeEventListener(ChunkLoader.LOAD_COMPLETE, completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.clear();
			
			if(_loaderList == null) return;
			
			for(var i:int = 0; i < _loaderList.length; i++) {
				if(_loaderList[i] == loader) {
					_loaderList.splice(i, 1);
					return;
				}
			}
		}
		
		
		/**
		 * 播放鼠标按下的动画
		 */
		public function playMouseDownAnimation():void
		{
			if(_mouseDownAni == null)
				_mouseDownAni = new Animation(Common.config.getUIConfig(RpgConstants.CN_ANI_MAP_MOUSE_DOWN));
			
			_mouseDownAni.x = mouseX;
			_mouseDownAni.y = mouseY;
			if(_mouseDownAni.parent == null) this.addChild(_mouseDownAni);
			_mouseDownAni.play(1, 1, 0, _mouseDownAni.dispose);
		}
		
		
		
		
		/**
		 * 清理
		 */
		public function clear():void
		{
			TweenMax.killDelayedCallsTo(loadChunk);
			TweenMax.killDelayedCallsTo(delayedRemoveThumbnail);
			
			if(_loaderList != null) {
				while(_loaderList.length > 0) removeLoader(_loaderList[_loaderList.length - 1]);
				_loaderList = null;
			}
			_tags = null;
			
			if(_thumbnail != null) {
				if(_thumbnail.parent) _thumbnail.parent.removeChild(_thumbnail);
				//_thumbnail.bitmapData.dispose();
				_thumbnail = null;
			}
			
			if(_bg != null) {
				if(_bg.parent) _bg.parent.removeChild(_bg);
				if(_bg.bitmapData) _bg.bitmapData.dispose();
				_bg = null;
			}
		}
		//
	}
}