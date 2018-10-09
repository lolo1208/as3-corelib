package lolo.core
{
	import flash.events.IEventDispatcher;
	
	import lolo.data.LoadItemModel;
	
	/**
	 * 加载管理器
	 * @author LOLO
	 */
	public interface ILoadManager extends IEventDispatcher
	{
		/**
		 * 添加一个加载项模型到加载队列中
		 * @param lim 加载项模型
		 * @return 如果文件已在加载列表，或者已经加载完毕，将返回原先的加载项模型，并同步isSecretly和priority。否则返回参数lim传入的加载项模型
		 */
		function add(lim:LoadItemModel):LoadItemModel;
		
		
		/**
		 * 开始加载所有项目（包括暗中加载和正常加载）
		 * @param callback 显示加载项全部加载完成时的回调
		 * @param allCompleteCallback 所有加载项全部加载完毕时的回调
		 */
		function start(callback:Function=null, allCompleteCallback:Function=null):void;
		
		
		/**
		 * 停止所有项目的加载（包括暗中加载和正常加载），以及正在加载的项目
		 */
		function stop():void;
		
		
		/**
		 * 对需要加载的文件列表进行排序
		 */
		function sortLoadList():void;
		
		
		/**
		 * 清除加载列表
		 * @param type 类型[ 0:所有加载项, 1:所有显示加载项, 2:所有隐藏加载项 ]
		 */
		function clearLoadList(type:uint=0):void;
		
		/**
		 * 将指定的加载项从加载列表中移除
		 * @param lim
		 */
		function remove(lim:LoadItemModel):void;
		
		
		/**
		 * 通过url获取已加载好的资源。如果还加载完成，则返回null
		 * @param url
		 * @param clear 获取后是否清除
		 * @return	RES_TYPE_CLA 返回：swf所属的 ApplicationDomain <br/>
		 * 			RES_TYPE_IMG 返回：BitmapData <br/>
		 * 			RES_TYPE_SWF 返回：swf内容本身（loader.content） <br/>
		 * 			RES_TYPE_ZIP 返回：ZipReader <br/>
		 * 			RES_TYPE_XML 返回：XML
		 */
		function getResByUrl(url:String, clear:Boolean=false):*;
		
		
		/**
		 * 通过配置文件(ResConfig)中的名称，获取已加载好的资源
		 * @param configName
		 * @param clear 获取后是否清除
		 * @param urlArgs url的替换参数
		 * @return 见getResByUrl()方法
		 */
		function getResByConfigName(configName:String, clear:Boolean=false, urlArgs:Array=null):*;
		
		
		/**
		 * 通过url获取已创建的加载项数据模型。如果还未创建，则返回null
		 * @param url
		 * @return 
		 */
		function getLoadItemModelByUrl(url:String):LoadItemModel;
		
		
		/**
		 * 通过资源获取已创建的加载项数据模型。如果还未创建，则返回null
		 * @param res
		 * @return 
		 */
		function getLoadItemModelByRes(res:*):LoadItemModel;
		
		
		/**
		 * 通过url检测资源是否已经加载完成
		 * @param url
		 */
		function hasResLoaded(url:String):Boolean;
		
		
		
		/**
		 * 加载器是否正在运行中
		 * @return 
		 */
		function get running():Boolean;
		
		
		/**
		 * 是否为暗中加载状态（正在加载和将要加载的文件全部都是暗中加载项）
		 * @return 
		 */
		function get isSecretly():Boolean;
		
		
		
		/**
		 * 当前显示加载文件的编号
		 */
		function get numCurrent():uint;
		
		/**
		 * 当前显示加载文件的总数
		 */
		function get numTotal():uint;
	}
	//
}