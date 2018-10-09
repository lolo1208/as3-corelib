package lolo.display
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lolo.utils.optimize.CachePool;
	

	/**
	 * 位图显示对象九切片数据<br/>
	 * 该数据会被缓存起来，可以创建对应的 Scale9Bitmap 实例
	 * @author LOLO
	 */
	public class Scale9BitmapData
	{
		/**原始图像数据*/
		private var _bitmapData:BitmapData;
		/**九切片中间的格子*/
		private var _grid:Rectangle;
		
		/**左上的图像数据*/
		private var _topLeft:BitmapData;
		/**中上的图像数据*/
		private var _topCenter:BitmapData;
		/**右上的图像数据*/
		private var _topRight:BitmapData;
		
		/**左中的图像数据*/
		private var _middleLeft:BitmapData;
		/**中间的图像数据*/
		private var _middleCenter:BitmapData;
		/**右中的图像数据*/
		private var _middleRight:BitmapData;
		
		/**左下的图像数据*/
		private var _bottomLeft:BitmapData;
		/**下中的图像数据*/
		private var _bottomCenter:BitmapData;
		/**右下的图像数据*/
		private var _bottomRight:BitmapData;
		
		
		
		
		public function Scale9BitmapData(bitmapData:BitmapData=null, grid:Rectangle=null)
		{
			if(bitmapData != null && grid != null)
				parseData(bitmapData, grid);
		}
		
		
		/**
		 * 将传入的位图数据解析成九切片数据
		 * @param texture
		 * @param grid
		 * @return 
		 */
		public function parseData(bitmapData:BitmapData, grid:Rectangle):void
		{
			_bitmapData = bitmapData;
			_grid = grid;
			var destPoint:Point = CachePool.getPoint();
			var sourceRect:Rectangle = CachePool.getRectangle();
			
			
			_topLeft = new BitmapData(
				grid.x,
				grid.y,
				true, 0
			);
			sourceRect.setTo(
				0,
				0,
				_topLeft.width,
				_topLeft.height
			);
			_topLeft.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_topCenter = new BitmapData(
				grid.width,
				grid.y,
				true, 0
			);
			sourceRect.setTo(
				grid.x,
				0,
				_topCenter.width,
				_topCenter.height
			);
			_topCenter.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_topRight = new BitmapData(
				bitmapData.width - grid.x - grid.width,
				grid.y,
				true, 0
			);
			sourceRect.setTo(
				grid.x + grid.width,
				0,
				_topRight.width,
				_topRight.height
			);
			_topRight.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_middleLeft = new BitmapData(
				grid.x,
				grid.height,
				true, 0
			);
			sourceRect.setTo(
				0,
				grid.y,
				_middleLeft.width,
				_middleLeft.height
			);
			_middleLeft.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_middleCenter = new BitmapData(
				grid.width,
				grid.height,
				true, 0
			);
			sourceRect.setTo(
				grid.x,
				grid.y,
				_middleCenter.width,
				_middleCenter.height
			);
			_middleCenter.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_middleRight = new BitmapData(
				bitmapData.width - grid.x - grid.width,
				grid.height,
				true, 0
			);
			sourceRect.setTo(
				grid.x + grid.width,
				grid.y,
				_middleRight.width,
				_middleRight.height
			);
			_middleRight.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_bottomLeft = new BitmapData(
				grid.x,
				bitmapData.height - grid.y - grid.height,
				true, 0
			);
			sourceRect.setTo(
				0,
				grid.y + grid.height,
				_bottomLeft.width,
				_bottomLeft.height
			);
			_bottomLeft.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_bottomCenter = new BitmapData(
				grid.width,
				bitmapData.height - grid.y - grid.height,
				true, 0
			);
			sourceRect.setTo(
				grid.x,
				grid.y + grid.height,
				_bottomCenter.width,
				_bottomCenter.height
			);
			_bottomCenter.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			_bottomRight = new BitmapData(
				bitmapData.width - grid.x - grid.width,
				bitmapData.height - grid.y - grid.height,
				true, 0
			);
			sourceRect.setTo(
				grid.x + grid.width,
				grid.y + grid.height,
				_bottomRight.width,
				_bottomRight.height
			);
			_bottomRight.copyPixels(bitmapData, sourceRect, destPoint);
			
			
			CachePool.recover([ destPoint, sourceRect ]);
		}
		
		
		
		
		/**原始图像数据*/
		public function get bitmapData():BitmapData { return _bitmapData; }
		/**九切片中间的格子*/
		public function get grid():Rectangle { return _grid; }
		
		
		/**左上的图像数据*/
		public function get topLeft():BitmapData { return _topLeft; }
		/**中上的图像数据*/
		public function get topCenter():BitmapData { return _topCenter; }
		/**右上的图像数据*/
		public function get topRight():BitmapData { return _topRight; }
		
		
		/**左中的图像数据*/
		public function get middleLeft():BitmapData { return _middleLeft; }
		/**中间的图像数据*/
		public function get middleCenter():BitmapData { return _middleCenter; }
		/**右中的图像数据*/
		public function get middleRight():BitmapData { return _middleRight; }
		
		
		/**左下的图像数据*/
		public function get bottomLeft():BitmapData { return _bottomLeft; }
		/**下中的图像数据*/
		public function get bottomCenter():BitmapData { return _bottomCenter; }
		/**右下的图像数据*/
		public function get bottomRight():BitmapData { return _bottomRight; }
		//
	}
}