package lolo.utils.bezier
{
	import flash.geom.Point;

	/**
	 * 2次贝塞尔曲线。根据间距，生成锚点
	 * 建议直接使用CubicBezier
	 * @author LOLO
	 */
	public class QuadraticBezier
	{
		/**起点*/
		private var _p0:Point;
		/**贝塞尔点*/
		private var _p1:Point;
		/**终点*/
		private var _p2:Point;
		/**锚点间距*/
		private var _anchorSpace:uint;
		/**锚点数*/
		private var _anchorCount:uint;
		/**曲长*/
		private var _curveLength:Number;
		
		private var _ax:int;
		private var _ay:int;
		private var _bx:int;
		private var _by:int;
		
		private var _a:Number;
		private var _b:Number;
		private var _c:Number;
		
		
		
		/**
		 * 构造函数
		 * @param p0 起点
		 * @param p1 贝塞尔点
		 * @param p2 终点
		 * @param anchorSpace 锚点间距
		 */
		public function QuadraticBezier(p0:Point=null, p1:Point=null, p2:Point=null, anchorSpace:uint=10)
		{
			init(p0, p1, p2, anchorSpace);
		}
		
		
		/**
		 * 初始化
		 * @param p0 起点
		 * @param p1 贝塞尔点
		 * @param p2 终点
		 * @param anchorSpace 锚点间距
		 * @return 锚点总数
		 */
		public function init(p0:Point=null, p1:Point=null, p2:Point=null, anchorSpace:uint=10):uint
		{
			if(p0 == null || p1 == null || p2 == null || anchorSpace == 0) return 0;
			
			_p0 = p0;
			_p1 = p1;
			_p2 = p2;
			_anchorSpace = anchorSpace;
			
			_ax = _p0.x - 2 * _p1.x + _p2.x;
			_ay = _p0.y - 2 * _p1.y + _p2.y;
			_bx = 2 * _p1.x - 2 * _p0.x;
			_by = 2 * _p1.y - 2 * _p0.y;
			
			if(_ax == 0) _ax = 1;
			if(_ay == 0) _ay = 1;
			
			_a = 4*(_ax * _ax + _ay * _ay);
			_b = 4*(_ax * _bx + _ay * _by);
			_c = _bx * _bx + _by * _by;
			
			_curveLength = getLength(1);
			
			_anchorCount = Math.floor(_curveLength / _anchorSpace);
			if (_curveLength % _anchorSpace > _anchorSpace / 2)	_anchorCount ++;
			
			return _anchorCount;
		}
		
		
		
		
		
		/**
		 * 获取速度
		 * @param t
		 * @return 
		 */
		private function getSpeed(t:Number):Number
		{
			return Math.sqrt(_a * t * t + _b * t + _c);
		}
		
		
		/**
		 * 获取长度
		 * @param t
		 * @return 
		 */
		private function getLength(t:Number):Number
		{
			var temp1:Number = Math.sqrt(_c + t * (_b + _a * t));
			var temp2:Number = (2 * _a * t * temp1 + _b *(temp1 - Math.sqrt(_c)));
			var temp3:Number = Math.log(_b + 2 * Math.sqrt(_a) * Math.sqrt(_c));
			var temp4:Number = Math.log(_b + 2 * _a * t + 2 * Math.sqrt(_a) * temp1);
			var temp5:Number = 2 * Math.sqrt(_a) * temp2;
			var temp6:Number = (_b * _b - 4 * _a * _c) * (temp3 - temp4);
			
			return (temp5 + temp6) / (8 * Math.pow(_a, 1.5));
		}
		
		
		/**
		 * 获取反长度
		 * @param t
		 * @param l
		 * @return 
		 */
		private function getInvertLength(t:Number, l:Number):Number
		{
			var t1:Number = t;
			var t2:Number;
			do {
				t2 = t1 - (getLength(t1) - l) / getSpeed(t1);
				if(Math.abs(t1 - t2) < 0.000001) break;
				t1 = t2;
			}
			while(true);
			
			return t2;
		}
		
		
		
		/**
		 * 根据锚点的索引，获取锚点的信息
		 * @param index
		 * @return {x:x坐标, y:y坐标, degrees:角度}
		 */
		public function getAnchorInfo(index:uint):Object
		{
			if (index >= 0 && index <= _anchorCount)
			{
				var t:Number = index / _anchorCount;
				var l:Number = t * _curveLength;//对应的曲长
				t = getInvertLength(t, l);//获得对应的t值
				
				//获得坐标
				var x:Number = (1 - t) * (1 - t) * _p0.x + 2 * (1 - t) * t * _p1.x + t * t * _p2.x;
				var y:Number = (1 - t) * (1 - t) * _p0.y + 2 * (1 - t) * t * _p1.y + t * t * _p2.y;
				
				//获得切线
				var t0:Point = new Point((1 - t) * _p0.x + t * _p1.x, (1 - t) * _p0.y + t * _p1.y);
				var t1:Point = new Point((1 - t) * _p1.x + t * _p2.x, (1 - t) * _p1.y + t * _p2.y);
				
				//算出角度
				var dx:Number = t1.x - t0.x;
				var dy:Number = t1.y - t0.y;
				var radians:Number = Math.atan2(dy, dx);
				var degrees:Number = radians * 180 / Math.PI;
				
				return {x:x, y:y, degrees:degrees};
			}
			else {
				return null;
			}
		}
		
		
		/**
		 * 起点
		 */
		public function get pStart():Point { return _p0; }
		
		/**
		 * 贝塞尔点
		 */
		public function get pBezier():Point { return _p1; }
		
		/**
		 * 终点
		 */
		public function get pEnd():Point { return _p2; }
		
		
		/**
		 * 锚点间距
		 */
		public function get anchorSpace():uint { return _anchorSpace; }
		
		/**
		 * 锚点数
		 */
		public function get anchorCount():uint { return _anchorCount; }
		
		/**
		 * 曲长
		 */
		public function get curveLength():Number { return _curveLength; }
		//
	}
}