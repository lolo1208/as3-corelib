package lolo.data
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * 哈希表数据接口<br/>
	 * 可多个键对应一个值
	 * @author LOLO
	 */
	public interface IHashMap extends IEventDispatcher
	{
		/**
		 * 通过键获取值
		 * @param key
		 * @return 
		 */
		function getValueByKey(key:*):*;
		
		/**
		 * 通过索引获取值
		 * @param index
		 * @return 
		 */
		function getValueByIndex(index:uint):*;
		
		/**
		 * 通过键获取索引
		 * @param key
		 * @return 
		 */
		function getIndexByKey(key:*):int;
		
		/**
		 * 通过值获取索引
		 * @param value
		 * @return 
		 */
		function getIndexByValue(value:*):int;
		
		/**
		 * 通过键列表获取索引
		 * @param keys
		 * @return 
		 */
		function getIndexByKeys(keys:Array):int;
		
		/**
		 * 通过索引获取键列表
		 * @param index
		 * @return 
		 */
		function getKeysByIndex(index:uint):Array;
		
		
		
		/**
		 * 通过索引设置值
		 * @param index
		 * @param value
		 */
		function setValueByIndex(index:uint, value:*):void;
		
		/**
		 * 通过键设置值
		 * @param key
		 * @param value
		 */
		function setValueByKey(key:*, value:*):void;
		
		
		
		/**
		 * 移除某个键与值的映射关系<br/>
		 * <font color="red">注意，该方法并不是移除数据的方法。</font><br/>
		 * 要移除数据请参考：removeByKey()、removeByIndex() 方法
		 * @param key
		 */
		function removeKey(key:*):void;
		
		/**
		 * 通过键移除对应的键与值
		 * @param key
		 */
		function removeByKey(key:*):void;
		
		/**
		 * 通过索引移除对应的键与值
		 * @param index
		 */
		function removeByIndex(index:uint):void;
		
		
		
		/**
		 * 添加一个值，以及对应的键列表，并返回该值的索引
		 * @param value
		 * @param keys
		 * @return 
		 */
		function add(value:*, ...keys):uint;
		
		/**
		 * 通过索引为该值添加一个键，并返回该值的索引
		 * @param newKey
		 * @param index
		 * @return 
		 */
		function addKeyByIndex(newKey:*, index:uint):uint;
		
		/**
		 * 通过键为该值添加一个键，并返回该值的索引。如果没有源键将添加失败，并返回-1
		 * @param newKey
		 * @param key
		 * @return 
		 */
		function addKeyByKey(newKey:*, key:*):int;
		
		
		
		/**
		 * 在数据有改变时，是否需要抛出 DataEvent.DATA_CHANGED 事件（默认不抛）
		 */
		function set dispatchChanged(value:Boolean):void;
		function get dispatchChanged():Boolean;
		
		/**
		 * 值列表（Array 或 Vector）
		 */
		function set values(value:*):void;
		function get values():*;
		
		/**
		 * 与值列表对应的键列表
		 */
		function set keys(value:Dictionary):void;
		function get keys():Dictionary;
		
		/**
		 * 值的长度
		 */
		function get length():uint;
		
		
		
		/**
		 * 克隆
		 */
		function clone():IHashMap;
		
		/**
		 * 清空
		 */
		function clear():void;
		//
	}
}