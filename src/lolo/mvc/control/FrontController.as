package lolo.mvc.control
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import lolo.mvc.command.ICommand;

	/**
	 * mvc控制器基类，用于注册命令与事件
	 * @author LOLO
	 */
	public class FrontController
	{
		/**已注册的命令列表*/
		protected var _commands:Dictionary = new Dictionary();
		/**事件侦听、调度者*/
		protected var _eventDispatcher:EventDispatcher;
		
		
		
		/**
		 * 注册、添加命令
		 * @param commandName 命令的名称
		 * @param commandRef 命令的处理类
		 */
		public function addCommand(commandName:String, commandRef:Class):void
		{
			if(_eventDispatcher) {
				_commands[commandName] = commandRef;
				_eventDispatcher.addEventListener(commandName, executeCommand);
			}
		}
		
		
		/**
		 * 移除命令
		 * @param commandName 命令的名称
		 */		
		public function removeCommand(commandName:String):void
		{
			_eventDispatcher.removeEventListener(commandName, executeCommand);
			delete _commands[commandName];
		}
		
		
		/**
		 * 获取命令
		 * @param commandName 命令的名称
		 * @return 
		 */		
		protected function getCommand(commandName:String):Class
		{
			return _commands[commandName];
		}
		
		
		/**
		 * 执行命令
		 * @param event
		 */
		protected function executeCommand(event:MvcEvent):void
		{
			var tempClass:Class = _commands[event.type];
			var command:ICommand = new tempClass();
			command.execute(event);
		}
		//
	}
}