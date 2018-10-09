package lolo.components
{
	import flash.display.Shape;
	
	import lolo.display.Skin;
	import lolo.utils.AutoUtil;

	/**
	 * 图片按钮（图形皮肤 + 图片）
	 * @author LOLO
	 */
	public class ImageButton extends BaseButton
	{
		/**按钮上的图片*/
		protected var _image:Skin;
		/**图片的遮罩*/
		protected var _imageMask:Shape;
		
		/**按钮的最小宽度*/
		protected var _minWidth:uint;
		/**按钮的最大宽度*/
		protected var _maxWidth:uint;
		/**按钮的最小高度*/
		protected var _minHeight:uint;
		/**按钮的最大高度*/
		protected var _maxHeight:uint;
		
		/**图片距顶像素*/
		protected var _imagePaddingTop:int;
		/**图片距底像素*/
		protected var _imagePaddingBottom:int;
		/**图片距左像素*/
		protected var _imagePaddingLeft:int;
		/**图片距右像素*/
		protected var _imagePaddingRight:int;
		
		/**图片的水平对齐方式，可选值["left", "center", "right"]*/
		protected var _imageHorizontalAlign:String = "center";
		/**图片的垂直对齐方式，可选值["top", "middle", "bottom"]*/
		protected var _imageVerticalAlign:String = "middle";
		
		/**是否自动调整大小*/
		protected var _autoSize:Boolean;
		
		
		
		public function ImageButton()
		{
			super();
			
			_image = new Skin();
			
			_imageMask = new Shape();
			this.addChild(_imageMask);
			_image.mask = _imageMask;
		}
		
		
		override public function set style(value:Object):void
		{
			super.style = value;
			
			if(value.autoSize != null) _autoSize = value.autoSize;
			
			if(value.minWidth != null) _minWidth = value.minWidth;
			if(value.maxWidth != null) _maxWidth = value.maxWidth;
			if(value.minHeight != null) _minHeight = value.minHeight;
			if(value.maxHeight != null) _maxHeight = value.maxHeight;
			
			if(value.imagePaddingTop != null) _imagePaddingTop = value.imagePaddingTop;
			if(value.imagePaddingBottom != null) _imagePaddingBottom = value.imagePaddingBottom;
			if(value.imagePaddingLeft != null) _imagePaddingLeft = value.imagePaddingLeft;
			if(value.imagePaddingRight != null) _imagePaddingRight = value.imagePaddingRight;
			
			if(value.imageHorizontalAlign != null) _imageHorizontalAlign = value.imageHorizontalAlign;
			if(value.imageVerticalAlign != null) _imageVerticalAlign = value.imageVerticalAlign;
			
			if(value.imagePrefix != null) imagePrefix = value.imagePrefix;
			
			update();
		}
		
		
		override public function set skinName(value:String):void
		{
			super.skinName = value;
			this.addChild(_image);
		}
		
		
		/**
		 * 设置图片的属性
		 */
		public function set imageProps(value:Object):void
		{
			AutoUtil.initObject(_image, value);
			update();
		}
		
		
		override public function update():void
		{
			if(_skin == null) return;
			
			if(_autoSize)
			{
				_width = _image.width + _imagePaddingLeft + _imagePaddingRight;
				if(_maxWidth > 0 && _width > _maxWidth) _width = _maxWidth;
				else if(_minWidth > 0 && _width < _minWidth) _width = _minWidth;
				
				_height = _image.height + _imagePaddingTop + _imagePaddingBottom;
				if(_maxHeight > 0 && _height > _maxHeight) _height = _maxHeight;
				else if(_minHeight > 0 && _height < _minHeight) _height = _minHeight;
				
				_skin.width = _width;
				_skin.height = _height;
			}
			
			//根据图片的水平对齐方式来确定图片的x坐标
			if(_imageHorizontalAlign == "left") {
				_image.x = _imagePaddingLeft;
			}
			else if(_imageHorizontalAlign == "right") {
				_image.x = _width - _imagePaddingRight - _image.width;
			}
			else {
				_image.x = Math.round(_imagePaddingLeft + (_width - _imagePaddingLeft - _imagePaddingRight - _image.width) / 2);
			}
			
			//根据图片的垂直对齐方式来确定图片的y坐标
			if(_imageVerticalAlign == "top") {
				_image.y = _imagePaddingTop;
			}
			else if(_imageVerticalAlign == "bottom") {
				_image.y = _height - _imagePaddingBottom - _image.height;
			}
			else {
				_image.y = Math.round(_imagePaddingTop + (_height - _imagePaddingTop - _imagePaddingBottom - _image.height) / 2);
			}
			
			//绘制图片的遮罩
			_imageMask.graphics.clear();
			_imageMask.graphics.beginFill(0);
			_imageMask.graphics.drawRect(
				_imagePaddingLeft, _imagePaddingTop,
				_width - _imagePaddingLeft - _imagePaddingRight,
				_height - _imagePaddingTop - _imagePaddingBottom
			);
			_imageMask.graphics.endFill();
			
			super.update();
		}
		
		
		
		/**
		 * 按钮上的图片
		 */
		public function get image():Skin
		{
			return _image;
		}
		
		
		/**
		 * 按钮上的图片源名称的前缀（根据该前缀解析相对应的皮肤状态）
		 */
		public function set imagePrefix(value:String):void
		{
			if(value == _image.prefix) return;
			_image.prefix = value;
			_image.state = _skin.state;
			update();
		}
		public function get imagePrefix():String { return _image.prefix; }
		
		
		
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
		 * 图片的水平对齐方式，可选值["left", "center", "right"]
		 */
		public function set imageHorizontalAlign(value:String):void
		{
			_imageHorizontalAlign = value;
			update();
		}
		public function get imageHorizontalAlign():String { return _imageHorizontalAlign; }
		
		/**
		 * 图片的垂直对齐方式，可选值["top", "middle", "bottom"]
		 */
		public function set imageVerticalAlign(value:String):void
		{
			_imageVerticalAlign = value;
			update();
		}
		public function get imageVerticalAlign():String { return _imageVerticalAlign; }
		
		
		
		override public function set state(value:String):void
		{
			super.state = value;
			_image.state = value;
			update();
		}
		//
	}
}