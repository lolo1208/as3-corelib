package lolo.core
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;

	/**
	 * 音频管理<br/>
	 * <font color="gray">在代码或注释中，Music 指的是背景音乐，Sound 指的是音效</font>
	 * @author LOLO
	 */
	public interface ISoundManager
	{
		/**
		 * 预加载音频
		 * @param name 音频的名称（可以包含路径，例如："effSnd/att1" 或 "bgMusic1"）
		 */
		function preload(name:String):Sound;
		
		
		/**
		 * 加载音频数据
		 * @param name 音频的名称（可以包含路径，例如："effSnd/att1" 或 "bgMusic1"）
		 * @param data 音频数据
		 */
		function loadData(name:String, data:ByteArray):Sound;
		
		
		
		/**
		 * 播放背景音乐或音效，并返回音频的SoundChannel对象
		 * @param name 音频的名称（可以包含路径，例如："effSnd/att1" 或 "bgMusic1"）
		 * @param isMusic 是否作为背景音乐播放
		 * @param repeatCount 重复播放次数（0：表示无限重复）
		 * @param replay 如果当前正在播放该音频，是否需要重新播放（该声音是否可以多个同时播放）
		 * @param stopAllMusic 是否停止所有正在播放的背景音乐
		 * @param stopAllSound 是否停止所有正在播放的音效
		 * @return 创建好的 SoundChannel对象
		 */
		function play(name:String,
					  isMusic:Boolean = false,
					  repeatCount:uint = 1,
					  replay:Boolean = true,
					  stopAllMusic:Boolean = false,
					  stopAllSound:Boolean = false
		):SoundChannel;
		
		
		/**
		 * 停止指定名称的所有音频
		 * @param name 音频的名称（可以包含路径，例如："effSnd/att1" 或 "bgMusic1"）
		 * @param fadeOut 是否以逐渐淡出的效果来停止声音
		 */
		function stop(name:String, fadeOut:Boolean=true):void;
		
		
		/**
		 * 停止所有背景音乐的播放（不包括音效）
		 * @param fadeOut 是否以逐渐淡出的效果来停止声音
		 */
		function stopAllMusic(fadeOut:Boolean=true):void;
		
		/**
		 * 停止所有音效的播放（不包括背景音乐）
		 * @param fadeOut 是否以逐渐淡出的效果来停止声音
		 */
		function stopAllSound(fadeOut:Boolean=false):void;
		
		
		/**
		 * 指定的音乐或音效是否正在播放中
		 * @param name
		 * @return 
		 */
		function hasPlaying(name:String):Boolean;
		
		
		
		/**
		 * 是否启用背景音频播放<br/>
		 * 如果为false将会停止当前所有正在播放的背景音频。该值会被保存在SO中
		 */
		function set musicEnabled(value:Boolean):void;
		function get musicEnabled():Boolean;
		
		/**
		 * 是否启用音效播放<br/>
		 * 如果为false将会停止当前所有正在播放的音效。该值会被保存在SO中
		 */
		function set soundEnabled(value:Boolean):void;
		function get soundEnabled():Boolean;
		
		
		
		/**
		 * 背景音乐的音量<br/>
		 * 音量范围从 0（静音）至 1（最大音量）。该值会被保存在SO中
		 */
		function set musicVolume(value:Number):void;
		function get musicVolume():Number;
		
		/**
		 * 音效的音量<br/>
		 * 音量范围从 0（静音）至 1（最大音量）。该值会被保存在SO中
		 */
		function set soundVolume(value:Number):void;
		function get soundVolume():Number;
		//
	}
}