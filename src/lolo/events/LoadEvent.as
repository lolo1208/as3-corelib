package lolo.events
{
	import flash.events.Event;
	
	import lolo.data.LoadItemModel;

	/**
	 * 加载事件
	 * @author LOLO
	 */
	public class LoadEvent extends Event
	{
		/**开始加载*/
		public static const START:String = "loadStart";
		/**加载资源中*/
		public static const PROGRESS:String = "loadProgress";
		/**加载单个资源完成*/
		public static const ITEM_COMPLETE:String = "loadItemComplete";
		/**显示加载项全部加载完成*/
		public static const COMPLETE:String = "loadComplete";
		/**所有加载项全部加载完毕（包括显示加载项和暗中加载项）*/
		public static const ALL_COMPLETE:String = "loadAllComplete";
		/**加载某个资源失败*/
		public static const ERROR:String = "loadError";
		/**加载某个资源超时*/
		public static const TIMEOUT:String = "loadTimeout";
		
		/**触发该事件的加载项*/
		public var lim:LoadItemModel;
		
		
		/**
		 * 构造一个加载资源事件
		 * @param type
		 * @param lim
		 * @param bubbles
		 * @param cancelable
		 */		
		public function LoadEvent(type:String, lim:LoadItemModel=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.lim = lim;
		}
		
		
		override public function clone():Event
		{
			return new LoadEvent(type, lim, bubbles, cancelable);
		}
		//
	}
}