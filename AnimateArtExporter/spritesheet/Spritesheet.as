package AnimateArtExporter.spritesheet
{	
	import AnimateArtExporter.utils.*;
	
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.getQualifiedClassName;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Spritesheet
	{
		var movieClipName = "";
		var _scale:int;
		var _transparentBG:Boolean;
		var _bgColor:uint;
		var spriteSheetExtension = "-SpriteSheet";
		
		public function export(mc:MovieClip, scale:int, sheetPadding:int, transparentBG:Boolean)
		{
			movieClipName = getQualifiedClassName(mc);
			_scale = scale;
			_transparentBG = transparentBG;
			_bgColor = _transparentBG ? 0x0 : 0xFFFF00FF;
			
			var bitmaps = getBitmaps(mc);
			var maxRectSolver = new MaxRectSolver(mc, bitmaps, _scale, sheetPadding);
			var spriteSheetName = createSpritesheet(bitmaps, maxRectSolver);
			
			var framesJsonString = maxRectSolver.exportFramesJsonString(spriteSheetName);
			
			var framesJson = JSON.parse(framesJsonString);			
			
			var bounds = getBounds(mc);
			framesJson.meta.size = { width: bounds.width, height: bounds.height };
			framesJson.meta.origin = { x: bounds.x, y: bounds.y };

			var animationName = mc.currentLabel;
			framesJson.meta.animationName = animationName;
			
			framesJsonString = JSON.stringify(framesJson, function(k,v) { return v }, 2);			
			
			FileExporter.ExportJSON(framesJsonString, spriteSheetName + "-Frames");
		}
		
		function getBitmaps(mc:MovieClip)
		{
			var bitmaps = [];
			
			for(var frameId = 1; frameId <= mc.totalFrames; ++frameId)
			{
				var frameBitmap:BitmapData = getFrameBitmap(mc, frameId);
				bitmaps.push(frameBitmap);
			}

			return bitmaps;
		}
		
		function getFrameBitmap(mc:MovieClip, frame:int):BitmapData
		{
			mc.gotoAndStop(frame);
			
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(_scale, _scale);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(mc.width * _scale, mc.height * _scale, _transparentBG, _bgColor));
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			
			return bitmap.bitmapData;
		}
		
		function createSpritesheet(bitmaps:Array, maxRectSolver:MaxRectSolver):String
		{
			var maxRects = maxRectSolver.getRectangles();
			var maxRectSize = maxRectSolver.getSize();
			var spriteSheet = new BitmapData(maxRectSize, maxRectSize, _transparentBG, _bgColor);
			
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
		
		function getBounds(mc:MovieClip)
		{
			mc.gotoAndStop(1);
			var bounds:Rectangle = mc.getBounds(mc);
			return { 
				x: Math.round(bounds.x * -1), 
			  y: Math.round(bounds.y * -1), 
			  width: Math.round(bounds.width), 
				height: Math.round(bounds.height) 
			};
		}
	}
}