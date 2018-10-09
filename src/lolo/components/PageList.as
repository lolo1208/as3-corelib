package lolo.components
{
	import flash.display.DisplayObject;
	
	import lolo.events.components.ListEvent;
	import lolo.events.components.PageEvent;
	import lolo.utils.optimize.PrerenderScheduler;

	/**
	 * 翻页列表
	 * @author LOLO
	 */
	public class PageList extends List implements IPageList
	{
		/**对应的翻页组件*/
		private var _page:IPage;
		
		
		
		public function PageList()
		{
			super();
		}
		
		
		
		override protected function prerender():void
		{
			recoverAllItem();
			
			//属性或数据不完整，不能显示
			if(_data == null || _data.length == 0 || _itemRendererClass == null || _columnCount == 0 || _rowCount == 0)
			{
				if(_selectedItem != null) selectedItem = null;//取消选中
				PrerenderScheduler.removeCallback(prerender);
				this.dispatchEvent(new ListEvent(ListEvent.RENDER));
				return;
			}
			
			var numPerPage:uint = this.numPerPage;
			//有对应的翻页组件
			if(_page != null)
			{
				var currentPage:int = _page.currentPage;
				_page.initialize(numPerPage, (_data == null) ? 0 : _data.length);
				//当前页有改变，清除索引
				if(_page.currentPage != currentPage) {
					_curSelectedIndex = -1;
					_curSelectedKeys = null;
				}
			}
			
			//计算出当前页要显示多少条子项
			var length:uint = Math.min(numPerPage, _data.length);
			if(_page != null && (_page.currentPage * numPerPage) > _data.length) {
				length = _data.length - (_page.currentPage - 1) * numPerPage;
			}
			
			//根据数据显示（创建）子项
			var pageIndex:uint = (_page != null) ? (_page.currentPage - 1) * numPerPage : 0;
			var i:int, item:IItemRenderer, lastItem:IItemRenderer;
			for(i = 0; i < length; i++)
			{
				item = getItem();
				addChild(item as DisplayObject);
				item.index = i;
				item.data = _data.getValueByIndex(i + pageIndex);
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
		
		
		
		override public function selectItemByDataIndex(index:uint):void
		{
			super.selectItemByDataIndex(index);
			if(_page != null) _page.currentPage = Math.ceil((index + 1) / numPerPage);
		}
		
		
		override public function getItemByIndex(index:int):IItemRenderer
		{
			if(_data == null) return null;
			if(_page != null) index -= (_page.currentPage - 1) * numPerPage;
			if(index < 0 || index >= _itemList.length) return null;
			return _itemList[index];
		}
		
		
		override public function getDataIndexByListIndex(listIndex:uint):uint
		{
			if(_page != null) {
				return (_page.currentPage - 1) * numPerPage + listIndex;
			}
			else {
				return listIndex;
			}
		}
		
		
		
		public function get numPerPage():uint
		{
			return _rowCount * _columnCount;
		}
		
		
		
		public function set page(value:IPage):void
		{
			if(_page == value) return;
			
			if(_page != null) _page.removeEventListener(PageEvent.FLIP, page_flipHandler);
			
			_page = value;
			if(_page != null) _page.addEventListener(PageEvent.FLIP, page_flipHandler);
			
			update();
		}
		public function get page():IPage { return _page; }
		
		
		/**
		 * 翻页组件触发翻页事件
		 * @param event
		 */
		private function page_flipHandler(event:PageEvent):void
		{
			_curSelectedIndex = -1;
			_curSelectedKeys = null;
			update();
		}
		
		
		
		
		override public function clear():void
		{
			if(_page != null) _page.reset();
			super.clear();
		}
		//
	}
}