package lolo.components
{
	import flash.events.IEventDispatcher;

	/**
	 * 翻页组件接口
	 * @author LOLO
	 */
	public interface IPage extends IEventDispatcher
	{
		/**
		 * 页码显示文本的格式化字符串，替换符{0}表示当前页，{1}表示总页数
		 */
		function set pageTextFormat(value:String):void;
		function get pageTextFormat():String;
		
		/**
		 * 页码显示文本的格式化字符串的ID，将会根据该ID自动到语言包中取出内容
		 * @param value
		 */
		function set pageTextFormatID(value:String):void;
		
		
		
		/**
		 * 首页按钮的属性
		 */
		function set firstBtnProp(value:Object):void;
		
		/**
		 * 尾页按钮的属性
		 */
		function set lastBtnProp(value:Object):void;
		
		/**
		 * 上一页按钮的属性
		 */
		function set prevBtnProp(value:Object):void;
		
		/**
		 * 下一页按钮的属性
		 */
		function set nextBtnProp(value:Object):void;
		
		/**
		 * 页码显示文本的属性
		 */
		function set pageTextProp(value:Object):void;
		
		
		
		/**
		 * 首页按钮
		 */
		function get firstBtn():Button;
		
		/**
		 * 尾页按钮
		 */
		function get lastBtn():Button;
		
		/**
		 * 上一页按钮
		 */
		function get prevBtn():Button;
		
		/**
		 * 下一页按钮
		 */
		function get nextBtn():Button;
		
		/**
		 * 页码显示文本
		 */
		function get pageText():Label;
		
		
		
		/**
		 * 当前页
		 */
		function set currentPage(value:uint):void;
		function get currentPage():uint;
		
		/**
		 * 总页数
		 */
		function set totalPage(value:uint):void;
		function get totalPage():uint;
		
		/**
		 * 是否启用
		 */
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
		
		
		
		
		/**
		 * 根据数量初始化<br/>
		 * 如果有与 PageList 相关联，PageList 将会自动调用该方法
		 * @param numPerPage 每页显示的数量
		 * @param numTotal 总数量
		 */
		function initialize(numPerPage:uint, numTotal:uint):void;
		
		
		/**
		 * 显示更新
		 */
		function update():void;
		
		
		/**
		 * 重置
		 */
		function reset():void;
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		function dispose():void;
		//
	}
}