package lolo.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lolo.utils.FrameTimer;
	import lolo.utils.logging.LogSampler;
	import lolo.utils.optimize.FpsSampler;
	
	/**
	 * 内存，FPS统计面板
	 * @author LOLO
	 */
	public class Stats extends Sprite
	{
		/**byte to mb*/
		private static const BTOM:uint = 1048576;
		/**单例*/
		private static var _instance:Stats;
		
		/**统计面板的容器*/
		public var container:DisplayObjectContainer;
		
		/**背景*/
		public var background:Shape;
		/**统计信息显示文本*/
		public var infoText:TextField;
		
		/**用于定期更新*/
		private var _timer:FrameTimer;
		/**记录的内存使用值列表*/
		private var _memoryList:Array = [];
		/**记录中，最大的内存使用值*/
		private var _maxMemory:Number = 0;
		
		/**当前container中包含的容器数量*/
		private var _docCount:uint;
		/**当前container中包含的显示对象数量*/
		private var _doCount:uint;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():Stats
		{
			if(_instance == null) _instance = new Stats(new Enforcer());
			return _instance;
		}
		
		
		
		public function Stats(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Stats.getInstance()获取实例");
				return;
			}
			this.alpha = 0.3;
			this.mouseChildren = false;
			this.doubleClickEnabled = true;
			
			background = new Shape();
			this.addChild(background);
			
			infoText = new TextField();
			infoText.autoSize = "left";
			infoText.selectable = false;
			infoText.x = 5;
			infoText.y = 5;
			var textFormat:TextFormat = new TextFormat("Arial", 9, 0xFFFFFF);
			textFormat.leading = 2;
			infoText.defaultTextFormat = textFormat;
			this.addChild(infoText);
			
			background.graphics.clear();
			background.graphics.beginFill(0, 0.6);
			background.graphics.drawRect(0, 0, 1, 1);
			background.graphics.endFill();
			
			this.addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
			this.addEventListener(MouseEvent.DOUBLE_CLICK, mouseEventHandler);
			
			_timer = new FrameTimer(1000, timerHandler);
		}
		
		
		/**
		 * 鼠标相关事件处理
		 * @param event
		 */
		private function mouseEventHandler(event:MouseEvent):void
		{
			switch(event.type)
			{
				case MouseEvent.ROLL_OVER:
					this.alpha = 1;
					break;
				
				case MouseEvent.ROLL_OUT:
					this.alpha = 0.3;
					break;
				
				case MouseEvent.MOUSE_DOWN:
					this.startDrag(false, new Rectangle(0, 0, stage.stageWidth - width, stage.stageHeight - height));
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
					break;
				
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
					this.stopDrag();
					break;
				
				case MouseEvent.DOUBLE_CLICK:
					if(this.hasEventListener(MouseEvent.ROLL_OVER)) {
						this.removeEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
						this.removeEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
					}
					else {
						this.addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
						this.addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
					}
					break;
			}
		}
		
		
		/**
		 * 定时器回调，更新数据
		 * @param event
		 */
		private function timerHandler():void
		{
			//统计内存
			var mem:Number = System.totalMemory / BTOM;
			_maxMemory = Math.max(mem, _maxMemory);
			
			_memoryList.unshift(mem);
			if(_memoryList.length >= 10) _memoryList.pop();
			
			var i:int, len:int, average:Number;
			var info:String = "";
			
			average = 0;
			len = FpsSampler.FPS.length;
			for(i = 0; i < len; i++) average += FpsSampler.FPS[i];
			average = Math.round(average / len);
			info += "FPS: " + FpsSampler.fps + " / " + average + " / " + stage.frameRate + "\n";
			
			average = 0;
			len = _memoryList.length;
			for(i = 0; i < len; i++) average += _memoryList[i];
			info += "MEM: " + mem.toFixed(1) + " / " + (average / len).toFixed(1) + " / " + _maxMemory.toFixed(1) + "\n";
			info += "         " + (System.freeMemory / BTOM).toFixed(1) + " / " + (System.privateMemory / BTOM).toFixed(1) + "\n";
			
			info += "RTT: " + LogSampler.rtt + " / " + LogSampler.command + "\n";
			
			_docCount = _doCount = 0;
			countDisplayList(container);
			info += "CHILDREN: " + _doCount + " / " + _docCount + " / " + (_doCount + _docCount);
			
			infoText.text = info;
			background.width = infoText.width + 10;
			background.height = infoText.height + 10;
		}
		
		
		/**
		 * 统计容器中包含的显示对象以及容器的数量
		 * @param container
		 */
		private function countDisplayList(container:DisplayObjectContainer):void
		{
			for (var i:int=0; i < container.numChildren; i++)
			{
				var c:DisplayObjectContainer = container.getChildAt(i) as DisplayObjectContainer;
				if(c != null) {
					_docCount++;
					countDisplayList(c);
				}
				else {
					_doCount++;
				}
			}
		}
		
		
		
		/**
		 * 显示
		 */
		public function show():void
		{
			if(container != null) {
				container.addChild(this);
				FpsSampler.start();
				_timer.start();
			}
		}
		
		/**
		 * 隐藏
		 */
		public function hide():void
		{
			_timer.stop();
			FpsSampler.stop();
			if(this.parent != null) this.parent.removeChild(this);
		}
		
		
		/**
		 * 显示或者隐藏
		 */
		public function showOrHide():void
		{
			isShow ? hide() : show();
		}
		
		
		/**
		 * 获取当前是否显示
		 */
		public function get isShow():Boolean
		{
			return parent != null;
		}
		//
	}
}


class Enforcer {}