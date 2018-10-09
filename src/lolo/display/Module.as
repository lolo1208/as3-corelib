package lolo.display
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.data.LoadItemModel;
	
	
	/**
	 * 模块
	 * @author LOLO
	 */
	public class Module extends Container implements IModule
	{
		/**需要重载的XML的ConfigName列表*/
		private static var _xmlReloadCNs:Dictionary = new Dictionary();
		
		/**模块的名称*/
		private var _moduleName:String;
		/**模块对应XML的ConfigName（deubg环境，用于重载）*/
		private var _xmlConfigName:String;
		
		
		
		
		public function Module()
		{
			super();
		}
		
		
		
		
		public function initialize(...args):void
		{
			throw new Error("请重写 initialize() 方法，并将 initUI() 等初始化事务放在该方法内");
		}
		
		
		
		
		public function set moduleName(value:String):void { _moduleName = value; }
		public function get moduleName():String { return _moduleName; }
		
		
		
		
		public function set xmlConfigName(value:String):void
		{
			if(!Common.isDebug) return;
			
			delete [_xmlConfigName];
			_xmlConfigName = value;
			_xmlReloadCNs[_xmlConfigName] = false;
			
			Common.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
		}
		public function get xmlConfigName():String { return _xmlConfigName; }
		
		
		
		/**
		 * 在舞台按键
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.F5) {
				for(var cn:String in _xmlReloadCNs)
				{
					//标记为true，下次startup()将会更新xml
					_xmlReloadCNs[cn] = true;
					
					//使用loader里的lim
					var lim:LoadItemModel = new LoadItemModel(cn);
					lim = Common.loader.getLoadItemModelByUrl(lim.url);
					Common.loader.getResByConfigName(cn, true);
					Common.loader.add(lim);
				}
				Common.loader.start();
			}
		}
		
		
		
		override protected function startup():void
		{
			super.startup();
			
			//是在debug环境，并且该模块对应XML需要被重载
			if(Common.isDebug && _xmlReloadCNs[_xmlConfigName]) {
				_xmlReloadCNs[_xmlConfigName] = false;
				refreshUI(Common.loader.getResByConfigName(_xmlConfigName));
			}
		}
		//
	}
}