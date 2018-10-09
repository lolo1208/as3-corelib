package lolo.utils
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Object工具
	 * @author LOLO
	 */
	public class ObjectUtil
	{
		/**
		 * 深度克隆一个对象
		 * 注：无法对有过delete操作的flash.utils.Dictionary对象进行克隆
		 * @param source 要克隆的对象
		 * @return 
		 */
		public static function baseClone(source:*):*
		{
			var typeName:String = getQualifiedClassName(source);
			var packageName:String = (typeName.indexOf("::") != -1) ? typeName.split("::")[1] : typeName;
			var type:Class = Class(getDefinitionByName(typeName));
			
			registerClassAlias(packageName, type);
			
			var copier:ByteArray = new ByteArray();
			copier.writeObject(source);
			copier.position = 0;
			return copier.readObject();
		}
		//
	}
}