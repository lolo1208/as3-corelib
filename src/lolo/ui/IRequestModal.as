package lolo.ui
{
	import lolo.data.RequestModel;

	/**
	 * 将与服务端通信的请求进行模态的界面
	 * @author LOLO
	 */
	public interface IRequestModal
	{
		/**
		 * 对指定的命令，开始进行通信模态
		 * @param rm 通信接口模型
		 */
		function startModal(rm:RequestModel):void;
		
		/**
		 * 对指定的命令，结束通信模态
		 * @param rm 通信接口模型
		 */
		function endModal(rm:RequestModel):void;
		
		
		/**
		 * 重置所有模态的通信
		 */
		function reset():void;
	}
}