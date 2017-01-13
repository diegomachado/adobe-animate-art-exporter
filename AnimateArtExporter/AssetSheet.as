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
	import flash.display.FrameLabel;

	public class AssetSheet
	{		
		var _movieClipName = "";
		var _scale:int;
		var _bgColor:uint;
		var _assetSheetExtension = "-AssetSheet";
		var _transparentBG:Boolean;
		
		var _spritesheetData = {};
		
		public function export(mc:MovieClip, scale:int, sheetPadding:int, transparentBG:Boolean)
		{			
			_movieClipName = getQualifiedClassName(mc);
			_scale = scale;
			_transparentBG = transparentBG;
			_bgColor = _transparentBG ? 0x0 : 0xFFFF00FF;
			
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
			var assetSheet = new BitmapData(maxRectSize, maxRectSize, true, _bgColor);
			
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
					var childMC:MovieClip = child as MovieClip;
	
					//for (var frameId in childMC.currentLabels)
//						trace(frameId, childMC.currentLabels[0]);
					
					if(childMC.currentLabels[0] != undefined && childMC.currentLabels[0].name == "spritesheet")
					{
						var animationLabel = childMC.currentLabels[1].name;
						var spritesheetBitmaps = getSpriteSheetBitmaps(childMC, animationLabel);
					
						for(var spritesheetBitmapId in spritesheetBitmaps)
							bitmaps[spritesheetBitmapId] = spritesheetBitmaps[spritesheetBitmapId];
					}
					else
					{
						var bitmap = getBitmap(childMC);
						bitmaps[childMC.name] = bitmap;
					}
					
					if(childMC.numChildren > 0)
					{
						var nestedBitmaps = getBitmaps(childMC);
						
						for(var nestedBitmapId in nestedBitmaps)
							bitmaps[nestedBitmapId] = nestedBitmaps[nestedBitmapId];
					}
				}
			}
			
			return bitmaps;
		}
		
		function getSpriteSheetBitmaps(mc:MovieClip, animationName:String)
		{
			var spritesheetBitmaps = {};
			_spritesheetData[animationName] = {}
			_spritesheetData[animationName][mc.name] = [];
			
			var keyframeId = 1;
			var spriteName = mc.name + "_" + keyframeId;
			
			for(var frameId = 1; frameId <= mc.totalFrames; ++frameId)
			{
				mc.gotoAndStop(frameId);
				
				var currentBitmap = getBitmap(mc);
				var addBitmap = false;
				
				if(frameId == 1)
				{
					addBitmap = true;
				}
				else
				{
					var distinctCount = 0;
					var bitmapCount = 0;
					
					for(var bitmapId in spritesheetBitmaps)
					{
						var bitmap = spritesheetBitmaps[bitmapId];
						bitmapCount++;
						
						var bitmapComparison = currentBitmap.compare(bitmap);
						
						if(bitmapComparison == -4 || bitmapComparison == -3)
						{
							spriteName = mc.name + "_" + keyframeId;
							distinctCount++;							
						}
						else
						{
							spriteName = bitmapId;		
							break;
						}
					}
					
					if(distinctCount == bitmapCount)
						addBitmap = true;
				}
				
				if(addBitmap)
				{					
					spritesheetBitmaps[spriteName] = currentBitmap;
					keyframeId++;
				}
				
				_spritesheetData[animationName][mc.name].push(spriteName);
			}
			
			return spritesheetBitmaps;
		}
		
		function getBitmap(mc:MovieClip):BitmapData
		{
			var bounds = mc.getBounds(mc);
			
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(_scale, _scale);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(mc.width * _scale, mc.height * _scale, true, _bgColor));
			
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
		
		public function getSpritesheetData():Object
		{
			return _spritesheetData;
		}
	}
}