package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import lolo.display.IBaseSprite;
	import lolo.events.components.ListEvent;
	
	
	/**
	 * 标签导航组件，包含一组按钮，以及对应的界面
	 * @author LOLO
	 */
	public class TabNavigator extends Sprite
	{
		/**选项卡按钮组*/
		public var tabBtnGroup:ItemGroup;
		/**界面容器*/
		public var viewContainer:Sprite;
		
		/**当前正在显示的界面的名称*/
		private var _currentViewName:String;
		
		
		
		
		
		public function TabNavigator()
		{
			viewContainer = new Sprite();
			this.addChild(viewContainer);
			
			tabBtnGroup = new ItemGroup();
			this.addChild(tabBtnGroup);
			
			tabBtnGroup.addEventListener(ListEvent.ITEM_SELECTED, tabBtnGroup_itemSelectedHandler);
		}
		
		
		/**
		 * 选项卡按钮组有按钮被选中
		 * @param event
		 */
		protected function tabBtnGroup_itemSelectedHandler(event:ListEvent):void
		{
			switchView((event.item != null) ? event.item.name : null);
		}
		
		
		/**
		 * 添加一个选项卡按钮，以及对应的界面
		 * @param tabBtn 将会添加到 tabBtnGroup 的显示列表中
		 * @param view 将会添加到 viewContainer 的显示列表中
		 * @param viewName 界面的名称，为 null 将不会设置 tabBtn.name 和 view.name 属性
		 */
		public function add(tabBtn:BaseButton, view:DisplayObjectContainer, viewName:String=null):void
		{
			tabBtnGroup.addChild(tabBtn);
			tabBtn.group = tabBtnGroup;
			
			if(view is IBaseSprite) (view as IBaseSprite).autoRemove = false;
			viewContainer.addChild(view);
			
			if(viewName != null) tabBtn.name = view.name = viewName;
		}
		
		
		/**
		 * 移除一个选项卡按钮，以及对应的界面（从 tabBtnGroup 和 viewContainer 的显示列表中移除。<font color="red">并不会销毁</font>）
		 * @param viewName
		 */
		public function remove(viewName:String):void
		{
			var disObj:DisplayObject = tabBtnGroup.getChildByName(viewName);
			if(disObj != null) tabBtnGroup.removeChild(disObj);
			
			disObj = viewContainer.getChildByName(viewName);
			if(disObj != null) viewContainer.removeChild(disObj);
		}
		
		
		
		/**
		 * 切换界面
		 * @param viewName 要切换至的界面的名称
		 */
		public function switchView(viewName:String):void
		{
			if(_currentViewName == viewName) return;
			var view:DisplayObject = currentView;
			if(view != null) {
				(view is IBaseSprite) ? (view as IBaseSprite).hide() : viewContainer.removeChild(view);
			}
			
			_currentViewName = viewName;
			view = currentView;
			if(currentView != null) {
				(view is IBaseSprite) ? (view as IBaseSprite).show() : viewContainer.addChild(view);
			}
			
			if(viewName != null) (tabBtnGroup.getChildByName(viewName) as BaseButton).selected = true;
		}
		
		
		/**
		 * 当前正在显示的界面
		 */
		public function get currentView():DisplayObjectContainer
		{
			if(_currentViewName == null) return null;
			return viewContainer.getChildByName(_currentViewName) as DisplayObjectContainer;
		}
		
		
		/**
		 * 当前正在显示的界面的名称
		 */
		public function get currentViewName():String
		{
			return _currentViewName;
		}
		
		
		
		/**
		 * 重置
		 */
		public function reset():void
		{
			switchView(null);
			if(tabBtnGroup.selectedItem) tabBtnGroup.selectedItem = null;
		}
		
		
		//
	}
}