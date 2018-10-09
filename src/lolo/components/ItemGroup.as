package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.core.Constants;
	import lolo.events.components.ListEvent;
	import lolo.utils.optimize.PrerenderScheduler;

	/**
	 * 子项集合
	 * 排列（创建）子项
	 * 子项间的选中方式会互斥
	 * @author LOLO
	 */
	public class ItemGroup extends Sprite implements IItemGroup
	{
		/**布局方式（默认：Constants.ABSOLUTE）*/
		protected var _layout:String;
		/**水平方向子项间的像素间隔*/
		protected var _horizontalGap:int;
		/**垂直方向子项间的像素间隔*/
		protected var _verticalGap:int;
		/**包含的子项的列表*/
		protected var _itemList:Vector.<IItemRenderer>;
		/**当前选中的子项*/
		protected var _selectedItem:IItemRenderer;
		/**是否启用*/
		protected var _enabled:Boolean = true;
		/**在对应的事件（update()、click、mouseDown）发生时，是否自动切换子项的选中状态*/
		protected var _autoSelectItem:Boolean = true;
		
		
		
		public function ItemGroup()
		{
			super();
			_layout = Constants.ABSOLUTE;
			_itemList = new Vector.<IItemRenderer>();
		}
		
		

		public function update():void
		{
			PrerenderScheduler.addCallback(prerender);
		}
		
		public function updateNow():void
		{
			prerender();
		}
		
		/**
		 * 即将进入渲染时的回调
		 */
		protected function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			if(_layout == Constants.ABSOLUTE || _itemList.length == 0) return;
			
			var item:IItemRenderer;
			var position:int = 0;
			for(var i:int = 0; i < _itemList.length; i++)
			{
				item = _itemList[i];
				
				//只对父级是当前集合的可见的子项进行布局排序
				if(item.parent == this && item.visible)
				{
					switch(_layout) {
						
						case Constants.HORIZONTAL:
							item.x = position;
							item.y = 0;
							position += item.itemWidth + _horizontalGap;
							break;
						
						case Constants.VERTICAL:
							item.x = 0;
							item.y = position;
							position += item.itemHeight + _verticalGap;
							break;
					}
				}
			}
		}
		
		
		public function addItem(item:IItemRenderer):void
		{
			//已经是该集合的子项，不再重复添加
			for(var i:int=0; i<_itemList.length; i++) if(_itemList[i] == item) return;
			
			_itemList.push(item);
			item.group = this;
			item.enabled = _enabled;
			item.index = _itemList.length - 1;
			item.addEventListener(MouseEvent.CLICK, itemClickHandler);
			item.addEventListener(MouseEvent.MOUSE_DOWN, itemMouseDownHandler);
		}
		
		
		public function removeItem(item:IItemRenderer):void
		{
			var delIndex:int = -1;
			
			//重排子项
			for(var i:int = 0 ; i < _itemList.length; i++)
			{
				if(delIndex != -1) {
					_itemList[i].index = i - 1;
				}
				else if(_itemList[i] == item) {
					delIndex = i;
				}
			}
			
			//移除指定的子项
			if(delIndex != -1)
			{
				_itemList.splice(delIndex, 1);
				update();
				
				item.removeEventListener(MouseEvent.CLICK, itemClickHandler);
				item.removeEventListener(MouseEvent.MOUSE_DOWN, itemMouseDownHandler);
				if(item == _selectedItem) _selectedItem = null;
				if(item.selected) item.selected = false;
				item.index = 0;
				item.group = null;
				
				if(item.parent == this) {
					super.removeChild(item as DisplayObject);
					item.dispose();
				}
			}
		}
		
		
		/**
		 * 鼠标按下子项
		 * @param event
		 */
		protected function itemMouseDownHandler(event:MouseEvent):void
		{
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			this.dispatchEvent(new ListEvent(ListEvent.ITEM_MOUSE_DOWN, item));
		}
		
		
		/**
		 * 鼠标单击子项
		 * @param event
		 */
		protected function itemClickHandler(event:MouseEvent):void
		{
			var item:IItemRenderer = event.currentTarget as IItemRenderer;
			switchItem(item);
			this.dispatchEvent(new ListEvent(ListEvent.ITEM_CLICK, item));
		}
		
		
		/**
		 * 切换子项的选中状态
		 * @param event
		 */
		protected function switchItem(item:IItemRenderer):void
		{
			if(_autoSelectItem) {
				if(_selectedItem == item) {
					if(item.deselect) selectedItem = null;
				}
				else {
					selectedItem = item;
				}
			}
		}
		
		
		public function getItemByIndex(index:int):IItemRenderer
		{
			return _itemList[index];
		}
		
		
		public function selectItemByIndex(index:int):void
		{
			if(_itemList.length == 0) return;
			if(index < 0) index = 0;
			else if(index >= _itemList.length) index = _itemList.length - 1;
			selectedItem = _itemList[index];
		}
		
		
		public function set selectedItem(value:IItemRenderer):void
		{
			var oldItem:IItemRenderer = _selectedItem;
			_selectedItem = value;
			
			if(value != null && value.group == this) _selectedItem.selected = true;
			
			if(oldItem != null)
			{
				//是同一个子项
				if(oldItem == value) {
					if(oldItem.deselect) oldItem.selected = false;//可以取消选中
					return;
				}
				oldItem.selected = false;
			}
			
			this.dispatchEvent(new ListEvent(ListEvent.ITEM_SELECTED, value));
		}
		public function get selectedItem():IItemRenderer { return _selectedItem; }
		
		
		public function get selectedItemData():*
		{
			return (_selectedItem != null) ? _selectedItem.data : null;
		}
		
		
		public function get numItems():uint { return _itemList.length; }
		
		
		public function set enabled(value:Boolean):void
		{
			if(_enabled == value) return;
			
			_enabled = value;
			for(var i:int=0; i < _itemList.length; i++) _itemList[i].enabled = value;
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		public function set layout(value:String):void
		{
			_layout = value;
			update();
		}
		public function get layout():String { return _layout; }
		
		
		public function set horizontalGap(value:int):void
		{
			_horizontalGap = value;
			update();
		}
		public function get horizontalGap():int { return _horizontalGap; }
		
		
		public function set verticalGap(value:int):void
		{
			_verticalGap = value;
			update();
		}
		public function get verticalGap():int { return _verticalGap; }
		
		
		public function get autoSelectItem():Boolean { return _autoSelectItem; }
		public function set autoSelectItem(value:Boolean):void { _autoSelectItem = value; }
		
		
		
		
		public function clear():void
		{
			PrerenderScheduler.removeCallback(prerender);
			var item:IItemRenderer;
			while(_itemList.length > 0)
			{
				item = _itemList.pop();
				item.index = 0;
				item.group = null;
				item.removeEventListener(MouseEvent.CLICK, itemClickHandler);
				item.removeEventListener(MouseEvent.MOUSE_DOWN, itemMouseDownHandler);
				if(item.parent == this) {
					super.removeChild(item as DisplayObject);
					item.dispose();
				}
			}
			_selectedItem = null;
		}
		//
	}
}