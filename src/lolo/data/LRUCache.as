package lolo.data
{
	import lolo.utils.FrameTimer;
	import lolo.utils.TimeUtil;

	/**
	 * 该数据集为哈希表数据</br>
	 * 主要用途：缓存对象，并自动释放最近最少使用的对象(LRU:Least Recently Used)</br>
	 * 满足其中一个情况，将会自动释放对象：</br>
	 * 	1.超过了设置的最大内存值</br>
	 * 	2.对象在指定失效时间内未被使用过
	 * @author LOLO
	 */
	public class LRUCache implements ILRUCache
	{
		/**缓存数据链表*/
		private var _list:LinkedList;
		
		/**LRU缓存的最大内存，单位：字节*/
		private var _maxMemorySize:Number = 100 * 1024 * 1024;
		/**已缓存对象的失效时间，单位：毫秒*/
		private var _deadline:uint = 30 * 60 * 1000;
		/**当前已经使用内存大小，单位：字节*/
		private var _currentMemorySize:Number;
		
		/**缓存对象被清理时，调用的回调函数*/
		private var _disposeCallback:Function;
		/**用于定期清理缓存数据*/
		private var _clearTimer:FrameTimer;
		/**日志和状态信息*/
		private var _log:Object;
		
		
		
		
		public function LRUCache()
		{
			initialization();
			_clearTimer = new FrameTimer(5 * 60 * 1000, clearTimerHandler);
			_clearTimer.start();
		}
		
		
		
		/**
		 * 初始化
		 */
		private function initialization():void
		{
			_list = new LinkedList();
			_currentMemorySize = 0;
			_log = { requestCount:0, hitCacheCount:0 };
		}
		
		
		
		
		public function add(key:*, value:*, memory:Number=0):void
		{
			if(_list.contains(key)) remove(key);
			_list.push({ value:value, memory:memory, time:TimeUtil.getTime() }, key);
			
			//缓存超标，删除激活时间较久（表头）的缓存
			_currentMemorySize += memory;
			if(_currentMemorySize > _maxMemorySize) {
				while(_currentMemorySize > _maxMemorySize && _list.head != null) remove(_list.head.key);
			}
		}
		
		
		public function remove(key:*):*
		{
			var data:Object = _list.getValue(key);
			if(data == null) return;
			
			_currentMemorySize -= data.memory;//减少总内存使用量
			_list.remove(key);
			
			if(_disposeCallback != null) _disposeCallback(key, data.value);
			return data.value;
		}
		
		
		public function getValue(key:*):*
		{
			_log.requestCount++;//增加请求总数
			var data:Object = _list.getValue(key);
			if(data == null) {
				return null;
			}
			else {
				_log.hitCacheCount++;//增加缓存命中数
			}
			
			data.time = TimeUtil.getTime();//更新激活时间
			_list.moveToTail(key);
			
			return data.value;
		}
		
		
		public function hasAdded(key:*):Boolean
		{
			return _list.contains(key);
		}
		
		
		
		/**
		 * 周期查询对象在指定失效时间内是否未被使用过，并清除
		 */
		private function clearTimerHandler():void
		{
			var curTime:Number = TimeUtil.getTime();
			var node:LinkedListNode = _list.head;
			while(_list.head != null) {
				if(curTime - _list.head.value.time > _deadline)
					remove(_list.head.key);
				else
					break;
			}
		}
		
		
		
		public function clear():void
		{
			initialization();
		}
		
		public function dispose():void
		{
			_list.clear();
			_log = null;
			_clearTimer.reset();
		}
		
		
		
		public function set maxMemorySize(value:Number):void
		{
			_maxMemorySize = value;
		}
		public function get maxMemorySize():Number { return _maxMemorySize; }
		
		
		public function get currentMemorySize():Number
		{
			return _currentMemorySize;
		}
		
		
		public function set deadline(value:uint):void
		{
			_deadline = value;
		}
		public function get deadline():uint { return _deadline; }
		
		
		public function set disposeCallback(value:Function):void
		{
			_disposeCallback = value;
		}
		public function get disposeCallback():Function { return _disposeCallback; }
		
		
		
		public function get log():Object
		{
			var valueCount:int = 0;
			var node:LinkedListNode = _list.head;
			while(node != null) {
				valueCount++;
				node = node.next;
			}
			
			return {
				memory			: _currentMemorySize,
				valueCount		: valueCount,
				requestCount	: _log.requestCount,
				hitCacheCount	: _log.hitCacheCount
			};
		}
		//
	}
}