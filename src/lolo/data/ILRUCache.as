package lolo.data
{
	/**
	 * 该数据集为哈希表数据</br>
	 * 主要用途：缓存对象，并自动释放最近最少使用的对象(LRU:Least Recently Used)</br>
	 * 满足其中一个情况，将会自动释放对象：</br>
	 * 	1.超过了设置的最大内存值</br>
	 * 	2.对象在指定失效时间内未被使用过
	 * @author LOLO
	 */
	public interface ILRUCache
	{
		/**
		 * 添加一个值，以及对应的键。</br>
		 * 如果该键已经存在，将会释放掉之前的对象（值），替换成新的对象
		 * @param key
		 * @param value
		 * @param memory 指定value的内存大小，单位：字节。默认值0：让LRU动态获取，前提是程序的运行环境是在调试环境中
		 */
		function add(key:*, value:*, memory:Number=0):void;
		
		
		/**
		 * 移除一个已缓存的对象
		 * @param key
		 * @return 返回移除的对象
		 */
		function remove(key:*):*;
		
		
		/**通过键获取值*/
		function getValue(key:*):*;
		
		
		/**
		 * 指定的key是否已经被添加到缓存中了
		 * @param key
		 * @return 
		 */
		function hasAdded(key:*):Boolean;
		
		
		/**
		 * 清空
		 */
		function clear():void;
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		function dispose():void;
		
		
		
		/**
		 * LRU缓存的最大内存，单位：字节
		 */
		function set maxMemorySize(value:Number):void;
		function get maxMemorySize():Number;
		
		
		/**
		 * 当前已经使用内存大小，单位：字节
		 */
		function get currentMemorySize():Number;
		
		
		/**
		 * 缓存对象的失效时间，单位：毫秒
		 */
		function set deadline(value:uint):void;
		function get deadline():uint;
		
		
		/**
		 * 缓存对象被清理时，调用的回调函数。
		 * 该函数应有两个参数，fun(key, value)
		 */
		function set disposeCallback(value:Function):void;
		function get disposeCallback():Function;
		
		
		/**
		 * 日志和状态信息</br>
		 * 	valueCount		: 当前缓存的对象数量</br>
		 * 	memory			: 当前已使用内存量（单位：字节）</br>
		 * 	requestCount	: 总请求次数（调用getValue()次数）</br>
		 * 	hitCacheCount	: 命中缓存次数（getValue()时有缓存）
		 */
		function get log():Object;
		//
	}
}