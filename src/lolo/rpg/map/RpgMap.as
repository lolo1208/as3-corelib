package lolo.rpg.map
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.avatar.Avatar;
	import lolo.rpg.avatar.AvatarLoading;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.events.RpgMapEvent;
	import lolo.utils.FrameTimer;
	import lolo.utils.MathUtil;
	import lolo.utils.optimize.CachePool;
	import lolo.utils.optimize.InteractiveScene;
	
	/**
	 * RPG地图
	 * @author LOLO
	 */
	public class RpgMap extends EventDispatcher implements IRpgMap
	{
		/**地图的ID*/
		private var _id:String;
		/**地图配置信息*/
		private var _info:MapInfo;
		/**地图拖拽和鼠标响应管理*/
		private var _interactive:InteractiveScene;
		
		
		/**顶层容器*/
		private var _container:Sprite;
		/**背景*/
		private var _background:MapBackground;
		/**角色容器*/
		private var _avatarC:Sprite;
		/**遮挡物*/
		private var _covers:MapCover;
		/**在所有角色和遮挡物之上的容器*/
		private var _aboveC:Sprite;
		/**在所有角色和遮挡物之下的容器*/
		private var _belowC:Sprite;
		
		
		/**镜头跟踪的角色*/
		private var _trackingAvatar:IAvatar;
		/**卷屏相关的属性*/
		private var _scrollInfo:Object = {};
		
		
		/**角色索引列表，avatars[tile.y][tile.x]=Vector.Avatar*/
		private var _avatars:Array;
		/**用于对可见范围内的角色进行排序*/
		private var _sortTimer:FrameTimer;
		
		/**鼠标在背景上按下时，是否自动播放鼠标点击动画*/
		private var _autoPlayMouseDownAnimation:Boolean;
		/**角色走到被遮挡的区块上时，是否半透明*/
		private var _autoCoverAvatar:Boolean = true;
		/**是否在对avatar进行排序后抛出 RpgMapEvent.AVATAR_SORTED 事件*/
		private var _dispatchAvatarSorted:Boolean;
		
		/**屏幕中心位置*/
		private var _screenCenter:Point;
		
		
		
		public function RpgMap(mapContainer:DisplayObjectContainer, id:String=null)
		{
			super();
			
			_container = new Sprite();
			_container.mouseEnabled = false;
			mapContainer.addChild(_container);
			
			_background = new MapBackground(this);
			_background.mouseChildren = false;
			_background.name = Constants.LAYER_NAME_BG;
			_container.addChild(_background);
			
			_belowC = new Sprite();
			_belowC.mouseEnabled = _belowC.mouseChildren = false;
			_container.addChild(_belowC);
			
			_avatarC = new Sprite();
			_avatarC.mouseEnabled = _avatarC.mouseChildren = false;
			_container.addChild(_avatarC);
			
			_covers = new MapCover(this);
			_covers.mouseEnabled = _covers.mouseChildren = false;
			_container.addChild(_covers);
			
			_aboveC = new Sprite();
			_aboveC.mouseEnabled = _aboveC.mouseChildren = false;
			_container.addChild(_aboveC);
			
			_interactive = new InteractiveScene(_background, _container, null, mouseDownHandler);
			_interactive.dragEnabled = false;
			
			this.avatarMouseEnabled = true;
			
			if(id != null) init(id);
		}
		
		
		public function init(id:String):void
		{
			clear();
			
			_id = id;
			_container.name = "id" + id;
			
			//读取地图信息
			var data:ByteArray = Common.loader.getResByUrl(Common.config.getUIConfig(RpgConstants.CN_MAP_DATA, _id), true);
			data.readByte();//移除标记
			_info = new MapInfo(data.readObject());
			
			//显示背景（这里不需要清除，因为IMG会被ImageLoader清除）
			_background.init(Common.loader.getResByUrl(Common.config.getUIConfig(RpgConstants.CN_MAP_THUMBNAIL, _id)));
			//显示遮挡物
			_covers.init();
			
			//初始化数据
			_avatars = [];
			
			//添加事件侦听
			if(_sortTimer == null) _sortTimer = new FrameTimer(RpgConstants.AVATAR_DEPTH_SORT_DELAY, avatarSortTimerHandler);
			
			_screenCenter = new Point();
			Common.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
			
			_interactive.startup();
		}
		
		
		
		public function createAvatar(key:String, pic:String=null, horesPic:String=null, priority:int=0, tile:Point=null, direction:uint=0):IAvatar
		{
			if(tile == null) tile = RpgUtil.getRandomCanPassTile(_info);
			if(direction == 0) direction = MathUtil.getBetweenRandom(1, 9);
			
			var avatar:Avatar = getAvatarByKey(key) as Avatar;
			if(avatar == null) {
				avatar = new Avatar();
				avatar.key = key;
				avatar.tile = tile;//设置map的时候，需要访问tile
				avatar.map = this;
			}
			
			avatar.tile = tile;
			avatar.direction = direction;
			avatar.loadingClass = AvatarLoading;
			avatar.priority = priority;
			avatar.pic = pic;
			avatar.playStand();
			
			return avatar;
		}
		
		
		public function addAvatar(avatar:IAvatar):void
		{
			//同步角色的map（设置 avatar.map 属性，会调用 map.addAvatar）
			if(avatar.map != this) {
				avatar.map = this;
				return;
			}
			
			//先将相同key的角色移除
			removeAvatar(getAvatarByKey(avatar.key));
			
			//再将该角色添加到地图
			var a:Avatar = avatar as Avatar;
			a.name = "avatar" + a.key;
			_avatarC.addChild(a);
			
			//添加到角色列表
			avatar.addEventListener(AvatarEvent.TILE_CHANGED, avatarTileChangedHandler);
			avatar.dispatchEvent(new AvatarEvent(AvatarEvent.TILE_CHANGED));
		}
		
		
		public function removeAvatar(avatar:IAvatar):void
		{
			if(avatar == null) return;
			
			//从索引列表中移除
			var avatars:Vector.<IAvatar> = getAvatarListFromTile(avatar.tile);
			if(avatars.length > 0) {
				var i:int = avatars.indexOf(avatar);
				if(i != -1) avatars.splice(i, 1);
			}
			
			//从显示列表中移除
			if((avatar as Avatar).parent == _avatarC) _avatarC.removeChild(avatar as Avatar);
			
			if(avatar == _interactive.mouseObj) _interactive.mouseObj = null;
			if(avatar == _trackingAvatar) _trackingAvatar = null;
			
			avatar.removeEventListener(AvatarEvent.TILE_CHANGED, avatarTileChangedHandler);
			avatar.clear();
		}
		
		
		public function getAvatarByKey(key:String):IAvatar
		{
			return _avatarC.getChildByName("avatar" + key) as IAvatar;
		}
		
		public function getAllAvatar():Vector.<IAvatar>
		{
			var avatars:Vector.<IAvatar> = new Vector.<IAvatar>();
			for(var i:int = 0; i < _avatarC.numChildren; i++)
				avatars.push(_avatarC.getChildAt(i) as IAvatar);
			return avatars;
		}
		
		public function getAvatarListFromTile(tile:Point):Vector.<IAvatar>
		{
			if(tile == null) return new Vector.<IAvatar>();//传入的错误的值
			if(_avatars[tile.y] == null) _avatars[tile.y] = [];
			if(_avatars[tile.y][tile.x] == null) _avatars[tile.y][tile.x] = new Vector.<IAvatar>();
			return _avatars[tile.y][tile.x];
		}
		
		
		/**
		 * 地图上有角色的区块位置发生了改变
		 * @param event
		 */
		private function avatarTileChangedHandler(event:AvatarEvent):void
		{
			var avatar:Avatar = event.target as Avatar;
			
			//走到了被遮挡的区块上
			var alpha:Number = 1;
			if(_autoCoverAvatar) {
				try {
					if(_info.data[avatar.tile.y][avatar.tile.x].cover) alpha = 0.6;
				}
				catch(error:Error) {}
			}
			avatar.alpha = alpha;
			
			//启动透视深度排序的定时器
			if(!_sortTimer.running) _sortTimer.start();
		}
		
		/**
		 * 根据角色透视深度进行排序
		 */
		private function avatarSortTimerHandler():void
		{
			_sortTimer.stop();
			
			var avatars:Vector.<IAvatar> = getScreenAvatars();
			avatars = avatars.sort(avatarDepthSort);
			for(var i:int = 0; i < avatars.length; i++)
			{
				var avatar:Avatar = avatars[i] as Avatar;
				//容错。addChildAt 的效率要比 addChild 快很多倍
				try {
					_avatarC.addChildAt(avatar, i);
				}
				catch(error:Error) {
					_avatarC.addChild(avatar);
				}
			}
			if(_dispatchAvatarSorted) dispatchEvent(new RpgMapEvent(RpgMapEvent.AVATAR_SORTED));
		}
		
		private function avatarDepthSort(a1:IAvatar, a2:IAvatar):int
		{
			if(a1.isDead && !a2.isDead) return -1;
			if(a2.isDead && !a1.isDead) return 1;
			
			if(a1.isDead && a2.isDead) {
				if(_info.staggered) {
					if(a1.tile.y < a2.tile.y) return 1;
					if(a1.tile.y > a2.tile.y) return -1;
				}
				else {
					if(a1.tile.y < a2.tile.y) return -1;
					if(a1.tile.y > a2.tile.y) return 1;
					if(a1.tile.x < a2.tile.x) return -1;
					if(a1.tile.x > a2.tile.x) return 1;
				}
			}
			
			if(_info.staggered) {
				if(a1.tile.y < a2.tile.y) return -1;
				if(a1.tile.y > a2.tile.y) return 1;
			}
			else {
				if(a1.tile.y < a2.tile.y) return 1;
				if(a1.tile.y > a2.tile.y) return -1;
				if(a1.tile.x < a2.tile.x) return 1;
				if(a1.tile.x > a2.tile.x) return -1;
			}
			
			return avatarDepthSortByKey(a1, a2);
		}
		
		private function avatarDepthSortByKey(a1:IAvatar, a2:IAvatar):int
		{
			if(a1.key < a2.key) return -1;
			if(a1.key > a2.key) return 1;
			return 0;
		}
		
		
		
		public function set trackingAvatar(value:IAvatar):void
		{
			if(_trackingAvatar != null) {
				_trackingAvatar.dispatchMoveing = false;
				_trackingAvatar.removeEventListener(AvatarEvent.MOVEING, trackingAvatar_moveingHandler);
			}
			
			_trackingAvatar = value;
			if(_trackingAvatar != null) {
				_trackingAvatar.dispatchMoveing = true;
				_trackingAvatar.addEventListener(AvatarEvent.MOVEING, trackingAvatar_moveingHandler);
				trackingAvatar_moveingHandler();
			}
		}
		public function get trackingAvatar():IAvatar { return _trackingAvatar; }
		
		/**
		 * 镜头跟踪的角色正在移动中
		 * @param event
		 */
		private function trackingAvatar_moveingHandler(event:AvatarEvent=null):void
		{
			var p:Point = CachePool.getPoint(_trackingAvatar.x, _trackingAvatar.y);
			scroll(p, true);
			CachePool.recover(p);
		}
		
		
		/**
		 * 舞台尺寸有改变
		 * @param event
		 */
		private function stage_resizeHandler(event:Event=null):void
		{
			_scrollInfo.sw = Common.ui.stageWidth;//舞台宽高
			_scrollInfo.sh = Common.ui.stageHeight;
			_scrollInfo.hsw = _scrollInfo.sw >> 1;//半个舞台宽高
			_scrollInfo.hsh = _scrollInfo.sh >> 1;
			_scrollInfo.rb = -(_info.mapWidth - _scrollInfo.sw);//右和下的边界
			_scrollInfo.db = -(_info.mapHeight - _scrollInfo.sh);
			
			scroll(_screenCenter, true);
		}
		
		
		public function scroll(position:Point, now:Boolean=false, duration:Number=0.5):void
		{
			var x:int = -(position.x - _scrollInfo.hsw);
			var y:int = -(position.y - _scrollInfo.hsh);
			if(x > 0) x = 0;
			else if(x < _scrollInfo.rb) x = _scrollInfo.rb;
			if(y > 0) y = 0;
			else if(y < _scrollInfo.db) y = _scrollInfo.db;
			
			_screenCenter.setTo(-x + _scrollInfo.hsw, -y + _scrollInfo.hsh);
			TweenMax.killTweensOf(_container);
			
			//背景不够大，没达到卷屏的尺寸
			if(_info.mapWidth <= _scrollInfo.sw && _info.mapHeight <= _scrollInfo.sh) {
				_container.x = _container.y = 0;
				return;
			}
			
			if(now) {
				_container.x = x;
				_container.y = y;
			}
			else {
				TweenMax.to(_container, duration, { x:x, y:y });
			}
			
			this.dispatchEvent(new RpgMapEvent(RpgMapEvent.SCREEN_CENTER_CHANGED));
		}
		
		
		
		public function getScreenArea(offsets:int=50):Rectangle
		{
			return CachePool.getRectangle(
				-_container.x - offsets,
				-_container.y - offsets,
				Common.ui.stageWidth + offsets * 2,
				Common.ui.stageHeight + offsets * 2
			);
		}
		
		
		public function getScreenAvatars():Vector.<IAvatar>
		{
			var v:int, h:int, vNum:int, hNum:int, hh:Number, lt:Point, ld:Point, rt:Point, rd:Point;
			var avts:Vector.<IAvatar>, i:int;
			var rect:Rectangle = getScreenArea(30);
			var avatars:Vector.<IAvatar> = new Vector.<IAvatar>();
			var p:Point = CachePool.getPoint();
			
			p.setTo(rect.x, rect.y);
			lt = RpgUtil.getTile(p, _info);
			
			p.setTo(rect.x + rect.width, rect.y + rect.height);
			rd = RpgUtil.getTile(p, _info);
			
			if(_info.staggered)
			{
				for(v = lt.y; v < rd.y; v++) {
					for(h = lt.x; h < rd.x; h++) {
						p.setTo(h, v);
						avts = getAvatarListFromTile(p);
						for(i = 0; i < avts.length; i++) avatars.push(avts[i]);
					}
				}
			}
			else
			{
				p.setTo(rect.x, rect.y + rect.height);
				ld = RpgUtil.getTile(p, _info);
				
				p.setTo(rect.x + rect.width, rect.y);
				rt = RpgUtil.getTile(p, _info);
				
				hNum = (lt.x - ld.x) * 2;
				vNum = ld.y - rd.y;
				for(h = 0; h < hNum; h++) {
					hh = h / 2;
					for(v = 0; v < vNum; v++) {
						p.setTo(ld.x + Math.ceil(hh) + v, ld.y + Math.floor(hh) - v);
						avts = getAvatarListFromTile(p);
						for(i = 0; i < avts.length; i++) avatars.push(avts[i]);
					}
				}
			}
			
			CachePool.recover([ lt, ld, rt, rd, rect, p ]);
			return avatars;
		}
		
		
		public function addElement(element:DisplayObject, above:Boolean, depth:int=-1):void
		{
			var c:Sprite = above ? _aboveC : _belowC;
			if(depth < 0 || c.numChildren == 0) {
				c.addChild(element);
			}
			else {
				if(depth >= c.numChildren) depth = c.numChildren - 1;
				c.addChildAt(element, depth);
			}
		}
		
		
		
		
		public function set draggingHandler(value:Function):void
		{
			_interactive.draggingHandler = value;
			_interactive.dragEnabled = (value != null);
		}
		public function get draggingHandler():Function { return _interactive.draggingHandler; }
		
		
		/**
		 * 鼠标在target上按下鼠标时（没有点到IInteractiveObject）的回调
		 */
		private function mouseDownHandler():void
		{
			if(_autoPlayMouseDownAnimation) _background.playMouseDownAnimation();
			this.dispatchEvent(new RpgMapEvent(RpgMapEvent.MOUSE_DOWN, mouseTile));
		}
		
		
		
		
		public function get id():String { return _id; }
		
		
		public function get info():MapInfo { return _info; }
		
		
		public function set autoPlayMouseDownAnimation(value:Boolean):void { _autoPlayMouseDownAnimation = value; }
		public function get autoPlayMouseDownAnimation():Boolean { return _autoPlayMouseDownAnimation; }
		
		
		public function set autoCoverAvatar(value:Boolean):void { _autoCoverAvatar = value; }
		public function get autoCoverAvatar():Boolean { return _autoCoverAvatar; }
		
		
		public function set avatarMouseEnabled(value:Boolean):void
		{
			_interactive.mouseEnabled = value;
		}
		public function get avatarMouseEnabled():Boolean { return _interactive.mouseEnabled; }
		
		
		public function get container():DisplayObjectContainer { return _container; }
		
		
		public function get screenCenter():Point { return _screenCenter; }
		
		
		public function set dispatchAvatarSorted(value:Boolean):void { _dispatchAvatarSorted = value; }
		public function get dispatchAvatarSorted():Boolean { return _dispatchAvatarSorted; }
		
		public function set scaleX(value:Number):void
		{
			_container.scaleX = value;
			stage_resizeHandler();
		}
		public function get scaleX():Number { return _container.scaleX; }
		
		
		public function set scaleY(value:Number):void
		{
			_container.scaleY = value;
			stage_resizeHandler();
		}
		public function get scaleY():Number { return _container.scaleY; }
		
		
		public function get mouseAvatar():IAvatar { return _interactive.mouseObj as IAvatar; }
		
		
		public function get mouseTile():Point
		{
			var p1:Point = CachePool.getPoint(_container.mouseX, _container.mouseY);
			var p2:Point = RpgUtil.getTile(p1, _info);
			CachePool.recover(p1);
			return p2;
		}
		
		
		public function pauseOrContinueLoadChunk(pause:Boolean):void
		{
			_background.pauseOrContinueLoadChunk(pause);
		}
		
		
		public function get cleared():Boolean
		{
			return _info == null;
		}
		
		
		public function clearAllAvatar():void
		{
			while(_avatarC.numChildren > 0) {
				removeAvatar(_avatarC.removeChildAt(0) as IAvatar);
			}
			
			trackingAvatar = null;
			_interactive.mouseObj = null;
			_avatars = null;
		}
		
		
		public function clear():void
		{
			Common.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			if(_sortTimer != null) _sortTimer.stop();
			
			_interactive.reset();
			clearAllAvatar();
			_background.clear();
			_covers.clear();
			
			//移除附加的显示元素，并尝试调用 dispose() 和 clear() 方法
			var element:DisplayObject;
			while(_aboveC.numChildren > 0) {
				element = _aboveC.removeChildAt(0);
				try { element["dispose"](); } catch(error:Error){}
				try { element["clear"](); } catch(error:Error){}
			}
			while(_belowC.numChildren > 0) {
				element = _belowC.removeChildAt(0);
				try { element["dispose"](); } catch(error:Error){}
				try { element["clear"](); } catch(error:Error){}
			}
			
			_id = null;
			_info = null;
		}
		//
	}
}