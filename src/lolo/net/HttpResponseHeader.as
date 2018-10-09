package lolo.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	
	import lolo.ui.Console;
	
	
	/**
	 * 获取和解析http响应头
	 * @author LOLO
	 */
	public class HttpResponseHeader extends EventDispatcher
	{
		/**http请求的完整url*/
		private var _url:String;
		/**http请求的服务器地址*/
		private var _host:String;
		/**http请求的路径*/
		private var _uri:String;
		/**http请求的端口*/
		private var _prot:uint;
		/**用于向目标服务器发送http请求*/
		private var _socket:Socket;
		/**http相应头列表[name]=value*/
		private var _responseHeaders:Dictionary = new Dictionary();
		
		/**随便记点什么*/
		public var data:*;
		
		
		
		public function HttpResponseHeader()
		{
			super();
			
			_socket = new Socket();
			_socket.addEventListener(Event.CONNECT, socket_eventHandler);
			_socket.addEventListener(Event.CLOSE, socket_eventHandler);
			_socket.addEventListener(ProgressEvent.SOCKET_DATA, socket_eventHandler);
			_socket.addEventListener(IOErrorEvent.IO_ERROR, socket_eventHandler);
			_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, socket_eventHandler);
		}
		
		
		
		/**
		 * 发送http请求，并从指定url获取http响应头
		 * @param url
		 */
		public function load(url:String):void
		{
			_url = url;
			_responseHeaders = new Dictionary();
			
			if(_url == null) {
				_host = null;
				_uri = null;
				_prot = 0;
				return;
			}
			
			//解析参数
			var p:RegExp = /http:\/\/([^:\/]+)(?::(\d+))?(\/.*$)/i;
			var match:Array = p.exec(_url);
			_host = match[1];
			_prot = match[2] || 80;
			_uri = match[3] || "/";
			
			//var pfURL:String = "http://" + _host + ":" + _prot + "/crossdomain.xml";
			//Security.loadPolicyFile(pfURL);
			
			//尝试链接该服务器
			_socket.connect(_host, _prot);
		}
		
		
		
		/**
		 * 用于发送http请求的socket产生的事件
		 * @param event
		 */
		private function socket_eventHandler(event:Event):void
		{
			Console.trace(event.type);
			switch(event.type)
			{
				case Event.CONNECT:
					//写入http请求头，并发送
					_socket.writeUTFBytes(
						"GET " + _uri + " HTTP/1.0" +
						"\r\nHost: " + _host +
						"\r\nAccept: */*" +
						"\r\nAccept-Encoding: gzip, deflate" +
						"\r\nAccept-Language: zh-cn, en-us" +
						"\r\nConnection: Close" +
						"\r\nUser-Agent: Get Response Headers (LOLO Framework)" +
						"\r\n\r\n"
					);
					_socket.flush();
					break;
				
				case ProgressEvent.SOCKET_DATA:
					break;
				
				case Event.CLOSE:
					//解析响应头
					if(_socket.bytesAvailable > 0)
					{
						var str:String = _socket.readUTFBytes(_socket.bytesAvailable);
						str = str.split("\r\n\r\n")[0];//丢弃内容
						var arr:Array = str.split("\r\n");
						for each(var item:String in arr)
						{
							var arr2:Array = item.split(": ");
							if(arr2.length == 2) {
								var name:String = arr2[0];
								if(_responseHeaders[name] == null) {
									_responseHeaders[name] = "";
								}
								else {
									_responseHeaders[name] += ", ";//连接并分隔多个值
								}
								_responseHeaders[name] += arr2[1];
							}
						}
						
						this.dispatchEvent(new Event(Event.COMPLETE));
					}
					else {
						this.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "未知错误！"));
					}
					break;
				
				default:
					this.dispatchEvent(event);//IOErrorEvent 和 SecurityErrorEvent
			}
		}
		
		
		
		/**
		 * 获取指定名称的http响应头。<br/>
		 * 如果不存在该名称的响应头，将会返回 null
		 * @param name
		 * @return 
		 */
		public function getHeader(name:String):String
		{
			return _responseHeaders[name];
		}
		
		
		
		/**
		 * 获取所有的响应头名称
		 * @return 
		 */
		public function get names():Array
		{
			var arr:Array;
			for(var name:String in _responseHeaders) arr.push(name);
			return arr;
		}
		
		
		
		/**
		 * http请求的完整url
		 */
		public function get url():String { return _url; }
		
		
		/**
		 * http请求的服务器地址
		 */
		public function get host():String { return _host; }
		
		
		/**
		 * http请求的路径
		 */
		public function get uri():String { return _uri; }
		
		
		/**
		 * http请求的端口
		 */
		public function get prot():uint { return _prot; }
		//
	}
}