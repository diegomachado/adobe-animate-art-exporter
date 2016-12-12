package AnimateArtExporter
{	
	import flash.utils.ByteArray;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.display.BitmapData;
	
	import by.blooddy.crypto.image.PNGEncoder;

	public class FileExporter
	{
		var _swfName:String;
		
		public static function ExportPNG(bitmapData:BitmapData, filePath:String, scale:int=1):String
		{
			var fileName = filePath + "@" + scale + "x.png";
			var bytes:ByteArray = PNGEncoder.encode(bitmapData);
			
			FileExporter.saveFile(bytes, "export/" + fileName);
			
			return fileName;
		}

		public static function ExportJSON(json:String, filePath:String)
		{
			var fileName = filePath + ".json";
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(json, "iso-8859-1");
			
			FileExporter.saveFile(bytes, "export/" + fileName);
			
			return fileName;
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