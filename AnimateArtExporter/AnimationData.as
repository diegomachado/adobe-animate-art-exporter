package AnimateArtExporter
{
	import AnimateArtExporter.FileExporter;
	import flash.display.MovieClip;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.getQualifiedClassName;
	
	public class AnimationData
	{
		public function export(sourceMC:MovieClip)
		{
			var animationsData = extractEntityData(sourceMC);
			
			var animationsJSON = JSON.stringify(animationsData, function(k, v)
			{
				if(k == "colorMatrix")
				{
					var arrayString = JSON.stringify(v)
					return arrayString.slice(1, arrayString.length - 1);
				}
				
				return v;
			}, 2);
			
			FileExporter.ExportJSON(animationsJSON, getQualifiedClassName(sourceMC) + "-AnimationData");
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
				var childMC = mc.getChildAt(childId);
			
				if(childMC is MovieClip)
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
	}
}