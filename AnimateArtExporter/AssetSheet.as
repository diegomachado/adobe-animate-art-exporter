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
		var _movieClipName = "";
		var _scale:int;
		var _assetSheetExtension = "-AssetSheet";
		
		public function export(mc:MovieClip, scale:int, sheetPadding:int)
		{			
			_movieClipName = getQualifiedClassName(mc);
			_scale = scale;
			
			var bitmaps = getBitmaps(mc);			
			var maxRectSolver = new MaxRectSolver(mc, bitmaps, _scale, sheetPadding);
			
			var assetSheetFileName = createAssetSheet(bitmaps, maxRectSolver);			
			
			var framesJSON = maxRectSolver.exportFramesJSON(assetSheetFileName);
			FileExporter.ExportJSON(framesJSON, assetSheetFileName + "-Frames");
		}
		
		function createAssetSheet(bitmaps:Object, maxRectSolver:MaxRectSolver):String
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
			
			return FileExporter.ExportPNG(assetSheet, _movieClipName + _assetSheetExtension, _scale);
		}
		
		function getBitmaps(mc:MovieClip)
		{
			var bitmaps = {};
		
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var child = mc.getChildAt(childId);
				
				if(child is MovieClip)
				{
					var childMC = child as MovieClip;
					var bitmap = getBitmap(childMC);
					bitmaps[childMC.name] = bitmap;
						
					if(childMC.numChildren > 1)
					{
						var nestedBitmaps = getBitmaps(childMC);
						for(var nestedBitmapId in nestedBitmaps)
							bitmaps[nestedBitmapId] = nestedBitmaps[nestedBitmapId];
					}
				}
			}
			
			return bitmaps;
		}
				
		function getBitmap(mc:MovieClip):BitmapData
		{
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(_scale, _scale);
			
			var bitmap = new Bitmap(new BitmapData(mc.width * _scale, mc.height * _scale, true, 0x0));
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
	}
}