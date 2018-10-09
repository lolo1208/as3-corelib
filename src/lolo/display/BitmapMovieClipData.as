package lolo.display
{
	import flash.display.BitmapData;
	
	/**
	 * 位图影片剪辑数据
	 * @author LOLO
	 */
	public class BitmapMovieClipData extends BitmapData
	{
		/**像素数据相对注册点的x坐标偏移值*/
		public var offsetX:int;
		/**像素数据相对注册点的y坐标偏移值*/
		public var offsetY:int;
		
		
		public function BitmapMovieClipData(width:int, height:int, offsetX:int=0, offsetY:int=0, transparent:Boolean=true, fillColor:uint=0)
		{
			super(width, height, transparent, fillColor);
			this.offsetX = offsetX;
			this.offsetY = offsetY;
		}
		//
	}
}