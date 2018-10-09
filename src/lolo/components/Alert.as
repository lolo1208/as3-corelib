package lolo.components
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.display.BitmapSprite;
	import lolo.events.components.CloseEvent;
	import lolo.utils.AutoUtil;
	
	/**
	 * 弹出提示框
	 * @author LOLO
	 */
	public class Alert extends Sprite
	{
		/**[确定]按钮显示的Label*/
		public static var OK:String;
		/**[取消]按钮显示的Label*/
		public static var CANCEL:String;
		/**[是]按钮显示的Label*/
		public static var YES:String;
		/**[否]按钮显示的Label*/
		public static var NO:String;
		/**[关闭]按钮显示的Label*/
		public static var CLOSE:String;
		/**[返回]按钮显示的Label*/
		public static var BACK:String;
		
		
		/**模态背景*/
		private var _modalBG:ModalBackground;
		/**背景*/
		private var _background:BitmapSprite = new BitmapSprite();
		/**按钮组容器*/
		private var _btnC:Sprite;
		
		/**内容*/
		public var text:String;
		/**按钮列表（显示的Label）*/
		public var buttons:Array;
		/**关闭弹出框时的回调函数（点击任意按钮都会关闭）*/
		public var callback:Function;
		/**是否显示模态背景*/
		public var modal:Boolean;
		/**默认按钮在按钮列表中的索引（按下空格或回车键，与点击默认按钮效果一样）*/
		public var defaultButtonIndex:uint;
		/**使用样式的名称*/
		public var styleName:String;
		
		
		
		
		/**
		 * 创建、显示提示框，并返回该提示框的实例
		 * @param text 内容
		 * @param buttons 按钮列表（显示的Label），默认为[Alert.OK]
		 * @param callback 关闭弹出框时的回调函数（点击任意按钮都会关闭）
		 * @param modal 是否显示模态背景
		 * @param defaultButtonIndex 默认按钮在按钮列表中的索引（按下空格或回车键，与点击默认按钮效果一样）
		 * @param styleName
		 * @return 使用样式的名称
		 */
		public static function show(text:String,
									buttons:Array = null,
									callback:Function = null,
									modal:Boolean = true,
									defaultButtonIndex:uint = 0,
									styleName:String = "alert"):Alert
		{
			var alert:Alert = new Alert();
			if(buttons == null) buttons = [Alert.OK];
			
			alert.text = text;
			alert.buttons = buttons;
			alert.callback = callback;
			alert.modal = modal;
			alert.defaultButtonIndex = defaultButtonIndex;
			alert.styleName = styleName;
			
			alert.show();
			return alert;
		}
		
		
		
		public function Alert()
		{
			super();
		}
		
		
		
		/**
		 * 显示
		 */
		public function show():void
		{
			dispose();
			
			var style:Object = Common.config.getStyle(styleName);
			
			//根据需要，生成模态背景
			if(modal) {
				_modalBG = new ModalBackground(this);
				if(style.modalColor != null) _modalBG.color = style.modalColor;
				if(style.modalAlpha != null) _modalBG.alpha = style.modalAlpha;
			}
			
			//生成背景
			this.addChild(_background);
			_background.sourceName = style.background;
			
			//生成内容显示文本
			var labelText:Label = AutoUtil.init(new Label(), this, style.labelProp);
			labelText.width = style.minWidth - style.labelPaddingLeft - style.labelPaddingRight;
			labelText.text = text;
			
			//根据列表生成按钮
			_btnC = AutoUtil.init(new Sprite(), this);
			var x:int = 0;
			for(var i:int = 0; i < buttons.length; i++)
			{
				var btn:Button = AutoUtil.init(new Button(), _btnC);
				btn.styleName = (i == defaultButtonIndex) ? style.defaultButtonStyleName : style.buttonStyleName;
				AutoUtil.initObject(btn, style.buttonProp);
				btn.label = buttons[i];
				btn.name = "btn" + i;
				btn.x = x;
				x += btn.width + style.buttonGap;
				
				btn.addEventListener(MouseEvent.CLICK, btn_clickHandler);
			}
			
			//内容、按钮等高度相加，已经超过了限制的最小高度，将以最大高度方式显示
			if((style.labelPaddingTop + labelText.textHeight + style.labelPaddingBottom + _btnC.height + style.buttonPaddingBottom) > style.minHeight)
			{
				labelText.width = style.maxWidth - style.labelPaddingLeft - style.labelPaddingRight;
				labelText.height = style.maxHeight - style.labelPaddingTop - style.labelPaddingBottom - _btnC.height - style.buttonPaddingBottom;
				
				_background.width = style.maxWidth;
				_background.height = style.maxHeight;
			}
			else {//最小高度方式显示
				_background.width = style.minWidth;
				_background.height = style.minHeight;
			}
			
			//计算文本的位置
			labelText.x = int((_background.width - style.labelPaddingLeft - style.labelPaddingRight - labelText.textWidth) / 2 ) + style.labelPaddingLeft;
			labelText.y = int((_background.height - style.labelPaddingTop - style.labelPaddingBottom - _btnC.height - style.buttonPaddingBottom - labelText.textHeight) / 2) + style.labelPaddingTop;
			//计算按钮组的位置（水平居中）
			_btnC.x = int((_background.width - _btnC.width) / 2);
			_btnC.y = _background.height - style.buttonPaddingBottom - _btnC.height;
			
			//生成拖动区域
			if(style.dragArea != null) {
				var da:DragArea = AutoUtil.init(new DragArea(this), this);
				da.x = style.dragArea.paddingLeft;
				da.y = style.dragArea.paddingTop;
				da.width = _background.width - style.dragArea.paddingLeft - style.dragArea.paddingRight;
				da.height = style.dragArea.height;
			}
			
			this.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			Common.layout.addStageLayout(this, {});
			Common.ui.addChildToLayer(this, Constants.LAYER_NAME_ALERT);
		}
		
		
		
		/**
		 * 鼠标点击按钮
		 * @param event
		 */
		private function btn_clickHandler(event:MouseEvent):void
		{
			dispose();
			var btn:Button = event.currentTarget as Button;
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE, btn.label);
			if(callback != null) {
				callback(e);
				callback = null;
			}
			this.dispatchEvent(e);
		}
		
		/**
		 * 键盘按下
		 * @param event
		 */
		private function keyDownHandler(event:KeyboardEvent):void
		{
			//按下回车或空格，让默认按钮派发MouseEvent.CLICK事件
			if(event.keyCode == 13 || event.keyCode == 32) {
				var btn:Button = _btnC.getChildByName("btn" + defaultButtonIndex) as Button;
				btn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
		
		/**
		 * 添加到舞台上时
		 * @param event
		 */
		private function addedToStageHandler(event:Event):void
		{
			if(stage != null) stage.focus = this;
		}
		
		
		
		override public function get width():Number { return _background.width; }
		
		override public function get height():Number { return _background.height; }
		
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		public function dispose():void
		{
			Common.layout.removeStageLayout(this);
			Common.ui.removeChildToLayer(this, Constants.LAYER_NAME_ALERT);
			
			if(this.numChildren == 0) return;
			
			if(_modalBG != null) _modalBG.dispose();
			
			this.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			for(var i:int = 0; i < _btnC.numChildren; i++) {
				var btn:Button = _btnC.getChildAt(i) as Button;
				btn.removeEventListener(MouseEvent.CLICK, btn_clickHandler);
				btn.dispose();
			}
			
			while(this.numChildren > 0) this.removeChildAt(0);
		}
		//
	}
}