package lolo.components
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import lolo.core.Common;
	import lolo.data.IHashMap;
	import lolo.display.BitmapSprite;
	import lolo.display.Container;
	import lolo.events.components.ListEvent;
	import lolo.events.components.ToolTipEvent;
	
	/**
	 * ComboBox组件，包含如下元素：<br/>
	 * 	- 下拉按钮<br/>
	 * 	- 输入文本（可编辑状态下显示）<br/>
	 * 	- 显示文本（不可编辑状态下显示）<br/>
	 * 	- 下拉列表的背景（9切片）<br/>
	 * 	- 下拉列表（单列）<br/>
	 * 	- 下拉列表组件对应的垂直滚动条（会自动调整尺寸）
	 * @author LOLO
	 */
	public class ComboBox extends Container
	{
		/**下拉按钮*/
		public var arrowBtn:BaseButton;
		/**输入文本（可编辑状态下显示）*/
		public var inputText:InputText;
		/**显示文本（不可编辑状态下显示）*/
		public var labelText:Label;
		/**下拉列表的背景（9切片）*/
		public var listBG:BitmapSprite;
		/**下拉列表（单列）*/
		public var list:ScrollList;
		/**下拉列表组件对应的垂直滚动条（会自动调整尺寸）*/
		public var listVSB:ScrollBar;
		
		
		/**下拉列表item被选中时，在ItemRenderer中获取标签字符串的字段*/
		public var labelField:String = "label";
		/**列表的背景大于列表的高度*/
		public var listBGPaddingHeight:int;
		
		
		/**是否可以编辑*/
		protected var _editable:Boolean;
		/**上次选中item的key*/
		protected var _lastKey:String;
		/**在点击下拉按钮时，是否需要打开下拉列表*/
		protected var _needOpen:Boolean = true;
		
		
		public function ComboBox()
		{
			super();
			_initShow = true;
		}
		
		
		override public function initUI(config:XML):void
		{
			super.initUI(config);
			
			labelText.autoTooltip = labelText.mouseEnabled = labelText.mouseWheelEnabled = false;
			list.autoSelectDefaultItem = false;
			
			editable = true;//默认可以编辑
			close();//默认关闭下拉列表
			
			inputText.addEventListener(Event.CHANGE, inputText_changeHandler);
			inputText.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			labelText.addEventListener(ToolTipEvent.SHOW, labelText_showToolTipHandler);
			arrowBtn.addEventListener(MouseEvent.CLICK, arrowBtn_clickHandler);
			list.addEventListener(ListEvent.ITEM_MOUSE_DOWN, list_itemMouseDownHandler);
			list.addEventListener(ListEvent.RENDER, list_renderHandler);
		}
		
		
		/**
		 * 列表渲染更新
		 * @param event
		 */
		protected function list_renderHandler(event:ListEvent):void
		{
			var height:int = list.height;
			if(listVSB.showed) {
				height = listVSB.viewableArea.height;
				if(height != listVSB.size) listVSB.size = height;
			}
			
			if(!list.visible) listVSB.visible = false;
			height += listBGPaddingHeight;
			if(height == 0) height = 1;//防止背景在设置数据（listBG.data）时，重置宽（高）
			listBG.height = height;
		}
		
		
		
		/**
		 * 文本的tooltip有改变时
		 * @param event
		 */
		protected function labelText_showToolTipHandler(event:ToolTipEvent):void
		{
			ToolTip.register(arrowBtn, event.toolTip);
		}
		
		
		/**
		 * 用户有按键
		 * @param event
		 */
		protected function keyDownHandler(event:KeyboardEvent):void
		{
			var index:int;
			switch(event.keyCode)
			{
				case 13://回车
					close();
					inputText.setSelection(inputText.text.length, inputText.text.length);
					break;
				
				case 38://上箭头
					index = list.selectedItem ? list.selectedItem.index - 1 : 0;
					selectItemByIndex(index);
					break;
				
				case 40://下箭头
					index = list.selectedItem ? list.selectedItem.index + 1 : 0;
					if(index == list.numItems) index = 0;
					selectItemByIndex(index);
					break;
			}
		}
		
		
		/**
		 * 下拉列表，鼠标按下item
		 * @param event
		 */
		protected function list_itemMouseDownHandler(event:ListEvent):void
		{
			if(event.item != null) label = event.item[labelField];
		}
		
		/**
		 * 输入文本，内容有改变
		 * @param event
		 */
		protected function inputText_changeHandler(event:Event):void
		{
			label = inputText.text;
			selectItemByKey(inputText.text);
			open();
		}
		
		
		/**
		 * 点击下拉按钮
		 * @param event
		 */
		protected function arrowBtn_clickHandler(event:MouseEvent):void
		{
			_needOpen ? open() : _needOpen = true;
		}
		
		
		/**
		 * 鼠标在舞台上按下
		 * @param event
		 */
		protected function stage_mouseDownHandler(event:MouseEvent):void
		{
			close();
			_needOpen = event.target != arrowBtn;
		}
		
		
		/**
		 * 鼠标在滚动条上按下
		 * @param event
		 */
		protected function listVSB_mouseDownHandler(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
		}
		
		
		
		
		/**
		 * 打开下拉列表
		 */
		public function open():void
		{
			Common.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, false, 9999);
			Common.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, true, 9999);
			Common.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			listVSB.addEventListener(MouseEvent.MOUSE_DOWN, listVSB_mouseDownHandler);
			openOrCloseList(true);
		}
		
		/**
		 * 关闭下拉列表
		 */
		public function close():void
		{
			Common.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
			Common.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, true);
			Common.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			listVSB.removeEventListener(MouseEvent.MOUSE_DOWN, listVSB_mouseDownHandler);
			openOrCloseList(false);
		}
		
		
		
		/**
		 * 打开或关闭下拉列表
		 * @param isOpen
		 */
		public function openOrCloseList(isOpen:Boolean):void
		{
			list.visible = isOpen;
			listBG.visible = isOpen;
			listVSB.visible = isOpen && listVSB.showed;
		}
		
		
		
		
		/**
		 * 通过key选中item
		 * @param key
		 */
		public function selectItemByKey(key:String):void
		{
			var data:IHashMap = list.data;
			if(data == null) return;
			
			if(key.length > 0 && key != _lastKey)
			{
				var i:int;
				var n:int;
				var keys:Array;
				for(i = 0; i < data.length; i++)
				{
					keys = data.getKeysByIndex(i);
					if(keys != null) {
						for(n = 0; n < keys.length; n++)
						{
							if(String(keys[n]).slice(0, key.length) == key)
							{
								_lastKey = key;
								label = keys[n];
								inputText.setSelection(key.length, inputText.text.length);
								list.selectItemByDataIndex(i);
								return;
							}
						}
					}
				}
			}
			list.selectedItem = null;
			_lastKey = "";
		}
		
		
		/**
		 * 通过index选中item
		 * @param index
		 */
		public function selectItemByIndex(index:int):void
		{
			list.selectItemByDataIndex(index);
			label = list.selectedItem[labelField];
		}
		
		
		
		/**
		 * 当前文本的内容
		 */
		public function set label(value:String):void
		{
			inputText.text = labelText.text = value;
		}
		public function get label():String { return inputText.text; }
		
		
		/**
		 * 是否可以编辑
		 */
		public function set editable(value:Boolean):void
		{
			_editable = value;
			inputText.visible = value;
			labelText.visible = !value;
		}
		public function get editable():Boolean { return _editable; }
		
		
		
		/**
		 * 销毁<br/>
		 * <font color="red">在丢弃该组件时，一定要调用该方法，以免导致内存泄漏</font>
		 */
		public function dispose():void
		{
			list.dispose();
			listVSB.dispose();
			arrowBtn.dispose();
			labelText.dispose();
		}
		//
	}
}