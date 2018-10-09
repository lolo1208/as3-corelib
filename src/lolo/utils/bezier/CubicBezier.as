package lolo.utils.bezier
{
	import flash.geom.Point;

	/**
	 * 多次贝塞尔曲线，根据贝塞尔点列表和间距，生成一系列锚点
	 * @author LOLO
	 */
	public class CubicBezier
	{
		/**起点*/
		private var _pStart:Point;
		/**终点*/
		private var _pEnd:Point;
		/**贝塞尔点列表*/
		private var _pBezierList:Array;
		/**锚点信息列表[{x:x坐标, y:y坐标, degrees:角度}]*/
		private var _anchorList:Array = [];
		/**锚点间距*/
		private var _anchorSpace:uint;
		/**曲长*/
		private var _curveLength:Number;
		
		
		/**
		 * 构造函数
		 * @param pStart 起点
		 * @param pEnd 终点
		 * @param pBezierList 贝塞尔点列表
		 * @param anchorSpace 锚点间距
		 */
		public function CubicBezier(pStart:Point=null, pEnd:Point=null, pBezierList:Array=null, anchorSpace:uint=10)
		{
			init(pStart, pEnd, pBezierList, anchorSpace);
		}
		
		
		/**
		 * 初始化
		 * @param pStart 起点
		 * @param pEnd 终点
		 * @param pBezierList 贝塞尔点列表。当列表长度为0时，将自动取起点与终点的中心点为贝塞尔点
		 * @param anchorSpace 锚点间距
		 * @return 锚点总数
		 */
		public function init(pStart:Point=null, pEnd:Point=null, pBezierList:Array=null, anchorSpace:uint=10):uint
		{
			if(pStart == null || pEnd == null || pBezierList == null || anchorSpace == 0) return 0;
			
			_pStart = pStart;
			_pEnd = pEnd;
			_pBezierList = pBezierList;
			_anchorSpace = anchorSpace;
			
			var path:Array = [pStart];
			if(pBezierList.length == 0) pBezierList.push(Point.interpolate(pStart, pEnd, 0.5));
			path = path.concat(pBezierList);
			path.push(pEnd);
			
			_anchorList = [];
			var bezier:QuadraticBezier;
			
			for(var n:int = 0; n < path.length - 2; n++)
			{
				var p0:Point = (n == 0) ? path[0] : new Point((path[n].x + path[n + 1].x) / 2, (path[n].y + path[n + 1].y) / 2);
				var p1:Point = new Point(path[n + 1].x, path[n + 1].y);
				var p2:Point = (n <= path.length - 4) ? new Point((path[n + 1].x + path[n + 2].x) / 2, (path[n + 1].y + path[n + 2].y) / 2) : path[n + 2];
				bezier = new QuadraticBezier(p0, p1, p2, anchorSpace);
				
				for(var i:int=0; i < bezier.anchorCount; i++)
				{
					var anchor:Object = bezier.getAnchorInfo(i);
					_anchorList.push(anchor);
				}
			}
			
			_curveLength = (bezier != null) ? bezier.curveLength : 0;
			
			return _anchorList.length;
		}
		
		
		/**
		 * 根据锚点的索引，获取锚点的信息
		 * @param index
		 * @return {x:x坐标, y:y坐标, degrees:角度}
		 */
		public function getAnchorInfo(index:uint):Object
		{
			return _anchorList[index];
		}
		
		
		/**
		 * 锚点信息列表[{x:x坐标, y:y坐标, degrees:角度}]
		 */
		public function get anchorList():Array { return _anchorList; }
		
		/**
		 * 起点
		 */
		public function get pStart():Point { return _pStart; }
		
		/**
		 * 贝塞尔点列表
		 */
		public function get pBezierList():Array { return _pBezierList; }
		
		/**
		 * 终点
		 */
		public function get pEnd():Point { return _pEnd; }
		
		
		/**
		 * 锚点间距
		 */
		public function get anchorSpace():uint { return _anchorSpace; }
		
		/**
		 * 锚点数
		 */
		public function get anchorCount():uint { return _anchorList.length; }
		
		/**
		 * 曲长
		 */
		public function get curveLength():Number { return _curveLength; }
		//
	}
}