package lolo.utils
{
	/**
	 * 简单的UBB操作工具（常用于支持RichText，聊天系统）
	 * 该工具操作的UBB字符串是由尖括号包含的，而不是中括号
	 * @author LOLO
	 */
	public class UbbUtil
	{
		/**标签 - 普通字符串*/
		public static const LABEL_STRING:String = "str";
		/**标签 - 颜色*/
		public static const LABEL_COLOR:String = "color";
		/**标签 - 链接*/
		public static const LABEL_LINK:String = "link";
		/**标签 - 图像*/
		public static const LABEL_IMG:String = "img";
		
		/**用于找出color包含的文字*/
		private static const RE_COLOR:RegExp = /\<(color)=(.*?)>(.*?)\<\/(color)\>/ig;
		/**用于找出link包含的文字*/
		private static const RE_LINK:RegExp = /\<(link)=(.*?)>(.*?)\<\/(link)\>/ig;
		/**用于找出img包含的文字*/
		private static const RE_IMG:RegExp = /\<(img)=(.*?)>(.*?)\<\/(img)\>/ig;
		
		
		
		/**
		 * 将UBB字符串转换成由Object组成的数组
		 * 不支持嵌套，支持的标签有：
		 * 		&lt;color="0x16位颜色值"&gt;文本内容&lt;/color&gt;
		 * 		&lt;link="链接的值"&gt;链接文本内容&lt;/link&gt;
		 * 		&lt;img&gt;&lt;/img&gt;
		 * @param str 要转换的UBB字符串，例："aaa&lt;link=111&gt;&lt;color=0xFF0000&gt;bbb&lt;/color&gt;&lt;/link&gt;ccc&lt;img=face.Smile&gt;&lt;/img&gt;"
		 * @return 
		 */
		public static function stringToList(str:String):Array
		{
			var colors:Array = [];
			var links:Array = [];
			var imgs:Array = [];
			var items:Array = [
				{re:RE_COLOR, data:colors, str:"|<color>|"},
				{re:RE_LINK, data:links, str:"|<link>|"},
				{re:RE_IMG, data:imgs, str:"|<img>|"}
			];
			
			var list:Array = [];
			var result:Array;
			var i:int;
			var str2:String = str;
			
			//找出标签包含的字符串
			for(i = 0; i < items.length; i++)
			{
				result = items[i].re.exec(str);
				while(result != null)
				{
					items[i].data.push({ type:result[1], value:result[2], content:result[3] });
					result = items[i].re.exec(str);
				}
				
				//替换内容，用|进行分隔
				str2 = str2.replace(items[i].re, items[i].str);
			}
			
			
			//拆分成数组，并组合最终返回的数组
			var strList:Array = str2.split("|");
			for(i = 0; i < strList.length; i++)
			{
				str = strList[i];
				switch(str)
				{
					case "<color>":
						list.push(colors.shift());
						break;
					case "<link>":
						list.push(links.shift());
						break;
					case "<img>":
						list.push(imgs.shift());
						break;
					default:
						if(str != "") list.push({ type:LABEL_STRING, content:str });
				}
			}
			
			return list;
		}
		//
	}
}