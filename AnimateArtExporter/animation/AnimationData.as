package AnimateArtExporter.animation
{
	import AnimateArtExporter.utils.FileExporter;

	import flash.display.MovieClip;
	import flash.filters.ColorMatrixFilter;
	import flash.utils.getQualifiedClassName;
	
	public class AnimationData
	{
		public function export(sourceMC:MovieClip, spritesheetData:Object)
		{			
			var animationsData = getEntityData(sourceMC);		
			
			animationsData.entityName = getQualifiedClassName(sourceMC);
			animationsData.animationName = sourceMC.currentLabel;
			animationsData.totalFrames = sourceMC.totalFrames;
			
			formatChildrenSpriteSheetData(animationsData, spritesheetData);
			formatChildrenDataToSprites(animationsData);
			
			var animationsJSON = JSON.stringify(animationsData, formatAnimationJSON, 2);
			FileExporter.ExportJSON(animationsJSON, getQualifiedClassName(sourceMC) + "-AnimationData");
		}
		
		function formatChildrenSpriteSheetData(animationsData:Object, spritesheetData:Object)
		{
			for(var animationName in spritesheetData)
			{
				for(var spriteId in spritesheetData[animationName])
				{
					if(animationsData.children[spriteId] != null)
					{
						animationsData.children[spriteId].spritesheet = {};
						animationsData.children[spriteId].spritesheet.frameIds = spritesheetData[animationName][spriteId];
						animationsData.children[spriteId].spritesheet.totalFrames = spritesheetData[animationName][spriteId].length;
					}
				}
			}
		}
		
		function formatChildrenDataToSprites(animationsData:Object)
		{
			animationsData.sprites = [];
			
			for each(var child in animationsData.children)
				animationsData.sprites.push(child);
			
			delete animationsData.children;
		}
		
		function getEntityData(mc:MovieClip)
		{
			var data = {};
			data.children = {};
			
			for(var frameId = 0; frameId < mc.totalFrames; ++frameId)
			{
				mc.gotoAndStop(frameId);
				getChildrenData(mc, data.children);
			}
			
			return data;
		}
		
		function getChildrenData(mc:MovieClip, childrenData:Object)
		{
			for(var childId = 0; childId < mc.numChildren; ++childId)
			{
				var childMC = mc.getChildAt(childId);
				
				if(childMC is MovieClip)
				{
					var childName = childMC.name;
					
					if(childrenData[childName] == null)
					{
						childrenData[childName] = {};
						childrenData[childName].name = childName;
						childrenData[childName].frames = [];
					}
					
					childrenData[childName].frames.push(getMovieClipProperties(childMC));
					
					if(childMC.numChildren > 0)
						getChildrenData(childMC, childrenData);
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
		
		function formatAnimationJSON(key, value)
		{
			if(key == "colorMatrix")
			{
				var arrayString = JSON.stringify(value)
				return arrayString.slice(1, arrayString.length - 1);
			}
			
			return value;
		}
	}
}