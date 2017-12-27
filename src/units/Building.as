package units 
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.UnitIcon;
	import wins.BarterWindow;
	import wins.ConstructWindow;
	import wins.SpeedWindow;
	import wins.StockWindow;

	import ui.Hints;
	import ui.Cursor;
	import wins.ProductionWindow;
	import wins.SimpleWindow;
	import wins.Window;
	
	public class Building extends AUnit
	{
		public static const BUILD:String = 'build';
		public static const BOOST:String = 'boost';
		
		public var level:uint 		= 0;
		public var totalLevels:uint = 0;
		public var formula:Object;
		public var fID:uint			= 0;
		public var crafted:uint		= 0;
		public var instance:uint	= 1;
		public var helpers:Object	= { };
		public var alwaysAnimated:Array = [422];		// Постоянная анимация при окончании постройки
		public var hasProduct:Boolean = false;
		
		public var _crafting:Boolean = false;
		public var gloweble:Boolean = false;
		
		public var hasBuilded:Boolean = false;
		public var hasUpgraded:Boolean = false;
		
		public var upgradedTime:int;
	
		public var hasPresent:Boolean = false;
		
		public var completed:Array	= [];			// Завершенные крафты
		public var began:int 		= 0;
		public var queue:Array = [];
		public var openedSlots:int;
		
		public var isBaloon:Boolean = false;
		
		public var totalLimit:int = 0;
		public var climit:int = -1;
		public var attachedToTerritory:int = 0;
		public var sameBuildings:Array = [];
		
		public var parentBuilding:* = null;
		private var singleAnimation:Boolean = true;
		
		public function Building(object:Object)
		{	
			//if(layer == null)
			layer = object.layer || Map.LAYER_SORT;
			
			helpers = object.helpers || { };
			
			if (object.hasOwnProperty('climit') && object.sid != 86) {
				totalLimit = object.climit.max;
				climit = object.climit.cur;
			}
			
			if (object.sid == 3160)
				trace();
			
			if (object.hasOwnProperty('level'))
				level = object.level;
			else
				addEventListener(AppEvent.AFTER_BUY, onAfterBuy);
			
			info = App.data.storage[object.sid];
			
			if (info.hasOwnProperty("anim1") && info.sid == 3082)
			{
				//if (info.sid == 3082)
					//trace();
				singleAnimation = info.anim1;
			}
			
			if (object['fromStock'] && info.type == 'Building') {
				for (var lvl:String in App.user.stock.data[object.sid]) {
					if (App.user.stock.data[object.sid][lvl] == 0) continue;
					level = int(lvl); 
				}
			}
			
			super(object);
			
			checkAttach();
			
			touchableInGuest = true;
			if (formed && (sid == 88 || sid == 637)) {
				removable = false;
				moveable = false;
				rotateable = false;
			}
			
			if ([84,87,88,278,281,282,419,422,538,543,630,637,780,898,952,2014,2419,2415,2421,2420].indexOf(int(sid)) != -1) {
				removable = false;
			}
			
			if (sid == 780 || sid == 952) {
				moveable = false;
				rotateable = false;
			}
			
			setCraftLevels();
			
			if (info.devel) {
				for each(var obj:* in info.devel.req) {
					totalLevels++;
				}
			}
			
			if (formed && sid == 533) {
				moveable = false;
				removable = false;
				rotateable = false;
				if (level == totalLevels){
					touchable = false;
					clickable = false;
				}
			}
			
			//if (level == totalLevels && info.type == 'Building' && attachedToTerritory == 0)
				//stockable = true;
			
			/*if ([1950, 1961, 1952].indexOf(int(sid)) != -1) {
				stockable = false;
			}*/
				
			if (componentable || sid == 1596 || sid == 1950 || sid == 1952 || sid == 1961) {
				removable = false;
				stockable = false;
				rotateable = true;
				moveable = true;
				
				if (!object.fromStock && sid == 1596)
					moveable = false;
			}
			
			if (sid == 1970)
				stockable = false;
			
			var comps:Object = Storage.componentsGet(App.map.id, sid);
			if (comps.hasOwnProperty(id)) {
				if (comps[id] == 1) {
					stockable = false;
					removable = false;
				}
				
				visible = Boolean(comps[id]);
			}
			
			initProduction(object);
			
			if (object.hasOwnProperty("slots")) {
				openedSlots = object.slots;
			}else {
				for each(var slot:* in info.slots) {
					if (slot.status == 1) {
						openedSlots++;
					}
				}
			}
			
			upgradedTime = object.upgrade;
			created = object.created;
			
			if (formed) {
				
				hasBuilded = true;
				hasUpgraded = true;
				
				if(upgradedTime > 0){
					hasUpgraded = false;
					upgraded();
					if (!hasUpgraded) {
						App.self.setOnTimer(upgraded);
						addEffect(Building.BUILD);
					}	
				}
			}
			
			/*if (level >= totalLevels && sid == 780 && !train) {
				addTrain();
			}*/
			
			load();
			showIcon();
			
			tip = function():Object 
			{
				/*if (sid == 780) {
					return {
						title:Locale.__e('flash:1429185230673')
						//text:info.description
					};
				}*/
				if (App.user.mode == User.GUEST)
				{
					return {
						title:info.title,
						text:info.description
					};
				}
				if (sid == 668 || sid == 738 || sid == 749 || sid == 1010) {
					return {
						title:info.title,
						text:info.description
					};
				}
				if (hasProduct) {
					var text:String = '';
					/*for (var i:int = 0; i < completed.length; i++ ) {
						if (text.length > 0) text += ', ';
						text += App.data.storage[getFormula(completed[i]).out].title;
					}*/
					if (formula)
						text = App.data.storage[formula.out].title;
					
					return {
						title:info.title,
						text:Locale.__e("flash:1382952379845", [text]),
						timer:false
					};
				} else if (created > 0 && !hasBuilded) {
					return {
						title:info.title,
						text:Locale.__e('flash:1395412587100') +  '\n' + TimeConverter.timeToStr(created-App.time),
						timer:true
					}
				} else if (upgradedTime > 0 && !hasUpgraded) {
					return {
						title:info.title,
						text:Locale.__e('flash:1395412562823') +  '\n' + TimeConverter.timeToStr(upgradedTime-App.time),
						timer:true
					}
				} else if (crafting) {
						return {
						title:info.title,
						text:Locale.__e(Locale.__e('flash:1395853416367') +  '\n' + TimeConverter.timeToStr(crafted-App.time)),
						timer:true
					}
				}
				
				var defText:String = '';
				var prevItm:String;
				var cnt:int = 0;
				if (this.info.type == 'Building') {
					if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
						for (var itm:String in this.info.devel.craft[totalLevels]) {
							if (cnt == 5) {
								defText += ' ' + Locale.__e('flash:1459931239335');
								break;
							}
							if (App.data.crafting[this.info.devel.craft[totalLevels][itm]])
							{
								if (prevItm && prevItm == App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title) continue;
								if (!User.inUpdate(App.data.crafting[this.info.devel.craft[totalLevels][itm]].out)) continue;
								if (defText.length > 0) defText += ', ';
								defText += App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title;
								prevItm = App.data.storage[App.data.crafting[this.info.devel.craft[totalLevels][itm]].out].title;
								
								cnt++;
							}
						}
					}
				}
				
				if (defText.length > 0) {
					return {
						title:info.title,
						text:Locale.__e('flash:1404823388967', [defText]),
						timer:false
					};
				} else {
					return {
						title:info.title,
						text:info.description
					};
				}
				
			}
			
			if (!formed && info.base == 1) {
				showHelp(Locale.__e('flash:1435843230961'));
			}
			
			if (App.data.options.hasOwnProperty('Aerostats')) {
				var baloons:Object = JSON.parse(App.data.options.Aerostats);
				if (baloons.hasOwnProperty(sid))	isBaloon = true;
			}			
		}
		
		public function getBonus(bonus:Object = null):void {
			if (!bonus) return;
			Treasures.bonus(bonus, new Point(this.x, this.y));
		}
		
		private function checkAttach():void {
			var worlds:Array = [];
			for (var land:* in App.data.storage) {
				var itm:Object = App.data.storage[land];
				if (itm.type == 'Lands') {
					worlds.push(land);
				}
			}
			for (var id:int = 0; id < worlds.length; id++)
			{	
				var world:Object = App.data.storage[worlds[id]];
				if (!world.hasOwnProperty('stacks')) continue;
				for (var bSID:String in world.stacks) {
					if (sid == world.stacks[bSID]) {
						attachedToTerritory = worlds[id];
						return;
					}
				}
			}
		}
		
		private static const sizes:Object = { "90":1, '180':3, '240':5, '320':6 };
		private static const padding:uint = 3;
		private static const fontSize:uint = 17;
		private static var textLabel:TextField;
		private var prompt:Sprite = new Sprite();
		private function showHelp(text:String):void {
			var iconScale:Number;
			
			var text:String = text;
			var sprite:Sprite;
			
			for (var w:String in sizes) {
				var textWidth:int = int(w);
				var lineCount:int = Math.round((text.length * fontSize) / textWidth);
			}
			textLabel = Window.drawText("", {
				color:0x413116,
				multiline:true,
				border:false,
				fontSize:fontSize,
				textLeading:-5
			});
			
			textLabel.wordWrap = true;
			textLabel.text = text;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.width = textWidth;
			

			var maxWidth:int = Math.max(textLabel.textWidth) + padding * 2;
			textLabel.width = maxWidth + 5;
			
			var maxHeight:int = textLabel.height + 10;
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(maxWidth + padding * 2, maxHeight + padding, (Math.PI / 180) * 90, 0, 0);
			
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xeed4a6, 0xeed4a6], [1, 1], [0, 255], matrix);  //[0xe9e0ce, 0xd5c09f]
			shape.graphics.drawRoundRect(0, 0, maxWidth + padding * 2, maxHeight + padding, 15);
			shape.graphics.endFill();
			shape.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			shape.alpha = 0.8;
			prompt.addChild(shape);
			
			textLabel.x = padding;
			//textLabel.y = titleLabel.height;
			
			if (sprite) {
				prompt.addChild(sprite);
			}
			
			textLabel.y = padding;
			
			prompt.addChild(textLabel);
			
			this.x -= 20;
			
			this.addChild(prompt);
		}
		
		public function getFormula(fID:*):Object {
			return (App.data.crafting[fID] != null) ? App.data.crafting[fID] : null;
		}
		
		public function initProduction(object:Object):void {
			
			if (object.hasOwnProperty('fID')) {
				
				/*var willCrafted:int;
				
				if (object.fID is Number && getFormula(object.fID) && object.crafted) {
					formula = getFormula(object.fID);
					fID = object.fID;
					began = object.crafted - formula.time;
					crafted = object.crafted;
					queue.push( {
						order:		0,
						fID:		object.fID,
						crafted:	crafted
					});
					
					willCrafted = crafted;
					
					checkProduction();
				}else if (typeof(object.fID) == 'object') {
					queue = [];
					willCrafted = object.crafted;
					for (var id:String in object.fID) {
						
						if(id != "0")
							willCrafted += getFormula(object.fID[id]).time;
							
						queue.push( {
							order:		int(id),
							fID:		object.fID[id],
							crafted:	willCrafted//_crafted
						});
					}
					queue.sortOn('order', Array.NUMERIC);
					
					checkProduction();
				}*/
				
				queue = [];
				
				//if (object.hasOwnProperty('crafted') && object.crafted > 0) {
					//queue.push( {
						//order:		int(id),
						//fID:		object.c,
						//crafted:	object.crafted
					//});
					//queue.sortOn('order', Array.NUMERIC);
				//}
				crafted = object.crafted;
				fID = object.fID;
				
				checkProduction();
			}
			
			if (Map.ready)
				setTechnoesQueue();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, setTechnoesQueue);
			
		}
		
		private function setTechnoesQueue(e:AppEvent = null):void  {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, setTechnoesQueue);
			if (App.user.mode == User.OWNER && getFormula(fID) != null && crafted > App.time) {
				var technosForWork:* = Techno.findTechnosForCraft(fID, crafted - formula.time);
				if (technosForWork is Array) {
					Techno.setBusy(technosForWork, this, crafted);
				}
			}
		}
		
		public function checkProduction():void {
			completed = [];
			crafting = false;
			
				if(crafted >0){
					if (crafted <= App.time) {
						hasProduct = true;
						formula = getFormula(fID);
						showIcon();
					}else {
						beginCraft(fID, crafted);
					}
				}
			
			/*if (!crafting) {
				began = 0;
				stopAnimation();
			}else {
				initAnimation();
				startAnimation();	
			}*/
			
			checkOnAnimationInit();
		}
		
		/*public function checkTechnoNeed(isUpgrade:Boolean = false):void
		{
			var req:Object;
			
			req = info.devel.obj[level + 1];
			
			for (var itm:* in req) {
				if (itm == Techno.TECHNO) {
					needTechno = req[itm];
					break;
				}
			}	
			
			if (needTechno <= 0) return;
			
			if (Map.ready)
				rentTechno();
			else
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete)
		}*/
		
		/*private function onMapComplete(e:AppEvent):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete)
			rentTechno();
		}*/
		
		public function load():void {
			
			// Прервать загрузку если является не основным компонентом
			var components:Object = Storage.componentsGet(App.map.id, sid);
			if (components.hasOwnProperty(id) && components[id] == 0) return;
			
			
			if (textures) {
				stopAnimation();
				textures = null;
			}
			
			var view:String = info.view;
			if (info.hasOwnProperty('start') && level == 0) {
				level = info.start;
			}
			
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('req')) {
				var viewLevel:int = level;
				while (true) {
					if (info.devel.req.hasOwnProperty(viewLevel) && info.devel.req[viewLevel].hasOwnProperty('v') && String(info.devel.req[viewLevel].v).length > 0) {
						if (info.devel.req[viewLevel].v == '0') {
							if (viewLevel > 0) {
								viewLevel --;
							}else {
								break;
							}
						} else {
							view = info.devel.req[viewLevel].v;
							break;
						}
					}else if (viewLevel > 0) {
						viewLevel --;
					}else {
						break;
					}
				}
			}
			Load.loading(Config.getSwf(type, view), onLoad);
		}
		
		public function componentAddAction():void {
			if (Storage.componentSet(App.map.id, this)) {
				visible = false;
			}
		}
		
		public function isBuilded():Boolean 
		{
			if (created == 0) return false;
			
			var curLevel:int = level + 1;
			if (curLevel >= totalLevels) curLevel = totalLevels;
			if (created <= App.time) {
				if (level == 0) level = 1;
				hasBuilded = true;
				return true;
			}
			
			return false;
		}
		
		public function build():void {
			//updateProgress(created - info.devel.req[level+1].t, created);

			if (isBuilded()){
				App.self.setOffTimer(build);
				showIcon();
				hasPresent = true;
				updateLevel();
				fireTechno();
				hasUpgraded = true;
				onBuildComplete();
			}
		}
		
		public function onBuildComplete():void {
			//
		}
		
		public function isUpgrade():Boolean 
		{
			if (upgradedTime <= App.time) {
				hasUpgraded = true;
				//moveable = true;
				return true;
			}
			
			return false;
		}
		
		public function upgraded():void {
			
			if (isUpgrade()){
				App.self.setOffTimer(upgraded);
				
				if (!hasUpgraded) {
					instance = 1;
					created = App.time + info.devel.req[1].t;
					App.self.setOnTimer(build);
					addEffect(Building.BUILD);
				}else {
					hasUpgraded = true;
					hasPresent = true;
					this.level++;
					if (fromStock) {
						if ((this is Tribute) && sid != 402 && sid != 1580 && sid != 1624) {
							hasUpgraded = false;
							hasPresent = false;
							this.level = 0;
							if ([1275, 1276, 1277, 1278].indexOf(sid) != -1) {
								hasUpgraded = true;
								hasPresent = true;
								this.level = this.totalLevels;
							}
						} else if ((this is Floors) ||  this.sid == 303) {
							hasPresent = false;
							this.level = 0;
						} else if (this is Mfield) {
							this.level = this.totalLevels - 1;
						}else if (!(this is Hut) && !(this is Garden)) {
							this.level = this.totalLevels;
						} else if (this.sid == 752 && currentHutLevel > 0) {
							this.level = currentHutLevel;
							currentHutLevel = -1;
						}
					}
					if (this.level > this.totalLevels) this.level = this.totalLevels;
					checkAttach();
					//if (this.level == this.totalLevels && info.type == 'Building' && attachedToTerritory == 0 && [1970].indexOf(sid) == -1) stockable = true;
					if (this.level == this.totalLevels && info.type == 'Tribute' && !componentable && [1596, 1580, 1624, 1580, 1624,1094,1761,1961,1952,2418].indexOf(sid) == -1) stockable = true;
					finishUpgrade();
					load();
					fireTechno();
					fromStock = false;
					
					if (sid == 1596 && level >= totalLevels) {
						removable = false;
						stockable = false;
						rotateable = false;
						moveable = false;
					}
				}
			}
		}		
		
		override public function moveAction():void {
			super.moveAction();
			addGround();
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			super.onBuyAction(error, data, params);
			
			Storage.instanceAdd(sid);
			
			showIcon();
			
			if (info.devel && (info.type == 'Building' || info.type == 'Barter')) {
				openConstructWindow();
			}
			
			var dt:Object;
			if ([738,749,797,815,816,817,835,935,980,981,982,1302,1845,1868,1658,2201,2371,2641,2642,2732].indexOf(int(sid)) != -1) {
				dt = App.user.storageRead('building_' + sid, 0);
				dt += 1;
				App.user.storageStore('building_' + sid, dt, true);
			}
			
			if (['Fatman'].indexOf(info.type) != -1) {
				dt = App.user.storageRead('building_' + sid, 0);
				dt += 1;
				App.user.storageStore('building_' + sid, dt, true);
			}
		}
		
		
		
		
		public function onAfterBuy(e:AppEvent):void
		{
			if(textures != null){
				var levelData:Object = textures.sprites[this.level];
				removeEventListener(AppEvent.AFTER_BUY, onAfterBuy);
				App.ui.flashGlowing(this, 0xFFF000);
				addGround();
			}
			
			hasUpgraded = true;
			hasBuilded = true;
			
			if (prompt) prompt.visible = false;
			
			//Делаем push в _6e
			if (App.social == 'FB') {
				ExternalApi.og('place','building');
			}
			
			SoundsManager.instance.playSFX('building_1');
		}
		
		override public function onLoad(data:*):void {
			
			if (sid == 3160)
				trace();
			
			super.onLoad(data);
			textures = data;
			updateLevel();
			
			if (formed && sid == 533) {
				moveable = false;
				removable = false;
				rotateable = false;
				if (level == totalLevels){
					touchable = false;
					clickable = false;
				} else {
					framesType = 'techno';
					startAnimation();
				}
			}
			
			countBounds('', usedStage);
			iconSetPosition();
			
			if (!formed) {
				if (prompt) prompt.x += 30;
			} else {
				if (prompt) prompt.visible = false;
			}
			
			if (App.data.options.hasOwnProperty('Aerostats')) {
				var baloons:Object = JSON.parse(App.data.options.Aerostats);
				if (baloons.hasOwnProperty(sid))	isBaloon = true;
			}
			if (animationContainer && isBaloon && info.type != 'Golden') {
				animationContainer.visible = false;
			}
			
			if (textures.hasOwnProperty('animation') && textures.animation.animations.hasOwnProperty('idle')) {
				framesType = 'idle';
				startAnimation();
			}
		}
		
		private var usedStage:int = 0;
		public function updateLevel(checkRotate:Boolean = false, mode:int = -1):void 
		{
			if (textures == null) return;
			if (sid == 3175)
				trace();
			var levelData:Object;
			if (this.level && info.devel && info.devel.req.hasOwnProperty(this.level) && info.devel.req[this.level].hasOwnProperty("s") && textures.sprites[info.devel.req[this.level].s]) {
				usedStage = info.devel.req[this.level].s;
			}else if (textures.sprites[this.level]) {
				usedStage = this.level;
			}else if (textures.sprites[this.level-1]) {
				usedStage = this.level-1;
			}
			if (!singleAnimation)
			{
				if(textures.sprites[level])
						levelData = textures.sprites[level];
					else
						levelData = textures.sprites[level-1];
			}
			else
				levelData = textures.sprites[usedStage];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (this.level != 0 && gloweble)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0xFFF000);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
				
				gloweble = false;
			}
			
			if (crafted > 0 && crafted > App.time && isBaloon && info.type != 'Golden' && info.type != 'Pethouse') {
				levelData = textures.sprites[2];
				if (animationContainer) animationContainer.visible = false;
			}
			
			if (levelData) draw(levelData.bmp, levelData.dx, levelData.dy);
			
			/*if (level >= totalLevels)*/ addGround();
			
			/*if (level >= totalLevels && sid == 780 && !train) {
				addTrain();
			}*/
			
			checkOnAnimationInit();
		}
				
		public var ground:Bitmap;
		public function addGround():void {
			if (!formed) return;
			if (textures && textures.hasOwnProperty('ground')) 
			{
				if (!ground) {
					ground = new Bitmap(textures.ground.bmp);
					App.map.mLand.addChildAt(ground, 0);
				}
				
				ground.scaleX = scaleX;
				ground.x = this.x + textures.ground.dx - ((rotate) ? (textures.ground.dx * 2) : 0);
				ground.y = this.y + textures.ground.dy;
			}
		}
		
		public function removeGround():void {
			if (!formed) return;
			if (ground) {
				App.map.mLand.removeChild(ground);
				ground = null;
			}
		}
		
		public function checkOnAnimationInit():void {			
			if (textures && textures['animation'] && level > totalLevels - craftLevels) {
				initAnimation();
				
				if (crafted > 0 || alwaysAnimated.indexOf(sid) != -1) {
					beginAnimation();
				}else{
					finishAnimation();
				}
				
				//checkAndDrawFirstFrame();
			}
			
			if (textures && textures['animation'] && textures.animation.animations.hasOwnProperty('idle')) {
				initAnimation();		
				framesType = 'idle';
				startAnimation();
				checkAndDrawFirstFrame();
			}
			
			if (!singleAnimation && textures && textures['animation'] && textures.animation.animations.hasOwnProperty('sleep') && !crafting && level >= totalLevels) {
				initAnimation();		
				framesType = 'sleep';
				startAnimation();
				checkAndDrawFirstFrame();
			}
		}
		
		override public function startAnimation(random:Boolean = false):void
		{
			if (animated) return;
			visibleAnimation = false;
			for each(var name:String in framesTypes) {
				
				multipleAnime[name]['length'] = textures.animation.animations[name].chain.length;
				if(singleAnimation)
					multipleAnime[name].bitmap.visible = true;
				else
				{
					if(framesType == name)
						multipleAnime[name].bitmap.visible = true;
					else
						multipleAnime[name].bitmap.visible = false;
				}
				multipleAnime[name]['frame'] = 0;
				if (random) {
					multipleAnime[name]['frame'] = int(Math.random() * multipleAnime[name].length);
				}
			}
			
			App.self.setOnEnterFrame(animate);
			animated = true;
		}
		
		private function swap():void {
			uninstall();
			Post.send({
				'ctr':'building',
				'act':'swap',
				'uID':App.user.id,
				'wID':App.user.worldID,
				'sID':780,
				'id':this.id,
				'tID':794
			}, function(error:*, response:*, params:*):void {
				if (!error) {
					var newBuild:Building = new Tstation( { id:response.id, sid:794, level:0, x:coords.x, z:coords.z } );
				}
			});
			return;	
		}
		
		public var cantClick:Boolean = false;
		public var helpTarget:int = 0;
		override public function click():Boolean 
		{
			info
			if (sid == 780) {
				//if (!App.isSocial('FB','NK','HV')) {
					if(App.user.mode == User.OWNER)
						swap();
					else 
						guestClick();
				//} else {
					//new SimpleWindow( {
						//label:SimpleWindow.ATTENTION,
						//title:Locale.__e("flash:1429185188688"),
						//text:Locale.__e('flash:1429185230673'),
						//height:300
					//}).show();
				//}
				return true;
			}
			
			Cursor.accelerator = false;
			if (StockWindow.accelMaterial != 0 && crafted > 0 && crafted > App.time) {
				if (StockWindow.accelUnits.length > 0) {
					var boost:Boolean = false;
					for each (var build:* in StockWindow.accelUnits) {
						if (build.sid == this.sid) boost = true;
					}
					if (boost) {
						onBoostMaterialEvent(0, StockWindow.accelMaterial);
						if (StockWindow.accelUnits) {
							for each (var unit:* in StockWindow.accelUnits) {
								unit.hideGlowing();
							}
							StockWindow.accelUnits = [];
							StockWindow.accelMaterial = 0;
						}
					}
				}
			}
			
			if (cantClick)
				return false;
			
			if (App.user.mode == User.GUEST) {
				guestClick();
				return true;
			}
			
			var ufind:* = null;
			switch (sid) {
				case 2421:
					ufind = Map.findUnit(2420, 1);
					if (!ufind || ufind.level >= ufind.totalLevels) {
						ufind = null;
					}
					break;
				case 2415:
					ufind = Map.findUnit(2421, 2);
					if (!ufind || ufind.level >= ufind.totalLevels) {
						ufind = null;
					}
					break;
				case 2419:
					ufind = Map.findUnit(2415, 4);
					if (!ufind || ufind.level >= ufind.totalLevels) {
						ufind = null;
					}
					break;
			}
			
			if (ufind) {
				new SimpleWindow( {
					popup:true,
					title:Locale.__e('flash:1382952380254'),
					text:Locale.__e('flash:1470053117007'),
					confirm:function():void {
						App.map.focusedOn(ufind, true);
					}
				}).show();
				return false;
			}
			
			if (!super.click() || this.id == 0) return false;
			
			if (!isReadyToWork()) return true;
			
			if (isPresent()) return true;
			
			if (isProduct()) return true;
			
			if (climit >= totalLimit && crafted <= App.time) {
				new SimpleWindow( {
					label:SimpleWindow.ATTENTION,
					title:Locale.__e("flash:1429185188688"),
					text:Locale.__e('flash:1452679157687'),
					height:300
				}).show();
				return false;
			}
			
			if (openConstructWindow()) return true;	
			
			openProductionWindow();
			
			return true;
		}
		
		public function openConstructWindow():Boolean 
		{
			
			if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1))
			{
				if (App.user.mode == User.OWNER)
				{
					if (hasUpgraded)
					{
						if (!componentBuildable)
							return true;
						
						new ConstructWindow( {
							title:			info.title,
							upgTime:		info.devel.req[level + 1].t,
							request:		info.devel.obj[level + 1],
							reward:			null,
							target:			this,
							win:			this,
							onUpgrade:		upgradeEvent,
							hasDescription:	true,
							height: 600
						}).show();
						
						return true;
					}
				}
			}
			return false;
		}
		
		private var guestDone:Boolean = false;
		public function guestClick():void 
		{
			
			if (guestDone) return;
			
			if(App.user.addTarget({
				target:this,
				near:true,
				callback:onGuestClick,
				event:Personage.HARVEST,
				jobPosition:getContactPosition(),
				shortcut:true
			})) {
				ordered = true;
				//убрать ExpIcon
				clearIcon();
			}else {
				ordered = false;
			}
		}
		
		public function onGuestClick():void {
			if (App.user.friends.takeGuestEnergy(App.owner.id)) {
				
				guestDone = true;
				
				var that:* = this;
				Post.send({
					ctr:'user',
					act:'guestkick',
					uID:App.user.id,
					sID:this.sid,
					fID:App.owner.id
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}	
					if (data.hasOwnProperty("bonus")){
						spit(function():void{
							clearIcon();
							getBonus(data.bonus);
						}, bitmapContainer);
					}
					ordered = false;
					
					if (data.hasOwnProperty('energy')) {												//
						if(App.user.friends.data[App.owner.id].energy != data.energy){					//
							App.user.friends.data[App.owner.id].energy = data.energy;					//
							App.ui.leftPanel.update();													//test
						}																				//
					}																					//
					App.user.friends.giveGuestBonus(App.owner.id);										//
				});
			}else {
				showIcon();
				ordered = false;
			}
		}
		
		//public var sendPresent:Boolean = false;
		public function isPresent():Boolean
		{
			if (hasPresent /*&& !sendPresent*/) {
				hasPresent = false;
				//if (sid == 3025)
					//trace(); //return false;
				if (level >= totalLevels - craftLevels + 1) {
					makePost();
				}
				
				//sendPresent = true;
				
				Post.send({
					ctr:this.type,
					act:'reward',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, onBonusEvent);
				
				return true;
			}
			return false;
			
		}
		
		public function isReadyToWork():Boolean
		{
			var finishTime:int = -1;
			var totalTime:int = -1;
			if (created > 0 && !hasBuilded){ // еще строится
				var curLevel:int = level + 1;
				if (curLevel >= totalLevels) curLevel = totalLevels;
				finishTime = created;
				totalTime = App.data.storage[sid].devel.req[1].t;
			}else if (upgradedTime >0 && !hasUpgraded) { // еще апграйдится
				finishTime = upgradedTime;
				if (App.data.storage[sid].hasOwnProperty('devel'))
					totalTime = App.data.storage[sid].devel.req[level + 1].t;
				else
				{
					finishTime = 0;
					totalTime = 0;
				}
			}	
			
			if(finishTime >0){
				new SpeedWindow( {
					title:info.title,
					target:this,
					info:info,
					finishTime:finishTime,
					totalTime:totalTime,
					priceSpeed: info.skip
				}).show();
				return false;	
			}		
			
			return true;
		}
		
		override public function putAction():void {
			if (crafted >= App.time || hasProduct) {
				return;
			}
			if (!stockable) {
				return;
			}
			
			uninstall();
			if (sid == 752 || App.data.storage[sid].type == 'Building' || App.data.storage[sid].type == 'Tribute')
				App.user.stock.add(sid, {lvl: this.level, cnt:1});
			else 
				App.user.stock.add(sid, 1);
			
			Post.send( {
				ctr:this.type,
				act:'put',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id,
				lvl:this.level
			}, function(error:int, data:Object, params:Object):void {
					
			});
		}
		
		protected var currentHutLevel:int = -1;
		override public function stockAction(params:Object = null):void {
			
			if (!App.user.stock.check(sid)) {
				//TODO показываем окно с ообщением, что на складе уже нет ничего
				return;
			}else if (!World.canBuilding(sid)) {
				uninstall();
				return;
			}
			
			if (params && params.coords) {
				coords.x = params.coords.x;
				coords.z = params.coords.z;
			}
			
			var lvl:int = 0;
			if (sid == 752 || App.data.storage[sid].type == 'Building' || App.data.storage[sid].type == 'Tribute') {
				for (var level:String in App.user.stock.data[sid]) {
					if (App.user.stock.data[sid][level] == 0) continue;
					lvl = int(level); 
				}
				if (!lvl && App.data.storage[sid].type == 'Building') {
					lvl = this.totalLevels;
				}
				
				if (lvl < 0) lvl = 0;
				this.level = lvl;
				
				if (!componentable && [1580,1624,1094,1761].indexOf(int(sid)) == -1)
					stockable = true;
				
				updateLevel();
			} else {
				if (App.data.storage[sid].type == 'Hut' || App.data.storage[sid].type == 'Garden'){
					lvl = 0;
					if (sid == 461) lvl = 1;
				} else if (this.totalLevels > 0) {
					lvl = this.totalLevels - 1;
				}
			}
			if (sid == 303) 
			{
				lvl = 0;
				level = '0';
				this.level = 0;
				updateLevel();
			}
			App.user.stock.take(sid, 1);
			
			if (App.data.storage[sid].type == 'Golden'/* || sid == 1580 || sid == 1624*/) {
				lvl = 0;
			}
			
			// Потому что что здания этого типа попали на склад
			if (componentable)
				lvl = totalLevels;
			
			if (sid != 752 && App.data.storage[sid].type != 'Building' && App.data.storage[sid].type != 'Tribute') {
				Post.send( {
					ctr:this.type,
					act:'stock',
					uID:App.user.id,
					wID:App.user.worldID,
					sID:this.sid,
					x:coords.x,
					z:coords.z,
					level:lvl
				}, onStockAction);
				return;
			}
			
			currentHutLevel = lvl;
			Post.send( {
				ctr:this.type,
				act:'stock',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z,
				lvl:lvl,
				fld:'level'
			}, onStockAction, {level:lvl});
		}
		
		override protected function onStockAction(error:int, data:Object, params:Object):void {
			super.onStockAction(error, data, params);
			
			//if (App.user.instance.hasOwnProperty(sid)) 
			//{
				//App.user.instance[sid] += 1;
			//}else 
			//{
				//App.user.instance[sid] = 1;
			//}
			if (info.type == 'Building') {
				hasUpgraded = true;
				hasBuilded = true;
				fromStock = true;
			} else {
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = App.time - 1000;
				fromStock = true;
				App.self.setOnTimer(upgraded);
			}
			
			if (data.hasOwnProperty('limit')) {
				totalLimit = data.limit.max;
				climit = data.limit.cur;
			}
		}
		
		override public function onAfterStock():void {
			showIcon();
			addGround();
		}
		
		public function isProduct(value:int = 0):Boolean
		{
			if (hasProduct)
			{
				if (App.data.storage[formula.out].type == 'Lamp')
				{
					var that:* = this;
					new SimpleWindow( {
						title:Locale.__e('flash:1382952379893'),
						text:Locale.__e('flash:1445430929040'),
						dialog:true,
						label:SimpleWindow.ATTENTION,
						cancelText:Locale.__e('flash:1445430817897'),
						confirm:storageEvent
					}).show();
					
					return true;
				}
				var price:Object = getPrice();
				
				var out:Object = { };
				out[formula.out] = formula.count;
				if (!App.user.stock.checkAll(price))	return true;  // было false
				
				// Отправляем персонажа на сбор
				storageEvent();
				
				return true; 
			}
			return false;
		}
		
		public function onBonusEvent(error:int, data:Object, params:Object):void 
		{
			//sendPresent = false;
			if (error) {
				Errors.show(error, data);
				return;
			}
			
			if (data.hasOwnProperty('limit')) {
				totalLimit = data.limit.max;
				climit = data.limit.cur;
			}
			
			removeEffect();
			showIcon();
			
			
			
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('rew')) {
				getBonus(Treasures.convert(info.devel.rew[level]));
			}
		}
		
		public function showPostWindow():void {
			
			var text:String = 'flash:1382952379896';//Поздравляем! Вы закончили строительство здания!
			
			if (level > 1)
				text = 'flash:1395849886254';//Поздравляем! Вы улучшили здание!
			new SimpleWindow( {
				title:info.title,
				label:SimpleWindow.BUILDING,
				text:Locale.__e("flash:1382952379896"),
				sID:sid,
				ok:(App.social == 'PL')?null:makePost
			}).show();
		}
		
		public function findJobPosition():Object
		{
			var _y:int = -1;
			if (coords.z + _y < 0)
				_y = 0;
				
			var _x:int = int(info.area.w / 2);
			var _direction:int = 0;
			var _flip:int = 0;
				
			return {
				x:_x,
				y:_y,
				direction:_direction,
				flip:_flip
			}		
		}
		
		public function openProductionWindow(settings:Object = null):void {
			
			/*if (sid == 273) {
				new BarterWindow({}).show();
				return;
			}*/
			
			if (App.user.quests.tutorial && App.tutorial && App.tutorial.step == 31) return;
			
			var setObjest:Object = {
				title:			info.title,
				crafting:		info.devel.craft,
				target:			this,
				onCraftAction:	onCraftAction,
				hasPaginator:	true,
				hasButtons:		true,
				find:helpTarget
			};
			if (settings && settings.hasOwnProperty('historyPage')) setObjest['historyPage'] = settings.historyPage;
			new ProductionWindow(setObjest).show();
		}
		
		public function onCraftAction(fID:uint):void
		{
			var isBegin:Boolean = true;
			//if (queue.length > 0)
			//isBegin = false;
			//addToQueue(fID);
				
			var formula:Object = App.data.crafting[fID];
			
			if(formula.time > 0){
				beginCraft(fID, App.time + formula.time);
				
				if (!singleAnimation)
					framesType = "work";
				checkOnAnimationInit();
				
				var levelData:Object;
				if (isBaloon) {
					if (crafted > 0 && crafted > App.time) {
						baloonStarted = true;
						if (this.animationContainer.x != 0) this.animationContainer.x = 0;
						if (this.animationContainer.y != 0) this.animationContainer.y = 0;
						this.animationContainer.alpha = 1;
						this.animationContainer.visible = true;
						
						App.self.setOnEnterFrame(flyBaloon);
						//TweenLite.to(this.animationContainer, 20.0, { alpha:0, x:this.animationContainer.x + 1200, y:this.animationContainer.y - 1200});
						
						levelData = textures.sprites[2];
						if (levelData) draw(levelData.bmp, levelData.dx, levelData.dy);
						iconSetPosition();
					}
				}
				
				if (App.isSocial('VK','DM','FS','ML','OK')) {
					if (sameBuildings.length <= 1) Window.closeAll();
				}else {
					Window.closeAll();
				}
			}
			
			for (var sID:* in formula.items){
				App.user.stock.take(sID, formula.items[sID]);
			}
			
			Post.send({
				ctr:this.type,
				act:'crafting',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fID:fID
			}, onCraftEvent);
		}
		
		private function flyBaloon(e:Event = null):void {
			this.animationContainer.x += 1;
			this.animationContainer.y -= 1;
			
			if (this.animationContainer.x == 1000) TweenLite.to(this.animationContainer, 5.0, { alpha:0});
			
			if (this.animationContainer.x == 1200) App.self.setOffEnterFrame(flyBaloon);
		}
		
		protected function onCraftEvent(error:int, data:Object, params:Object):void 
		{
			if (error) {
				Errors.show(error, data);
				cancelCraft();
				return;
			}
			
			if (climit != -1) 
				climit++;
			
			if (data.hasOwnProperty('crafted')) {
				this.crafted = data.crafted;
			}else {
				ordered = false;
				hasProduct = false;
				queue = [];
				crafted = 0;
				//onStorageEvent(error, data, params);
			}
			
			//Создание ресурса в OG
			if (App.social == 'FB') {
				ExternalApi.og('create','resource');
			}
			
			if (climit + 1 > totalLimit)
				Window.closeAll();
		}
		
		protected function addToQueue(fID:int, order:* = null):void {
			// Выбираем самое позднее окончание производства
			var _crafted:int = 0;
			var _order:int = 0;
			for (var i:int = 0; i < queue.length; i++) {
				if (queue[i].crafted > _crafted)
					_crafted = queue[i].crafted;
				
				if (order === null && queue[i].order > _order)
					_order = queue[i].order;
			}
			if (_crafted == 0) _crafted = App.time;
			if (order === null) order = _order;
			
			queue.push( {
				order:		int(order),
				fID:		fID,
				crafted:	_crafted + getFormula(fID).time
			});
		}
		
		public function onBoostEvent(count:int = 0):void {
			var that:* = this;
			if (!App.user.stock.take(Stock.FANT, count, function():void {
				App.self.setOffTimer(production);
				
				crafted = App.time;
				onProductionComplete();
				
				cantClick = true;
				
				Post.send({
					ctr:that.type,
					act:'boost',
					uID:App.user.id,
					id:that.id,
					wID:App.user.worldID,
					sID:that.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					cantClick = false;
					if (isBaloon) {
						that.animationContainer.visible = false;
						App.self.setOffEnterFrame(flyBaloon);
						baloonReturn();
					}
					SoundsManager.instance.playSFX('bonusBoost');
				});
			})) return;
				
				App.self.setOffTimer(production);
				
				crafted = App.time;
				onProductionComplete();
				
				cantClick = true;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					//crafted = data.crafted;
					cantClick = false;
					
					//if (data) {
						//for (var i:int = 0; i < queue.length; i++) {
							//if (crafted == queue[i].crafted) {
								//var delta:int = crafted - App.time;
								//for (var j:int = 0; j < queue.length; j++) {
									//queue[j].crafted -= delta;
								//}
								//break;
							//}
						//}
						//checkProduction();
						//
						//cantClick = false;
					//}
					if (isBaloon) {
						that.animationContainer.visible = false;
						App.self.setOffEnterFrame(flyBaloon);
						baloonReturn();
					}
					/*if (train) {
						train.trainReturn();
					}*/
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		//ускорялка для зданий за материалы
		public function onBoostMaterialEvent(count:int = 0, material:int = 0):void {
			var that:* = this;
			if (!App.user.stock.take(Stock.FANT, count)) return;
				
				//App.self.setOffTimer(production);
				App.user.stock.take(material, 1);
				//crafted = App.time;
				//onProductionComplete();
				
				cantClick = true;
				
				Post.send({
					ctr:this.type,
					act:'boost',
					uID:App.user.id,
					id:this.id,
					wID:App.user.worldID,
					sID:this.sid,
					m:material
				}, function(error:*, data:*, params:*):void {
					
					if (error) {
						Errors.show(error, data);
						return;
					}
					
					crafted = data.crafted;
					if (icon) {
						icon.params.progressEnd = crafted;
						icon.params.progressBegin = crafted - formula.time;
						icon.progress();
					}
					
					if (crafted <= App.time) {
						App.self.setOffTimer(production);
						onProductionComplete();
					}
					
					cantClick = false;
					
					if (isBaloon) {
						that.animationContainer.visible = false;
						App.self.setOffEnterFrame(flyBaloon);
						baloonReturn();
					}
					SoundsManager.instance.playSFX('bonusBoost');
				});
		}
		
		public function baloonReturn():void {
			//baloonFinished = false;
			animationContainer.visible = false;
			
			var levelData:Object = textures.sprites[1];
			if (levelData) draw(levelData.bmp, levelData.dx, levelData.dy);
			iconSetPosition();
		}
		
		public function getPrice():Object
		{
			var price:Object = { }
			price[Stock.FANTASY] = 0;
			return price;
		}
		
		public function storageEvent(value:int = 0):void
		{
			var out:Object = { };
			out[formula.out] = formula.count;
			hasProduct = false;
			
			cantClick = true; 
			
			Post.send({
				ctr:this.type,
				act:'storage',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			}, onStorageEvent);	
			if (climit + 1 > totalLimit)
				Window.closeAll();
		}
		
		public function onStorageEvent(error:int, data:Object, params:Object):void {
			
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			//for (var i:int = 0; i < queue.length; i++) {
				//if (queue[i].crafted <= App.time) {
					//var formula:Object = getFormula(queue[i].fID);
					//
					//// Удаляем из готовых
					//var index:int = completed.indexOf(queue[i].fID);
					//if (index >= 0) completed.splice(index, 1);
					//
					//queue.splice(i, 1);
					//i--;
				//}
			//}
			
			/*if (climit != -1) 
				climit++;*/
			
			
			
			if (App.user.quests.tutorial) {
				try {
					if (data.bonus.hasOwnProperty('228')) {
						App.user.stock.addAll(data.bonus);
						App.user.stock.add(234, 1);
						App.user.stock.data[234] = -1;
						data.bonus = { 234:1 };
					}
				}catch(e:*) {}
			}
			//formula
			if (data.hasOwnProperty('bonus')) {
				var that:* = this;
				var exit:Boolean = false;
				for (var sID:* in data.bonus) {
					if (App.data.storage[sID].type == 'Pack') {
						getBonus(Treasures.convert(App.data.storage[sID].bonus));
						exit = true;
						break;
					}
				}
				if (!exit) getBonus(data.bonus);// Treasures.bonus(/*Treasures.convert(*/data.bonus/*)*/, new Point(that.x, that.y));
				//showIcon();
			} 
			
			if (App.data.storage[formula.out].type == "Energy" && App.data.storage[formula.out].out == 2992)
			{
				App.user.stock.charge(formula.out);
			}
			
			clearIcon();
			
			ordered = false;
			hasProduct = false;
			queue = [];
			crafted = 0;
			
			cantClick = false;
		}
		
		public var needTechno:uint = 0;
		public function beginCraft(fID:uint, crafted:uint):void
		{
			formula = getFormula(fID);
			if (crafted == 0) crafted = App.time + formula.time;
			
			this.fID = fID;
			this.crafted = crafted;
			began = crafted - formula.time;
			crafting = true;
			open = true;
			showIcon();
			
			//if (train) train.trainToGo();
			
			App.self.setOnTimer(production);
		}
		protected function cancelCraft():void {
			this.fID = 0;
			this.crafted = 0;
			began = 0;
			crafting = false;
			showIcon();
			
			App.self.setOffTimer(production);
		}
		
		public var countLabel:TextField;
		public var title:TextField;
		
		protected function onOutLoad(data:*):void {
			//
		}
		
		public function set material(toogle:Boolean):void {
			if (countLabel == null) return;
			if (toogle) {
				if(crafted > App.time){
					countLabel.text = TimeConverter.timeToStr(crafted - App.time);
					countLabel.x = (icon.width - countLabel.width) / 2;
				}
			}
			//popupBalance.visible = toogle;
		}
		
		protected var timeID:uint;
		protected var anim:TweenLite;
		override public function set touch(touch:Boolean):void {
			if ((!moveable && Cursor.type == 'move') ||
				(!removable && Cursor.type == 'remove') ||
				(!rotateable && Cursor.type == 'rotate'))
			{
				return;
			}
			
			super.touch = touch;	
			if (touch) {
				if(Cursor.type == 'default' && crafted && App.user.mode == User.OWNER){
					timeID = setTimeout(function():void{
						material = true;
					},400);
				}
			}else {
				clearTimeout(timeID);
				if(anim){
					anim.complete(true);
					anim.kill();
					anim = null;
				}
				material = false;
			}
		}
		
		protected function production():void {
			if (progress) {
				checkOnAnimationInit();
				
				App.self.setOffTimer(production);
			}
		}
		
		public function get progress():Boolean {
			if (began + formula.time - 20 == App.time && isBaloon) {
				baloonStarted = true;
				if (this.animationContainer.x == 0) this.animationContainer.x += 1200;
				if (this.animationContainer.y == 0) this.animationContainer.y -= 1200;
				this.animationContainer.visible = true;
				this.animationContainer.alpha = 0;
				TweenLite.to(this.animationContainer, 20.0, { alpha:1, x:this.animationContainer.x - 1200, y:this.animationContainer.y + 1200, onComplete:baloonReturn } );
			}
			if (fID == 0 || began + formula.time <= App.time)
			{
				onProductionComplete();
				//if (queue.length - completed.length <= 0) return true;
				if (crafted <= App.time) return true;
			}
			
			if(countLabel != null){
				countLabel.text = TimeConverter.timeToStr(crafted - App.time);
			}
			
			return false;
		}
		
		public function set crafting(value:Boolean):void
		{
			_crafting = value;
		}
		public function get crafting():Boolean
		{
			return _crafting;
		}
		
		public function onProductionComplete():void {
			//if (train) train.trainReturn();
			fireTechno();
			checkProduction();
		}
		
		public function upgradeEvent(params:Object, fast:int = 0):void {
			
			if (level  > totalLevels) {
				return;
			}
			
			var price:Object = { };
			for (var sID:* in params) {
				if (sID == Techno.TECHNO) {
					//needTechno = params[sID];
					//delete params[sID];
					continue;
				}
				price[sID] = params[sID];
			}
			
			// Забираем материалы со склада
			if (fast == 0) {
				if (!App.user.stock.takeAll(price)) return;
			}/*else {
				if (!App.user.stock.take(Stock.FANT,fast)) return;
			}*/
			
			gloweble = true;
			info
			Post.send( {
				ctr:this.type,
				act:'upgrade',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid,
				fast:fast
			},onUpgradeEvent, params);
		}
		
		public function onUpgradeEvent(error:int, data:Object, params:Object):void 
		{
			if (error){
				Errors.show(error, data);
				return;
			}else {
				//moveable = false;
				hasUpgraded = false;
				hasBuilded = true;
				upgradedTime = data.upgrade;
				App.self.setOnTimer(upgraded);
				
				addEffect(Building.BUILD);
				showIcon();
				
				if (App.social == 'FB') {
					ExternalApi.og('improve','building');
				}
			}
		}
		
		override public function onRemoveAction(error:int, data:Object, params:Object):void {
			super.onRemoveAction(error, data, params);
			
			Storage.instanceRemove(sid);
		}
		
		public function finishUpgrade():void
		{
			/*if (level == totalLevels && App.user.mode != User.GUEST) {
				new SimpleWindow( {
					title:info.title,
					label:SimpleWindow.BUILDING,
					text:Locale.__e("flash:1382952379896"),
					sID:sid,
					ok:(App.social == 'PL')?null:makePost
				}).show();
			}*/
			if (level == totalLevels && App.social == 'FB') {
				ExternalApi.og('construct','building');
			}
			
			if (App.user.mode != User.GUEST) {
				isPresent();
				showIcon();
			}
		}
		
		public function acselereatEvent(count:int):void
		{
			if (!App.user.stock.check(Stock.FANT, count)) return;
			
			Post.send( {
				ctr:this.type,
				act:'speedup',
				uID:App.user.id,
				id:this.id,
				wID:App.user.worldID,
				sID:this.sid
			},onAcselereatEvent);
		}
		
		public function onAcselereatEvent(error:int, data:Object, params:Object):void 
		{
			if (error)
			{
				Errors.show(error, data);
				return;
			}
			
			var minusFant:int = App.user.stock.count(Stock.FANT) - data[Stock.FANT];
			
			var price:Object = { }
			price[Stock.FANT] = minusFant;
			
			if (!App.user.stock.takeAll(price))	return;
			
			if(!App.user.quests.tutorial)
				Hints.minus(Stock.FANT, minusFant, new Point(this.x * App.map.scaleX + App.map.x, this.y * App.map.scaleY + App.map.y), true);
			
			upgradedTime = data.upgrade;
			created = data.created;
		}
		
		/*
		 * Изменяем помощников
		 */ 
		public function changeHelpers(role:String, data:String):void
		{
			if (helpers == null) return;
			
			if (data == "rent")
				helpers[role] = 0;
			else if (data == "remove")
				delete helpers[role];
			else
				helpers[role] = data;
		}
		
		
		private var baloonStarted:Boolean = false;
		private var baloonFinished:Boolean = false;
		public function beginAnimation():void 
		{
			if (crafting == true || alwaysAnimated.indexOf(sid) != -1 || (textures.animation != null && textures.animation.hasOwnProperty('infinityAnimation') && textures.animation.infinityAnimation))
			{
				startAnimation();
				checkAndDrawFirstFrame();
			}
			
			if (crafting == true) 
			{
				if (animationBitmap != null && animationBitmap.visible == false) 
					animationBitmap.visible = true;
					
				//startSmoke();
			}
			
			if (animationBitmap != null) {
				if (crafting == true) 
					animationBitmap.visible = true;
				else
				{
					if (info.view == 'firefactory')
						animationBitmap.visible = false;
				}
			}			
		}
		
		public function finishAnimation():void 
		{
			if (App.user.mode == User.GUEST)
				return;
			
			if (textures && textures.hasOwnProperty('animation'))
			{
				if (textures.animation != null && textures.animation.hasOwnProperty('infinityAnimation') && textures.animation.infinityAnimation)
				{
					stopSmoke();
					return;
				}
				stopAnimation();
				
			}
			
			if(animationBitmap != null){
				if (info.view == 'firefactory') 
					animationBitmap.visible = false;
			}
		}
		
		public var isTechnoWork:Boolean = false;
		
		public function fireTechno():void 
		{
			Techno.setFree(this);
		}
		
		public var workerPath:Object = {
			
		}
		public function generateWorkerPath(pos:int):void 
		{
			var _workerPath:Object = { };
			var path:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			var path_reverse:Vector.<AStarNodeVO> = new Vector.<AStarNodeVO>();
			
			var node:AStarNodeVO;
			var _z:int = coords.z;
			var _x:int = coords.x;
			switch(pos) 
			{
				case 0:
					_z = coords.z - 1;
					for (_x = coords.x; _x < coords.x + cells; _x++) {
						if(App.map.inGrid({x:_x, z:_z})){
							node = App.map._aStarNodes[_x][_z];
							path.push(node);
						}
					}
					_x = coords.x + cells;
					for (_z = coords.z + 1; _z < coords.z + rows / 2; _z++) {
						if(App.map.inGrid({x:_x, z:_z})){
							node = App.map._aStarNodes[_x][_z];
							path.push(node);
						}	
					}
					break;	
				case 1:
					_x = coords.x - 1;
					for (_z = coords.z + 1; _z< coords.z + rows; _z++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					_z = coords.z + rows;
					for (_x = coords.x; _x< coords.x + rows/2; _x++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					break;	
				case 2:
					_x = coords.x - 1;
					for (_z = coords.z + 1; _z< coords.z + rows; _z++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					_z = coords.z + rows;
					for (_x = coords.x; _x< coords.x + rows; _x++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					break;	
				case 3:
					_x = coords.x - 1;
					for (_z = coords.z + 1; _z< coords.z + rows; _z++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					_z = coords.z + rows;
					for (_x = coords.x; _x< coords.x + rows / 4; _x++) {
						node = App.map._aStarNodes[_x][_z];
						path.push(node);
					}
					break;
			}
			
			path_reverse = path_reverse.concat(path);
			path_reverse.reverse();
			
			_workerPath = {
				0:path,
				1:path_reverse
			}
			
			workerPath[pos] = _workerPath;
		}
		
		public function getTechnoPosition(pos:int = 0):Object 
		{
			var workType:String = Personage.HARVEST;
			var direction:int = 0;
			var flip:int = 0;
			
			if (!crafting){
				workType = Personage.HARVEST;
				direction = 1;
			}
			
			generateWorkerPath(pos);
			
			var firstPlace:AStarNodeVO = workerPath[pos][1][0];
			return {
				x:firstPlace.position.x,//coords.x + info.area.w - 1,
				z:firstPlace.position.y,//coords.z + int(info.area.h / 2) + 2*id,
				direction:direction,
				flip:flip,
				workType:workType
			}
		}
		
		override public function flip():void {
			super.flip();
			
			showIcon();
		}
		
		override public function uninstall():void {
			App.self.setOffTimer(production);
			
			super.uninstall();
			fireTechno();
			removeGround();
		}
		
		public function getContactPosition():Object
		{
			var y:int = -1;
			if (this.coords.z + y < 0)
				y = 0;
				
			return {
				x: int(info.area.w / 2),
				y: y,
				direction:0,
				flip:0
			}
		}	
		
		override public function free():void {
			super.free();
			if (ground) ground.visible = false;
		}
		
		override public function take():void {
			super.take();
			if (ground) ground.visible = true;
		}
		
		private var effect:AnimationItem;
		public function addEffect(type:String):void 
		{
			return;
			var layer:int = 0;
			if (type == BUILD) {
				effect = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
				effect.blendMode = BlendMode.HARDLIGHT;
				layer = 1;
			}else if (type == BOOST) {
				effect = new AnimationItem( { type:'Effects', view:type, params:AnimationItem.getParams(type, info.view) } );
			}
			addChildAt(effect, layer);
			var pos:Object = IsoConvert.isoToScreen(int(cells / 2), int(rows / 2), true, true);
			effect.x = pos.x;
			effect.y = pos.y - 5;
		}
		
		public function removeEffect():void {
			if (effect){
				if(effect.parent)effect.parent.removeChild(effect);
				effect.stopAnimation();
				effect.dispose();
			}	
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			if (App.self.constructMode) return EMPTY;
			for (var i:uint = 0; i < cells; i++) {
				for (var j:uint = 0; j < rows; j++) {
					node = App.map._aStarNodes[coords.x + i][coords.z + j];
					if (App.data.storage[sid].base == 1) {
						if ((node.b != 0 || node.open == false || node.object != null) && node.w != 1) {
							return OCCUPIED;
						}
						if (node.w != 1 || node.open == false || node.object != null) {
							return OCCUPIED;
						}
					} else {
						if (node.b != 0 || node.open == false || (node.object != null && (node.object is Stall))) {
							return OCCUPIED;
						}
					}
				}
			}
			return EMPTY;
		}
		
		public var craftLevels:int = 0;
		public function setCraftLevels():void
		{
			if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('craft')) {
				for each(var obj:* in info.devel.craft) {
					craftLevels++;
				}
			}else if (info.hasOwnProperty('devel') && info.devel.hasOwnProperty('open')) {
				for each(obj in info.devel.open) {
					craftLevels++;
				}
			}
		}
		
		// Составные прибыльные домики
		private var component:Object = {
			1561: [1545,1546,1547,1548,1550,1551,1552,1553],
			1869: [1870,1871,1872,1873,1874,1875,1876,1877]
		}
		
		public function get componentable():Boolean {
			if (componentMainID != 0)
				return true;
			
			return false;
		}
		
		public function get componentIsMain():Boolean {
			if (component.hasOwnProperty(sid))
				return true;
			
			return false;
		}
		
		public function get componentIsChild():Boolean {
			for (var comp:String in component) {
				if (component[comp].indexOf(sid) != -1)
					return true;
			}
			
			return false;
		}
		
		public function get componentMainID():int {
			if (component.hasOwnProperty(sid))
				return sid;
			
			for (var comp:String in component) {
				if (component[comp].indexOf(sid) != -1)
					return int(comp);
			}
			
			return 0;
		}
		
		public function get componentChildsReady():Boolean {
			if (componentFirstUnreadyChild)
				return false;
			
			return true;
		}
		
		private function get componentFirstUnreadyChild():* {
			var childs:Array = Map.findUnits(component[componentMainID]);
			var index:int = childs.length;
			
			while (--index && index >= 0) {
				if (childs[index].level <= level && childs[index].level < childs[index].totalLevels)
					return childs[index];
			}
			
			return null;
		}
		
		private function get componentChildsUnready():Array {
			var childs:Array = Map.findUnits(component[componentMainID]);
			var index:int = childs.length;
			
			while (index > 0) {
				--index;
				if (childs[index].level >= childs[index].totalLevels)
					childs.splice(index, 1);
			}
			
			childs.sortOn('level', Array.NUMERIC);
			
			return childs;
		}
		
		//protected function get componentBuildable():Boolean {
			//if (componentable) {
				//
				//var list:Array;
				//
				//// Если составная постройка главная
				//if (componentIsMain) {
					//
					//return true;
					//// Если дочерние компоненты не готовы
					///*if (!componentChildsReady) {
						//var locale1:String = 'flash:1454767850835';						
						//var locale2:String = 'flash:1454767883977';						
						//new SimpleWindow( {
							//title:		info.title,
							//text:		(level == totalLevels - 1) ? Locale.__e(locale1) : Locale.__e(locale2),
							//ok:			function():void {
								//list = componentChildsUnready;
								//if (list.length > 0) {
									//App.map.focusedOn(list[0], true);
								//}
							//}
						//}).show();
						//
						//return false;
					//}*/
				//}else {
					//var mainComponent:int;
					//for (var comp:* in component) {
						//for each (var i:* in component[comp]) {
							//if (int(i) == sid) {
								//mainComponent = comp;
								//break;
							//}
						//}
					//}
					//list = Map.findUnits([mainComponent]);
					//
					//if (list.length > 0 && list[0].level <= this.level) {
						//new SimpleWindow( {
							//title:		info.title,
							//text:		Locale.__e('flash:1454767850835'),
							//confirm:			function():void {
								//if (list.length > 0) {
									//App.map.focusedOn(list[0], true);
								//}
							//}
						//}).show();
						//return false;
					//} else {
						//return true;
					//}
					//
					///*for each(var unit:* in list) {
						//
						//// Если найдена главная постройка, ее уровень ниже чем у текущей дочерней постройки, уровень главной не предпоследний
						//if (unit && unit.sid == componentMainID && unit.level < level && unit.level != unit.totalLevels - 1) {
							//
							//list = componentChildsUnready;
							//
							//var locale3:String = 'flash:1454767883977';							
							//new SimpleWindow( {
								//title:		info.title,
								//text:		(minimumLevel(list) > unit.level) ? Locale.__e('flash:1454768360946') : Locale.__e(locale3),
								//ok:			function():void {
									//if (minimumLevel(list) > unit.level) {
										//App.map.focusedOn(unit, true);
									//}else if (list.length > 0) {
										//App.map.focusedOn(list[0], true);
									//}
								//}
							//}).show();
							//
							////App.map.focusedOn(unit, true);
							//
							//return false;
						//}
					//}*/
				//}
			//}
			//
			//return true;
			//
			//function minimumLevel(list:Array):int {
				//var level:int = 999;
				//for each(var unit:* in list) {
					//if (unit && unit.level < level)
						//level = unit.level;
				//}
				//return level;
			//}
		//}
		
		protected function get componentBuildable():Boolean {
			if (componentable) {
				
				var list:Array;
				
				// Если составная постройка главная
				if (componentIsMain) {					
					// Если дочерние компоненты не готовы
					if (!componentChildsReady) {
						var locale1:String = 'flash:1454767850835';						
						var locale2:String = 'flash:1454767883977';
						
						new SimpleWindow( {
							title:		info.title,
							text:		(level == totalLevels - 1) ? Locale.__e(locale1) : Locale.__e(locale2),
							confirm:			function():void {
								list = componentChildsUnready;
								if (list.length > 0) {
									App.map.focusedOn(list[0], true);
								}
							}
						}).show();
						
						return false;
					}
				}else {
					list = Map.findUnits([componentMainID]);
					
					for each(var unit:* in list) {
						
						// Если найдена главная постройка, ее уровень ниже чем у текущей дочерней постройки, уровень главной не предпоследний
						if (unit && unit.sid == componentMainID && unit.level < level && unit.level != unit.totalLevels - 1) {
							
							list = componentChildsUnready;
							
							var locale3:String = 'flash:1454767883977';
							
							new SimpleWindow( {
								title:		info.title,
								text:		(minimumLevel(list) > unit.level) ? Locale.__e('flash:1454768360946') : Locale.__e(locale3),
								confirm:			function():void {
									if (minimumLevel(list) > unit.level) {
										App.map.focusedOn(unit, true);
									}else if (list.length > 0) {
										App.map.focusedOn(list[0], true);
									}
								}
							}).show();
							
							//App.map.focusedOn(unit, true);
							
							return false;
						}
					}
				}
			}
			
			return true;
			
			function minimumLevel(list:Array):int {
				var level:int = 999;
				for each(var unit:* in list) {
					if (unit && unit.level < level)
						level = unit.level;
				}
				return level;
			}
		}
		
		
		// Мультисбор
		public var multistorage:Object = [
			[1545,1546,1547,1548,1550,1551,1552,1553]
		]
		
		public function startMultistorage():Boolean {
			if (App.user.mode == User.GUEST) return false;
			
			for (var i:int = 0; i < multistorage.length; i++) {
				if (multistorage[i].indexOf(sid) != -1) {
					var list:Array = Map.findUnits(multistorage[i]);
					
					for each(var unit:* in list) {
						// Существует, не ожидает ответа от сервера, достроен, готов, есть фантазия для сбора
						if (unit && !unit.ordered && unit.level == unit.totalLevels && unit.tribute /*&& App.user.stock.check(Stock.FANTASY, 1)*/)
							unit.storageEvent();
					}
					
					return true;
				}
			}
			
			return false;
		}
		
		
		/*public function isPhase():Boolean
		{
			var phase:Boolean = true;
			
			if (level > totalLevels - craftLevels) {
				phase = false;
			}
			
			return phase;
		}*/
		
		public function showIcon():void {
			if (App.user.mode == User.OWNER) {
				if (level > 0 && (info.type == 'Hut' || info.type == 'Mfield' || info.type == 'Exchange')) {
					clearIcon();
					return;
				}
			}
			if (!formed || !open) return;
			
			if (sid == 533) {
				clearIcon();
				return;
			}
			
			if (App.user.mode == User.OWNER) {	
				if (/*completed.length > 0*/crafted > 0 && crafted <= App.time && hasProduct && formula) {
					drawIcon(UnitIcon.REWARD, formula.out, 1, {
						glow:		true
					});
				}else if (crafted > 0 && crafted >= App.time && formula) {
					drawIcon(UnitIcon.PRODUCTION, formula.out, 1, {
						progressBegin:	crafted - formula.time,
						progressEnd:	crafted
					});
				}else if (hasPresent) {
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		true
					});
				}else if (hasBuilded && upgradedTime > 0 && upgradedTime > App.time && level < totalLevels) {
					drawIcon(UnitIcon.BUILDING, null, 0, {
						clickable:		false,
						boostPrice:		(info.devel.hasOwnProperty('skip')) ? info.devel.skip[level + 1] : null,
						progressBegin:	upgradedTime - info.devel.req[level + 1].t,
						progressEnd:	upgradedTime,
						onBoost:		function():void {
							acselereatEvent(info.devel.skip[level + 1]);
						}
					});
				}else if ((craftLevels == 0 && level < totalLevels) || (craftLevels > 0 && level < totalLevels - craftLevels + 1)) {
					drawIcon(UnitIcon.BUILD, null);
				}else {
					clearIcon();
				}
			}else if (App.user.mode == User.GUEST) {
				if (info.type == 'Floors')
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		false,
						iconDY:     -50
					});
				} else
				{
					drawIcon(UnitIcon.REWARD, 2, 1, {
						glow:		false
					});
				}
			}
		}
		
		
		
		
		/**
		 * Обновляет очереди по crafted
		 * @param	data
		 * @return
		 */
		public function queueParse(data:Object):Object {
			if (!data.hasOwnProperty('queue') || !(data.queue is Array))
				data.queue = [];
			
			if (!data.hasOwnProperty('crafted')) data.crafted = 0;
			
			if (data.fID) {
				if (data.fID is int)
					data.fID = { 0:data.fID };
			}else {
				data.fID = { };
			}
			
			var queue:Array = [];
			var index:int = 0;
			var __crafted:int = 0;
			while (data.fID[index]) {
				if (index == 0) {
					__crafted = data.crafted;
				}else {
					__crafted += getFormula(data.fID[index]).time;
				}
				
				queue.push({
					order:		index,
					fID:		data.fID[index],
					crafted:	__crafted
				});
				
				index++;
			}
			
			data.queue = queue;
			
			return data;
		}
		
		/**
		 * Сбор крафта и очистка очереди (лучше перенести в Building)
		 * @param	data
		 * @param	serverData
		 * @return
		 */
		public function queueStorage(data:Object, serverData:Object):Object {
			var bonus:Object;
			
			if (serverData) {
				if (serverData.hasOwnProperty('crafted'))
					data.crafted = serverData.crafted;
				
				if (serverData[Stock.FANTASY])
					App.user.stock.data[Stock.FANTASY] = serverData[Stock.FANTASY];
				
				// Добавление в бонус 
				if (serverData['bonus']) {
					var for_remove:Array = [];
					
					bonus = Treasures.treasureToObject(serverData.bonus);
					
					for (var queueID:* in data.fID) {
						var formulaID:int = data.fID[queueID];
						var outID:int = App.data.crafting[formulaID].out;
						var count:int = App.data.crafting[formulaID].count;
						
						if (bonus.hasOwnProperty(outID)) {
							/*if (!bonus.hasOwnProperty(outID))
								bonus[outID] = 0;
							
							bonus[outID] += count;
							
							serverData[outID] -= count;
							if (serverData[outID] <= 0) delete serverData[outID];*/
							
							if (App.data.storage[outID].hasOwnProperty('experience') && App.data.storage[outID].experience > 0) {
								if (!bonus.hasOwnProperty(Stock.EXP)) bonus[Stock.EXP] = 0;
								bonus[Stock.EXP] += App.data.storage[outID].experience;
							}
							
							for_remove.push(queueID);
							
							// Очистка очереди
							for (var i:int = 0; i < data.queue.length; i++) {
								if (data.queue[i].fID == formulaID) {
									data.queue.splice(i, 1);
									break;
								}
							}
						}
					}
					
					for (var j:int = 0; j < for_remove.length; j++) {
						delete data.fID[for_remove[j]];
					}
					
					if (Numbers.countProps(data.fID) == 0)
						data.crafted = 0;
					
					// Смещение элементов объекта как будто это массив ;)
					var lowestID:int = Numbers.countProps(data.fID);
					for (queueID in data.fID) {
						if (queueID < lowestID) lowestID = queueID;
					}
					if (lowestID > 0) {
						var objectFID:Object = { };
						for (queueID in data.fID) {
							objectFID[queueID - lowestID] = data.fID[queueID];
						}
						data.fID = objectFID;
					}
				}
			}
			
			return bonus;
		}
		
		/**
		 * Удаление последнего элемента очереди
		 */
		public function queueRemoveLast(data:Object):void {
			if (data.hasOwnProperty('queue')) {
				data.queue.pop();
				data.crafted = (data.queue.length > 0) ? data.queue[data.queue.length - 1] : 0;
				
				for (var id:* in data.fID) {
					if (id >= data.queue.length)
						delete data.fID[id];
				}
			}
		}
	}
}