package lolo.display
{
	/**
	 * 基本容器
	 * @author LOLO
	 */
	public interface IContainer extends IBaseSprite
	{
		
		/**
		 * 初始化用户界面
		 * @param config 界面的配置文件
		 */
		function initUI(config:XML):void;
		
		
		/**
		 * 在初始化界面完成后，是否立即显示
		 */
		function set initShow(value:Boolean):void;
		function get initShow():Boolean;
		//
	}
}