package AnimateArtExporter
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;	
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import by.blooddy.crypto.image.PNGEncoder;
	import treefortress.textureutils.MaxRectPacker;

	public class AssetSheet
	{
		public function exportMaxRect(mc:MovieClip)
		{
			var bitmapList = [];
			var bitmapData:BitmapData;
			
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var childMC:MovieClip = mc.getChildAt(childId) as MovieClip;
				bitmapData = getMovieClipBitmapData(childMC, 1);
				bitmapList.push(bitmapData);
			}
			
			var pow2Sizes = [128, 256, 512, 1024, 2048];
			var packer:MaxRectPacker;
			var atlasBitmap:BitmapData;
			
			for(var sizeId:int = 0; sizeId < pow2Sizes.length; ++sizeId)
			{
				var pow2Size = pow2Sizes[sizeId];
				packer = new MaxRectPacker(pow2Size, pow2Size);
				atlasBitmap = new BitmapData(pow2Size, pow2Size, true);

				var fittedBitmaps = 0;
				
				for(var i:int = 0; i < bitmapList.length; ++i)
				{
					bitmapData = bitmapList[i];
					var rect:Rectangle = packer.quickInsert(bitmapData.width, bitmapData.height);
					
					if(!rect)
					{ 
						trace("Can't fit into " + pow2Size + "x" + pow2Size + "."); 
						break; 
					}

					var m:Matrix = new Matrix();
					m.translate(rect.x, rect.y);
					atlasBitmap.draw(bitmapData, m);
					fittedBitmaps++;
				}		
				
				if(fittedBitmaps == bitmapList.length)
					break;
			}
			
			var byteArray:ByteArray = PNGEncoder.encode(atlasBitmap);
			FileExporter.ExportPNG(byteArray, 1, getQualifiedClassName(mc) + "-AssetSheet-MaxRect");
		}
				
		function getMovieClipBitmapData(mc:MovieClip, scale:int)
		{
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(scale, scale);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(mc.width * scale, mc.height * scale, true, 0x0));
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			
			return bitmap.bitmapData;
		}
	}
}