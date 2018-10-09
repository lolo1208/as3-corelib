package lolo.utils
{
	/**
	 * 验证工具。提供一些常用的数据验证方法
	 * @author LOLO
	 */
	public class Validator
	{
		
		/**
		 * 验证字符串大于零，并且没有空格(包括全角空格)
		 * @param str 要验证的字符串
		 * @return 
		 */
		public static function noSpace(str:String):Boolean
		{
			return str.length > 0 && str.indexOf(" ") == -1 && str.indexOf("　") == -1;
		}
		
		
		/**
		 * 验证字符串不全是空格(包括全角空格)
		 * @param str
		 * @return 
		 */
		public static function notExactlySpace(str:String):Boolean
		{
			for(var i:int = 0; i < str.length; i++)
			{
				if(str.charAt(i) != " " && str.charAt(i) != "　") return true;
			}
			return false;
		}
		
		
		/**
		 * 验证字符串是否为正确的邮箱地址
		 * @param str
		 * @return 
		 */
		public static function rightEmail(str:String):Boolean
		{
			var re:RegExp = /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
			return re.test(str);
		}
		//
	}
}