package lolo.display
{
	import flash.events.IEventDispatcher;

	/**
	 * 动画统一实现的接口
	 * @author LOLO
	 */
	public interface IAnimation extends IEventDispatcher
	{
		
		/**
		 * 动画的源名称
		 */
		function set sourceName(value:String):void;
		function get sourceName():String;
		
		/**
		 * 动画的帧频
		 */
		function set fps(value:uint):void;
		function get fps():uint;
		
		/**
		 * 动画是否正在播放中
		 */
		function set playing(value:Boolean):void;
		function get playing():Boolean;
		
		/**
		 * 当前帧编号
		 */
		function set currentFrame(value:uint):void;
		function get currentFrame():uint;
		
		/**
		 * 总帧数
		 */
		function get totalFrames():uint;
		
		/**
		 * 是否反向播放动画
		 */
		function set reverse(value:Boolean):void;
		function get reverse():Boolean;
		
		/**
		 * 动画的重复播放次数（值为0时，表示无限循环）
		 */
		function set repeatCount(value:uint):void;
		function get repeatCount():uint;
		
		/**
		 * 动画当前已重复播放的次数
		 */
		function get currentRepeatCount():uint;
		
		/**
		 * 动画达到重复播放次数时的停止帧
		 */
		function set stopFrame(value:uint):void;
		function get stopFrame():uint;
		
		/**
		 * 动画在完成了指定重复次数，并到达了停止帧时的回调（异常情况将不会触发回调，如：位图数据包还未初始化，帧数为0，以及重复次数为0）
		 */
		function set callback(value:Function):void;
		function get callback():Function;
		
		/**
		 * 是否需要抛出AnimationEvent.ENTER_FRAME事件（默认不抛）
		 */
		function set dispatchEnterFrame(value:Boolean):void;
		function get dispatchEnterFrame():Boolean;
		
		
		
		
		/**
		 * 播放动画
		 * @param startFrame 动画开始帧（默认值:0 为当前帧）
		 * @param repeatCount 动画的重复播放次数（默认值:0 为无限循环）
		 * @param stopFrame 动画达到重复播放次数时的停留帧（默认值:0 为最后一帧）
		 * @param callback 动画在完成了指定重复次数，并到达了停止帧时的回调（异常情况将不会触发回调，如：位图数据包还未初始化，帧数为0，以及重复次数为0）
		 */
		function play(startFrame:uint=0, repeatCount:uint=0, stopFrame:uint=0, callback:Function=null):void;
		
		/**
		 * 停止动画的播放
		 */
		function stop():void;
		
		/**
		 * 跳转到指定帧，并继续播放
		 * @param startFrame 动画开始帧
		 * @param repeatCount 动画的重复播放次数（默认值:0 为无限循环）
		 * @param stopFrame 动画达到重复播放次数时的停留帧（默认值:0 为最后一帧）
		 * @param callback 动画在完成了指定重复次数，并到达了停止帧时的回调（异常情况将不会触发回调，如：位图数据包还未初始化，帧数为0，以及重复次数为0）
		 */
		function gotoAndPlay(value:uint, repeatCount:uint=0, stopFrame:uint=0, callback:Function=null):void;
		
		/**
		 * 跳转到指定帧，并停止动画的播放
		 */
		function gotoAndStop(value:uint):void;
		
		
		/**
		 * 立即播放下一帧（反向播放时为上一帧），并停止动画
		 */
		function nextFrame():void;
		
		/**
		 * 立即播放上一帧（反向播放时为下一帧），并停止动画
		 */
		function prevFrame():void;
		
		
		/**
		 * 异步初始化（异步加载完成后，由 MovieClipLoader 调用）
		 * @param sourceName 动画的源名称
		 */
		function asyncInitialize(sourceName:String):void;
		
		
		
		/**
		 * 释放对象，并且<b>会将动画从父级容器中移除</b>。<br/>
		 * <font color="red">如果是 ControlledMovieClip 对象，并且 mc 的类定义被加载到了新域，在丢弃时请调用该方法。</font>
		 * Animation 和 BitmapMovieClip 在丢弃时，并不需要调用该方法来达到清除内存的目的。
		 */
		function dispose():void;
		//
	}
}