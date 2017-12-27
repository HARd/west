package  
{
	import api.ExternalApi;
	import astar.AStarNodeVO;
	import buttons.Button;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import com.greensock.*;
	import com.greensock.easing.*;
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.UnitIcon;
	import units.Animal;
	import units.Box;
	import units.Building;
	import units.Field;
	import units.Hero;
	import units.Personage;
	import units.Resource;
	import units.Techno;
	import units.Tree;
	import units.Unit;
	import units.Walkgolden;
	import units.WorkerUnit;
	import units.WUnit;
	import units.Zoner;
	import wins.GoalWindow;
	import wins.InfoWindow;
	import wins.ProductionWindow;
	import wins.QuestWindow;
	import wins.ShopWindow;
	import wins.TutorialMessageWindow;
	import wins.Window;
	
	public class Tutorial
	{
		
		public static const INTRO_1:String = 'intro1';
		public static const INTRO_2:String = 'intro2';
		public static const INTRO_3:String = 'intro3';
		public static const INTRO_4:String = 'intro4';
		public static const INTRO_5:String = 'intro5';
		public static const INTRO_6:String = 'intro6';
		
		public static const BOX:int = 312;
		public static const BEAR:int = 279;
		public static const BOAT:int = 315;
		
		public static var mainTutorialComplete:Boolean = false;
		
		private var fader:Sprite;
		private var originalHeroTexture:*;
		private var tutorialHeroTexture:*;
		
		public var hero:Hero;
		public var klide:Techno;
		public var merry:Personage;
		public var seaman:Personage;
		public var karl:Zoner;
		public var ketrin:Personage;
		public var ted:Personage;
		public var map:Bitmap;
		private var loader:Sprite;
		public var loadText:TextField;
		
		public var extendTargets:Array = [];
		public var targets:Array = [
			{step:4, sid:315, id:1},
			{step:6, sid:1063, id:1648 },
			{step:10, sid:322, id:9999 },
			{step:13, sid:62, id:1618},
			{step:14, sid:87, id:4},
			{step:14, name:'pw_craft'},
			{step:14, name:'rw_craft'},
			{step:15, sid:196, id:1 },
			{step:31, sid:281, id:3 },
			
			//{step:41, sid:304, id:2},	//
			{step:41, sid:87, id:2},	//
			{step:42, sid:86, id:1},	// Merry
			{step:43, sid:89, id:5 },	//
			{step:44, name:'bttn_home' },
			
			{step:50, sid:65, id:1656},	// Золото
			{step:60, name:'QuestWindow_helpBttn' },	// Егерь
			{step:61, name:'HutHireWindow_addFeedButton'},
			{step:61, name:'HutHireWindow_user1'},
			{step:61, name:'HutHireWindow_feedButton'},
		]
		
		public static var checkIn:Object = {
			'mapComplete':102,
			'tutorialLoaded':103,
			'waterfall':104,
			'standup':105,
			'taketree':106,
			'kitchen':107
		}
		
		public function Tutorial() {
			fader = new Sprite();
			
			if (App.data.options.hasOwnProperty('TutorialText')) {
				try {
					var array:* = JSON.parse(App.data.options['TutorialText']);
					dialog = array;
				}catch(e:*) {}
			}
		}
		
		public static function init():void {
			if (!App.tutorial)
				App.tutorial = new Tutorial();
		}
		
		// Fader
		public function fade(onComplete:Function, alpha:Number = 1, time:Number = 1, color:uint = 0):void {
			if (loader && App.self.contextContainer.contains(loader)) {
				App.self.contextContainer.removeChild(loader);
				loader = null;
			}
			
			if (!App.self.contextContainer.contains(fader)) App.self.contextContainer.addChildAt(fader, 0);
			fader.visible = true;
			fader.graphics.clear();
			fader.graphics.beginFill(color, 1);
			fader.graphics.drawRect(0, 0, Capabilities.screenResolutionX, Capabilities.screenResolutionY);
			fader.graphics.endFill();
			
			TweenLite.to(fader, time, { alpha:alpha, onComplete:complete} );
			
			function complete():void {
				if (alpha == 0) fader.visible = false;
				if (onComplete != null)
					onComplete();
			}
		}
		
		
		public function setOriginalHeroTexture():void {
			if (hero.textures == tutorialHeroTexture) {
				hero.textures = originalHeroTexture;
				hero.framesType = Personage.STOP;
			}
		}
		
		
		public function show(step:int = 0):void {
			if (App.user.quests.tutorial) return;
			
			App.user.quests.tutorial = true;
			
			if (App.user.sex == 'f')
				Load.loading(Config.getSwf('Clothes', 'intro_girl'), onLoadPersonage);
			else
				Load.loading(Config.getSwf('Clothes', 'intro_boy'), onLoadPersonage);
			
			currentStep = step;
			nextStep(0);
			
			//if (App.user.id == '120635122' && currentStep <= 3) currentStep = 3;
		}
		private function onLoadPersonage(data:*):void {
			tutorialHeroTexture = data;
			nextStep(step);
		}
		public function get loaded():Boolean {
			if (mainTutorialComplete || tutorialHeroTexture)
				return true;
			
			
			fade(null, 1, 0, 0x278295);
			
			loader = new Sprite();
			
			var preloader:Preloader = new Preloader();
			preloader.x = 35;
			
			loadText = Window.drawText(Locale.__e('flash:1433335456482'), {
				color:			0xffffff,
				borderColor:	0x113344,
				width:			300,
				fontSize:		22
			});
			loadText.x = 80;
			loadText.y = -loadText.height / 2;
			
			loader.addChild(preloader);
			loader.addChild(loadText);
			loader.x = App.self.stage.stageWidth / 2 - 80;
			loader.y = App.self.stage.stageHeight / 2;
			App.self.contextContainer.addChild(loader);
			
			return false;
		}
		
		private function initHeros():void {
			hero = App.user.hero;
			klide = findAndGetFirst(277) as Techno;
			merry = findAndGetFirst(323) as Personage;
			seaman = findAndGetFirst(323) as Personage;
			karl = findAndGetFirst(430) as Zoner;
		}
		
		private var playMusicCallback:Function;
		public function initMusic(playNusic:Function = null):void {
			
			if (playNusic != null)
				playMusicCallback = playNusic;
			
			if (step < 2) 
				return;
			
			if (playMusicCallback != null) {
				playMusicCallback();
				playMusicCallback = null
			}
		}
		
		
		/**
		 * Задать позицию и поворота персонажа
		 */
		public static function unitTo(unit:WUnit, rotate:uint = 0, cell:int = -1, row:int = -1):void {
			if (cell >= 0 && row >= 0) {
				unit.placing(cell, 0, row);
				unit.cell = cell;
				unit.row = row;
			}
			
			if (unit.framesFlip != rotate) {
				if (rotate == 1) {
					unit.framesFlip = rotate;
					unit.sign = -1;
					unit.bitmap.scaleX = -1;
				}else{
					unit.framesFlip = rotate;
					unit.sign = 1;
					unit.bitmap.scaleX = 1;
				}
			}
			
			if (unit.textures)
				unit.update();
		}
		
		
		public var step:int = 0;
		/*private var __step:int = 0;
		public function get step():int {
			return __step;
		}
		public function set step(value:int):void {
			__step = value;
		}*/
		public var currentStep:int = 0;
		private function nextStep(step:int = 0):void {
			if (!loaded) return;
			
			this.step = step;
			dialogSkip = 0;
			saveStep();
			
			if (step >= 2)
				initMusic();
			
			switch(step) {
				case 0:
					if (Map.ready) {
						tutorial1();
					}else{
						App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, tutorial0);
					}
					break;
				case 1:
					setTimeout(tutorial4, 2000);
					break;
				case 2:
					tutorial2();
					break;
				case 3:
					tutorial3();
					break;
				case 4:
					tutorial5();
					break;
				case 5:
					//tutorial6();
					redirect_0();
					break;
				case 6:
					tutorial7();
					break;
				case 7:
					tutorial8();
					break;
				case 8:
					tutorial8_1();
					break;
				case 9:
					tutorial9();
					break;
				case 10:
					//tutorial9_1();
					tutorial9_2();
					break;
				case 11:
					//tutorial10();
					tutorial10_2();
					break;
				case 12:
					redirect_1();
					//tutorial11();
					break;
				case 13:
					tutorial12();
					break;
				case 14:
					tutorial12_1();
					break;
				case 15:
					tutorial13();
					break;
				case 16:
					tutorial14();
					break;
					break;
				case 22:
					tutorial17();
					break;
				case 23:
					tutorial17_1();
					break;
				case 24:
					tutorial18();
					break;
				
				
				case 30:
					tutorial30();
					break;
				case 31:
					tutorial31();
					break;
				case 32:
					tutorial32();
					break;
				
				// Мерри
				case 38:
				case 39:
					quest28_4();
				case 40:
					//tutorial6();
					break;
				case 41:
				case 42:
				case 43:
					quest28_1();
					break;
				case 44:
					quest28_2();
					break;
				case 45:
					quest28_3();
					break;
				
				// Золото
				case 51:
					quest54_2();
					break;
				
				// Егеря
				case 61:
					quest32_1();
					break;
				case 62:
					quest32_2();
					break;
				
				// Локация
				case 70:
					quest157_5();
					break;
				case 71:
					quest157_0();
					break;
				case 72:
					quest157_1();
					break;
				case 75:
					quest157_4();
					break;
				
				// Кетрин на локации Озеро (423)
				case 80: break;
				case 81:
					quest923_1();
					break;
				case 86:
					quest925_2();
					break;
				case 88:
					quest925_3();
					break;
			}
		}
		private function setNextStep():void {
			nextStep(step + 1);
		}
		
		private function tutorial0(e:AppEvent = null):void {
			App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, tutorial0);
			//App.self.addEventListener(AppEvent.ON_QUEUE_COMPLETE, tutorial1);
			App.user.quests.silentRead(Tutorial.checkIn['mapComplete']);
			App.self.setOnTimer(startPrepare);
			function startPrepare():void {
				if (Load.queueLength == 0) {
					App.self.setOffTimer(startPrepare);
					tutorial1();
				}else {
					trace('AAAAAAAA', Load.queueLength);
				}
			}
		}
		private function tutorial1(e:AppEvent = null):void {
			// Инициализация текстур и 
			//App.self.removeEventListener(AppEvent.ON_QUEUE_COMPLETE, tutorial1);
			
			
			if (!map) {
				copyMap(tutorial1);
				return;
			}
			
			if (!hero) {
				hero = App.user.hero;
				hero.x = heroCoords[heroCoords.length - 1].x;
				hero.y = heroCoords[heroCoords.length - 1].y;
			}
			
			if (!hero.textures) {
				setTimeout(tutorial1, 25);
				return;
			}
			
			var boxes:Array = Map.findUnits([BOX]);
			if (currentStep > 4 || boxes.length > 0) {
				for (var i:int = 0; i < boxes.length; i++)
					boxes[i].visible = false;
				
				App.map.allSorting();
			}else if (boxes.length == 0 && App.user.stock.count(BOX) > 0) {
				Post.send( { "x":38, "z":81, "ctr":"Box", "act":"stock", "wID":112, "sID":BOX, "uID":App.user.id }, function(error:int, data:Object, params:Object):void {
					if (error) return;
					Unit.add( { 'sid':BOX, id:data.id, x:38, z:81 } );
					App.user.stock.take(BOX, 1);
					tutorial1();
				});
				return;
			}else{
				currentStep = 5;
			}
			
			Load.loading(Config.getImageIcon('quests/preview', App.data.personages[1].preview), function(data:*):void { } );
			
			App.ui.leftPanel.visible = false;
			App.ui.rightPanel.visible = false;
			App.ui.upPanel.visible = false;
			App.ui.bottomPanel.visible = false;
			App.ui.systemPanel.visible = false;
			
			klide = findAndGetFirst(277) as Techno;
			klide.workStatus = WorkerUnit.BUSY;
			klide.stopWalking();
			
			originalHeroTexture = hero.textures;
			hero.textures = tutorialHeroTexture;
			hero.framesType = INTRO_1;
			rotateHero(hero, WUnit.LEFT);
			
			if (currentStep >= 1) step = currentStep;
			prepareScene();
			nextStep(step);
		}
		
		private var heroCoords:Array = [
			{x:5400, y:790}
		];
		private function tutorial2():void {
			App.map.watchOn(hero, 1);
			fade(null, 0, 2, 0x278295);
			dialogSkipClear();
			
			dialogStart();
			dialogManage(0);
			
			Cursor.type = 'default';
			Cursor.image = null;
			
			App.user.quests.silentRead(Tutorial.checkIn['tutorialLoaded']);
			
			uncontrol = TweenLite.to(hero, 6, { x:5060, y:880, ease:Linear.easeNone, onComplete:function():void {
				hero.framesType = INTRO_2;
				uncontrol = TweenLite.to(hero, 5, { x:4780, y:950, ease:Linear.easeNone, onComplete:function():void {
					uncontrol = setTimeout(fade, 4000, null, 1, 1.3);
					//TweenLite.to(hero, 5.5, { x:4410, y:1100, ease:Linear.easeNone, onComplete:function():void {
					uncontrol = TweenLite.to(hero, 5.5, { x:4470, y:1070, ease:Linear.easeNone, onComplete:function():void {
						App.map.addChildAt(map, App.map.getChildIndex(App.map.bitmap));
						App.map.bitmap.visible = false;
						Cursor.type = 'default';
						Cursor.image = null;
						
						dialogSkipClear();
						App.user.quests.silentRead(Tutorial.checkIn['waterfall']);
						
						var unit:*
						for (var i:int = 0; i < App.map.mSort.numChildren; i++) {
							unit = App.map.mSort.getChildAt(i);
							if (unit != hero) unit.visible = false;
						}
						
						hero.framesType = INTRO_4;
						hero.x = 4360;
						hero.y = 1240;
						fade(null, 0, 1);
						uncontrol = setTimeout(fade, 3000, null, 1, 1);
						uncontrol = TweenLite.to(hero, 4, { x:4305, y:1320, ease:Linear.easeNone, onComplete:function():void {
							App.map.removeChild(map);
							App.map.bitmap.visible = true;
							
							var unit:*
							for (var i:int = 0; i < App.map.mSort.numChildren; i++) {
								unit = App.map.mSort.getChildAt(i);
								if (unit != hero) unit.visible = true;
							}
							
							nextStep(3);
						}} );
					}} );
				}} );
			}});
		}
		private function tutorial3():void {
			// На берегу
			
			dialogSkipClear();
			changeMapUnit(1063, 1648, { alpha:0, visible:false } );
			changeMapUnit(BOAT, 1, { visible:true } );
			
			App.map.watchOff();
			App.ui.upPanel.visible = true;
			App.ui.bottomPanel.visible = true;
			App.ui.systemPanel.visible = true;
			
			var boxes:Array = Map.findUnits([BOX]);
			for (var i:int = 0; i < boxes.length; i++)
				boxes[i].visible = true;
			
			hero.x = 2370;
			hero.y = 1210;
			hero.framesType = INTRO_5;
			
			klide.placing(24, 0, 100);
			klide.cell = 24;
			klide.row = 100;
			klide.shortcutDistance = 10000;
			App.map.sorted.push(klide);
			App.map.allSorting();
			
			fade(null, 0, 4, 0x000000);
			
			
			
			setTimeout(function():void {
				klide.initMove(33, 92, function():void {
					klide.framesType = Personage.STOP;
					
					dialogStart();
					
					setTimeout(function():void {
						hero.framesType = INTRO_6;
						App.user.quests.silentRead(Tutorial.checkIn['standup']);
					}, 2000);
				});
			}, 500);
			
			App.map.focusedOn(hero, false, null, false);
			
			var heroMapX:Number = hero.x + 250;
			var heroMapY:Number = hero.y + 100;
			
			App.map.x = -heroMapX * App.map.scaleX + App.self.stage.stageWidth / 2;
			App.map.y = -heroMapY * App.map.scaleX + App.self.stage.stageHeight / 2;
			
			App.self.setOnEnterFrame(mapMove);
			
			function mapMove(e:Event):void {
				heroMapX -= 2.5;
				heroMapY -= 1.05;
				
				App.map.x = -heroMapX * App.map.scaleX + App.self.stage.stageWidth / 2;
				App.map.y = -heroMapY * App.map.scaleX + App.self.stage.stageHeight / 2;
				
				if (Math.abs(heroMapX - hero.x) < 30) {
					App.self.setOffEnterFrame(mapMove);
					TweenLite.to(App.map, 1, { x:-hero.x * App.map.scaleX + App.self.stage.stageWidth / 2, y:-hero.y * App.map.scaleX + App.self.stage.stageHeight / 2 });
				}
			}
		}
		
		// Панорамы
		private var handlers:Array = [];
		private function tutorial4():void {
			App.self.setOffEnterFrame(App.map.sorting);
			
			// Убираем лишние объекты
			changeMapUnit(BOAT, 1, { visible:false } );
			changeMapUnit(1063, 1648, { alpha:0 } );
			
			App.map.x = -2000;
			App.map.y = -600;
			var mapX:int = App.map.x;
			var mapY:int = App.map.y;
			var time:int = 3000;
			fade(null, 0, 1.25, 0x278295);
			
			uncontrol = setTimeout(fade, time - 1500, null, 1, 1.25, 0x278295);
			
			uncontrol = TweenLite.to(App.map, time / 1000, { x:mapX - 350, y:mapY - 175, ease:Linear.easeNone, onComplete:function():void {
				App.map.x = -3800;
				App.map.y = -900;
				mapX = App.map.x;
				mapY = App.map.y;
				time = 3000;
				fade(null, 0, 1.25, 0x278295);
				
				uncontrol = setTimeout(fade, time - 1500, null, 1, 1.25, 0x278295);
				
				uncontrol = TweenLite.to(App.map, time / 1000, { x:mapX - 300, y:mapY + 160, ease:Linear.easeNone, onComplete:function():void {
					App.self.setOnEnterFrame(App.map.sorting);
					
					nextStep(2);
				}} );
			}} );
			
			dialogManage(0);
		}
		private function set uncontrol(value:*):void {
			handlers.push(value);
		}
		private function clearFirstSteps():void {
			for (var i:int = 0; i < handlers.length; i++) {
				if (handlers[i] is Number) {
					clearTimeout(handlers[i]);
				}else if (handlers[i] && (handlers[i] is TweenLite)) {
					handlers[i].kill();
				}
			}
			
			handlers = [];
		}
		
		private function tutorial5():void {
			// Коробка
			getTarget();
			target.showGlowing();
			target.showPointing('top', -120, -26);
			
			App.map.watchOff();
			App.map.focusedOn(target);
		}
		private function tutorial6():void {
			// Диалог до золота
			step = 5;
			hero.clearIcon();
			circleFocusOff();
			clearTarget();
			
			dialogStart();
			
			klide.shortcutDistance = 5;
			klide.initMove(35, 94, function():void {
				klide.framesType = Personage.STOP;
				rotateHero(klide, WUnit.LEFT);
			});
			
			//App.map.focusedOn(hero);
			//setTimeout(App.map.focusedOn, 8000, hero);
			//setTimeout(nextStep, 20000, 6);
		}
		private function tutorial7():void {
			// Золото
			App.user.quests.silentRead(Tutorial.checkIn['taketree']);
			getTarget();
			
			if (target) {
				target.showGlowing();
				App.map.focusedOn(target);
				target.visible = true;
				
				TweenLite.to(target, 1.5, { alpha:1, onComplete:function():void {
					if (target)
						target.showPointing('top', -50, -26);
				}} );
				
			}else {
				setNextStep();
			}
		}
		private function tutorial8():void {
			hero.clearIcon();
			circleFocusOff();
			clearTarget();
			
			dialogStart();
			
			setTimeout(rotateHero, 4000, klide, WUnit.LEFT);
			setTimeout(rotateHero, 4000, hero, WUnit.RIGHT);
		}
		private function tutorial8_1():void {
			
			App.self.setOnEnterFrame(mapMoveToGold);
			
			setTimeout(fade, 2000, function():void {
				App.self.setOffEnterFrame(mapMoveToGold);
				
				var unit:* = Map.findUnit(67, 1346);
				
				App.map.focusedOn(unit, false, null, false);
				App.map.x += 25;
				App.map.y += 12;
				App.self.setOnEnterFrame(mapMove);
				
				fade(null, 0, 0.75, 0x278295);
			}, 1, 0.75, 0x278295);
			setTimeout(fade, 5000, function():void {
				App.map.focusedOn(hero, false, null, false);
				App.self.setOffEnterFrame(mapMove);
				fade(function():void {
					//nextStep(9);
					nextStep(22);
				}, 0, 0.75, 0x278295);
			}, 1, 0.75, 0x278295);
			
			function mapMove(e:Event):void {
				App.map.x -= 1;
				App.map.y -= 0.5;
			}
			
			var mapMoveX:Number = -0.7;
			var mapMoveY:Number = 0.5;
			function mapMoveToGold(e:Event):void {
				App.map.x += mapMoveX;
				App.map.y += mapMoveY;
				mapMoveX -= 0.07;
				mapMoveY += 0.05;
			}
		}
		private function tutorial9():void {
			// Перед дубом
			hero.clearIcon();
			circleFocusOff();
			clearTarget();
			
			App.map.focusedOn(klide);
			
			dialogStart();
		}
		private function tutorial9_1():void {
			// Дуб
			getTarget();
			
			target.showGlowing();
			target.showPointing('top', -100, -180);
			App.map.focusedOn(target);
		}
		private function tutorial9_2():void {
			// Деревце (10)
			getTarget();
			
			target.showGlowing();
			target.showPointing('top', -75, -180);
			App.map.focusedOn(target);
			
			setTimeout(function():void {
				App.ui.leftPanel.visible = true;
				App.ui.leftPanel.x = -120;
				TweenLite.to(App.ui.leftPanel, 0.75, { x:0 } );
				
				App.ui.leftPanel.questsPanel.refresh();
			}, 1000);
		}
		private function tutorial10_2():void {
			
			// Перед золотом
			setTimeout(tutorial6, 3000);
		}
		private function tutorial10():void {
			// Хлев
			circleFocusOff();
			clearTarget();
			
			klide.shortcutDistance = 5;
			klide.initMove(58, 121, function():void {
				klide.framesType = Personage.STOP;
				rotateHero(klide, WUnit.LEFT);
			});
			
			/*setTimeout(function():void {
				target.showGlowing();
				target.showPointing('top', -138, -74);
				App.map.focusedOn(target);
			}, 2000);*/
			
			setTimeout(function():void {
				new TutorialMessageWindow( {
					title:			Locale.__e('flash:1426259573142'),
					description:	'Почини хлев. Он пригодится для приготовления кормов животным!',
					callback:		function():void {
						getTarget();
						
						target.showGlowing();
						target.showPointing('top', -138, -74);
						App.map.focusedOn(target);
					}
				}).show();
			}, 2500);
		}
		private function tutorial11():void {
			// Трава
			setTimeout(function():void {
				new TutorialMessageWindow( {
					title:			Locale.__e('flash:1426259573142'),
					description:	'Найди траву, и сделай сено в хлеву, чтобы было чем покормить овцу.',
					callback:		setNextStep
				}).show();
			}, 1000);
		}
		private function tutorial12():void {
			// Сено
			getTarget();
			
			setTimeout(function():void {
				target.showGlowing();
				target.showPointing('top', -46, -65);
				App.map.focusedOn(target);
				
				/*setTimeout(function():void {
					if (step == 11) circleFocusOn(target);
				}, 1000);*/
			}, 1000);
		}
		private function tutorial12_1():void {
			// Крафт сена
			ProductionWindow.find = 24;
			for (var i:int = 0; i < extendTargets.length; i++) {
				if (extendTargets[i] is Building) {
					extendTargets.splice(i, 1);
					i--;
				}
			}
			
			setTimeout(function():void {
				getTarget();
				
				target.showGlowing();
				target.showPointing('top', -138, -74);
				App.map.focusedOn(target);
			}, 3000);
		}
		private function tutorial13():void {
			// Овца
			Window.closeAll();
			
			setTimeout(function():void {
				getTarget();
				
				target.icon.showGlowing();
				target.showPointing('top', -48, -115);
				App.map.focusedOn(target);
				extendTargets.push(target.icon);
			}, 4000);
		}
		private function tutorial14():void {
			clearTarget();
			
			nextStep(22);
		}
		private var cornStartHarvests:Array = [];
		private function tutorial15():void {
			// Собрать кукурузку
			//if (step == 14) {
			//	setTimeout(focusOnTarget, 1500);
			//}else {
				focusOnTarget();
			//}
			
			cornStartHarvests.push(getTimer());
			
			function focusOnTarget():void {
				getTarget();
				App.map.focusedOn(target, false, null, true, null, true, 0.4);
				target.showGlowing();
				target.showPointing('top', -74, -75, App.map.mTreasure);
				
				if (step == 14) setTimeout(circleFocusOn, 800, target, {dy:-20});
			}
		}
		private function tutorial16():void {
			// Посадить пшеницу
			
			for (var i:int = 0; i < extendTargets.length; i++) {
				if (extendTargets[i] is Field) {
					extendTargets.splice(i, 1);
					i--;
				}
			}
			
			if (step == 18) {
				var timeout:int = 3000;
				var maxRange:int = 0;
				for (i = 0; i < cornStartHarvests.length; i++) {
					if (cornStartHarvests[i] + (cornStartHarvests.length - i) * 3000 > getTimer()) {
						if ((cornStartHarvests[i] + (cornStartHarvests.length - i) * 3000) - getTimer() > maxRange)
							maxRange = (cornStartHarvests[i] + (cornStartHarvests.length - i) * 3000) - getTimer();
					}
				}
				timeout += maxRange;
				
				setTimeout(focusOnTarget, timeout);
			}else {
				if (Cursor.material != 203) {
					Cursor.material = 203;
					ShopWindow.currentBuyObject.sid = 203;
					ShopWindow.currentBuyObject.type = 'Plant';
				}
				
				focusOnTarget();
			}
			
			function focusOnTarget():void {
				getTarget();
				App.map.focusedOn(target, false, null, true, null, true, 0.4);
				target.showGlowing();
				target.showPointing('top', -78, -30, App.map.mTreasure);
				
				if (step == 18) setTimeout(circleFocusOn, 800, target, {dy:20});
			}
		}
		private function tutorial17():void {
			// Медведь
			
			/*Cursor.material = 0;
			ShopWindow.currentBuyObject.sid = 0;
			ShopWindow.currentBuyObject.type = '';
			if (App.map.moved) {
				App.map.moved.uninstall();
				App.map.moved = null;
			}*/
			
			circleFocusOff();
			dialogStart();
			
			setTimeout(function():void {
				App.map.focusedOn(klide);
				rotateHero(hero, WUnit.RIGHT);
			}, 1000);
		}
		private function tutorial17_1():void {
			setTimeout(function():void {
				App.map.focusedOn(findAndGetFirst(BEAR), true);
			}, 4000);
			setTimeout(setNextStep, 6000);
		}
		private function tutorial18():void {
			dialogStart();
			
			//var field:Field = Field.findUnit(181, 3);
			App.map.focusedOn(klide);
			
			setTimeout(tutorialComplete, 8000);
		}
		private function tutorial30():void {
			clearTarget();
			
			dialogStart();
			
			setTimeout(App.map.focusedOn , 9000, hero);
		}
		private function tutorial31():void {
			setTimeout(function():void {
				dialogClear();
				
				getTarget();
				
				App.map.focusedOn(target, false, function():void {
					target.showGlowing();
					target.showPointing('top', -128, -115, App.map.mTreasure);
				}, true, null, true, 3);
				
				hero.placing(41, 0, 110);
				hero.cell = 41;
				hero.row = 110;
				App.map.sorted.push(hero, klide);
				App.map.sorting();
				//hero.shortcutDistance = 5;
				hero.initMove(44, 115, function():void {
					hero.framesType = Personage.STOP;
					rotateHero(hero, WUnit.RIGHT);
				});
				
				klide.shortcutDistance = 5;
				klide.initMove(47, 112, function():void {
					klide.framesType = Personage.STOP;
					rotateHero(klide, WUnit.LEFT);
				});
			}, 3000);
		}
		/*private function tutorial31():void {
			setTimeout(function():void {
				dialogClear();
				
				getTarget();
				
				App.map.focusedOn(target, false, function():void {
					target.showGlowing();
					target.showPointing('top', -128, -115, App.map.mTreasure);
				}, true, null, true, 3);
				
				hero.placing(50, 0, 120);
				hero.cell = 50;
				hero.row = 120;
				//hero.shortcutDistance = 5;
				hero.initMove(54, 121, function():void {
					hero.framesType = Personage.STOP;
					rotateHero(hero, WUnit.LEFT);
				});
				
				klide.shortcutDistance = 5;
				klide.initMove(58, 121, function():void {
					klide.framesType = Personage.STOP;
					rotateHero(klide, WUnit.LEFT);
				});
			}, 3000);
		}*/
		private function tutorial32():void {
			//App.map.focusedOn(hero);
			App.user.quests.silentRead(Tutorial.checkIn['kitchen']);
			nextStep(9);
		}
		
		private function redirect_0():void {
			nextStep(30);
		}
		private function redirect_1():void {
			nextStep(40);
		}
		
		
		// Dialog manager
		private var dialog:Array = [];
		
		private var dialogTimeout:int = 0;
		private var nearestDialog:int = 0;
		private var dialogTimer:int = 0;
		private var dialogSkip:int = 0;
		private var dialogList:Array = [];
		public function dialogStart():void {
			dialogClear();
			
			for (var i:int = 0; i < dialog.length; i++) {
				if (dialog[i].step == step && dialog[i].time > 0) {
					var timeout:int = setTimeout(showDialog, dialog[i].time * 1000, i);
					dialogList.push(timeout);
				}
			}
		}
		public function dialogRestart():void {
			dialogClear();
			
			var skipTime:int = -1;
			var skip:int = 0;
			var indexs:Array = [];
			
			for (var i:int = 0; i < dialog.length; i++) {
				if (dialog[i].step == step)
					indexs.push(i);
			}
			
			for (i = 0; i < indexs.length; i++) {
				if (skip < dialogSkip) {
					skip++;
				}else {
					if (skipTime == -1)
						skipTime = dialog[indexs[i]].time * 1000;
					
					var timeout:int = setTimeout(showDialog, dialog[indexs[i]].time * 1000 - skipTime, indexs[i]);
					dialogList.push(timeout);
				}
			}
		}
		private function dialogClear():void {
			if (hero) hero.clearIcon();
			if (klide) klide.clearIcon();
			if (merry) merry.clearIcon();
			if (karl) karl.clearIcon();
			
			for (var i:int = 0 ; i < dialogList.length; i++)
				clearTimeout(dialogList[i]);
			
			dialogList = [];
		}
		private function showDialog(index:int):void {
			var info:Object = dialog[index];
			
			switch(info.target) {
				case 'hero':
					if (hero) {
						hero.countBounds(hero._framesType);
						hero.iconSetPosition();
						
						var type:String = UnitIcon.DIALOG;
						var sid:int = 0;
						if (info['sid'] && App.data.storage.hasOwnProperty(info.sid)) {
							type = UnitIcon.DREAM;
							sid = info.sid;
						}
						
						hero.drawIcon(type, sid, 0, {
							fadein:			true,
							hidden:			true,
							hiddenTimeout:	info.duration * 1000,
							text:			Locale.__e(info.local),
							iconDY:			-10,
							textSettings:	{
								color:			0xfffef4,
								borderColor:	0x11243e,
								textAlign:		'center',
								autoSize:		'center',
								fontSize:		24,
								shadowSize:		1.5
							}
						});
						
						dialogManage(index);
					}
					break;
				case 'klide':
					if (klide) {
						klide.countBounds(klide._framesType);
						klide.iconSetPosition();
						
						klide.drawIcon(UnitIcon.DIALOG, 0, 0, {
							fadein:			true,
							hidden:			true,
							hiddenTimeout:	info.duration * 1000,
							text:			Locale.__e(info.local),
							iconDY:			-10,
							textSettings:	{
								color:			0xfffef4,
								borderColor:	0x42220f,
								textAlign:		'center',
								autoSize:		'center',
								fontSize:		24,
								shadowSize:		1.5
							}
						});
						
						dialogManage(index);
					}
					
					break;
				case 'merry':
					if (merry) {
						if (merry.textures) {
							merry.countBounds(merry._framesType);
							merry.iconSetPosition();
						}
						
						merry.drawIcon(UnitIcon.DIALOG, 0, 0, {
							fadein:			true,
							hidden:			true,
							hiddenTimeout:	info.duration * 1000,
							text:			Locale.__e(info.local),
							iconDY:			-10,
							textSettings:	{
								color:			0xfffef4,
								borderColor:	0x42220f,
								textAlign:		'center',
								autoSize:		'center',
								fontSize:		24,
								shadowSize:		1.5
							}
						});
						
						dialogManage(index);
					}
					
					break;
				case 'karl':
					if (karl) {
						if (karl.textures) {
							karl.countBounds(karl._framesType);
							karl.iconSetPosition();
						}
						
						karl.drawIcon(UnitIcon.DIALOG, 0, 0, {
							fadein:			true,
							hidden:			true,
							hiddenTimeout:	info.duration * 1000,
							text:			Locale.__e(info.local),
							iconDY:			-10,
							textSettings:	{
								color:			0xfffef4,
								borderColor:	0x42220f,
								textAlign:		'center',
								autoSize:		'center',
								fontSize:		24,
								shadowSize:		1.5
							}
						});
						
						dialogManage(index);
					}
					
					break;
				case 'ketrin':
					if (ketrin) {
						if (ketrin.textures) {
							ketrin.countBounds(ketrin._framesType);
							ketrin.iconSetPosition();
						}
						
						ketrin.drawIcon(UnitIcon.DIALOG, 0, 0, {
							fadein:			true,
							hidden:			true,
							hiddenTimeout:	info.duration * 1000,
							text:			Locale.__e(info.local),
							iconDY:			-10,
							textSettings:	{
								color:			0xfffef4,
								borderColor:	0x42220f,
								textAlign:		'center',
								autoSize:		'center',
								fontSize:		24,
								shadowSize:		1.5
							}
						});
						
						dialogManage(index);
					}
					
					break;
				case 'ted':
					if (ted) {
						if (ted.textures) {
							ted.countBounds(ketrin._framesType);
							ted.iconSetPosition();
						}
						
						ted.drawIcon(UnitIcon.DIALOG, 0, 0, {
							fadein:			true,
							hidden:			true,
							hiddenTimeout:	info.duration * 1000,
							text:			Locale.__e(info.local),
							iconDY:			-10,
							textSettings:	{
								color:			0xfffef4,
								borderColor:	0x42220f,
								textAlign:		'center',
								autoSize:		'center',
								fontSize:		24,
								shadowSize:		1.5
							}
						});
						
						dialogManage(index);
					}
					
					break;
			}
		}
		
		private var dialogSkipTimeout:int;
		private var dialogSkipTween:TweenLite;
		private var dialogSkipBttn:Sprite;
		private function drawSkipFader():void {
			dialogSkipBttn = new Sprite();
			dialogSkipBttn.alpha = 0;
			dialogSkipBttn.addEventListener(MouseEvent.CLICK, onDialogSkip);
			
			var back:Bitmap = Window.backing(280, 50, 14, 'dialogBacking');
			back.alpha = 0.4;
			dialogSkipBttn.addChild(back);
			
			var text:TextField = Window.drawText(Locale.__e('flash:1426177873367'), {
				width:			back.width,
				fontSize:		26,
				textAlign:		'center',
				color:			0xe0f6c5,
				borderColor:	0x0d2f4a,
				shadowSize:		2
			});
			text.y = (back.height - text.height) / 2 + 2;
			dialogSkipBttn.addChild(text);
			
			dialogSkipBttn.x = (App.self.stage.stageWidth - dialogSkipBttn.width) / 2;
			dialogSkipBttn.y = App.self.stage.stageHeight - dialogSkipBttn.height - 100;
			dialogSkipBttn.name = 'dialog_skip';
		}
		private function dialogManage(index:int):void {
			var info:Object = dialog[index];
			dialogSkip++;
			
			var time:int = 0;
			if ([1, 2].indexOf(step) >= 0) {
				time = (Config.admin) ? 20000 : 0;
			}else if (info.hasOwnProperty('skip') && info.skip == 1) {
				time = info.duration * 1000 + 100;
			}
			
			if (time > 0) {
				if (dialogSkipTimeout) clearTimeout(dialogSkipTimeout);
				dialogSkipTimeout = setTimeout(dialogSkipClear, time);
				
				if (dialogSkipTween) dialogSkipTween.kill();
				if (!App.self.contextContainer.contains(dialogSkipBttn)) {
					dialogSkipBttn.x = (App.self.stage.stageWidth - dialogSkipBttn.width) / 2;
					dialogSkipBttn.y = App.self.stage.stageHeight - dialogSkipBttn.height - 100;
					App.self.contextContainer.addChild(dialogSkipBttn);
				}
				
				dialogSkipTween = TweenLite.to(dialogSkipBttn, 0.25, { alpha:1, onComplete:function():void {
					dialogSkipTween = null;
				}});
			}else {
				dialogSkipClear();
			}
			
			if (info.hasOwnProperty('next') && info.next > step) {
				if (info.hasOwnProperty('nextTimeout') && info.nextTimeout > 0) {
					setTimeout(nextStep, info.nextTimeout * 1000, info.next);
				}else{
					nextStep(info.next);
				}
			}
		}
		private function dialogSkipClear():void {
			if (dialogSkipTimeout) {
				clearTimeout(dialogSkipTimeout);
				dialogSkipTimeout = 0;
			}
			
			if (dialogSkipBttn && App.self.contextContainer.contains(dialogSkipBttn)) {
				dialogSkipTween = TweenLite.to(dialogSkipBttn, 0.25, { alpha:0, onComplete:function():void {
					dialogSkipTween = null;
					if (App.self.contextContainer.contains(dialogSkipBttn))
						App.self.contextContainer.removeChild(dialogSkipBttn);
				}});
			}
		}
		private function onDialogSkip(e:MouseEvent):void {
			if ([1, 2].indexOf(step) >= 0) {
				clearFirstSteps();
				dialogClear();
				setNextStep();
			}else {
				dialogRestart();
			}
		}
		
		
		private function copyMap(callback:Function):void {
			if (App.map.mSort.numChildren < 100)
				trace('a');
			
			map = new Bitmap();
			map.bitmapData = new BitmapData(App.map.bitmap.width, App.map.bitmap.height, true, App.map.bitmap.bitmapData.getPixel(0, 0));
			
			for (var i:int = 0; i < App.user.personages.length; i++) 
				App.user.personages[i].visible = false;
			
			map.bitmapData.draw(App.map);
			
			for (i = 0; i < App.user.personages.length; i++) 
				App.user.personages[i].visible = true;
			
			for (i = 0; i < 40; i++)
				map.bitmapData.draw(map, new Matrix(1, 0, 0, 1, i * 0.9, -i * 1.8), new ColorTransform(1, 1, 1, 0.02));
			
			callback();
		}
		
		public static var target:*;
		public static function initTargets(objects:Array = null):void {
			if (!App.user.quests.tutorial || !App.tutorial) return;
			
			if (!objects) objects = [];
			
			var find:Boolean = false;
			for (var i:int = 0; i < objects.length; i++) {
				var object:* = objects[i];
				while (object.parent) {
					
					if (object is UnitIcon) {
						if (target && target.hasOwnProperty('icon') && target.icon == object) {
							find = true;
							if (object.__hasGlowing) object.hideGlowing();
							if (object.__hasPointing) object.hidePointing();
							App.tutorial.setExtendTarget(target);
							
							//object.onClick();
							object.target.hidePointing();
						}
					}else if (object == target) {
						find = true;
						if (object.hasOwnProperty('click') && (object.click is Function)) object.click();
						if (target.__hasGlowing) target.hideGlowing();
						if (target.__hasPointing) target.hidePointing();
						App.tutorial.setExtendTarget(target);
					}else if ((target is String) && object.name == target) {
						find = true;
						if (object.__hasGlowing) object.hideGlowing();
						if (object.__hasPointing) object.hidePointing();
						App.tutorial.setExtendTarget(target);
					}
					
					if (find) {
						//target = null;
						circleFocusOff();
						
						break;
					}else if (object.parent) {
						object = object.parent;
					}
				}
			}
			
			if (target && (target is Unit) && !find)
				circleFocusOn(target);
			
			if (mainTutorialComplete)
				missTarget();
			
			if (App.tutorial.dialogSkipBttn && App.tutorial.dialogSkipBttn.parent && App.tutorial.dialogSkipBttn.alpha == 1)
				App.tutorial.dialogRestart();
		}
		public function clearTarget(_target:* = null):void {
			if (target && (target is LayerX)) {
				target.hideGlowing();
				target.hidePointing();
			}else if (_target && (_target is LayerX)) {
				_target.hideGlowing();
				_target.hidePointing();
			}
			
			target = null;
		}
		public function getTarget():void {
			var find:Boolean = false;
			var targetsIDs:Array = [];
			for (var i:int = 0; i < targets.length; i++) {
				if (targets[i].step == step)
					targetsIDs.push(i);
			}
			
			for (i = 0; i < targetsIDs.length; i++) {
				//if (extendTargets.indexOf(targetsIDs[i]) >= 0) continue;
				
				var object:Object = targets[targetsIDs[i]];
				if (object.hasOwnProperty('sid') && object.hasOwnProperty('id')) {
					if (App.data.storage[object.sid].type == 'Field') {
						target = Field.findUnit(object.sid, object.id);
					}else {
						target = Map.findUnit(object.sid, object.id);
						
						if (target && target.hasOwnProperty('icon') && target.icon && target.icon.parent) {
							extendTargets.push(target.icon);
						}/*else {
							var tg:Array = Map.findUnits([65,66,67,68,69,70,71]);
							if (tg.length > 0) {
								for each (var unt:* in tg) {
									var node:AStarNodeVO = App.map._aStarNodes[unt.coords.x][unt.coords.z]; 
									if (node.open) {
										target = unt;
										if (target && target.hasOwnProperty('icon') && target.icon && target.icon.parent) {
											extendTargets.push(target.icon);
										}
										break;
									}
								}
							}
						}*/
					}
				}else if (object.hasOwnProperty('name')) {
					target = object.name;
				}
				
				if (target && extendTargets.indexOf(target) < 0) {
					find = true;
					break;
				}
			}
			
			if (targetsIDs.length > 0 && !find) {
				setNextStep();
			}
		}
		public function setExtendTarget(target:*):void {
			if (target && extendTargets.indexOf(target) < 0)
				extendTargets.push(target);
			
			getTarget();
		}
		
		public static function tutorialBttn(bttn:*):Boolean {
			var list:Array = ['sp_sound', 'sp_music', 'sp_panel', 'LevelUpWindow_okBttn', 'QuestRewardWindow_okBttn', 'DayliBonusWindow_okBttn', 'RewardWindow_okBttn', 'tmw_okBttn', 'dialog_skip', 'gw_bttn'];
			
			if (App.user.id == '120635122') list.push('sp_fullscreen');
			
			if (App.tutorial && list.indexOf(bttn.name) >= 0)
				return true;
			
			if (App.tutorial && (Tutorial.target == bttn.name || App.tutorial.extendTargets.indexOf(bttn.name) >= 0 || App.tutorial.extendTargets.indexOf(bttn) >= 0)) {
				return true;
			}
			
			return false;
		}
		
		
		private function tutorialComplete():void {
			App.user.quests.tutorial = false;
			App.tutorial = null;
			
			App.ui.leftPanel.visible = true;
			App.ui.rightPanel.visible = true;
			App.ui.upPanel.visible = true;
			App.ui.bottomPanel.visible = true;
			App.ui.systemPanel.visible = true;
			
			clearTarget();
			circleFocusOff();
			
			saveStep(1);
			
			klide.workStatus = WorkerUnit.FREE;
			
			App.user.quests.openMessages();
			//App.ui.leftPanel.resize();
			
			for (var i:int = 0; i < App.user.quests.opened.length; i++) {
				if (App.data.quests[App.user.quests.opened[i].id].bonus)
					App.user.quests.openWindow(App.user.quests.opened[i].id);
			}
			
			/*for (i = 0; i < App.ui.leftPanel.questsPanel.icons.length; i++) 
				App.ui.leftPanel.questsPanel.icons[i].glowIcon('', 0, false);*/
			
			if (App.self.contextContainer.contains(fader))
				App.self.contextContainer.removeChild(fader);
		}
		private function findAndGetFirst(sid:int):Unit {
			var array:Array = Map.findUnits([sid]);
			if (array.length > 0)
				return array[0];
			
			return null;
		}
		private function changeMapUnit(sid:int, id:int, params:Object = null):* {
			var unit:* = Map.findUnit(sid, id);
			if (unit && params) {
				for (var s:* in params) {
					if (unit.hasOwnProperty(s))
						unit[s] = params[s];
				}
			}
			return unit;
		}
		
		private static var circleFader:Sprite;
		private static var circleUnit:*;
		public static function circleFocusOn(unit:*, params:Object = null):void {
			if (!unit || circleUnit == unit) return;
			
			/*if (circleFader && circleFader.parent == App.self.contextContainer) {
				TweenLite.to(circleFader, 0.25, { alpha:0, onComplete:function():void {
					App.self.contextContainer.removeChild(circleFader);
					circleFader = null;
					circleFocusOn(unit);
				}} );
				return;
			}*/
			
			circleUnit = unit;
			
			if (unit.hasOwnProperty('bounds') && !unit.bounds)
				unit.countBounds();
			
			var width:int = unit.bounds.w * 1.5;
			var height:int = unit.bounds.h * 1.5;
			
			if (unit.sid == 196)
				params = { dx:-15, dy:-40 };
			
			circleDraw(new Point(App.self.stage.stageWidth / 2, App.self.stage.stageHeight / 2), height, params);
		}
		public static function circleDraw(point:Point = null, radius:Number = 50, params:Object = null):void {
			if (circleFader && circleFader.parent == App.self.contextContainer) return;
			
			var _params:Object = { dx:0, dy:0 };
			
			if (params) {
				for (var s:* in params)
					_params[s] = params[s];
			}
			
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(Capabilities.screenResolutionX * 2, Capabilities.screenResolutionX * 2);
			
			var alphas:Array = [0, 0, 0, 255];
			alphas[1] = 255 * radius * 0.25 / App.self.stage.stageHeight;
			alphas[2] = alphas[1] * 1.25;
			
			circleFader = new Sprite();
			
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill(GradientType.RADIAL, [0, 0, 0, 0], [0, 0, 0.7, 0.7], alphas, matrix);
			shape.graphics.drawRect(0, 0, Capabilities.screenResolutionX * 2, Capabilities.screenResolutionX * 2);
			shape.graphics.endFill();
			shape.filters = [new BlurFilter(4, 4, 3)];
			
			var bitmap:Bitmap = new Bitmap(new BitmapData(Capabilities.screenResolutionX * 2, Capabilities.screenResolutionX * 2, true, 0));
			bitmap.bitmapData.draw(shape);
			bitmap.x = -bitmap.width / 2;
			bitmap.y = -bitmap.height / 2;
			circleFader.addChild(bitmap);
			
			App.self.contextContainer.addChild(circleFader);
			App.self.contextContainer.mouseEnabled = false;
			App.self.contextContainer.mouseChildren = false;
			
			circleFader.alpha = 0;
			circleFader.scaleX = 1.5;
			circleFader.scaleY = 1.5;
			circleFader.x = point.x + _params.dx;
			circleFader.y = point.y + _params.dy;
			
			TweenLite.to(circleFader, 0.35, { alpha:1, scaleX:1, scaleY:1 } );
		}
		public static function circleFocusOff(quick:Boolean = false):void {
			App.self.contextContainer.mouseEnabled = true;
			App.self.contextContainer.mouseChildren = true;
			
			if (circleFader && circleFader.parent == App.self.contextContainer) {
				if (quick) {
					if (circleFader.parent) App.self.contextContainer.removeChild(circleFader);
				}else{
					TweenLite.to(circleFader, 0.2, { alpha:0, onComplete:function():void {
						if (circleFader.parent) App.self.contextContainer.removeChild(circleFader);
					}} );
				}
			}
		}
		
		public static var missHandlers:Vector.<Function> = new Vector.<Function>;
		public static function missTarget():void {
			for (var i:int = 0; i < missHandlers.length; i++)
				missHandlers[i]();
		}
		
		public static function boxInterface():void {
			if (App.user.quests.tutorial) {
				var boxes:Array = Map.findUnits([Tutorial.BOX]);
				for (var i:int = 0; i < boxes.length; i++)
					boxes[i].click();
			}
		}
		
		// Mode
		public function shopMode(settings:Object):Object {
			if (step == 18) {
				settings['find'] = [203];
			}
			
			return settings;
		}
		
		private function saveStep(complete:int = 0):void {
			if ([0,1,2].indexOf(step) >= 0 || App.user.quests.data.hasOwnProperty(5)) return;
			
			var tutorial:Object = App.user.storageRead('tutorial', { } );
			
			mainTutorialComplete = Boolean(complete);
			tutorial['c'] = complete;
			tutorial['s'] = step;
			App.user.storageStore('tutorial', tutorial, true);
			
			if (complete) {
				if (App.social == 'FB') {
					ExternalApi.og('finish', 'tutorial');
				}
			}
		}
		private function prepareScene():void {
			drawSkipFader();
			
			if (step >= 8) {
				App.ui.upPanel.visible = true;
				App.ui.bottomPanel.visible = true;
				App.ui.systemPanel.visible = true;
				
				fade(null, 0, 0.25, 0x278295);
				
				hero.placing(41, 0, 110);
				hero.cell = 41;
				hero.row = 110;
				hero.textures = originalHeroTexture;
				hero.framesType = Personage.STOP;
				rotateHero(hero, WUnit.LEFT);
				
				klide.placing(47, 0, 112);
				klide.framesType = Personage.STOP;
				klide.cell = 47;
				klide.row = 112;
				rotateHero(klide, WUnit.RIGHT);
				
				App.map.focusedOn(hero, false, null, false);
				App.map.sorted.push(hero, klide);
			}else if (step > 3) {
				App.ui.upPanel.visible = true;
				App.ui.bottomPanel.visible = true;
				App.ui.systemPanel.visible = true;
				
				fade(null, 0, 0.25, 0x278295);
				
				/*var boxes:Array = Map.findUnits([BOX]);
				for (var i:int = 0; i < boxes.length; i++)
					boxes[i].visible = false;*/
				
				hero.x = 2370;
				hero.y = 1210;
				hero.textures = originalHeroTexture;
				hero.framesType = Personage.STOP;
				rotateHero(hero, WUnit.LEFT);
				
				klide.placing(33, 0, 92);
				klide.cell = 33;
				klide.row = 92;
				klide.shortcutDistance = 10000;
				klide.framesType = Personage.STOP;
				rotateHero(klide, WUnit.RIGHT);
				
				App.map.focusedOn(hero, false, null, false);
				App.map.sorted.push(hero, klide);
			}
		}
		
		public function rotateHero(hero:*, side:int = 0):void {
			if (side == 1) {
				hero.framesFlip = side;
				hero.sign = -1;
				hero.bitmap.scaleX = -1;
			}else{
				hero.framesFlip = side;
				hero.sign = 1;
				hero.bitmap.scaleX = 1;
			}
			
			hero.update();
		}
		
		
		
		public function resize():void {
			if (circleFader && circleFader.parent) {
				circleFader.x = App.self.stage.stageWidth / 2;
				circleFader.y = App.self.stage.stageHeight / 2;
			}
			
			if (target && (target is Unit)) {
				App.map.focusedOn(target, false, null, false);
			}else if(hero) {
				App.map.focusedOn(hero, false, null, false);
			}
		}
		
		
		// For quests
		public static var showedQuests:Array = [];
		private static var tutorialQuestWait:int = 0;
		public static function tutorialQuests():void {
			if (!Map.ready) {
				if (tutorialQuestWait > 0) clearTimeout(tutorialQuestWait);
				tutorialQuestWait = setTimeout(tutorialQuests, 500);
				return;
			}
			
			var find:Boolean = false;
			for (var i:int = 0; i < App.user.quests.opened.length; i++) {
				switch(App.user.quests.opened[i].id) {
					case 28:
						if (App.map.id == User.HOME_WORLD) {
							startQuest28();
							find = true;
						}
						break;
					case 2:
						if (App.map.moved && (App.map.moved is Tree)) {
							startQuest2();
							find = true;
						}
						break;
					case 54:
						if (App.map.id == User.HOME_WORLD)
							startQuest54();
						
						find = true;
						break;
					case 23:
						if (App.map.id == User.HOME_WORLD && App.map.moved && (App.map.moved is Building))
							startQuest23();
						
						find = true;
						break;
					case 55:
						if (App.map.moved && (App.map.moved is Animal)) {
							sheeps = App.user.quests.data[55][1] || 0;
							startQuest55();
						}
						
						break;
					case 32:
						if (App.map.id == User.HOME_WORLD) {
							startQuest32();
							find = true;
						}
						break;
					case 5:
						if (App.map.id == User.HOME_WORLD) {
							startQuest5();
							find = true;
						}
						break;
					case 157:
						if (App.user.quests.data[157].finished == 0) {
							startQuest157();
							find = true;
						}
						break;
					case 234:
						if (App.map.id == User.HOME_WORLD)
							startQuest234();
						
						find = true;
						break;
					case 340:
						//if (App.map.id == User.HOME_WORLD)
							setTimeout(startQuest340, 2000);
						
						find = true;
						break;
					case 411:
						if (App.user.quests.data[411].finished == 0 && App.map.id == 1122) {
							startQuest411();
							find = true;
						}
						break;
					case 925: // 923
						if (App.user.quests.isOpen(925) && App.map.id == 418) {	// Озеро
							startQuest923();
							find = true;
						}
						break;
					case 934: // 925
						if (App.user.quests.isOpen(934) && App.map.id == Travel.SAN_MANSANO) {	// Озеро
							startQuest925();
							find = true;
						}
						break;
					case 1170:
						if (App.map.id == 3060)
						{
							startQuest1170();
							find = true;
						}
						break;
					default:
				}
			}
			
			if (!find && mainTutorialComplete && App.user.quests.tutorial) {
				App.user.quests.tutorial = false;
			}
		}
		
		// Поход к Мерри
		private static function startQuest28():void {
			if (App.user.quests.tutorial) return;
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			Window.closeAll();
			
			App.tutorial.quest28_5();
		}
		private function quest28_0():void {
			circleFocusOff(true);
			missHandlers.splice(0, missHandlers.length);
			
			setTimeout(function():void {
				initHeros();
				step = 40;
				dialogStart();
			}, 1000);
		}
		private function quest28_1():void {
			setTimeout(function():void {
				circleFocusOff();
				getTarget();
				
				if (App.user.quests.data[28].finished > 0) {
					nextStep(44);
				}else if (target) {
					App.map.focusedOn(target);
					target.showGlowing();
					
					if (target.sid == 304) {
						target.showPointing('top', -170, -125);
					}else if (target.sid == 86) {
						target.showPointing('top', -70, -45);
					}else {
						target.showPointing('top', -138, -74);
					}
				}
			}, 3500);
		}
		private function quest28_2():void {
			getTarget();
			
			setTimeout(function():void {
				App.ui.bottomPanel.bttnMainHome.showGlowing();
				App.ui.bottomPanel.bttnMainHome.showPointing('top', 0, 0, App.ui.bottomPanel.bttnMainHome.parent);
			}, 3000);
		}
		private function quest28_3():void {
			App.user.quests.tutorial = false;
			setTimeout(function():void {
				if (App.user.quests.isOpen(23)) {
					App.user.quests.openWindow(23);
				}
			}, 3000);
		}
		private function quest28_4():void {
			if (App.ui.bottomPanel.friendsPanel.start != 0) {
				App.ui.bottomPanel.friendsPanel.start = 0;
				App.ui.bottomPanel.friendsPanel.showFriends();
			}
			
			var merryIcon:*;
			
			setTimeout(function():void {
				//new GoalWindow( { quest:App.data.quests[], width:595, height:360 } ).show();
				
				// Найти Мерри (ID = 1) и вызвать showPointing 
				for (var i:int = 0; i < App.ui.bottomPanel.friendsPanel.friendsItems.length; i++) {
					if (App.ui.bottomPanel.friendsPanel.friendsItems[i].uid == '1') {
						merryIcon = App.ui.bottomPanel.friendsPanel.friendsItems[i];
						
						App.tutorial.extendTargets.push(merryIcon);
						
						merryIcon.showGlowing();
						merryIcon.showPointing('top', 63, -80, App.ui.bottomPanel.friendsPanel);
						
						App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
						
						missHandlers.push(missHandler);
					}
				}
			}, 1000);
			
			function onMapComplete(e:AppEvent):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				
				if (Map.ready && App.map.id == User.MERRY_WORLD) {
					if (!App.user.quests.data[28].hasOwnProperty(2)) App.user.quests.data[28][2] = 0;
					App.user.quests.data[28][2] = 1;
					
					for (var i:int = 0; i < App.ui.bottomPanel.friendsPanel.friendsItems.length; i++) {
						if (App.ui.bottomPanel.friendsPanel.friendsItems[i].uid == '1') {
							App.ui.bottomPanel.friendsPanel.friendsItems[i].hideGlowing();
							App.ui.bottomPanel.friendsPanel.friendsItems[i].hidePointing();
						}
					}
					App.user.quests.tutorial = false;
					
					setTimeout(function():void {
						App.ui.bottomPanel.bttnMainHome.showGlowing();
						App.ui.bottomPanel.bttnMainHome.showPointing('top', 0, 0, App.ui.bottomPanel.bttnMainHome.parent);
					}, 3000);
					//App.tutorial.quest28_0();
				}
			}
			
			function missHandler():void {
				Window.closeAll();
				var point:Point = BonusItem.localToGlobal(merryIcon);
				circleDraw(point, 90);
			}
		}
		private function quest28_5():void {
			if (!Map.ready) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
			}else {
				onMap();
			}
			
			function onMap(e:AppEvent = null):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
				
				setTimeout(function():void {
					var merry:Personage = new Personage( { id:10, sid:Hero.MERRY, x:58, z:122, alien:Hero.MERRY, aka:'' }, 'merry');
					merry.framesType = Personage.WALK;
					//App.map.watchOn(merry);
					//merry.rotateTo( { x:merry.x + 1 } );
					
					merry.initMove(61, 122, function():void {
						merry.initMove(67, 128, function():void {
							merry.framesType = Personage.STOP;
							//App.map.watchOff();
							
							step = 38;
							dialogStart();
						});
					});
					
					initHeros();
					
					hero.placing(72, 0, 124);
					hero.cell = 72;
					hero.row = 124;
					hero.rotateTo( { x:merry.x - 1 } );
					
					App.map.sorted.push(hero, merry);
					App.map.sorting();
					
					App.map.focusedOn({x:hero.x - 80, y:hero.y});
				}, 1000);
			}
		}
		
		// Посадака яблони
		private static function startQuest2():void {
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			
			App.self.addEventListener(MouseEvent.MOUSE_UP, onClick);
			
			var place:LayerX = new LayerX();
			place.graphics.beginFill(0x00FF00, 0.4);
			place.graphics.drawEllipse(0, 0, 120, 50);
			place.graphics.endFill();
			place.x = 2625;
			place.y = 2020;
			
			var timeout:int = setTimeout(function():void {
				App.map.mField.addChild(place);
				App.map.focusedOn(place);
				place.showPointing('top', 0, -35);
			}, 250);
			
			function onClick(e:MouseEvent):void {
				App.self.removeEventListener(MouseEvent.MOUSE_UP, onClick);
				clearTimeout(timeout);
				
				place.hidePointing();
				
				if (place.parent == App.map.mField) {
					App.map.mField.removeChild(place);
				}
			}
		}
		
		// Установка здания
		private static function startQuest23():void {
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			
			App.self.addEventListener(MouseEvent.MOUSE_UP, onClick);
			
			var place:LayerX = new LayerX();
			place.graphics.beginFill(0x00FF00, 0.4);
			place.graphics.drawEllipse(0, 0, 300, 150);
			place.graphics.endFill();
			place.x = 2090;
			place.y = 1195;
			
			var timeout:int = setTimeout(function():void {
				App.map.mField.addChild(place);
				App.map.focusedOn(place);
				place.showPointing('top', 0, -50);
			}, 250);
			
			function onClick(e:MouseEvent):void {
				App.self.removeEventListener(MouseEvent.MOUSE_UP, onClick);
				clearTimeout(timeout);
				
				place.hidePointing();
				
				if (place.parent == App.map.mField) {
					App.map.mField.removeChild(place);
				}
			}
		}
		
		
		
		// Установка здания
		public static var sheeps:int = 0;
		private static function startQuest55():void {
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onClick);
			
			var place:LayerX = new LayerX();
			place.graphics.beginFill(0x00FF00, 0.4);
			place.graphics.drawEllipse(0, 0, 100, 50);
			place.graphics.endFill();
			
			if (sheeps == 0) {
				place.x = 1860;
				place.y = 2020;
			}else {
				place.x = 1915;
				place.y = 2045;
			}
			
			var timeout:int = setTimeout(function():void {
				App.map.mField.addChild(place);
				App.map.focusedOn(place);
				place.showPointing('top', 0, -35);
			}, 250);
			
			function onClick(e:AppEvent):void {
				App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onClick);
				clearTimeout(timeout);
				
				place.hidePointing();
				
				if (place.parent == App.map.mField) {
					App.map.mField.removeChild(place);
				}
				
				sheeps++;
				
				if (App.map.moved && (App.map.moved is Animal)) {
					if (sheeps >= 2) {
						App.map.moved.uninstall();
						App.map.moved = null;
						sheeps = 0;
					}else {
						startQuest55();
					}
				}
			}
		}
		
		// Сценарий с золотом
		public static function startQuest54():void {
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			
			if (!Map.ready) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}else {
				onMapComplete();
			}
			
			function onMapComplete(e:AppEvent = null):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				
				App.tutorial.quest54_0();
			}
		}
		public function quest54_0():void {
			Window.closeAll();
			
			App.user.quests.openWindow(54);
			
			extendTargets.push('QuestWindow_helpBttn');
		}
		public function quest54_1():void {
			step = 50;
			
			getTarget();
			
			if (!target || App.user.stock.count(15) == 0) {
				App.user.quests.scoreQuest(54,1,27);
				quest54_2();
				return;
			}
			
			if (target) {
				App.map.focusedOn(target, false, function():void {
					if (target) {
						target.showGlowing();
						target.showPointing('top', -40, -50);
					}
				});
			}
		}
		public function quest54_2():void {
			App.self.setOnTimer(timer);
			target = null;
			
			function timer():void {
				if (App.user.quests.data[54] && App.user.quests.data[54].finished > 0) {
					App.user.quests.tutorial = false;
					App.self.setOffTimer(timer);
				}
			}
		}
		
		// Сцена с егерями
		private static function startQuest32():void {
			var huts:Array = Map.findUnits([160]);
			var hungry:Boolean = true;
			if (huts.length > 0 && huts[0].workers.hasOwnProperty(0) && huts[0].workers[0].finished > App.time)
				hungry = false;
			
			if (App.user.stock.count(Stock.FOOD) < 10 || huts.length > 1 || !hungry) return;
			if (App.user.quests.tutorial) return;
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			
			if (!Map.ready) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			}else {
				onMapComplete();
			}
			
			function onMapComplete(e:AppEvent = null):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
				
				App.tutorial.quest32_0();
			}
		}
		public function quest32_0():void {
			
			step = 60;
			getTarget();
			
			var needOpenWindow:Boolean = true;
			for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
				var window:* = App.self.windowContainer.getChildAt(i);
				if (window.settings.hasOwnProperty('qID') && window.settings.qID == 32) needOpenWindow = false;
			}
			
			if (needOpenWindow) {
				Window.closeAll();
				App.user.quests.openWindow(32);
			}
		}
		public function quest32_1():void {
			circleFocusOff();
			
			target = findAndGetFirst(160);
		}
		public function quest32_2():void {
			App.user.quests.tutorial = false;
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, onClick);
			
			var place:LayerX = new LayerX();
			place.graphics.beginFill(0x00FF00, 0.4);
			place.graphics.drawEllipse(0, 0, 120, 60);
			place.graphics.endFill();
			
			place.x = 2015;
			place.y = 1560;
			
			var timeout:int = setTimeout(function():void {
				App.map.mField.addChild(place);
				App.map.focusedOn(place);
				place.showPointing('top', 0, -35);
			}, 250);
			
			function onClick(e:AppEvent):void {
				App.self.removeEventListener(AppEvent.ON_MOUSE_UP, onClick);
				
				clearTimeout(timeout);
				place.hidePointing();
				
				if (place.parent == App.map.mField) {
					App.map.mField.removeChild(place);
				}
			}
		}
		
		private static function startQuest5():void {
			Tutorial.init();
			
			if (App.user.quests.currentMID == 2) {
				App.tutorial.fieldClicks = [];
				App.tutorial.quest5_1();
			}
		}
		public var fieldClicks:Array = [];
		public function quest5_0(field:Field):void {
			if (fieldClicks.length >= 1) return;
			
			// Сортирует массив объектов на карте по возрастанию удаленности от объекта unit
			var unit:* = App.user.hero;
			function remoteness(u1:*, u2:*):int {
				if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) > Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
					return 1;
				}else if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) < Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
					return -1;
				}else {
					return 0;
				}
			}
			
			fieldClicks.push(field);
			
			var fields:Array = Field.findFields();
			fields.sort(remoteness);
			for (var i:int = 0; i < fields.length; i++) {
				if (fieldClicks.indexOf(fields[i]) < 0 && fields[i].plant && fields[i].plant.ready) {
					App.map.focusedOn(fields[i], true);
				}
			}
		}
		public function quest5_1(field:Field = null):void {
			if (fieldClicks.length >= 2) return;
			
			// Сортирует массив объектов на карте по возрастанию удаленности от объекта unit
			var unit:* = App.user.hero;
			function remoteness(u1:*, u2:*):int {
				if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) > Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
					return 1;
				}else if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) < Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
					return -1;
				}else {
					return 0;
				}
			}
			
			fieldClicks.push(field);
			
			var fields:Array = Field.findFields();
			fields.sort(remoteness);
			for (var i:int = 0; i < fields.length; i++) {
				if (fieldClicks.indexOf(fields[i]) >= 0) continue;
				
				if (fields[i].formed && (!fields[i].plant || !fields[i].plant.planted)) {
					fields[i].showPointing('top', -78, -30, App.map.mTreasure);
					App.map.focusedOn(fields[i], true, function():void {});
					break;
				}
			}
		}
		
		// Поход к друзьям (Мерри)
		public static function startQuest49():void {
			//if (App.user.quests.tutorial) return;
			//App.user.quests.tutorial = true;
			Tutorial.init();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			Window.closeAll();
			
			App.tutorial.quest49_0();
		}
		private function quest49_0():void {
			App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
			
			if (Map.ready) onMap();
			
			var merryIcon:*;
			
			function onMap(e:AppEvent = null):void {
				
				if (App.user.mode == User.GUEST) {
					App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
					
					for (var i:int = 0; i < App.ui.bottomPanel.friendsPanel.friendsItems.length; i++) {
						if (App.ui.bottomPanel.friendsPanel.friendsItems[i].uid == '1') {
							App.ui.bottomPanel.friendsPanel.friendsItems[i].hideGlowing();
							App.ui.bottomPanel.friendsPanel.friendsItems[i].hidePointing();
						}
					}
					
					quest49_1();
				}else{
					if (App.ui.bottomPanel.friendsPanel.start != 0) {
						App.ui.bottomPanel.friendsPanel.start = 0;
						App.ui.bottomPanel.friendsPanel.showFriends();
					}
					
					setTimeout(function():void {
						// Найти Мерри (ID = 1) и вызвать showPointing 
						for (var i:int = 0; i < App.ui.bottomPanel.friendsPanel.friendsItems.length; i++) {
							if (App.ui.bottomPanel.friendsPanel.friendsItems[i].uid == '1') {
								merryIcon = App.ui.bottomPanel.friendsPanel.friendsItems[i];
								
								App.tutorial.extendTargets.push(merryIcon);
								
								merryIcon.showGlowing();
								merryIcon.showPointing('top', 63, -80, App.ui.bottomPanel.friendsPanel);
							}
						}
					}, 250);
				}
			}
		}
		private function quest49_1():void {
			var golds:Array = Map.findUnits(Resource.golden);
			var index:int = 0;
			var timeout:int = 0;
			
			App.self.addEventListener(AppEvent.ON_MOUSE_UP, tutorialOff);
			
			timeout = setTimeout(showGold, 2000);
			
			function showGold():void {
				if (golds.length <= index) return;
				
				// Сортирует массив объектов на карте по возрастанию удаленности от объекта unit
				var unit:* = App.user.hero;
				function remoteness(u1:*, u2:*):int {
					if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) > Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
						return 1;
					}else if (Math.sqrt((unit.x - u1.x) * (unit.x - u1.x) + (unit.y - u1.y) * (unit.y - u1.y)) < Math.sqrt((unit.x - u2.x) * (unit.x - u2.x) + (unit.y - u2.y) * (unit.y - u2.y))) {
						return -1;
					}else {
						return 0;
					}
				}
				golds.sort(remoteness);
				
				App.map.focusedOn(golds[index], true, function():void {
					tutorialOff();
				});
			}
			
			function tutorialOff(e:AppEvent = null):void {
				clearTimeout(timeout);
				App.self.removeEventListener(AppEvent.ON_MOUSE_UP, tutorialOff);
				App.user.quests.tutorial = false;
			}
		}
		
		// Клайд на новом острове
		private static var mapHandler157:Boolean = false;
		public static function startQuest157():void {
			if (App.map.id == 418) {
				onMap();
			}else if (!mapHandler157) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
				mapHandler157 = true;
			}
			
			Tutorial.init();
			App.tutorial.drawSkipFader();
			
			function onMap(e:AppEvent = null):void {
				
				if (App.map.id == 418 && App.user.quests.isOpen(157)) {
					App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
					
					if (App.user.quests.tutorial) return;
					App.user.quests.tutorial = true;
					setTimeout(function():void {
						App.tutorial.initHeros();
						App.ui.leftPanel.questsPanel.clearIconsGlow();
						
						App.tutorial.quest157_5();
					}, 100);
				}
			}
			
		}
		private function quest157_0():void {
			
			hero.placing(49, 0, 68);
			hero.cell = 49;
			hero.row = 68;
			App.map.sorted.push(hero);
			App.map.sorting();
			
			hero.alpha = 0;
			TweenLite.to(hero, 1.5, { alpha:1 } );
			
			hero.initMove(49, 45, function():void {
				hero.framesType = Personage.STOP;
				rotateHero(hero, WUnit.RIGHT);
				step = 71;
				dialogStart();
				setTimeout(function():void {
					App.map.focusedOn(karl, false);
				}, 4000);
				
				if (merry) merry.uninstall();
			});
			
			var position:Object = IsoConvert.isoToScreen(49, 45, true);
			App.map.focusedOn( {
				x:position.x,
				y:position.y
			});
		}
		private function quest157_1():void {
			hero.initMove(karl.coords.x - 1, karl.coords.z + 5, function():void {
				hero.framesType = Personage.STOP;
				rotateHero(hero, WUnit.RIGHT);
				
				setTimeout(quest157_2, 3000);
			});
		}
		private function quest157_2():void {
			step = 74;
			dialogStart();
		}
		private function quest157_4():void {
			App.user.quests.tutorial = false;
			
			if (App.user.quests.isOpen(157)) {
				App.user.quests.openWindow(157);
			}
		}
		private function quest157_5():void {
			merry = new Personage( { id:10, sid:Hero.MERRY, x:hero.coords.x - 1, z:hero.coords.z + 1, alien:Hero.MERRY, aka:'' }, 'merry');
			merry.framesType = 'stop_pause';
			merry.rotateTo(hero);
			
			step = 70;
			dialogStart();
		}
		
		//появление моряка
		private static function startQuest234():void {
			if (App.user.quests.tutorial) return;
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			Window.closeAll();
			
			App.tutorial.quest234_0();
		}
		
		private function quest234_0():void {
			if (!Map.ready) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
			}else {
				onMap();
			}
			
			function onMap(e:AppEvent = null):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
				
				setTimeout(function():void {
					var seaman:Personage = new Personage( { id:10, sid:Hero.SEAMAN, x:58, z:122, alien:Hero.SEAMAN, aka:'' }, 'seaman');
					seaman.framesType = Personage.WALK;
					
					seaman.initMove(61, 122, function():void {
						seaman.initMove(67, 128, function():void {
							seaman.framesType = Personage.STOP;	
							
							App.user.quests.tutorial = false;
							var questInfo:Object = App.data.quests[234];
							new TutorialMessageWindow( {
								title:			questInfo.title,
								description:	questInfo.description,
								personage:		(App.data.personages.hasOwnProperty(questInfo.character)) ? App.data.personages[questInfo.character].preview : App.data.personages[1].preview,
								callback:		function():void {
									App.user.quests.readEvent(234, function():void {
										seaman.free();
										App.map.removeUnit(seaman);
										onSeamanRemove();
									} );
								}
							} ).show();
						});
					});
					
					initHeros();
					
					hero.placing(72, 0, 124);
					hero.cell = 72;
					hero.row = 124;
					hero.rotateTo( { x:seaman.x - 1 } );
					
					klide.placing(70, 0, 120);
					klide.cell = 70;
					klide.row = 120;
					klide.rotateTo( { x:hero.x - 1 } );
					klide.framesType = Personage.STOP;
					klide.stopWalking();
					
					App.map.sorted.push(hero, seaman);
					App.map.sorting();
					
					App.map.focusedOn({x:hero.x - 80, y:hero.y});
				}, 1000);
			}
		}
		
		private function onSeamanRemove():void {
			App.user.stock.add(629, 1);
			var settings:Object = { sid:629, fromStock:true };

			var unit:Unit = Unit.add(settings);
			unit.stockAction({coords:{x:65, z:140}});
			unit.placing(67, 0, 128);
			(unit as Walkgolden).rotateTo( { x:hero.x - 1 } );
		}
		
		//появление моряка на море
		private static function startQuest340():void {
			if (App.user.quests.tutorial) return;
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			Window.closeAll();
			
			App.tutorial.quest340_0();
		}
		
		private function quest340_0():void {
			if (!Map.ready) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
			}else {
				onMap();
			}
			
			function onMap(e:AppEvent = null):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
				
				setTimeout(function():void {
					var seaman:Personage = new Personage( { id:10, sid:Hero.SEAMAN, x:178, z:126, alien:Hero.SEAMAN, aka:'' }, 'seaman');
					seaman.framesType = Personage.WALK;
					
					//seaman.initMove(61, 122, function():void {
						//seaman.initMove(67, 128, function():void {
							seaman.framesType = Personage.STOP;	
							
							App.user.quests.tutorial = false;
							var questInfo:Object = App.data.quests[340];
							new TutorialMessageWindow( {
								title:			questInfo.title,
								description:	questInfo.description,
								personage:		(App.data.personages.hasOwnProperty(questInfo.character)) ? App.data.personages[questInfo.character].preview : App.data.personages[1].preview,
								callback:		function():void {
									App.user.quests.readEvent(340, function():void {
										seaman.free();
										App.map.removeUnit(seaman);
										onSeamanRemove2();
									} );
								}
							} ).show();
						//});
					//});
					
					initHeros();
					
					//hero.placing(72, 0, 124);
					//hero.cell = 72;
					//hero.row = 124;
					hero.rotateTo( { x:seaman.x - 1 } );
					
					App.map.sorted.push(hero, seaman);
					App.map.sorting();
					
					App.map.focusedOn({x:hero.x - 80, y:hero.y});
				}, 1000);
			}
		}
		
		private function onSeamanRemove2():void {
			App.user.stock.add(629, 1);
			var settings:Object = { sid:629, fromStock:true };

			var unit:Unit = Unit.add(settings);
			unit.stockAction({coords:{x:116, z:128}});
			unit.placing(116, 0, 128);
			(unit as Walkgolden).rotateTo( { x:hero.x - 1 } );
		}
		
		//появление моряка на море
		private static function startQuest411():void {
			if (App.user.quests.tutorial) return;
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			Window.closeAll();
			
			App.tutorial.quest411_0();
		}
		
		private function quest411_0():void {
			if (!Map.ready) {
				App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
			}else {
				onMap();
			}
			
			function onMap(e:AppEvent = null):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
				
				setTimeout(function():void {
					var joe:WorkerUnit = new WorkerUnit( { id:10, sid:1127, x:153, z:168, alien:1127, aka:'' }, 'joe');
					joe.shortcutDistance = 20;
					joe.framesType = Personage.WALK;
					
					//seaman.initMove(61, 122, function():void {
						//seaman.initMove(67, 128, function():void {
							joe.framesType = Personage.STOP;	
							
							App.user.quests.tutorial = false;
							var questInfo:Object = App.data.quests[411];
							new TutorialMessageWindow( {
								title:			questInfo.title,
								description:	questInfo.description,
								personage:		(App.data.personages.hasOwnProperty(questInfo.character)) ? App.data.personages[questInfo.character].preview : App.data.personages[1].preview,
								callback:		function():void {
									App.user.quests.readEvent(411, function():void {
										//joe.free();
										//App.map.removeUnit(joe);
										//onSeamanRemove2();
									} );
								}
							} ).show();
						//});
					//});
					
					initHeros();
					
					//hero.placing(72, 0, 124);
					//hero.cell = 72;
					//hero.row = 124;
					hero.rotateTo( { x:joe.x - 1 } );
					
					App.map.sorted.push(hero, joe);
					App.map.sorting();
					
					App.map.focusedOn( { x:hero.x - 80, y:hero.y } );
					App.user.personages.push(joe);
				}, 1000);
			}
		}
		
		//Диалог в Сан-Мансано
		private static function startQuest1170():void {
			new InfoWindow({qID:'eldorado_invader'}).show();
		}
		//Диалог в Сан-Мансано
		private static function startQuest925():void {
			if (App.user.quests.tutorial) return;
			var tut:int = App.user.storageRead('tutorial934', 0);
			if (tut == 1) return;
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			Window.closeAll();
			
			if (Map.ready) onMap();
			else App.self.addEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
			
			function onMap(e:AppEvent = null):void {
				App.self.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMap);
				App.tutorial.quest925_0();
			}
		}
		
		private function quest925_0():void {
			initHeros();
			ketrin = Unit.add( { sid:2490, id:1 } ) as Personage;
			ketrin.framesType = Personage.STOP;
			//ketrin.alpha = 0;
			
			ted = Unit.add( { sid:2489, id:1 } ) as Personage;
			ted.framesType = Personage.STOP;
			ted.alpha = 0;
			
			unitTo(hero, 0, 222, 157);
			unitTo(ketrin, 1, 219, 159);
			unitTo(ted, 0, 242, 155);
			
			var heroMapX:Number = hero.x - 700;
			var heroMapY:Number = hero.y - 300;
			
			App.map.x = -heroMapX * App.map.scaleX + App.self.stage.stageWidth / 2;
			App.map.y = -heroMapY * App.map.scaleX + App.self.stage.stageHeight / 2;
			
			App.self.setOnEnterFrame(mapMove);
			
			function mapMove(e:Event):void {
				heroMapX += 2.5;
				heroMapY += 1.05;
				
				App.map.x = -heroMapX * App.map.scaleX + App.self.stage.stageWidth / 2;
				App.map.y = -heroMapY * App.map.scaleX + App.self.stage.stageHeight / 2;
				
				if (Math.abs(heroMapX - hero.x) < 30) {
					App.self.setOffEnterFrame(mapMove);
					TweenLite.to(App.map, 1, { x:-hero.x * App.map.scaleX + App.self.stage.stageWidth / 2, y:-hero.y * App.map.scaleX + App.self.stage.stageHeight / 2, onComplete:quest925_1});
				}
			}
		}
		
		private function quest925_1():void {
			step = 85;
			dialogStart();
		}
		
		private function quest925_2():void {
			TweenLite.to(ted, 1, { alpha:1 } );
				
			ted.framesType = Personage.WALK;
			ted.initMove(224, 155, function():void {
				unitTo(hero, 1, 222, 157);
				ted.framesType = Personage.STOP;
				hero.framesType = Personage.STOP;
				
				step = 87;
				dialogStart();
			});
		}
		
		private function quest925_3():void {
			App.self.setOnEnterFrame(mapMoveToGold);
			
			setTimeout(fade, 2000, function():void {
				App.self.setOffEnterFrame(mapMoveToGold);
				
				var unit:* = Map.findUnit(2418, 2);
				
				App.map.focusedOn(unit, false, null, false);
				App.map.x += 25;
				App.map.y += 12;
				App.self.setOnEnterFrame(mapMove);
				
				fade(null, 0, 0.75, 0x278295);
				
				ketrin.alpha = 0;
				ted.alpha = 0;
			}, 1, 0.75, 0x278295);
			setTimeout(fade, 5000, function():void {
				App.map.focusedOn(hero, false, null, false);
				App.self.setOffEnterFrame(mapMove);
				fade(function():void {
					quest925_4();
				}, 0, 0.75, 0x278295);
			}, 1, 0.75, 0x278295);
			
			function mapMove(e:Event):void {
				App.map.x -= 1;
				App.map.y -= 0.5;
			}
			
			var mapMoveX:Number = 0.7;
			var mapMoveY:Number = -0.5;
			function mapMoveToGold(e:Event):void {
				App.map.x += mapMoveX;
				App.map.y += mapMoveY;
				mapMoveX += 0.07;
				mapMoveY += 0.05;
			}
		}
		
		private function quest925_4():void {
			App.user.quests.tutorial = false;
			App.user.quests.openWindow(934);
			App.user.storageStore('tutorial934', 1, true);
		}
		
		
		// Персонаж и Кетрин
		private static function startQuest923():void {
			if (App.user.quests.tutorial) return;
			App.user.quests.tutorial = true;
			Tutorial.init();
			App.tutorial.drawSkipFader();
			App.ui.leftPanel.questsPanel.clearIconsGlow();
			Window.closeAll();
			
			App.tutorial.quest923_0();
		}
		public function quest923_0():void {
			
			hidePlaceForScene(49, 64, 61, 76);
			
			hero = App.user.hero;
			ketrin = Unit.add({ sid:2490, id:1 }) as Personage;
			ketrin.alpha = 0;
			
			unitTo(hero, 0, 56, 65);
			unitTo(ketrin, 1, 42, 69);
			hero.framesType = Personage.GATHER;
			
			App.map.focusedOn({ x:hero.x - 100, y:hero.y }, false, function():void {
				TweenLite.to(ketrin, 1, { alpha:1 } );
				
				ketrin.framesType = Personage.WALK;
				ketrin.initMove(52, 67, function():void {
					ketrin.framesType = Personage.STOP;
					hero.framesType = Personage.STOP;
					
					step = 80;
					dialogStart();
				});
			});
		}
		public function quest923_1():void {
			
			ketrin.framesType = Personage.WALK;
			ketrin.initMove(42, 69, function():void {
				ketrin.framesType = Personage.STOP;
				
				step = 76;
				dialogStart();
			});
			
			setTimeout(hideKetrin, 3000);
			
			function hideKetrin():void {
				TweenLite.to(ketrin, 1, { alpha:0, onComplete:startGame } );
				App.user.quests.tutorial = false;
			}
			
			function startGame():void {
				showPlaceForScene(2);
				App.user.quests.openWindow(925);
				App.user.quests.tutorial = false;
			}
		}
		
		/**
		 * Скрывает юниты в области на время временного туториала
		 */
		private var hiddenUnits:Vector.<Unit>;
		private function hidePlaceForScene(fromGridX:int, toGridX:int, fromGridZ:int, toGridZ:int):void {
			if (fromGridX > toGridX || fromGridZ > toGridZ) return;
			if (!hiddenUnits) hiddenUnits = new Vector.<Unit>;
			
			for (var i:int = fromGridX; i < toGridX; i++) {
				for (var j:int = fromGridZ; j < toGridZ; j++) {
					var node:AStarNodeVO = App.map._aStarNodes[i][j];
					var unit:Unit = node.object;
					if (unit && unit.visible && unit.alpha == 1 && hiddenUnits.indexOf(unit) < 0) {
						hiddenUnits.push(unit);
						unit.visible = false;
					}
				}
			}
		}
		private function showPlaceForScene(time:Number = 0):void {
			if (!hiddenUnits || hiddenUnits.length == 0) return;
			for (var i:int = 0; i < hiddenUnits.length; i++) {
				hiddenUnits[i].visible = true;
				if (time > 0) {
					hiddenUnits[i].alpha = 0;
					TweenLite.to(hiddenUnits[i], time, { alpha:1 } );
				}
			}
			hiddenUnits.length = 0;
		}
	}
}
