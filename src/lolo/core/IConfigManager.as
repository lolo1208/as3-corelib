package lolo.core
{
	/**
	 * 配置信息管理
	 * @author LOLO
	 */
	public interface IConfigManager
	{
		/**
		 * 初始化网页目录下的Config.xml
		 */
		function initConfig():void;
		
		/**
		 * 初始化资源配置文件
		 * @param url 源配置文件的url
		 */
		function initResConfig(url:String):void;
		
		/**
		 * 初始化界面配置文件
		 */
		function initUIConfig():void;
		
		/**
		 * 初始化样式配置文件
		 * @param config
		 */
		function initStyleConfig(config:XML=null):void
		
		/**
		 * 初始化皮肤配置文件
		 */
		function initSkinConfig(config:XML=null):void;
		
		
		
		/**
		 * 获取网页目录下Config.xml文件的配置信息
		 * @param name 配置的名称
		 * @return
		 */
		function getConfig(name:String):String;
		
		/**
		 * 获取资源配置文件信息
		 * @param name 配置的名称
		 * @return { url, type, nameID, newAppDomain }
		 */
		function getResConfig(name:String):Object;
		
		/**
		 * 获取界面配置文件信息
		 * @param name 配置的名称
		 * @param rest 可变参数
		 * @return
		 */
		function getUIConfig(name:String, ...rest):String;
		
		
		/**
		 * 获取样式配置信息
		 * @param name 样式的名称
		 * @return 
		 */
		function getStyle(name:String):Object;
		
		
		/**
		 * 获取皮肤配置信息
		 * @param skinName 皮肤的名称
		 * @return [{state, sourceName}]
		 */
		function getSkin(skinName:String):Array;
		//
	}
}