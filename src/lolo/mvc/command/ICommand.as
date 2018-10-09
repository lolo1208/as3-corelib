package lolo.mvc.command
{
	import lolo.mvc.control.MvcEvent;
	/**
	 * mvc命令接口
	 * @author LOLO
	 */
	public interface ICommand
	{
		/**
		 * 执行命令
		 * @param event
		 */
		function execute(event:MvcEvent):void;
		//
	}
}