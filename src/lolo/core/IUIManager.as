package lolo.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	
	import lolo.display.IModule;
	import lolo.display.IWindow;
	import lolo.ui.ILoadBar;
	import lolo.ui.IRequestModal;

	/**
	 * 用户界面管理
	 * @author LOLO
	 */
	public interface IUIManager extends IEventDispatcher
	{
		
		/**
		 * 初始化，入口函数
		 * @param args
		 */
		function initialize(...args):void;
		
		
		
		/**
		 * 显示指定模块
		 * @param moduleName 模块的名称
		 * @param args 显示模块（和加载模块）时附带的参数
		 */
		function showModule(moduleName:String, ...args):void;
		
		/**
		 * 获取指定ID的模块的实例
		 * @param moduleName
		 * @return 
		 */
		function getModule(moduleName:String):IModule;
		
		
		
		/**
		 * 打开指定窗口
		 * @param window 要打开的窗口
		 */
		function openWindow(window:IWindow):void;
		
		/**
		 * 关闭指定窗口
		 * @param window 要关闭的窗口
		 */
		function closeWindow(window:IWindow):void;
		
		/**
		 * 关闭所有窗口
		 */
		function closeAllWindow():void;
		
		
		
		/**
		 * 显示上一个场景
		 */
		function showPrevScene():void;
		
		/**
		 * 获取上一个场景的名称，没有上一个场景时，值为null
		 */
		function get prevSceneName():String;
		
		/**
		 * 获取当前场景的名称，没有进入场景时，值为null
		 */
		function get currentSceneName():String;
		
		
		
		/**
		 * 添加显示对象到指定的层中
		 * @param child 显示对象
		 * @param layerName 层的名称
		 */
		function addChildToLayer(child:DisplayObject, layerName:String):void;
		
		/**
		 * 从指定层中移除指定显示对象
		 * @param child 显示对象
		 * @param layerName 层的名称
		 */
		function removeChildToLayer(child:DisplayObject, layerName:String):void;
		
		/**
		 * 根据名称获取图层<br/>
		 * <font color="red">注意：</font>如果要在图层中添加或移除内容，请使用 addChildToLayer() 或  removeChildToLayer()
		 * @param layerName 
		 * @return 
		 */
		function getLayer(layerName:String):DisplayObjectContainer;
		
		
		/**
		 * 显示全屏模态（模态对象为单例，就算调用该方法多次，同时也只会有一个模态实例存在）
		 * @param alpha 模态透明度
		 * @param color 模态颜色
		 * @param layerName 将模态放置在该图层，可使用 Constants.LAYER_NAME_xxx 系列常量
		 * @param depth 模态在图层中的深度[ 0:最下面, 负数:最上面 ]
		 */
		function showModal(alpha:Number=0.01, color:uint=0x0, layerName:String="top", depth:int=0):void;
		
		/**
		 * 隐藏已显示的全屏模态
		 */
		function hideModal():void;
		
		
		
		/**
		 * 获取加载条的实例
		 * @return 
		 */
		function get loadBar():ILoadBar;
		
		/**
		 * 将与服务端通信的请求进行模态的界面
		 * @return 
		 */
		function get requestModal():IRequestModal;
		
		/**
		 * 当前已打开的窗口列表
		 */
		function get windowList():Vector.<IWindow>;
		
		/**
		 * 获取舞台宽度（介于最大宽度与最小宽度之间）
		 */
		function get stageWidth():uint;
		
		/**
		 * 获取舞台高度（介于最大高度与最小高度之间）
		 */
		function get stageHeight():uint;
		
		
		/**
		 * 最小舞台宽度
		 */
		function get minStageWidth():uint;
		
		/**
		 * 最小舞台高度
		 */
		function get minStageHeight():uint;
		
		/**
		 * 最大舞台宽度
		 */
		function get maxStageWidth():uint;
		
		/**
		 * 最大舞台高度
		 */
		function get maxStageHeight():uint;
		//
	}
}