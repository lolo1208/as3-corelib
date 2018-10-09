package lolo.components
{
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import lolo.core.Common;

	/**
	 * 链接文本
	 * 可设置"弹起"、"鼠标经过"、"鼠标按下"、"禁用"、"选中"，几种状态
	 * @author LOLO
	 */
	public class LinkText extends Label
	{
		/**弹起状态样式名称*/
		public static const STYlE_UP:String = "upStyle";
		/**鼠标经过状态样式名称*/
		public static const STYLE_OVER:String = "overStyle";
		/**鼠标按下状态样式名称*/
		public static const STYLE_DOWN:String = "downStyle";
		/**禁用状态样式名称*/
		public static const STYLE_DISABLED:String = "disabledStyle";
		/**选中状态样式名称*/
		public static const STYLE_SELECTED:String = "selectedStyle";
		
		
		/**弹起状态的文本样式*/
		public var upStyle:TextFormat		= new TextFormat();
		/**鼠标经过状态的文本样式*/
		public var overStyle:TextFormat		= new TextFormat();
		/**鼠标按下状态的文本样式*/
		public var downStyle:TextFormat		= new TextFormat();
		/**禁用状态的文本样式*/
		public var disabledStyle:TextFormat	= new TextFormat();
		/**选中状态的文本样式*/
		public var selectedStyle:TextFormat	= new TextFormat();
		
		
		/**当前文本样式*/
		protected var _currentStyle:TextFormat;
		/**是否启用，是否侦听鼠标事件自动改变状态*/
		protected var _editable:Boolean;
		
		
		
		public function LinkText(editable:Boolean = true)
		{
			super();
			this.editable = editable;
		}
		
		
		
		override public function set style(value:Object):void
		{
			super.style = value;
			
			//设置所有样式的属性
			if(value.align != null) setStyleProp("align", value.align);
			if(value.bold != null) setStyleProp("bold", value.bold);
			if(value.color != null) setStyleProp("color", value.color);
			if(value.font != null) setStyleProp("font", value.font);
			if(value.size != null) setStyleProp("size", value.size);
			if(value.underline != null) setStyleProp("underline", value.underline);
			if(value.leading != null) setStyleProp("leading", value.leading);
			
			//设置单种样式的所有属性
			if(value.upStyle != null) setStyle(STYlE_UP, value.upStyle);
			if(value.overStyle != null) setStyle(STYLE_OVER, value.overStyle);
			if(value.downStyle != null) setStyle(STYLE_DOWN, value.downStyle);
			if(value.disabledStyle != null) setStyle(STYLE_DISABLED, value.disabledStyle);
			if(value.selectedStyle != null) setStyle(STYLE_SELECTED, value.selectedStyle);
			
			_currentStyle = upStyle;
			updateNow();
		}
		
		
		override public function set align(value:String):void
		{
			setStyleProp("align", value);
			super.align = value;
		}
		
		override public function set bold(value:Boolean):void
		{
			setStyleProp("bold", value);
			super.bold = value;
		}
		
		override public function set color(value:uint):void
		{
			setStyleProp("color", value);
			super.color = value;
		}
		
		override public function set font(value:String):void
		{
			setStyleProp("font", value);
			super.font = value;
		}
		
		override public function set size(value:uint):void
		{
			setStyleProp("size", value);
			super.size = value;
		}
		
		override public function set underline(value:Boolean):void
		{
			setStyleProp("underline", value);
			super.underline = value;
		}
		
		override public function set leading(value:int):void
		{
			setStyleProp("leading", value);
			super.leading = value;
		}
		
		
		
		
		
		/**
		 * 设置单种样式的所有属性
		 * @param styleName 样式的名称
		 * @param value 样式的值
		 */
		private function setStyle(styleName:String, value:Object):void
		{
			for(var key:String in value) this[styleName][key] = value[key];
		}
		
		/**
		 * 设置所有样式的属性
		 * @param propName 属性的名称
		 * @param value 属性的值
		 */
		private function setStyleProp(propName:String, value:*):void
		{
			var arr:Array = [upStyle, overStyle, downStyle, disabledStyle, selectedStyle];
			for(var i:int = 0; i < arr.length; i++) arr[i][propName] = value;
		}
		
		
		
		override protected function prerender():void
		{
			_align		= _currentStyle.align;
			_bold		= _currentStyle.bold;
			_font		= _currentStyle.font;
			_color		= uint(_currentStyle.color);
			_size		= uint(_currentStyle.size);
			_underline	= _currentStyle.underline;
			_leading	= int(_currentStyle.leading);
			
			super.prerender();
		}
		
		
		
		/**
		 * 切换到指定样式
		 * @param styleName 样式的名称
		 */		
		public function switchStyle(styleName:String):void
		{
			if(_currentStyle == this[styleName]) return;
			
			_currentStyle = this[styleName];
			updateNow();
		}
		
		
		
		/**
		 * 是否启用，是否侦听鼠标事件自动改变状态
		 * @param value
		 */
		public function set editable(value:Boolean):void
		{
			_editable = value;
			if(_editable) {
				this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
				this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				switchStyle(STYlE_UP);
			}
			else {
				this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
				this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				switchStyle(STYLE_DISABLED);
			}
		}
		public function get editable():Boolean { return _editable; }
		
		
		
		
		/**
		 * 鼠标移上来
		 * @param event
		 */
		private function mouseOverHandler(event:MouseEvent):void
		{
			if(!event.buttonDown) switchStyle(STYLE_OVER);
		}
		
		/**
		 * 鼠标移开
		 * @param event
		 */
		private function mouseOutHandler(event:MouseEvent):void
		{
			if(!event.buttonDown) switchStyle(STYlE_UP);
		}
		
		/**
		 * 鼠标按下
		 * @param event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			switchStyle(STYLE_DOWN);
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
		}
		
		/**
		 * 鼠标在舞台上松开
		 * @param event
		 */
		private function stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
			
			if(event.target == this) {
				mouseOverHandler(event);
			}else {
				mouseOutHandler(event);
			}
		}
		//
	}
}