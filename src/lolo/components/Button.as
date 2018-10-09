package lolo.components
{
	import flash.display.Shape;
	
	import lolo.core.Common;
	import lolo.display.Skin;
	import lolo.events.components.ToolTipEvent;
	import lolo.utils.AutoUtil;

	/**
	 * 文本按钮（图形皮肤 + 链接文本）
	 * @author LOLO
	 */
	public class Button extends BaseButton
	{
		/**链接文本*/
		protected var _labelText:LinkText;
		/**文本的遮罩*/
		protected var _labelMask:Shape;
		
		/**按钮的最小宽度*/
		protected var _minWidth:uint;
		/**按钮的最大宽度*/
		protected var _maxWidth:uint;
		/**按钮的最小高度*/
		protected var _minHeight:uint;
		/**按钮的最大高度*/
		protected var _maxHeight:uint;
		
		/**文本距顶像素*/
		protected var _labelPaddingTop:int;
		/**文本距底像素*/
		protected var _labelPaddingBottom:int;
		/**文本距左像素*/
		protected var _labelPaddingLeft:int;
		/**文本距右像素*/
		protected var _labelPaddingRight:int;
		
		/**文本的水平对齐方式，可选值["left", "center", "right"]*/
		protected var _labelHorizontalAlign:String = "center";
		/**文本的垂直对齐方式，可选值["top", "middle", "bottom"]*/
		protected var _labelVerticalAlign:String = "middle";
		
		/**是否自动调整大小*/
		protected var _autoSize:Boolean;
		/**是否在文本有省略时，自动显示toolTip*/
		protected var _autoToolTip:Boolean = true;
		
		/**标签文本内容在语言包的ID*/
		protected var _labelID:String = "";
		
		
		
		public function Button()
		{
			super();
			
			_labelText = new LinkText(false);
			_labelText.mouseEnabled = false;
			_labelText.mouseWheelEnabled = false;
			_labelText.autoTooltip = false;
			_labelText.addEventListener(ToolTipEvent.SHOW, labelTextShowToolTipHandler);
			
			_labelMask = new Shape();
			this.addChild(_labelMask);
			_labelText.mask = _labelMask;
		}
		
		
		override public function set style(value:Object):void
		{
			super.style = value;
			
			if(value.autoSize != null) _autoSize = value.autoSize;
			
			if(value.minWidth != null) _minWidth = value.minWidth;
			if(value.maxWidth != null) _maxWidth = value.maxWidth;
			if(value.minHeight != null) _minHeight = value.minHeight;
			if(value.maxHeight != null) _maxHeight = value.maxHeight;
			
			if(value.labelPaddingTop != null) _labelPaddingTop = value.labelPaddingTop;
			if(value.labelPaddingBottom != null) _labelPaddingBottom = value.labelPaddingBottom;
			if(value.labelPaddingLeft != null) _labelPaddingLeft = value.labelPaddingLeft;
			if(value.labelPaddingRight != null) _labelPaddingRight = value.labelPaddingRight;
			
			if(value.labelHorizontalAlign != null) _labelHorizontalAlign = value.labelHorizontalAlign;
			if(value.labelVerticalAlign != null) _labelVerticalAlign = value.labelVerticalAlign;
			
			if(value.labelStyle != null) _labelText.style = value.labelStyle;
			
			update();
		}
		
		
		override public function set skinName(value:String):void
		{
			super.skinName = value;
			this.addChild(_labelText);
		}
		
		
		/**
		 * 设置链接文本的属性
		 */
		public function set labelProps(value:Object):void
		{
			AutoUtil.initObject(_labelText, value);
			update();
		}
		
		
		override public function update():void
		{
			if(_skin == null) return;
			
			if(_labelText.originalText.length == 0) {
				super.update();
				return;
			}
			
			var w:int;
			if(_autoSize)
			{
				_labelText.width = _labelText.height = 99999;//重置宽高
				
				_width = _labelText.textWidth + _labelPaddingLeft + _labelPaddingRight;
				if(_maxWidth > 0 && _width > _maxWidth) _width = _maxWidth;
				else if(_minWidth > 0 && _width < _minWidth) _width = _minWidth;
				w = _width - _labelPaddingLeft - _labelPaddingRight;
				_labelText.width = _labelText.multiline ? (w + 4) : w;//多行，若不加上4像素，最后一个字符总是会自动换行
				
				_height = _labelText.textHeight + _labelPaddingTop + _labelPaddingBottom;
				if(_maxHeight > 0 && _height > _maxHeight) _height = _maxHeight;
				else if(_minHeight > 0 && _height < _minHeight) _height = _minHeight;
				
				_skin.width = _width;
				_skin.height = _height;
			}
			else {
				w = _width - _labelPaddingLeft - _labelPaddingRight;
				_labelText.width = _labelText.multiline ? (w + 4) : w;//多行，若不加上4像素，最后一个字符总是会自动换行
			}
			
			_labelText.height = _height - _labelPaddingTop - _labelPaddingBottom;
			
			//根据文本的水平对齐方式来确定文本的x坐标
			if(_labelHorizontalAlign == "left") {
				_labelText.x = _labelPaddingLeft;
			}
			else if(_labelHorizontalAlign == "right") {
				_labelText.x = _width - _labelPaddingRight - _labelText.textWidth;
			}
			else {
				_labelText.x = Math.round(_labelPaddingLeft + (_width - _labelPaddingLeft - _labelPaddingRight - _labelText.textWidth) / 2);
			}
			if(!_labelText.multiline) _labelText.x--;//单行，有多1像素的偏差
			
			//根据文本的垂直对齐方式来确定文本的y坐标
			if(_labelVerticalAlign == "top") {
				_labelText.y = _labelPaddingTop;
			}
			else if(_labelVerticalAlign == "bottom") {
				_labelText.y = _height - _labelPaddingBottom - _labelText.textHeight;
			}
			else {
				_labelText.y = Math.round(_labelPaddingTop + (_height - _labelPaddingTop - _labelPaddingBottom - _labelText.textHeight) / 2);
			}
			
			//绘制文本的遮罩
			_labelMask.graphics.clear();
			_labelMask.graphics.beginFill(0);
			_labelMask.graphics.drawRect(
				_labelPaddingLeft, _labelPaddingTop,
				_width - _labelPaddingLeft - _labelPaddingRight + 1,
				_height - _labelPaddingTop - _labelPaddingBottom + 2
			);//水平加上1像素，垂直加上2像素，遮罩才会显示完整
			_labelMask.graphics.endFill();
			
			super.update();
		}
		
		/**
		 * 在文本被省略时，是否自动显示toolTip
		 */
		public function set autoToolTip(value:Boolean):void
		{
			_autoToolTip = value;
			ToolTip.register(this, value ? _labelText.tooltip : null);
		}
		public function get autoToolTip():Boolean { return _autoToolTip; }
		
		
		/**
		 * 文本有省略，显示ToolTip
		 * @param event
		 */
		private function labelTextShowToolTipHandler(event:ToolTipEvent):void
		{
			if(_autoToolTip) ToolTip.register(this, event.toolTip);
		}
		
		
		override public function set state(state:String):void
		{
			super.state = state;
			
			switch(state)
			{
				case Skin.UP:
					_labelText.switchStyle(LinkText.STYlE_UP);
					break;
				case Skin.OVER:
					_labelText.switchStyle(LinkText.STYLE_OVER);
					break;
				case Skin.DOWN:
					_labelText.switchStyle(LinkText.STYLE_DOWN);
					break;
				case Skin.DISABLED:
					_labelText.switchStyle(LinkText.STYLE_DISABLED);
					break;
				case Skin.SELECTED_UP:
					_labelText.switchStyle(LinkText.STYLE_SELECTED);
					break;
				case Skin.SELECTED_OVER:
					_labelText.switchStyle(LinkText.STYLE_SELECTED);
					break;
				case Skin.SELECTED_DOWN:
					_labelText.switchStyle(LinkText.STYLE_SELECTED);
					break;
				case Skin.SELECTED_DISABLED:
					_labelText.switchStyle(LinkText.STYLE_DISABLED);
					break;
			}
			update();
		}
		
		
		
		/**
		 * 按钮的链接文本
		 */
		public function get textField():LinkText
		{
			return _labelText;
		}
		
		
		/**
		 * 标签文本的内容
		 */
		public function set label(value:String):void
		{
			if(value == null) value = "";
			_labelText.text = value;
			_labelID = "";
			update();
		}
		public function get label():String { return _labelText.originalText; }
		
		
		/**
		 * 标签文本内容在语言包的ID（将会通过ID自动到语言包中拿取对应的内容）
		 */
		public function set labelID(value:String):void
		{
			label = Common.language.getLanguage(value);
			_labelID = value;
		}
		public function get labelID():String { return _labelID; }
		
		
		/**
		 * 是否自动调整大小
		 */
		public function set autoSize(value:Boolean):void
		{
			_autoSize = value;
			update();
		}
		public function get autoSize():Boolean { return _autoSize; }
		
		
		/**
		 * 最小宽度
		 */
		public function set minWidth(value:uint):void
		{
			_minWidth = value;
			update();
		}
		public function get minWidth():uint { return _minWidth; }
		
		/**
		 * 最大宽度
		 */
		public function set maxWidth(value:uint):void
		{
			_maxWidth = value;
			update();
		}
		public function get maxWidth():uint { return _maxWidth; }
		
		/**
		 * 最小高度
		 */
		public function set minHeight(value:uint):void
		{
			_minHeight = value;
			update();
		}
		public function get minHeight():uint { return _minHeight; }
		
		/**
		 * 最大高度
		 */
		public function set maxHeight(value:uint):void
		{
			_maxHeight = value;
			update();
		}
		public function get maxHeight():uint { return _maxHeight; }
		
		
		/**
		 * 文本的水平对齐方式，可选值["left", "center", "right"]
		 */
		public function set labelHorizontalAlign(value:String):void
		{
			_labelHorizontalAlign = value;
			update();
		}
		public function get labelHorizontalAlign():String { return _labelHorizontalAlign; }
		
		/**
		 * 文本的垂直对齐方式，可选值["top", "middle", "bottom"]
		 */
		public function set labelVerticalAlign(value:String):void
		{
			_labelVerticalAlign = value;
			update();
		}
		public function get labelVerticalAlign():String { return _labelVerticalAlign; }
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		override public function dispose():void
		{
			_labelText.dispose();
			
			super.dispose();
		}
		//
	}
}