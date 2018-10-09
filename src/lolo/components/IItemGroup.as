package lolo.components
{
	import flash.events.IEventDispatcher;
	/**
	 * 子项集合接口
	 * 排列（创建）子项
	 * 子项间的选中方式会互斥
	 * @author LOLO
	 */
	public interface IItemGroup extends IEventDispatcher
	{
		/**
		 * 添加一个子项
		 * @param item
		 */
		function addItem(item:IItemRenderer):void;
		
		/**
		 * 移除一个子项
		 * @param item
		 */
		function removeItem(item:IItemRenderer):void;
		
		/**
		 * 通过索引获取子项
		 * @param index
		 * @return 
		 */
		function getItemByIndex(index:int):IItemRenderer;
		
		/**
		 * 通过索引选中子项
		 * @param index 
		 */
		function selectItemByIndex(index:int):void;
		
		
		
		
		/**
		 * 当前选中的子项（设置该值时，如果value的group属性不是当前集合，或者为null，将什么都不选中）
		 */
		function set selectedItem(value:IItemRenderer):void;
		function get selectedItem():IItemRenderer;
		
		/**
		 * 当前选中子项的数据
		 */
		function get selectedItemData():*;
		
		/**
		 * 获取子项的数量<br/>
		 * <font color="red">在 List 中，该值返回的是  list.data.length</font>
		 */
		function get numItems():uint;
		
		/**
		 * 是否启用
		 */
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
		
		
		
		/**
		 * 布局方式（默认：Constants.ABSOLUTE）
		 */
		function set layout(value:String):void;
		function get layout():String;
		
		/**
		 * 水平方向子项间的像素间隔
		 */
		function set horizontalGap(value:int):void;
		function get horizontalGap():int;
		
		/**
		 * 垂直方向子项间的像素间隔
		 */
		function set verticalGap(value:int):void;
		function get verticalGap():int;
		
		/**
		 * 在对应的事件（update()、click、mouseDown）发生时，是否自动切换子项的选中状态。默认值：true
		 */
		function get autoSelectItem():Boolean;
		function set autoSelectItem(value:Boolean):void;
		
		
		
		/**
		 * 更新显示内容（在 PrerenderScheduler 的回调中）</br>
		 *  - 对子项进行排列<br/>
		 *  - List 中将根据数据创建子项
		 */
		function update():void;
		
		/**
		 * 立即更新显示内容，而不是等待 PrerenderScheduler 的回调更新
		 */
		function updateNow():void;
		
		
		
		/**
		 * 清空
		 */
		function clear():void;
		//
	}
}