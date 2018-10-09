package lolo.components
{
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;

	/**
	 * 滚动条接口
	 * @author LOLO
	 */
	public interface IScrollBar extends IEventDispatcher
	{
		/**
		 * 滚动的内容
		 */
		function set content(value:Sprite):void;
		function get content():Sprite;
		
		/**
		 * 内容的显示区域（滚动区域）{ x, y, width, height }
		 */
		function set viewableArea(value:Object):void;
		function get viewableArea():Object;
		
		/**
		 * 是否启用
		 */
		function set enabled(value:Boolean):void;
		function get enabled():Boolean;
		
		/**
		 * 显示内容是否需要侦听鼠标滑轮事件
		 */
		function set mouseWheelEnabled(value:Boolean):void;
		function get mouseWheelEnabled():Boolean;
		
		/**
		 * 滚动方向，水平(horizontal，默认)还是垂直(vertical)
		 */
		function set direction(value:String):void;
		function get direction():String;
		
		/**
		 * 滚动条的尺寸，水平时为width，垂直时为height
		 */
		function set size(value:uint):void;
		function get size():uint;
		
		/**
		 * 在显示内容尺寸改变时，是否自动隐藏或显示
		 */
		function set autoDisplay(value:Boolean):void;
		function get autoDisplay():Boolean;
		
		
		/**
		 * 是否自动调整滑块尺寸
		 */
		function set autoThumbSize(value:Boolean):void;
		function get autoThumbSize():Boolean;
		
		/**
		 * 滑块最小尺寸
		 */
		function set thumbMinSize(value:uint):void;
		function get thumbMinSize():uint;
		
		/**
		 * 一行的滚动量
		 */
		function set lineScrollSize(value:uint):void;
		function get lineScrollSize():uint;
		
		/**
		 * 一页的滚动量，默认值为0，表示自动使用显示区域的尺寸代替该值
		 */
		function set pageScrollSize(value:uint):void;
		function get pageScrollSize():uint;
		
		/**
		 * 第一次buttonDown事件后，在按repeatInterval重复buttonDown事件前，需要等待的毫秒数
		 */
		function set repeatDelay(value:uint):void;
		function get repeatDelay():uint;
		
		/**
		 * 在按钮上按住鼠标时，重复buttonDown事件的间隔毫秒数
		 */
		function set repeatInterval(value:uint):void;
		function get repeatInterval():uint;
		
		/**
		 * 轨道
		 */
		function get track():BaseButton;
		
		/**
		 * 滑块
		 */
		function get thumb():BaseButton;
		
		/**
		 * 向上或向左按钮
		 */
		function get upBtn():BaseButton;
		
		/**
		 * 向下或向右按钮
		 */
		function get downBtn():BaseButton;
		
		/**
		 * 滚动条当前是否已显示（内容尺寸是否超出了显示区域）
		 */
		function get showed():Boolean;
		
		
		
		
		/**
		 * 设置样式
		 */
		function set style(value:Object):void;
		
		/**
		 * 根据样式名称，在样式列表中获取并设置样式
		 */
		function set styleName(value:String):void;
		
		/**
		 * 向上或向左按钮的属性
		 */
		function set upBtnProp(value:Object):void;
		
		/**
		 * 向下或向右按钮的属性
		 */
		function set downBtnProp(value:Object):void;
		
		/**
		 * 轨道的属性
		 */
		function set trackProp(value:Object):void;
		
		/**
		 * 滑块的属性
		 */
		function set thumbProp(value:Object):void;
		
		
		
		/**
		 * 滚动到指定位置
		 */
		function scrollToPosition(p:int):void;
		
		/**
		 * 滚动到底部
		 */
		function scrollToBottom():void;
		
		
		
		/**
		 * 更新显示内容（在 PrerenderScheduler 的回调中）<br/>
		 * 当显示内容有变化时，可以主动调用该方法，或在显示内容中抛出 Event.CHANGE 事件
		 */
		function update():void;
		
		/**
		 * 立即更新显示内容，而不是等待 PrerenderScheduler 的回调更新
		 */
		function updateNow():void;
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		function dispose():void;
		//
	}
}