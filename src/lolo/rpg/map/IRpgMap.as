package lolo.rpg.map
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lolo.rpg.avatar.IAvatar;
	
	/**
	 * RPG地图接口
	 * @author LOLO
	 */
	public interface IRpgMap extends IEventDispatcher
	{
		
		/**
		 * 创建一个角色，加入到地图中，并返回该角色的实例
		 * @param key 角色在map中的唯一key（如果已经有角色使用该key，将会更新该角色，而不是创建）
		 * @param pic 角色的pic
		 * @param horesPic 角色坐骑的pic
		 * @param priority 加载优先级，数字越大，优先级越高
		 * @param tile 角色所在的区块坐标，默认值null表示随机位置
		 * @param direction 角色的方向，默认值0表示随机方向
		 * @return 
		 */
		function createAvatar(key:String, pic:String=null, horesPic:String=null, priority:int=0, tile:Point=null, direction:uint=0):IAvatar;
		
		/**
		 * 将角色添加到地图中
		 * @param avatar
		 */
		function addAvatar(avatar:IAvatar):void;
		
		/**
		 * 移除角色
		 * @param avatar
		 */
		function removeAvatar(avatar:IAvatar):void;
		
		/**
		 * 通过key来获取角色
		 * @param key
		 * @return 
		 */
		function getAvatarByKey(key:String):IAvatar;
		
		/**
		 * 获取所有角色
		 * @return 
		 */
		function getAllAvatar():Vector.<IAvatar>;
		
		
		
		
		/**
		 * 初始化地图
		 * @param id 地图的ID
		 */
		function init(id:String):void;
		
		/**
		 * 滚动地图
		 * @param position 目标像素位置（屏幕中心）
		 * @param now 是否立即滚动到该位置
		 * @param duration 缓动持续时间
		 */
		function scroll(position:Point, now:Boolean=false, duration:Number=0.5):void
		
		/**
		 * 获取屏幕在整张地图中的位置（范围）
		 * @param offsets 偏移（缓冲区域半径）
		 * @return 
		 */
		function getScreenArea(offsets:int=50):Rectangle;
		
		/**
		 * 获取屏幕范围内的玩家列表
		 * @return 
		 */
		function getScreenAvatars():Vector.<IAvatar>;
		
		/**
		 * 获取指定区块点上的角色列表
		 * @param tile
		 * @return 
		 */
		function getAvatarListFromTile(tile:Point):Vector.<IAvatar>;
		
		/**
		 * 添加一个显示元素
		 * @param element
		 * @param above 是否在所有角色和遮挡物之上
		 * @param depth 要添加到的图层深度（负数表示添加到最上层）
		 */
		function addElement(element:DisplayObject, above:Boolean, depth:int=-1):void;
		
		/**
		 * 清理所有的Avatar（保留地图背景数据等）
		 */
		function clearAllAvatar():void;
		
		/**
		 * 清理，丢弃该RpgMap时，需要调用该方法
		 */
		function clear():void;
		
		
		
		
		
		/**
		 * 地图的ID
		 */
		function get id():String;
		
		/**
		 * 地图的配置信息
		 */
		function get info():MapInfo;
		
		/**
		 * 顶级容器（不要直接添加或移除该容器内的显示对象，可以使用addElement()方法添加显示对象）
		 */
		function get container():DisplayObjectContainer;
		
		/**
		 * 屏幕中心位置（要设置该值，可以调用 scroll(p, true) 方法）
		 */
		function get screenCenter():Point;
		
		
		/**
		 * 镜头跟踪的角色
		 */
		function set trackingAvatar(value:IAvatar):void;
		function get trackingAvatar():IAvatar;
		
		
		/**
		 * 当前鼠标下的角色
		 */
		function get mouseAvatar():IAvatar;
		
		
		/**
		 * 当前鼠标所在区块点
		 */
		function get mouseTile():Point;
		
		
		/**
		 * 鼠标在背景上按下时，是否自动播放鼠标点击动画
		 */
		function set autoPlayMouseDownAnimation(value:Boolean):void;
		function get autoPlayMouseDownAnimation():Boolean;
		
		
		/**
		 * 角色走到被遮挡的区块上时，是否半透明
		 */
		function set autoCoverAvatar(value:Boolean):void;
		function get autoCoverAvatar():Boolean;
		
		
		/**
		 * 角色是否可以和鼠标交互（是否派发相关AvatarEvent）
		 */
		function set avatarMouseEnabled(value:Boolean):void;
		function get avatarMouseEnabled():Boolean;
		
		
		/**
		 * 鼠标拖动容器时，回调的函数。draggingHandler(x:int, y:int)
		 */
		function set draggingHandler(value:Function):void;
		function get draggingHandler():Function;
		
		
		/**
		 * 是否在对avatar进行排序后抛出 RpgMapEvent.AVATAR_SORTED 事件。默认:false
		 */
		function set dispatchAvatarSorted(value:Boolean):void;
		function get dispatchAvatarSorted():Boolean;
		
		
		/**
		 * 水平缩放比例
		 */
		function set scaleX(value:Number):void;
		function get scaleX():Number;
		
		/**
		 * 垂直缩放比例
		 */
		function set scaleY(value:Number):void;
		function get scaleY():Number;
		
		
		
		/**
		 * 暂停或继续加载图块
		 * @param pause [ true:暂停加载，false:继续加载 ]
		 */
		function pauseOrContinueLoadChunk(pause:Boolean):void;
		
		
		
		/**
		 * 是否已经被清理了
		 */
		function get cleared():Boolean;
		//
	}
}