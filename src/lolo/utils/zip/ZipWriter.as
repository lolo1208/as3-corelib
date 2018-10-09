package lolo.utils.zip
{
	import com.nochump.utils.zip.ZipEntry;
	import com.nochump.utils.zip.ZipOutput;
	
	import flash.utils.ByteArray;

	/**
	 * 写入zip文件
	 * @author LOLO
	 */
	public class ZipWriter extends ZipOutput
	{
		
		public function ZipWriter()
		{
			super();
		}
		
		
		/**
		 * 向zip包中添加一个文件
		 * @param name 文件的路径和名称，如 test.txt 或 package/test.txt
		 * @param data 文件的数据
		 */
		public function addFile(name:String, data:ByteArray):void
		{
			var entry:ZipEntry = new ZipEntry(name);
			putNextEntry(entry);
			write(data);
		}
		//
	}
}