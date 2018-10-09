package lolo.net
{
	import lolo.data.RequestModel;

	/**
	 * 与后台进行通信的接口
	 * @author LOLO
	 */
	public interface IService
	{
		/**
		 * 发送数据
		 * @param rm 通信接口模型
		 * @param data 数据
		 * @param callback 通信结果的回调函数
		 * @param alertError 通信错误时，是否需要自动AlertText提示
		 */
		function send(rm:RequestModel, data:Object=null, callback:Function=null, alertError:Boolean=true):void;
		
		/**
		 * 将指定的一条通信设置为超时（模态的请求才会被设置为超时）
		 * @param rm
		 */
		function setTimeout(rm:RequestModel):void;
	}
}