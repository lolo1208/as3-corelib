package lolo.effects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	
	/**
	 * 迷雾
	 * @author LOLO
	 */
	public class Fog extends Bitmap
	{
		/**容器*/
		private var _container:Sprite;
		/**已经显示区域的容器（块列表）*/
		private var _showAreaC:Sprite;
		/**迷雾的总宽度*/
		private var _fogWidth:uint;
		/**迷雾的总高度*/
		private var _fogHeight:uint;
		/**块的宽度*/
		private var _tileWidht:uint;
		/**块的高度*/
		private var _tileHeight:uint;
		/**块缓冲池*/
		private var _tilePool:Vector.<Shape>;
		
		
		/**
		 * 构造一个迷雾
		 * @param width 
		 * @param height
		 * @param tileWidht
		 * @param tileHeight
		 */
		public function Fog(fogWidth:uint, fogHeight:uint, tileWidht:uint, tileHeight:uint)
		{
			super();
			_tilePool = new Vector.<Shape>();
			_fogWidth = fogWidth;
			_fogHeight = fogHeight;
			_tileWidht = tileWidht;
			_tileHeight = tileHeight;
			
			var data:BitmapData = new BitmapData(_fogWidth, _fogHeight, true, 0xFF000000);
			this.bitmapData = data;
			this.alpha = 0.7;
			
			_showAreaC = new Sprite();
			_showAreaC.blendMode = BlendMode.ERASE;
			_showAreaC.filters = [new BlurFilter(tileWidht, tileHeight)];
			
			_container = new Sprite();
			_container.mouseChildren = _container.mouseEnabled = false;
			_container.blendMode = BlendMode.LAYER;
			
			addEventListener(Event.ADDED, addedHandler);
		}
		
		
		
		/**
		 * 被添加到显示列表中时
		 * @param event
		 */
		private function addedHandler(event:Event):void
		{
			if(parent != null && parent != _container) {
				parent.addChild(_container);
				_container.addChild(this);
				_container.addChild(_showAreaC);
			}
		}
		
		
		
		/**
		 * 设置一个块的显示和隐藏
		 * @param x 块的水平编号
		 * @param y 块的垂直编号
		 * @param isShow 是否显示
		 */
		public function setTile(x:int, y:int, isShow:Boolean):void
		{
			var name:String = "t" + x + "_" + y;
			var tile:Shape = _showAreaC.getChildByName(name) as Shape;//目标块
			
			if(isShow) {
				if(tile == null) {
					tile = getTile();
					tile.graphics.clear();
					tile.graphics.beginFill(0);
					tile.graphics.drawEllipse(-_tileWidht / 2, -_tileHeight / 2, _tileWidht * 2, _tileHeight * 2);
					tile.graphics.endFill();
					tile.name = name;
					tile.x = _tileWidht * x;
					tile.y = _tileWidht * y;
					_showAreaC.addChild(tile);
				}
			}
			else {
				if(tile != null) {
					_tilePool.push(_showAreaC.removeChild(tile));
				}
			}
		}
		
		
		
		/**
		 * 指定的块是否已经存在
		 * @param x
		 * @param y
		 * @return 
		 */
		public function hasTile(x:int, y:int):Boolean
		{
			return _showAreaC.getChildByName("t" + x + "_" + y) != null;
		}
		
		
		
		/**迷雾的总宽度*/
		public function get fogWidth():uint { return _fogWidth; }
		/**迷雾的总高度*/
		public function get fogHeight():uint { return _fogHeight; }
		
		/**块的宽度*/
		public function get tileWidht():uint { return _tileWidht; }
		/**块的高度*/
		public function get tileHeight():uint { return _tileHeight; }
		
		
		
		
		/**
		 * 丢弃时需要调用该方法
		 */
		public function clear():void
		{
			
		}
		
		
		
		/**
		 * 在池中获取一个块
		 * @return 
		 */
		private function getTile():Shape
		{
			if(_tilePool.length > 0) return _tilePool.pop();
			return new Shape();
		}
		//
	}
}