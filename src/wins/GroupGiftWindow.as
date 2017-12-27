package wins {
	
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.IsoConvert;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	public class GroupGiftWindow extends Window {
		
		public static var inGroup:Boolean = false;
		public static var groupLink:String = '';
		
		private var bitmapImage:Bitmap;
		private var bitmapTitle:Bitmap;
		private var descLabel:TextField;
		private var desc2Label:TextField;
		private var checkBttn:CheckboxButton;
		private var enterBttn:Button;
		
		private var bonus:*;
		
		public function GroupGiftWindow(settings:Object = null) {
			if (!settings) settings = { };
			settings['width'] = settings['width'] || 580;
			settings['height'] = settings['height'] || 330;
			settings['title'] = Locale.__e('flash:1406554897349');
			settings['hasPaginator'] = false;
			settings['background'] = 'commGiftWin';
			settings['hasExit'] = false;
			settings['faderAsClose'] = false;
			
			bonus = settings['bonus'];
			//bonus['3'] = 350;
			//bonus['17'] = 50;
			//bonus['21'] = 5;
			settings['content'] = new Array();
			
			for (var item:* in bonus)
			{
				settings.content.push({sid:item, count:bonus[item]});
			}
			
			super(settings);
		}
		
		public static function addWindow():void {
			//if (App.isSocial('VK', 'OK', 'MM', 'FB') && App.user.level >= 4 && App.user.storageRead('gw', 1) == 1) {
				//// Найти ссылку на группу для соцсети
				//if (App.data.options.hasOwnProperty('GroupLinks')) {
					//var soc:Object = JSON.parse(App.data.options.GroupLinks);
					//if (soc.hasOwnProperty(App.social))
						//groupLink = soc[App.social];
				//}
				//
				//// Если ссылки нет (groupLink == null) не показываем окно
				//if (groupLink.length == 0) return;
				//
				//// Проверяем наличие в группе и показываем окно
				//if (ExternalInterface.available) {
					//ExternalApi.checkGroupMember(function(param:*):void {
						//if (param == 1)
							//inGroup = true;
					//});
					//setTimeout(function():void {
						//if (!inGroup) {
							//new GroupWindow().show();
						//}
					//}, 5000);
				//}else {
					new GroupGiftWindow().show();
				//}
			//}
		}
		
		private var pic:Bitmap;
		override public function drawBackground():void {
			
			var background:Bitmap = backing(settings.width, settings.height, 35, "alertBacking");
			bodyContainer.addChild(background);
			
			pic = new Bitmap(Window.textures.giftWinPic);
			pic.smoothing = true;
			pic.x = (settings.width - pic.width) / 2;
			pic.y -= 250;
			bodyContainer.addChild(pic);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 40,
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
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2 + 45;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			
			headerContainer.addChild(titleLabel);
		}
		
		public var groupGiftLabel:TextField;
		private const MATERIAL_MARGIN:int = 170;
		private const LEFT_MARGIN:int = 20;
		private var items_margin:int = 0;
		private var headContainer:Sprite;
		override public function drawBody():void {
			super.drawBody();
			
			drawPresent();
			
			enterBttn = new Button( {
				fontSize:	32,
				width:		186,
				height:		50,
				caption:	Locale.__e('flash:1382952379737')
			});
			enterBttn.x = (settings.width - enterBttn.width) / 2;
			enterBttn.y = settings.height - enterBttn.height - 10;
			bodyContainer.addChild(enterBttn);
			enterBttn.addEventListener(MouseEvent.CLICK, onEnter);
		}
		
		private var itemsContainer:Sprite = new Sprite();
		public function drawPresent():void {
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 110;
			itemsContainer.x = 85;
			itemsContainer.y = Ys;
			for each (var item:* in settings.content) {
				var gift:ItemGift = new ItemGift(item.sid, item.count);
				gift.x = Xs;
				itemsContainer.addChild(gift);
				
				Xs += gift.background.width + 20;
			}
			
			bodyContainer.addChild(itemsContainer);
			itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		public function onEnter(e:MouseEvent = null):void {
			var obj:Object = {
				ctr:	'user',
				act:	settings.mode,
				uID:	App.user.id
			};
			obj[settings.mode] = settings.id;
			Post.send(obj, onBlink);
			close();
		}
		
		public function onBlink(error:int, data:Object = null, params:Object = null):void {
			if (error) {
				close();
				return;
			}
			
			//var tresItem:Object = { };
			//tresItem[settings.sid] = settings.count;
			//tresItem = Treasures.convert(tresItem);
			App.user.stock.addAll(settings.bonus);
			
			//var conv:Object = IsoConvert.screenToIso(itmGift.x, itmGift.y);
			//var point:Point = new Point(conv.x, conv.y);
			//Treasures.bonus(settings.bonus, point, null, true);
			
			//if (settings.bonus) {
				//App.user.stock.addAll(settings.bonus);
				//take(settings.bonus, takeBttn);
			//}
			//else {
				//App.user.stock.addAll(App.data.blinks[App.blink].bonus);
				//take(App.data.blinks[App.blink].bonus, takeBttn);
			//}
		}
		
		override public function dispose():void {
			super.dispose();
			enterBttn.removeEventListener(MouseEvent.CLICK, onEnter);
		}
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class ItemGift extends Sprite {
	public var background:Bitmap;
	public var sid:int;
	public var count:int = 0;
	public var itmGift:Bitmap = new Bitmap();
	private var preloader:Preloader = new Preloader();
	
	public function ItemGift(sid:uint, count:int):void {
		this.sid = sid;
		this.count = count;
		
		background = new Bitmap(new BitmapData(50 * 2, 50 * 2, true, 0xffffff));
		addChild(background);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xc8cabc, 1);
		shape.graphics.drawCircle(50, 50, 50);
		shape.graphics.endFill();
		background.bitmapData.draw(shape);
		
		addChild(preloader);
		preloader.scaleX = preloader.scaleY = 0.6;
		preloader.x = (background.width - preloader.width) / 2 + 20;
		preloader.y = (background.height - preloader.height) / 2 + 20;
			
		var item:Object = App.data.storage[sid];
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
	}
	
	public function onLoad(data:Bitmap):void {
		if(contains(preloader)){
			removeChild(preloader);
		}
			
		itmGift.bitmapData = data.bitmapData;
		itmGift.smoothing = true;
		if (sid == 4) {
			itmGift.x = (background.width - data.width) / 2 - 20;
			itmGift.y = (background.height - data.height) / 2 - 20;
		} else {
			itmGift.x = (background.width - data.width) / 2 + 10;
			itmGift.y = (background.height - data.height) / 2 + 10;
		}
		Size.size(itmGift, 90, 90);
		App.ui.flashGlowing(itmGift);
		
		addChild(itmGift);
		
		drawCount();
	}
	
	public function drawCount():void {
		var countOnStock:TextField = Window.drawText('x' + count || "", {
			color:0xefcfad9,
			borderColor:0x764a3e,  
			fontSize:30,
			autoSize:"left"
		});
		
		var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
		
		addChild(countOnStock);
		countOnStock.x = (background.width - countOnStock.width) / 2;
		countOnStock.y = background.height + 10;
	}
}