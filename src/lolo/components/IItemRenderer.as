package lolo.components
{
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;

	/**
	 * Item渲染器接口
	 * @author LOLO
	 */
	public interface IItemRenderer extends IEventDispatcher
	{
		/**x轴像素坐标*/
		function set x(value:Number):void;
		function get x():Number;
		
		/**y轴像素坐标*/
		function set y(value:Number):void;
		function get y():Number;
		
		/**实例名称*/
		function set name(value:String):void;
		function get name():String;
		
		/**对父级的引用*/
		function get parent():DisplayObjectContainer;
		
		/**是否可见*/
		function set visible(value:Boolean):void;
		function get visible():Boolean;
		
		
		/**Item的宽度*/
		function set itemWidth(value:uint):void;
		function get itemWidth():uint;
		
		/**Item的高度*/
		function set itemHeight(value:uint):void;
		function get itemHeight():uint;
		
		/**是否已选中*/
		function set selected(value:Boolean):void;
		function get selected():Boolean;
		
		/**在已选中时，是否可以取消选中*/
		function set deselect(value:Boolean):void;
		function get deselect():Boolean;
		
		/**是否启用*/
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
		
		/**数据*/
		function set data(value:*):void;
		function get data():*;
		
		/**所属的组*/
		function set group(value:IItemGroup):void;
		function get group():IItemGroup;
		
		/**在组中的索引*/
		function set index(value:uint):void;
		function get index():uint;
		
		
		
		/**
		 * 在被回收到缓存池时，回调的方法<br/>
		 * 所在的列表进行回收时，会自动调用该方法，无需手动调用
		 */
		function recover():void;
		
		/**
		 * 该ItemRenderer需要从内存中清除时，调用的方法<br/>
		 * 列表会在清理时自动调用该方法，您无需手动调用<br/>
		 * <font color="#FF0000">应重写该方法，置空引用、停止计时器、调用子组件的 dispose()方法等</font>
		 */
		function dispose():void;
		//
	}
}