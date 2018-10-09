package lolo.data
{
	/**
	 * 双向链表的节点
	 * @author LOLO
	 */
	public class LinkedListNode
	{
		
		/**该节点的key*/
		public var key:*;
		
		/**该节点的value*/
		public var value:*;
		
		/**上一个节点。表头节点的上一个节点始终为null*/
		public var prev:LinkedListNode;
		
		/**下一个节点。表尾节点的下一个节点始终为null*/
		public var next:LinkedListNode;
		
		//
	}
}