package lolo.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lolo.core.Common;
	
	
	/**
	 * 处理显示对象相关事物的工具
	 * @author LOLO
	 */
	public class DisplayUtil
	{
		
		
		/**
		 * 获取显示对象的指定位置是否为全透明
		 * @param target 目标显示对象
		 * @param location 显示对象的内部坐标，如果该值为null，将会取显示对象当前的鼠标位置
		 * @return 
		 */
		public static function fullTransparent(target:DisplayObject, location:Point=null):Boolean
		{
			if(location == null) location = new Point(target.mouseX, target.mouseY);
			var bitmapData:BitmapData = new BitmapData(1, 1, true, 0);
			bitmapData.draw(target, new Matrix(1, 0, 0, 1, -location.x, -location.y));
			var px:uint = bitmapData.getPixel32(0, 0);
			bitmapData.dispose();
			return px == 0;
		}
		
		
		
		/**
		 * 等比例缩放显示对象（并居中到目标位置）
		 * @param target 要缩放的显示对象
		 * @param rect 目标位置，为null将会以舞台为目标位置
		 * @param one true:宽高的值只要有一个在rect内就好，false:宽高的值都必须在rect内
		 * @param center 是否需要居中到目标位置。如果值为false，将只修改target宽高，不调整x/y
		 */
		public static function scale(target:DisplayObject, rect:Rectangle=null, one:Boolean=true, center:Boolean=true):void
		{
			if(rect == null) rect = new Rectangle(0, 0, Common.ui.stageWidth, Common.ui.stageHeight);
			
			var ws:Number = rect.width / target.width;
			var hs:Number = rect.height / target.height;
			
			target.scaleX = target.scaleY = (ws > hs) ? (one ? ws : hs) : (one ? hs : ws);
			
			if(center) {
				target.x = (rect.width - target.width) / 2 + rect.x;
				target.y = (rect.height - target.height) / 2 + rect.y;
			}
		}
		
		
		/**
		 * 获取位图中的最小不透明矩形区域
		 * @param bitmapData
		 * @return 
		 */
		public static function getOpaqueRect(bitmapData:BitmapData):Rectangle
		{
			//先尝试用getColorBoundsRect()获取
			var rect:Rectangle = bitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
			
			//再尝试从各方向向中心探索
			if(rect.width == 0 || rect.height == 0) {
				var x:int, y:int;
				for(x = 0; x < bitmapData.width; x++) {
					for(y = 0; y < bitmapData.height; y++) {
						if(bitmapData.getPixel32(x, y) != 0) {
							rect.x = x;
							x = bitmapData.width;//结束外层x的循环
							break;
						}
					}
				}
				for(x = bitmapData.width - 1; x > 0; x--) {
					for(y = 0; y < bitmapData.height; y++) {
						if(bitmapData.getPixel32(x, y) != 0) {
							rect.width = x - rect.x;
							x = 0;
							break;
						}
					}
				}
				for(y = 0; y < bitmapData.height; y++) {
					for(x = 0; x < bitmapData.width; x++) {
						if(bitmapData.getPixel32(x, y) != 0) {
							rect.y = y;
							y = bitmapData.height;
							break;
						}
					}
				}
				for(y = bitmapData.height - 1; y > 0; y--) {
					for(x = 0; x < bitmapData.width; x++) {
						if(bitmapData.getPixel32(x, y) != 0) {
							rect.height = y - rect.y;
							y = 0;
							break;
						}
					}
				}
				rect.width++;//会少1像素，需补齐。也可避免完全空白图像报错
				rect.height++;
			}
			return rect;
		}
		//
	}
}