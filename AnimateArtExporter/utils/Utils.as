package AnimateArtExporter.utils
{	
	public class Utils 
	{		
		public static function mapSize(map:Object):int
		{
			var size = 0;
			
			for (var s:String in map) 
				size++;
			
			return size;
		}
	}	
}