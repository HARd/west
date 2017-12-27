package buttons 
{
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import silin.filters.ColorAdjust;	
	
	public class ChangedButton extends Button
	{

		var textfilterActive:GlowFilter
		/**
		 * Конструктор
		 * @param	settings	пользовательские настройки кнопки
		 */
		public function ChangedButton(settings:Object = null)
		{
			super(settings)
			createTextfilterActive()
		}
		function createTextfilterActive()
		{
			textfilterActive = new GlowFilter(settings.fontBorderColorActive, 1, settings.fontBorderSize, settings.fontBorderSize, 10, 1);
		}
		
		public override function disable() {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(0);
			this.filters = [mtrx.filter];
			//this.mouseChildren = false;
		}
		
		public override function enable() {
			this.filters = [];
			this.mouseChildren = true;
			
			effect(0, 1);
			style.color = settings.fontColor; 
			textLabel.setTextFormat(style)
			textLabel.filters = [textFilter]
		}
		
		public override function active() {
			
			style.color = settings.fontColorActive; 
			textLabel.setTextFormat(style)
			textLabel.filters = [textfilterActive]
			effect( -0.2, 0);
		}
		
		protected override function MouseOver(e:MouseEvent) {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
			
		}
		
		protected override function MouseOut(e:MouseEvent) {			
			if(mode == Button.NORMAL){
				effect(0,1);
			}
		}
		
	}

}