package lolo.core
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import lolo.display.IBaseSprite;
	import lolo.display.IModule;
	import lolo.display.IScene;
	import lolo.display.IWindow;
	import lolo.events.SceneEvent;
	import lolo.ui.ILoadBar;
	import lolo.ui.IRequestModal;
	import lolo.ui.IWindowLayout;
	import lolo.utils.optimize.CachePool;
	
	/**
	 * 用户界面管理
	 * @author LOLO
	 */
	public class UIManager extends Sprite implements IUIManager
	{
		/**背景层*/
		protected var _bgLayer:Sprite;
		/**场景层*/
		protected var _sceneLayer:Sprite;
		/**UI层*/
		protected var _uiLayer:Sprite;
		/**窗口层*/
		protected var _windowLayer:Sprite;
		/**顶级UI层*/
		protected var _uiTopLayer:Sprite;
		/**提示消息层*/
		protected var _alertLayer:Sprite;
		/**游戏指导层*/
		protected var _guideLayer:Sprite;
		/**顶级层*/
		protected var _topLayer:Sprite;
		/**装饰层*/
		protected var _adornLayer:Sprite;
		
		/**全屏模态*/
		protected var _modal:Sprite;
		
		/**模块加载条*/
		protected var _loadBar:ILoadBar;
		/**将与服务端通信的请求进行模态的界面*/
		protected var _requestModal:IRequestModal;
		
		/**当前窗口*/
		protected var _nowWindow:IWindow;
		
		
		/**所有的模块信息列表*/
		protected var _moduleList:Dictionary;
		/**当前正在加载的模块的信息*/
		protected var _loadModuleInfo:Object;
		/**当前已经打开的窗口列表*/
		protected var _windowList:Vector.<IWindow>;
		
		/**当前场景的信息 { moduleName:模块名称, args:启动时参数 }*/
		protected var _currentSceneInfo:Object;
		/**上一个场景的信息{ moduleName:模块名称, args:启动时参数 }*/
		protected var _prevSceneInfo:Object;
		
		
		/**当前的舞台宽度*/
		protected var _stageWidth:uint;
		/**当前的舞台高度*/
		protected var _stageHeight:uint;
		
		
		
		public function UIManager()
		{
			super();
			this.mouseEnabled = false;
		}
		
		
		public function initialize(...args):void
		{
			_moduleList = new Dictionary();
			_windowList = new Vector.<IWindow>();
			
			_bgLayer = new Sprite();
			_bgLayer.mouseEnabled = false;
			_bgLayer.name = Constants.LAYER_NAME_BG;
			this.addChild(_bgLayer);
			
			_sceneLayer = new Sprite();
			_sceneLayer.mouseEnabled = false;
			_sceneLayer.name = Constants.LAYER_NAME_SCENE;
			this.addChild(_sceneLayer);
			
			_uiLayer = new Sprite();
			_uiLayer.mouseEnabled = false;
			_uiLayer.name = Constants.LAYER_NAME_UI;
			this.addChild(_uiLayer);
			
			_windowLayer = new Sprite();
			_windowLayer.mouseEnabled = false;
			_windowLayer.name = Constants.LAYER_NAME_WINDOW;
			this.addChild(_windowLayer);
			
			_uiTopLayer = new Sprite();
			_uiTopLayer.mouseEnabled = false;
			_uiTopLayer.name = Constants.LAYER_NAME_UI_TOP;
			this.addChild(_uiTopLayer);
			
			_alertLayer = new Sprite();
			_alertLayer.mouseEnabled = false;
			_alertLayer.name = Constants.LAYER_NAME_ALERT;
			this.addChild(_alertLayer);
			
			_guideLayer = new Sprite();
			_guideLayer.mouseEnabled = false;
			_guideLayer.name = Constants.LAYER_NAME_GUIDE;
			this.addChild(_guideLayer);
			
			_topLayer = new Sprite();
			_topLayer.mouseEnabled = false;
			_topLayer.name = Constants.LAYER_NAME_TOP;
			this.addChild(_topLayer);
			
			_adornLayer = new Sprite();
			_adornLayer.mouseEnabled = false;
			_adornLayer.name = Constants.LAYER_NAME_ADORN;
			this.addChild(_adornLayer);
			
			_modal = new Sprite();
			
			Common.stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, 9999);
			stage_resizeHandler();
		}
		
		
		
		/**
		 * 舞台尺寸有改变
		 * @param event
		 */
		private function stage_resizeHandler(event:Event=null):void
		{
			_stageWidth = (Common.stage != null) ? Common.stage.stageWidth : minStageWidth;
			if(_stageWidth < minStageWidth) _stageWidth = minStageWidth;
			if(_stageWidth > maxStageWidth) _stageWidth = maxStageWidth;
			
			_stageHeight = (Common.stage != null) ? Common.stage.stageHeight : minStageHeight;
			if(_stageHeight < minStageHeight) _stageHeight = minStageHeight;
			if(_stageHeight > maxStageHeight) _stageHeight = maxStageHeight;
			
			_modal.width = _stageWidth;
			_modal.height = _stageHeight;
		}
		
		
		
		/**
		 * 添加一个模块（Scene 或 Window）
		 * @param moduleName 模块的名称（完整类定义）
		 * @param limList 模块需要的资源列表
		 * @param initArgs 初始化模块时，传递的参数列表
		 */
		protected function addModule(moduleName:String, limList:Array, ...initArgs):void
		{
			if(_moduleList[moduleName] != null) {
				throw new Error("不能重复添加模块，请检查 moduleName：" + moduleName);
				return;
			}
			
			_moduleList[moduleName] = { instance:null, moduleName:moduleName, limList:limList, initArgs:initArgs };
		}
		
		
		public function showModule(moduleName:String, ...args):void
		{
			//当前有模块正在加载
			if(_loadModuleInfo != null)
			{
				//当前正在加载的模块，不是需要显示的模块。清除加载
				if(moduleName != _loadModuleInfo.moduleName) {
					for(var i:int = 0; i < _loadModuleInfo.limList.length; i++) {
						Common.loader.remove(_loadModuleInfo.limList[i]);
					}
				}
			}
			
			_loadModuleInfo = _moduleList[moduleName];
			_loadModuleInfo.args = args;
			loadModule(moduleName, _loadModuleInfo.limList, args);
		}
		
		
		/**
		 * 加载当前要显示模块的所需资源
		 * 可以重写该函数，并根据 args 来编写显示该模块需要加载资源的逻辑。
		 */
		protected function loadModule(moduleName:String, limList:Array, args:Array):void
		{
			for(var i:int = 0; i < limList.length; i++) Common.loader.add(limList[i]);
			Common.loader.start(loadModuleComplete);
		}
		
		
		/**
		 * 加载模块所需资源完成
		 */
		private function loadModuleComplete():void
		{
			//初始化模块
			if(_loadModuleInfo.instance == null) {
				_loadModuleInfo.instance = getDefinitionByName(_loadModuleInfo.moduleName).instance;
				(_loadModuleInfo.instance as IModule).initialize.apply(null, _loadModuleInfo.initArgs);
				(_loadModuleInfo.instance as IModule).moduleName = _loadModuleInfo.moduleName;
			}
			
			showNowModule(_loadModuleInfo.moduleName, _loadModuleInfo.args);
		}
		
		
		/**
		 * 模块加载完成，并初始化完毕后，显示模块。<br/>
		 * 可以重写该函数，并根据 args 来编写模块展示前的逻辑。
		 * @param moduleName 模块的名称
		 * @param args 显示模块时附带的参数
		 */
		protected function showNowModule(moduleName:String, args:Array):void
		{
			var module:IModule = _moduleList[moduleName].instance as IModule;
			if(module is IWindow) {
				openWindow(module as IWindow);
			}
			else {
				showScene(module as IScene);
			}
		}
		
		
		public function getModule(moduleName:String):IModule
		{
			return _moduleList[moduleName].instance;
		}
		
		
		
		
		public function openWindow(window:IWindow):void
		{
			//这个窗口已经打开了
			if(window.showed) {
				if(window.autoHide) closeWindow(window);
				else showDisplayObject(window as DisplayObject, _windowLayer);
				return;
			}
			
			//将新打开的窗口放到默认的位置上
			var p:Point = Common.layout.getStageLayout(window as DisplayObject);
			window.x = p.x;
			window.y = p.y;
			CachePool.recover(p);
			
			//关闭互斥的窗口，获取需要组合的窗口
			var i:int, w:IWindow, needClose:Boolean;
			var comboList:Array = [];
			for(i = 0; i < _windowList.length; i++)
			{
				needClose = true;
				w = _windowList[i];
				
				//这个窗口在组合列表中
				if(window.comboList.indexOf(w.moduleName) != -1) {
					comboList.push(w);
					needClose = false;
				}
				else {
					//这个窗口不在互斥列表中
					if(window.excludeList != null) {
						if(window.excludeList.indexOf(w.moduleName) == -1) needClose = false;
					}
				}
				
				if(needClose) closeWindow(w);
			}
			
			_windowList.push(window);
			
			//当前没有别的窗口被打开
			if(comboList.length == 0) {
				showDisplayObject(window as DisplayObject, _windowLayer);
				return;
			}
			
			//按照组合排序显示窗口
			comboList.push(window);
			comboList.sortOn("layoutIndex", Array.NUMERIC);
			var width:int, height:int;
			for(i = 0; i < comboList.length; i++)
			{
				w = comboList[i];
				Common.layout.setStageLayoutEnabled(w as DisplayObject, false);
				showDisplayObject(w as DisplayObject, _windowLayer);
				
				//计算出组合后的窗口所占的总宽高
				if((window as IWindowLayout).layoutDirection == "horizontal") {
					width += w.layoutWidth;
					if(i < comboList.length - 1) width += w.layoutGap;
					if(w.layoutHeight > height) height = w.layoutHeight;
				}
				else {
					height += w.layoutHeight;
					if(i < comboList.length - 1) height += w.layoutGap;
					if(w.layoutWidth > width) width = w.layoutWidth;
				}
			}
			
			//缓动到正确的位置上
			var x:int = stageWidth - width >> 1;
			var y:int = stageHeight - height >> 1;
			for(i = 0; i < comboList.length; i++)
			{
				w = comboList[i];
				TweenMax.killTweensOf(w);
				TweenMax.to(w, Constants.EFFECT_DURATION_WINDOW_MOVE, { x:x, y:y });
				
				if(i < comboList.length - 1) {
					if((window as IWindowLayout).layoutDirection == "horizontal")
						x += w.layoutWidth + w.layoutGap;
					else
						y += w.layoutHeight + w.layoutGap;
				}
			}
		}
		
		public function closeWindow(window:IWindow):void
		{
			window.hide();
			Common.layout.setStageLayoutEnabled(window as DisplayObject, true);
			
			var i:int = _windowList.indexOf(window);
			if(i == -1) return;//要关闭的窗口不在已打开的窗口列表中
			_windowList.splice(i, 1);
			
			if(window.comboList.length == 0) return;
			for(i = 0; i < _windowList.length; i++)
			{
				var w:IWindow = _windowList[i];
				//w 在 window 的组合列表中
				if(window.comboList.indexOf(w.moduleName) != -1) {
					var p:Point = Common.layout.getStageLayout(w as DisplayObject);
					TweenMax.killTweensOf(w);
					TweenMax.to(w, Constants.EFFECT_DURATION_WINDOW_MOVE, { x:p.x, y:p.y });
					CachePool.recover(p);
				}
			}
		}
		
		public function closeAllWindow():void
		{
			//拷贝是为了 window.hide() 调回 closeWindow() 时 _windowList.length=0
			var list:Vector.<IWindow> = _windowList.concat();
			_windowList = new Vector.<IWindow>();
			while(list.length > 0) list.pop().hide();
		}
		
		
		
		
		/**
		 * 显示一个显示对象，并添加到指定容器中。<br/>
		 * 如果显示对象为 IBaseSprite，将会调用 show() 方法进行显示
		 * @param target 目标显示对象
		 * @param parent 父级容器
		 */
		private function showDisplayObject(target:DisplayObject, parent:DisplayObjectContainer):void
		{
			if(target.parent == parent) {
				target.parent.setChildIndex(target, target.parent.numChildren - 1);
			}else {
				parent.addChild(target);
			}
			
			if(target is IBaseSprite) {
				(target as IBaseSprite).show();
			}else {
				target.visible = true;
			}
		}
		
		/**
		 * 隐藏一个显示对象，并从父级容器中移除。<br/>
		 * 如果显示对象为 IBaseSprite，将会调用 hide() 方法进行隐藏
		 * @param target
		 */
		private function hideDisplayObject(target:DisplayObject):void
		{
			if(target is IBaseSprite) {
				(target as IBaseSprite).hide();
			}else {
				target.visible = false;
				if(target.parent) target.parent.removeChild(target);
			}
		}
		
		
		
		
		public function addChildToLayer(child:DisplayObject, layerName:String):void
		{
			if(layerName == Constants.LAYER_NAME_WINDOW) {
				throw new Error("要将显示对象添加到 window 层，请使用 openWindow() 方法");
				return;
			}
			
			showDisplayObject(child, getLayer(layerName));
		}
		
		
		public function removeChildToLayer(child:DisplayObject, layerName:String):void
		{
			var layer:DisplayObjectContainer = getLayer(layerName);
			if(child.parent == layer) hideDisplayObject(child);
		}
		
		
		public function getLayer(layerName:String):DisplayObjectContainer
		{
			return this.getChildByName(layerName) as DisplayObjectContainer;
		}
		
		
		
		
		/**
		 * 显示已经加载好的场景
		 * @param scene
		 */
		protected function showScene(scene:IScene):void
		{
			//场景有变动，隐藏当前场景，并记录到上个场景的信息
			var changed:Boolean = _currentSceneInfo != null && _currentSceneInfo.moduleName != _loadModuleInfo.moduleName;
			if(changed) {
				_prevSceneInfo = _currentSceneInfo;
				(_moduleList[_prevSceneInfo.moduleName].instance as IScene).hide();
				closeAllWindow();
			}
			if(!changed) changed = _currentSceneInfo == null;//第一次进入场景
			
			//显示已经加载好的新场景，并记录到当前场景的信息
			_currentSceneInfo = { moduleName:_loadModuleInfo.moduleName, args:_loadModuleInfo.args };
			showDisplayObject(_moduleList[_currentSceneInfo.moduleName].instance, _sceneLayer);
			if(changed) dispatchEvent(new SceneEvent(SceneEvent.ENTER_SCENE));
		}
		
		public function showPrevScene():void
		{
			if(_prevSceneInfo == null) return;
			
			var args:Array = _prevSceneInfo.args.concat();
			args.unshift(_prevSceneInfo.moduleName);
			showModule.apply(null, args);
		}
		
		public function get prevSceneName():String
		{
			if(_prevSceneInfo == null) return null;
			return _prevSceneInfo.moduleName;
		}
		
		public function get currentSceneName():String
		{
			if(_currentSceneInfo == null) return null;
			return _currentSceneInfo.moduleName;
		}
		
		
		
		public function showModal(alpha:Number=0.01, color:uint=0x0, layerName:String="top", depth:int=0):void
		{
			_modal.graphics.clear();
			_modal.graphics.beginFill(color, alpha);
			_modal.graphics.drawRect(0, 0, 10, 10);
			_modal.graphics.endFill();
			_modal.width = _stageWidth;
			_modal.height = _stageHeight;
			
			var layer:DisplayObjectContainer = getLayer(layerName);
			if(depth < 0 || depth > layer.numChildren) depth = layer.numChildren;
			layer.addChildAt(_modal, depth);
		}
		
		
		public function hideModal():void
		{
			if(_modal.parent != null) _modal.parent.removeChild(_modal);
		}
		
		
		
		public function get loadBar():ILoadBar { return _loadBar; }
		
		
		public function get requestModal():IRequestModal { return _requestModal; }
		
		
		public function get windowList():Vector.<IWindow> { return _windowList; }
		
		
		public function get stageWidth():uint { return _stageWidth; }
		public function get stageHeight():uint { return _stageHeight; }
		
		public function get minStageWidth():uint { return 500; }
		public function get minStageHeight():uint { return 300; }
		public function get maxStageWidth():uint { return 2000; }
		public function get maxStageHeight():uint { return 900; }
		//
	}
}