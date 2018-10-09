package lolo.components
{
	import flash.events.MouseEvent;

	/**
	 * 多选框（图形皮肤 + 链接文本）
	 * 链接文本的属性，需要通过labelProp方法来控制
	 * @author LOLO
	 */
	public class CheckBox extends Button
	{
		public function CheckBox()
		{
			super();
			
			this.removeChild(_labelMask);
			_labelText.mask = null;
			_labelMask = null;
			
			_deselect = true;
			this.addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		
		
		override public function set style(value:Object):void
		{
			super.style = value;
			this.hitArea = null;
			
			_labelText.x = _labelPaddingLeft;
			_labelText.y = _labelPaddingTop;
		}
		
		
		
		/**
		 * 鼠标单击
		 * @param event
		 */
		private function mouseClickHandler(event:MouseEvent):void
		{
			if(_group == null)
			{
				if(_selected) {
					if(_deselect) this.selected = false;
				}
				else {
					this.selected = true;
				}
			}
		}
		
		
		
		override public function update():void
		{
			
		}
		
		override public function set width(value:Number):void
		{
			
		}
		
		override public function set height(value:Number):void
		{
			
		}
		//
	}
}