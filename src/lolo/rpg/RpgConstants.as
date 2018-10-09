package lolo.rpg
{
	/**
	 * RPG相关的常量
	 * @author LOLO
	 */
	public class RpgConstants
	{
		
		/**地图数据在UIConfig中的名称*/
		public static const CN_MAP_DATA:String = "mapData";
		/**地图缩略图在UIConfig中的名称*/
		public static const CN_MAP_THUMBNAIL:String = "mapThumbnail";
		/**地图图块在UIConfig中的名称*/
		public static const CN_MAP_CHUNK:String = "mapChunk";
		/**地图遮挡物在UIConfig中的名称*/
		public static const CN_MAP_COVER:String = "mapCover";
		
		/**鼠标点击地图时播放的动画在UIConfig中的名称*/
		public static const CN_ANI_MAP_MOUSE_DOWN:String = "mapMouseDownAni";
		
		/**角色动画在UIConfig中的名称*/
		public static const CN_ANI_AVATAR:String = "avatarAnimation";
		/**坐骑动画在UIConfig中的名称*/
		public static const CN_ANI_HORSE:String = "horseAnimation";
		/**附属物动画在UIConfig中的名称*/
		public static const CN_ANI_ADJUNCT:String = "adjunctAnimation";
		
		
		/**附属物类型 - 服饰*/
		public static const ADJUNCT_TYPE_DRESS:String = "dress";
		/**附属物类型 - 发型*/
		public static const ADJUNCT_TYPE_HAIR:String = "hair";
		/**附属物类型 - 武器*/
		public static const ADJUNCT_TYPE_WEAPON:String = "weapon";
		
		
		/**偏移和代价，偶数行(0,2,4...)[direction]=[offsetX, offsetY, cost]*/
		public static const O_EVEN:Array = [ null, [0,-1,10], [1,0,14], [0,1,10], [0,2,14], [-1,1,10], [-1,0,14], [-1,-1,10], [0,-2,14] ];
		/**偏移和代价，奇数行*/
		public static const O_ODD:Array = [  null, [1,-1,10], [1,0,14], [1,1,10], [0,2,14], [ 0,1,10], [-1,0,14], [ 0,-1,10], [0,-2,14] ];
		/**偏移和代价，大菱形地图*/
		public static const O_RHO:Array = [  null, [1,0,10], [1,-1,14], [0,-1,10], [-1,-1,14], [-1,0,10], [-1,1,14], [0,1,10], [1,1,14] ];
		
		
		/**角色每次移动的X像素距离*/
		public static const AVATAR_MOVE_ADD_X:Number = 3.0;
		/**角色每次移动的Y像素距离*/
		public static const AVATAR_MOVE_ADD_Y:Number = 1.5;
		
		
		/**是否为8方向素材*/
		public static var is8Direction:Boolean = true;
		
		
		/**方向 - 上↑*/
		public static const D_UP:uint = 8;
		/**方向 - 下↓*/
		public static const D_DOWN:uint = 4;
		/**方向 - 左←*/
		public static const D_LEFT:uint = 6;
		/**方向 - 右→*/
		public static const D_RIGHT:uint = 2;
		/**方向 - 左上↖*/
		public static const D_LEFT_UP:uint = 7;
		/**方向 - 左下↙*/
		public static const D_LEFT_DOWN:uint = 5;
		/**方向 - 右上↗*/
		public static const D_RIGHT_UP:uint = 1;
		/**方向 - 右下↘*/
		public static const D_RIGHT_DOWN:uint = 3;
		
		
		/**武器在不同方向的层叠位置（透视角度） data[direction]=depth */
		public static const WEAPON_DEPTH:Array = [null, 3, 3, 3, 3, 0, 0, 0, 0];
		
		
		/**动作 - 出场*/
		public static const A_APPEAR:String = "appear";
		/**动作 - 站立*/
		public static const A_STAND:String = "stand";
		/**动作 - 跑动*/
		public static const A_RUN:String = "run";
		/**动作 - 攻击*/
		public static const A_ATTACK:String = "attack";
		/**动作 - 施法*/
		public static const A_CONJURE:String = "conjure";
		/**动作 - 受击*/
		public static const A_HITTED:String = "hitted";
		/**动作 - 死亡*/
		public static const A_DEAD:String = "dead";
		/**动作 - 休闲*/
		public static const A_LEISURE:String = "leisure";
		
		
		/**根据角色透视深度进行排序的间隔（毫秒）*/
		public static var AVATAR_DEPTH_SORT_DELAY:uint = 10;
		/**run动作结束时，启动定时器，在该延时后切换到stand动作（毫秒）*/
		public static var AVATAR_RUN_TO_STAND_DELAY:uint = 0;
		
		
		/**帧频 - 出场*/
		public static var FPS_APPEAR:uint = 9;
		/**帧频 - 站立*/
		public static var FPS_STAND:uint = 3;
		/**帧频 - 跑动*/
		public static var FPS_RUN:uint = 21;
		/**帧频 - 攻击*/
		public static var FPS_ATTACK:uint = 12;
		/**帧频 - 施法*/
		public static var FPS_CONJURE:uint = 12;
		/**帧频 - 受击*/
		public static var FPS_HITTED:uint = 0;
		/**帧频 - 死亡*/
		public static var FPS_DEAD:uint = 9;
		/**帧频 - 休闲*/
		public static var FPS_LEISURE:uint = 0;
		//
	}
}