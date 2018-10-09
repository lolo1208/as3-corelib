package lolo.utils.bind
{
	import flash.events.IEventDispatcher;

	/**
	 * 绑定数据工具
	 * @author LOLO
	 */
	public class BindUtil
	{
		
		
		/**
		 * 将公用属性(tHost.tProp) 与 数据源(sHost.sPorp) 进行绑定
		 * 当 数据源(sHost.sPorp) 的值有改变时，公用属性(tHost.tProp) 也会随之改变
		 * @param tHost 要绑定数据的宿主
		 * @param tProp 要绑定数据的宿主的属性
		 * @param sHost 数据源宿主
		 * @param sProp 数据源宿主的属性
		 * @param exec 是否需要将公用属性(tHost.tProp)初始化成数据源(sHost.sPorp)的值
		 * @return 
		 */
		public static function bindProperty(tHost:Object,
											tProp:String,
											sHost:IEventDispatcher,
											sProp:String,
											exec:Boolean=false):ChangeWatcher
		{
			var value:* = sHost[sProp];
			if(exec) tHost[tProp] = value;
			
			var cw:ChangeWatcher = new ChangeWatcher(sHost, sProp, null, tHost, tProp);
			return cw;
		}
		
		
		
		/**
		 * 将函数与 数据源(sHost.sPorp) 进行绑定
		 * 当 数据源(sHost.sPorp) 的值有改变时，将会调用handler函数
		 * @param handler 数据改变时，调用的方法
		 * @param sHost 数据源宿主
		 * @param sProp 数据源宿主的属性
		 * @param exec 初始化时，是否需要执行一次handler函数
		 * @return 
		 */
		public static function bindSetter(handler:Function,
										  sHost:IEventDispatcher,
										  sProp:String,
										  exec:Boolean=false):ChangeWatcher
		{
			var value:* = sHost[sProp];
			if(exec) handler(value);
			
			var cw:ChangeWatcher = new ChangeWatcher(sHost, sProp, handler);
			return cw;
		}
		//
	}
}