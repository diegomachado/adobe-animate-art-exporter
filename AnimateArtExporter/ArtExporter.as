package AnimateArtExporter
{	
	import by.blooddy.crypto.image.PNGEncoder;
	import AnimateArtExporter.AnimationData;
	import AnimateArtExporter.AssetSheet;
	import AnimateArtExporter.SpriteSheet;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;

	public class ArtExporter
	{
		public static var swfName:String;
		private var animationData:AnimationData;
		private var assetSheet:AssetSheet;
		private var spriteSheet:SpriteSheet;

		public function init(root:DisplayObjectContainer)
		{
			var swf = root.loaderInfo.url;
			swf = swf.slice(swf.lastIndexOf("/") + 1);
			swf = swf.slice(0, swf.indexOf("."));
			swfName = swf;
			
			animationData = new AnimationData();
			assetSheet = new AssetSheet();
			spriteSheet = new SpriteSheet();
		}
		
		public function exportAssetSheet(mc:MovieClip, scales:Array)
		{
			for(var scaleId in scales)
				assetSheet.export(mc, scales[scaleId]);
			
			animationData.export(mc);
		}
		
		public function exportSpriteSheet(mc:MovieClip)
		{
			spriteSheet.export(mc);
		}
	}
}