package lolo.components
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObjectContainer;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.display.BaseTextField;
	
	/**
	 * 提示文本
	 * 文本会在指定时间后显示（可设置显示动画持续时间），指定时间后隐藏（可设置隐藏动画持续时间），并且可以在隐藏结束后回调指定函数
	 * @author LOLO
	 */
	public class AlertText extends BaseTextField
	{
		/**实例列表*/
		private static var _instanceList:Dictionary = new Dictionary();
		
		/**该时间后显示（该时间后播放显示动画）*/
		public var showDelay:Number;
		/**该时间后隐藏（显示动画结束到隐藏动画开始之间的间隔）*/
		public var hideDelay:Number;
		/**显示动画的持续时间（alpha）*/
		public var showEffectDuration:Number;
		/**隐藏动画的持续时间（alpha）*/
		public var hideEffectDuration:Number;
		
		/**隐藏结束后的回调函数*/
		public var callback:Function;
		/**是否在提示层显示*/
		public var alertLayerShow:Boolean = true;
		/**设定的颜色列表（style默认值["red", "green"]）*/
		public var colorList:Array;
		
		/**在实例列表中的key*/
		private var _key:*;
		/**对父级的引用*/
		private var _parent:DisplayObjectContainer;
		
		
		
		/**
		 * 通过key来获取实例
		 * @param key
		 * @return 
		 */
		public static function getInstance(key:*="common"):AlertText
		{
			if(_instanceList[key] == null)
			{
				_instanceList[key] = new AlertText();
				_instanceList[key].key = key;
			}
			return _instanceList[key];
		}
		
		
		/**
		 * 显示
		 * @param text 内容
		 * @param key 在实例列表中的key
		 * @param callback 隐藏结束后的回调函数
		 */
		public static function show(text:String, key:*="common", callback:Function=null):AlertText
		{
			var alertText:AlertText = getInstance(key);
			alertText.show(text, callback);
			return alertText;
		}
		
		
		
		public function AlertText()
		{
			super();
			
			this.selectable = false;
			this.mouseEnabled = false;
			this.mouseWheelEnabled = false;
			this.autoSize = TextFieldAutoSize.LEFT;
			
			this.style = Common.config.getStyle("alertText");
		}
		
		
		override public function set style(value:Object):void
		{
			super.style = value;
			
			if(value.colorList != null) this.colorList = value.colorList;
			if(value.showDelay != null) this.showDelay = value.showDelay;
			if(value.hideDelay != null) this.hideDelay = value.hideDelay;
			if(value.showEffectDuration != null) this.showEffectDuration = value.showEffectDuration;
			if(value.hideEffectDuration != null) this.hideEffectDuration = value.hideEffectDuration;
		}
		
		
		/**
		 * 显示
		 * @param text 内容
		 * @param callback 隐藏结束后的回调函数
		 */
		public function show(text:String, callback:Function=null):void
		{
			this.text = text;
			this.updateNow();
			this.callback = callback;
			
			TweenMax.killTweensOf(this);
			this.alpha = 0;
			TweenMax.to(this, showEffectDuration, { alpha:1, delay:showDelay });
			TweenMax.to(this, hideEffectDuration, { alpha:0, delay:showDelay + showEffectDuration + hideDelay, onComplete:hideComplete });
			
			if(alertLayerShow) {
				Common.ui.addChildToLayer(this, Constants.LAYER_NAME_ALERT);
			}
			else {
				if(this.parent) _parent = this.parent;
				if(_parent != null) _parent.addChild(this);
			}
		}
		
		
		/**
		 * 隐藏
		 * @param complete 是否为正常结束
		 */
		public function hide(complete:Boolean = false):void
		{
			TweenMax.killTweensOf(this);
			
			if(parent != null) parent.removeChild(this);
			if(alertLayerShow) _parent = null;
			
			if(complete && callback != null) {
				callback();
				callback = null;
			}
		}
		
		
		/**
		 * 隐藏动画结束
		 */
		private function hideComplete():void
		{
			if(parent != null) parent.removeChild(this);
			if(alertLayerShow) _parent = null;
			
			if(callback != null)
			{
				callback();
				callback = null;
			}
		}
		
		
		/**
		 * 移到舞台中鼠标所在位置
		 */
		public function moveToStageMousePosition():void
		{
			this.x = Common.stage.mouseX;
			this.y = Common.stage.mouseY;
		}
		
		
		/**
		 * 在实例列表中的key
		 */
		public function set key(value:*):void
		{
			if(_key != null) delete _instanceList[_key];
			
			_key = value;
			if(_key != null) _instanceList[_key] = this;
		}
		public function get key():* { return _key; }
		
		
		
		/**
		 * 通过index在colorList中获取颜色值，并设置为color属性
		 * @param value
		 */
		public function set colorIndex(value:uint):void
		{
			color = colorList[value];
		}
		
		
		
		/**
		 * 获取居中宽度
		 * @return 
		 */
		public function get centerWidth():uint
		{
			return width;
		}
		
		/**
		 * 获取居中高度
		 * @return 
		 */
		public function get centerHeight():uint
		{
			return height;
		}
		
		
		override public function set text(value:String):void
		{
			super.text = value;
			x = x;
			y = y;
		}
		
		
		override public function set x(value:Number):void
		{
			//超出舞台的情况
			super.x = (value + this.width > Common.ui.stageWidth) ? (Common.ui.stageWidth - this.width) : value;
		}
		
		override public function set y(value:Number):void
		{
			//超出舞台的情况
			super.y = (value + this.height > Common.ui.stageHeight) ? (Common.ui.stageHeight - this.height) : value;
		}
		//
	}
}