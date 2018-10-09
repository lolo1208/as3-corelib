package lolo.effects
{
	import flash.utils.Dictionary;
	
	import lolo.utils.FrameTimer;
	
	
	/**
	 * 属性动画
	 * 按照指定的数组序列更改目标的属性，并在动画播放完毕时，恢复更改的属性
	 * @author LOLO
	 */
	public class PropAnimation
	{
		/**震动动画*/
		public static const FRAMES_SHAKE:Array = [[25, "x", "y"], {x:2, y:-3}, {x:-1, y:3}, {x:1, y:2}, {x:-3, y:-2}];
		/**剧烈震动动画*/
		public static const FRAMES_STRONG_SHAKE:Array = [[25, "x", "y"], {x:4, y:-5}, {x:-3, y:5}, {x:3, y:4}, {x:-5, y:-4}];
		/**左右晃动*/
		public static const FRAMES_SLOSHING_AROUND:Array = [[25, "x"], {x:1}, {x:-1}, {x:1}, {x:-1}, {x:1}, {x:-1}, {x:1}, {x:-1}];
		/**慢速左右晃动*/
		public static const FRAMES_SLOSHING_AROUND_SLOW:Array = [[10, "x"], {x:1}, {x:-1}, {x:1}, {x:-1}, {x:1}, {x:-1}, {x:1}, {x:-1}];
		
		
		/**正在播放属性动画的目标列表*/
		private static var _targetList:Dictionary = new Dictionary();
		
		
		/**动画的施加目标*/
		private var _target:Object;
		/**默认属性（动画播放前）*/
		private var _defaultProps:Object;
		/**帧列表*/
		private var _frames:Array;
		/**当前帧编号*/
		private var _currentFrame:uint;
		/**帧频*/
		private var _fps:uint;
		/**动画当前已重复播放的次数*/
		private var _currentRepeatCount:uint;
		
		/**重复播放次数*/
		public var repeatCount:uint;
		/**动画在完成了指定重复次数，并到达了停止帧时的回调*/
		public var callback:Function;
		/**动画播放完成时，是否自动销毁*/
		public var autoDispose:Boolean;
		
		/**用于播放动画*/
		private var _timer:FrameTimer;
		
		
		
		
		/**
		 * 获取一个属性动画的实例
		 * @param target
		 * @return 
		 */
		public static function getInstance(target:Object, frames:Array=null):PropAnimation
		{
			var pa:PropAnimation = _targetList[target];
			if(pa == null) {
				pa = new PropAnimation(new Enforcer(), target);
				_targetList[target] = pa;
			}
			if(frames != null) pa.frames = frames;
			return pa;
		}
		
		
		
		/**
		 * 构造函数
		 * @param enforcer
		 */
		public function PropAnimation(enforcer:Enforcer, target:Object)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过 PropAnimation.getInstance() 获取实例");
			}
			
			_target = target;
			_timer = new FrameTimer(1000, timerHandler);
		}
		
		
		
		/**
		 * 帧到达更新时间
		 */
		private function timerHandler():void
		{
			_currentFrame++;
			
			//动画已播放完成
			if(_currentFrame >= _frames.length)
			{
				_currentRepeatCount++;
				//有指定重复播放次数，并且达到了重复播放次数
				if(repeatCount > 0 && _currentRepeatCount >= repeatCount)
				{
					_timer.stop();
					recoverDefaultProps();
					
					if(autoDispose) dispose();
					
					if(callback != null) {
						callback();
						callback = null;
					}
					return;
				}
				
				_currentFrame = 0;
				timerHandler();
			}
			else
			{
				var obj:Object = _frames[_currentFrame];
				for(var prop:String in obj) _target[prop] = obj[prop];
			}
		}
		
		
		/**
		 * 恢复默认属性
		 */
		private function recoverDefaultProps():void
		{
			for(var prop:String in _defaultProps) _target[prop] = _defaultProps[prop];
		}
		
		
		
		/**
		 * 播放动画
		 * @param repeatCount 动画的重复播放次数（0 :无限循环）
		 */
		public function play(repeatCount:uint=1, callback:Function=null, autoDispose:Boolean=true):void
		{
			if(_timer.running) stop();
			this.repeatCount = repeatCount;
			this.callback = callback;
			this.autoDispose = autoDispose;
			
			_timer.start();
		}
		
		/**
		 * 停止播放动画，并还原属性
		 */
		public function stop():void
		{
			_timer.stop();
			_currentFrame = 0;
			_currentRepeatCount = 0;
			recoverDefaultProps();
		}
		
		
		/**
		 * 帧列表。按照该数组序列改变目标的属性值<br/>
		 * frames[0] 应该为该动画的描述：<br/>
		 * frames[0] = [ fps, prop1, prop2, ... ]
		 */
		public function set frames(value:Array):void
		{
			_frames = value;
			fps = frames[0][0];
			
			_defaultProps = {};
			for(var i:int=1; i < _frames[0].length; i++) {
				_defaultProps[_frames[0][i]] = _target[_frames[0][i]];
			}
		}
		public function get frames():Array { return _frames; }
		
		
		
		/**
		 * 帧频
		 */
		public function set fps(value:uint):void
		{
			_fps = value;
			_timer.delay = 1000 / _fps;
		}
		public function get fps():uint { return _fps; }
		
		/**
		 * 是否正在播放动画
		 */
		public function get running():Boolean { return _timer.running; }
		
		/**
		 * 当前帧编号
		 */
		public function get currentFrame():uint { return _currentFrame; }
		
		/**
		 * 动画当前已重复播放的次数
		 */
		public function get currentRepeatCount():uint { return _currentRepeatCount; }
		
		
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		public function dispose():void
		{
			stop();
			delete _targetList[_target];
		}
		//
	}
}


class Enforcer {}