package lolo.core
{
	import com.greensock.TweenMax;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.data.SO;
	import lolo.utils.logging.Logger;
	
	/**
	 * 音频管理<br/>
	 * <font color="gray">在代码或注释中，Music 指的是背景音乐，Sound 指的是音效</font>
	 * @author LOLO
	 */
	public class SoundManager implements ISoundManager
	{
		/**音频文件路径在UIConfig中的名称*/
		private static const PATH:String = "sound";
		/**淡出效果递减百分比*/
		private static const FADE_OUT:Array = [0.9, 0.8, 0.7, 0.55, 0.3, 0.2, 0.1];
		
		/**单例的实例*/
		private static var _instance:SoundManager;
		
		
		/**已加载的音频列表[ 音频的name为key ]*/
		private var _soundList:Dictionary;
		/**当前正在播放的音频列表[ 音频的name为key ]*/
		private var _playingList:Dictionary;
		/**当前是否已激活（没有最小化）*/
		private var _activated:Boolean = true;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():SoundManager
		{
			if(_instance == null) _instance = new SoundManager(new Enforcer());
			return _instance;
		}
		
		public function SoundManager(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过 Common.sound 获取实例");
				return;
			}
			
			_soundList = new Dictionary();
			_playingList = new Dictionary();
			
			if(SO.data.musicVolume == null) {
				SO.data.musicVolume = 1;
				SO.data.soundVolume = 1;
				SO.data.musicEnabled = true;
				SO.data.soundEnabled = true;
				SO.save();
			}
			
			Common.stage.addEventListener(Event.ACTIVATE, stage_activateHandler);
			Common.stage.addEventListener(Event.DEACTIVATE, stage_activateHandler);
		}
		
		
		
		/**
		 * 休眠、最小化，或恢复正常
		 * @param event
		 */
		private function stage_activateHandler(event:Event):void
		{
			_activated = event.type == Event.ACTIVATE;
			if(_activated) {
				setVolume(1, musicVolume);
				setVolume(2, soundVolume);
			}
			else {
				setVolume(0, 0);
			}
		}
		
		
		
		public function loadDaata(name:String, data:ByteArray):Sound
		{
			if(_soundList[name] != null) return _soundList[name];
			
			var sound:Sound = new Sound();
			data.position = 0;
			sound.loadCompressedDataFromByteArray(data, data.bytesAvailable);
			_soundList[name] = sound;
			return sound;
		}
		
		
		public function preload(name:String):Sound
		{
			if(_soundList[name] != null) return _soundList[name];
			
			var url:String = Common.getResUrl(Common.config.getUIConfig(PATH, name));
			var sound:Sound = new Sound();
			sound.addEventListener(IOErrorEvent.IO_ERROR, sound_ioErrorHandler);
			sound.load(new URLRequest(url), new SoundLoaderContext(1, true));
			_soundList[name] = sound;
			return sound;
		}
		
		
		/**
		 * 加载音频失败
		 * @param event
		 */
		private function sound_ioErrorHandler(event:IOErrorEvent):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, sound_ioErrorHandler);
			Logger.addLog("[LFW] 加载音频失败，URL: " + event.target.url, Logger.LOG_TYPE_INFO);
		}
		
		
		
		public function play(name:String,
							 isMusic:Boolean=false,
							 repeatCount:uint=1,
							 replay:Boolean=true,
							 stopAllMusic:Boolean=false,
							 stopAllSound:Boolean=false
		):SoundChannel
		{
			if(stopAllMusic) this.stopAllMusic();
			if(stopAllSound) this.stopAllSound();
			
			//是禁止播放的状态
			if(!musicEnabled && isMusic) return new SoundChannel();
			if(!soundEnabled && !isMusic) return new SoundChannel();
			
			var sound:Sound = preload(name);
			var channelList:Array = _playingList[name];
			
			//正在播放该音频，并且不需要重新播放
			if(channelList != null && !replay) {
				channelList[0].currentCount = 0;
				channelList[0].repeatCount = repeatCount;
				return channelList[0].channel;
			}
			
			//创建 SoundChannel，播放音频
			try {
				var channel:SoundChannel = sound.play();
			}
			catch(error:Error) {
				return new SoundChannel();//音频地址有误；设备有问题，不能创建声音
			}
			
			//音频无法构建，已构建的SoundChannel太多（最多32个声道）
			if(channel == null) return new SoundChannel();
			channel.addEventListener(Event.SOUND_COMPLETE, channelCompleteHandler);
			channel.soundTransform = new SoundTransform(_activated ? (isMusic ? musicVolume : soundVolume) : 0);
			
			//保存到正在播放的Channel列表
			channelList = _playingList[name];
			if(channelList == null) _playingList[name] = channelList = [];
			channelList.push({ channel:channel, repeatCount:repeatCount, currentCount:0, isMusic:isMusic });
			
			//积压了很多还没播放的channel，这个音频可能加载出错了
			if(channelList.length > 10 && sound.length == 0) stop(name);
			
			return channel;
		}
		
		/**
		 * 音频播放完成
		 * @param event
		 */
		private function channelCompleteHandler(event:Event=null, channel:SoundChannel=null):void
		{
			if(event != null) channel = event.target as SoundChannel;
			channel.removeEventListener(Event.SOUND_COMPLETE, channelCompleteHandler);
			
			var name:String, channelList:Array, i:int, info:Object;
			for(name in _playingList) {
				channelList = _playingList[name];
				for(i = 0; i < channelList.length; i++)
				{
					info = channelList[i];
					if(info.channel == channel) break;
					info = null;
				}
				if(info != null) break;
			}
			
			//还未达到指定的重复次数
			info.currentCount++;
			if(info.repeatCount == 0 || info.currentCount < info.repeatCount)
			{
				var sound:Sound = _soundList[name];
				var newChannel:SoundChannel = sound.play();
				if(newChannel != null) {
					newChannel.addEventListener(Event.SOUND_COMPLETE, channelCompleteHandler);
					newChannel.soundTransform = channel.soundTransform;
					info.channel = newChannel;
				}
				else {
					//已构建的SoundChannel太多（最多32个声道），1秒后再重新尝试
					TweenMax.delayedCall(1, channelCompleteHandler, [null, channel]);
				}
			}
			else
			{
				channelList.splice(i, 1);
				if(channelList.length == 0) delete _playingList[name];
			}
		}
		
		
		public function stop(name:String, fadeOut:Boolean=true):void
		{
			var channelList:Array = _playingList[name];
			if(channelList == null) return;
			
			for(var i:int = 0; i < channelList.length; i++)
			{
				var info:Object = channelList[i];
				var channel:SoundChannel = info.channel;
				channel.removeEventListener(Event.SOUND_COMPLETE, channelCompleteHandler);
				
				if(fadeOut) {
					this.fadeOut(channel);
				}
				else {
					channel.stop();
				}
			}
			
			delete _playingList[name];
		}
		
		
		
		public function stopAllMusic(fadeOut:Boolean=true):void
		{
			stopSound(true, fadeOut);
		}
		
		public function stopAllSound(fadeOut:Boolean=false):void
		{
			stopSound(false, fadeOut);
		}
		
		/**
		 * 停止所有 背景音乐 或 音效 的播放
		 * @param isMusic 是否为背景音乐
		 * @param fadeOut 是否以逐渐淡出的效果来停止声音
		 */
		private function stopSound(isMusic:Boolean, fadeOut:Boolean):void
		{
			//拷贝一份，进行for...in操作
			var playingList:Dictionary = new Dictionary();
			var name:String, channelList:Array, i:int, info:Object, channel:SoundChannel;
			for(name in _playingList) playingList[name] = _playingList[name];
			
			for(name in playingList) {
				channelList = playingList[name];
				for(i = 0; i < channelList.length; i++) {
					info = channelList[i];
					if(info.isMusic == isMusic)
					{
						channel = channelList[i].channel;
						channel.removeEventListener(Event.SOUND_COMPLETE, channelCompleteHandler);
						channelList.splice(i, 1);
						i--;
						
						if(fadeOut) {
							this.fadeOut(channel);
						}
						else {
							channel.stop();
						}
					}
				}
				if(channelList.length == 0) delete _playingList[name];
			}
		}
		
		
		
		/**
		 * 淡出声音
		 * @param channel 要应用淡出效果的SoundChannel对象
		 * @param count 已执行淡出效果的次数
		 * @param initVol 开始淡出时的初始音量
		 */
		public function fadeOut(channel:SoundChannel, count:int=-1, initVol:Number=0):void
		{
			if(initVol <= 0) initVol = channel.soundTransform.volume;
			if(initVol <= 0) {
				channel.stop();
				return;
			}
			
			count++;
			if(count < 0) count = 0;
			if(count < FADE_OUT.length) {
				var vol:Number = initVol * FADE_OUT[count];
				channel.soundTransform = new SoundTransform(vol);
				TweenMax.delayedCall(0.4, fadeOut, [channel, count, initVol]);
			}
			else {
				channel.stop();
			}
		}
		
		
		
		public function hasPlaying(name:String):Boolean
		{
			return _playingList[name] != null;
		}
		
		
		
		public function set musicEnabled(value:Boolean):void
		{
			if(SO.data.musicEnabled != value) {
				SO.data.musicEnabled = value;
				SO.save();
				if(!value) stopSound(true, false);
			}
		}
		public function get musicEnabled():Boolean 	{ return SO.data.musicEnabled; }
		
		
		public function set soundEnabled(value:Boolean):void
		{
			if(SO.data.soundEnabled != value) {
				SO.data.soundEnabled = value;
				SO.save();
				if(!value) stopSound(false, false);
			}
		}
		public function get soundEnabled():Boolean { return SO.data.soundEnabled; }
		
		
		
		
		public function set musicVolume(value:Number):void
		{
			if(value > 1) value = 1;
			SO.data.musicVolume = value;
			SO.save();
			setVolume(1, musicVolume);
		}
		public function get musicVolume():Number { return SO.data.musicVolume; }
		
		
		public function set soundVolume(value:Number):void
		{
			if(value > 1) value = 1;
			SO.data.soundVolume = value;
			SO.save();
			setVolume(2, soundVolume);
		}
		public function get soundVolume():Number { return SO.data.soundVolume; }
		
		
		/**
		 * 设置 背景音乐 或 音效 的音量
		 * @param type 要设置音量的channel类型 [ 0:所有，1:背景音乐，2:音效 ]
		 */
		private function setVolume(type:int, volume:Number):void
		{
			if(volume > 1) volume = 1;
			var isMusic:Boolean = (type == 1);
			var name:String, channelList:Array, i:int, info:Object, channel:SoundChannel;
			var soundTransform:SoundTransform = new SoundTransform(volume);
			for(name in _playingList) {
				channelList = _playingList[name];
				for(i = 0; i < channelList.length; i++) {
					info = channelList[i];
					if(type == 0 || info.isMusic == isMusic)
					{
						channel = channelList[i].channel;
						channel.soundTransform = soundTransform;
					}
				}
			}
		}
		//
	}
}


class Enforcer {}