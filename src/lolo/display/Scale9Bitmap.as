package lolo.display
{
	import flash.display.Bitmap;
	
	
	/**
	 * 位图显示对象九切片实例（布局对象）
	 * @author LOLO
	 */
	public class Scale9Bitmap
	{
		/**当前使用的位图九切片数据*/
		private var _data:Scale9BitmapData;
		
		/**设置的宽*/
		private var _width:int;
		/**设置的高*/
		private var _height:int;
		
		/**九切片图片实例列表*/
		public var bitmaps:Vector.<Bitmap>;
		
		
		
		
		public function Scale9Bitmap(data:Scale9BitmapData=null, width:uint=0, height:uint=0)
		{
			_width = width;
			_height = height;
			this.data = data;
		}
		
		
		
		/**
		 * 当前使用的位图九切片数据
		 */
		public function set data(value:Scale9BitmapData):void
		{
			if(value == _data || value == null) return;
			_data = value;
			
			//没设置过宽高
			if(_width == 0 || _height == 0) {
				_width = _data.bitmapData.width;
				_height = _data.bitmapData.height;
			}
			
			if(bitmaps == null) {
				bitmaps = new Vector.<Bitmap>();
				bitmaps.push(
					new Bitmap(_data.topLeft),		new Bitmap(_data.topCenter),	new Bitmap(_data.topRight),
					new Bitmap(_data.middleLeft),	new Bitmap(_data.middleCenter),	new Bitmap(_data.middleRight),
					new Bitmap(_data.bottomLeft),	new Bitmap(_data.bottomCenter),	new Bitmap(_data.bottomRight)
				);
			}
			else {
				bitmaps[0].bitmapData = _data.topLeft;
				bitmaps[1].bitmapData = _data.topCenter;
				bitmaps[2].bitmapData = _data.topRight;
				
				bitmaps[3].bitmapData = _data.middleLeft;
				bitmaps[4].bitmapData = _data.middleCenter;
				bitmaps[5].bitmapData = _data.middleRight;
				
				bitmaps[6].bitmapData = _data.bottomLeft;
				bitmaps[7].bitmapData = _data.bottomCenter;
				bitmaps[8].bitmapData = _data.bottomRight;
			}
			
			bitmaps[1].x = bitmaps[4].x = bitmaps[7].x = _data.topLeft.width;
			bitmaps[3].y = bitmaps[4].y = bitmaps[5].y = _data.topLeft.height;
			
			layout();
		}
		public function get data():Scale9BitmapData { return _data; }
		
		
		
		/**
		 * 宽度
		 */
		public function set width(value:uint):void
		{
			if(value == _width) return;
			_width = value;
			layout();
		}
		public function get width():uint { return _width; }
		
		
		/**
		 * 高度
		 */
		public function set height(value:uint):void
		{
			if(value == _height) return;
			_height = value;
			layout();
		}
		public function get height():uint { return _height; }
		
		
		
		/**
		 * 有改变时，重新布局
		 */
		private function layout():void
		{
			if(_data == null) return;
			bitmaps[1].width  = bitmaps[4].width  = bitmaps[7].width  = (_width - _data.topLeft.width - _data.bottomRight.width);
			bitmaps[2].x      = bitmaps[5].x      = bitmaps[8].x      = (_width - _data.bottomRight.width);
			bitmaps[3].height = bitmaps[4].height = bitmaps[5].height = (_height - _data.topLeft.height - _data.bottomRight.height);
			bitmaps[6].y      = bitmaps[7].y      = bitmaps[8].y      = (_height - _data.bottomRight.height);
		}
		//
	}
}