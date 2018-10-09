package lolo.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.core.Common;
	import lolo.events.components.PageEvent;
	import lolo.utils.AutoUtil;
	import lolo.utils.StringUtil;

	/**
	 * 翻页组件
	 * @author LOLO
	 */
	public class Page extends Sprite implements IPage
	{
		/**首页按钮*/
		protected var _firstBtn:Button;
		/**尾页按钮*/
		protected var _lastBtn:Button;
		/**上一页按钮*/
		protected var _prevBtn:Button;
		/**下一页按钮*/
		protected var _nextBtn:Button;
		/**页码显示文本*/
		protected var _pageText:Label;
		
		/**当前页*/
		protected var _currentPage:uint;
		/**总页数*/
		protected var _totalPage:uint;
		/**页码显示文本的格式化字符串，替换符{0}表示当前页，{1}表示总页数*/
		protected var _pageTextFormat:String = "{0}/{1}";
		
		/**是否启用*/
		protected var _enabled:Boolean = true;
		
		
		public function Page()
		{
			super();
			
			_firstBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_lastBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_prevBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_nextBtn	= AutoUtil.init(new Button(), this, { enabled:false });
			_pageText	= AutoUtil.init(new Label(), this);
			
			_firstBtn.addEventListener(MouseEvent.CLICK, firstBtn_clickHandler);
			_lastBtn.addEventListener(MouseEvent.CLICK, lastBtn_clickHandler);
			_prevBtn.addEventListener(MouseEvent.CLICK, prevBtn_clickHandler);
			_nextBtn.addEventListener(MouseEvent.CLICK, nextBtn_clickHandler);
		}
		
		
		
		public function set pageTextFormat(value:String):void { _pageTextFormat = value; }
		public function get pageTextFormat():String { return _pageTextFormat; }
		
		
		public function set pageTextFormatID(value:String):void
		{
			_pageTextFormat = Common.language.getLanguage(value);
		}
		
		
		
		public function set firstBtnProp(value:Object):void
		{
			AutoUtil.initObject(_firstBtn, value);
		}
		
		public function set lastBtnProp(value:Object):void
		{
			AutoUtil.initObject(_lastBtn, value);
		}
		
		public function set prevBtnProp(value:Object):void
		{
			AutoUtil.initObject(_prevBtn, value);
		}
		
		public function set nextBtnProp(value:Object):void
		{
			AutoUtil.initObject(_nextBtn, value);
		}
		
		public function set pageTextProp(value:Object):void
		{
			AutoUtil.initObject(_pageText, value);
		}
		
		
		
		public function set currentPage(value:uint):void
		{
			_currentPage = value;
			update();
		}
		public function get currentPage():uint { return _currentPage; }
		
		
		public function set totalPage(value:uint):void
		{
			_totalPage = value;
			update();
		}
		public function get totalPage():uint { return _totalPage; }
		
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			if(!_enabled) {
				_firstBtn.enabled = _lastBtn.enabled = _prevBtn.enabled = _nextBtn.enabled = false;
			}
			else {
				update();
			}
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		public function get firstBtn():Button { return _firstBtn; }
		
		public function get lastBtn():Button { return _lastBtn; }
		
		public function get prevBtn():Button { return _prevBtn; }
		
		public function get nextBtn():Button { return _nextBtn; }
		
		public function get pageText():Label { return _pageText; }
		
		
		
		
		/**
		 * 点击首页按钮
		 * @param event
		 */
		protected function firstBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = 1;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		/**
		 * 点击尾页按钮
		 * @param event
		 */
		protected function lastBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = _totalPage;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		/**
		 * 点击上一页按钮
		 * @param event
		 */
		protected function prevBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = _currentPage - 1;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		/**
		 * 点击下一页按钮
		 * @param event
		 */
		protected function nextBtn_clickHandler(event:MouseEvent):void
		{
			currentPage = _currentPage + 1;
			this.dispatchEvent(new PageEvent(PageEvent.FLIP, _currentPage, _totalPage));
		}
		
		
		
		
		
		public function initialize(numPerPage:uint, numTotal:uint):void
		{
			_totalPage = Math.ceil(numTotal / numPerPage);
			if(_currentPage == 0 && _totalPage > 0) _currentPage = 1;
			if(_currentPage > _totalPage) _currentPage = _totalPage;
			update();
		}
		
		
		public function update():void
		{
			_firstBtn.enabled	= _enabled && _currentPage > 1;
			_lastBtn.enabled	= _enabled && _currentPage < _totalPage;
			_prevBtn.enabled	= _firstBtn.enabled;
			_nextBtn.enabled	= _lastBtn.enabled;
			_pageText.text = StringUtil.substitute(_pageTextFormat, _currentPage, _totalPage);
		}
		
		
		public function reset():void
		{
			_totalPage = _currentPage = 0;
			update();
		}
		
		
		public function dispose():void
		{
			_pageText.dispose();
			_firstBtn.dispose();
			_lastBtn.dispose();
			_prevBtn.dispose();
			_nextBtn.dispose();
		}
		//
	}
}