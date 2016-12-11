package AnimateArtExporter
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	public class AssetSheet
	{		
		var movieClipName = "";
		var assetSheetExtension = "-AssetSheet";
		
		public function export(mc:MovieClip)
		{			
			movieClipName = getQualifiedClassName(mc);
			
			var bitmaps = getBitmaps(mc, 1);			
			var maxRectSolver = new MaxRectSolver(mc, bitmaps);
			
			createAssetSheet(bitmaps, maxRectSolver);			
			createFramesJSON(maxRectSolver);
		}
		
		function createAssetSheet(bitmaps:Object, maxRectSolver:MaxRectSolver)
		{
			var maxRects = maxRectSolver.getRectangles();
			var maxRectSize = maxRectSolver.getSize();
			var assetSheet = new BitmapData(maxRectSize, maxRectSize, true);
			
			for(var bitmapId in bitmaps)
			{
				var bitmap = bitmaps[bitmapId];
				var rect = maxRects[bitmapId];
				
				var m:Matrix = new Matrix();
				m.translate(rect.x, rect.y);
				assetSheet.draw(bitmap, m);
			}
		
			FileExporter.ExportPNG(assetSheet, movieClipName + assetSheetExtension);
		}
		
		function getBitmaps(mc:MovieClip, scale:int=1)
		{
			var bitmaps = {};
		
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var child = mc.getChildAt(childId);
				
				if(child is MovieClip)
				{
					var childMC = child as MovieClip;
					var bitmap = getBitmap(childMC, scale);
					bitmaps[childMC.name] = bitmap;
						
					if(childMC.numChildren > 1)
					{
						var nestedBitmaps = getBitmaps(childMC, scale);
						for(var nestedBitmapId in nestedBitmaps)
							bitmaps[nestedBitmapId] = nestedBitmaps[nestedBitmapId];
					}
				}
			}
			
			return bitmaps;
		}
				
		function getBitmap(mc:MovieClip, scale:int):BitmapData
		{
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(scale, scale);
			
			var bitmap = new Bitmap(new BitmapData(mc.width * scale, mc.height * scale, true, 0x0));
			toggleChildrenVisibility(mc, false);
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			toggleChildrenVisibility(mc, true);
			
			return bitmap.bitmapData;
		}
		
		function toggleChildrenVisibility(mc:MovieClip, isVisible:Boolean)
		{
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var child = mc.getChildAt(childId);
				
				if(child is MovieClip)
					child.visible = isVisible;
			}
		}
		
		function createFramesJSON(maxRectSolver:MaxRectSolver)
		{
			var rectangles = maxRectSolver.getRectangles();
			var pngSize = maxRectSolver.getSize();
			
			var framesJSON = {}
			framesJSON["meta"] = {};
			framesJSON["frames"] = [];
			
			for(var frameId in rectangles)
			{
				var rect = rectangles[frameId];
				var frameJSON = {};
				
				frameJSON["filename"] = frameId;
				frameJSON["frame"] = { "x": rect.x, "y": rect.y, "w": rect.width, "h": rect.height };
				frameJSON["rotated"] = false;
				frameJSON["trimmed"] = false;
				framesJSON["frames"].push(frameJSON);
			}
			
			framesJSON["meta"]["image"] = movieClipName + assetSheetExtension + ".png";
			framesJSON["meta"]["size"] = { "w": pngSize, "h": pngSize };
			framesJSON["meta"]["scale"] = 1;

			framesJSON = JSON.stringify(framesJSON, function(k,v) { return v }, 2);
			FileExporter.ExportJSON(framesJSON, movieClipName + "-Frames");
		}
	}
}