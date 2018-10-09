package lolo.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	
	import lolo.components.AlertText;
	import lolo.components.ArtText;
	import lolo.components.BaseButton;
	import lolo.components.Button;
	import lolo.components.CheckBox;
	import lolo.components.ComboBox;
	import lolo.components.DragArea;
	import lolo.components.IItemRenderer;
	import lolo.components.ImageButton;
	import lolo.components.ImageLoader;
	import lolo.components.InputText;
	import lolo.components.ItemGroup;
	import lolo.components.Label;
	import lolo.components.LinkText;
	import lolo.components.List;
	import lolo.components.Mask;
	import lolo.components.ModalBackground;
	import lolo.components.MultiColorLabel;
	import lolo.components.NumberText;
	import lolo.components.Page;
	import lolo.components.PageList;
	import lolo.components.RadioButton;
	import lolo.components.RichText;
	import lolo.components.ScrollBar;
	import lolo.components.ScrollList;
	import lolo.components.ToolTip;
	import lolo.core.Common;
	import lolo.display.Animation;
	import lolo.display.BitmapMovieClip;
	import lolo.display.BitmapSprite;
	import lolo.display.Container;
	import lolo.display.ControlledMovieClip;
	import lolo.ui.IWindowLayout;
	import lolo.utils.logging.Logger;
	
	/**
	 * 自动化工具
	 * @author LOLO
	 */
	public class AutoUtil
	{
		/**
		 * 自动化生成用户界面
		 * @param target 需要自动化生成用户界面的目标
		 * @param config 界面的配置信息
		 */
		public static function autoUI(target:DisplayObjectContainer, config:XML):void
		{
			//容器的相关设定
			initToolTip(target, config.@toolTip);
			initJsonString(target, config.@properties);
			initJsonString(target, config.@props);
			initJsonString(target, config.@vars);
			var slStr:String;//舞台布局属性
			
			//生成子元素
			for each(var item:XML in config.*)
			{
				if(item.@ignore == "true") continue;//编辑器中才需要生成的层
				
				var obj:DisplayObject;//创建的显示对象实例
				var id:String = item.@id;//指定的obj的实例名称
				var type:String = item.@type;//类型
				var targetID:String = item.@target;//指定目标，在某些组件中有特殊意义
				var groupID:String = item.@group;//是ItemRenderer时，指定的所属的组
				var parentID:String = item.@parent;//指定的父级容器
				var itemName:String = item.name().toString();//在xml中，这条item的名称
				
				//尝试直接从目标中拿该对象的引用
				if(id != "") obj = target[id];
				
				switch(itemName)
				{
					case "container":
						if(obj == null) {
							obj = (type == "comboBox") ? new ComboBox() : new Container();
						}
						(obj as Container).initUI(item);//继续初始化容器的UI
						break;
					
					case "bitmapSprite":
						if(obj == null) obj = new BitmapSprite();
						break;
					
					
					case "animation": case "ani":
						if(obj == null) obj = new Animation();
						break;
					
					
					case "displayObject"://普通的显示对象，fla文件中导出的类
						if(obj == null) obj = getInstance(item.@definition);
						if(obj is MovieClip) (obj as MovieClip).gotoAndStop(1);
						break;
					
					case "sprite":
						if(obj == null) obj = new Sprite();
						break;
					
					case "imageLoader":
						if(obj == null) obj = new ImageLoader();
						break;
					
					case "artText":
						if(obj == null) obj = new ArtText();
						break;
					
					
					case "label":
						if(obj == null) obj = new Label();
						break;
					
					case "inputText":
						if(obj == null) obj = new InputText();
						break;
					
					case "numberText":
						if(obj == null) obj = new NumberText();
						break;
					
					
					case "baseButton":
						if(obj == null) obj = new BaseButton();
						break;
					
					case "imageButton":
						if(obj == null) obj = new ImageButton();
						break;
					
					case "button":
						if(obj == null) obj = new Button();
						break;
					
					case "checkBox":
						if(obj == null) obj = new CheckBox();
						break;
					
					case "radioButton":
						if(obj == null) obj = new RadioButton();
						break;
					
					
					case "page":
						if(obj == null) obj = new Page();
						break;
					
					case "scrollBar":
						if(obj == null) obj = new ScrollBar();
						if(targetID != "") {
							(obj as ScrollBar).content = target[targetID];
							if(target[targetID] is ScrollList) (target[targetID] as ScrollList).scrollBar = obj as ScrollBar;
						}
						break;
					
					
					case "itemGroup":
						if(obj == null) obj = new ItemGroup();
						break;
					
					case "list":
						if(obj == null) obj = new List();
						break;
					
					case "pageList":
						if(obj == null) obj = new PageList();
						if(targetID != "") (obj as PageList).page = target[targetID];
						break;
					
					case "scrollList":
						if(obj == null) obj = new ScrollList();
						break;
					
					
					case "modalBackground": case "modalBG":
						if(obj == null) obj = new ModalBackground(target);
						break;
					
					
					
					
					case "bitmapMovieClip": case "bmc":
						if(obj == null) obj = new BitmapMovieClip();
						break;
					
					case "controlledMovieClip": case "cmc":
						if(obj == null) obj = new ControlledMovieClip();
						break;
					
					
					//内容多色（可以是动画）显示文本
					case "mcLabel":
						if(obj == null) obj = new MultiColorLabel();
						break;
					
					//富显示文本
					case "richText":
						if(obj == null) obj = new RichText();
						break;
					
					//链接文本
					case "linkText":
						if(obj == null) obj = new LinkText();
						break;
					
					//提示文本
					case "alertText":
						if(obj == null) obj = new AlertText();
						break;
					
					//拖动区域
					case "dragArea":
						if(obj == null) obj = new DragArea(target as Sprite);
						break;
					
					//遮罩
					case "mask":
						if(obj == null) obj = new Mask();
						if(targetID != "") (obj as Mask).target = target[targetID];
						break;
					
					default :
						obj = null;
				}
				
				if(obj != null)
				{
					//对象不是容器
					if(itemName != "container") {
						initToolTip(obj, item.@toolTip);
						initJsonString(obj, item.@properties);
						initJsonString(obj, item.@props);
						initJsonString(obj, item.@vars);
						
						if(String(item.@style).length > 0)
						{
							obj["style"] = JSON.parse(item.@style);
							//按钮会重置宽高
							if(obj is BaseButton) {
								var props:Object = JSON.parse(item.@properties);
								if(props.width != null) obj.width = props.width;
								if(props.height != null) obj.height = props.height;
							}
						}
						
						slStr = item.@stageLayout;
						if(slStr != "") Common.layout.addStageLayout(obj, JSON.parse(slStr));
					}
					
					//有指定实例名称，将引用赋值给target
					if(id != "") target[id] = obj;
					
					//是ItemRenderer，并且有指定的组
					if(obj is IItemRenderer && groupID != "") {
						(obj as IItemRenderer).group = target[groupID];
					}
					
					//有指定父级容器
					if(parentID != ""){
						if(parentID != "null") (target[parentID] as DisplayObjectContainer).addChild(obj);
					}
					//不是模态背景和遮罩
					else if(!(obj is ModalBackground) && !(obj is Mask)) {
						target.addChild(obj);
					}
					
					obj = null;
				}
			}
			
			//舞台布局属性
			slStr = config.@stageLayout;
			if(slStr == "" && target is IWindowLayout) slStr = "{}";//窗口默认需要使用stageLayout
			if(slStr != "") Common.layout.addStageLayout(target, JSON.parse(slStr));
		}
		
		
		
		/**
		 * 刷新用户界面（用于重载xml）
		 * @param target 需要刷新的用户界面
		 * @param config 界面的配置信息
		 */
		public static function refreshUI(target:DisplayObjectContainer, config:XML):void
		{
			//容器的相关设定
			initToolTip(target, config.@toolTip);
			initJsonString(target, config.@properties);
			initJsonString(target, config.@vars);
			var slStr:String = config.@stageLayout;//有舞台布局属性
			if(slStr != "") Common.layout.addStageLayout(target, JSON.parse(slStr));
			
			
			//刷新子元素
			for each(var item:XML in config.*)
			{
				var obj:DisplayObject;//创建的显示对象实例
				var id:String = item.@id;//指定的obj的实例名称
				var itemName:String = item.name().toString();//在xml中，这条item的名称
				
				//只刷新已存在的对象
				if(id != "") obj = target[id];
				if(obj != null) {
					//对象是容器
					if(obj is Container) {
						(obj as Container).refreshUI(item);
					}
					else {
						initToolTip(obj, item.@toolTip);
						initJsonString(obj, item.@properties);
						initJsonString(obj, item.@vars);
						
						if(String(item.@style).length > 0)
						{
							obj["style"] = JSON.parse(item.@style);
							//按钮会重置宽高
							if(obj is BaseButton) {
								var props:Object = JSON.parse(item.@properties);
								if(props.width != null) obj.width = props.width;
								if(props.height != null) obj.height = props.height;
							}
						}
						
						slStr = item.@stageLayout;
						if(slStr != "") Common.layout.addStageLayout(obj, JSON.parse(slStr));
					}
				}
				obj = null;
			}
		}
		
		
		/**
		 * 通过JSON字符串，初始化目标的ToolTip
		 * @param target 需要初始化的目标
		 * @param jsonStr 属性的JSON字符串
		 */
		public static function initToolTip(target:DisplayObject, jsonStr:String):void
		{
			if(jsonStr != "")
			{
				var prop:Object = JSON.parse(jsonStr);
				if(prop.styleName != null) ToolTip.registerStyle(target, prop.styleName);
				
				ToolTip.register(target, prop.text, prop.toolTipID);
			}
		}
		
		
		/**
		 * 初始化实例，先初始化属性对象，再初始化JSON字符串属性对象
		 * @param target 目标实例
		 * @param parent 目标实例如果是显示对象，可以指定容器
		 * @param obj 初始化属性对象
		 * @param jsonStr JSON字符串属性对象
		 * @return 初始化完毕的实例对象（即参数target）
		 */
		public static function init(target:Object, parent:DisplayObjectContainer=null, obj:Object=null, jsonStr:String=null):*
		{
			if(target == null) return null;
			if(obj != null) initObject(target, obj);
			if(jsonStr != null) initJsonString(target, jsonStr);
			if(parent != null && target is DisplayObject) parent.addChild(target as DisplayObject);
			return target;
		}
		
		
		/**
		 * 初始化属性对象
		 * @param target 目标对象的引用
		 * @param obj 属性对象
		 */
		public static function initObject(target:Object, obj:Object):void
		{
			obj = ObjectUtil.baseClone(obj);//拷贝出一个副本，用于操作
			
			//优先处理的属性
			if(obj.skin != null) {
				target.skin = obj.skin;
				delete obj.skin;
			}
			if(obj.skinName != null) {
				target.skinName = obj.skinName;
				delete obj.skin;
			}
			
			
			if(obj.style != null) {
				target.style = obj.style;
				delete obj.style;
			}
			if(obj.styleName != null) {
				target.styleName = obj.styleName;
				delete obj.styleName;
			}
			
			
			if(obj.sourceName != null) {
				target.sourceName = obj.sourceName;
				delete obj.sourceName;
			}
			
			
			if(obj.autoSize != null) {
				target.autoSize = obj.autoSize;
				delete obj.autoSize;
			}
			if(obj.autoTooltip != null) {
				target.autoTooltip = obj.autoTooltip;
				delete obj.autoTooltip;
			}
			
			if(obj.directory != null) {
				target.directory = obj.directory;
				delete obj.directory;
			}
			if(obj.extension != null) {
				target.extension = obj.extension;
				delete obj.extension;
			}
			
			for(var properties:String in obj)
			{
				try {
					target[properties] = obj[properties];
				}
				catch(error:Error) {
					trace("\n");
					trace("-=-=-=-=-=-=-=-=-= initObject Error =-=-=-=-=-=-=-=-=-");
					trace("     error:", error);
					trace("    target:", target);
					trace("properties:", properties);
					trace("     value:", obj[properties]);
					trace("-=-=-=-=-=-=-=-=-=-=-=-=- END =-=-=-=-=-=-=-=-=-=-=-=-");
					trace("\n");
				}
			}
		}
		
		/**
		 * 初始化JSON字符串
		 * @param target 目标对象的引用
		 * @param jsonStr JSON字符串属性对象
		 */
		public static function initJsonString(target:Object, jsonStr:String):void
		{
			if(jsonStr.length > 0) initObject(target, JSON.parse(jsonStr));
		}
		
		
		
		
		
		/**
		 * 根据类的完整定义名称，返回类实例
		 * @param definition 类的完整定义名称
		 * @param appDomain 指定的应用程序域。默认值 null 表示使用当前程序域
		 */
		public static function getInstance(definition:String, appDomain:ApplicationDomain=null):*
		{
			try {
				var tempClass:Class = (appDomain == null)
					? getDefinitionByName(definition) as Class
					: appDomain.getDefinition(definition) as Class;
				return new tempClass();
			}
			catch(error:Error) {
				Logger.addLog("[LFW] definition: " + definition + " 不存在！", Logger.LOG_TYPE_WARN);
				
				//防止后续出错，返回一个空MC
				return new MovieClip();
			}
		}
		//
	}
}