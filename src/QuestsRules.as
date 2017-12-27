package  
{
	import astar.AStarNodeVO;
	import buttons.Button;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.utils.setTimeout;
	import units.Animal;
	import units.Factory;
	import units.Resource;
	import units.Sphere;
	import units.Techno;
	import units.Unit;
	import wins.BuildingConstructWindow;
	import wins.CharactersWindow;
	import wins.HutHireWindow;
	import wins.DialogWindow;
	import wins.FactoryWindow;
	import wins.HutWindow;
	import wins.ProductionWindow;
	import wins.RecipeWindow;
	import wins.SelectAnimalWindow;
	import wins.SpeedWindow;
	import wins.Window;
	public class QuestsRules 
	{
		public static function getQuestRule(qID:*, mID:*):void {
			//
		}
		
		/*
		public static var fullscreen:Boolean = false;
		public static var rules:Object = { 
			"80": {
				"0":takeReward,
				"1":takeReward
			},
			"85": {
				"2":waitForStorehouseComplete
			}
		};
		
		public static var quest87_1:Boolean = false;
		public static var quest80:Boolean = false;
		
		public static var quest97:Boolean = false;
		
		public static function takeReward():void {
			if (!quest80) {
				App.tutorial.hide();
				App.user.quests.unlockFuckAll();
				new CharactersWindow( { qID:80, mID:1 } ).show();
			}else {
				App.user.quests.lockFuckAll();
				App.tutorial.goCircleTo(
					{
						x:App.self.stage.stageWidth / 2,
						y:App.self.stage.stageHeight / 2
					},
					{
						scaleX:2.5,
						scaleY:2.5
					},
					false,
					true
				);
				App.tutorial.show();
				quest80 = false;
				setTimeout(takeReward, 5000);
			}	
		}
		
		public static var quest85:Boolean = false;
		private static function waitForStorehouseComplete():void {
			if (quest85) return;
			var target:* = Map.findUnit(161, 2);
			
			App.map.focusedOn(target, false, function():void {
				Tutorial.watchOn(target, false, true, Tutorial.getCorrections(161));
			});
			App.user.quests.lockFuckAll();
		}
		
		public static function onStorehouseComplete():void {
			quest85 = true;
			App.user.quests.unlockFuckAll();
			App.user.quests.helpEvent(85, 2);
		}
		
		public static function getQuestRule(qID:int, mID:int):void {
			trace('getQuestRule '+qID, mID);
			if (rules[qID] != undefined && rules[qID][mID] != undefined) {
				var func:Function = rules[qID][mID];
				
				setTimeout(function():void {
					App.user.quests.lock = false;
					func();
				}, 100);
			}
		}
		
		
		public static function finishTutorial():void {
			App.user.quests.tutorial = false;
			App.tutorial.hide();
			App.user.quests.stopTrack();
		}
			
		public static function focusOnQuest(bttn:*):void {
			App.ui.leftPanel.visible = true;
			Tutorial.watchOn(bttn, 'right');
			App.user.quests.lock = false;
			App.user.quests.currentTarget = bttn;
		}
		
		public static var quest10_1:Boolean = false;
		private static function focusOnResorce1():void {
			App.user.quests.lockFuckAll();
			if (quest10_1) {
				var targets:Array = Map.findUnits([358]);
				quest10_1 = false;
				Tutorial.watchOn(targets[0], false, true, Tutorial.getCorrections(358));
				return
			}
			quest10_1 = true;
			App.user.quests.helpEvent(App.user.quests.currentQID, App.user.quests.currentMID);
		}
		
		public static var quest10_2:Boolean = false;
		private static function focusOnResorce2():void {
			App.tutorial.hide();
			App.user.quests.lockFuckAll();
			if (quest10_2) {
				var targets:Array = Map.findUnits([359]);
				quest10_2 = false;
				Tutorial.watchOn(targets[0], false, true, Tutorial.getCorrections(359));
				return
			}
			quest10_2 = true;
			App.user.quests.helpEvent(App.user.quests.currentQID, App.user.quests.currentMID);
		}
		
		private static function focusedOnHeroes():void {
			var position:Object = IsoConvert.isoToScreen(App.map.heroPosition.x, App.map.heroPosition.z, true);
			App.map.focusedOn( { x:position.x, y:position.y }, false, function():void {
				new CharactersWindow( { qID:9} ).show();	
			});
		}
		
		private static function focusedOnTrade():void {
			
			
			var position:Object = IsoConvert.isoToScreen(65, 78, true);
			App.map.focusedOn( { x:position.x, y:position.y }, false, function():void {
				new DialogWindow( { qID:138, mID:1} ).show();	
			});
		}
		
		private static var quest139_1:Boolean = false;
		private static function focusedOnTrade2():void 
		{
			if (quest139_1)
				return;
				
			App.user.quests.lockFuckAll();	
			setTimeout(function():void {
				App.tutorial.hide();
				App.user.quests.helpEvent(139, 1);
			}, 2000);
			quest139_1 = true;
		}
		
		public static var quest77:Boolean = false;
		public static var quest77_text:int = 0;
		private static function closeInstanseAndWait():void {
			if (!quest77) {
				quest77_text = 1;
				App.user.quests.helpEvent(77, 2);
			}else{
				//App.tutorial.hide();
				quest77_text = 0;
				var target:* = Map.findUnits([250]);	
				Tutorial.watchOn(target[0], false, true, {
					scaleX:2,
					scaleY:2, 
					dx: 0,
					dy: -70
				});
				setTimeout(App.user.quests.lockFuckAll, 100);
				quest77 = false;
			}
		}
		private static function findShip():void {
			if (quest77) return;
			App.user.quests.helpEvent(77, 1);
			quest77 = true;
		}
		
		public static function showOnInstanceReward():void {
			QuestsRules.getQuestRule(77, 2);
			setTimeout(App.user.quests.unlockFuckAll, 200);
			
		}
		
		public static var quest14:Boolean = false;
		private static function waitForFieldComplete():void {
			if (quest14) return;
			var target:* = Map.findUnit(15, 1);
			
			App.map.focusedOn(target, false, function():void {
				Tutorial.watchOn(target, false, true, Tutorial.getCorrections(15));
			});
			App.user.quests.lockFuckAll();
		}
		public static function onFieldComplete():void {
			quest14 = true;
			App.user.quests.unlockFuckAll();
			App.user.quests.helpEvent(14, 2);
		}
		
		public static var quest139:Boolean = false;
		private static function waitForTradeComplete():void {
			if (quest139) return;
			var target:* = Map.findUnit(173, 1);
			
			App.map.focusedOn(target, false, function():void {
				Tutorial.watchOn(target, false, true, Tutorial.getCorrections(173));
			});
			App.user.quests.lockFuckAll();
		}
		public static function onTradeComplete():void {
			App.user.quests.unlockFuckAll();
			App.user.quests.helpEvent(139, 2);
			quest139 = true;
		}
		
		
		private static function waitForMinningComplete():void {
			if (quest6) return;
			var target:* = Map.findUnit(162, 1);
			
			App.map.focusedOn(target, false, function():void {
				Tutorial.watchOn(target, false, true, Tutorial.getCorrections(162));
			});
			App.user.quests.lockFuckAll();
			
		}
		public static function onMinningBuildComplete():void {
			//App.user.quests.unlockFuckAll();
			App.user.quests.helpEvent(6, 2);
			quest6 = true;
		}
		
		public static function glowBoostStoreBttn():void {
			if (Window.isOpen) {
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var win:* = App.self.windowContainer.getChildAt(i);
						
					if (win is SpeedWindow){
						var bttn:Button = win.boostBttn;
						bttn.showGlowing();
						bttn.showPointing("bottom", 0, 70, bttn.parent);
						App.user.quests.currentTarget = bttn;
						Quests.lockButtons = false;
						break;
					}
				}
			}
		}
		public static function glowOnStoreHouse2():void {
			App.user.quests.helpEvent(7, 3);
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		public static function glowMakeTechnoBttn():void {
			if (Window.isOpen) {
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var win:* = App.self.windowContainer.getChildAt(i);
						
					if (win is FactoryWindow){
						var bttn:Button = win.upgBttn;
						bttn.showGlowing();
						bttn.showPointing("top", bttn.width / 2 - 35, 0, bttn.parent);
						App.user.quests.currentTarget = bttn;
						break;
					}
				}
			}
		}
		
		
		
		public function QuestsRules() 
		{
			
		}
		
		public static function goToFullscreen():void {
			App.user.quests.currentTarget = App.ui.systemPanel.bttnSystemFullscreen;
			App.ui.systemPanel.bttnSystemFullscreen.addEventListener(MouseEvent.CLICK, onFullscreen, false, 2000);
		}
		
		private static function onFullscreen(e:MouseEvent):void {
			fullscreen = true;
			App.ui.systemPanel.bttnSystemFullscreen.removeEventListener(MouseEvent.CLICK, onFullscreen);
			App.ui.systemPanel.bttnSystemFullscreen.hidePointing();
			App.ui.systemPanel.bttnSystemFullscreen.hideGlowing();
			App.user.quests.continueTutorial();
		}
		
		
		
		public static function glowBuildingCreateBttn():void {
			if (Window.isOpen) {
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var win:* = App.self.windowContainer.getChildAt(i);

					if (win is BuildingConstructWindow) {
						var bttn:Button = win.buildBttn;
						bttn.showGlowing();
						bttn.showPointing("top", (win.buildBttn.width - 30) / 2, 0, win.buildBttn.parent);
						App.user.quests.lockFuckAll();
						break;
					}
				}
			}
		}
		
		private static function onBuildBttnClick(e:MouseEvent):void 
		{
			//App.user.quests.lockFuckAll();
		}
		
		private static var jamPlace:LayerX;
		public static function pointingJamPlace():void {
			if (App.user.quests.currentTarget != null) {
				return;
			}
			
			//App.ui.upPanel.jamBttn.state = Button.DISABLED;
			
			App.user.quests.currentTarget = App.map.moved;
			var node:AStarNodeVO = App.map._aStarNodes[21][17];
			
			jamPlace = new LayerX();
			jamPlace.graphics.beginFill(0x000000, 0.4);
			jamPlace.graphics.drawEllipse(0, 0, 80, 46);
			jamPlace.graphics.endFill();
			jamPlace.filters = [new BlurFilter(15, 15, 1)];
			
			App.map.mLand.addChild(jamPlace);
			jamPlace.x = node.tile.x;
			jamPlace.y = node.tile.y;
			
			jamPlace.showPointing("top", 25);
			
			App.map.focusedOn(jamPlace);
			
			App.self.addEventListener(MouseEvent.CLICK, onJamPlaceRemove, false, 2000);
		}
		
		private static function onJamPlaceRemove(e:MouseEvent):void {
			//App.user.quests.currentTarget
			App.self.removeEventListener(MouseEvent.CLICK, onJamPlaceRemove);
			
			jamPlace.hidePointing();
			App.map.mLand.removeChild(jamPlace);
			jamPlace = null;
			
			//App.user.quests.lock = true;
		}
		
		
		
		public static function glowTree():void {
			if (App.user.quests.currentTarget is Resource) {
				App.user.quests.currentTarget = null;
				return;
			}
		}
		
		public static function glowPineTree():void {
			if (App.user.quests.currentTarget is Resource) {
				App.user.quests.currentTarget = null;
				return;
			}
		}
		
		public static function glowHutTarget():void {
			if (Window.isOpen) {
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var win:* = App.self.windowContainer.getChildAt(i);

					if (win is HutWindow){
						for each(var item:* in win.items){
							if (item.setTargetBttn == null)
								continue;
							var bttn:Button = item.setTargetBttn;
							bttn.showGlowing();
							bttn.showPointing("top", (bttn.width - 30) / 2, 0, bttn.parent);
							App.user.quests.currentTarget = bttn;
							break;
						}
						break;
					}
				}
			}
		}
		
		public static function glowRecipeTarget():void {
			if (Window.isOpen) {
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var win:* = App.self.windowContainer.getChildAt(i);

					if (win is RecipeWindow){
						var bttn:Button = win.outItem.recipeBttn;
						bttn.showGlowing();
						bttn.showPointing("top", (bttn.width - 30) / 2, 0, bttn.parent);
						App.user.quests.currentTarget = bttn;
						break;
					}
				}
			}
		}
		

		public static function glowRecipeBuilding():void {
			if (Window.isOpen) {
				for (var i:int = 0; i < App.self.windowContainer.numChildren; i++) {
					var win:* = App.self.windowContainer.getChildAt(i);

					if (win is ProductionWindow) {
						win.glowQuest();
						break;
					}
				}
			}
		}
		
		public static function glowSelectAnimal():void {
			var i:int;
			var win:*;
			var bttn:*;
			var item:*;
			if (App.user.quests.currentTarget == null) {
				return;
			}
			if (App.user.quests.currentTarget is Sphere){
				if (Window.isOpen) {
					for (i = 0; i < App.self.windowContainer.numChildren; i++) {
						win = App.self.windowContainer.getChildAt(i);
					
						if (win is SelectAnimalWindow) {
							var qID:* = App.user.quests.currentQID;
							var mID:* = App.user.quests.currentMID;
							var targets:* = App.data.quests[qID].missions[mID].target;
							for each(var sID:* in targets) break;
							for each(item in win.items) {
								if (item.sID == sID) {
									bttn = item.selectBttn;
									bttn.showGlowing();
									bttn.showPointing("top", (bttn.width - 30) / 2, 0, bttn.parent);
									bttn.mouseEnabled = true;
									App.user.quests.currentTarget = bttn;
									
									Quests.initQuestRule = true;
									break;
								}
							}	
						}else if (win is HutHireWindow) {
							for each(item in win.items) {
								bttn = item.selectBttn;
								bttn.showGlowing();
								bttn.showPointing("top", (bttn.width - 30) / 2, 0, bttn.parent);
								bttn.mouseEnabled = true;
								App.user.quests.currentTarget = bttn;
								Quests.initQuestRule = true;
								break;
							}
						}
						break;
					}
				}
			}else if (App.user.quests.currentTarget.name == "SelectAnimalBttn" ) {
				if (Window.isOpen) {
					for (i = 0; i < App.self.windowContainer.numChildren; i++) {
						win = App.self.windowContainer.getChildAt(i);
						if (win is HutHireWindow) {
							for each(item in win.items) {
								bttn = item.selectBttn;
								bttn.showGlowing();
								bttn.showPointing("top", (bttn.width - 30) / 2, 0, bttn.parent);
								bttn.mouseEnabled = true;
								App.user.quests.currentTarget = bttn;
								Quests.initQuestRule = true;
								return;
							}
							break;
						}
					}
				}
				setTimeout(glowSelectAnimal, 60);
				
			}else if (App.user.quests.currentTarget.name == "EnergyFriendBttn" || App.user.quests.currentTarget.name == "UserEnergyBttn") {
				if (Window.isOpen) {
					for (i = 0; i < App.self.windowContainer.numChildren; i++) {
						win = App.self.windowContainer.getChildAt(i);
						if (win is HutHireWindow) {
							if(win.createBttn.mode != Button.NORMAL){
								bttn = win.energyBttn;
								bttn.showGlowing();
								bttn.showPointing("top", (bttn.width - 30) / 2, 0, bttn.parent);
								bttn.mouseEnabled = true;
								App.user.quests.currentTarget = bttn;
								Quests.initQuestRule = true;
								break;
							}else {
								bttn = win.createBttn;
								bttn.showGlowing();
								bttn.showPointing("top", (bttn.width - 30) / 2, 0, bttn.parent);
								bttn.mouseEnabled = true;
								App.user.quests.currentTarget = bttn;
								break;
							}
						}
						break;
					}
				}
			}
		}
		
		private static var place:LayerX;
		private static function pointingPlace(x:int, z:int, onPlaceRemove:Function):void {
		
			App.user.quests.lockFuckAll();
			App.user.quests.currentTarget = App.map.moved;
			
			App.user.quests.lockFuckAll();
			App.self.addEventListener(MouseEvent.CLICK, onPlaceRemove, false, 2000);
		}
		
		private static function onPlaceRemove(e:MouseEvent):void 
		{
			if((App.map.moved.coords.x == rightPosition[App.user.quests.currentQID].x) &&
			(App.map.moved.coords.z == rightPosition[App.user.quests.currentQID].z)) {
				
			}else {
				return;
			}
			
			App.self.removeEventListener(MouseEvent.CLICK, onPlaceRemove);
			Map.removeLight();
			
			App.user.quests.lock = true;
			App.user.quests.currentTarget = App.map.moved;
			App.map.moved.move = false;
			App.map.moved = null;
			trace('onPlaceRemove');
			App.user.quests.unlockFuckAll();
		}
		
		public static function pointingTechnoPlace():void {
			var sid:int = Factory.TECHNO_FACTORY;
			var object:Object = App.data.storage[sid];
			Map.createLight( { x:53, z:91 }, object.view);
			pointingPlace(53, 91, onPlaceRemove);
			//App.user.quests.lockFuckAll();
		}
		
		public static var rightPosition:Object = {
			5: {
				x:53,
				z:91
			},
			6: {
				x:73,
				z:98
			},
			7: {
				x:74,//70
				z:106//92
			},
			14: {
				x:67,
				z:110
			},
			80: {
				x:87,
				z:98
			}
		}	
		
		public static function pointingMiningPlace():void {
			var sid:int = 162;
			var object:Object = App.data.storage[sid];
			Map.createLight(rightPosition[6], object.view);
			pointingPlace(rightPosition[6].x, rightPosition[6].z, onPlaceRemove);
		}
		
		public static function pointingStoreHousePlace():void {
			var sid:int = 187;
			var object:Object = App.data.storage[sid];
			Map.createLight(rightPosition[7], object.view);
			pointingPlace(rightPosition[7].x, rightPosition[7].z, onPlaceRemove);
		}
		
		public static function pointingFieldPlace():void {
			var sid:int = 15;
			var object:Object = App.data.storage[sid];
			Map.createLight(rightPosition[14], object.view);
			pointingPlace(rightPosition[14].x, rightPosition[14].z, onPlaceRemove);
		}
		
		public static function pointingMoneyHousePlace():void {
			var sid:int = 352;
			var object:Object = App.data.storage[sid];
			Map.createLight(rightPosition[80], object.view);
			pointingPlace(rightPosition[80].x, rightPosition[80].z, onPlaceRemove);
		}
		
		public static var places:Array = [
			{x:36,z:23}, {x:36,z:27}, {x:40,z:23}, {x:40,z:27}
		];
		
		public static function pointingPlantPlace():void {
			var p:Object = places.shift();
			pointingPlace(p.x, p.z, onPlantRemove);
		}
		
		private static function onPlantRemove(e:MouseEvent):void 
		{
			if (App.map.moved && !App.map.moved.canInstall()) return;
			
			App.self.removeEventListener(MouseEvent.CLICK, onPlantRemove);
			
			place.hidePointing();
			App.map.mLand.removeChild(place);
			place = null;
			
			if (places.length > 0) {
				App.user.quests.currentTarget = null;
				var p:Object = places.shift();
				pointingPlace(p.x, p.z, onPlantRemove);
			}
		}
		
		public static const DEER:uint = 823;
		public static const BOX:uint = 839;
		public static function addDeer():void
		{
			if (App.user.stock.count(DEER) > 0)
			{
				var settings:Object = { sid:DEER, fromStock:true, x:10, z:10};
				settings['started'] = App.time - App.data.storage[DEER].time;
				settings['time'] = App.time - App.data.storage[DEER].time;
				var unit:Unit = Unit.add(settings);
				unit.stockAction( { ready:1 } );
				App.map.focusedOn(unit, true);
			}
		}
		
		public static function addBox():void 
		{
			if (App.user.stock.count(BOX) > 0)
			{
				var settings:Object = { sid:BOX, fromStock:true, x:13, z:24};
				var unit:Unit = Unit.add(settings);
				unit.stockAction();
				App.map.focusedOn(unit, false, function():void {
					unit.startGlowing();
				});
			}
		}
		
		public static function focusedOnWorker():void {
			App.user.quests.lockFuckAll();
			var worker:Techno = App.user.techno[0];
			App.map.focusedOnCenter(worker, false, 
				function():void {
					Tutorial.watchOn(worker, false, false, {
						scaleX:1.5,
						scaleY:1.5
					});
					
					if(Factory.spirit != null){
						setTimeout(function():void {
							TweenLite.to(Factory.spirit, 0.5, { alpha:0, onComplete:function():void {
									Factory.spirit.uninstall();
									Factory.spirit = null;
								}})
							
						}, 3000)
					}
				}
			);	
		}
		
		public static function furryComplete():void {
			App.user.quests.lock = false;
			App.tutorial.hide();
			App.user.quests.unlockFuckAll();
			new DialogWindow( { qID:92, mID:1 } ).show();
		}
		
		public static function initStart():void {
			App.user.quests.lockFuckAll();
			//App.user.startIntro();
		}
		
		public static function pointingTraget(sid:int):void {
			var arrTargets:Array = Map.findUnits([sid]);
			
			if (arrTargets && arrTargets.length > 0) {
				App.map.focusedOn(arrTargets[0]);
				if(arrTargets[0].bitmap.bitmapData)
					arrTargets[0].showPointing("top", -arrTargets[0].x - 140, -arrTargets[0].y + 80, arrTargets[0]);
				else
					arrTargets[0].showPointing("top", -arrTargets[0].x - 80, -arrTargets[0].y + 80, arrTargets[0]);
			}
		}
		
		public static var quest6:Boolean = false;
		public static function startInstanseTutorial():void {
			//App.user.quests.lockFuckAll();
		}
		*/
	}
}