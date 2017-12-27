package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	/**
	 * ...
	 * @author ...
	 */
	public class CrossPlatformUnit extends Walkgolden
	{
		public static var characters:Object;
		public static var character:Object;
		private var url:String;
		public static var FAKESID:int = 460;
		public static var isInit:CrossPlatformUnit;
		public function CrossPlatformUnit(object:Object) {
			url = object.url;
			object['sid'] = FAKESID;
			object['id'] = 1;
			super(object);
			tip = function():Object {
				
				return { text: Locale.__e('flash:1443779795516') };
			}
			isInit = this;
		}
		//override public function setRest():void 
		//{
			////super.setRest();
		//}
		override public function load():void 
		{
			Load.loading(Config.getCross(url), onLoad);
			//super.load();
		}
		//override public function generateRestCount():uint 
		//{
			//return 0;
		//}
		override public function goHome(_movePoint:Object = null):void 
		{
			super.goHome(_movePoint);
		}
		override public function set tribute(value:Boolean):void 
		{
			super.tribute = false;
		}
		override public function onLoad(data:*):void 
		{
			textures = data;
			if ( textures.hasOwnProperty('animation') && textures.animation.hasOwnProperty('animations') && textures.animation.animations.hasOwnProperty('walk'))
				this.info['moveable'] = 1;
			
			super.onLoad(data);
			goHome();
		}
		override public function click():Boolean 
		{
			return false;
			//return super.click();
		}
		//character = "dreams.islandsville.com/resource/swf/Perosnage/super_helper.swf"
		public static function start ():void {
			if ( !App.data.options.hasOwnProperty ('CrossCharacter')) return;
			try {
				characters = JSON.parse(App.data.options.CrossCharacter) as Object;
				for (var keySoc:String in characters) {
					if (App.isSocial(keySoc) && App.map.id == User.HOME_WORLD &&  App.user.mode == User.OWNER) {
						character = characters[keySoc]
						//just for test
							//character.time = App.time + 15;
							//character.duration = 300;
						//
						App.self.setOnTimer(init);
					}
				}
			}catch(e:*) {}
		}
		override public function showIcon():void 
		{
			clearIcon();
			//super.showIcon();
		}
		public static function init ():void {
			
			if ( character.time < App.time && App.time < character.time+ character.duration && !isInit) {
				var object:Object = { };
				var pos:Object	= setPosition ( { onAllMap: 1 } );
				object['x'] = pos.x; /*App.map.heroPosition.x;*/
				object['z'] = pos.z;/* App.map.heroPosition.z;*/
				object['url'] = character.character;
				new CrossPlatformUnit(object);
			}
			if ( App.time > character.time+ character.duration && isInit)
				isInit.uninstall();
		}
		override public function uninstall():void 
		{
			App.self.setOffTimer(init);
			super.uninstall();
		}
		public static function  setPosition ( object: Object):Object {
			var _x:int = object.x;
			var _z:int = object.z;
			var serchSet:int = 100;
			if ( object.hasOwnProperty("radius") && object.radius > 0 ) {
				for (var count:int = 0; count < serchSet; ++count ) {
					_x = int(Math.random() * object.radius  + object.x - object.radius / 2);
					_z = int(Math.random() * object.radius + object.z - object.radius / 2);
					// check free node
					if (App.map._aStarNodes[_x][_z].w == 0 && App.map._aStarNodes[_x][_z].object == null && App.map._aStarNodes[_x][_z].open == 1 && App.map._aStarNodes[_x][_z].isWall == false && App.map._aStarNodes[_x][_z].p == 0) {
						break;
					}
				}
				if (count >= serchSet) {
					for ( count = 0; count < serchSet; ++count ) {
					_x = int(Math.random() * object.radius  + object.x - object.radius / 2);
					_z = int(Math.random() * object.radius + object.z - object.radius / 2);
					// check free node
					if (App.map._aStarNodes[_x][_z].w == 0 && App.map._aStarNodes[_x][_z].object == null  && App.map._aStarNodes[_x][_z].isWall == false && App.map._aStarNodes[_x][_z].p == 0) {
						break;
					}
				}
				}
			}
			if ( object.hasOwnProperty("onAllMap") && object.onAllMap ) { // заданое коичество раз генерируем координаты в квадрате сетки карты с верхней левой точкой в 0 0
				//for (var count:int = 0; count < serchSet; ++count ) {
					var minRadius:int = (Map.cells > Map.rows)? Map.rows:Map.cells;
					var test:Object = setPosition( { x:minRadius/2, z: minRadius/2, radius:minRadius, onAllMap: false } );
					//if ( test.x != 0 || test.z != 0) {
						_x = test.x;
						_z = test.z;
						//break;
					//}
				//}
			}
			object.x = _x;
			object.z = _z
			return object;
		}
	}

}