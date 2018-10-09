package lolo.components
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import lolo.data.IHashMap;
	import lolo.events.DataEvent;
	import lolo.events.components.ListEvent;
	import lolo.utils.optimize.PrerenderScheduler;
	
	/**
	 * 列表
	 * @author LOLO
	 */
	public class List extends ItemGroup implements IList
	{
		/**刷新列表时，根据索引来选中子项*/
		public static const SELECT_MODE_INDEX:String = "index";
		/**刷新列表时，根据键来选中子项*/
		public static const SELECT_MODE_KEY:String = "key";
		
		/**数据*/
		protected var _data:IHashMap;
		/**子项的渲染类*/
		protected var _itemRendererClass:Class;
		/**列数（默认值：3）*/
		protected var _columnCount:uint = 3;
		/**行数（默认值：3）*/
		protected var _rowCount:uint = 3;
		/**刷新列表时，根据什么来选中子项，可选值["index", "key"]，默认值："index"*/
		protected var _selectMode:String;
		/**在还未选中过子项时，创建列表（设置数据，翻页）是否自动选中第一个子项，默认值：true*/
		protected var _autoSelectDefaultItem:Boolean;
		/**是否水平方向排序，默认值：true*/
		protected var _isHorizontalSort:Boolean = true;
		
		/**当前选中子项的索引*/
		protected var _curSelectedIndex:int = -1;
		/**当前选中子项的键列表*/
		protected var _curSelectedKeys:Array;
		
		/**子项的缓存池，已移除的子项实例不会立即销毁，将会回收到池中*/
		protected var _itemPool:Vector.<IItemRenderer>;
		
		
		
		public function List()
		{
			super();
			_selectMode = SELECT_MODE_INDEX;
			_autoSelectDefaultItem = true;
			_itemPool = new Vector.<IItemRenderer>();
		}
		
		

		public function set data(value:IHashMap):void
		{
			if(value == _data) return;
			if(_data != null) {
				_data.dispatchChanged = false;
				_data.removeEventListener(DataEvent.DATA_CHANGED, dataChangedHandler);
			}
			
			_data = value;
			if(_data != null) {
				_data.dispatchChanged = true;
				_data.addEventListener(DataEvent.DATA_CHANGED, dataChangedHandler);
			}
			
			selectedItem = null;
			update();
		}
		public function get data():IHashMap { return _data; }
		
		
		
		
		override protected function prerender():void
		{
			recoverAllItem();
			
			//属性或数据不完整，不能显示
			if(_data == null || _data.length == 0 || _itemRendererClass == null)
			{
				if(_selectedItem != null) selectedItem = null;//取消选中
				PrerenderScheduler.removeCallback(prerender);
				this.dispatchEvent(new ListEvent(ListEvent.RENDER));
				return;
			}
			
			
			//根据数据显示（创建）子项
			var length:uint = Math.min(_data.length, _rowCount * _columnCount);
			var i:int, item:IItemRenderer, lastItem:IItemRenderer;
			for(i = 0; i < length; i++)
			{
				item = getItem();
				addChild(item as DisplayObject);
				item.index = i;
				item.data = _data.getValueByIndex(i);
				addItem(item);
				
				if(lastItem != null)
				{
					if(_isHorizontalSort)
					{
						if((i % _columnCount) == 0) {//新行的开始
							item.x = 0;
							item.y = lastItem.y + lastItem.itemHeight + _verticalGap;
						}
						else {
							item.x = lastItem.x + lastItem.itemWidth + _horizontalGap;
							item.y = lastItem.y;
						}
					}
					else 
					{
						if((i % _rowCount) == 0) {
							item.y = 0;
							item.x = lastItem.x + lastItem.itemWidth + _horizontalGap;
						}
						else {
							item.y = lastItem.y + lastItem.itemHeight + _verticalGap;
							item.x = lastItem.x;
						}
					}
				}
				else {
					item.x = item.y = 0;
				}
				lastItem = item;
			}
			
			updateSelectedItem();
			PrerenderScheduler.removeCallback(prerender);
			this.dispatchEvent(new ListEvent(ListEvent.RENDER));
		}
		
		
		/**
		 * 在update之后，更新选中的item
		 */
		protected function updateSelectedItem():void
		{
			//还没有选中过任何子项
			if(_curSelectedIndex == -1)
			{
				if(_autoSelectDefaultItem && _autoSelectItem) selectItemByIndex(0);
			}
				
			//通过索引来选中子项
			else if(_selectMode == SELECT_MODE_INDEX)
			{
				autoSelectItemByIndex(_curSelectedIndex);
			}
				
			//根据键来选中子项
			else
			{
				var index:int = _data.getIndexByKeys(_curSelectedKeys);
				(index != -1) ? selectItemByIndex(index) : autoSelectItemByIndex(_curSelectedIndex);
			}
		}
		
		
		
		/**
		 * 通过索引来选中子项
		 * 如果指定的index不存在，将会自动选中index-1的子项
		 * @param index 指定的索引
		 */
		protected function autoSelectItemByIndex(index:uint):void
		{
			if(index >= _itemList.length || _itemList[index] != null) {
				selectItemByIndex(index);
			}
			else {
				index--;
				if(index >= 0) autoSelectItemByIndex(index);
			}
		}
		
		
		
		
		override protected function itemMouseDownHandler(event:MouseEvent):void
		{
			super.itemMouseDownHandler(event);
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			
			if(_autoSelectItem)
			{
				if(_selectedItem == item) {
					if(item.deselect) selectedItem = null;
				}
				else {
					selectedItem = item;
				}
			}
		}
		
		
		override protected function itemClickHandler(event:MouseEvent):void
		{
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			this.dispatchEvent(new ListEvent(ListEvent.ITEM_CLICK, item));
		}
		
		
		
		
		public function set itemRendererClass(value:Class):void
		{
			if(value == _itemRendererClass) return;
			
			var data:IHashMap = _data;
			clear();
			_data = data;
			
			_itemRendererClass = value;
			update();
		}
		public function get itemRendererClass():Class { return _itemRendererClass; }
		
		
		public function set columnCount(value:uint):void
		{
			if(value == _columnCount) return;
			_columnCount = value;
			update();
		}
		public function get columnCount():uint { return _columnCount; }
		
		
		public function set rowCount(value:uint):void
		{
			if(value == _rowCount) return;
			_rowCount = value;
			update();
		}
		public function get rowCount():uint { return _rowCount; }
		
		
		public function set selectMode(value:String):void
		{
			if(value == _selectMode) return;
			_selectMode = value;
			update();
		}
		public function get selectMode():String { return _selectMode; }
		
		
		public function set autoSelectDefaultItem(value:Boolean):void
		{
			if(value == _autoSelectDefaultItem) return;
			_autoSelectDefaultItem = value;
			update();
		}
		public function get autoSelectDefaultItem():Boolean { return _autoSelectDefaultItem; }
		
		
		public function set isHorizontalSort(value:Boolean):void
		{
			if(value == _isHorizontalSort) return;
			_isHorizontalSort = value;
			update();
		}
		public function get isHorizontalSort():Boolean { return _isHorizontalSort; }
		
		
		
		
		override public function set selectedItem(value:IItemRenderer):void
		{
			if(value == _selectedItem)
			{
				if(_selectedItem == null) return;
				if(_selectedItem.deselect) 
					value = null;//取消选中
				else
					return;
			}
			
			super.selectedItem = value;
			if(_selectedItem != null)
			{
				_curSelectedIndex = _selectedItem.index;
				_curSelectedKeys = _data.getKeysByIndex(_curSelectedIndex);
			}
			else {
				_curSelectedIndex = -1;
				_curSelectedKeys = null;
			}
		}
		
		public function selectItemByDataIndex(index:uint):void
		{
			if(index >= _data.length) index = _data.length - 1;
			else if(index < 0) index = 0;
			selectedItem = getItemByIndex(index);
		}
		
		public function selectItemByDataKeys(keys:Array):void
		{
			selectItemByDataIndex(_data.getIndexByKeys(keys));
		}
		
		override public function getItemByIndex(index:int):IItemRenderer
		{
			if(_data == null) return null;
			if(index < 0 || index >= _itemList.length) return null;
			return _itemList[index];
		}
		
		public function getItemByKey(key:*):IItemRenderer
		{
			return getItemByIndex(_data.getIndexByKey(key));
		}
		
		
		public function setItemData(item:IItemRenderer, data:*):void
		{
			if(item == null) return;
			item.recover();
			item.data = data;
			item.group = this;
			this.dispatchEvent(new ListEvent(ListEvent.RENDER, item));
		}
		
		
		
		
		public function getDataIndexByListIndex(listIndex:uint):uint
		{
			return listIndex;
		}
		
		
		override public function get numItems():uint
		{
			return _data == null ? 0 : _data.length;
		}
		
		
		
		
		/**
		 * 数据有改变
		 * @param event
		 */
		protected function dataChangedHandler(event:DataEvent):void
		{
			//修改item的数据
			if(event.index != -1) {
				setItemData(getItemByIndex(event.index), event.newValue);
			}
			//数据列表有变动
			else {
				update();
			}
		}
		
		
		/**
		 * 获取一个Item，先尝试从缓存池中拿，如果没有，将创建一个新的item
		 * @return 
		 */
		protected function getItem():IItemRenderer
		{
			if(_itemPool.length > 0) {
				return _itemPool.pop();
			}
			else {
				return (_itemRendererClass == null) ? null : new _itemRendererClass();
			}
		}
		
		/**
		 * 移除所有子项，并回收到缓存池中
		 */
		public function recoverAllItem():void
		{
			var item:IItemRenderer;
			while(_itemList.length > 0)
			{
				item = _itemList.pop();
				item.group = null;
				item.selected = false;
				item.recover();
				this.removeChild(item as DisplayObject);
				
				_itemPool.push(item);
			}
			_selectedItem = null;
		}
		
		/**
		 * 清空子项缓存池
		 */
		protected function clearItemPool():void
		{
			var item:IItemRenderer;
			while(_itemPool.length > 0)
			{
				item = _itemPool.pop();
				item.dispose();
			}
		}
		
		
		override public function clear():void
		{
			recoverAllItem();
			clearItemPool();
			
			if(_data != null) {
				_data.dispatchChanged = false;
				_data.removeEventListener(DataEvent.DATA_CHANGED, dataChangedHandler);
				_data = null;
			}
			_curSelectedIndex = -1;
			_curSelectedKeys = null;
		}
		
		
		public function dispose():void
		{
			clear();
		}
		//
	}
}