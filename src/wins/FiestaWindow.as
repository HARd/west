package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import core.Log;
	import core.Post;
	import core.TimeConverter;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.elements.TimerUnit;

	public class FiestaWindow extends Window
	{
		private var back:Bitmap;
		private var eventManager:Object;
		private var shop:Object;
		public var action:Object;
		private var up_devider:Bitmap;
		private var shopBttn:Button;
		private var chaptersBttn:Button;
		private var prizeBttn:Button;
		private var canTell:Boolean = false;
		private var checkBox:CheckboxButton;		
		public var extra:ExtraItem;
		private var callback:Function;
		
		public function FiestaWindow(settings:Object = null):void
		{
			if (settings == null) {
				settings = new Object();
			}	
			action = settings['news'];
			eventManager = JSON.parse(App.data.options['EventManager']);
			
			settings["section"] = settings.section || "all"; 
			settings["page"] = settings.page || 0; 
			settings["find"] = settings.find || null;
			settings["title"] = action.title;
			settings["width"] = 620;
			settings["height"] = 470;
			settings["hasPaginator"] = false;
			settings["hasArrows"] = false;
			settings["itemsOnPage"] = 0;
			settings["buttonsCount"] = 0;
			settings["background"] = 'winterBacking';
			
			if (App.isSocial('DM','VK'/*,'FB'*/) && App.user.settings.hasOwnProperty('upd')) {
				var array:Array = App.user.settings.upd.split('_');
				if (!array[2] || array[2] == '0') canTell = true;
			}
				
			super(settings);
		}
		
		override public function drawBody():void {
			drawImage();
			
			var blank:Bitmap = Window.backing(settings.width - 70, settings.height - 90, 50, 'dialogueBacking');
			blank.x = 35;
			blank.y = 15;
			bodyContainer.addChild(blank);
			
			bodyContainer.addChild(titleLabel);
			titleLabel.y += 40;
			
			drawTimer();
			
			up_devider = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 75;
			up_devider.y = titleLabel.y + titleLabel.height + 15;
			up_devider.width = settings.width - 150;
			up_devider.alpha = 0.5;
			bodyContainer.addChild(up_devider);
			
			var descTextTitle:TextField = drawText(Locale.__e("flash:1428068259484"),{
				color				:0xffffff,
				borderColor			:0x814f31,
				shadowColor			:0x814f31,
				shadowSize			:1,
				multiline			:true,
				fontSize			:30,
				autoSize			:"center"
			});
			descTextTitle.x = (settings.width - descTextTitle.textWidth) / 2;
			descTextTitle.y = 80;
			bodyContainer.addChild(descTextTitle);
			
			drawDescription();
				
			Load.loading(
				Config.getImage('events', eventManager.img2.bitmap),function(data:*):void {
				draw(data.bitmapData);
			});
			drawButtons();
			App.self.setOnTimer(update);
			update();
			
			if (!canTell) return;
			
			checkBox = new CheckboxButton();
			checkBox.x = shopBttn.x + (shopBttn.width - checkBox.width) / 2 + 50;
			checkBox.y = 310;
			bodyContainer.addChild(checkBox);
			
			extra = new ExtraItem(this);
			extra.x = checkBox.x - 20;
			extra.y = background.y + background.height - 120;
			bodyContainer.addChild(extra);
		}
		
		private function update():void {
			/*if (eventManager.timeFinish > App.time) {
				textDay.text = TimeConverter.timeToDays(eventManager.timeFinish - App.time);
			}else this.close();*/
		}
		
		private function draw(ico:BitmapData):void {		
			var image:Bitmap;
			image = new Bitmap(ico);
			bodyContainer.addChild(image);
			image.x = eventManager.img2.dx;
			image.y = eventManager.img2.dy;
			if (eventManager.img2.scaleX == -1) {
				image.scaleX *= -1;
			}	
		}
		
		private function drawDescription():void {
			var text:String = Locale.__e(action.description);
			text = text.replace(/\r/g, '');
			text = text.replace(/\n\n/g, '\n');
			
			var descriptionLabel:TextField = drawText(text, {
				fontSize:25,
				autoSize:"left",
				textAlign:"left",
				color:0x6b3a0f,
				borderColor:0xfff7ee,
				multiline:true
			});
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = 290;
			descriptionLabel.height = descriptionLabel.textHeight;
			descriptionLabel.x = 90;
			descriptionLabel.y = up_devider.y + 20;
			
			bodyContainer.addChild(descriptionLabel);
		}
		
		private function drawButtons():void {
			var bttnSettings:Object = {
				fontSize:21,
				width:180,
				fontColor:				0xFFFFFF,				//Цвет шрифта
				fontBorderColor:		0x814f31,				//Цвет обводки шрифта	
				height:50
			};
			
			bttnSettings['caption'] = Locale.__e('flash:1447864875539');
			chaptersBttn = new Button(bttnSettings);
			chaptersBttn.x = settings.width - chaptersBttn.width - 70;
			chaptersBttn.y = 130;
			bodyContainer.addChild(chaptersBttn);
			chaptersBttn.addEventListener(MouseEvent.CLICK, onChapters);
			
			bttnSettings['caption'] = Locale.__e('flash:1440499603885');
			prizeBttn = new Button(bttnSettings);
			prizeBttn.x = settings.width - prizeBttn.width - 70;
			prizeBttn.y = chaptersBttn.y + chaptersBttn.height + 10;
			bodyContainer.addChild(prizeBttn);
			prizeBttn.addEventListener(MouseEvent.CLICK, onPrize);
			
			bttnSettings['caption'] = Locale.__e('flash:1382952380228');
			shopBttn = new Button(bttnSettings);
			shopBttn.x = settings.width - shopBttn.width - 70;
			shopBttn.y = prizeBttn.y + prizeBttn.height + 10;
			bodyContainer.addChild(shopBttn);
			shopBttn.addEventListener(MouseEvent.CLICK, onShop);
		}
		
		private function onChapters(e:MouseEvent = null):void {
			if (checkBox && checkBox.checked == true) {
				callback = onChapters;
				sendPost();
			}else {
				new QuestsChaptersWindow( { find:[30], popup:true } ).show();
				close();
			}
		}
		
		private function onPrize(e:MouseEvent = null):void {
			if (checkBox && checkBox.checked == true) {
				callback = onPrize;
				sendPost();
			}else {
				new InfoWindow( {
					popup:true,
					qID:'100800'
				}).show();
				close();
			}
		}
		
		private function onShop(e:MouseEvent = null):void {
			if (checkBox && checkBox.checked == true) {
				callback = onShop;
				sendPost();
			}else {
				shopIt();
				var window:ShopWindow;
				if (App.user.quests.tutorial)
					return;
					
				//window = new ShopWindow({popup:true});
				//window.show();
				//window.setContentNews(shop.data);
				close();
			}
		}
		
		private function shopIt():void 
		{
			if (shop == null) {
				shop = new Object();
				shop = {
					data:[],	
					page:0
				};
				
				for (var updateID:* in App.data.updates) {	
					if (updateID == action.nid){
						if (!App.data.updates[updateID].social || !App.data.updates[updateID].social.hasOwnProperty(App.social)) 
							continue;
						var updateObject:Object = {
							id:updateID,
							data:[]
						}
						
						var updatesItems:Array = [];
						var items:Object = App.data.updates[updateID].items;
						
						for (var _sid:* in items)
						{
							if (!App.data.storage.hasOwnProperty(_sid))
								continue;
							if (App.data.storage[_sid].visible == 0) continue;
							if (App.data.storage[_sid].type == 'Collection') continue;
							if (App.data.storage[_sid].type == 'Lands') continue;
							updatesItems.push( { sid:_sid, order:items[_sid] } );
						}	
						updatesItems.sortOn('order', Array.NUMERIC);
						for (var i:int = 0; i < updatesItems.length; i++) {
							updateObject.data.push(App.data.storage[updatesItems[i].sid]);
						}
						shop.data=updateObject.data;
					}
				}
			}	
		}
		
		private var randomKey:String;
		public function sendPost():void {
			chaptersBttn.state = Button.DISABLED;
			prizeBttn.state = Button.DISABLED;
			shopBttn.state = Button.DISABLED;
			
			randomKey = Config.randomKey;
			var linkType:String = '?ref=';
			if (App.isSocial('VK','ML')) linkType = '#';
			var url:String = Config.appUrl + linkType + 'oneoff' + randomKey + 'z';
			
			var message:String = Locale.__e('flash:1402657722719', [url]); // 'В игре Легенды снов новое обновление!\nРасскажи друзьям, получи кристалы!' + '\n' + Config.appUrl;
			
			if (image != null) {
				var beautyshot:BitmapData;
				var cont:Sprite = new Sprite();
				var bitmap:Bitmap = new Bitmap(image.bitmapData);
				cont.addChild(bitmap);
				
				//var gameTitle:Bitmap = new Bitmap(Window.textures.logo, "auto", true);
				var gameTitle:Bitmap = new Bitmap(UserInterface.textures.goldenLogo, "auto", true);
				gameTitle.scaleY = gameTitle.scaleX = 1.2;
				gameTitle.x = 0;
				gameTitle.y = image.height;// - gameTitle.height - 5;
				bitmap.x = (gameTitle.width - bitmap.width) / 2;
				cont.addChildAt(gameTitle, cont.numChildren);
				
				beautyshot = new BitmapData(cont.width, cont.height, false, 0xffffff);
				beautyshot.draw(cont);
				
				ExternalApi.apiWallPostEvent(ExternalApi.OTHER, new Bitmap(beautyshot), App.user.id, message, 0, onPostComplete);
			}
		}
		
		private function onPostComplete(result:*):void {
			chaptersBttn.state = Button.NORMAL;
			prizeBttn.state = Button.NORMAL;
			shopBttn.state = Button.NORMAL;
			
			Log.alert(result);
			Log.alert(canTell);
			
			if (!canTell || !result || result == 'null') return;
			
			Log.alert('START GET REWARD');
			
			var items:Object = extra.newsBonus;
			checkBox.state = Button.DISABLED;
			
			App.user.stock.addAll(items);
			App.ui.upPanel.update();
			
			canTell = false;
			
			if (App.user.settings.hasOwnProperty('upd')) {
				var array:Array = App.user.settings.upd.split('_');
				if (!array[2] || array[2] == '0') {
					array[2] = 1;
					App.user.storageStore('upd', array.join('_'), true, { tell:1} );
				}
			}
			
			Post.send( {
				ctr:	'oneoff',
				act:	'set',
				uID:	App.user.id,
				id:		randomKey
			}, function(error:int, data:Object, params:Object):void { } );
			
			if (callback != null) {
				callback();
				callback = null;
			}
		}
		
		private var preloader:Preloader = new Preloader();
		private var bg:Bitmap;
		private var image:Bitmap = new Bitmap();
		private function drawImage():void {
			bodyContainer.addChild(preloader);
			preloader.x = (settings.width )/ 2;
			preloader.y = 50;
			
			Load.loading(Config.getImageIcon('updates/images', action.preview), function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				
				image = new Bitmap(data.bitmapData);
				image.x = (settings.width - image.width) / 2;
				image.y = -image.height + 95;
				bodyContainer.addChildAt(image, 0);
				bodyContainer.addChild(titleLabel);
			});
		}
		
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			})
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -10;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
		}
		
		override public function titleText(settings:Object):Sprite
		{
			var titleCont:Sprite = new Sprite();
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			if (this.settings.hasTitle == true && this.settings.titleDecorate == true) {
				drawMirrowObjs('winterDec', textLabel.x + (textLabel.width - textLabel.textWidth) / 2 - 75, textLabel.x + (textLabel.width - textLabel.textWidth) / 2 + textLabel.textWidth + 75, textLabel.y + (textLabel.height - 80) / 2, false, false, false, 1, 1, titleCont);
			}
			
			titleCont.mouseChildren = false;
			titleCont.mouseEnabled = false;
			titleCont.addChild(textLabel);
			
			return titleCont;
		}
		
		private function drawTimer():void {
			var timer:TimerUnit = new TimerUnit( {backGround:'glow',width:140,height:60,time: { started:App.data.updatelist[App.social][action.nid], duration:336}} );
			timer.start();
			timer.x = (settings.width - timer.width) - 30;
			timer.y = 50;
			bodyContainer.addChild(timer);
		}
		
		override public function dispose():void {
			App.self.setOffTimer(update);
			chaptersBttn.removeEventListener(MouseEvent.CLICK, onChapters);
			prizeBttn.removeEventListener(MouseEvent.CLICK, onPrize);
			shopBttn.removeEventListener(MouseEvent.CLICK, onShop);
			super.dispose();
		}
	}
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;
import wins.RewardList;

internal class ExtraItem extends Sprite {
	
	public var extra:Object;
	public var bg:Bitmap;
	
	public function ExtraItem(window:*) {
		if (!App.data.options.hasOwnProperty('NewsBonus') || App.user.quests.tutorial) return;
		
		extra = JSON.parse(App.data.options.NewsBonus);
		
		bg = Window.backing(164, 92, 38, "shareBonusBacking");
		addChild(bg);
		drawTitle();
		drawReward();
	}
	
	private function drawTitle():void {
		var title:TextField = Window.drawText(Locale.__e("flash:1406545004234"), {
			fontSize	:17,
			color		:0x673a1f,
			borderColor	:0xffffff,
			textAlign   :'center',
			multiline   :true,
			wrap        :true
		});
		title.width = bg.width - 10;
		title.x = 5
		title.y = 6;
		addChild(title);
	}
	
	private function drawReward():void {
		var reward:RewardList = new RewardList(extra, false, 0, '', 1, 30, 16, 32, "x", 0.5, -8, 7, false, true);
		addChild(reward);
		reward.x = -10;
		reward.y = bg.height - reward.height - 10;
	}
	
	public function get newsBonus():Object {
		return extra;
	}
}