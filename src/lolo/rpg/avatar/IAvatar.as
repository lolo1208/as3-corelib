package lolo.rpg.avatar
{
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import lolo.display.IAnimation;
	import lolo.rpg.map.IRpgMap;
	import lolo.utils.optimize.IInteractiveObject;
	
	/**
	 * RPG角色接口
	 * @author LOLO
	 */
	public interface IAvatar extends IInteractiveObject, IEventDispatcher
	{
		/**
		 * 角色会自动寻路，并移动到指定的区块坐标
		 * @param tp 目的地区块坐标
		 */
		function moveToTile(tp:Point):void;
		
		/**
		 * 根据整条路径进行移动
		 * @param road 路径（区块坐标列表 [ [x,y], [x,y], ... ]）
		 */
		function moveByRoad(road:Array):void;
		
		/**
		 * 将整条路径添加到移动路径列表中
		 * @param road 路径（区块坐标列表 [ [x,y], [x,y], ... ]）
		 */
		function addRoad(road:Array):void;
		
		/**
		 * 停止移动
		 */
		function stopMove():void;
		
		/**
		 * 播放站立动作
		 * @param direction 方向。默认值0表示不改变当前方向
		 * @param delay 延时。常用解决于移动与站立的频繁切换（由于网络延迟导致的）。
		 */
		function playStand(direction:uint=0, delay:uint=0):void;
		
		/**
		 * 播放指定动作（动画）
		 * @param action 动作的名称
		 * @param replay 是否重复播放
		 * @param startFrame 开始帧
		 * @param endIdle 结束播放时，是否自动切换到站立动作
		 */
		function playAction(action:String, replay:Boolean=false, startFrame:uint=1, endIdle:Boolean=true):void;
		
		/**
		 * 添加附属物（服装、发型、武器等会与人物同步播放的动画，类型必须是Animation）
		 * @param type 
		 * @param pic
		 */
		function addAdjunct(type:String=null, pic:String=null):void;
		
		/**
		 * 移除附属物
		 * @param type 如果该值为null，将会移除所有附属物
		 * @param pic 如果传入该值，将会移除 type + pic 的附属物，否则会删除该type所有的附属物
		 */
		function removeAdjunct(type:String=null, pic:String=null):void;
		
		/**
		 * 添加UI
		 * @param ui UI的实例
		 * @param name UI的名称
		 * @param index UI层叠的位置（小于0表示放在最上层）
		 */
		function addUI(ui:IAvatarUI, name:String="basic", index:int=-1):void;
		
		/**
		 * 通过名称移除UI
		 * @param name
		 * @return 
		 */
		function removeUI(name:String="basic"):IAvatarUI;
		
		/**
		 * 通过名称获取UI
		 * @param name
		 * @return 
		 */
		function getUI(name:String="basic"):IAvatarUI;
		
		/**
		 * 清理，丢弃该角色时，需要调用该方法
		 */
		function clear():void;
		
		
		
		
		/**
		 * 所属的RpgMap
		 */
		function set map(value:IRpgMap):void;
		function get map():IRpgMap;
		
		/**
		 * 角色在map中的唯一key
		 */
		function set key(value:String):void;
		function get key():String;
		
		/**
		 * 附带的数据
		 */
		function set data(value:*):void;
		function get data():*;
		
		/**
		 * 角色的外形
		 */
		function set pic(value:String):void;
		function get pic():String;
		
		/**
		 * 方向
		 */
		function set direction(value:uint):void;
		function get direction():uint;
		
		/**
		 * 是否为8方向素材，默认值为：RpgConstants.IS_8_DIRECTION
		 */
		function set is8Direction(value:Boolean):void;
		function get is8Direction():Boolean;
		
		/**
		 * 区块坐标。设置该值，角色将会立即变换到该位置，并停止移动
		 */
		function set tile(value:Point):void;
		function get tile():Point;
		
		/**
		 * 是否已死亡
		 */
		function set isDead(value:Boolean):void;
		function get isDead():Boolean;
		
		/**
		 * 当前移动的动作（默认：RpgConstants.A_RUN）
		 */
		function set moveAction(value:String):void;
		function get moveAction():String;
		
		/**
		 * 移动速度
		 */
		function set moveSpeed(value:Number):void;
		function get moveSpeed():Number;
		
		/**
		 * 动画的播放速度
		 */
		function set animationSpeed(value:Number):void;
		function get animationSpeed():Number;
		
		/**
		 * 整体速度（设置该值会同时修改 moveSpeed 和 animationSpeed）
		 */
		function set speed(speed:Number):void;
		
		/**
		 * 是否正在移动中
		 */
		function get moveing():Boolean;
		
		/**
		 * 正在移动的（剩余）路径
		 */
		function get road():Array;
		
		/**
		 * 外形的加载优先级，数字越大，优先级越高
		 */
		function set priority(value:int):void;
		function get priority():int;
		
		/**
		 * 角色加载外形时，显示的Loading的Class
		 */
		function set loadingClass(value:Class):void;
		
		/**
		 * 是否需要抛出 AvatarEvent.MOVEING 事件（默认不抛）
		 */
		function set dispatchMoveing(value:Boolean):void;
		function get dispatchMoveing():Boolean;
		
		/**
		 * 当前正在执行的动作（没有在动作执行时，返回null）
		 */
		function get action():String;
		
		/**
		 * 角色的外形动画
		 */
		function get avatarAni():IAnimation;
		
		/**
		 * 是否已经被清理了
		 */
		function get cleared():Boolean;
		
		
		
		/**
		 * 像素x坐标
		 */
		function set x(value:Number):void;
		function get x():Number;
		
		/**
		 * 像素y坐标
		 */
		function set y(value:Number):void;
		function get y():Number;
		
		/**
		 * 是否可见
		 */
		function set visible(value:Boolean):void;
		function get visible():Boolean;
		
		/**
		 * 透明度
		 */
		function set alpha(value:Number):void;
		function get alpha():Number;
		
		/**
		 * 滤镜列表
		 */
		function set filters(value:Array):void;
		function get filters():Array;
		//
	}
}