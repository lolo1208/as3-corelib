package lolo.display
{
	/**
	 * 模块
	 * @author LOLO
	 */
	public interface IModule extends IContainer
	{
		
		/**
		 * 初始化该模块</br>
		 * 该方法只会被 UIManager 调用一次，请将 initUI() 等初始化事务放在该方法内
		 * @param args 初始化参数
		 */
		function initialize(...args):void;
		
		
		/**
		 * 模块的名称
		 */
		function set moduleName(value:String):void;
		function get moduleName():String;
		
		
		
		/**
		 * 该模块对应XML的ConfigName（在deubg环境下用于重载）
		 */
		function set xmlConfigName(value:String):void;
		function get xmlConfigName():String;
		//
	}
}