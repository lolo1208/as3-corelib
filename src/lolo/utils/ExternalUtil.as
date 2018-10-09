package lolo.utils
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import lolo.components.IScrollBar;
	
	/**
	 * 与外部容器通信的工具
	 * @author LOLO
	 */
	public class ExternalUtil
	{
		/**在新窗口打开*/
		public static const WINDOW_BLANK:String = "_blank";
		/**在当前窗口打开*/
		public static const WINDOW_SELF:String = "_self";
		/**在父窗口打开*/
		public static const WINDOW_PARENT:String = "_parent";
		
		/**用于抛出 mouseWheel 等事件*/
		public static var eventDispatcher:EventDispatcher;
		
		/**注册的滚动条列表（等待 mouseWheelChaged() 被调用）*/
		private static var _scrollBarList:Vector.<IScrollBar>;
		/**鼠标正悬停在该滚动条，或滚动条对应的内容上*/
		private static var _curScrollBarList:IScrollBar;
		
		
		
		
		/**
		 * 调用外部容器函数（页面JS），并返回接收的响应<br/>
		 * 如果不允许调用，或调用出错，将会返回null
		 * @param functionName
		 * @param args
		 * @return 
		 */
		public static function call(functionName:String, ...args):*
		{
			if(!ExternalInterface.available) return null;
			
			try {
				args.splice(0, 0, functionName);
				return ExternalInterface.call.apply(null, args);
			}
			catch(error:Error) {
				return null;
			}
		}
		
		
		
		/**
		 * 初始化相关的js代码
		 * @param swfID Main.swf在html页面中的ID
		 */
		public static function initialize(swfID:String="flashContent"):void
		{
			if(eventDispatcher != null) return;
			eventDispatcher = new EventDispatcher();
			
			//初始化
			call("function(){"
				+ "lolo = {};\n"
				+ "lolo.isChrome = window.google && window.chrome;\n"
				+ "lolo.isSafari = window.openDatabase;\n"
				+ 'lolo.swf = (navigator.appName.indexOf("Microsoft") != -1) ? window["' + swfID + '"] : document["' + swfID + '"];'
				+ "}");
			
			//JS相关函数
			var jsCode:XML = <script><![CDATA[ function(){
			
			/**
			 * 鼠标滚轮事件
			 */
			lolo.mouseWheelHandler = function(event) 
			{
				if(!event) event = window.event;
				if(event.preventDefault) {
					event.preventDefault();
				}
				if(lolo.isChrome || lolo.isSafari) {
					var detail = event.wheelDelta ? event.wheelDelta : event.detail;
					detail = lolo.isChrome ? (detail / 120) : (detail > 0 ? 1 : -1);
					lolo.swf.mouseWheelHander(detail);
				}
			}
			
			lolo.addMouseWheelListener = function()
			{
				if(typeof window.addEventListener != 'undefined') {
					window.addEventListener('DOMMouseScroll', lolo.mouseWheelHandler, false);
				}
				window.onmousewheel = document.onmousewheel = lolo.mouseWheelHandler;
			}
			
			lolo.removeMouseWheelListener = function()
			{
				if(typeof window.removeEventListener != 'undefined') {
					window.removeEventListener('DOMMouseScroll', lolo.mouseWheelHandler, false);
				}
				window.onmousewheel = document.onmousewheel = null;
			}
			
			
			/**
			 * 获取HTTP响应头中的CDN节点信息
			 */
			lolo.getCdnNodeInfo = function(url)
			{
				var p = /http:\/\/([^:\/]+)(?::(\d+))?(\/.*$)/i;
				var match = p.exec(url);
				var host = match[1];
				
				var url = "http://" + host + "/testcdnnode.jpg" + "?" + Math.random();
				var req = window.XMLHttpRequest ? new XMLHttpRequest() : new ActivexObject("microsoft.xmlhttp");
				req.open("GET", url, false);
				req.send(null);
				
				//var h = (host.indexOf("cdn01.aoshitang") != -1) ? "Via" : "X-Via";
				var h = "Sophnep-Edge-FX";
				return req.getResponseHeader(h);
			}
			
			} ]]></script>;
			
			call(jsCode);
			
			//注册JS回调函数
			try {
				ExternalInterface.addCallback("mouseWheelHander", mouseWheelHander);
			}
			catch(error:Error) {}
		}
		
		
		/**
		 * 鼠标滚动有变化（由外部JS调用、Chrome/Safari 浏览器）
		 * @param delta 表示用户将鼠标滚轮每滚动一个单位应滚动多少行。正 delta 值表示向上滚动；负值表示向下滚动。各浏览器有所不同
		 */
		private static function mouseWheelHander(detail:int):void
		{
			var event:MouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL);
			event.delta = detail;
			eventDispatcher.dispatchEvent(event);
		}
		
		
		/**
		 * 设置页面是否启用鼠标滑轮事件<br/>
		 * 页面禁用JS时，会通过 ExternalUtil.eventDispatcher 抛出 mouseWheel 事件
		 * @param value
		 */
		public static function set mouseWheelEnabled(value:Boolean):void
		{
			call(value ? "lolo.removeMouseWheelListener" : "lolo.addMouseWheelListener");
		}
		
		
		/**
		 * 获取HTTP响应头中的CDN节点信息
		 * @param value
		 */
		public static function getCdnNodeInfo(url:String):String
		{
			var info:String = call("lolo.getCdnNodeInfo", url);
			if(info == null) info = "Get CDN Node Fail";
			return info;
		}
		
		
		/**
		 * 打开一个浏览器窗口
		 * @param url 网络地址
		 * @param window 目标浏览器窗口
		 */
		public static function openWindow(url:String, window:String="_blank"):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			
			if(!ExternalInterface.available) {
				return navigateToURL(urlRequest, window)
			}
			
			if(/safari|opera/i.test(call("function(){return navigator.userAgent}") || "opera")) {
				navigateToURL(urlRequest, window);
			}
			else {
				call("function(){window.open('" + getURLString(urlRequest) + "','" + window + "');}");
			}
		}
		
		
		/**
		 * 获取url字符串
		 * @param urlRequest
		 * @return 
		 */
		private static function getURLString(urlRequest:URLRequest):String
		{
			var patams:String = urlRequest.data ? URLVariables(urlRequest.data).toString() : "";
			if((urlRequest.method == URLRequestMethod.POST) || !patams) return urlRequest.url;
			return urlRequest.url + "?" + patams;
		}
		//
	}
}