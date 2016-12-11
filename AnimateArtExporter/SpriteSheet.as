package AnimateArtExporter
{	
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.getQualifiedClassName;
	import flash.geom.Matrix;

	public class SpriteSheet
	{
		var movieClipName = "";
		var spriteSheetExtension = "-SpriteSheet";
		
		public function export(mc:MovieClip)
		{
			movieClipName = getQualifiedClassName(mc);
			
			var bitmaps = getBitmaps(mc);
			var maxRectSolver = new MaxRectSolver(mc, bitmaps);
			
			createSpriteSheet(bitmaps, maxRectSolver);
		}
		
		function createSpriteSheet(bitmaps:Array, maxRectSolver:MaxRectSolver)
		{
			var maxRects = maxRectSolver.getRectangles();
			var maxRectSize = maxRectSolver.getSize();
			var spriteSheet = new BitmapData(maxRectSize, maxRectSize, true);
			
			for(var bitmapId = 0; bitmapId < bitmaps.length; ++bitmapId)
			{
				var bitmap = bitmaps[bitmapId];
				var rect = maxRects[bitmapId];
				
				var m:Matrix = new Matrix();
				m.translate(rect.x, rect.y);
				spriteSheet.draw(bitmap, m);
			}
		
			FileExporter.ExportPNG(spriteSheet, movieClipName + spriteSheetExtension);
		}
		
		function getBitmaps(mc:MovieClip)
		{
			var bitmaps = [];
			
			for(var frameId = 0; frameId < mc.totalFrames; ++frameId)
				bitmaps.push(getFrameBitmap(mc, frameId));

			return bitmaps;
		}
		
		function getFrameBitmap(mc:MovieClip, frame:int, scale:int=1):BitmapData
		{
			mc.gotoAndStop(frame);
			
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(scale, scale);
			
			var bitmap = new Bitmap(new BitmapData(mc.width * scale, mc.height * scale, true, 0x0));
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			
			return bitmap.bitmapData;
		}
	}
}