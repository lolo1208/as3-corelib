package lolo.utils.optimize
{
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import lolo.components.ArtText;
	import lolo.display.Animation;
	import lolo.display.BitmapSprite;
	import lolo.effects.float.IFloat;

	/**
	 * 对象缓存池
	 * @author LOLO
	 */
	public class CachePool
	{
		/**Animation 缓存池*/
		private static var _aniPool:Vector.<Animation> = new Vector.<Animation>();
		/**BitmapSprite 缓存池*/
		private static var _bsPool:Vector.<BitmapSprite> = new Vector.<BitmapSprite>();
		/**ArtText 缓存池*/
		private static var _atPool:Vector.<ArtText> = new Vector.<ArtText>();
		/**Bitmap 缓存池*/
		private static var _bmpPool:Vector.<Bitmap> = new Vector.<Bitmap>();
		
		
		/**Point 缓存池*/
		private static var _pointPool:Vector.<Point> = new Vector.<Point>();
		/**Rectangle 缓存池*/
		private static var _rectPool:Vector.<Rectangle> = new Vector.<Rectangle>();
		
		/**同一个像素点上不能重叠的动画列表，[ani.sourceName + _ + x + _ + y] 为key*/
		private static var _aniList:Dictionary = new Dictionary(true);
		
		
		
		
		/**
		 * 获取一个 BitmapSprite 对象
		 * @param sn
		 * @param x
		 * @param y
		 * @return 
		 */
		public static function getBitmapSprite(sn:String="", x:int=0, y:int=0):BitmapSprite
		{
			var bs:BitmapSprite;
			if(_bsPool.length == 0) {
				bs = new BitmapSprite(sn);
			}
			else {
				bs = _bsPool.pop();
				if(sn != "") bs.sourceName = sn;
			}
			bs.x = x;
			bs.y = y;
			
			return bs;
		}
		
		
		/**
		 * 获取一个 Animation 对象
		 * @param sn
		 * @param x
		 * @param y
		 * @param fps
		 * @param excludeKey 使用该属性，将不会出现 sourceName 与 excludeKey 相同的动画（忽略Animation的容器是否相同）。将会使用 ani.name 记录excludeKey。如果使用该参数，请保证在回收前不会改变 ani.name 属性。
		 * @return <font color="red">注意：</font>如果 excludeKey 已经存在，将会更新已存在 ani 的 x 和 y，以及从第一帧开始播放，并返回<b>null</b>
		 */
		public static function getAnimation(sn:String="", x:int=0, y:int=0, fps:uint=0, excludeKey:String=null):Animation
		{
			var ani:Animation;
			
			//已存在 sourceName 与 excludeKey 相同的动画
			if(excludeKey != null) {
				excludeKey = sn + "_" + excludeKey;
				ani = _aniList[excludeKey];
				if(ani != null) {
					ani.x = x;
					ani.y = y;
					ani.play(1, ani.repeatCount, ani.stopFrame, ani.callback);
					return null;
				}
			}
			
			if(_aniPool.length == 0) {
				ani = new Animation(sn, fps);
			}
			else {
				ani = _aniPool.pop();
				if(sn != "") ani.sourceName = sn;
				if(fps != 0) ani.fps = fps;
			}
			ani.x = x;
			ani.y = y;
			
			if(excludeKey != null) {
				ani.name = excludeKey;
				_aniList[excludeKey] = ani;
			}
			
			return ani;
		}
		
		
		/**
		 * 获取一个 ArtText 对象
		 * @param x
		 * @param y
		 * @param align
		 * @param valign
		 * @param spacing
		 * @return 
		 */
		public static function getArtText(x:int=0, y:int=0, align:String="left", valign:String="top", spacing:int=0):ArtText
		{
			var at:ArtText = _atPool.length == 0 ? new ArtText() : _atPool.pop();
			at.x = x;
			at.y = y;
			at.align = align;
			at.valign = valign;
			at.spacing = spacing;
			return at;
		}
		
		
		
		/**
		 * 获取一个 Bitmap 对象
		 * @param x
		 * @param y
		 * @param bitmapData
		 * @return 
		 */
		public static function getBitmap(bitmapData:BitmapData=null, x:int=0, y:int=0):Bitmap
		{
			var bmp:Bitmap;
			if(_bmpPool.length == 0) {
				bmp = new Bitmap(bitmapData);
			}
			else {
				bmp = _bmpPool.pop();
				bmp.bitmapData = bitmapData;
			}
			bmp.x = x;
			bmp.y = y;
			return bmp;
		}
		
		
		
		
		
		/**
		 * 获取一个 Point 对象
		 * @param x
		 * @param y
		 * @return 
		 */
		public static function getPoint(x:Number=0, y:Number=0):Point
		{
			if(_pointPool.length == 0) {
				return new Point(x, y);
			}
			else {
				var p:Point = _pointPool.pop();
				p.setTo(x, y);
				return p;
			}
		}
		
		
		/**
		 * 获取一个 Rectangle 对象
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @return 
		 */
		public static function getRectangle(x:Number=0, y:Number=0, width:Number=0, height:Number=0):Rectangle
		{
			if(_rectPool.length == 0) {
				return new Rectangle(x, y, width, height);
			}
			else {
				var rect:Rectangle = _rectPool.pop();
				rect.setTo(x, y, width, height);
				return rect;
			}
		}
		
		
		
		
		/**
		 * 回收一个[ BitmapSprite / Animation / ArtText / Point / Rectangle ]对象。<br/>
		 * <br/>
		 * 该函数可用作事件Hander，比如：<br/>
		 * animation.addEventListener(AnimationEvent.ANIMATION_END, CachePool.recover);<br/>
		 * <br/>
		 * 也可以传入一个需要回收的对象列表，比如：recover([ bs, ani, ani, at, p, rect ]);
		 * @param obj
		 */
		public static function recover(obj:*):void
		{
			if(obj == null) return;
			
			//要回收的对象列表，循环回收
			if(obj is Array || obj is Vector)
			{
				var len:uint = obj.length;
				for(var i:int = 0; i < len; i++) recover(obj[i]);
				return;
			}
			
			//event handler
			if(obj is Event)
			{
				var event:Event = obj;
				obj = event.target;
				(obj as IEventDispatcher).removeEventListener(event.type, recover);
			}
			
			//DisplayObject相关属性重置
			if(obj is DisplayObject)
			{
				var disObj:DisplayObject = obj;
				TweenMax.killTweensOf(disObj);
				disObj.rotation = 0;
				disObj.scaleX = disObj.scaleY = 1;
				disObj.alpha = 1;
				disObj.visible = true;
				if(disObj.parent != null) disObj.parent.removeChild(disObj);
			}
			
			//各对象回收相关处理
			if(obj is Point) {
				_pointPool.push(obj);
			}
			
			else if(obj is BitmapSprite)
			{
				var bs:BitmapSprite = obj;
				bs.smoothing = false;
				_bsPool.push(bs);
			}
			
			else if(obj is Animation)
			{
				var ani:Animation = obj;
				ani.stop();
				delete _aniList[ani.name];
				ani.name = "";
				_aniPool.push(ani);
			}
			
			else if(obj is ArtText)
			{
				var at:ArtText = obj;
				at.prefix = null;
				at.text = null;
				at.smoothing = false;
				_atPool.push(at);
				
				while(at.numChildren > 0)
					CachePool.recover(at.removeChildAt(at.numChildren - 1));
			}
				
			else if(obj is Bitmap)
			{
				_bmpPool.push(obj);
			}
			
			else if(obj is Rectangle) {
				_rectPool.push(obj);
			}
		}
		
		
		/**
		 * 在浮动结束时，回收 float.target
		 * @param complete
		 * @param float
		 */
		public static function recoverAfterFloatComplete(complete:Boolean, float:IFloat):void
		{
			recover(float.target);
		}
		
		
		
		
		
		/**
		 * 清理缓存池
		 * @param type	[<br/>
		 * 					1 : Animation缓存池 和 不能重叠的动画列表<br/>
		 * 					2 : BitmapSprite缓存池<br/>
		 * 					3 : ArtText缓存池<br/>
		 * 					4 : Point缓存池<br/>
		 * 					5 : Rectangle缓存池<br/>
		 * 					6 : Bitmap缓存池<br/>
		 * 					其他值 : 所有缓存池<br/>
		 * 				]
		 */
		public static function clear(type:int=0):void
		{
			switch(type)
			{
				case 1:
					_aniPool.length = 0;
					_aniList = new Dictionary(true);
					break;
				
				case 2: _bsPool.length = 0; break;
				
				case 3: _atPool.length = 0; break;
				
				case 4: _pointPool.length = 0; break;
				
				case 5: _rectPool.length = 0; break;
				
				case 6: _bmpPool.length = 0; break;
				
				default:
					clear(1); clear(2); clear(3); clear(4); clear(5); clear(6);
			}
		}
		//
	}
}