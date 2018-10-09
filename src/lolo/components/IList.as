package lolo.components
{
	import lolo.data.IHashMap;

	/**
	 * 列表接口
	 * @author LOLO
	 */
	public interface IList extends IItemGroup
	{
		/**
		 * 通过数据中的索引来选中子项
		 * @param index
		 */
		function selectItemByDataIndex(index:uint):void;
		
		/**
		 * 通过数据中的键列表来选中子项
		 * @param keys
		 */
		function selectItemByDataKeys(keys:Array):void;
		
		
		
		/**
		 * 通过数据中的键来获取子项
		 * @param key
		 * @return 
		 */
		function getItemByKey(key:*):IItemRenderer;
		
		/**
		 * 通过列表中的索引，获取对应的在数据中的索引
		 * @param listIndex
		 * @return 
		 */
		function getDataIndexByListIndex(listIndex:uint):uint;
		
		
		
		/**
		 * 设置子项的数据，该方法会在设置 item.data 前，调用 item.recover()<br/>
		 * 如果设置 item.data 会导致 item 的宽高有变化，你需要主动调用 update() 方法来更新布局
		 * @param item
		 * @param data
		 */
		function setItemData(item:IItemRenderer, data:*):void;
		
		
		
		
		
		/**
		 * 数据（将根据该数据来创建子项，呈现列表）
		 */
		function set data(value:IHashMap):void;
		function get data():IHashMap;
		
		/**
		 * 子项的渲染类
		 */
		function set itemRendererClass(value:Class):void;
		function get itemRendererClass():Class;
		
		/**
		 * 列数（默认值：3）
		 */
		function set columnCount(value:uint):void;
		function get columnCount():uint;
		
		/**
		 * 行数（默认值：3）
		 */
		function set rowCount(value:uint):void;
		function get rowCount():uint;
		
		/**
		 * 刷新列表时，根据什么来选中子项，可选值["index", "key"]，默认值："index"
		 */
		function set selectMode(value:String):void;
		function get selectMode():String;
		
		/**
		 * 在还未选中过子项时，创建列表（设置数据，翻页）是否自动选中第一个子项，默认值：true
		 */
		function set autoSelectDefaultItem(value:Boolean):void;
		function get autoSelectDefaultItem():Boolean;
		
		/**
		 * 是否水平方向排序，默认值：true。<br/>
		 * ScrollList 中，该值为与 ScrollBar.direction 相对应
		 */
		function set isHorizontalSort(value:Boolean):void;
		function get isHorizontalSort():Boolean;
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		function dispose():void;
		//
	}
}