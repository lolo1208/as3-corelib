package lolo.rpg.avatar
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.LoadItemModel;
	import lolo.display.Animation;
	import lolo.display.IAnimation;
	import lolo.events.LoadEvent;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.Wayfinding;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.map.IRpgMap;
	import lolo.utils.FrameTimer;
	import lolo.utils.logging.Logger;
	import lolo.utils.optimize.CachePool;
	
	public class Avatar extends Sprite implements IAvatar
	{
		/**所属的RpgMap*/
		private var _map:IRpgMap;
		/**角色在map中的唯一key*/
		private var _key:String;
		/**附带的数据*/
		private var _data:*;
		/**角色的外形*/
		private var _pic:String;
		/**当前方向*/
		private var _direction:uint;
		/**当前所在的区块坐标*/
		private var _tile:Point;
		/**是否已死亡*/
		private var _isDead:Boolean;
		/**当前移动的动作（默认：RpgConstants.A_RUN）*/
		private var _moveAction:String;
		/**移动速度*/
		private var _moveSpeed:Number = 1;
		/**动画的播放速度*/
		private var _animationSpeed:Number = 1;
		/**是否正在移动中*/
		private var _moveing:Boolean;
		/**是否需要抛出 AvatarEvent.MOVEING 事件（默认不抛）*/
		private var _dispatchMoveing:Boolean;
		
		/**角色外形动画*/
		private var _avatarAni:Animation;
		/**角色外形容器（会随着方向翻转）*/
		private var _shapeC:Sprite;
		/**附属物 - 服饰容器*/
		private var _dressC:Sprite;
		/**附属物 - 发型容器*/
		private var _hairC:Sprite;
		/**附属物 - 武器容器*/
		private var _weaponC:Sprite;
		
		/**Loading的类定义*/
		private var _loadingClass:Class;
		/**角色加载外形时，显示的Loading*/
		private var _loading:IAvatarLoading;
		/**外形的加载优先级，数字越大，优先级越高*/
		private var _priority:int = 0;
		
		/**当前执行的动作 { action, replay, endIdle } */
		private var _actionInfo:Object;
		
		/**正在移动的（剩余）路径*/
		private var _road:Array = [];
		/**下一个区块点（移动结束点）的像素坐标*/
		private var _endPixel:Point;
		/**每次移动需要递增的像素*/
		private var _moveAddPixel:Point = new Point();
		/**现在真实的像素位置（x,y未取整前）*/
		private var _realPixel:Point = new Point();
		
		/**角色的附属物列表*/
		private var _adjuncts:Array = [];
		
		/**是否为8方向素材，默认值为：RpgConstants.DIRECTION_8*/
		private var _is8Direction:Boolean;
		/**根据 当前方向 和 素材是否为8方向，得出的素材应该使用的方向*/
		private var _assetDirection:uint;
		
		/**用于移动*/
		private var _moveTimer:FrameTimer;
		/**用于在指定的延时后，切换到stand动作*/
		private var _standTimer:FrameTimer;
		
		
		
		public function Avatar()
		{
			super();
			_is8Direction = RpgConstants.is8Direction;
			
			_shapeC = new Sprite();
			this.addChild(_shapeC);
			
			_avatarAni = new Animation();
			_shapeC.addChild(_avatarAni);
			
			_dressC = new Sprite();
			_dressC.name = RpgConstants.ADJUNCT_TYPE_DRESS;
			_shapeC.addChild(_dressC);
			
			_hairC = new Sprite();
			_hairC.name = RpgConstants.ADJUNCT_TYPE_HAIR;
			_shapeC.addChild(_hairC);
			
			_weaponC = new Sprite();
			_weaponC.name = RpgConstants.ADJUNCT_TYPE_WEAPON;
			_shapeC.addChild(_weaponC);
			
			_moveAction = RpgConstants.A_RUN;
			_moveTimer = new FrameTimer(16, moveTimerHandler);
			
			_standTimer = new FrameTimer(1000, standTimerHandler);
		}
		
		
		
		
		
		public function moveToTile(tp:Point):void
		{
			moveByRoad(Wayfinding.search(_map.info.data, _tile, tp));
		}
		
		public function moveByRoad(road:Array):void
		{
			_road = road;
			moveToNextTile();
		}
		
		public function addRoad(road:Array):void
		{
			if(_moveing) {
				for(var i:int=0; i < road.length; i++) _road.push(road[i]);
			}
			else {
				moveByRoad(road);
			}
		}
		
		/**
		 * 移动到路径组的下一个区块中
		 */
		private function moveToNextTile():void
		{
			if(_moveing) return;
			
			//没有需要继续移动的路径了
			if(_road.length == 0) {
				playStand(0, RpgConstants.AVATAR_RUN_TO_STAND_DELAY);
				dispatchEvent(new AvatarEvent(AvatarEvent.MOVE_END));//追着敌人攻击，需要关注该事件
				return;
			}
			
			//取出下一个区块的位置
			var arr:Array = _road.shift();
			var ep:Point = CachePool.getPoint(arr[0], arr[1]);
			
			//当前区块的位置，就是下一个区块位置
			if(ep.x == _tile.x && ep.y == _tile.y) {
				moveToNextTile();
				return;
			}
			
			
			//得出方向，以及每次移动的像素距离
			var nowDirection:uint = _direction;//记录当前方向
			_moveAddPixel.setTo(0, 0);//默认x、y都无需移动
			var el:Boolean = (_tile.y % 2) == 0;//是否为偶数行
			
			
			//交错地图的方向判断
			if(_map.info.staggered)
			{
				if(ep.y < _tile.y)
				{
					//左上
					if((el && ep.x < _tile.x) || (!el && _tile.y-1 == ep.y && _tile.x == ep.x)) {
						_direction = RpgConstants.D_LEFT_UP;
						_moveAddPixel.x = -RpgConstants.AVATAR_MOVE_ADD_X;
					}
					//右上
					else if((el && ep.x == _tile.x && ep.y == _tile.y-1) || (!el && ep.x > _tile.x)) {
						_direction = RpgConstants.D_RIGHT_UP;
						_moveAddPixel.x = RpgConstants.AVATAR_MOVE_ADD_X;
					}
					//正上
					else {
						_direction = RpgConstants.D_UP;
					}
					_moveAddPixel.y = -RpgConstants.AVATAR_MOVE_ADD_Y;
				}
				else if(ep.y > _tile.y)
				{
					//左下
					if((el && ep.x < _tile.x) || (!el && _tile.y+1 == ep.y && _tile.x == ep.x)) {
						_direction = RpgConstants.D_LEFT_DOWN;
						_moveAddPixel.x = -RpgConstants.AVATAR_MOVE_ADD_X;
					}
					//右下
					else if((el && ep.x == _tile.x && ep.y == _tile.y+1) || (!el && ep.x > _tile.x)) {
						_direction = RpgConstants.D_RIGHT_DOWN;
						_moveAddPixel.x = RpgConstants.AVATAR_MOVE_ADD_X;
					}
					//正下
					else {
						_direction = RpgConstants.D_DOWN;
					}
					_moveAddPixel.y = RpgConstants.AVATAR_MOVE_ADD_Y;
				}
				else
				{
					//正左
					if(ep.x < _tile.x) {
						_direction = RpgConstants.D_LEFT;
						_moveAddPixel.x = -RpgConstants.AVATAR_MOVE_ADD_X;
					}
					//正右
					else {
						_direction = RpgConstants.D_RIGHT;
						_moveAddPixel.x = RpgConstants.AVATAR_MOVE_ADD_X;
					}
				}
			}
			//大菱形地图的方向判断
			else
			{
				if(ep.y > _tile.y)
				{
					//正左
					if(ep.x < _tile.x) {
						_direction = RpgConstants.D_LEFT;
						_moveAddPixel.x = -RpgConstants.AVATAR_MOVE_ADD_X;
					}
					//左上
					else if(ep.x == _tile.x) {
						_direction = RpgConstants.D_LEFT_UP;
						_moveAddPixel.x = -RpgConstants.AVATAR_MOVE_ADD_X;
						_moveAddPixel.y = -RpgConstants.AVATAR_MOVE_ADD_Y;
					}
					//正上
					else {
						_direction = RpgConstants.D_UP;
						_moveAddPixel.y = -RpgConstants.AVATAR_MOVE_ADD_Y;
					}
				}
				else if(ep.y < _tile.y)
				{
					//正下
					if(ep.x < _tile.x) {
						_direction = RpgConstants.D_DOWN;
						_moveAddPixel.y = RpgConstants.AVATAR_MOVE_ADD_Y;
					}
					//右下
					else if(ep.x == _tile.x) {
						_direction = RpgConstants.D_RIGHT_DOWN;
						_moveAddPixel.x = RpgConstants.AVATAR_MOVE_ADD_X;
						_moveAddPixel.y = RpgConstants.AVATAR_MOVE_ADD_Y;
					}
					//正右
					else {
						_direction = RpgConstants.D_RIGHT;
						_moveAddPixel.x = RpgConstants.AVATAR_MOVE_ADD_X;
					}
				}
				else 
				{
					//左下
					if(ep.x < _tile.x) {
						_direction = RpgConstants.D_LEFT_DOWN;
						_moveAddPixel.x = -RpgConstants.AVATAR_MOVE_ADD_X;
						_moveAddPixel.y = RpgConstants.AVATAR_MOVE_ADD_Y;
					}
					//右上
					else {
						_direction = RpgConstants.D_RIGHT_UP;
						_moveAddPixel.x = RpgConstants.AVATAR_MOVE_ADD_X;
						_moveAddPixel.y = -RpgConstants.AVATAR_MOVE_ADD_Y;
					}
				}
			}
			
			//乘上速度值
			_moveAddPixel.x *= _moveSpeed;
			_moveAddPixel.y *= _moveSpeed;
			
			//下一个区块的像素位置
			CachePool.recover(_endPixel);
			_endPixel = RpgUtil.getTileCenter(ep, _map.info);
			
			
			//开始移动
			_moveing = true;
			changeTile(ep);
			playAction(_moveAction, true, (nowDirection != _direction ? 1 : 0) );
			
			_realPixel.setTo(this.x, this.y);
			_moveTimer.start();
			
			dispatchEvent(new AvatarEvent(AvatarEvent.TILE_CHANGED));//排序依赖该事件，所以必须抛出
		}
		
		
		/**
		 * 移动定时器回调
		 */
		private function moveTimerHandler():void
		{
			_realPixel.x += _moveAddPixel.x;
			_realPixel.y += _moveAddPixel.y;
			
			//已经移出界了
			if(		(_moveAddPixel.x <  0 && _realPixel.x <  _endPixel.x)
				||	(_moveAddPixel.x >  0 && _realPixel.x >  _endPixel.x)
				||	(_moveAddPixel.x == 0 && _realPixel.x != _endPixel.x)
			) {
				_realPixel.x = _endPixel.x;
			}
			
			if(		(_moveAddPixel.y <  0 && _realPixel.y <  _endPixel.y)
				||	(_moveAddPixel.y >  0 && _realPixel.y >  _endPixel.y)
				||	(_moveAddPixel.y == 0 && _realPixel.y != _endPixel.y)
			) {
				_realPixel.y = _endPixel.y;
			}
			
			this.x = int(_realPixel.x);
			this.y = int(_realPixel.y);
			if(_dispatchMoveing) dispatchEvent(new AvatarEvent(AvatarEvent.MOVEING));
			
			//已经移动到目标区块的中心点了
			if(this.x == _endPixel.x && this.y == _endPixel.y) {
				stopMove();
				moveToNextTile();
			}
		}
		
		
		public function stopMove():void
		{
			_moveTimer.reset();
			_moveing = false;
		}
		
		
		public function playStand(direction:uint=0, delay:uint=0):void
		{
			if(direction != 0) _direction = direction;
			
			if(delay == 0) {
				standTimerHandler();
			}
			else {
				_standTimer.delay = delay;
				_standTimer.start();
			}
		}
		
		private function standTimerHandler():void
		{
			playAction(RpgConstants.A_STAND, true, 1, false);
		}
		
		
		public function playAction(action:String, replay:Boolean=false, startFrame:uint=1, endIdle:Boolean=true):void
		{
			_standTimer.stop();
			_actionInfo = { action:action, replay:replay, endIdle:endIdle };
			
			//5方向时，右侧的动画，直接用左侧的图像，并翻转
			_assetDirection = _direction;
			var assetScaleX:int = 1;
			if(!_is8Direction) {
				switch(_direction)
				{
					case RpgConstants.D_LEFT:
						_assetDirection = RpgConstants.D_RIGHT;
						assetScaleX = -1;
						break;
					case RpgConstants.D_LEFT_UP:
						_assetDirection = RpgConstants.D_RIGHT_UP;
						assetScaleX = -1;
						break;
					case RpgConstants.D_LEFT_DOWN:
						_assetDirection = RpgConstants.D_RIGHT_DOWN;
						assetScaleX = -1;
						break;
				}
			}
			var scaleXChanged:Boolean = _shapeC.scaleX != assetScaleX;
			_shapeC.scaleX = assetScaleX;
			
			if(_pic == null) return;//还没设置过角色外形
			
			var sn:String = "avatar." + _pic + "." + action + _assetDirection;
			//动画有改变，或者动画没在播放
			if(_avatarAni.sourceName != sn || !_avatarAni.playing || scaleXChanged)
			{
				_avatarAni.sourceName = sn;
				_avatarAni.play(startFrame, replay ? 0 : 1, 0, actionAnimationEnd);
				showFPS();
				
				//这个动画还没被缓存
				if(!Animation.hasAnimation(sn)) {
					Common.loader.addEventListener(LoadEvent.PROGRESS, loadItemEventHandler);
					Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadItemEventHandler);
					if(_loading == null) _loading = new _loadingClass();
					_loading.progress = 0;
					this.addChildAt(_loading as DisplayObject, 0);
				}
				else {
					var loading:DisplayObject = _loading as DisplayObject;
					if(loading && loading.parent) {
						Common.loader.removeEventListener(LoadEvent.PROGRESS, loadItemEventHandler);
						Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loadItemEventHandler);
						this.removeChild(loading);
					}
				}
				
				dispatchEvent(new AvatarEvent(AvatarEvent.ACTION_START));
			}
		}
		
		
		/**
		 * 动作的动画播放结束
		 */
		private function actionAnimationEnd():void
		{
			_actionInfo.action = null;//置空，表示现在没有执行任何动作
			if(_actionInfo.endIdle) playStand();
			
			dispatchEvent(new AvatarEvent(AvatarEvent.ACTION_END));
		}
		
		
		/**
		 * 加载资源事件
		 * @param event
		 */
		private function loadItemEventHandler(event:LoadEvent):void
		{
			if(event.lim.url != Animation.getUrl(_avatarAni.sourceName)) return;//不是当前动画对应的资源
			
			if(event.type == LoadEvent.PROGRESS) {
				_loading.progress = event.lim.bytesLoaded / event.lim.bytesTotal;
			}
			else {
				Common.loader.removeEventListener(LoadEvent.PROGRESS, loadItemEventHandler);
				Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loadItemEventHandler);
				var loading:DisplayObject = _loading as DisplayObject;
				if(loading.parent) this.removeChild(loading);
			}
		}
		
		
		
		
		/**
		 * 显示当前的帧频
		 */
		private function showFPS():void
		{
			switch(_actionInfo.action)
			{
				case RpgConstants.A_APPEAR:
					_avatarAni.fps = RpgConstants.FPS_APPEAR * _animationSpeed;
					break;
				case RpgConstants.A_STAND:
					_avatarAni.fps = RpgConstants.FPS_STAND * _animationSpeed;
					break;
				case RpgConstants.A_RUN:
					_avatarAni.fps = RpgConstants.FPS_RUN * _animationSpeed;
					break;
				case RpgConstants.A_ATTACK:
					_avatarAni.fps = RpgConstants.FPS_ATTACK * _animationSpeed;
					break;
				case RpgConstants.A_CONJURE:
					_avatarAni.fps = RpgConstants.FPS_CONJURE * _animationSpeed;
					break;
				case RpgConstants.A_HITTED:
					_avatarAni.fps = RpgConstants.FPS_HITTED * _animationSpeed;
					break;
				case RpgConstants.A_DEAD:
					_avatarAni.fps = RpgConstants.FPS_DEAD * _animationSpeed;
					break;
				case RpgConstants.A_LEISURE:
					_avatarAni.fps = RpgConstants.FPS_LEISURE * _animationSpeed;
					break;
			}
			playAdjunctAnimation();
		}
		
		
		
		public function addAdjunct(type:String=null, pic:String=null):void
		{
			if(type == null || pic == null) return;
			
			var ani:Animation = new Animation();
			(_shapeC.getChildByName(type) as Sprite).addChild(ani);
			_adjuncts.push({ type:type, pic:pic, ani:ani });
			
			playAdjunctAnimation();
		}
		
		public function removeAdjunct(type:String=null, pic:String=null):void
		{
			for(var i:int = 0; i < _adjuncts.length; i++)
			{
				var info:Object = _adjuncts[i];
				if(type == null || type == info.type) {
					if(pic == null || pic == info.pic)
					{
						info.ani.parent.removeChild(info.ani);
						_adjuncts.splice(i, 1);
						i--;
					}
				}
			}
		}
		
		/**
		 * 播放附属物的动画
		 */
		private function playAdjunctAnimation():void
		{
			for(var i:int = 0; i < _adjuncts.length; i++)
			{
				var info:Object = _adjuncts[i];
				var ani:Animation = info.ani;
				
				ani.sourceName = "adjunct." + info.type + "." + info.pic + "." + _actionInfo.action + _assetDirection;
				ani.fps = _avatarAni.fps;
				ani.play(_avatarAni.currentFrame, _avatarAni.repeatCount, _avatarAni.stopFrame);
				
				//武器需要根据方向调换透视深度
				if(info.type == RpgConstants.ADJUNCT_TYPE_WEAPON) {
					_shapeC.addChildAt(_shapeC.getChildByName(info.type), RpgConstants.WEAPON_DEPTH[_assetDirection]);
				}
			}
		}
		
		
		
		public function addUI(ui:IAvatarUI, name:String="basic", index:int=-1):void
		{
			//已存在该名称的UI，先移除
			var oldUI:IAvatarUI = this.getChildByName(name) as IAvatarUI;
			if(oldUI != null) {
				if(oldUI != ui) {
					oldUI.dispose();
					this.removeChild(oldUI as DisplayObject);
				}
			}
			
			ui.name = name;
			ui.avatar = this;
			
			if(index < 0) index = this.numChildren;
			this.addChildAt(ui as DisplayObject, index);
		}
		
		public function removeUI(name:String="basic"):IAvatarUI
		{
			var ui:IAvatarUI = this.getChildByName(name) as IAvatarUI;
			if(ui != null) {
				ui.dispose();
				this.removeChild(ui as DisplayObject);
			}
			return ui;
		}
		
		public function getUI(name:String="basic"):IAvatarUI
		{
			return this.getChildByName(name) as IAvatarUI;
		}
		
		
		
		
		
		public function set map(value:IRpgMap):void
		{
			if(_map != null) _map.removeAvatar(this);
			_map = value;
			_map.addAvatar(this);
		}
		public function get map():IRpgMap { return _map; }
		
		
		public function set key(value:String):void
		{
			if(value == null) {
				Logger.addLog("[RPG] 角色的 key 不能为 null", Logger.LOG_TYPE_WARN);
				return;
			}
			
			_key = value;
			this.name = "avatar" + _key;
		}
		public function get key():String { return _key; }
		
		
		public function set data(value:*):void { _data = value; }
		public function get data():* { return _data; }
		
		
		public function set pic(value:String):void
		{
			if(value == _pic) return;
			_pic = value;
			
			var url1:String = Common.config.getUIConfig(RpgConstants.CN_ANI_AVATAR, _pic, 1);
			var url2:String = Common.config.getUIConfig(RpgConstants.CN_ANI_AVATAR, _pic, 2);
			
			//还没加载好所有的动画资源
			if(!Common.loader.hasResLoaded(url1) && !Common.loader.hasResLoaded(url2))
			{
				//加载角色外形，第1部分，基础资源，站立行走等
				var lim:LoadItemModel = new LoadItemModel();
				lim.parseUrl(url1);
				lim.type = Constants.RES_TYPE_BINARY;
				lim.isSecretly = true;
				lim.priority = (_priority != 0) ? _priority : Constants.PRIORITY_AVATAR;
				Common.loader.add(lim);
				
				//第2部分，战斗相关动画等
				lim = new LoadItemModel();
				lim.parseUrl(url2);
				lim.type = Constants.RES_TYPE_BINARY;
				lim.isSecretly = true;
				lim.priority = (_priority != 0) ? _priority : Constants.PRIORITY_AVATAR;
				Common.loader.add(lim);
				
				Common.loader.start();
			}
			//正在执行动作
			if(_actionInfo != null) {
				playAction(_actionInfo.action, _actionInfo.replay, _avatarAni.currentFrame, _actionInfo.endIdle);
			}
		}
		public function get pic():String { return _pic; }
		
		
		public function set direction(value:uint):void { _direction = value; }
		public function get direction():uint { return _direction; }
		
		
		public function set is8Direction(value:Boolean):void { _is8Direction = value; }
		public function get is8Direction():Boolean { return _is8Direction; }
		
		
		
		public function set tile(value:Point):void
		{
			changeTile(value);
			_moveing = false;
			
			//map=null 表示还在createAvatar阶段
			if(_map != null) {
				var p:Point = RpgUtil.getTileCenter(_tile, _map.info);
				this.x = p.x;
				this.y = p.y;
				CachePool.recover(p);
				
				dispatchEvent(new AvatarEvent(AvatarEvent.TILE_CHANGED));//排序依赖该事件，所以必须抛出
			}
		}
		public function get tile():Point { return _tile; }
		
		/**
		 * 更新tile
		 * @param newTile
		 */
		private function changeTile(newTile:Point):void
		{
			if(_map == null) {
				_tile = newTile;
				return;
			}
			
			//从之前的列表中移除
			var avatars:Vector.<IAvatar> = _map.getAvatarListFromTile(_tile);
			if(avatars.length > 0) {
				var i:int = avatars.indexOf(this);
				if(i != -1) avatars.splice(i, 1);
			}
			
			//更新tile
			_tile = newTile;
			
			//添加到现在的列表中
			_map.getAvatarListFromTile(_tile).push(this);
		}
		
		
		public function set isDead(value:Boolean):void { _isDead = value; }
		public function get isDead():Boolean { return _isDead; }
		
		
		public function set moveAction(value:String):void { _moveAction = value; }
		public function get moveAction():String { return _moveAction; }
		
		
		public function set moveSpeed(value:Number):void
		{
			if(value == _moveSpeed) return;
			_moveSpeed = value;
			
			if(_moveAddPixel.x != 0) {
				_moveAddPixel.x = _moveAddPixel.x < 0 ? -RpgConstants.AVATAR_MOVE_ADD_X : RpgConstants.AVATAR_MOVE_ADD_X;
				_moveAddPixel.x *= value;
			}
			if(_moveAddPixel.y != 0) {
				_moveAddPixel.y = _moveAddPixel.y < 0 ? -RpgConstants.AVATAR_MOVE_ADD_Y : RpgConstants.AVATAR_MOVE_ADD_Y;
				_moveAddPixel.y *= value;
			}
		}
		public function get moveSpeed():Number { return _moveSpeed; }
		
		
		public function set animationSpeed(value:Number):void
		{
			_animationSpeed = value;
			showFPS();
		}
		public function get animationSpeed():Number { return _animationSpeed; }
		
		
		public function set speed(value:Number):void
		{
			moveSpeed = value;
			animationSpeed = value;
		}
		
		
		public function get road():Array { return _road; }
		
		
		public function get moveing():Boolean { return _moveing; }
		
		
		public function set priority(value:int):void { _priority = value; }
		public function get priority():int { return _priority; }
		
		
		public function set loadingClass(value:Class):void
		{
			_loadingClass = value;
			if(_loading != null) {
				var progress:Number = _loading.progress;
				_loading.clear();
				
				_loading = new _loadingClass();
				_loading.progress = progress;
			}
		}
		
		
		public function set dispatchMoveing(value:Boolean):void { _dispatchMoveing = value; }
		public function get dispatchMoveing():Boolean { return _dispatchMoveing; }
		
		
		public function get action():String
		{
			return _actionInfo.action;
		}
		
		public function get avatarAni():IAnimation
		{
			return _avatarAni;
		}
		
		public function get cleared():Boolean
		{
			return _moveTimer == null;
		}
		
		
		
		
		public function get interactiveEnabled():Boolean { return true; }
		
		public function get isTransparent():Boolean { return true; }
		
		public function get isCancelEvent():Boolean { return true; }
		
		public function get isCancelDrag():Boolean { return false; }
		
		
		public function onMoveOver():void
		{
			this.dispatchEvent(new AvatarEvent(AvatarEvent.MOUSE_OVER));
		}
		
		public function onMoveOut():void
		{
			this.dispatchEvent(new AvatarEvent(AvatarEvent.MOUSE_OUT));
		}
		
		public function onMoveDown():void
		{
			this.dispatchEvent(new AvatarEvent(AvatarEvent.MOUSE_DOWN));
		}
		
		public function onClick():void
		{
			this.dispatchEvent(new AvatarEvent(AvatarEvent.CLICK));
		}
		
		
		
		
		public function clear():void
		{
			Common.loader.removeEventListener(LoadEvent.PROGRESS, loadItemEventHandler);
			Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loadItemEventHandler);
			
			for(var i:int=0; i < this.numChildren; i++) {
				var ui:IAvatarUI = this.getChildAt(i) as IAvatarUI;
				if(ui != null) {
					ui.dispose();
					this.removeChildAt(i);
					i--;
				}
			}
			
			while(_adjuncts.length > 0) _adjuncts.shift().ani.stop();
			
			if(_loading != null) {
				_loading.clear();
				_loading = null;
			}
			
			if(_avatarAni != null) {
				_avatarAni.callback = null;
				_avatarAni.dispose();
				_avatarAni = null;
			}
			
			if(_moveTimer != null) {
				_moveTimer.stop();
				_moveTimer = null;
			}
			
			if(_standTimer != null) {
				_standTimer.stop();
				_standTimer = null;
			}
		}
		//
	}
}