package AnimateArtExporter 
{
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import treefortress.textureutils.MaxRectPacker;
	
	public class MaxRectSolver 
	{
		var _rectangles:Object;
		var _size:int;
		var _scale:int;
		var _padding:int;
		
		function MaxRectSolver(mc:MovieClip, bitmapDatas:Object, scale:int, padding:int)
		{
			_rectangles = {};
			_size = 0;
			_scale = scale;
			_padding = padding;
			solve(mc, bitmapDatas);
		}
		
		function solve(mc:MovieClip, bitmapDatas:Object)
		{
			var rectangles = {};
			
			var pow2Sizes = [128, 256, 512, 1024, 2048];
			var pow2Sheet:BitmapData;
			var packer:MaxRectPacker;
			
			var bitmapDatasLength = Utils.mapSize(bitmapDatas);
			
			for(var sizeId:int = 0; sizeId < pow2Sizes.length; ++sizeId)
			{
				rectangles = [];
				var pow2Size = pow2Sizes[sizeId];
				var fittedRectangles = 0;
				
				packer = new MaxRectPacker(pow2Size, pow2Size);
				
				for(var bitmapDataId in bitmapDatas)
				{
					var bitmapData = bitmapDatas[bitmapDataId];
					var fittedRectangle = packer.quickInsert(bitmapData.width + _padding * _scale * 2, bitmapData.height + _padding * _scale * 2);
					
					if(!fittedRectangle)
						break; 
					
					fittedRectangle.x += _padding * _scale;
					fittedRectangle.y += _padding * _scale;
					fittedRectangle.width -= _padding * _scale * 2;
					fittedRectangle.height -= _padding * _scale * 2;
					
					rectangles[bitmapDataId] = fittedRectangle;
					fittedRectangles++;
				}
			
				if(fittedRectangles == bitmapDatasLength)
				{
					_rectangles = rectangles;
					_size = pow2Size;
					break;
				}
			}
		}
		
		public function exportFramesJSON(fileName):String
		{
			var framesJSON = {}
			framesJSON["meta"] = {};
			framesJSON["frames"] = [];
			
			for(var frameId in _rectangles)
			{
				var rect = _rectangles[frameId];
				var frameJSON = {};
				
				frameJSON["filename"] = String(frameId);
				frameJSON["frame"] = { "x": rect.x, "y": rect.y, "w": rect.width, "h": rect.height };
				//frameJSON["rotated"] = false;
				//frameJSON["trimmed"] = false;
				framesJSON["frames"].push(frameJSON);
			}
			
			framesJSON["meta"]["image"] = fileName;
			framesJSON["meta"]["size"] = { "w": _size, "h": _size };
			framesJSON["meta"]["scale"] = 1;
			
			return JSON.stringify(framesJSON, function(k,v) { return v }, 2);
		}
		
		public function getRectangles()
		{
			return (Utils.mapSize(_rectangles) > 1) ? _rectangles : [];
		}
		
		public function getSize()
		{
			return _size;
		}
	}
}
