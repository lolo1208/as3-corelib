package lolo.utils.zip
{
	import com.nochump.utils.zip.ZipEntry;
	import com.nochump.utils.zip.ZipFile;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * 读取zip文件
	 * @author LOLO
	 */
	public class ZipReader extends ZipFile
	{
		public function ZipReader(data:IDataInput)
		{
			super(data);
		}
		
		
		/**
		 * 根据文件名称，获取文件
		 * @param name
		 * @return 
		 */
		public function getFile(name:String):ByteArray
		{
			return getInput(getEntry(name));
		}
		//
	}
}