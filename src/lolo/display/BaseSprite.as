package lolo.display
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * <b>基本显示对象</b><br/>
	 * 调用 show() 触发 startup()<br/>
	 * 调用 hide() 触发 reset()<br/>
     * 该对象默认会自动添加到显示对象、从显示对象中移除
	 * @author LOLO
	 */
	public class BaseSprite extends Sprite implements IBaseSprite
	{
		/**是否已经显示*/
		protected var _showed:Boolean = false;
		/**是否自动添加到显示对象、从显示对象中移除*/
		protected var _autoRemove:Boolean = true;
		
		/**对父级容器的引用*/
		protected var _parent:DisplayObjectContainer;
		
		
		
		public function BaseSprite()
		{
			super();
			this.visible = false;
			this.addEventListener(Event.ADDED, addedHandler);
		}
		
		
		/**
		 * 添加到显示列表中时
		 * @param event
		 */
		protected function addedHandler(event:Event):void
		{
			if(this.parent != null) {
				_parent = this.parent;
				try {
					//Loader类不实现此方法
					if(!_showed && _autoRemove) _parent.removeChild(this);
				}
				catch(error:Error){};
			}
		}
		
		
		
		
		public function show():void
		{
			if(!_showed) {
				_showed = true;
				this.visible = true;
				if(_autoRemove && this.parent == null && _parent != null) _parent.addChild(this);
				startup();
			}
		}
		
		/**
		 * 启动
		 */
		protected function startup():void
		{
			
		}
		
		
		
		public function hide():void
		{
			if(_showed) {
				_showed = false;
				this.visible = false;
				if(_autoRemove && this.parent != null) this.parent.removeChild(this);
				reset();
			}
		}
		
		/**
		 * 重置
		 */
		protected function reset():void
		{
			
		}
		
		
		
		public function showOrHide():void
		{
			_showed ? hide() : show();
		}
		
		
		
		
		public function get showed():Boolean { return _showed; }
		
		
		public function get autoRemove():Boolean { return _autoRemove; }
		public function set autoRemove(value:Boolean):void { _autoRemove = value; }
		//
	}
}