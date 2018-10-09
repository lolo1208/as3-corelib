package lolo.components
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.core.Common;
	import lolo.display.Skin;
	
	/**
	 * 基础按钮（图形皮肤）
	 * 在状态改变时，将皮肤切换到对应的状态
	 * @author LOLO
	 */
	public class BaseButton extends ItemRenderer
	{
		/**当鼠标滑过时，是否显示系统手形光标*/
		public static var useHandCursor:Boolean = false;
		/**鼠标点击时，播放的音效名称。默认值：null，表示不用播放*/
		public static var clickSoundName:String = null;
		
		/**皮肤*/
		protected var _skin:Skin;
		/**指定的点击区域*/
		protected var _hitArea:Sprite;
		
		/**点击区域距顶像素*/
		protected var _hitAreaPaddingTop:int;
		/**点击区域距底像素*/
		protected var _hitAreaPaddingBottom:int;
		/**点击区域距左像素*/
		protected var _hitAreaPaddingLeft:int;
		/**点击区域距右像素*/
		protected var _hitAreaPaddingRight:int;
		
		/**设置的宽度*/
		protected var _width:uint;
		/**设置的高度*/
		protected var _height:uint;
		/**在skinName改变时，是否需要自动重置宽高*/
		public var autoResetSize:Boolean = true;
		
		/**
		 * 鼠标点击时，播放的音效名称。<br/>
		 * 值为 null 时（默认），将使用 BaseButton.clickSoundName 的值<br/>
		 * 值为 "" 时（空字符串），表示不用播放
		 */
		public var clickSoundName:String = null;
		
		
		
		public function BaseButton()
		{
			super();
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = BaseButton.useHandCursor;
			
			_skin = new Skin();
			this.addChild(_skin);
		}
		
		
		/**
		 * 设置样式
		 */
		public function set style(value:Object):void
		{
			if(value.skinName != null) skinName = value.skinName;
			
			if(value.hitAreaPaddingTop != null) _hitAreaPaddingTop = value.hitAreaPaddingTop;
			if(value.hitAreaPaddingBottom != null) _hitAreaPaddingBottom = value.hitAreaPaddingBottom;
			if(value.hitAreaPaddingLeft != null) _hitAreaPaddingLeft = value.hitAreaPaddingLeft;
			if(value.hitAreaPaddingRight != null) _hitAreaPaddingRight = value.hitAreaPaddingRight;
			
			update();
		}
		
		
		/**
		 * 根据样式名称，在样式列表中获取并设置样式
		 */
		public function set styleName(value:String):void
		{
			style = Common.config.getStyle(value);
		}
		
		
		
		/**
		 * 皮肤的名称
		 */
		public function set skinName(value:String):void
		{
			_skin.autoResetSize = autoResetSize;
			_skin.skinName = value;
			
			if(super.hitArea == null) {
				super.hitArea = new Sprite();
				hitArea.alpha = 0;
				this.addChild(hitArea);
			}
			
			_skin.state = Skin.UP;
			_width = _skin.width;
			_height = _skin.height;
			_skin.autoResetSize = false;
			
			update();
			setEventListener();
		}
		public function get skinName():String { return _skin.skinName; }
		
		
		/**
		 * 皮肤
		 */
		public function get skin():Skin { return _skin; }
		
		
		override public function set hitArea(value:Sprite):void
		{
			if(hitArea != null && hitArea.parent == this) removeChild(hitArea);
			
			_hitArea = value;
			super.hitArea = value;
			
			if(hitArea != null) {
				value.alpha = 0;
				this.addChild(value);
			}
		}
		
		
		
		/**
		 * 显示更新
		 */
		public function update():void
		{
			if(_skin.skinName == null) return;
			
			//如果没有指定点击区域，根据padding绘制hitArea
			if(_hitArea == null)
			{
				hitArea.graphics.clear();
				hitArea.graphics.beginFill(0);
				hitArea.graphics.drawRect(
					_hitAreaPaddingLeft, _hitAreaPaddingTop,
					_width - _hitAreaPaddingLeft - _hitAreaPaddingRight,
					_height - _hitAreaPaddingTop - _hitAreaPaddingBottom
				);
				hitArea.graphics.endFill();
			}
		}
		
		
		
		
		/**
		 * 当前状态
		 */
		public function set state(value:String):void
		{
			if(_skin.skinName == null) return;
			_skin.state = value;
		}
		public function get state():String { return _skin.state; }
		
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			setEventListener();
		}
		
		override public function set selected(value:Boolean):void
		{
			super.selected = value;
			setEventListener();
		}
		
		
		/**
		 * 根据状态，侦听事件或解除事件的侦听
		 */
		private function setEventListener():void
		{
			if(_enabled) {
				this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				this.addEventListener(MouseEvent.CLICK, clickHandler);
				state = _selected ? Skin.SELECTED_UP : Skin.UP;
			}
			else {
				this.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
				this.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				this.removeEventListener(MouseEvent.CLICK, clickHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				state = _selected ? Skin.SELECTED_DISABLED : Skin.DISABLED;
			}
		}
		
		
		/**
		 * 鼠标移上来
		 * @param event
		 */
		protected function rollOverHandler(event:MouseEvent):void
		{
			if(_enabled && !event.buttonDown) {
				state = _selected ? Skin.SELECTED_OVER : Skin.OVER;
			}
		}
		
		
		/**
		 * 鼠标移开
		 * @param event
		 */
		protected function rollOutHandler(event:MouseEvent):void
		{
			if(_enabled && !event.buttonDown) {
				state = _selected ? Skin.SELECTED_UP : Skin.UP;
			}
		}
		
		
		/**
		 * 鼠标按下
		 * @param event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(_enabled) {
				Common.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
				state = _selected ? Skin.SELECTED_DOWN : Skin.DOWN;
			}
		}
		
		
		/**
		 * 鼠标在舞台释放
		 * @param event
		 */
		private function stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			
			if(event.target == this) {
				rollOverHandler(event);
			}
			else {
				rollOutHandler(event);
			}
		}
		
		
		/**
		 * 鼠标点击
		 * @param event
		 */
		private function clickHandler(event:MouseEvent):void
		{
			var sndName:String = (this.clickSoundName != null) ? this.clickSoundName : BaseButton.clickSoundName;
			if(sndName == null || sndName == "") return;
			Common.sound.play(sndName);
		}
		
		
		
		
		override public function set width(value:Number):void
		{
			_skin.width = _width = value;
			update();
		}
		
		override public function set height(value:Number):void
		{
			_skin.height = _height = value;
			update();
		}
		
		
		/**
		 * 重置宽高（将会置成当前皮肤的默认宽高）
		 */
		public function resetSize():void
		{
			_skin.resetSize();
			_width = _skin.width;
			_height = _skin.height;
			update();
		}
		
		
		
		
		/**
		 * 点击区域距顶像素
		 */
		public function set hitAreaPaddingTop(value:int):void
		{
			_hitAreaPaddingTop = value;
			update();
		}
		public function get hitAreaPaddingTop():int { return _hitAreaPaddingTop; }
		
		/**
		 * 点击区域距底像素
		 */
		public function set hitAreaPaddingBottom(value:int):void
		{
			_hitAreaPaddingBottom = value;
			update();
		}
		public function get hitAreaPaddingBottom():int { return _hitAreaPaddingBottom; }
		
		/**
		 * 点击区域距左像素
		 */
		public function set hitAreaPaddingLeft(value:int):void
		{
			_hitAreaPaddingLeft = value;
			update();
		}
		public function get hitAreaPaddingLeft():int { return _hitAreaPaddingLeft; }
		
		/**
		 * 点击区域距右像素
		 */
		public function set hitAreaPaddingRight(value:int):void
		{
			_hitAreaPaddingRight = value;
			update();
		}
		public function get hitAreaPaddingRight():int { return _hitAreaPaddingRight; }
		//
	}
}