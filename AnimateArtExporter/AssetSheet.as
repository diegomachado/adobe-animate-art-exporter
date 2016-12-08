package AnimateArtExporter
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;	

	import by.blooddy.crypto.image.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;


	public class AssetSheet
	{
		public function exportAssetSheet(mc:MovieClip, scale:int)
		{
			var pngName = getQualifiedClassName(mc);
			
			var bitmapDatas = [];
			var sheetBitmap:Bitmap = new Bitmap();
			var bitmapData:BitmapData;
			var bitmapMinWidth = 0;
			
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var childMC:MovieClip = mc.getChildAt(childId) as MovieClip;
				var bitmapData = getMovieClipBitmapData(childMC, scale);
				bitmapDatas.push(bitmapData);
				bitmapMinWidth += childMC.width;
			}
		
			bitmapDatas = bitmapDatas.sortOn("height", Array.NUMERIC | Array.DESCENDING);			
			sheetBitmap.bitmapData = new BitmapData(bitmapMinWidth, bitmapDatas[0].height, true, 0x0);

			var matrix = new Matrix();		
			
			for(var bitmapDataId = 0; bitmapDataId < bitmapDatas.length ; ++bitmapDataId)
			{
				bitmapData = bitmapDatas[bitmapDataId];				
				
				if(bitmapDataId > 0)
				{
					var previousBitmapData = bitmapDatas[bitmapDataId - 1];
					matrix.translate(previousBitmapData.width, 0);
				}

				sheetBitmap.bitmapData.draw(bitmapData, matrix);
			}
			
			var byteArray:ByteArray = PNGEncoder.encode(sheetBitmap.bitmapData);
			
			FileExporter.ExportPNG(byteArray, scale, pngName + "-AssetSheet");
		}
		
		function exportMovieClipFrameAsPNG(mc:MovieClip, frameToExport:int, scale:int = 1)
		{
			mc.gotoAndStop(frameToExport);
			
			var pngName = getQualifiedClassName(mc);
			var bitmapData = getMovieClipBitmapData(mc, scale);
			var byteArray:ByteArray = PNGEncoder.encode(bitmapData);
			
			FileExporter.ExportPNG(byteArray, scale, pngName);
		}
		
		function getMovieClipBitmapData(mc:MovieClip, scale:int)
		{
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(scale, scale);

			//addDebugBorder(mc);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(mc.width * scale, mc.height * scale, true, 0x0));
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			
			return bitmap.bitmapData;
		}
		
		function addDebugBorder(mc:MovieClip)
		{
			var bounds = mc.getBounds(mc);
			var border:Sprite = new Sprite();			
			border.graphics.lineStyle(2, 0xFF0000);
			border.graphics.moveTo(bounds.x, bounds.y);
			border.graphics.lineTo(bounds.x + bounds.width, bounds.y);
			border.graphics.lineTo(bounds.x + bounds.width, bounds.y + bounds.height);
			border.graphics.lineTo(bounds.x, bounds.y + bounds.height);
			border.graphics.lineTo(bounds.x, bounds.y);
			mc.addChild(border);
		}
	}
}