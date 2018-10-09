package lolo.effects.float
{
	import flash.display.DisplayObject;

	/**
	 * 浮动效果的接口
	 * @author LOLO
	 */
	public interface IFloat
	{
		/**
		 * 应用该效果的目标
		 */
		function set target(value:DisplayObject):void;
		function get target():DisplayObject;
		
		
		/**
		 * 浮动结束后的回调函数</br>
		 * 调用该函数时，将会传递一个Boolean类型的参数，表示效果是否正常结束
		 */
		function set onComplete(value:Function):void;
		function get onComplete():Function;
		
		
		/**
		 * 开始播放浮动效果
		 */
		function start():void;
		
		
		/**
		 * 结束播放浮动效果
		 * @param complete 效果是否正常结束
		 */
		function end(complete:Boolean=false):void;
		
		
		/**
		 * 是否正在浮动中
		 */
		function get floating():Boolean;
		//
	}
}