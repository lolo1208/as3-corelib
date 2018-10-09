package lolo.components
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.utils.AutoUtil;
	import lolo.utils.ExternalUtil;
	import lolo.utils.FrameTimer;
	import lolo.utils.optimize.PrerenderScheduler;
	
	/**
	 * 滚动条
	 * @author LOLO
	 */
	public class ScrollBar extends Sprite implements IScrollBar
	{
		/**轨道*/
		private var _track:BaseButton;
		/**滑块*/
		private var _thumb:BaseButton;
		/**向上或向左按钮*/
		private var _upBtn:BaseButton;
		/**向下或向右按钮*/
		private var _downBtn:BaseButton;
		
		/**滚动的内容*/
		private var _content:Sprite;
		/**内容的遮罩*/
		private var _contentMask:Mask;
		/**内容的显示区域（滚动区域）*/
		private var _viewableArea:Rectangle;
		
		/**是否启用*/
		private var _enabled:Boolean = true;
		/**滚动方向，水平还是垂直*/
		private var _direction:String;
		/**滚动条的尺寸，水平时为width，垂直时为height*/
		private var _size:uint = 100;
		
		/**坐标属性的名称，水平:"x"，垂直:"y"*/
		private var _xy:String = "y";
		/**宽高属性的名称，水平:"width"，垂直:"height"*/
		private var _wh:String = "height";
		/**当前滚动状态是否为向上或向左滚动*/
		private var _scrollUp:Boolean;
		/**当前滚动状态是否为自动滚动行而不是页*/
		private var _scrollLine:Boolean;
		
		/**显示内容是否需要侦听鼠标滑轮事件*/
		private var _mouseWheelEnabled:Boolean = true;
		/**在显示内容尺寸改变时，是否自动隐藏或显示*/
		private var _autoDisplay:Boolean;
		/**滚动条当前是否已显示（内容尺寸是否超出了显示区域）*/
		private var _showed:Boolean;
		
		/**是否自动调整滑块尺寸*/
		private var _autoThumbSize:Boolean;
		/**滑块最小尺寸*/
		private var _thumbMinSize:uint = 5;
		/**一行的滚动量*/
		private var _lineScrollSize:uint = 15;
		/**一页的滚动量，默认值为0，表示自动使用显示区域的尺寸代替该值*/
		private var _pageScrollSize:uint = 0;
		/**第一次buttonDown事件后，在按repeatInterval重复buttonDown事件前，需要等待的毫秒数*/
		private var _repeatDelay:uint = 500;
		/**在按钮上按住鼠标时，重复buttonDown事件的间隔毫秒数*/
		private var _repeatInterval:uint = 35;
		
		/**用于在对应的鼠标按下状态，定时滚动行或页*/
		private var _timer:FrameTimer;
		
		
		
		
		public function ScrollBar()
		{
			super();
			_track		= AutoUtil.init(new BaseButton(), this);
			_thumb		= AutoUtil.init(new BaseButton(), this);
			_upBtn		= AutoUtil.init(new BaseButton(), this);
			_downBtn	= AutoUtil.init(new BaseButton(), this);
			
			_direction = Constants.VERTICAL;
			
			_timer = new FrameTimer(_repeatDelay, timerHandler);
		}
		
		
		public function set style(value:Object):void
		{
			if(value.upBtnSkin != null) _upBtn.skinName = value.upBtnSkin;
			if(value.downBtnSkin != null) _downBtn.skinName = value.downBtnSkin;
			if(value.trackSkin != null) _track.skinName = value.trackSkin;
			if(value.thumbSkin != null) _thumb.skinName = value.thumbSkin;
			
			if(value.direction != null) direction = value.direction;
			if(value.autoDisplay != null) _autoDisplay = value.autoDisplay;
			
			if(value.autoThumbSize != null) _autoThumbSize = value.autoThumbSize;
			if(value.thumbMinSize != null) _thumbMinSize = value.thumbMinSize;
			
			if(value.lineScrollSize != null) _lineScrollSize = value.lineScrollSize;
			if(value.pageScrollSize != null) _pageScrollSize = value.pageScrollSize;
			if(value.repeatDelay != null) _repeatDelay = value.repeatDelay;
			if(value.repeatInterval != null) _repeatInterval = value.repeatInterval;
			
			size = (value.size != null) ? value.size : _size;
			
			update();
		}
		
		public function set styleName(value:String):void
		{
			style = Common.config.getStyle(value);
			size = _size;//重置尺寸和位置
		}
		
		
		public function set upBtnProp(value:Object):void
		{
			AutoUtil.initObject(_upBtn, value);
		}
		
		public function set downBtnProp(value:Object):void
		{
			AutoUtil.initObject(_downBtn, value);
		}
		
		public function set trackProp(value:Object):void
		{
			AutoUtil.initObject(_track, value);
		}
		
		public function set thumbProp(value:Object):void
		{
			AutoUtil.initObject(_thumb, value);
		}
		
		
		
		public function update():void
		{
			PrerenderScheduler.addCallback(prerender, -1);
		}
		
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
			if(_viewableArea == null || _content == null) return;
			
			_showed = _content[_wh] > _viewableArea[_wh];
			if(_autoDisplay) this.visible = _showed;
			enabled = _enabled;
			
			if(_showed)
			{
				if(_autoThumbSize) {
					_thumb[_wh] = int(_viewableArea[_wh] / _content[_wh] * _track[_wh]);
					if(_thumb[_wh] < _thumbMinSize) _thumb[_wh] = _thumbMinSize;
				}
				
				moveContent(_content[_xy]);
				
				this.addEventListener(MouseEvent.ROLL_OVER, mouseRollHandler);
				this.addEventListener(MouseEvent.ROLL_OUT, mouseRollHandler);
				this.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				if(_mouseWheelEnabled) {
					_content.addEventListener(MouseEvent.ROLL_OVER, mouseRollHandler);
					_content.addEventListener(MouseEvent.ROLL_OUT, mouseRollHandler);
					_content.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				}
				ExternalUtil.eventDispatcher.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				
				_track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
				_thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
				if(_upBtn != null) _upBtn.addEventListener(MouseEvent.MOUSE_DOWN, directionBtn_mouseDownHandler);
				if(_downBtn != null) _downBtn.addEventListener(MouseEvent.MOUSE_DOWN, directionBtn_mouseDownHandler);
			}
			else
			{
				_content[_xy] = _viewableArea[_xy];
				if(_showed) return;
				
				_thumb[_xy] = _track[_xy];
				_content.graphics.clear();
				
				this.removeEventListener(MouseEvent.ROLL_OVER, mouseRollHandler);
				this.removeEventListener(MouseEvent.ROLL_OUT, mouseRollHandler);
				this.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				_content.removeEventListener(MouseEvent.ROLL_OVER, mouseRollHandler);
				_content.removeEventListener(MouseEvent.ROLL_OUT, mouseRollHandler);
				_content.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				ExternalUtil.eventDispatcher.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				
				_track.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
				_thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
				if(_upBtn != null) _upBtn.removeEventListener(MouseEvent.MOUSE_DOWN, directionBtn_mouseDownHandler);
				if(_downBtn != null) _downBtn.removeEventListener(MouseEvent.MOUSE_DOWN, directionBtn_mouseDownHandler);
			}
			
		}
		
		
		/**
		 * 绘制内容的空白区域，用于接收鼠标事件
		 */
		private function drawContentViewableArea():void
		{
			_content.graphics.clear();
			if(!_mouseWheelEnabled || !_showed) return;
			
			_content.graphics.beginFill(0xFFFFFF, 0.001);
			if(_direction == Constants.HORIZONTAL) {
				_content.graphics.drawRect(_viewableArea.x - _content.x, 0, _viewableArea.width, _viewableArea.height);
			}
			else {
				_content.graphics.drawRect(0, _viewableArea.y - _content.y, _viewableArea.width, _viewableArea.height);
			}
			_content.graphics.endFill();
		}
		
		
		/**
		 * 内容有改变
		 * @param event
		 */
		private function content_changeHandler(event:Event):void
		{
			update();
		}
		
		
		/**
		 * 鼠标在 滚动条/内容 上 移入/移出
		 * @param event
		 */
		private function mouseRollHandler(event:MouseEvent):void
		{
			ExternalUtil.mouseWheelEnabled = event.type == MouseEvent.ROLL_OUT;
		}
		
		
		/**
		 * 鼠标在滑块上按下
		 * @param event
		 */
		private function thumb_mouseDownHandler(event:MouseEvent):void
		{
			var thumbDragBounds:Rectangle = (_direction == Constants.HORIZONTAL)
				? new Rectangle(_track.x, _track.y, _track.width - _thumb.width, 0)
				: new Rectangle(_track.x, _track.y, 0, _track.height - _thumb.height);
			_thumb.startDrag(false, thumbDragBounds);
			
			Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, thumb_stageMouseMoveHandler);
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, thumb_stageMouseUpHandler);
		}
		
		/**
		 * 鼠标在场景移动（滑块按下状态）
		 * @param event
		 */
		private function thumb_stageMouseMoveHandler(event:MouseEvent):void
		{
			moveContentByThumb();
		}
		
		/**
		 * 鼠标在场景释放（滑块按下状态）
		 * @param event
		 */
		private function thumb_stageMouseUpHandler(event:MouseEvent):void
		{
			_thumb.stopDrag();
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumb_stageMouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, thumb_stageMouseUpHandler);
		}
		
		
		
		
		/**
		 * 鼠标在方向按钮上按下
		 * @param event
		 */
		private function directionBtn_mouseDownHandler(event:MouseEvent):void
		{
			_scrollUp = event.currentTarget == _upBtn;
			_scrollLine = true;
			
			_timer.delay = _repeatDelay;
			_timer.start();
			
			moveContentByLine();
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, directionBtn_stageMouseUpHandler);
		}
		
		/**
		 * 鼠标在场景释放（方向按钮按下状态）
		 * @param event
		 */
		private function directionBtn_stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, directionBtn_stageMouseUpHandler);
			_timer.reset();
		}
		
		
		
		/**
		 * 鼠标在轨道上按下
		 * @param event
		 */
		private function track_mouseDownHandler(event:MouseEvent):void
		{
			var p:int = (_direction == Constants.HORIZONTAL) ? _track.mouseX : _track.mouseY;
			_scrollUp = p < _thumb[_xy];
			_scrollLine = false;
			
			_timer.delay = _repeatDelay;
			_timer.start();
			
			moveContentByPage();
			Common.stage.addEventListener(MouseEvent.MOUSE_UP, track_stageMouseUpHandler);
		}
		
		/**
		 * 鼠标在场景释放（轨道按下状态）
		 * @param event
		 */
		private function track_stageMouseUpHandler(event:MouseEvent):void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, track_stageMouseUpHandler);
			_timer.reset();
		}
		
		
		
		/**
		 * 鼠标滚动滑轮
		 * @param event
		 */
		private function mouseWheelHandler(event:MouseEvent):void
		{
			if(!_enabled) return;
			_scrollUp = event.delta > 0;
			moveContentByLine(Math.abs(event.delta));
		}
		
		
		
		/**
		 * 在对应的鼠标按下状态，滚动行或页
		 * @param event
		 */
		private function timerHandler():void
		{
			//刚到达回调时间
			if(_timer.delay == _repeatDelay) {
				_timer.delay = _repeatInterval;
				_timer.start();
			}
				//滚动
			else {
				_scrollLine ? moveContentByLine() : moveContentByPage();
			}
		}
		
		
		
		
		/**
		 * 内容的位置，移动指定行
		 * @param line
		 */
		private function moveContentByLine(line:uint=1):void
		{
			var p:int = line * _lineScrollSize;
			if(!_scrollUp) p = -p;
			moveContent(_content[_xy] + p);
		}
		
		/**
		 * 内容的位置，移动指定页
		 * @param line
		 */
		private function moveContentByPage(page:uint=1):void
		{
			var tmp:int = (_direction == Constants.HORIZONTAL) ? _track.mouseX : _track.mouseY;
			tmp += _track[_xy];
			
			//向上滚动，超出了鼠标位置
			if(_scrollUp && _thumb[_xy] <= tmp) {
				_timer.reset();
				return;
			}
			
			//向下滚动，超出了鼠标位置
			if(!_scrollUp && _thumb[_xy] + _thumb[_wh] >= tmp) {
				_timer.reset();
				return;
			}
			
			var pss:int = (_pageScrollSize == 0) ? _viewableArea[_wh] : _pageScrollSize;
			var p:int = page * pss;
			if(!_scrollUp) p = -p;
			moveContent(_content[_xy] + p);
		}
		
		
		/**
		 * 内容移动到指定像素位置（会自动判定指定的位置是否在可移动范围内）
		 * @param p
		 */
		private function moveContent(p:int):void
		{
			_content.graphics.clear();
			
			var max:int = _viewableArea[_xy];
			var min:int = -(_content[_wh] - _viewableArea[_wh] - _viewableArea[_xy]);
			
			//向下移动超出区域了
			if(p >= max) {
				_content[_xy] = max;
				_timer.reset();
			}
			//向上移动超出区域了
			else if(p <= min) {
				_content[_xy] = min;
				_timer.reset();
			}
			else {
				_content[_xy] = p;
			}
			
			drawContentViewableArea();
			moveThumbByContent();
		}
		
		
		
		/**
		 * 通过滑块的位置，来移动内容的位置
		 */
		private function moveContentByThumb():void
		{
			_content.graphics.clear();
			
			_content[_xy] = int(
				- (_thumb[_xy] - _track[_xy])
				/ (_track[_wh] - _thumb[_wh])
				* (_content[_wh] - _viewableArea[_wh])
				+ _viewableArea[_xy]
			);
			
			drawContentViewableArea();
		}
		
		
		/**
		 * 通过内容的位置，来移动滑块的位置
		 */
		private function moveThumbByContent():void
		{
			_thumb[_xy] = int(
				- (_content[_xy] - _viewableArea[_xy])
				/ (_content[_wh] - _viewableArea[_wh])
				* (_track[_wh] - _thumb[_wh])
				+ _track[_xy]
			);
		}
		
		
		
		
		/**
		 * 初始化
		 */
		private function initialize():void
		{
			if(_viewableArea != null && _content != null)
			{
				if(_contentMask == null) _contentMask = new Mask();
				_contentMask.x = _viewableArea.x;
				_contentMask.y = _viewableArea.y;
				_contentMask.rect = { width:_viewableArea.width, height:_viewableArea.height };
				_contentMask.target = _content;
				update();
			}
		}
		
		public function set content(value:Sprite):void
		{
			if(_content != null) {
				_content.removeEventListener(Event.CHANGE, content_changeHandler);
				_content.graphics.clear();
			}
			_content = value;
			_content.addEventListener(Event.CHANGE, content_changeHandler);
			initialize();
		}
		public function get content():Sprite { return _content; }
		
		
		public function set viewableArea(value:Object):void
		{
			_viewableArea = new Rectangle(value.x, value.y, value.width, value.height);
			initialize();
		}
		public function get viewableArea():Object { return _viewableArea; }
		
		
		
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			value = _enabled && _showed;
			if(_thumb.visible != value)
			{
				_thumb.visible = value;
				_track.enabled = _upBtn.enabled = _downBtn.enabled = value;
			}
		}
		public function get enabled():Boolean { return _enabled; }
		
		
		
		public function set direction(value:String):void
		{
			if(value == _direction) return;
			_direction = value;
			if(value == Constants.HORIZONTAL) {
				_xy = "x";
				_wh = "width";
			}
			else {
				_xy = "y";
				_wh = "height";
			}
			
			//重置尺寸和位置
			_upBtn.resetSize();
			_downBtn.resetSize();
			_track.resetSize();
			_thumb.resetSize();
			size = _size;
		}
		public function get direction():String { return _direction; }
		
		
		
		public function set size(value:uint):void
		{
			_size = value;
			
			_upBtn.x = _upBtn.y = _downBtn.x = _downBtn.y = _track.x = _track.y = _thumb.x = _thumb.y = 0;
			
			_downBtn[_xy] = _size - _downBtn[_wh];
			_track[_xy] = _upBtn[_wh];
			_track[_wh] = _size - _track[_xy] - _downBtn[_wh];
			if(_thumb.x == 0 && _thumb.y == 0) _thumb[_xy] = _track[_xy];
		}
		public function get size():uint { return _size; }
		
		
		public function set autoDisplay(value:Boolean):void
		{
			if(value == _autoDisplay) return;
			_autoDisplay = value;
			update();
		}
		public function get autoDisplay():Boolean { return _autoDisplay; }
		
		
		public function set mouseWheelEnabled(value:Boolean):void
		{
			if(value == _mouseWheelEnabled) return;
			_mouseWheelEnabled = value;
			update();
		}
		public function get mouseWheelEnabled():Boolean { return _mouseWheelEnabled; }
		
		
		public function set autoThumbSize(value:Boolean):void { _autoThumbSize = value; }
		public function get autoThumbSize():Boolean { return _autoThumbSize; }
		
		
		public function set thumbMinSize(value:uint):void { _thumbMinSize = value; }
		public function get thumbMinSize():uint { return _thumbMinSize; }
		
		
		public function set lineScrollSize(value:uint):void { _lineScrollSize = value; }
		public function get lineScrollSize():uint { return _lineScrollSize; }
		
		
		public function set pageScrollSize(value:uint):void { _pageScrollSize = value; }
		public function get pageScrollSize():uint { return _pageScrollSize; }
		
		
		public function set repeatDelay(value:uint):void { _repeatDelay = value; }
		public function get repeatDelay():uint { return _repeatDelay; }
		
		
		public function set repeatInterval(value:uint):void { _repeatInterval = value; }
		public function get repeatInterval():uint { return _repeatInterval; }
		
		
		public function get track():BaseButton { return _track; }
		
		public function get thumb():BaseButton { return _thumb; }
		
		public function get upBtn():BaseButton { return _upBtn; }
		
		public function get downBtn():BaseButton { return _downBtn; }
		
		
		public function get showed():Boolean { return _showed; }
		
		
		
		
		public function scrollToPosition(p:int):void
		{
			moveContent(p);
		}
		
		public function scrollToBottom():void
		{
			moveContent(int.MIN_VALUE);
		}
		
		
		
		
		public function dispose():void
		{
			_timer.reset();
			
			PrerenderScheduler.removeCallback(prerender);
			Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumb_stageMouseMoveHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, thumb_stageMouseUpHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, directionBtn_mouseDownHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_UP, track_stageMouseUpHandler);
			
			if(_contentMask != null) _contentMask.dispose();
			if(_track != null) _track.dispose();
			if(_thumb != null) _thumb.dispose();
			if(_upBtn != null) _upBtn.dispose();
			if(_downBtn != null) _downBtn.dispose();
		}
		//
	}
}