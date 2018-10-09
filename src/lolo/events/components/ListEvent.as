package lolo.events.components
{
	import flash.events.Event;
	
	import lolo.components.IItemRenderer;
	
	
	/**
	 * 子项事件
	 * @author LOLO
	 */
	public class ListEvent extends Event
	{
		/**鼠标按下子项*/
		public static const ITEM_MOUSE_DOWN:String = "itemMouseDown";
		
		/**鼠标点击子项*/
		public static const ITEM_CLICK:String = "itemClick";
		
		/**鼠标双击击子项（需要IItemRenderer自己实现，冒泡抛出）*/
		public static const ITEM_DOUBLE_CLICK:String = "itemDoubleClick";
		
		/**选中子项*/
		public static const ITEM_SELECTED:String = "itemSelected";
		
		
		
		/**渲染更新（在Event.RENDER之后）*/
		public static const RENDER:String = "listRender";
		
		
		
		/**触发事件的子项*/
		public var item:IItemRenderer;
		
		
		
		public function ListEvent(type:String, item:IItemRenderer=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.item = item;
		}
		//
	}
}