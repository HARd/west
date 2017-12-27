package core {
 
	/**
	 * Преобразует экранные координаты контейнера в flash:1382952379993ометрические и наоботрот
	 * @author HardCoder
	 */
	public class IsoConvert {
		private static const ALPHA:Number = 0.4636476090008062;

		private static const TAN:Number = Math.tan(ALPHA);
		private static const SIN:Number = Math.sin(ALPHA);
		private static const COS:Number = Math.cos(ALPHA);
		/**
		 * Преобразует экранные координаты контейнера в flash:1382952379993ометрические
		 * @param	x - экранная x
		 * @param	y - экранная y
		 * @return	Object(x:isoX, y:0, z:isoZ)
		 */
		public static function screenToIso(x:Number, y:Number, grid:Boolean = false):Object {
			x -= int(Map.mapWidth * 0.5);
			
			var isoX:int = (x * TAN + ((y - x * TAN) * 0.5)) / SIN;
			var isoZ:int = ((y - x * TAN) * 0.5) / SIN;
			
			if(grid){
				isoX = isoX / IsoTile.spacing;
				isoZ = isoZ / IsoTile.spacing;
			}
			
			return {x:isoX, y:0, z:isoZ};
		}
 
		/**
		 * Преобразует flash:1382952379993ометрические координаты в экранные координаты контейнера
		 * @param	isoX - flash:1382952379993ометрическая x
		 * @param	isoZ - flash:1382952379993ометрическая z
		 * @return	Object{x:x, y:y}
		 */
		public static function isoToScreen(isoX:Number, isoZ:Number, grid:Boolean=false, local:Boolean = false):Object {
			//x -= Main.WORLDWIDTH * .5;
			
			if(grid){
				isoX = isoX * IsoTile.spacing;
				isoZ = isoZ * IsoTile.spacing;
			}
			
			var x:int = isoX * (COS) - isoZ * (COS);
			var y:int = isoX * (SIN) + isoZ * (SIN);
			if (local) {
				return {x:x, y:y};
			}else{
				return { x:x + int(Map.mapWidth * 0.5), y:y };
			}
		}
		
		
	}
}