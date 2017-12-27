package wins {
	
	import buttons.Button;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Hut;

	public class BonusVisitingWindow extends Window {
		
		public var bonus:Object = { };
		private var descBg:Bitmap;
		private var giftSprite:Sprite;
		private var getBttn:Button;
		
		public function BonusVisitingWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			if (settings.hasOwnProperty('bonus'))
				bonus = settings.bonus;
			
			/*bonus = { 2:10,
					3:20,
					4:30,
					5:40,
					12:50
			}*/
			
			settings['faderAsClose'] = true;
			settings['faderClickable'] = false;
			settings['escExit'] = false;
			settings['hasExit'] = false;
			settings['hasTitle'] = true;
			settings["title"] = Locale.__e("flash:1413800714577");
			settings['fontSize'] = 48;
			settings['width'] = 575;
			settings['height'] = 410;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			
			if(Numbers.countProps(bonus) == 4)
				settings['width'] = 718;
			if(Numbers.countProps(bonus) == 5)
				settings['width'] = 861;
			
			super(settings);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowColor			: settings.shadowColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				shadowSize			:4
			})
				
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = -40;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.y = 32;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			titleLabel.y += 8;
			
			var preloader:Preloader = new Preloader();
			preloader.x = settings.width / 2;
			preloader.y = -160;
			bodyContainer.addChild(preloader);
			
			var bitmap:Bitmap = new Bitmap();
			layer.addChild(bitmap);
			var imagePath:String = Config.getImage('promo/images', 'ComebackPic');
			Load.loading(imagePath , function(data:Bitmap):void {
				bodyContainer.removeChild(preloader);
				bitmap.bitmapData = data.bitmapData;
				bitmap.x = (settings.width - bitmap.width) / 2;
				bitmap.y = -180;
			});
			
			drawDescription();
			drawGift();
			drawButtons();
			
			this.y += 80;
			fader.y -= 80;
		}
		
		private var bg:Bitmap;
		private function drawDescription() : void {
			bg = Window.backing(settings.width - 140, 82, 50, 'fadeOutWhite');
			bg.x = (settings.width - bg.width) / 2 + 5;
			bg.y = 45;
			bg.alpha = 0.2;
			bodyContainer.addChild(bg);
			
			var separator:Bitmap = Window.backingShort(settings.width - 140, 'dividerLine', false);
			separator.x = bg.x;
			separator.y = bg.y;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(settings.width - 140, 'dividerLine', false);
			//separator2.scaleY = -1;
			separator2.x = separator.x;
			separator2.y = bg.y + bg.height - 4;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var descText:TextField = Window.drawText(Locale.__e("flash:1431421322596"), {
				fontSize:26,
				color:0x5c320c,
				border:false,
				textAlign:"center",
				autoSize:"center"
			});
			descText.x = (settings.width - descText.width) / 2;
			descText.y = bg.y + 10;
			bodyContainer.addChild(descText);
		}
		
		private var sprite:Sprite = new Sprite();
		private function drawGift() : void {
			bodyContainer.addChild(sprite);
			
			var Xs:int = 0;
			var Ys:int = 130;
			sprite.y = Ys;
			for (var s:* in bonus) {
				var item:BonusVisitingItem = new BonusVisitingItem({sID:s, count:bonus[s]});
				item.x = Xs;
				sprite.addChild(item);
				
				Xs += item.bg.width + 20;
			}
			
			sprite.x = (settings.width - sprite.width) / 2;
			/*var bonusList:RewardListB = new RewardListB(bonus, false, 0, '', 1, 40, 16, 40, 'x', 1, 0, 0, true);
			bonusList.x = (bonusList.width / 2) * Numbers.countProps(bonus) + 25;
			if(Numbers.countProps(bonus) == 4)
				bonusList.x += 16;
			if(Numbers.countProps(bonus) == 5)
				bonusList.x += 32;
			bonusList.y = 100;
			bodyContainer.addChild(bonusList);*/
		}
		
		private function drawButtons() : void {
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379737"),
				fontSize:32,
				width:200,
				height:58
			};
			getBttn = new Button(bttnSettings);
			getBttn.x = (settings.width - getBttn.width) / 2;
			getBttn.y = settings.height - 90;
			bodyContainer.addChild(getBttn);
			getBttn.addEventListener(MouseEvent.CLICK, onTakeEvent);
		}
		
		private function onTakeEvent(e:MouseEvent):void {
			getBttn.state = Button.DISABLED;
			if (settings.hasOwnProperty('type') && settings.type == 'lack') {
				apply();
			}else {
				App.user.stock.addAll(bonus);
				take(bonus, getBttn);
				close();
			}
		}
		
		private function apply():void {
			var window:* = this;
			
			Post.send({
				ctr:'bonus',
				act:'lack',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					close();
					return;
				}
				if (data && data.bonus) {
					App.user.stock.addAll(data.bonus);
					take(data.bonus, getBttn);
				}
				
				setTimeout(function():void {
					close();
					
					if (settings.onTake != null)
						settings.onTake();
						
				}, 1000);
				
			});
			
			/*if (settings.onTake != null)
				settings.onTake();*/
		}
		
		private function take(items:Object, target:*):void {
			for(var i:String in items) {
				var item:BonusItem = new BonusItem(uint(i), items[i]);
				var point:Point = Window.localToGlobal(target);
				item.cashMove(point, App.self.windowContainer);
			}
		}
		
		public override function dispose():void	{
			super.dispose();
		}
	}
}
import buttons.Button;
import core.Load;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import units.Hut;
import units.Techno;
import units.WorkerUnit;
import wins.TechnoManagerWindow;
import wins.Window;

internal class BonusVisitingItem extends Sprite
{
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	private var count:uint;
	private var preloader:Preloader;
	
	public function BonusVisitingItem(data:Object)
	{
		this.sID = data.sID;
		this.item = App.data.storage[sID];
		this.count = data.count;
		
		bg = new Sprite();
		bg.graphics.beginFill(0xcbd4cf);
		bg.graphics.drawCircle(65, 100, 65);
		bg.graphics.endFill();
		addChild(bg);
		
		preloader = new Preloader();
		preloader.x = (bg.width - preloader.width) / 2;
		preloader.y = (bg.height - preloader.height) / 2;
		addChild(preloader);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawCount();
		drawTitle();
	}
	
	private function onLoad(data:Bitmap):void {
		if (preloader) {
			removeChild(preloader);
		}
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		addChildAt(bitmap, 1);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 + 35;
		bitmap.smoothing = true;
	}
	
	public function drawCount():void {
		var textCount:TextField = Window.drawText('x' + this.count, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07,
			width: bg.width,
			textAlign:'center'
		});
		textCount.y = bg.y + bg.height + 25;
		addChild(textCount);
	}
	
	public function drawTitle():void {
		var textTitle:TextField = Window.drawText(item.title, {
			color:0x7b3e07,
			fontSize:28,
			borderColor:0xffffff,
			width:bg.width,
			textAlign:'center'
		});
		textTitle.y = 0;
		addChild(textTitle);
	}
}

