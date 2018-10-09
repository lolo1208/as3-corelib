package lolo.rpg
{
	import flash.geom.Point;
	
	import lolo.rpg.map.MapInfo;
	import lolo.utils.optimize.CachePool;
	
	/**
	 * Rpg工具
	 * @author LOLO
	 */
	public class RpgUtil
	{
		/**
		 * 获取指定 区块 的 中心点像素坐标
		 * @param tile 区块坐标
		 * @param mapInfo 地图信息
		 * @return 
		 */
		public static function getTileCenter(tile:Point, mapInfo:MapInfo):Point
		{
			if(mapInfo.staggered)
			{
				var p:Point = CachePool.getPoint();
				
				//算出目标区块的坐标
				var isEven:Boolean = (tile.y % 2) == 0;//是否为偶数行
				p.x = tile.x * mapInfo.tileWidth;
				p.y = tile.y * mapInfo.tileHeight * 0.5;
				if(!isEven) p.x += mapInfo.tileWidth * 0.5;
				
				//加上半个区块宽高
				p.x += mapInfo.tileWidth * 0.5;
				p.y += mapInfo.tileHeight * 0.5;
				
				return p;
			}
			
			
			//找到(0,0)点位置
			var num:int = Math.round(mapInfo.mapWidth / mapInfo.tileWidth) - 1;
			var hw:int = mapInfo.tileWidth >> 1;
			var hh:int = mapInfo.tileHeight >> 1;
			var zx:int = hw * num;
			var zy:int = hh * num + mapInfo.mapHeight;
			
			//加上半个区块宽高（区块的中心点）
			zx += mapInfo.tileWidth >> 1;
			zy += mapInfo.tileHeight >> 1;
			
			return CachePool.getPoint(
				zx + (tile.x - tile.y) * hw,
				zy - (tile.x + tile.y) * hh
			);
		}
		
		/**
		 * 获取指定 像素坐标 所对应的 区块坐标
		 * @param pixel 像素坐标
		 * @param mapInfo 地图信息
		 * @return 
		 */
		public static function getTile(pixel:Point, mapInfo:MapInfo):Point
		{
			if(mapInfo.staggered)
			{
				var x:uint = pixel.x;
				var y:uint = pixel.y;
				var tx:int = 0;
				var ty:int = 0;
				
				var cx:int, cy:int, rx:int, ry:int;
				cx = int(x / mapInfo.tileWidth) * mapInfo.tileWidth + mapInfo.tileWidth / 2;
				cy = int(y / mapInfo.tileHeight) * mapInfo.tileHeight + mapInfo.tileHeight / 2;
				
				rx = (x - cx) * mapInfo.tileHeight / 2;
				ry = (y - cy) * mapInfo.tileWidth / 2;
				
				if(Math.abs(rx) + Math.abs(ry) <= mapInfo.tileWidth * mapInfo.tileHeight / 4) {
					tx = int(x / mapInfo.tileWidth);
					ty = int(y / mapInfo.tileHeight) * 2;
				}
				else {
					x = x - mapInfo.tileWidth / 2;
					tx = int(x / mapInfo.tileWidth) + 1;
					y = y - mapInfo.tileHeight / 2;
					ty = int(y / mapInfo.tileHeight) * 2 + 1;
				}
				
				//无区块的区域，加上半个区块宽高，得到最近的区块
				if(tx > 99999 || ty > 99999) {
					pixel.x += mapInfo.tileWidth / 2;
					pixel.y += mapInfo.tileHeight / 2;
					return getTile(pixel, mapInfo);
				}
				
				return CachePool.getPoint(tx - (ty & 1), ty);
			}
			
			
			//找到(0,0)点位置
			var num:int = Math.round(mapInfo.mapWidth / mapInfo.tileWidth) - 1;
			var hw:int = mapInfo.tileWidth >> 1;
			var hh:int = mapInfo.tileHeight >> 1;
			var zx:int = hw * num;
			var zy:int = hh * num + mapInfo.mapHeight;
			
			//水平平移半个宽，垂直平移一个高
			zx += mapInfo.tileWidth >> 1;
			zy += mapInfo.tileHeight;
			
			//算出正确的偏移的像素
			pixel.x = zx - pixel.x;
			pixel.y = zy - pixel.y;
			
			return CachePool.getPoint(
				Math.abs(int(pixel.x / mapInfo.tileWidth - pixel.y / mapInfo.tileHeight)),
				Math.abs(int(pixel.x / mapInfo.tileWidth + pixel.y / mapInfo.tileHeight))
			);
		}
		
		
		
		
		
		
		/**
		 * 获取指定方向的旁边点的坐标
		 * @param p 区块位置
		 * @param direction 方向
		 * @return 
		 */
		public static function getSideTile(p:Point, direction:uint, mapInfo:MapInfo):Point
		{
			var oa:Array;
			if(mapInfo.staggered)
				oa = (p.y % 2 == 0) ? RpgConstants.O_EVEN : RpgConstants.O_ODD;
			else
				oa = RpgConstants.O_RHO;
			return CachePool.getPoint(p.x + oa[direction][0], p.y + oa[direction][1]);
		}
		
		
		/**
		 * 获取指定方向的旁边点是否可以通行
		 * @param p 区块位置
		 * @param direction 要探测的方向
		 * @param mapInfo 地图信息
		 * @return 
		 */
		public static function canPassSide(p:Point, direction:uint, mapInfo:MapInfo):Boolean
		{
			var pSide:Point = getSideTile(p, direction, mapInfo);//查找的点
			
			//超出范围
			if(!tileInTheMapData(pSide, mapInfo)) return false;
			
			return mapInfo.data[pSide.y][pSide.x].canPass;
		}
		
		
		/**
		 * 指定的区块是否在地图数据范围内
		 * @param tile
		 * @param mapInfo
		 * @return 
		 */
		public static function tileInTheMapData(tile:Point, mapInfo:MapInfo):Boolean
		{
			return (tile.x >= 0 && tile.x < mapInfo.data[0].length && tile.y >= 0 && tile.y < mapInfo.data.length);
		}
		
		
		
		/**
		 * 获取p2在p1的什么角度（<b>是像素点，不是区块点</b>，方向正右→ angle=0）
		 * @param p1
		 * @param p2
		 * @return 
		 */
		public static function getAngle(p1:Point, p2:Point):int
		{
			//两点的x,y值，斜边
			var x:Number = p2.x - p1.x;
			var y:Number = p2.y - p1.y;
			var hypotenuse:Number = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
			
			//斜边长度，弧度
			var cos:Number = x / hypotenuse;
			var radian:Number = Math.acos(cos);
			
			//角度
			var angle:Number = 180 / (Math.PI / radian);
			
			//用弧度算出角度
			if(y < 0) {
				angle = -angle;
			}
			else if(y == 0 && x < 0) {
				angle = 180;
			}
			
			return angle;
		}
		
		
		/**
		 * 根据方向获取对应的角度（方向正右→ angle=0）
		 * @param direction
		 * @return 
		 */
		public static function getAngleByDirection(direction:uint):int
		{
			switch(direction)
			{
				case RpgConstants.D_UP: return -90;
				case RpgConstants.D_RIGHT_UP: return -45;
				case RpgConstants.D_RIGHT: return 0;
				case RpgConstants.D_RIGHT_DOWN: return 45;
				case RpgConstants.D_DOWN: return 90;
				case RpgConstants.D_LEFT_DOWN: return 135;
				case RpgConstants.D_LEFT: return 180;
				case RpgConstants.D_LEFT_UP: return -135;
			}
			return 0;
		}
		
		
		
		/**
		 * 获取p2在p1的什么方向（<b>是像素点，不是区块点</b>，方向正右→ angle=0）
		 * @param p1 
		 * @param p2
		 * @return 方向（见"RpgConstants.D_"系列常量）
		 */
		public static function getDirection(p1:Point, p2:Point):uint
		{
			var angle:int = getAngle(p1, p2);
			if(angle <= -70 && angle > -110)	return RpgConstants.D_UP;
			if(angle <= 110 && angle > 70)		return RpgConstants.D_DOWN;
			if(angle <= -165 || angle > 165)	return RpgConstants.D_LEFT;
			if(angle <= 15 && angle > -15)		return RpgConstants.D_RIGHT;
			if(angle <= -110 && angle > -165)	return RpgConstants.D_LEFT_UP;
			if(angle <= 165 && angle > 110)		return RpgConstants.D_LEFT_DOWN;
			if(angle <= -15 && angle > -70)		return RpgConstants.D_RIGHT_UP;
			return RpgConstants.D_RIGHT_DOWN;
		}
		
		
		
		/**
		 * 获取t2在t1的什么方向（<b>是区块点，不是像素点</b>）
		 * @param t1 
		 * @param t2
		 * @param mapInfo
		 * @return 方向（见"RpgConstants.D_"系列常量）
		 */
		public static function getDirection2(t1:Point, t2:Point, mapInfo:MapInfo):uint
		{
			var p1:Point = getTileCenter(t1, mapInfo);
			var p2:Point = getTileCenter(t2, mapInfo);
			var d:uint = getDirection(p1, p2);
			CachePool.recover([ p1, p2 ]);
			return d;
		}
		
		
		
		/**
		 * 指定的点是否可通行
		 * @param p
		 * @param mapInfo
		 * @return 
		 */
		public static function canPassTile(p:Point, mapInfo:MapInfo):Boolean
		{
			return mapInfo.data[p.y] && mapInfo.data[p.y][p.x] && mapInfo.data[p.y][p.x].canPass;
		}
		
		
		/**
		 * 获取一个离终点最近的可通行的点
		 * @param p1 起点
		 * @param p2 终点
		 * @param mapInfo 地图信息
		 * @return 
		 */
		public static function closestCanPassTile(p1:Point, p2:Point, mapInfo:MapInfo):Point
		{
			//终点已经在起点旁边了
			if((Math.abs(p2.x - p1.x) == 1 || p2.x == p1.x) && (Math.abs(p2.y - p1.y) == 1 || p2.y == p1.y)) {
				return p2;
			}
			
			//终点不能通行
			if(!canPassTile(p2, mapInfo))
			{
				var d:uint = getDirection(p2, p1);//起点在终点的什么方向
				var p:Point = getSideTile(p2, d, mapInfo);//取终点朝这个方向的点
				return closestCanPassTile(p1, p, mapInfo);//继续查找
			}
			
			return p2;
		}
		
		
		
		/**
		 * 获取地图上随机的一个可通行的区块点
		 * @param mapInfo
		 * @return 
		 */
		public static function getRandomCanPassTile(mapInfo:MapInfo):Point
		{
			var p:Point = CachePool.getPoint(
				int(mapInfo.data[0].length * Math.random()),
				int(mapInfo.data.length * Math.random())
			);
			if(mapInfo.data[p.y][p.x].canPass) return p;
			
			CachePool.recover(p);
			return getRandomCanPassTile(mapInfo);
		}
		
		
		
		
		/**
		 * 获取指定范围内所包含的所有区块列表
		 * @param tile 起始点
		 * @param range 范围（外围几圈）
		 * @param mapInfo 地图信息
		 * @param canPass 是否只搜寻可通行的点
		 * @return 
		 */
		public static function getTileArea(tile:Point, range:uint, mapInfo:MapInfo, canPass:Boolean=true):Vector.<Point>
		{
			var checkFun:Function;
			checkFun = canPass ? canPassTile : tileInTheMapData;
			
			var tiles:Vector.<Point> = new Vector.<Point>();
			if(checkFun(tile, mapInfo)) tiles.push(tile);
			
			var i:int = 0;
			var n:int, p:Point, len:int;
			while(i < range)
			{
				i++;
				len = i * 2;
				
				//先找到正上方
				p = tile;
				for(n = 0; n < i; n++) p = getSideTile(p, RpgConstants.D_UP, mapInfo);
				
				//从正上往右下，直到正右，获取这条边上所有的点
				for(n = 0; n < len; n++) {
					p = getSideTile(p, RpgConstants.D_RIGHT_DOWN, mapInfo);
					if(checkFun(p, mapInfo)) tiles.push(p);
				}
				
				//从正右往左下，直到正下
				for(n = 0; n < len; n++) {
					p = getSideTile(p, RpgConstants.D_LEFT_DOWN, mapInfo);
					if(checkFun(p, mapInfo)) tiles.push(p);
				}
				
				//从正下往左上，直到正右
				for(n = 0; n < len; n++) {
					p = getSideTile(p, RpgConstants.D_LEFT_UP, mapInfo);
					if(checkFun(p, mapInfo)) tiles.push(p);
				}
				
				//从正右往右上，直到正上
				for(n = 0; n < len; n++) {
					p = getSideTile(p, RpgConstants.D_RIGHT_UP, mapInfo);
					if(checkFun(p, mapInfo)) tiles.push(p);
				}
			}
			
			return tiles;
		}
		
		
		
		/**
		 * t1 与 t2 是否为相邻的两个区块
		 * @param t1
		 * @param t2
		 * @return 
		 */
		public static function isAdjacent(t1:Point, t2:Point, mapInfo:MapInfo):Boolean
		{
			var oa:Array;
			if(mapInfo.staggered)
				oa = (t1.y % 2 == 0) ? RpgConstants.O_EVEN : RpgConstants.O_ODD;
			else
				oa = RpgConstants.O_RHO;
			
			for(var d:int = 1; d < 9; d++)
				if(t2.x == t1.x + oa[d][0] && t2.y == t1.y + oa[d][1]) return true;
			
			return false;
		}
		//
	}
}
