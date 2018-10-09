package lolo.components
{
	/**
	 * 翻页列表接口
	 * @author LOLO
	 */
	public interface IPageList extends IList
	{
		/**
		 * 对应的翻页组件
		 */
		function set page(value:IPage):void;
		function get page():IPage;
		
		/**
		 * 每页显示的数量
		 */
		function get numPerPage():uint;
		//
	}
}