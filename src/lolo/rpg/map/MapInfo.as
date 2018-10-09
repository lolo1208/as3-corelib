package lolo.rpg.map
{
	/**
	 * 地图信息数据结构
	 * @author LOLO
	 */
	public class MapInfo
	{
		/**地图的像素宽*/
		public var mapWidth:uint;
		/**地图的像素高*/
		public var mapHeight:uint;
		
		/**是否为交错排列的区块*/
		public var staggered:Boolean;
		/**区块的像素宽*/
		public var tileWidth:uint;
		/**区块的像素高*/
		public var tileHeight:uint;
		/**水平方向区块的数量*/
		public var hTileCount:uint;
		/**垂直方向区块的数量*/
		public var vTileCount:uint;
		
		/**图块的像素宽*/
		public var chunkWidth:uint;
		/**图块的像素高*/
		public var chunkHeight:uint;
		/**水平方向图块的数量*/
		public var hChunkCount:uint;
		/**垂直方向图块的数量*/
		public var vChunkCount:uint;
		
		/**缩略图占正常图的缩放比例*/
		public var thumbnailScale:Number;
		
		/**地图数据，二维数组 data[y][x] */
		public var data:Array;
		
		/**遮挡物列表 covers[{id:遮挡物的id, point:遮挡物的像素位置)}]*/
		public var covers:Array;
		
		
		
		
		
		public function MapInfo(info:Object)
		{
			mapWidth = info.mapWidth;
			mapHeight = info.mapHeight;
			
			staggered = info.staggered;
			tileWidth = info.tileWidth;
			tileHeight = info.tileHeight;
			hTileCount = info.hTileCount;
			vTileCount = info.vTileCount;
			
			chunkWidth = info.chunkWidth;
			chunkHeight = info.chunkHeight;
			hChunkCount = info.hChunkCount;
			vChunkCount = info.vChunkCount;
			
			thumbnailScale = info.thumbnailScale;
			data = info.data;
			covers = info.covers;
		}
		//
	}
}