package  
{
	import core.Post;
	import flash.display.Sprite;
	import units.Unit;
	import units.Hero;
	import units.Personage;
	import wins.SimpleWindow;

	public class Owner extends Sprite
	{
		
		public var id:String = '0'; 
		public var worldID:int = 1; 
		public var aka:String = ""; 
		public var sex:String = "m"; 
		public var first_name:String; 
		public var last_name:String; 
		public var photo:String; 
		public var level:uint = 1; 
		public var worlds:Object = { }; 
		public var world:World; 
		public var friends:Friends; 
		public var stock:Stock = null;
		public var lastvisit:uint;
		public var createtime:uint;
		public var energy:uint = 0;
		public var restore:int; 
		public var units:Object; 
		public var wishlist:Array = []; 
		public var maps:Object = {}; 
		public var shop:Object = {}; 
		public var money:int = 0; 
		public var pay:int = 0;
		
		public var hero:Hero;
		public var head:uint = 0;
		public var body:uint = 0;
		public var day:uint = 0;
		public var year:uint = 0;
		public var bonus:uint = 0;
		public var _6wbonus:Array = [];
		
		public var ref:String = "";
		
		public function Owner(friend:Object, _worldID:int = 112){
			
			this.id = friend.uid;
			
			aka 		= friend.aka;
			first_name 	= friend.first_name;
			last_name 	= friend.last_name;
			sex 		= friend.sex;
			photo		= friend.photo;
			level		= friend.level;
			
			if (friend.wID == null) {
				worldID = _worldID;
			}
			
			/*if(friend.wID == undefined){
				for (var sID:* in App.data.storage) {
					var item:Object = App.data.storage[sID];
					if (item.type == 'Dreams' && item.started) {
						worldID = sID;
						break;
					}
				}
			}*/
			
			if (id == '1') 
				worldID = User.MERRY_WORLD;
				//worldID = 228;
				//worldID = 359;
				
			
			
			Post.send( {
				'ctr':'user',
				'act':'state',
				'uID':id,
				'wID':worldID,
				'fields':JSON.stringify(['world', 'user']),
				'visited':App.user.id
			}, onLoad);
			
			
		}
		
		public function onLoad(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				//Обрабатываем ошибку
				return;
			}
			
			units = data.units;
			world = new World(data.world);
			
			for (var properties:* in data.user)
			{
				if (properties == 'friends') 
					continue;
				//this[properties] = data.user[properties];
			}
			
			if (head == 0)
			{
				if (sex == 'm')
					head = User.BOY_HEAD;
				else
					head = User.GIRL_HEAD;
			}
			
			if (body == 0)
			{
				if (sex == 'm')
					body = User.BOY_BODY;
				else
					body = User.GIRL_BODY;
			}
			
			if (data.user.hasOwnProperty('worlds')) {
				for each(var _wID:* in data.user.worlds) {
					worlds[_wID] = int(_wID);
				}
			}
			//worldID = User.HOME_WORLD;
			//TODO инициализируем зависимые объекты
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_OWNER_COMPLETE));
			
		}
		
		public function addPersonag():void {
			// добавляем персонажа
			hero = new Hero(this, { id:8, sid:Personage.HERO, x:12, z:16, ava:true } );
			Unit.sorting(hero);
			
			//Не показываем персонажа бота
			if (this.id == '1') {
				hero.visible = false;
			}
		}
		
		public function showMessage():void {
			if (App.user.quests.data['78'] != null && App.user.quests.data['74'].finished > 0) {
				if (App.user.quests.data['93'] == null || App.user.quests.data['93'].finished == 0) {
					new SimpleWindow( {
						label:SimpleWindow.ATTENTION,
						title:Locale.__e("flash:1382952379699"),
						text:Locale.__e('flash:1382952379742'),
						height:400
					}).show()
				}
			}
			
			
		}
	}
}