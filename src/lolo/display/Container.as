package lolo.display
{
	import lolo.utils.AutoUtil;

	/**
	 * 基本容器
	 * @author LOLO
	 */
	public class Container extends BaseSprite implements IContainer
	{
		/**用户界面配置*/
		protected var _uiConfig:XML;
		/**在初始化界面完成后，是否立即显示*/
		protected var _initShow:Boolean;
		
		
		
		/**
		 * 初始化用户界面
		 * @param config 界面的配置文件
		 */
		public function initUI(config:XML):void
		{
			_uiConfig = config;
			AutoUtil.autoUI(this, _uiConfig);
			if(_initShow) show();
		}
		
		
		/**
		 * 刷新用户界面
		 * @param config 界面的配置文件
		 */
		public function refreshUI(config:XML):void
		{
			_uiConfig = config;
			AutoUtil.refreshUI(this, _uiConfig);
		}
		
		
		
		public function set initShow(value:Boolean):void { _initShow = value; }
		public function get initShow():Boolean { return _initShow; }
		//
	}
}