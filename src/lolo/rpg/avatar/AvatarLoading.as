package lolo.rpg.avatar
{
	import flash.display.Sprite;
	
	import lolo.components.Label;
	import lolo.core.Common;
	import lolo.display.BitmapSprite;
	import lolo.utils.AutoUtil;
	
	/**
	 * 角色加载外形时，默认显示的Loading
	 * @author LOLO
	 */
	public class AvatarLoading extends Sprite implements IAvatarLoading
	{
		public var sketch:BitmapSprite;
		public var progressText:Label;
		
		private var _progress:Number;
		
		
		
		public function AvatarLoading()
		{
			super();
			mouseChildren = mouseEnabled = false;
			initUI();
		}
		
		
		protected function initUI():void
		{
			AutoUtil.autoUI(this, new XML(Common.loader.getResByConfigName("mainUIConfig").avatarLoading));
		}
		
		
		
		
		public function set progress(value:Number):void
		{
			_progress = value;
			progressText.text = String(int(value * 100)) + "%";
		}
		
		public function get progress():Number
		{
			return _progress;
		}
		
		
		
		
		public function clear():void
		{
			if(parent) parent.removeChild(this);
		}
		//
	}
}