package buttons 
{
	import flash.events.MouseEvent;
	import silin.filters.ColorAdjust;
	/**
	 * ...
	 * @author 
	 */
	public class SimpleButton extends LayerX
	{
		
		public function SimpleButton() 
		{
			addListeners();
		}
		
		private function addListeners():void 
		{
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		public function onOut(e:MouseEvent):void 
		{
			effect(0, 1);
		}
		
		public function onOver(e:MouseEvent):void 
		{
			effect(0.1);
		}
		
		public function effect(count:Number, saturation:Number = 1):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(count);
			this.filters = [mtrx.filter];
		}
		
		public function dispose():void
		{
			removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
	}

}