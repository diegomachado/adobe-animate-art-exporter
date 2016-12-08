package AnimateArtExporter
{	
	import flash.utils.ByteArray;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;

	public class FileExporter
	{
		var _swfName:String;
		
		public static function ExportPNG(bytes:ByteArray, scale:int, filePath:String)
		{
			FileExporter.saveFile(bytes, "export/" + filePath + "@" + scale + "x.png");
		}

		public static function ExportJSON(json:String, filePath:String)
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(json, "iso-8859-1");
			
			FileExporter.saveFile(bytes, "export/" + filePath + ".json");
		}
		
		private static function saveFile(bytes:ByteArray, path:String)
		{
			var file = File.applicationDirectory.resolvePath(path);
			var wr = new File(file.nativePath);
			var stream = new FileStream();
			
			stream.open(wr, FileMode.WRITE);
			stream.writeBytes(bytes, 0, bytes.length);
			stream.close();
		}
	}
}