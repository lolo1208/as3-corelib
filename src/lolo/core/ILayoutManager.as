package lolo.core
{
	import flash.display.DisplayObject;
	import flash.geom.Point;

	/**
	 * 布局管理
	 * @author LOLO
	 */
	public interface ILayoutManager
	{
		
		/**
		 * 添加一个需要根据舞台尺寸调整位置的显示对象<br/>
		 * <font color="red">在丢弃 target 对象时，一定要调用 removeStageLayout() 方法，不然会导致内存泄漏</font>
		 * @param target 参数解释见 stageLayout() 方法
		 * @param args 
		 */
		function addStageLayout(target:DisplayObject, args:Object):void;
		
		
		/**
		 * 根据舞台尺寸调整显示对象的位置
		 * @param target 要调整位置的显示对象
		 * @param args	可用属性： { width, height, x, y, paddingRight, offsetX, paddingBottom, offsetY, cancelH, cancelV }<br/><br/>
		 * 				<b>属性解释，以水平方向为例：</b><br/><br/>
		 * 					1.目标默认水平居中于舞台。<br/>
		 * 					　默认获取 target.width，如果有设置 width 则使用 width。<br/>
		 * 					　如果有实现 IWindowLayout 接口，则使用 layoutWidth。<br/><br/>
		 * 					2.在居中的基础上，可以设置 offsetX 左右偏移目标的位置。<br/><br/>
		 * 					3.如果设置 paddingRight，将会 <b>取消居中</b>，只会贴于舞台右侧。<br/><br/>
		 * 					4.如果设置 x 将会 <b>取消居中</b> 和 <b>贴于舞台右侧</b>，只会使用 x 属性。<br/>
		 * 					　x 的值为舞台宽度的百分数，1 = 100%。<br/>
		 * 					　例如：x=0.6 在 stageWidth=1200 时表示 target.x=720<br/><br/>
		 * 					5.如果在水平方向不想具有根据舞台尺寸调整位置的功能，可以设置 cancelH=true。<br/><br/>
		 * 
		 * 				如果该值为 <b>null</b>，将会在已注册的列表中寻找参数<br/>
		 * 				可以调用该方法，传入null，刷新target在舞台的相对位置
		 */
		function stageLayout(target:DisplayObject, args:Object=null):void;
		
		
		/**
		 * 移除一个需要根据舞台尺寸调整位置的显示对象
		 * @param target
		 */
		function removeStageLayout(target:DisplayObject):void;
		
		
		/**
		 * 根据参数，获取显示对象的舞台相对位置
		 * @param target 
		 * @param args 如果该值为null，将会在已注册的列表中寻找参数
		 * @return 
		 */
		function getStageLayout(target:DisplayObject, args:Object=null):Point;
		
		
		/**
		 * 设置显示对象（注册列表中的）是否启用舞台布局
		 * @param target
		 * @param enabled
		 */
		function setStageLayoutEnabled(target:DisplayObject, enabled:Boolean):void;
		
		
		
		/**
		 * 将显示对象居中于舞台
		 * @param target 要居中于舞台的目标
		 * @param width 默认值：0，将会使用 target.width
		 * @param height 默认值：0，将会使用 target.height
		 */
		function toStageCenter(target:DisplayObject, width:uint=0, height:uint=0):void;
		//
	}
}