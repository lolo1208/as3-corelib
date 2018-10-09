package lolo.rpg.map
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	
	/**
	 * 图块加载器
	 * @author LOLO
	 */
	public class ChunkLoader extends URLLoader
	{
		/**加载完成*/
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		/**图块位置*/
		private var _x:uint;
		private var _y:uint;
		
		private var _loader:Loader;
		
		private var _bitmapData:BitmapData;
		
		
		
		public function ChunkLoader(x:uint, y:uint)
		{
			super();
			_x = x;
			_y = y;
			this.dataFormat = URLLoaderDataFormat.BINARY;
			
			this.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		
		private function completeHandler(event:Event):void
		{
			var bytes:ByteArray = this.data;
			try { bytes.uncompress(); } catch(error:Error) {}
			bytes.readUnsignedByte();
			var data:ByteArray = new ByteArray();
			bytes.readBytes(data);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			_loader.loadBytes(data);
		}
		
		
		private function loader_completeHandler(event:Event):void
		{
			_bitmapData = (_loader.content as Bitmap).bitmapData;
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		
		
		public function get x():uint
		{
			return _x;
		}
		
		public function get y():uint
		{
			return _y;
		}
		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		
		public function clear():void
		{
			if(_loader) {
				try { _loader.close(); }
				catch(error:Error) {}
				try { _loader.unload(); }
				catch(error:Error) {}
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loader_completeHandler);
			}
		}
		//
	}
}