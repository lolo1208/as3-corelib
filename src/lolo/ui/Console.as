package lolo.ui
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lolo.components.ImageLoader;
	import lolo.core.Common;
	import lolo.data.SO;
	import lolo.display.Animation;
	import lolo.display.BitmapMovieClip;
	import lolo.display.BitmapSprite;
	import lolo.events.ConsoleEvent;
	import lolo.utils.logging.Logger;
	
	/**
	 * 调试输出控制台
	 * @author LOLO
	 */
	public class Console extends Sprite
	{
		/**单例*/
		private static var _instance:Console;
		
		/**控制台的容器*/
		public var container:DisplayObjectContainer;
		
		/**背景*/
		public var background:Shape;
		/**头部，拖动区域*/
		public var head:Sprite;
		/**关闭按钮*/
		public var closeBtn:Sprite;
		/**标题显示文本*/
		public var titleText:TextField;
		/**内容显示文本*/
		public var outputText:TextField;
		/**输入文本*/
		public var inputText:TextField;
		/**输入按钮*/
		public var inputBtn:Sprite;
		/**保存按钮*/
		public var saveBtn:Sprite;
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():Console
		{
			if(_instance == null) _instance = new Console(new Enforcer());
			return _instance;
		}
		
		
		/**
		 * 将传入的参数作为字符串，追加到输出文本末尾，并显示控制台
		 * @param args
		 */
		public static function trace(...args):void
		{
			appendText.apply(null, args);
			Console.getInstance().show();
		}
		
		
		/**
		 * 将传入的参数作为字符串，追加到输出文本末尾
		 * @param args
		 */
		public static function appendText(...args):void
		{
			var console:Console = Console.getInstance();
			if(console.outputText.text != "") console.outputText.appendText("\n");
			for(var i:int = 0; i < args.length; i++)
			{
				if(i != 0) console.outputText.appendText(" ");
				if(args[i] != null) console.outputText.appendText(args[i].toString());
			}
		}
		
		/**
		 * 清除输出文本内的所有内容
		 */
		public static function clear():void
		{
			Console.getInstance().outputText.text = "";
		}
		
		/**
		 * 滚动输出文本框内容的垂直位置
		 * @param line 要滚动到的行，0表示最后一行
		 */
		public static function scrollV(line:uint=0):void
		{
			if(line == 0) line = getInstance().outputText.maxScrollV;
			getInstance().outputText.scrollV = line;
		}
		
		
		
		public function Console(enforcer:Enforcer)
		{
			super();
			if(!enforcer) {
				throw new Error("请通过Console.getInstance()获取实例");
				return;
			}
			
			background = new Shape();
			background.graphics.beginFill(0xFFFFFF, 0.8);
			background.graphics.lineStyle(0, 0x999999);
			background.graphics.drawRect(0, 0, 780, 460);
			background.graphics.endFill();
			this.addChild(background);
			
			head = new Sprite();
			head.graphics.beginFill(0xE8EAED, 0.8);
			head.graphics.drawRect(1, 1, 779, 14);
			head.graphics.beginFill(0xD6DBE3, 0.8);
			head.graphics.drawRect(1, 14, 779, 15);
			head.graphics.endFill();
			this.addChild(head);
			
			closeBtn = new Sprite();
			closeBtn.graphics.beginFill(0, 0);
			closeBtn.graphics.drawRect(-5, -5, 18, 18);
			closeBtn.graphics.endFill();
			closeBtn.graphics.lineStyle(1, 0x333333);
			closeBtn.graphics.moveTo(0, 0);
			closeBtn.graphics.lineTo(8, 8);
			closeBtn.graphics.moveTo(0, 8);
			closeBtn.graphics.lineTo(8, 0);
			closeBtn.x = 765;
			closeBtn.y = 11;
			closeBtn.buttonMode = true;
			this.addChild(closeBtn);
			
			titleText = new TextField();
			titleText.autoSize = "left";
			titleText.selectable = false;
			titleText.mouseEnabled = false;
			titleText.x = 10;
			titleText.y = 6;
			titleText.defaultTextFormat = new TextFormat("宋体", 14, 0x666666, true);
			titleText.text = "调试控制台";
			this.addChild(titleText);
			
			outputText = new TextField();
			outputText.multiline = true;
			outputText.wordWrap = true;
			outputText.defaultTextFormat = new TextFormat("宋体", 14, 0x333333, null, null, null, null, null, null, null, null, null, 4);
			outputText.type = "input";
			outputText.width = 760;
			outputText.height = 380;
			outputText.x = 10;
			outputText.y = 38;
			outputText.border = true;
			outputText.borderColor = 0xCCCCCC;
			this.addChild(outputText);
			
			inputText = new TextField();
			inputText.type = "input";
			inputText.defaultTextFormat = new TextFormat("宋体", 14, 0x333333);
			inputText.width = 760;
			inputText.height = 20;
			inputText.x = 10;
			inputText.y = 430;
			inputText.border = true;
			inputText.borderColor = 0xCCCCCC;
			this.addChild(inputText);
			
			saveBtn = new Sprite();
			saveBtn.graphics.beginFill(0, 0);
			saveBtn.graphics.drawRect(0, 0, 14, 14);
			saveBtn.graphics.endFill();
			saveBtn.graphics.lineStyle(1, 0x666666);//画最外侧的框
			saveBtn.graphics.lineTo(11, 0);
			saveBtn.graphics.lineTo(13, 2);
			saveBtn.graphics.lineTo(13, 13);
			saveBtn.graphics.lineTo(0, 13);
			saveBtn.graphics.lineTo(0, 0);
			saveBtn.graphics.endFill();
			saveBtn.graphics.moveTo(2, 13);//画下框
			saveBtn.graphics.lineTo(2, 7);
			saveBtn.graphics.lineTo(11, 7);
			saveBtn.graphics.lineTo(11, 13);
			saveBtn.graphics.lineStyle(1, 0xBBBBBB);//画下框的两条线
			saveBtn.graphics.moveTo(4, 9);
			saveBtn.graphics.lineTo(9, 9);
			saveBtn.graphics.moveTo(4, 11);
			saveBtn.graphics.lineTo(9, 11);
			saveBtn.graphics.lineStyle(1, 0x666666);//画上框
			saveBtn.graphics.moveTo(3, 1);
			saveBtn.graphics.lineTo(3, 5);
			saveBtn.graphics.lineTo(10, 5);
			saveBtn.graphics.lineTo(10, 1);
			saveBtn.graphics.lineStyle(2, 0x888888);//画上框的一条线
			saveBtn.graphics.moveTo(8, 2);
			saveBtn.graphics.lineTo(8, 3);
			saveBtn.x = 750;
			saveBtn.y = 45;
			saveBtn.alpha = 0.3;
			saveBtn.buttonMode = true;
			this.addChild(saveBtn);
			
			inputBtn = new Sprite();
			inputBtn.graphics.beginFill(0, 0);
			inputBtn.graphics.drawRect(0, 0, 15, 15);
			inputBtn.graphics.endFill();
			inputBtn.graphics.beginFill(0x666666);
			inputBtn.graphics.drawRect(0, 10, 11, 1);//长横线
			inputBtn.graphics.drawRect(1, 9, 10, 1);
			inputBtn.graphics.drawRect(2, 8, 3, 1);//左侧箭头
			inputBtn.graphics.drawRect(3, 7, 2, 1);
			inputBtn.graphics.drawRect(4, 6, 1, 1);
			inputBtn.graphics.drawRect(9, 5, 2, 4);//右侧竖线
			inputBtn.graphics.endFill();
			inputBtn.x = 753;
			inputBtn.y = 433;
			inputBtn.alpha = 0.3;
			inputBtn.buttonMode = true;
			this.addChild(inputBtn);
			
			Common.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			head.addEventListener(MouseEvent.MOUSE_DOWN, head_mouseDownHandler);
			closeBtn.addEventListener(MouseEvent.CLICK, closeBtn_clickHandler);
			
			inputText.addEventListener(KeyboardEvent.KEY_DOWN, inputText_keyDownHandler);
			inputBtn.addEventListener(MouseEvent.CLICK, inputBtn_mouseEventHandler);
			inputBtn.addEventListener(MouseEvent.MOUSE_OVER, inputBtn_mouseEventHandler);
			inputBtn.addEventListener(MouseEvent.MOUSE_OUT, inputBtn_mouseEventHandler);
			
			saveBtn.addEventListener(MouseEvent.CLICK, saveBtn_mouseEventHandler);
			saveBtn.addEventListener(MouseEvent.MOUSE_OVER, saveBtn_mouseEventHandler);
			saveBtn.addEventListener(MouseEvent.MOUSE_OUT, saveBtn_mouseEventHandler);
		}
		
		
		/**
		 * 鼠标在拖动区域按下
		 * @param event
		 */
		private function head_mouseDownHandler(event:MouseEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
			this.startDrag();
		}
		/**
		 * 拖动中松开鼠标
		 * @param event
		 */
		private function drag_mouseUpHandler(event:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
			this.stopDrag();
		}
		
		
		/**
		 * 点击关闭按钮
		 * @param event
		 */
		private function closeBtn_clickHandler(event:MouseEvent):void
		{
			hide();
		}
		
		
		
		/**
		 * 在输入框按键
		 * @param event
		 */
		private function inputText_keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == 13) inputHandler();//按下 Enter 键
		}
		
		/**
		 * 输入按钮鼠标相关事件处理
		 * @param event
		 */
		private function inputBtn_mouseEventHandler(event:MouseEvent):void
		{
			if(event.type == MouseEvent.CLICK) {
				inputHandler();
			}
			else {
				inputBtn.alpha = (event.type == MouseEvent.MOUSE_OVER) ? 1 : 0.3;
			}
		}
		
		/**
		 * 输入处理
		 * @param Event
		 */
		private function inputHandler():void
		{
			var str:String = inputText.text;
			var arr:Array = str.split(" ");
			var args:Array = [];
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++) if(arr[i] != "") args.push(arr[i]);
			if(args.length == 0) args[0] = "";
			
			var log:Object;
			switch(args[0].toLocaleLowerCase())
			{
				case "log":
					var logType:String = args[1];
					if(logType == null) logType = Logger.LOG_TYPE_DEBUG;
					var logCount:int = int(args[2]);
					if(logCount == 0) logCount = 15;
					showLog(logType, logCount);
					break;
				
				case "stats":
					Stats.getInstance().showOrHide();
					break;
				
				case "gc":
					Common.gc();
					break;
				
				case "te":
					throw new Error("这是一个由控制台抛出的，用于测试的错误！");
					break;
				
				case "sysinfo":
					clear();
					Console.trace("--------------------------[系统信息]--------------------------");
					Console.trace("OS\t\t\t\t: " + Capabilities.os);
					Console.trace("Manufacturer\t: " + Capabilities.manufacturer);
					Console.trace("PlayerType\t\t: " + Capabilities.playerType);
					Console.trace("Version\t\t\t: " + Capabilities.version);
					Console.trace("--------------------------------------------------------------");
					break;
				
				case "html":
					outputText.htmlText = outputText.text;
					break;
				
				case "cmd":
					if(SO.data.consoleCmdHistory != null) {
						clear();
						Console.trace("------------------------[CMD 历史记录]------------------------\n");
						for(i = 0; i < SO.data.consoleCmdHistory.length; i++)
							Console.trace(SO.data.consoleCmdHistory[i]);
					}
					break;
				
				case "illog":
					showLRUCacheLog(ImageLoader.log, "ImageLoader");
					break;
				
				case "bmclog":
					showLRUCacheLog(BitmapMovieClip.log, "BitmapMovieClip");
					break;
				
				case "anilog":
					showLRUCacheLog(Animation.log, "Animation");
					break;
				
				case "bslog":
					showLRUCacheLog(BitmapSprite.log, "BitmapSprite");
					break;
			}
			
			//CMD 历史记录
			if(str != "cmd") {
				if(SO.data.consoleCmdHistory == null) SO.data.consoleCmdHistory = [];
				var cmdHistory:Array = SO.data.consoleCmdHistory;
				for(i = 0; i < cmdHistory.length; i++) {
					if(cmdHistory[i] == str) {
						cmdHistory.splice(i, 1);
						break;
					}
				}
				if(cmdHistory.length >= 15) cmdHistory.pop();
				cmdHistory.unshift(str);
				SO.save();
			}
			
			
			dispatchEvent(new ConsoleEvent(ConsoleEvent.INPUT, str));
		}
		
		/**
		 * 显示LRUCache日志
		 * @param log
		 * @param type
		 */
		private function showLRUCacheLog(log:Object, type:String):void
		{
			clear();
			Console.trace("-----------------[" + type + " 的状态和日志]-----------------");
			Console.trace("缓存数\t\t\t: " + log.valueCount);
			Console.trace("占用内存\t\t: " + int(log.memory / 1024 / 1024 * 100) / 100 + " MB");
			Console.trace("总请求次数\t\t: " + log.requestCount);
			Console.trace("命中缓存次数\t: " + log.hitCacheCount);
			Console.trace("命中缓存率\t\t: " + int(log.hitCacheCount / log.requestCount * 10000) / 100 + "%");
			Console.trace("--------------------------------------------------------------");
		}
		
		
		
		/**
		 * 在舞台按键
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case 65://Ctrl+Alt+Shift+A
					if(event.ctrlKey && event.altKey && event.shiftKey) show();
					break;
				
				case 27://Esc
					hide();
					break;
			}
		}
		
		
		
		/**
		 * 显示
		 */
		public function show():void
		{
			if(container != null) {
				var center:Boolean = (this.parent == null);
				container.addChild(this);
				if(center) {
					this.x = stage.stageWidth - width >> 1;
					this.y = stage.stageHeight - height >> 1;
					if(SO.data.consoleCmdHistory != null) inputText.text = SO.data.consoleCmdHistory[0];
				}
			}
		}
		
		/**
		 * 隐藏
		 */
		public function hide():void
		{
			if(this.parent != null) this.parent.removeChild(this);
		}
		
		
		
		
		/**
		 * 保存按钮鼠标相关事件处理
		 * @param event
		 */
		private function saveBtn_mouseEventHandler(event:MouseEvent):void
		{
			if(event.type == MouseEvent.CLICK) {
				new FileReference().save(outputText.text, "ConsoleOutput.txt");
			}
			else {
				saveBtn.alpha = (event.type == MouseEvent.MOUSE_OVER) ? 1 : 0.3;
			}
		}
		
		
		
		
		
		/**
		 * 显示日志
		 * @param type 日志类型
		 * @param count 最多在控制台显示多少条日志
		 */
		public function showLog(type:String="debug", count:uint=15):void
		{
			outputText.text = "";
			
			if(type == "na" || type == "net" || type == "network") type = Logger.LOG_TYPE_NETWORK_ALL;
			else if(type == "ns") type = Logger.LOG_TYPE_NETWORK_SUCC;
			else if(type == "nf") type = Logger.LOG_TYPE_NETWORK_FAIL;
			else if(type == "np") type = Logger.LOG_TYPE_NETWORK_PUSH;
			
			var errList:Array = Logger.getLog(type);
			var i:int = errList.length;
			count = Math.max(i - count, 0);
			
			if(type == Logger.LOG_TYPE_ERROR) {
				for(; i > count; i--) {
					var log:Object = errList[i - 1];
					Console.trace("----------------------------[" + log.date + "]----------------------------");
					Console.trace("os           : " + Capabilities.os);
					Console.trace("playerType   : " + Capabilities.playerType);
					Console.trace("version      : " + Capabilities.version);
					Console.trace("errorMsg     : " + log.errorMsg);
					Console.trace("-------------------------------------------------------------------------\n");
				}
			}
			else {
				Console.trace("============================[Log Type:" + type + "]=============================\n");
				var msg:String;
				for(; i > count; i--) {
					if(errList[i - 1] is String) msg = errList[i-1];
					else msg = JSON.stringify(errList[i-1]);
					Console.trace(msg + "\n");
					if(i > count+1) Console.trace("-------------------------------------------------------------------------\n");
				}
				Console.trace("=========================================================================");
			}
		}
		//
	}
}


class Enforcer {}