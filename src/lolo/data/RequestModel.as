package lolo.data
{
	/**
	 * 与后台通信的数据模型
	 * @author LOLO
	 */
	public class RequestModel
	{
		/**这条请求的命令*/
		public var command:String;
		
		/**这条请求的代号*/
		public var token:Number = 0;
		
		/**通信时，是否需要模态*/
		public var modal:Boolean;
		
		/**是否正在请求中*/
		public var isRequest:Boolean = false;
		
		
		/**
		 * 构造函数
		 * @param command
		 * @param modal
		 * @param token
		 */
		public function RequestModel(command:String="", modal:Boolean=true)
		{
			this.command = command;
			this.modal = modal;
		}
		//
	}
}