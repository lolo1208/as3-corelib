package lolo.components
{
	import flash.display.DisplayObject;
	
	import lolo.core.Constants;
	import lolo.data.IHashMap;
	import lolo.events.DataEvent;
	import lolo.events.components.ListEvent;
	import lolo.utils.optimize.PrerenderScheduler;

	/**
	 * 滚动列表
	 * @author LOLO
	 */
	public class ScrollList extends List implements IScrollList
	{
		/**对应的滚动条*/
		private var _scrollBar:IScrollBar;
		
		/**设置的item宽度*/
		protected var _itemWidth:uint;
		/**设置的item高度*/
		protected var _itemHeight:uint;
		/**用来布局的item宽度（_itemWidth + _horizontalGap）*/
		protected var _itemLayoutWidth:uint;
		/**用来布局的item高度（_itemHeight + _verticalGap）*/
		protected var _itemLayoutHeight:uint;
		
		
		/**通过itemWidth和data.length计算出来的宽度*/
		private var _width:uint;
		/**通过itemHeight和data.length计算出来的高度*/
		private var _height:uint;
		
		/**本次更新，数据是否有改变*/
		private var _dataHasChanged:Boolean;
		
		
		
		public function ScrollList()
		{
			super();
		}
		
		
		
		public function set scrollBar(value:IScrollBar):void
		{
			if(value == _scrollBar) return;
			_scrollBar = value;
			update();
		}
		public function get scrollBar():IScrollBar { return _scrollBar; }
		
		
		
		
		override public function update():void
		{
			if(_scrollBar == null) {
				super.update();//没有滚动条，在 PrerenderScheduler 的回调中更新内容
			}
			else {
				_scrollBar.update();//有滚动条，在 x/y 有改变时更新内容
			}
		}
		
		
		
		override protected function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			
			if(_scrollBar == null) {
				super.prerender();
				return;
			}
			
			recoverAllItem();
			
			//属性或数据不完整，不能显示
			if(_data == null || _data.length == 0 || _itemRendererClass == null)
			{
				_width = _height = 0;
				if(_selectedItem != null) selectedItem = null;//取消选中
				PrerenderScheduler.removeCallback(prerender);
				this.dispatchEvent(new ListEvent(ListEvent.RENDER));
				return;
			}
			
			//先得到item的宽高
			var item:IItemRenderer;
			if(_itemWidth == 0 || _itemHeight == 0) {
				item = getItemByIndex(0);
				if(_itemWidth == 0) {
					_itemWidth = item.itemWidth;
					_itemLayoutWidth = _itemWidth + _horizontalGap;
				}
				if(_itemHeight == 0) {
					_itemHeight = item.itemHeight;
					_itemLayoutHeight = _itemHeight + _verticalGap;
				}
				recoverAllItem();
			}
			
			//只用显示该范围内的item
			var isVertical:Boolean = _scrollBar.direction == Constants.VERTICAL;
			var minP:int, maxP:int, minI:uint, maxI:uint;
			if(isVertical) {
				minP = Math.abs(y - _scrollBar.viewableArea.y);
				maxP = minP + _scrollBar.viewableArea.height;
				minI = Math.floor(minP / _itemLayoutHeight) *  _columnCount;
				maxI = Math.ceil(maxP / _itemLayoutHeight) * _columnCount;
			}
			else {
				minP = Math.abs(x - _scrollBar.viewableArea.x);
				maxP = minP + _scrollBar.viewableArea.width;
				minI = Math.floor(minP / _itemLayoutWidth) * _rowCount;
				maxI = Math.ceil(maxP / _itemLayoutWidth) * _rowCount;
			}
			if(maxI > _data.length) maxI = _data.length;
			
			//根据数据显示（创建）子项
			var i:int, lastItem:IItemRenderer;
			for(i = minI; i < maxI; i++)
			{
				item = getItem();
				addChild(item as DisplayObject);
				item.data = _data.getValueByIndex(i);
				addItem(item);
				item.index = i;
				
				if(lastItem != null)
				{
					if(isVertical) {
						if((i % _columnCount) == 0) {
							item.x = 0;
							item.y = lastItem.y + lastItem.itemHeight + _verticalGap;
						}
						else {
							item.x = lastItem.x + lastItem.itemWidth + _horizontalGap;
							item.y = lastItem.y;
						}
					}
					else {
						if((i % _rowCount) == 0) {
							item.x = lastItem.x + lastItem.itemWidth + _horizontalGap;
							item.y = 0
						}
						else {
							item.x = lastItem.x;
							item.y = lastItem.y + lastItem.itemHeight + _verticalGap;
						}
					}
				}
				else {
					if(isVertical) {
						item.x = 0;
						item.y = minI / _columnCount * _itemLayoutHeight;
					}
					else {
						item.x = minI / _rowCount * _itemLayoutWidth;
						item.y = 0;
					}
				}
				lastItem = item;
			}
			
			var oldValue:uint;
			if(isVertical) {
				oldValue = _height;
				_height = super.height;
				_height += Math.ceil((_data.length - (maxI - minI)) / _columnCount) * _itemLayoutHeight;
			}
			else {
				oldValue = _width;
				_width = super.width;
				_width += Math.ceil((_data.length - (maxI - minI)) / _rowCount) * _itemLayoutWidth;
			}
			
			//内容或宽高有变化时，通知滚动条更新
			var newValue:uint = isVertical ? _height : _width;
			if(_dataHasChanged || newValue != oldValue) {
				_dataHasChanged = false;
				_scrollBar.updateNow();
			}
			
			updateSelectedItem();
			PrerenderScheduler.removeCallback(prerender);
			this.dispatchEvent(new ListEvent(ListEvent.RENDER));
		}
		
		
		
		override protected function autoSelectItemByIndex(index:uint):void
		{
			if(index >= _data.length) index = _data.length - 1;
			selectItemByIndex(index);
		}
		
		override public function selectItemByIndex(index:int):void
		{
			if(_data == null) return;
			selectedItem = getItemByIndex(index);
		}
		
		override public function getItemByIndex(index:int):IItemRenderer
		{
			if(_data == null) return null;
			if(index < 0 || index >= _data.length) return null;
			
			//在已创建的item中（显示范围内），寻找指定index的item
			for(var i:int = 0; i < _itemList.length; i++) {
				if(_itemList[i].index == index) {
					return _itemList[i];
				}
			}
			
			//已创建的item中，没有对应index的item（表示item在显示范围外），直接创建
			var item:IItemRenderer = getItem();
			addChild(item as DisplayObject);
			item.data = _data.getValueByIndex(index);
			addItem(item);
			item.index = index;
			if(_scrollBar.direction == Constants.VERTICAL) {
				item.x = index % _columnCount * _itemLayoutWidth;
				item.y = Math.floor(index / _columnCount) * _itemLayoutHeight;
			}
			else {
				item.x = Math.floor(index / _rowCount) * _itemLayoutWidth;
				item.y = index % _rowCount * _itemLayoutHeight;
			}
			return item;
		}
		
		
		
		override public function set data(value:IHashMap):void
		{
			_dataHasChanged = true;
			super.data = value;
		}
		
		override protected function dataChangedHandler(event:DataEvent):void
		{
			_dataHasChanged = true;
			super.dataChangedHandler(event);
		}
		
		
		
		
		override public function set x(value:Number):void
		{
			if(value == super.x && !_dataHasChanged) return;
			super.x = value;
			if(_scrollBar != null) prerender();
		}
		
		override public function set y(value:Number):void
		{
			if(value == super.y && !_dataHasChanged) return;
			super.y = value;
			if(_scrollBar != null) prerender();
		}
		
		
		
		public function set itemWidth(value:uint):void
		{
			if(value == _itemWidth) return;
			_itemWidth = value;
			_itemLayoutWidth = _itemWidth + _horizontalGap;
			if(_scrollBar != null) prerender();
		}
		public function get itemWidth():uint { return _itemWidth; }
		
		
		public function set itemHeight(value:uint):void
		{
			if(value == _itemHeight) return;
			_itemHeight = value;
			_itemLayoutHeight = _itemHeight + _verticalGap;
			if(_scrollBar != null) prerender();
		}
		public function get itemHeight():uint { return _itemHeight; }
		
		
		override public function set horizontalGap(value:int):void
		{
			super.horizontalGap = value;
			_itemLayoutWidth = _itemWidth + _horizontalGap;
		}
		
		
		override public function set verticalGap(value:int):void
		{
			super.verticalGap = value;
			_itemLayoutHeight = _itemHeight + _verticalGap;
		}
		
		
		override public function get isHorizontalSort():Boolean
		{
			if(_scrollBar != null) return _scrollBar.direction == Constants.VERTICAL;
			return _isHorizontalSort;
		}
		
		
		
		override public function get width():Number
		{
			return _width > 0 ? _width : super.width;
		}
		
		override public function get height():Number
		{
			return _height > 0 ? _height : super.height;
		}
		
		
		
		
		
		override public function clear():void
		{
			super.clear();
			if(_scrollBar != null) _scrollBar.update();
		}
		//
	}
}