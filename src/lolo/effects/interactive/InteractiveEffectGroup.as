package lolo.effects.interactive
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import lolo.effects.AsEffect;

	/**
	 * 与鼠标时间交互的特效组
	 * @author LOLO
	 */
	public class InteractiveEffectGroup
	{
		/**实例引用列表*/
		private var _list:Dictionary;
		/**当前选中的目标*/
		private var _selectedTarget:InteractiveObject;
		
		
		public function InteractiveEffectGroup()
		{
			_list = new Dictionary();
		}
		
		
		/**
		 * 添加指定交互对象到组中
		 * @param target 交互目标
		 * @param overGray 鼠标移到target上，是否黑白
		 * @param overLight 鼠标移到target上，是否变亮
		 * @param overGlow 鼠标移到target上，是否周围发光
		 * @param upGray 鼠标从target上移开，是否黑白
		 * @param upLight 鼠标从target上移开，是否变亮
		 * @param upGlow 鼠标从target上移开，是否周围发光
		 * @param selectedGray 选中，是否黑白
		 * @param selectedLight 选中，是否变亮
		 * @param selectedGlow 选中，是否周围发光
		 */
		public function add(target:InteractiveObject,
							overGray:Boolean	= false,
							overLight:Boolean	= true,
							overGlow:Boolean	= false,
							upGray:Boolean	= false,
							upLight:Boolean	= false,
							upGlow:Boolean	= false,
							selectedGray:Boolean	= false,
							selectedLight:Boolean	= false,
							selectedGlow:Boolean	= true
		):void
		{
			_list[target] = {
				overGray:overGray, overLight:overLight, overGlow:overGlow,
				upGray:upGray, upLight:upLight, upGlow:upGlow,
				selectedGray:selectedGray, selectedLight:selectedLight, selectedGlow:selectedGlow
			};
			
			target.addEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
			target.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
		}
		
		
		
		
		/**
		 * 从组中移除指定交互对象
		 * @param target 交互目标
		 */
		public function remove(target:InteractiveObject):void
		{
			target.removeEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
			target.removeEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
			
			target.filters = [];
			target.transform.colorTransform = AsEffect.LIGHT_CTF_0;
			delete _list[target];
		}
		
		
		
		/**
		 * 清除组中所有的交互对象
		 */
		public function clear():void
		{
			_selectedTarget = null;
			for(var target:* in _list) remove(target);
			_list = new Dictionary();
		}
		
		
		
		/**
		 * 当前选中的目标（target必须为组中的交互对象）
		 */
		public function set selectedTarget(target:InteractiveObject):void
		{
			if(_selectedTarget != null) {
				_selectedTarget.addEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
				_selectedTarget.addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
				_selectedTarget.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
			}
			
			_selectedTarget = target;
			if(_selectedTarget != null) {
				_selectedTarget.removeEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
				_selectedTarget.removeEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
				
				var data:Object = _list[_selectedTarget];
				
				//黑白，周围发光
				var filters:Array = [];
				if(data.selectedGray) filters.push(AsEffect.GRAY_FILTER);
				if(data.selectedGlow) filters.push(AsEffect.getGlowFilter());
				_selectedTarget.filters = filters;
				
				//变亮
				_selectedTarget.transform.colorTransform = data.selectedLight ? AsEffect.LIGHT_CTF_4 : AsEffect.LIGHT_CTF_0;
			}
		}
		
		public function get selectedTarget():InteractiveObject { return _selectedTarget; }
		
		
		
		/**
		 * 鼠标移到target上
		 * @param event
		 */
		private function mouseOverHandler(event:MouseEvent):void
		{
			var target:InteractiveObject = event.currentTarget as InteractiveObject;
			var data:Object = _list[target];
			
			//黑白，周围发光
			var filters:Array = [];
			if(data.overGray) filters.push(AsEffect.GRAY_FILTER);
			if(data.overGlow) filters.push(AsEffect.getGlowFilter());
			target.filters = filters;
			
			//变亮
			target.transform.colorTransform = data.overLight ? AsEffect.LIGHT_CTF_4 : AsEffect.LIGHT_CTF_0;
		}
		
		
		/**
		 * 鼠标从target上移开
		 * @param event
		 */
		private function mouseOutHandler(event:MouseEvent):void
		{
			var target:InteractiveObject = event.currentTarget as InteractiveObject;
			var data:Object = _list[target];
			
			//黑白，周围发光
			var filters:Array = [];
			if(data.upGray) filters.push(AsEffect.GRAY_FILTER);
			if(data.upGlow) filters.push(AsEffect.getGlowFilter());
			target.filters = filters;
			
			//变亮
			target.transform.colorTransform = data.upLight ? AsEffect.LIGHT_CTF_4 : AsEffect.LIGHT_CTF_0;
		}
		//
	}
}