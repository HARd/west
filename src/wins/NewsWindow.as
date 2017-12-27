package wins {
	
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Log;
	import core.Post;
	import core.TimeConverter;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Hut;
	import units.Pigeon;
	import wins.elements.RewardListActive;

	public class NewsWindow extends Window {
		private var items:Array = new Array();
		public var action:Object;
		private var container:Sprite;
		private var priceBttn:Button;
		private var okBttn:Button;
		private var descTextTitle:TextField;
		private var up_devider:Bitmap;
		private var descriptionLabel:TextField;
		private var canTell:Boolean = false;
		private var checkBox:CheckboxButton;
		
		public var extra:ExtraItem;
		
		public function NewsWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
			action = settings['news'];
			settings['width'] = 495;
			settings['height'] = 375;
			
			descTextTitle = drawText(Locale.__e("flash:1428068259484"),{
				color				:0xffffff,
				borderColor			:0x814f31,
				shadowColor			:0x814f31,
				shadowSize			:1,
				multiline			:true,
				fontSize			:30,
				autoSize			:"center"
			});
			descTextTitle.x = (settings.width - descTextTitle.textWidth) / 2;
			descTextTitle.y = 190;
			
			up_devider = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 75;
			up_devider.y = descTextTitle.y + descTextTitle.height - 15;
			up_devider.width = settings.width - 150;
			up_devider.alpha = 0.5;
			
			//потом закоментировать
			//action.description = "- Новые баги!\n- Еще больше доната!\n- Красивие ништяки.\n- Курочки.";
			
			var text:String = Locale.__e(action.description);
			text = text.replace(/\r/g, '');
			text = text.replace(/\n\n/g, '\n');
			
			descriptionLabel = drawText(text, {
				fontSize:26,
				autoSize:"left",
				textAlign:"left",
				color:0x6b3a0f,
				borderColor:0xfff7ee,
				multiline:true
			});
			descriptionLabel.wordWrap = true;
			descriptionLabel.width = 320;
			descriptionLabel.height = descriptionLabel.textHeight;
			descriptionLabel.x = 90;
			descriptionLabel.y = up_devider.y + 20;
			
			/*if (descriptionLabel.numLines > 5) {
				var delta:int = (descriptionLabel.numLines - 5) * 30;
				settings['height'] = 400 + delta;
			}*/
			
			settings['title'] = action.title;
			settings['hasExit'] = false;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 4;
			settings['background'] = 'alertBacking';
			
			if (App.isSocial('DM','VK'/*,'FB'*/) && App.user.settings.hasOwnProperty('upd')) {
				var array:Array = App.user.settings.upd.split('_');
				if (!array[2] || array[2] == '0') canTell = true;
			}
			
			super(settings);
			
			//потом убрать
			//canTell = true;
		}
		
		override public function drawFader():void {
			super.drawFader();
			this.y -= 80;
			fader.y += 80;
		}
		
		override public function drawBackground():void {
			//
		}
		
		override public function drawTitle():void {
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
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2 + 40;
			titleLabel.y = 35;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
			titleLabel.visible = false;
		}
		
		override public function drawBody():void {
			var heightWin:int = descriptionLabel.height + 190;
			if (canTell) heightWin += 40;
			
			/*if (!App.isSocial('MX','YB')) background = backing(settings.width + 10, heightWin + 10, 45, 'winterBacking');
			else */background = backing(settings.width, heightWin, 45, 'alertBackingEmpty');
			layer.addChild(background);
			
			/*if (!App.isSocial('MX','YB')) bg = Window.backing(settings.width - 65, heightWin - 75, 30, 'dialogueBacking');
			else */bg = Window.backing(settings.width - 70, heightWin - 80, 30, 'dialogueBacking');
			bg.x = (settings.width - bg.width) / 2;
			bg.y = 145;
			bodyContainer.addChild(bg);
			
			background.y += 95;
			
			//bodyContainer.addChild(titleLabel);
			//titleLabel.x = (background.width - titleLabel.width) / 2 + 50;
			//titleLabel.y = 126;
			
			var titleText:TextField = drawText(settings.title, {
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleText.y = 125;
			bodyContainer.addChild(titleText);
			
			bodyContainer.addChild(up_devider);
			bodyContainer.addChild(descTextTitle);
			
			bodyContainer.addChild(descriptionLabel);
			drawImage();
			
			okBttn = new Button({
				caption:Locale.__e('flash:1382952380228'),
				fontSize:((App.social == 'NK') ? 30 : 36),
				width:200,
				height:54,
				hasDotes:false
			});
				
			bodyContainer.addChild(okBttn);
			okBttn.x = (settings.width - okBttn.width) / 2;
			okBttn.y = background.y + background.height - 50;
			okBttn.addEventListener(MouseEvent.CLICK, onOkBttn);
			
			if (!canTell) return;
			
			checkBox = new CheckboxButton();
			checkBox.x = (settings.width - 160) / 2 + 24;
			checkBox.y = okBttn.y - 35;
			bodyContainer.addChild(checkBox);
			
			//var items:Object = { };
			//items[Stock.FANT] = 1;
			//var rewards:RewardListActive = new RewardListActive(66, 66, items, { padding:16 });
			//rewards.x = settings.width - 50 - rewards.width;
			//rewards.y = okBttn.y - rewards.height + 10;
			//bodyContainer.addChild(rewards);
			
			extra = new ExtraItem(this);
			extra.x = okBttn.x + okBttn.width + 15;
			extra.y = background.y + background.height - 75;
			bodyContainer.addChild(extra);
		}
		
		private function onOkBttn(e:MouseEvent):void {
			if (checkBox && checkBox.checked == true) {
				sendPost();
			}else{
				showUpdate();
			}
		}
		
		private function showUpdate():void {
			close();
			ShopWindow.show( { section:100, page:0 } );
			Pigeon.dispose();
		}
		
		private var randomKey:String;
		public function sendPost():void {
			okBttn.state = Button.DISABLED;
			
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
			okBttn.state = Button.NORMAL;
			
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
			
			showUpdate();
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
				image.y = -image.height + 195;
				bodyContainer.addChildAt(image, 0);
				bodyContainer.addChild(titleLabel);
				//titleLabel.x = (settings.width - titleLabel.width) / 2;
			});
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
		
		//extra = App.data.levels[App.user.level].extra;
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