package lolo.components
{
	import flash.display.Sprite;
	
	import lolo.core.Constants;
	import lolo.display.BitmapSprite;
	import lolo.utils.optimize.CachePool;
	import lolo.utils.optimize.PrerenderScheduler;
	
	/**
	 * 美术字文本框（单行）</br>
	 * 根据 text 内容，逐个字符显示对应的 BitmapSprite</br>
	 * 例如：</br>
	 * 	prefix = "public.artText.num1"</br>
	 * 	text = "+1"</br>
	 * 	将会创建两个 BitmapSprite，</br>
	 * 	sourceName = "public.artText.num1.<b>+</b>" 和 "public.artText.num1.<b>1</b>"
	 * @author LOLO
	 */
	public class ArtText extends Sprite
	{
		/**默认是否平滑锯齿*/
		public static var defaultSmoothing:Boolean = false;
		
		/**设置的文本内容*/
		private var _text:String;
		/**用于设置字符 BitmapSprite.sourceName 的前缀*/
		private var _prefix:String;
		
		/**水平对齐方式，默认值：Constants.ALIGN_LEFT，可选值[Constants.ALIGN_LEFT, Constants.ALIGN_CENTER, Constants.ALIGN_RIGHT]*/
		private var _align:String = "left";
		/**垂直对齐方式，默认值：Constants.VALIGN_TOP，可选值[Constants.VALIGN_TOP, Constants.VALIGN_MIDDLE, Constants.VALIGN_BOTTOM]*/
		private var _valign:String = "top";
		
		/**字符间距*/
		private var _spacing:int = 0;
		
		/**设置的x坐标*/
		private var _x:int;
		/**设置的y坐标*/
		private var _y:int;
		
		/**是否平滑锯齿 @see lolo.components.ArtText.defaultSmoothing*/
		private var _smoothing:Boolean;
		
		
		
		/**
		 * 构造函数
		 * @param enforcer
		 */
		public function ArtText()
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			_smoothing = defaultSmoothing;
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
			if(_prefix == null || _text == null) return;
			
			//创建并显示对应的字符 BitmapSprite
			while(this.numChildren > _text.length)
				CachePool.recover(removeChildAt(numChildren - 1));
			
			while(_text.length > this.numChildren)
				addChild(CachePool.getBitmapSprite());
			
			var i:int, bs:BitmapSprite, offsetX:int;
			for(i = 0; i < _text.length; i++)
			{
				bs = this.getChildAt(i) as BitmapSprite;
				bs.sourceName = _prefix + "." + _text.charAt(i);
				bs.x = offsetX;
				offsetX += bs.width + _spacing;
				bs.smoothing = _smoothing;
			}
			
			//根据对齐方式确定最终的位置
			if(_align == Constants.ALIGN_LEFT)			super.x = _x;
			else if(_align == Constants.ALIGN_CENTER)	super.x = _x - width / 2;
			else if(_align == Constants.ALIGN_RIGHT)	super.x = _x - width;
			
			if(_valign == Constants.VALIGN_TOP)			super.y = _y;
			else if(_valign == Constants.VALIGN_MIDDLE)	super.y = _y - height / 2;
			else if(_valign == Constants.VALIGN_BOTTOM)	super.y = _y - height;
		}
		
		
		
		
		/**
		 * 内容</br>
		 * 将会根据内容，个字符显示对应的 BitmapSprite
		 */
		public function set text(value:String):void
		{
			_text = value;
			update();
		}
		
		public function get text():String { return _text; }
		
		
		/**
		 * 用于设置字符 BitmapSprite.sourceName 的前缀
		 */
		public function set prefix(value:String):void
		{
			_prefix = value;
			update();
		}
		
		public function get prefix():String { return _prefix; }
		
		
		
		
		/**
		 * 水平对齐方式，默认值：Constants.ALIGN_LEFT，可选值[Constants.ALIGN_LEFT, Constants.ALIGN_CENTER, Constants.ALIGN_RIGHT]
		 */
		public function set align(value:String):void
		{
			_align = value;
			update();
		}
		public function get align():String { return _align; }
		
		
		/**
		 * 垂直对齐方式，默认值：Constants.VALIGN_TOP，可选值[Constants.VALIGN_TOP, Constants.VALIGN_MIDDLE, Constants.VALIGN_BOTTOM]
		 */
		public function set valign(value:String):void
		{
			_valign = value;
			update();
		}
		public function get valign():String { return _valign; }
		
		
		/**
		 * 字符间距
		 */
		public function set spacing(value:int):void
		{
			_spacing = value;
			update();
		}
		public function get spacing():int { return _spacing; }
		
		
		
		/**
		 * X 坐标<br/>
		 * 设置该值时，小数位将会被四舍五入
		 */
		override public function set x(value:Number):void
		{
			_x = Math.round(value);
			update();
		}
		override public function get x():Number { return _x; }
		
		
		/**
		 * Y 坐标<br/>
		 * 设置该值时，小数位将会被四舍五入
		 */
		override public function set y(value:Number):void
		{
			_y = Math.round(value);
			update();
		}
		override public function get y():Number { return _y; }
		
		
		/**
		 * 是否平滑锯齿 @see lolo.components.ArtText.defaultSmoothing
		 */
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
			update();
		}
		public function get smoothing():Boolean { return _smoothing; }
		//
	}
}