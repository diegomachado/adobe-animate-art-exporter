package AnimationExporter
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

	public class AnimationExporter
	{
		var _swfName:String;

		public function init(root:DisplayObjectContainer)
		{
			var swfName = root.loaderInfo.url;
			swfName = swfName.slice(swfName.lastIndexOf("/") + 1);
			swfName = swfName.slice(0, swfName.indexOf("."));
			_swfName = swfName;
		}
		
		public function exportJSONAnimations(sourceMC:MovieClip)
		{
			var animationsData = extractEntityData(sourceMC);
			var animationsJSON = JSON.stringify(animationsData, function(k,v)
			{
				if(k == "colorMatrix")
				{
					var arrayString = JSON.stringify(v)
					return arrayString.slice(1, arrayString.length - 1);
				}
				
				return v;
			}, 2);
			
			trace(animationsJSON);
			
			ExportJSON(getQualifiedClassName(sourceMC), animationsJSON);
		}
		
		function extractEntityData(mc:MovieClip)
		{
			var entityData = {};
			entityData["name"] = getQualifiedClassName(mc);
			entityData["animations"] = {};
			
			for(var frameId = 1; frameId <= mc.totalFrames; ++frameId)
			{
				mc.gotoAndStop(frameId);		
				
				var animationName = mc.currentLabel;
				var animationsData = entityData["animations"];
				
				if(animationsData[animationName] == null)
					animationsData[animationName] = {};
					
				var animationData = animationsData[animationName];
				extractChildrenData(animationData, mc);
			}
			
			return animationsData;
		}
		
		function extractChildrenData(animationData:Object, mc:MovieClip)
		{
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var childMC:MovieClip = mc.getChildAt(childId) as MovieClip;
			
				if(childMC != null)
				{
					var childName = childMC.name;
					
					if(animationData[childName] == null)
					{
						animationData[childName] = {};
						animationData[childName]["totalFrames"] = childMC.totalFrames;
					}
					
					if(animationData[childName]["frames"] == null)
						animationData[childName]["frames"] = [];
					
					animationData[childName]["frames"].push(getMovieClipProperties(childMC));
					
					if(childMC.numChildren > 0)
						extractChildrenData(animationData, childMC);
				}
			}
		}
		
		function getMovieClipProperties(mc:MovieClip)
		{
			var properties = {};
			
			properties["x"] = mc.x;
			properties["y"] = mc.y;

			var mcCopy:MovieClip = new MovieClip();
			mcCopy.transform = mc.transform;
			mcCopy.rotation = 0;

			properties["scaleX"] = mcCopy.transform.matrix.a.toFixed(2);
			properties["scaleY"] = mcCopy.transform.matrix.d.toFixed(2);

			properties["rotation"] = mc.rotation.toFixed(3);
			properties["alpha"] = mc.alpha.toFixed(2);
			properties["frameId"] = mc.currentFrame;
			
			var color = new ColorMatrixFilter();
			var colorMatrix= color.matrix;
			
			if(mc.filters[0] is ColorMatrixFilter)
			{
				colorMatrix = mc.filters[0].matrix;

				for(var i: int = 0; i < colorMatrix.length; ++i)
					colorMatrix[i] = colorMatrix[i].toFixed(3);
			}
			
			properties["colorMatrix"] = colorMatrix;
			properties["depth"] = mc.parent.getChildIndex(mc);
			properties["blendMode"] = mc.blendMode;
						
			return properties;
		}

		private function ExportJSON(filename:String, json:String)
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(json, "iso-8859-1");
			
			saveFile(filename + "-anim.json", bytes);
		}
		
		public function exportAssetSheet(mc:MovieClip, scale:int)
		{
			var pngName = getQualifiedClassName(mc);
			var bitmapDatas = [];
			var bitmap:Bitmap = new Bitmap();
			var bitmapMinWidth = 0;
			
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var childMC:MovieClip = mc.getChildAt(childId) as MovieClip;
				bitmapDatas.push(bitmapData);
				bitmapMinWidth += childMC.width;
			}
			
			bitmapDatas = bitmapDatas.sortOn("height", Array.NUMERIC | Array.DESCENDING);			
			bitmap.bitmapData = new BitmapData(bitmapMinWidth, bitmapDatas[0].height, true, 0x0);

			matrix = new Matrix();			
			
			for(var bitmapDataId = 0; bitmapDataId < bitmapDatas.length ; ++bitmapDataId)
			{
				var bitmapData:BitmapData = bitmapDatas[bitmapDataId];				
				
				if(bitmapDataId > 0)
				{
					var previousBitmapData:BitmapData = bitmapDatas[bitmapDataId - 1];
					matrix.translate(previousBitmapData.width, 0);
				}

				bitmap.bitmapData.draw(bitmapData, matrix);
			}
			
			var byteArray:ByteArray = PNGEncoder.encode(bitmap.bitmapData);
			saveFile(pngName + "-AssetSheet@" + scale + "x.png", byteArray);
		}
		
		function exportMovieClipFrameAsPNG(mc:MovieClip, frameToExport:int, scale:int = 1)
		{
			mc.gotoAndStop(frameToExport);
			
			var pngName = getQualifiedClassName(mc);
			var bitmapData = getMovieClipBitmapData(mc, frameToExport, scale);
			var byteArray:ByteArray = PNGEncoder.encode(bitmapData);
			
			saveFile(pngName + "-" + frameToExport + "-@" + scale + "x.png", byteArray);
		}
		
		function getMovieClipBitmapData(mc:MovieClip, frameToExport, scale:int)
		{
			/*var bounds = mc.getBounds(mc);
			
			var border:Sprite = new Sprite();			
			border.graphics.lineStyle(2, 0xFF0000);
			border.graphics.moveTo(bounds.x, bounds.y);
			border.graphics.lineTo(bounds.x + bounds.width, bounds.y);
			border.graphics.lineTo(bounds.x + bounds.width, bounds.y + bounds.height);
			border.graphics.lineTo(bounds.x, bounds.y + bounds.height);
			border.graphics.lineTo(bounds.x, bounds.y);
			mc.addChild(border);
			
			trace(mc.name, bounds.width);
			
			var matrix:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			matrix.scale(scale, scale);
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(mc.width * scale, mc.height * scale, true, 0x0));
			bitmap.bitmapData.draw(mc, matrix, null, null, null, true);
			
			return bitmap.bitmapData;*/
		}
		
		function saveFile(path:String, bytes:ByteArray)
		{
			var file = File.applicationDirectory.resolvePath(path);
			var wr = new File(file.nativePath);
			var stream = new FileStream();
			
			stream.open(wr, FileMode.WRITE);
			stream.writeBytes(bytes, 0, bytes.length);
			stream.close();
		}
	}
}