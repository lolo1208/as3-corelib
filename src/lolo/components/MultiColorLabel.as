package lolo.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import lolo.effects.AsEffect;
	import lolo.utils.AutoUtil;
	
	/**
	 * 内容多色（可以是动画）显示文本
	 * @author LOLO
	 */
	public class MultiColorLabel extends Sprite
	{
		/**显示文本（遮罩）*/
		private var _textField:Label;
		/**多色彩内容（容器）*/
		private var _multiColorC:Sprite;
		/**多色彩内容的完整定义名称*/
		private var _multiColorDefinition:String;
		
		/**描边滤镜颜色*/
		private var _stroke:uint = 0x0;
		
		/**是否逐行渲染多彩内容*/
		private var _lineFill:Boolean = true;
		
		
		
		public function MultiColorLabel()
		{
			super();
			
			_textField = new Label();
			_textField.cacheAsBitmap = true;
			this.addChild(_textField);
			
			_multiColorC = new Sprite();
			_multiColorC.cacheAsBitmap = true;
			this.addChild(_multiColorC);
			
			_multiColorC.mask = _textField;
		}
		
		
		
		/**
		 * 通过设置完整定义名称，设置多色彩内容
		 * @param value
		 */
		public function set multiColor(value:String):void
		{
			if(value == _multiColorDefinition) return;
			
			if(_multiColorC.numChildren > 0) _multiColorC.removeChildAt(0);
			
			_multiColorDefinition = value;
			update();
		}
		public function get multiColor():String { return _multiColorDefinition; }
		
		
		/**
		 * 文本的内容
		 */
		public function set text(value:String):void
		{
			_textField.text = value;
			update();
		}
		public function get text():String { return _textField.text; }
		
		
		
		
		/**
		 * 显示更新
		 */
		public function update():void
		{
			if(_multiColorDefinition == null) return;
			
			//创建或删除至指定行数
			var numLines:int = _lineFill ? _textField.numLines : 1;
			while(_multiColorC.numChildren > numLines) _multiColorC.removeChildAt(0);
			while(_multiColorC.numChildren < numLines) AutoUtil.init(AutoUtil.getInstance(_multiColorDefinition), _multiColorC);
			
			//设置每个多彩显示内容的宽高，以及y坐标
			var height:int = _textField.multiline ? _textField.height / numLines : _textField.height;
			for(var i:int = 0; i < _multiColorC.numChildren; i++) {
				var mc:DisplayObject = _multiColorC.getChildAt(i);
				mc.width = _textField.width;
				mc.height = height;
				mc.y = i * height;
			}
		}
		
		
		
		/**描边滤镜颜色*/
		public function set stroke(value:String):void
		{
			//不需要描边
			if(value == "none") {
				this.filters = null;
				_stroke = 0x0;
			}else {
				_multiColorC.filters = [AsEffect.getStrokeFilter(uint(value))];
				_stroke = uint(value);
			}
		}
		public function get stroke():String { return _stroke.toString(16); }
		
		
		
		/**
		 * 设置显示文本的属性
		 * @param value
		 */
		public function set labelProp(value:Object):void
		{
			AutoUtil.initObject(_textField, value);
			update();
		}
		
		
		
		override public function set width(value:Number):void { _textField.width = value; }
		override public function get width():Number { return _textField.width; }
		
		override public function set height(value:Number):void { _textField.height = value; }
		override public function get height():Number { return _textField.height; }
		
		
		
		/**
		 * 是否逐行渲染多彩内容
		 */
		public function set lineFill(value:Boolean):void { _lineFill = value; }
		public function get lineFill():Boolean { return _lineFill; }
		
		
		/**
		 * 获取显示文本
		 */
		public function get textField():Label { return _textField; }
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		public function dispose():void
		{
			_textField.dispose();
		}
		//
	}
}