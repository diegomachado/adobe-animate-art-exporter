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
		var _scale:int;
		var spriteSheetExtension = "-SpriteSheet";
		
		public function export(mc:MovieClip, scale:int, sheetPadding:int)
		{
			movieClipName = getQualifiedClassName(mc);
			_scale = scale;
			
			var bitmaps = getBitmaps(mc);
			var maxRectSolver = new MaxRectSolver(mc, bitmaps, _scale, sheetPadding);
			
			var spriteSheetName = createSpriteSheet(bitmaps, maxRectSolver);
			
			var framesJSON = maxRectSolver.exportFramesJSON(spriteSheetName);
			FileExporter.ExportJSON(framesJSON, spriteSheetName + "-Frames");
		}
		
		function createSpriteSheet(bitmaps:Array, maxRectSolver:MaxRectSolver):String
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
		
			return FileExporter.ExportPNG(spriteSheet, movieClipName + spriteSheetExtension, _scale);
		}
		
		function getBitmaps(mc:MovieClip)
		{
			var bitmaps = [];
			
			for(var frameId = 0; frameId < mc.totalFrames; ++frameId)
				bitmaps.push(getFrameBitmap(mc, frameId));

			return bitmaps;
		}
		
		function getFrameBitmap(mc:MovieClip, frame:int):BitmapData
		{
			mc.gotoAndStop(frame);
			
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(_scale, _scale);
			
			var bitmap = new Bitmap(new BitmapData(mc.width * _scale, mc.height * _scale, true, 0x0));
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			
			return bitmap.bitmapData;
		}
	}
}