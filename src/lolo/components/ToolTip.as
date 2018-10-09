package lolo.components
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.display.BaseTextField;
	import lolo.display.BitmapSprite;

	/**
	 * 工具提示（显示文本 + 背景）
	 * @author LOLO
	 */
	public class ToolTip extends Sprite
	{
		/**单例的实例*/
		private static var _instance:ToolTip;
		/**目标对象数据列表（以目标实例为key）*/
		private static var _targetDataList:Dictionary = new Dictionary();
		/**当前目标实例*/
		private static var _target:DisplayObject;
		/**当前使用的样式名称*/
		private static var _styleName:String;
		/**当前使用的样式*/
		private static var _style:Object;
		/**当前是否为显示状态*/
		private static var _isShow:Boolean;
		
		/**内容显示文本*/
		private var _contentText:BaseTextField;
		/**背景*/
		private var _background:BitmapSprite;
		
		
		
		/**
		 * 注册目标显示对象，让其在对应的鼠标事件中显示或隐藏toolTip
		 * @param target 要注册的目标
		 * @param text 文本内容字符串
		 * @param toolTipID 文本内容在语言包中ID
		 * @param overEventType 鼠标移到目标上的事件类型
		 * @param outEventType 鼠标从目标上移开的事件类型
		 */
		public static function register(target:DisplayObject, text:String=null, toolTipID:String=null, overEventType:String=null, outEventType:String=null):void
		{
			//还没有初始化实例
			if(_instance == null) _instance = new ToolTip(new Enforcer());
			
			//没有指定显示内容，视为取消注册
			if(text == null && toolTipID == null) {
				unregister(target);
			}
			else {
				if(_targetDataList[target] == null) _targetDataList[target] = { styleName:"toolTip" };
				_targetDataList[target].text = text;
				_targetDataList[target].toolTipID = toolTipID;
				
				//当前正在显示target的toolTip
				if(_target == target) {
					_instance.show();
				}
				else {
					_targetDataList[target].overEventType = overEventType;
					_targetDataList[target].outEventType = outEventType;
					target.addEventListener((overEventType == null) ? MouseEvent.ROLL_OVER : overEventType, rollOverHandler);
					target.addEventListener((outEventType == null) ? MouseEvent.ROLL_OUT : outEventType, rollOutHandler);
				}
			}
		}
		
		
		/**
		 * 将指定显示对象目标取消ToolTip注册
		 * @param target 要取消注册的目标
		 */
		public static function unregister(target:DisplayObject):void
		{
			if(target == _target) _instance.hide();
			var data:Object = _targetDataList[target];
			if(data != null)
			{
				target.removeEventListener((data.overEventType == null) ? MouseEvent.ROLL_OVER : data.overEventType, rollOverHandler);
				target.removeEventListener((data.outEventType == null) ? MouseEvent.ROLL_OUT : data.outEventType, rollOutHandler);
			}
			delete _targetDataList[target];
		}
		
		
		/**
		 * 为目标显示对象注册一个指定名称的样式
		 * @param target 要注册的目标
		 * @param styleName 使用的样式的名称
		 */
		public static function registerStyle(target:DisplayObject, styleName:String):void
		{
			if(_targetDataList[target] == null) _targetDataList[target] = {};
			_targetDataList[target].styleName = styleName;
		}
		
		
		/**
		 * 鼠标移到target上时
		 * @param event
		 */
		private static function rollOverHandler(event:Event):void
		{
			_target = event.currentTarget as DisplayObject;
			_instance.show();
		}
		
		/**
		 * 鼠标从target上移开时
		 * @param event
		 */
		private static function rollOutHandler(event:Event):void
		{
			_instance.hide();
		}
		
		
		
		
		public function ToolTip(enforcer:Enforcer)
		{
			super();
			if(!enforcer)
			{
				throw new Error("私有单例，外部无法直接访问实例");
				return;
			}
			
			this.mouseEnabled = this.mouseChildren = false;
			
			_background = new BitmapSprite();
			this.addChild(_background);
			
			_contentText = new BaseTextField();
			_contentText.autoSize = TextFieldAutoSize.LEFT;
			_contentText.multiline = true;
			_contentText.selectable = false;
			_contentText.mouseWheelEnabled = false;
			this.addChild(_contentText);
		}
		
		
		/**
		 * 样式
		 * @param value
		 */
		public function set style(value:Object):void
		{
			if(value.labelStyle != null) _contentText.style = value.labelStyle;
			
			if(value.background != null) _background.sourceName = value.background;
			if(value.labelPaddingLeft != null) _contentText.x = value.labelPaddingLeft;
			if(value.labelPaddingTop != null) _contentText.y = value.labelPaddingTop;
		}
		
		
		
		/**
		 * 显示
		 */
		public function show():void
		{
			var data:Object = _targetDataList[_target];
			if(data == null) return;
			
			//样式不同
			if(_styleName != data.styleName)
			{
				_styleName = data.styleName;
				_style = Common.config.getStyle(_styleName);
				this.style = _style;
			}
			
			//先设定宽度为允许的最大宽度
			_contentText.width = _style.labelMaxWidth;
			_contentText.text = (data.toolTipID == null) ? data.text : Common.language.getLanguage(data.toolTipID);
			
			//设置为当前宽度（需要增加4像素最后一个字才会不被换行）
			_contentText.width = _contentText.textWidth + 5;
			
			//根据文本的宽高，设置背景的宽高
			_background.width = _style.labelPaddingLeft + _contentText.width + _style.labelPaddingRight;
			_background.height = _style.labelPaddingTop + _contentText.height + _style.labelPaddingBottom;
			
			//如果不再显示状态
			if(!_isShow)
			{
				_isShow = true;
				TweenMax.killTweensOf(this);
				var delay:Number = (this.alpha > 0) ? 0 : _style.showDelay;
				TweenMax.to(this, _style.showEffectDuration, { alpha:1, delay:delay });
				Common.ui.addChildToLayer(this, Constants.LAYER_NAME_ALERT);
				
				stageMouseMoveHandler();
				Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			}
			
			//在指定时间后隐藏
			TweenMax.killDelayedCallsTo(hide);
			TweenMax.delayedCall(_style.hideDelay, hide);
		}
		
		
		/**
		 * 隐藏
		 */
		public function hide():void
		{
			if(_isShow)
			{
				_isShow = false;
				_target = null;
				Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
				
				TweenMax.killTweensOf(this);
				TweenMax.to(this, _style.hideEffectDuration, {alpha:0, onComplete:hideComplete});
			}
		}
		
		private function hideComplete():void
		{
			Common.ui.removeChildToLayer(this, Constants.LAYER_NAME_ALERT);
		}
		
		
		
		/**
		 * 鼠标在舞台移动
		 * @param event
		 */
		private function stageMouseMoveHandler(event:MouseEvent=null):void
		{
			if(parent == null) return;
			this.x = parent.mouseX + _style.paddingMouseX;
			this.y = parent.mouseY + _style.paddingMouseY;
			
			//超出舞台的情况
			if((this.x + this.width) > Common.ui.stageWidth) this.x = parent.mouseX - this.width;
			if((this.y + this.height) > Common.ui.stageHeight) this.y = parent.mouseY - this.height;
		}
		//
	}
}


class Enforcer {}