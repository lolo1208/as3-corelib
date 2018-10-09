package lolo.core
{
	/**
	 * 框架中用到的常量集合
	 * @author LOLO
	 */
	public class Constants
	{
		/**后台服务类型 - tcp socket*/
		public static const SERVICE_TYPE_SOCKET:String = "socket";
		/**后台服务类型 - http*/
		public static const SERVICE_TYPE_HTTP:String = "http";
		
		
		/**class类型的资源*/
		public static const RES_TYPE_CLA:String = "class";
		/**图片类型的资源*/
		public static const RES_TYPE_IMG:String = "image";
		/**swf类型的资源*/
		public static const RES_TYPE_SWF:String = "swf";
		/**zip类型的资源*/
		public static const RES_TYPE_ZIP:String = "zip";
		/**xml类型的资源*/
		public static const RES_TYPE_XML:String = "xml";
		/**二进制类型的资源*/
		public static const RES_TYPE_BINARY:String = "binary";
		/**字体类型的资源*/
		public static const RES_TYPE_FONT:String = "font";
		
		
		/**后缀名 - 自定义数据*/
		public static const EXTENSION_LD:String = "ast";
		/**扩展名 - png*/
		public static const EXTENSION_PNG:String = "png";
		/**扩展名 - jpg*/
		public static const EXTENSION_JPG:String = "jpg";
		/**扩展名 - gif*/
		public static const EXTENSION_GIF:String = "gif";
		
		
		/**类型标记 - 纹理数据(TextureData)*/
		public static const FLAG_TD:int = 1;
		/**类型标记 - 地图信息(MapInfo)*/
		public static const FLAG_MI:int = 2;
		/**类型标记 - 图块数据(ChunkData)*/
		public static const FLAG_CD:int = 4;
		/**类型标记 - 动画数据(AimationData)*/
		public static const FLAG_AD:int = 3;
		/**类型标记 - 图片数据包(ImageDataPackage)*/
		public static const FLAG_IDP:int = 5;
		/**类型标记 - 无损的图片数据包(LosslessImageDataPackage)*/
		public static const FLAG_LIDP:int = 6;
		
		
		/**鼠标状态 - 正常*/
		public static const MOUSE_STATE_NORMAL:String = "normal";
		/**鼠标状态 - 按下*/
		public static const MOUSE_STATE_PRESS:String = "press";
		
		
		/**背景层的名称*/
		public static const LAYER_NAME_BG:String = "background";
		/**场景层的名称*/
		public static const LAYER_NAME_SCENE:String = "scene";
		/**UI层的名称*/
		public static const LAYER_NAME_UI:String = "ui";
		/**窗口层的名称*/
		public static const LAYER_NAME_WINDOW:String = "window";
		/**顶级UI层*/
		public static const LAYER_NAME_UI_TOP:String = "uiTop";
		/**提示层的名称*/
		public static const LAYER_NAME_ALERT:String = "alert";
		/**游戏指导层的名称*/
		public static const LAYER_NAME_GUIDE:String = "guide";
		/**顶级层的名称*/
		public static const LAYER_NAME_TOP:String = "top";
		/**装饰层的名称*/
		public static const LAYER_NAME_ADORN:String = "adorn";
		
		
		/**状态 - 正常*/
		public static const STATE_UP:String = "up";
		/**状态 - 鼠标移上来*/
		public static const STATE_OVER:String = "over";
		/**状态 - 鼠标按下*/
		public static const STATE_DOWN:String = "down";
		/**状态 - 禁用*/
		public static const STATE_DISABLED:String = "disabled";
		/**状态 - 选中：正常*/
		public static const STATE_SELECTED_UP:String = "selectedUp";
		/**状态 - 选中：鼠标移上来*/
		public static const STATE_SELECTED_OVER:String = "selectedOver";
		/**状态 - 选中：鼠标按下*/
		public static const STATE_SELECTED_DOWN:String = "selectedDown";
		/**状态 - 选中：禁用*/
		public static const STATE_SELECTED_DISABLED:String = "selectedDisabled";
		
		
		/**绝对定位（布局时表示：使用子项的x,y进行布局）*/
		public static const ABSOLUTE:String = "absolute";
		/**水平方向*/
		public static const HORIZONTAL:String = "horizontal";
		/**垂直方向*/
		public static const VERTICAL:String = "vertical";
		
		/**水平对齐方式 - 左对齐*/
		public static const ALIGN_LEFT:String = "left";
		/**水平对齐方式 - 水平居中*/
		public static const ALIGN_CENTER:String = "center";
		/**水平对齐方式 - 右对齐*/
		public static const ALIGN_RIGHT:String = "right";
		
		/**垂直对齐方式 - 顶对齐*/
		public static const VALIGN_TOP:String = "top";
		/**垂直对齐方式 - 垂直居中*/
		public static const VALIGN_MIDDLE:String = "middle";
		/**垂直对齐方式 - 底对齐*/
		public static const VALIGN_BOTTOM:String = "bottom";
		
		
		/**策略 - 自动*/
		public static const POLICY_AUTO:String = "auto";
		/**策略 - 始终*/
		public static const POLICY_ON:String = "on";
		/**策略 - 从不*/
		public static const POLICY_OFF:String = "off";
		
		
		
		/**窗口移动效果耗时*/
		public static const EFFECT_DURATION_WINDOW_MOVE:Number = 0.3;
		
		
		/**加载优先级 - 角色动画*/
		public static const PRIORITY_AVATAR:int = 100;
		/**加载优先级 - 嵌入字体*/
		public static const PRIORITY_EMBED_FONT:int = -999999;
		//
	}
}