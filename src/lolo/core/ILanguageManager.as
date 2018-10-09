package lolo.core
{
	import flash.events.IEventDispatcher;

	/**
	 * 语言包管理
	 * @author LOLO
	 */
	public interface ILanguageManager extends IEventDispatcher
	{
		
		/**
		 * 初始化语言包
		 * @param config xml配置（在编辑器中会传入）
		 */
		function initialize(config:XML=null):void;
		
		
		/**
		 * 通过ID在语言包中获取对应的字符串
		 * @param id 在语言包中的ID
		 * @param rest 用该参数替换字符串内的"{n}"标记
		 * @return 
		 */
		function getLanguage(id:String, ...rest):String;
	}
}