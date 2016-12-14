package  AnimateArtExporter
{	
	import flash.display.MovieClip;

	public class ArtExporterConfig 
	{
		internal var movieClip:MovieClip;
		internal var padding:uint;
		internal var transparentBackground:Boolean;
		internal var scalesToExport:Array;
		
		public function ArtExporterConfig(mc:MovieClip) 
		{
			movieClip = mc;
			padding = 0;
			transparentBackground = true;
			scalesToExport = [1];
		}
		
		public function withPadding(padding:uint)
		{
			this.padding = padding;
			return this;
		}
		
		public function withTransparentBackground(isTransparent:Boolean)
		{
			this.transparentBackground = isTransparent;
			return this;
		}
		
		public function withScales(_scalesToExport:Array)
		{
			this.scalesToExport = _scalesToExport;
			return this;
		}
	}
}
