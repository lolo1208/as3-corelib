package lolo.display
{
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	
	/**
	 * 可以切换状态的皮肤
	 * @author LOLO
	 */
	public class Skin extends BitmapSprite
	{
		/**状态 - 正常*/
		public static const UP:String = "up";
		/**状态 - 鼠标移上来*/
		public static const OVER:String = "over";
		/**状态 - 鼠标按下*/
		public static const DOWN:String = "down";
		/**状态 - 禁用*/
		public static const DISABLED:String = "disabled";
		/**状态 - 选中：正常*/
		public static const SELECTED_UP:String = "selectedUp";
		/**状态 - 选中：鼠标移上来*/
		public static const SELECTED_OVER:String = "selectedOver";
		/**状态 - 选中：鼠标按下*/
		public static const SELECTED_DOWN:String = "selectedDown";
		/**状态 - 选中：禁用*/
		public static const SELECTED_DISABLED:String = "selectedDisabled";
		
		
		/**皮肤的名称*/
		private var _skinName:String;
		/**当前皮肤包含的状态列表*/
		private var _stateList:Dictionary;
		/**当前状态*/
		private var _state:String;
		/**图片源名称的前缀*/
		private var _prefix:String;
		
		
		
		public function Skin(skinName:String=null)
		{
			super();
			this.skinName = skinName;
		}
		
		
		
		/**
		 * 皮肤的名称
		 */
		public function set skinName(value:String):void
		{
			if(value == _skinName) return;
			_skinName = value;
			
			_stateList = new Dictionary();
			while(numChildren > 0) removeChildAt(0);//清空皮肤， _skinName=null 或 _skinName="" 的时候，啥也不显示
			
			if(_skinName == null || _skinName == "") return;
			
			var list:Array = Common.config.getSkin(value);
			if(list == null) {
				throw new Error("皮肤 " + value + "不存在！！");
				return;
			}
			
			for(var i:int=0; i < list.length; i++) {
				var info:Object = list[i];
				addState(info.state, info.sourceName);
			}
		}
		public function get skinName():String { return _skinName; }
		
		
		
		/**
		 * 图片源名称的前缀（根据该前缀解析相对应的皮肤状态）
		 */
		public function set prefix(value:String):void
		{
			if(value == _prefix) return;
			_prefix = value;
			
			_stateList = new Dictionary();
			while(numChildren > 0) removeChildAt(0);
			
			
			var states:Array = [UP, OVER, DOWN, DISABLED, SELECTED_UP, SELECTED_OVER, SELECTED_DOWN, SELECTED_DISABLED];
			for(var i:int = 0; i < states.length; i++)
			{
				var sn:String = _prefix + "." + states[i];
				if(BitmapSprite.getConfigInfo(sn) != null) addState(states[i], sn);
			}
		}
		
		public function get prefix():String { return _prefix; }
		
		
		
		/**
		 * 添加一个状态
		 * @param state 状态的名称
		 * @param sourceName 状态对应的图像源名称
		 */
		public function addState(state:String, sourceName:String):void
		{
			_stateList[state] = sourceName;
		}
		
		
		/**
		 * 移除一个状态
		 * @param state
		 */
		public function removeState(state:String):void
		{
			delete _stateList[state];
		}
		
		
		/**
		 * 指定的状态是否存在
		 * @param state
		 * @return 
		 */
		public function hasState(state:String):Boolean
		{
			return _stateList[state] != null;
		}
		
		
		
		/**
		 * 当前状态
		 */
		public function set state(value:String):void
		{
			if(_stateList == null) return;
			_state = value;
			
			var state:String = value;
			if(!hasState(value))
			{
				if(value == SELECTED_OVER || value == SELECTED_DOWN || value == SELECTED_DISABLED)
					state = hasState(SELECTED_UP) ? SELECTED_UP : UP;
				else
					state = UP;
			}
			
			this.sourceName = _stateList[state];
		}
		public function get state():String { return _state; }
		//
	}
}