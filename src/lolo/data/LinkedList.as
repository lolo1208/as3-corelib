package lolo.data
{
	import flash.utils.Dictionary;

	/**
	 * 双向链表
	 * @author LOLO
	 */
	public class LinkedList
	{
		/**数据列表*/
		private var _list:Dictionary;
		
		/**表头节点*/
		private var _head:LinkedListNode;
		/**表尾节点*/
		private var _tail:LinkedListNode;
		
		
		
		public function LinkedList()
		{
			_list = new Dictionary();
		}
		
		
		
		
		
		/**
		 * 根据键值创建节点，并将该节点添加到表头
		 * @param value
		 * @param key
		 * @return 新添加的节点
		 */
		public function unshift(value:*, key:*):LinkedListNode
		{
			var node:LinkedListNode = new LinkedListNode();
			node.key = key;
			node.value = value;
			node.next = _head;
			
			if(_tail == null) _tail = node;
			if(_head == null) _head = node;
			else _head.prev = node;
			
			_head = node;
			_list[key] = node;
			return node;
		}
		
		
		/**
		 * 根据键值创建节点，并将该节点添加到表尾
		 * @param value
		 * @param key
		 * @return 新创建的节点
		 */
		public function push(value:*, key:*):LinkedListNode
		{
			var node:LinkedListNode = new LinkedListNode();
			node.key = key;
			node.value = value;
			node.prev = _tail;
			
			if(_head == null) _head = node;
			if(_tail == null) _tail = node;
			else _tail.next = node;
			
			_tail = node;
			_list[key] = node;
			return node;
		}
		
		
		
		
		/**
		 * 将 key 对应的节点移动到表头
		 * @param key
		 */
		public function moveToHead(key:*):void
		{
			var node:LinkedListNode = _list[key];
			if(node == null || node == _head) return;
			
			if(node.prev != null) node.prev.next = node.next;
			if(node.next != null) node.next.prev = node.prev;
			
			if(node == _tail) _tail = node.prev;
			
			node.prev = null;
			node.next = _head;
			
			if(_head != null) _head.prev = node;
			_head = node;
		}
		
		
		/**
		 * 将 key 对应的节点移动到表尾
		 * @param key
		 */
		public function moveToTail(key:*):void
		{
			var node:LinkedListNode = _list[key];
			if(node == null || node == _tail) return;
			
			if(node.prev != null) node.prev.next = node.next;
			if(node.next != null) node.next.prev = node.prev;
			
			if(node == _head) _head = node.next;
			
			node.next = null;
			node.prev = _tail;
			
			if(_tail != null) _tail.next = node;
			_tail = node;
		}
		
		
		
		/**
		 * 在 prevKey 对应的节点之后插入新的节点
		 * @param prevKey
		 * @param key
		 * @param value
		 * @return 新创建的节点
		 */
		public function insertAfter(prevKey:*, key:*, value:*):LinkedListNode
		{
			var prev:LinkedListNode = _list[prevKey];
			if(prev == null) return null;
			
			var node:LinkedListNode = new LinkedListNode();
			node.key = key;
			node.value = value;
			node.prev = prev;
			node.next = prev.next;
			
			prev.next = node;
			return node;
		}
		
		
		/**
		 * 在 nextKey 对应的节点之前插入新的节点
		 * @param nextKey
		 * @param key
		 * @param value
		 * @return 新创建的节点
		 */
		public function insertBefore(nextKey:*, key:*, value:*):LinkedListNode
		{
			var next:LinkedListNode = _list[nextKey];
			if(next == null) return null;
			
			var node:LinkedListNode = new LinkedListNode();
			node.key = key;
			node.value = value;
			node.next = next;
			node.prev = next.prev;
			
			next.prev = node;
			return node;
		}
		
		
		
		/**
		 * 移除 key 对应的节点
		 * @param key
		 * @return 已被移除的节点
		 */
		public function remove(key:*):LinkedListNode
		{
			var node:LinkedListNode = _list[key];
			if(node == null) return null;
			
			if(node.prev) node.prev.next = node.next;
			if(node.next) node.next.prev = node.prev;
			delete _list[key];
			
			if(node == _head) _head = node.next;
			if(node == _tail) _tail = node.prev;
			
			return node;
		}
		
		
		
		
		/**
		 * 获取 key 对应的节点
		 * @param key
		 * @return 
		 */
		public function getNode(key:*):LinkedListNode { return _list[key]; }
		
		
		/**
		 * 获取 key 对应的 value
		 * @param key
		 * @return 
		 */
		public function getValue(key:*):*
		{
			var node:LinkedListNode = _list[key];
			if(node == null) return null;
			return node.value;
		}
		
		
		/**
		 * 获取第一个节点（表头）
		 * @return 
		 */
		public function get head():LinkedListNode { return _head; }
		
		
		/**
		 * 获取最后一个节点（表尾）
		 * @return 
		 */
		public function get tail():LinkedListNode { return _tail; }
		
		
		/**
		 * 链表中是否包含 key 对应的节点
		 * @param key
		 * @return 
		 */
		public function contains(key:*):Boolean { return _list[key] != null; }
		
		
		
		
		
		
		/**
		 * 清除
		 */
		public function clear():void
		{
			_list = new Dictionary();
			_head = null;
			_tail = null;
		}
		
		//
	}
}