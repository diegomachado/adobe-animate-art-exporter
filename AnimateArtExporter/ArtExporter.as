package AnimateArtExporter
{	
	import by.blooddy.crypto.image.PNGEncoder;
	import AnimateArtExporter.AnimationData;
	import AnimateArtExporter.AssetSheet;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;

	public class ArtExporter
	{
		public static var swfName:String;
		private var animationData:AnimationData;
		private var assetSheet:AssetSheet;

		public function init(root:DisplayObjectContainer)
		{
			var swf = root.loaderInfo.url;
			swf = swf.slice(swf.lastIndexOf("/") + 1);
			swf = swf.slice(0, swf.indexOf("."));
			swfName = swf;
			
			animationData = new AnimationData();
			assetSheet = new AssetSheet();
		}
		
		public function exportAnimationData(mc:MovieClip)
		{
			animationData.exportJSONAnimations(mc);
		}
		
		public function exportAssetSheet(mc:MovieClip)
		{
			assetSheet.exportMaxRect(mc);
		}
	}
}