package lolo.ui
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lolo.effects.Fog;
	
	/**
	 * 迷雾编辑控制台
	 * @author LOLO
	 */
	public class FogConsole extends Sprite
	{
		/**目标迷雾*/
		private var _fog:Fog;
		/**网格*/
		private var _grid:Shape;
		/**坐标*/
		private var _coordinate:Sprite;
		
		
		public function FogConsole(fog:Fog)
		{
			super();
			_fog = fog;
			
			
			var h:int = Math.ceil(_fog.fogWidth / _fog.tileWidht);
			var v:int = Math.ceil(_fog.fogHeight / _fog.tileHeight);
			var i:int;
			
			
			//绘制网格
			_grid = new Shape();
			this.addChild(_grid);
			
			_grid.graphics.lineStyle(0, 0x00FF00, 0.3);
			for(i = 1; i < h; i++) {
				_grid.graphics.moveTo(i * _fog.tileWidht, 0);
				_grid.graphics.lineTo(i * _fog.tileWidht, _fog.fogHeight);
			}
			for(i = 1; i < v; i++) {
				_grid.graphics.moveTo(0, i * _fog.tileHeight);
				_grid.graphics.lineTo(_fog.fogWidth, i * _fog.tileHeight);
			}
			
			
			//显示坐标
			_coordinate = new Sprite();
			this.addChild(_coordinate);
			for(i = 0; i < h; i++) {
				for(var n:int = 0; n < v; n++) {
					var text:TextField = new TextField();
					text.selectable = text.mouseWheelEnabled = false;
					text.defaultTextFormat = new TextFormat("宋体", 12, 0x666666);
					text.width = _fog.tileWidht;
					text.height = _fog.tileHeight;
					text.x = i * _fog.tileWidht;
					text.y = n * _fog.tileHeight;
					text.text = i + " " + n;
					_coordinate.addChild(text);
				}
			}
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			var text:TextField = event.target as TextField;
			var arr:Array = text.text.split(" ");
			_fog.setTile(arr[0], arr[1], !_fog.hasTile(arr[0], arr[1]));
			
			text.textColor = _fog.hasTile(arr[0], arr[1]) ? 0xFFFFFF : 0x666666;
		}
		//
	}
}