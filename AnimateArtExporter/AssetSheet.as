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
			var bitmapDatas = getBitmapDatas(mc, 1);
			trace(bitmapDatas.length);
			
			var pow2Sheet = generatePOW2Sheet(bitmapDatas);
			
			var byteArray:ByteArray = PNGEncoder.encode(pow2Sheet);
			FileExporter.ExportPNG(byteArray, 1, getQualifiedClassName(mc) + "-AssetSheet-MaxRect");
		}
		
		function generatePOW2Sheet(bitmapDatas:Array):BitmapData
		{
			var pow2Sizes = [128, 256, 512, 1024, 2048];
			var packer:MaxRectPacker;
			var pow2Sheet:BitmapData;
			
			for(var sizeId:int = 0; sizeId < pow2Sizes.length; ++sizeId)
			{
				var pow2Size = pow2Sizes[sizeId];
				
				packer = new MaxRectPacker(pow2Size, pow2Size);
				pow2Sheet = new BitmapData(pow2Size, pow2Size, true);

				var fittedBitmaps = 0;
				
				for(var i:int = 0; i < bitmapDatas.length; ++i)
				{
					var bitmapData = bitmapDatas[i];
					var rect:Rectangle = packer.quickInsert(bitmapData.width, bitmapData.height);
					
					if(!rect)
					{ 
						trace("Can't fit into " + pow2Size + "x" + pow2Size + "."); 
						break; 
					}

					var m:Matrix = new Matrix();
					m.translate(rect.x, rect.y);
					pow2Sheet.draw(bitmapData, m);
					
					fittedBitmaps++;
				}		
				
				if(fittedBitmaps == bitmapDatas.length)
					break;
			}
			
			return pow2Sheet;
		}
		
		function getBitmapDatas(mc:MovieClip, scale:int=1):Array
		{
			var bitmapDatas:Array = [];
		
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var child = mc.getChildAt(childId);
				
				if(child is MovieClip)
				{
					var childMC:MovieClip = child;
					trace("Processing ", childMC.name);
					var bitmapData = getBitmapData(childMC, scale);
					bitmapDatas.push(bitmapData);
						
					if(childMC.numChildren > 1)
					{
						trace("----");
						trace(childMC.name, " has ", childMC.numChildren, " children.");
						bitmapDatas = bitmapDatas.concat(getBitmapDatas(childMC, scale));
						trace("----");
					}
				}
			}
			
			return bitmapDatas;
		}
				
		function getBitmapData(mc:MovieClip, scale:int)
		{
			var bounds = mc.getBounds(mc);
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(scale, scale);
			
			var bitmap = new Bitmap(new BitmapData(mc.width * scale, mc.height * scale, true, 0x0));
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			
			return bitmap.bitmapData;
		}
	}
}