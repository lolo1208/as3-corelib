package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.engine.BreakOpportunity;
	import flash.text.engine.FontWeight;
	
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.edit.SelectionManager;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.formats.TextDecoration;
	
	import lolo.core.Common;
	import lolo.events.components.RichTextEvent;
	import lolo.utils.AutoUtil;
	import lolo.utils.optimize.PrerenderScheduler;

	/**
	 * 可以具有丰富内容的显示文本，支持图文混排
	 * @author LOLO
	 */
	public class RichText extends Sprite
	{
		/**对其方式 @see flashx.textLayout.formats.TextAlign*/
		protected var _align:String = "left";
		/**字体的名称列表，名称之间用 “,” 进行分隔*/
		protected var _fontFamily:String = "宋体,Arial";
		/**文字尺寸（像素）*/
		protected var _size:uint = 12;
		/**颜色*/
		protected var _color:uint = 0x000000;
		/**是否粗体*/
		protected var _bold:Boolean = false;
		/**是否显示下划线*/
		protected var _underline:Boolean = false;
		/**文本的行距（值为数字或百分比）*/
		protected var _lineHeight:* = "150%";
		
		/**文本流*/
		private var _textFlow:TextFlow;
		/**容器控制器*/
		private var _containerController:ContainerController;
		/**当前段落*/
		private var _paragraph:ParagraphElement;
		
		/**布局宽度*/
		private var _compositionWidth:Number = NaN;
		/**布局高度*/
		private var _compositionHeight:Number = NaN;
		/**最大段落数*/
		private var _maxParagraph:uint = 60;
		/**是否可选*/
		private var _selectable:Boolean;
		
		
		
		
		public function RichText()
		{
			super();
			_textFlow = new TextFlow();
			_textFlow.breakOpportunity = BreakOpportunity.NONE;
			_containerController = new ContainerController(this, _compositionWidth, _compositionHeight);
			_textFlow.flowComposer.addController(_containerController);
			
			_textFlow.addEventListener(FlowElementMouseEvent.CLICK, flowElement_clickHandler);
			_textFlow.addEventListener(CompositionCompleteEvent.COMPOSITION_COMPLETE, compositionCompleteHandler);
			
			this.style = Common.config.getStyle("richText");
		}
		
		
		
		/**
		 * 样式
		 */
		public function set style(value:Object):void
		{
			if(value.align != null) this.align = value.align;
			if(value.bold != null) this.bold = value.bold;
			if(value.color != null) this.color = value.color;
			if(value.fontFamily != null) this.fontFamily = value.fontFamily;
			if(value.size != null) this.size= value.size;
			if(value.underline != null) this.underline = value.underline;
			if(value.lineHeight != null) this.lineHeight = value.lineHeight;
			
			if(value.linkNormalFormat != null) _textFlow.linkNormalFormat = value.linkNormalFormat;
			if(value.linkHoverFormat != null) _textFlow.linkHoverFormat = value.linkHoverFormat;
			if(value.linkActiveFormat != null) _textFlow.linkActiveFormat = value.linkActiveFormat;
			
			update();
		}
		
		
		
		
		/**
		 * 开始新的段落
		 */
		public function beginParagraph():void
		{
			_paragraph = new ParagraphElement();
		}
		
		
		/**
		 * 结束当前段落
		 */
		public function endParagraph():void
		{
			if(_paragraph == null) return;
			_textFlow.addChild(_paragraph);
			_paragraph = null;
			
			//第一次添加内容，重设selectable
			if(_textFlow.numChildren == 1) selectable = _selectable;
			
			//超出最大段落数时，从前面移除段落
			while(_textFlow.numChildren > _maxParagraph) _textFlow.removeChildAt(0);
			
			update();
		}
		
		
		/**
		 * 移除位于指定索引位置的段落
		 * @param index 要移除段落的位置
		 * @return 移除的段落
		 */
		public function removeParagraphAt(index:uint):ParagraphElement
		{
			var paragraph:ParagraphElement = _textFlow.removeChildAt(index) as ParagraphElement;
			update();
			return paragraph;
		}
		
		
		
		
		/**
		 * 在当前段落中添加一个文本元素
		 * @param text 文本的内容
		 * @param props 文本元素的属性 @see flashx.textLayout.elements.SpanElement
		 */
		public function appendText(text:String, props:Object=null):void
		{
			if(text == null) return;
			if(_paragraph == null) beginParagraph();
			
			var span:SpanElement = AutoUtil.init(new SpanElement(), null, props);
			span.text = text;
			span.setStyle("lineHeight", _lineHeight);
			_paragraph.addChild(span);
		}
		
		
		/**
		 * 在当前段落中添加一个链接文本元素
		 * @param text 文本的内容
		 * @param data 与链接相关联的数据（点击链接时，RichTextEvent 抛出的数据）
		 * @param spanProps 文本元素的属性 @see flashx.textLayout.elements.SpanElement
		 * @param linkProps 链接元素的属性 @see flashx.textLayout.elements.LinkElement
		 */
		public function appendLinkText(text:String, data:String=null, spanProps:Object=null, linkProps:Object=null):void
		{
			if(text == null) return;
			if(_paragraph == null) beginParagraph();
			
			var span:SpanElement = AutoUtil.init(new SpanElement(), null, spanProps);
			var link:LinkElement = AutoUtil.init(new LinkElement(), null, linkProps);
			link.target = data;
			span.text = text;
			span.setStyle("lineHeight", _lineHeight);
			link.addChild(span);
			_paragraph.addChild(link);
		}
		
		
		/**
		 * 在当前段落中添加一个图形元素
		 * @param source 图形的源
		 * @param props 图形元素的属性 @see flashx.textLayout.elements.SpanElement
		 */
		public function appendGraphic(source:DisplayObject, props:Object=null):void
		{
			if(source == null) return;
			if(_paragraph == null) beginParagraph();
			
			var graphic:InlineGraphicElement = AutoUtil.init(new InlineGraphicElement(), null, props);
			graphic.source = source;
			_paragraph.addChild(graphic);
		}
		
		
		
		
		/**
		 * 更新显示内容（在 PrerenderScheduler 的回调中）
		 */
		public function update():void
		{
			PrerenderScheduler.addCallback(prerender);
		}
		
		
		/**
		 * 立即更新显示内容，而不是等待 PrerenderScheduler 的回调更新
		 */
		public function updateNow():void
		{
			prerender();
		}
		
		
		/**
		 * 即将进入渲染时的回调
		 */	
		private function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			
			//宽高有改变
			if(_containerController.compositionWidth != _compositionWidth
				|| _containerController.compositionHeight != _compositionHeight)
				_containerController.setCompositionSize(_compositionWidth, _compositionHeight);
			
			if(_textFlow.numChildren > 0) _textFlow.flowComposer.updateAllControllers();
		}
		
		
		
		
		/**
		 * 点击内容元素
		 * @param event
		 */
		private function flowElement_clickHandler(event:FlowElementMouseEvent):void
		{
			//点击的是链接文本
			if(event.flowElement is LinkElement) {
				this.dispatchEvent(new RichTextEvent(RichTextEvent.CLICK_LINK, (event.flowElement as LinkElement).target));
			}
		}
		
		
		/**
		 * 内容重新合成
		 * @param event
		 */
		private function compositionCompleteHandler(event:CompositionCompleteEvent):void
		{
			update();
		}
		
		
		
		
		/**
		 * 是否可选
		 */
		public function set selectable(value:Boolean):void
		{
			_selectable = value;
			//没内容时，不设置，否则第一行将会为空行（endParagraph() 将会重设该值）
			if(_textFlow.numChildren == 0) return;
			_textFlow.interactionManager = _selectable ? new SelectionManager() : null;
		}
		public function get selectable():Boolean { return _selectable; }
		
		
		/**
		 * 当前段落数
		 */
		public function get numParagraph():uint { return _textFlow.numChildren; }
		
		
		/**
		 * 最大段落数
		 */
		public function set maxParagraph(value:uint):void { _maxParagraph = value; }
		public function get maxParagraph():uint { return _maxParagraph; }
		
		
		
		/**
		 * 布局宽度。默认值：NaN，表示无限宽度
		 */
		public function set compositionWidth(value:uint):void
		{
			_compositionWidth = value;
			update();
		}
		public function get compositionWidth():uint { return _compositionWidth; }
		
		/**
		 * 布局宽度。默认值：NaN，表示无限宽度
		 */
		override public function set width(value:Number):void { compositionWidth = value; }
		
		
		
		/**
		 * 布局高度。默认值：NaN，表示无限高度
		 */
		public function set compositionHeight(value:uint):void
		{
			_compositionHeight = value;
			update();
		}
		public function get compositionHeight():uint { return _compositionHeight; }
		
		/**
		 * 布局高度。默认值：NaN，表示无限高度
		 */
		override public function set height(value:Number):void { compositionHeight = value; }
		
		
		
		
		
		/**对其方式 @see flashx.textLayout.formats.TextAlign*/
		public function set align(value:String):void
		{
			_align = value;
			_textFlow.setStyle("textAlign", _align);
			update();
		}
		public function get align():String { return _align; }
		
		/**是否粗体*/
		public function set bold(value:Boolean):void
		{
			_bold = value;
			_textFlow.setStyle("fontWeight", _bold ? FontWeight.BOLD : FontWeight.NORMAL);
			update();
		}
		public function get bold():Boolean { return _bold; }
		
		/**颜色*/
		public function set color(value:uint):void
		{
			_color = value;
			_textFlow.setStyle("color", _color);
			update();
		}
		public function get color():uint { return _color; }
		
		/**字体的名称列表，名称之间用 “,” 进行分隔*/
		public function set fontFamily(value:String):void
		{
			_fontFamily = value;
			_textFlow.setStyle("fontFamily", _fontFamily);
			update();
		}
		public function get fontFamily():String { return _fontFamily; }
		
		/**文字尺寸（像素）*/
		public function set size(value:uint):void
		{
			_size = value;
			_textFlow.setStyle("fontSize", _size);
			update();
		}
		public function get size():uint { return _size; }
		
		/**是否显示下划线*/
		public function set underline(value:Boolean):void
		{
			_underline = value;
			_textFlow.setStyle("textDecoration", _underline ? TextDecoration.UNDERLINE : TextDecoration.NONE);
			update();
		}
		public function get underline():Boolean { return _underline; }
		
		/**文本的行距（值为数字或百分比）*/
		public function set lineHeight(value:*):void
		{
			_lineHeight = value;
		}
		public function get lineHeight():* { return _lineHeight; }
		
		
		
		
		/**
		 * 清除所有内容
		 */
		public function clear():void
		{
			while(this.numChildren > 0) this.removeChildAt(0);
			while(_textFlow.numChildren > 0) _textFlow.removeChildAt(0);
			update();
		}
		//
	}
}