package lolo.display
{
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.LoadItemModel;
	import lolo.effects.AsEffect;
	import lolo.events.LoadEvent;
	import lolo.utils.StringUtil;
	import lolo.utils.optimize.PrerenderScheduler;
	
	
	/**
	 * 基本文本对象
	 * @author LOLO
	 */
	public class BaseTextField extends TextField
	{
		/**默认是否加载嵌入字体*/
		public static var defaultLoadEmbedFont:Boolean = true;
		/**嵌入字体信息列表 ={ url, definition, state, tfList }*/
		private static var _embedFontList:Dictionary;
		
		
		/**对齐方式，可选值["left", "right", "center"]*/
		protected var _align:String = "left";
		/**是否粗体*/
		protected var _bold:Boolean = false;
		/**颜色*/
		protected var _color:uint = 0x000000;
		/**字体*/
		protected var _font:String = "宋体";
		/**文字尺寸(像素)*/
		protected var _size:uint = 12;
		/**是否显示下划线*/
		protected var _underline:Boolean = false;
		/**行与行之间的垂直间距*/
		protected var _leading:int = 3;
		/**描边滤镜颜色*/
		protected var _stroke:uint = 0x0;
		
		/**字符格式*/
		protected var _textFormat:TextFormat;
		
		/**文本类型*/
		protected var _textType:String = "htmlText";
		/**设置的宽*/
		protected var _width:int = 0;
		/**设置的高*/
		protected var _height:int = 0;
		
		/**当前显示的文本*/
		protected var _currentText:String = "";
		/**文本内容在语言包的ID*/
		protected var _textID:String = "";
		
		/**是否使用嵌入字体*/
		protected var _embedFonts:Boolean;
		
		
		
		
		/**
		 * 初始化
		 */
		public static function initialize(config:XML=null):void
		{
			if(config == null) config = Common.loader.getResByConfigName("embedFontConfig", true);
			_embedFontList = new Dictionary();
			var children:XMLList = config.item;
			for each(var item:XML in children)
			{
				_embedFontList[String(item.@fontName)] = {
					url			: String(item.@url),//文本文件对应的url
					definition	: String(item.@definition),//在swf中的导出类
					state		: 0,//加载状态[ 0:未加载, 1:已加载, 2:加载中 ]
					tfList		: []//字体加载完成后，需要刷新的文本列表
				}
			}
		}
		
		
		/**
		 * 加载嵌入字体
		 * @param fontName 字体的名称
		 */
		public static function loadEmbedFont(fontName:String):void
		{
			var info:Object = _embedFontList[fontName];
			if(info == null) return;//没有这个嵌入字体的描述信息
			if(info.state != 0) return;//已经加载好了，或正在加载中
			
			info.state = 2;
			var lim:LoadItemModel = new LoadItemModel();
			lim.type = Constants.RES_TYPE_FONT;
			lim.parseUrl(info.url);
			lim.isSecretly = true;
			lim.priority = Constants.PRIORITY_EMBED_FONT;
			
			Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadHandler);
			Common.loader.addEventListener(LoadEvent.ALL_COMPLETE, loadHandler);
			Common.loader.add(lim);
			Common.loader.start();
		}
		
		
		/**
		 * 加载资源相关事件
		 * @param event
		 */
		private static function loadHandler(event:LoadEvent):void
		{
			var info:Object;
			if(event.type == LoadEvent.ALL_COMPLETE) {
				for each(info in _embedFontList) if(info.state == 2) return;//还有字体正在加载中
				Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loadHandler);
				Common.loader.removeEventListener(LoadEvent.ALL_COMPLETE, loadHandler);
			}
			else if(event.lim.type == Constants.RES_TYPE_FONT)
			{
				for each(info in _embedFontList) {
					if(info.url == event.lim.url)
					{
						info.state = 1;
						Font.registerFont(getDefinitionByName(info.definition) as Class);
						for(var i:int=0; i < info.tfList.length; i++) {
							PrerenderScheduler.addCallback(info.tfList[i].prerender_updateEmbedFonts);
						}
						delete info.tfList;
						break;
					}
				}
			}
		}
		
		public function prerender_updateEmbedFonts():void
		{
			this.embedFonts = this.embedFonts;
		}
		
		
		
		public function BaseTextField()
		{
			super();
			_textFormat = new TextFormat();
			this.antiAliasType = AntiAliasType.ADVANCED;
			this.style = Common.config.getStyle("textField");
		}
		
		
		
		/**
		 * 设置样式
		 */
		public function set style(value:Object):void
		{
			if(value.align != null) _align = value.align;
			if(value.bold != null) _bold = value.bold;
			if(value.color != null) _color = value.color;
			if(value.font != null) font = value.font;
			if(value.size != null) _size= value.size;
			if(value.underline != null) _underline = value.underline;
			if(value.leading != null) _leading = value.leading;
			
			if(value.stroke != null) this.stroke = value.stroke;
			if(value.embedFonts != null) this.embedFonts = value.embedFonts;
			
			update();
		}
		
		
		/**
		 * 根据样式名称，在样式列表中获取并设置样式
		 */
		public function set styleName(value:String):void
		{
			style = Common.config.getStyle(value);
		}
		
		
		
		/**对齐方式，可选值["left", "right", "center"]*/
		public function set align(value:String):void
		{
			_align = value;
			update();
		}
		public function get align():String { return _align; }
		
		/**是否粗体*/
		public function set bold(value:Boolean):void
		{
			_bold = value;
			update();
		}
		public function get bold():Boolean { return _bold; }
		
		/**颜色*/
		public function set color(value:uint):void
		{
			_color = value;
			update();
		}
		public function get color():uint { return _color; }
		
		/**字体*/
		public function set font(value:String):void
		{
			_font = value;
			if(_embedFonts) embedFonts = _embedFonts;
			else update();
		}
		public function get font():String { return _font; }
		
		/**文字尺寸(像素)*/
		public function set size(value:uint):void
		{
			_size = value;
			update();
		}
		public function get size():uint { return _size; }
		
		/**是否显示下划线*/
		public function set underline(value:Boolean):void
		{
			_underline = value;
			update();
		}
		public function get underline():Boolean { return _underline; }
		
		/**行与行之间的垂直间距*/
		public function set leading(value:int):void
		{
			_leading = value;
			update();
		}
		public function get leading():int { return _leading; }
		
		
		/**描边滤镜颜色*/
		public function set stroke(value:String):void
		{
			_stroke = uint(value);
			//不需要描边
			if(value == "none") {
				this.filters = null;
			}else {
				this.filters = [AsEffect.getStrokeFilter(_stroke)];
			}
		}
		public function get stroke():String { return StringUtil.getColorString(_stroke); }
		
		
		
		
		/**
		 * 显示当前文本，渲染style（在 PrerenderScheduler 的回调中）
		 */
		public function update():void
		{
			PrerenderScheduler.addCallback(prerender);
		}
		
		/**
		 * 立即显示当前文本，渲染style，而不是等待 PrerenderScheduler 的回调更新
		 */
		public function updateNow():void
		{
			prerender();
		}
		
		/**
		 * 即将进入渲染时的回调
		 */
		protected function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			
			_textFormat.align		= _align;
			_textFormat.bold		= _bold;
			_textFormat.font		= _font;
			_textFormat.color		= _color;
			_textFormat.size		= _size;
			_textFormat.underline	= _underline;
			_textFormat.leading		= _leading;
			this.defaultTextFormat	= _textFormat;
			super[_textType] = _currentText;
			
			resetSize();
		}
		
		
		
		/**
		 * 文本类型，可选值["text", "htmlText"]
		 * @param value
		 */		
		public function set textType(value:String):void
		{
			_textType = value;
			update();
		}
		
		
		/**
		 * 获取当前显示的文本值，包括html字符
		 * @return 
		 */		
		public function get currentText():String
		{
			return _currentText;
		}
		
		
		
		/**
		 * 设置文本显示内容
		 */
		override public function set text(value:String):void
		{
			if(value == null) value = "";
			if(value == _currentText) return;
			
			_currentText = value;
			_textID = "";
			updateNow();
		}
		
		
		/**
		 * 文本内容在语言包的ID（将会通过ID自动到语言包中拿取对应的内容）
		 */
		public function set textID(value:String):void
		{
			text = Common.language.getLanguage(value);
			_textID = value;
		}
		
		public function get textID():String { return _textID; }
		
		
		
		/**
		 * 设置文本显示html内容
		 */
		override public function set htmlText(value:String):void
		{
			var textType:String = _textType;
			_textType = "htmlText";
			this.text = value;
			_textType = textType;
		}
		
		
		
		/**
		 * 文本的宽度
		 */
		override public function set width(value:Number):void
		{
			super.width = _width = value;
		}
		
		/**
		 * 文本的高度
		 */
		override public function set height(value:Number):void
		{
			super.height = _height = value;
		}
		
		
		/**
		 * 是否为多行文本
		 */
		override public function set multiline(value:Boolean):void
		{
			super.multiline = super.wordWrap = value;
			resetSize();
		}
		
		
		/**
		 * 是否使用嵌入字体
		 */
		override public function set embedFonts(value:Boolean):void
		{
			_embedFonts = value;
			
			if(_embedFonts)
			{
				if(_embedFontList[_font] == null) {
					value = false;
				}
				else {
					var info:Object = _embedFontList[_font];
					value = info.state == 1;
					
					if(!value) info.tfList.push(this);
					
					if(defaultLoadEmbedFont && info.state == 0)
						loadEmbedFont(_font);
				}
			}
			
			super.embedFonts = value;
			update();
		}
		override public function get embedFonts():Boolean { return _embedFonts; }
		
		
		
		/**
		 * 重置文本的宽高，将宽高设定到用户指定的宽高
		 */
		protected function resetSize():void
		{
			if(_width > 0) super.width = _width;
			if(_height > 0) super.height = _height;
		}
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		public function dispose():void
		{
			if(embedFonts)
			{
				var info:Object = _embedFontList[_font];
				if(info.state != 1) {
					var list:Array = info.tfList;
					for(var i:int = 0; i < list.length; i++) {
						if(list[i] == this) {
							list.splice(i, 1);
							break;
						}
					}
				}
			}
		}
		//
	}
}