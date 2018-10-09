package lolo.data
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import lolo.events.DataEvent;

	/**
	 * 哈希表数据
	 * 可多个键对应一个值
	 * @author LOLO
	 */
	public class HashMap extends EventDispatcher implements IHashMap
	{
		/**值列表（Array 或 Vector）*/
		private var _values:*;
		/**与值列表对应的键列表*/
		private var _keys:Dictionary;
		/**在数据有改变时，是否需要抛出 DataEvent.DATA_CHANGED 事件（默认不抛）*/
		private var _dispatchChanged:Boolean;
		
		
		
		
		/**
		 * 构造一个哈希表数据
		 * @param values 初始的值列表（Array 或 Vector）
		 * @param keys 与值列表对应的键列表
		 */
		public function HashMap(values:*=null, keys:Dictionary=null)
		{
			_values = (values == null) ? [] : values;
			_keys = (keys == null) ? new Dictionary() : keys;
		}
		
		
		
		
		public function getValueByKey(key:*):*
		{
			if(_keys[key] == undefined) return null;
			return getValueByIndex(_keys[key]);
		}
		
		
		public function getValueByIndex(index:uint):*
		{
			return _values[index];
		}
		
		
		public function getIndexByKey(key:*):int
		{
			return (_keys[key] != undefined) ? _keys[key] : -1;
		}
		
		
		public function getIndexByValue(value:*):int
		{
			for(var i:int = 0; i < _values.length; i++) {
				if(_values[i] == value) return i;
			}
			return -1;
		}
		
		
		public function getIndexByKeys(keys:Array):int
		{
			if(keys == null || keys.length == 0) return -1;
			
			var index:int = -1;
			var key:*;
			for(var i:int = 0; i < keys.length; i++) {
				key = keys[i];
				
				if(_keys[key] == undefined) return -1;//没有这个key
				
				if(index != -1) {
					if(_keys[key] != index) return -1;//列表中的key不一致
				}else {
					index = _keys[key];
				}
			}
			return index;
		}
		
		
		public function getKeysByIndex(index:uint):Array
		{
			var keys:Array = [];
			for(var key:* in _keys) {
				if(_keys[key] == index) keys.push(key);
			}
			return keys;
		}
		
		
		
		
		
		public function setValueByIndex(index:uint, value:*):void
		{
			var oldValue:* = _values[index];
			_values[index] = value;
			if(_dispatchChanged) dispatchEvent(new DataEvent(DataEvent.DATA_CHANGED, index, oldValue, value));
		}
		
		
		public function setValueByKey(key:*, value:*):void
		{
			if(_keys[key] != undefined) setValueByIndex(_keys[key], value);
		}
		
		
		
		
		
		
		public function removeKey(key:*):void
		{
			delete _keys[key];
		}
		
		
		public function removeByKey(key:*):void
		{
			if(_keys[key] != null) removeByIndex(_keys[key]);
		}
		
		
		public function removeByIndex(index:uint):void
		{
			_values.splice(index, 1);
			
			//克隆一份_keys进行for...in操作，直接对_keys进行操作将会导致for..in无序
			var key:*;
			var keys:Dictionary = new Dictionary();
			for(key in _keys) keys[key] = _keys[key];
			
			//检查key
			for(key in keys)
			{
				//移除相关的key
				if(_keys[key] == index) {
					delete _keys[key];
				}
				//后面的索引递减一次
				else if(_keys[key] > index) {
					_keys[key]--;
				}
			}
			
			if(_dispatchChanged) dispatchEvent(new DataEvent(DataEvent.DATA_CHANGED));
		}
		
		
		
		
		
		public function add(value:*, ...keys):uint
		{
			var index:int = _values.length;
			_values.push(value);
			for(var i:int = 0; i < keys.length; i++) _keys[keys[i]] = index;
			if(_dispatchChanged) dispatchEvent(new DataEvent(DataEvent.DATA_CHANGED));
			return index;
		}
		
		
		public function addKeyByIndex(newKey:*, index:uint):uint
		{
			_keys[newKey] = index;
			return index;
		}
		
		
		public function addKeyByKey(newKey:*, key:*):int
		{
			if(_keys[key] == null) return -1;
			return addKeyByIndex(newKey, _keys[key]);
		}
		
		
		
		
		public function set dispatchChanged(value:Boolean):void { _dispatchChanged = value; }
		public function get dispatchChanged():Boolean { return _dispatchChanged; }
		
		
		public function set values(value:*):void { _values = value; }
		public function get values():* { return _values; }
		
		
		public function set keys(value:Dictionary):void { _keys = value; }
		public function get keys():Dictionary { return _keys; }
		
		
		public function get length():uint
		{
			return (_values == null) ? 0 : _values.length;
		}
		
		
		
		
		
		public function clone():IHashMap
		{
			var keys:Dictionary = new Dictionary();
			for(var key:* in _keys) keys[key] = _keys[key];
			return new HashMap(_values.concat(), keys);
		}
		
		public function clear():void
		{
			(_values == null) ? _values.length = 0 : _values = [];
			_keys = new Dictionary();
			if(_dispatchChanged) dispatchEvent(new DataEvent(DataEvent.DATA_CHANGED));
		}
		//
	}
}