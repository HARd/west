package ui 
{
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import wins.DaylicWindow;
	import wins.GuestRewardsWindow;
	import wins.GuestRewardWindow;
	import wins.Window;
	
	public class LeftPanel extends Sprite
	{
		
		public static var QUEST_ICON_HEIGHT:uint = 50;
		
		public var glowedIcons:Object = { };
		public var guestEnergy:Sprite = new Sprite();
		public var questsPanel:QuestPanel;
		public var questIcons:Array = [];
		public const TOP_INDENT:int = 50;
		public static var iconHeight:uint = 80;		
		public var managerIcon:QuestManagerIcon;
		
		public function LeftPanel():void
		{
			var material:Object = App.data.storage[Stock.COINS];

			Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { } );
			addChild(guestEnergy);
		    
			createQuestPanel();
			if (App.user.level >= 3) createDaylicsIcon();
		}
		
		public function createQuestManagerIcon():void {
			if (App.user.level < 12) return;
			disposeQuestManagerIcon();
			managerIcon = new QuestManagerIcon();
			managerIcon.x = 8;
			addChild(managerIcon);
		}
		private function disposeQuestManagerIcon():void {
			if (managerIcon) {
				removeChild(managerIcon);
				managerIcon = null;
			}
		}
		
		public var bttnDaylics:ImageButton;
		public var dayliLabel:TextField;
		public function createDaylicsIcon():void {
			if (App.user.level < 12) return;
			
			disposeDaylicsIcon();			
			createQuestManagerIcon();
			
			bttnDaylics = new ImageButton(Window.textures.questDailyIco);			
			bttnDaylics.tip = function():Object {
				var time:int = App.nextMidnight - App.time;
				var text:String = '';
				if (time > 0) {
					if (Quests.daylicsComplete) {
						text = Locale.__e("flash:1443524151827", [TimeConverter.timeToStr(time)]);
					}else{
						text = Locale.__e("flash:1443524172154", [TimeConverter.timeToStr(time)]);
					}
				}
				
				return {
					title:Locale.__e("flash:1443524094307"),
					text:Locale.__e(text),
					timer:true
				};
			}
			
			bttnDaylics.x = 8;
			bttnDaylics.addEventListener(MouseEvent.CLICK, onDaylics);
			bttnDaylics.visible = true;
			App.self.addEventListener(AppEvent.ON_LEVEL_UP, App.user.quests.getDaylics);
			
			addChild(bttnDaylics);
		}
		private function disposeDaylicsIcon():void {
			if (bttnDaylics) {
				bttnDaylics.removeEventListener(MouseEvent.CLICK, onDaylics);
				removeChild(bttnDaylics);
				bttnDaylics = null;
			}
		}
		private function onDaylics(e:MouseEvent = null):void {
			stopDaylicsGlow();
			
			if (Quests.daylicsComplete) return;
			
			new DaylicWindow({}).show();
		}
		public function attantionMove():void {
			if (!bttnDaylics) return;
			var target:DisplayObject = bttnDaylics.getChildByName("attantion");
			TweenLite.to(target, 0.6, { rotation:6, ease:Elastic.easeIn, onComplete:function():void {
				TweenLite.to(target, 0.25, { rotation:-6, ease:Back.easeInOut, onComplete:function():void {
					TweenLite.to(target, 0.6, { rotation:0, ease:Elastic.easeOut} )
					}
				})
			}});
		}
		public function startDaylicsGlow(pointing:Boolean = false):void {
			if (!bttnDaylics) return;
			if (bttnDaylics.__hasGlowing) return;
			if (pointing) bttnDaylics.showPointing('left', bttnDaylics.width + 150, bttnDaylics.height / 2 - 80, bttnDaylics, '', null, true);
			
			bttnDaylics.showGlowing();
		}
		public function stopDaylicsGlow():void {
			bttnDaylics.hidePointing();
			bttnDaylics.hideGlowing();
		}
		public function dayliState(value:Boolean):void {
			if (!App.user.quests.dayliInit) return;
			
			bttnDaylics.visible = value;
			resize();
		}
		
		
		public function createQuestPanel():void {
			
			if (questsPanel != null) {
				questsPanel.dispose();
				removeChild(questsPanel);
				questsPanel = null; 
			}
			
			questsPanel = new QuestPanel();
			addChild(questsPanel);
		}
		
		public function clearIconsGlow():void {
			questsPanel.clearIconsGlow();
		}
		
		public function showGuestEnergy():void {
			if (App.owner == null) {
				return;
			}
			
			clearIconsGlow();
			questsPanel.visible = false;
			dayliState(false);
			if (managerIcon) managerIcon.visible = false;
			
			var childs:int = guestEnergy.numChildren;
			
			var friend:Object = App.user.friends.uid(App.owner.id);
			
			if (!App.isSocial('MX','YB','AI')) createGuestRewardIcon();
			if (childs > 0 && childs > friend.energy) {
				var icon:*;
				if (App.user.stock.count(Stock.GUESTFANTASY) && friend.energy > 0) {
					icon = guestEnergy.getChildAt(0);
				}else if (App.user.stock.count(Stock.GUESTFANTASY)) {
					icon = guestEnergy.getChildAt(0);
				}else{
					icon = guestEnergy.getChildAt(0);
				}
				
				App.ui.glowing(icon, 0x86e3f2, function():void{ 
					update();
				});
				
			}else {
				update();
			}
		}
		private var promoIconId:uint = 0;
		public function update():void 
		{
			var friend:Object = App.user.friends.uid(App.owner.id);
			
			while (guestEnergy.numChildren) {
				guestEnergy.removeChildAt(0);
			}
			var material:Object = App.data.storage[Stock.GUESTFANTASY];
			var contEn:LayerX;
			var limit:int = App.user.friends.energyLimit;
			if (limit > 0) {
				var min:int = Math.min(limit, friend.energy);
				for (var i:int = 0; i < min; i++) {
					contEn = new LayerX();
					
					var radius:int = 33;
					var background:Bitmap = new Bitmap(new BitmapData(radius * 2, radius * 2, true, 0xffffff));
					contEn.addChild(background);
					
					var shape:Shape = new Shape();
					shape.graphics.beginFill(0xefc99a, 1);
					shape.graphics.drawCircle(radius,radius,radius);
					shape.graphics.endFill();
					background.bitmapData.draw(shape);
					
					var bitmap:Bitmap = new Bitmap(UserInterface.textures.guestEnergy);
					bitmap.scaleX = bitmap.scaleY = 0.6;
					bitmap.smoothing = true;
					bitmap.x = 6;
					bitmap.y = (App.self.stage.stageHeight - min * bitmap.height) / 2 + (bitmap.height + 15) * i;
					contEn.addChild(bitmap);
					
					background.x = 6;
					background.y = bitmap.y - 5;
					background.alpha = 0.9;
					
					guestEnergy.addChild(contEn);
					
					contEn.tip = function():Object { 
						return {
							title:Locale.__e('flash:1404378818609'),
							text:Locale.__e("flash:1404378842760")
						};
					};
				}
				if(App.user.stock.count(Stock.GUESTFANTASY)){
					Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { 
						contEn = new LayerX();
						
						var radius:int = 33;
						var background:Bitmap = new Bitmap(new BitmapData(radius * 2, radius * 2, true, 0xffffff));
						contEn.addChild(background);
						
						var shape:Shape = new Shape();
						shape.graphics.beginFill(0xefc99a, 1);
						shape.graphics.drawCircle(radius,radius,radius);
						shape.graphics.endFill();
						background.bitmapData.draw(shape);
						
						var bitmap:Bitmap = data;
						bitmap.scaleX = bitmap.scaleY = 0.6;
						bitmap.smoothing = true;
						bitmap.x = 2;
						bitmap.y = (App.self.stage.stageHeight + min*bitmap.height)/2 - bitmap.height * (i+1) - 10 ;
						
						var counter:TextField = Window.drawText('x' + App.user.stock.count(Stock.GUESTFANTASY), {
							fontSize:22,
							autoSize:"left",
							color:0x38342c,
							borderColor:0xecddb9
						});
						
						background.x = 6;
						background.y = bitmap.y;
						background.alpha = 0.9;
						
						contEn.addChild(bitmap);
						contEn.addChild(counter);
						guestEnergy.addChild(contEn);
						counter.x = bitmap.x + bitmap.width - 30;
						counter.y = bitmap.y + bitmap.height - counter.height;
						
						contEn.tip = function():Object { 
							return {
								title:Locale.__e('flash:1404378818609'),
								text:Locale.__e("flash:1404378842760")
							};
						};
						
					});
				}
				
			}else{
				if(App.user.stock.count(Stock.GUESTFANTASY)){
					Load.loading(Config.getIcon(material.type, material.preview), function(data:*):void { 
						var radius:int = 33;
						var background:Bitmap = new Bitmap(new BitmapData(radius * 2, radius * 2, true, 0xffffff));
						guestEnergy.addChild(background);
						
						var shape:Shape = new Shape();
						shape.graphics.beginFill(0xefc99a, 1);
						shape.graphics.drawCircle(radius,radius,radius);
						shape.graphics.endFill();
						background.bitmapData.draw(shape);
						
						var bitmap:Bitmap = data;
						bitmap.scaleX = bitmap.scaleY = 0.6;
						bitmap.smoothing = true;
						
						bitmap.x = 2;
						bitmap.y = (App.self.stage.stageHeight - bitmap.height)/2;
						guestEnergy.addChild(bitmap);
						
						background.x = 6;
						background.y = bitmap.y;
						background.alpha = 0.9;
						
						var counter:TextField = Window.drawText('x' + App.user.stock.count(Stock.GUESTFANTASY), {
							fontSize:22,
							autoSize:"left",
							color:0x38342c,
							borderColor:0xecddb9
						});
						
						guestEnergy.addChild(counter);
						counter.x = bitmap.x + bitmap.width - 30;
						counter.y = bitmap.y + bitmap.height - counter.height;
					});
				}
			}
			
			if (guestSprite) {
				guestSprite.y = (App.self.stage.stageHeight + min * guestBacking.height) / 2 - guestBacking.height * (i + 1) - 10 - guestBacking.height;
				if (guestSprite.y < 40) guestSprite.y = 40;
			}
		}
		public var guestSprite:LayerX;
		public var guestPlusBttn:ImageButton;
		public var guestActionCounter:TextField;
		private var guestBacking:Bitmap;
		public function createGuestRewardIcon():void {
			if (guestSprite) {
				updateGuestReward();
				guestSprite.visible = true;
				return;
			}
			
			guestSprite = new LayerX();
			guestSprite.x = 6;
			addChild(guestSprite);
			
			guestBacking = new Bitmap(UserInterface.textures.friendsActionBonusBacking);
			guestSprite.addChild(guestBacking);
			
			guestPlusBttn = new ImageButton(UserInterface.textures.energyIcon);
			guestPlusBttn.x = (guestBacking.width - guestPlusBttn.width) /2;
			guestPlusBttn.y = (guestBacking.height - guestPlusBttn.height) /2;
			guestSprite.addChild(guestPlusBttn);
			
			guestPlusBttn.tip = function():Object {
				return {
					title:Locale.__e('flash:1427211986691')
					
				}
			};			
			guestPlusBttn.addEventListener(MouseEvent.CLICK, onGuestEvent);
			
			guestActionCounter = Window.drawText(String(0) + '/' + String(App.user.currentGuestLimit), {
				color:0xffffff,
				borderColor:0x644b2b,
				fontSize:26,
				textAlign:"center"
			});
			guestActionCounter.width = 100;
			guestActionCounter.height = guestActionCounter.textHeight;
			guestActionCounter.y = guestBacking.height - guestActionCounter.height + 5;
			guestSprite.addChild(guestActionCounter);
			
			guestActionCounter.x = (guestBacking.width - guestActionCounter.width) / 2;
			
			updateGuestReward();
		}
		private function onGuestEvent(e:MouseEvent):void {
			new GuestRewardsWindow().show();
		}
		
		public var rel:Array;
		public function updateGuestReward():void {
			if (App.isSocial('MX','YB','AI')) return;
			rel = [];
			var numb:int = 0;
			var currentNumb:int = 0;
			for each (var material:* in App.data.storage) {
				if (material.type == 'Guests') {
					if (App.self.getLength(material.outs) > 1) {
						delete(material.outs[Stock.COUNTER_GUESTFANTASY])
					}
					rel[numb] = material;
					numb++;
				}
			}
			
			rel.sortOn('count', Array.NUMERIC);
			
			for (var j:int = 0; j < rel.length; j++ ) {
				if (rel[j].count <= App.user.stock.data[Stock.COUNTER_GUESTFANTASY]) {
					currentNumb = j + 1;
					
				}
			}
			if (currentNumb == rel.length || App.user.currentGuestLimit != rel[currentNumb].count) {
				if (App.user.currentGuestLimit > 0 && currentNumb != 0) {
					if (rel[currentNumb-1].count == App.user.stock.data[Stock.COUNTER_GUESTFANTASY] && App.user.mode == User.GUEST) {
						new GuestRewardWindow().show();		
						new GuestRewardsWindow().show();
						if (currentNumb == rel.length) {
							App.user.stock.add(Stock.COUNTER_GUESTFANTASY, 1);	
						}
					}
				
				}
				if (currentNumb > rel.length - 1) {
					currentNumb = rel.length - 1;
				}
				
				for (var sid2:* in rel[currentNumb].outs){
					break;
				}
				Load.loading(Config.getIcon(App.data.storage[sid2].type, App.data.storage[sid2].preview), onLoadImage);
				
				App.user.currentGuestLimit = rel[currentNumb].count;
				App.user.currentGuestReward = rel[currentNumb];
			}
			if (App.user.stock.data[Stock.COUNTER_GUESTFANTASY] <= rel[rel.length - 1].count) {
				if (guestActionCounter)
					guestActionCounter.text = String((App.user.stock.data.hasOwnProperty(Stock.COUNTER_GUESTFANTASY)) ? (App.user.stock.data[Stock.COUNTER_GUESTFANTASY]) : 0) + '/' + String(App.user.currentGuestLimit);
				if (App.user.stock.data[Stock.COUNTER_GUESTFANTASY] == rel[rel.length - 1].count) {
					if (guestPlusBttn) {
						guestPlusBttn.tip = function():Object {
							return {
								title:Locale.__e('flash:1448274468759')
							}
						};	
					}
				}
			}else {
				if (guestActionCounter) guestActionCounter.text = String(rel[rel.length-1].count) + '/' + String(App.user.currentGuestLimit);
				if (App.user.stock.data[Stock.COUNTER_GUESTFANTASY] >= rel[rel.length - 1].count) {
					//guestGlowContainer.visible = false;
					if (guestPlusBttn) {
						guestPlusBttn.tip = function():Object {
							return {
								title:Locale.__e('flash:1448274468759')
							}
						};	
					}
				}
			}
			if (!App.user.stock.data.hasOwnProperty(Stock.COUNTER_GUESTFANTASY)) {
				if (guestActionCounter) guestActionCounter.text = String('0'+'/'+rel[0].count)	;
			}
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_CHANGE_GUEST_FANTASY));
		}
		private function onLoadImage(data:Object):void
		{
			if (!guestPlusBttn) return;
			guestPlusBttn.visible = true;
			guestPlusBttn.bitmapData = data.bitmapData;
			guestPlusBttn.bitmap.smoothing = true;
			Size.size(guestPlusBttn, 45, 45);
			guestPlusBttn.x = (guestBacking.width - guestPlusBttn.width) /2;
			guestPlusBttn.y = (guestBacking.height - guestPlusBttn.height) /2;
		}
		
		public function hideGuestEnergy():void {
			while (guestEnergy.numChildren) {
				guestEnergy.removeChildAt(0);
			}
			
			if (guestSprite) guestSprite.visible = false;
			
			questsPanel.visible = true;
			dayliState(true);
			if (managerIcon) managerIcon.visible = true;
		}
		
		public function resize():void {
			if(bttnDaylics && bttnDaylics.visible)
				bttnDaylics.y = 50;// promoPanel.y + promoIconId * iconHeight;
				
			if (managerIcon) {
				if(bttnDaylics && bttnDaylics.visible)
					managerIcon.y = bttnDaylics.y + bttnDaylics.height + 5;
				else
					managerIcon.y = 120;
			}
			
			if (questsPanel && questsPanel.visible) {
				if (managerIcon)
					questsPanel.y = 185;
				else 
					questsPanel.y = 110;
				questsPanel.resize(App.self.stage.stageHeight - questsPanel.y - 160);
			}
		}
	}
}
import buttons.ImageButton;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.QuestsChaptersWindow;

internal class QuestManagerIcon extends LayerX {
	
	private var preloader:Preloader;
	private var imageBttn:ImageButton;
	
	public function QuestManagerIcon() {
		
		Load.loading(Config.getImage('content', 'UpdateIcon'), function(data:Bitmap):void {
			if (preloader && preloader.parent)
				removeChild(preloader);
			
			imageBttn = new ImageButton(data.bitmapData);
			imageBttn.tip = function():Object { 
				return {
					title:Locale.__e('flash:1464359214772'),
					text:''
				};
			};
			imageBttn.addEventListener(MouseEvent.CLICK, onClick);
			addChild(imageBttn);
		});
		
		if (imageBttn) return;
		
		preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = 0.66;
		preloader.x = 35;
		preloader.y = 35;
		addChild(preloader);
	}
	
	protected function onClick(e:MouseEvent = null):void {
		if (App.user.quests.tutorial) return;
		new QuestsChaptersWindow().show();
	}
	
	public function clear():void {
		if (imageBttn) {
			imageBttn.removeEventListener(MouseEvent.CLICK, onClick);
		}
	}
	
}

