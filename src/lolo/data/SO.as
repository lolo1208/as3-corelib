package lolo.data
{
	import flash.net.SharedObject;

	/**
	 * 共享数据（SharedObject）
	 * @author LOLO
	 */
	public class SO
	{
		/**SharedObject的储存名称（路径）*/
		public static var localName:String = "game/so";
		/**储存在硬盘上的共享数据*/
		private static var _so:SharedObject;
		/**伪SharedObject，当无法在硬盘上储存数据时，记录在内存中的共享数据（防止后续操作报错）*/
		private static var _imitationSO:Object;
		
		
		
		
		public function SO()
		{
			throw new Error("不允许创建这个类的实例");
		}
		
		
		
		/**
		 * 初始化SharedObject
		 */
		private static function initialize():void
		{
			if(_so || _imitationSO) return;
			try {
				_so = SharedObject.getLocal(localName, "/");
			}
			catch(error:Error) {
				_imitationSO = {};
			}
		}
		
		
		
		/**
		 * 获取SharedObject数据
		 * 当无法在硬盘上储存数据时，将返回记录在内存中的共享数据
		 * <br/><font color="#FF0000">提示：</font>数据修改或赋值完成后，一定要调用SO.save()，保存数据
		 * @return 
		 */
		public static function get data():Object
		{
			initialize();
			return _so ? _so.data : _imitationSO;
		}
		
		
		
		/**
		 * 据保SharedObject数据
		 * @return 保存是否成功。当无法在硬盘上储存数据时，将会返回失败
		 */
		public static function save():Boolean
		{
			if(_so) {
				try {
					_so.flush();
					return true;
				}
				catch(error:Error) { }
			}
			return false;
		}
		//
	}
}