package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class BuildingConstructWindow extends Window
	{
		public var items:Array = new Array();
		
		private var _nextLevel:uint = 0;
		public var buildBttn:Button;
		public var buyAllBttn:MoneyButton;
		
		private var buyPrice:uint = 0;
		
		private var wishList:* = null;
		
		public function BuildingConstructWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] = 612;
			settings['height'] = 490;
			settings['hasPaper'] = true;
						
			settings['title'] = settings.title;
			//settings['titleScaleX'] = 0.76;
			//settings['titleScaleY'] = 0.76;
			
			settings['hasPaginator'] = false;
			settings['description'] = Locale.__e("flash:1382952380001");
			
			_nextLevel = Number(settings["level"]) + 1;
			
			super(settings);
			//SoundsManager.instance.playSFX("window")
		}
		
		override public function drawBody():void {
			drawStageInfo();
			drawBonusInfo();
			drawDevelsInfo();
			drawBttns();
			checkDevels();
		}
		
		private function checkDevels(e:* = null):Boolean
		{			
			var check:Boolean = true;
			var cantBuy:Boolean = false;
			buyPrice = 0;

				for (var sID:* in settings.devels)
				{
					if (App.data.storage[sID].type == 'Floors') 
					{
						for each(var _item:* in items) 
						{
							if (_item.sID == sID) 
							{
								if (_item.status != MaterialItem.READY)
									check = false;
							}
							if (App.data.storage[sID].real == 0)
								cantBuy = true;
						}
					}
					else
					{
						var needBuyCount:int = 0;
						var count:int = settings.devels[sID];
						
						var countOnStock:int = App.user.stock.count(sID);
						
						if (countOnStock < count)
						{
							needBuyCount = count - countOnStock;
							buyPrice += needBuyCount * App.data.storage[sID].real;
							check = false;
						}
						
						if (App.data.storage[sID].real == 0) 
						{
							cantBuy = true;
						}
					}
				}
				
					if (check == true)
					{
						buildBttn.visible = true;
						buyAllBttn.visible = false;
					}
					else
					{
						buildBttn.visible = false;
						buyAllBttn.visible = true;
						buyAllBttn.count = String(buyPrice);
						
						if (cantBuy == true) 
						{
							buyAllBttn.visible = false;
						}else 
						{
							buyAllBttn.visible = true;
						}
					}
			
			//if (settings.devels.hasOwnProperty/*("h")*/) 
			//{
				buyAllBttn.visible = /*false*/true;
				
				/*for each(var item:* in items)
				{
					if (item.ready == false && item.rent == false) check = false;
				}*/
				
				if (check == true)	buildBttn.state = Button.NORMAL;
				else 				buildBttn.state = Button.DISABLED;
			
			return check;
		}
		
		private function drawBttns():void{
			
			buildBttn = new Button({
				caption		:Locale.__e("flash:1382952379806"),
				width		:141,
				height		:38,	
				fontSize	:26
			});
			
			buildBttn.x = (settings.width - buildBttn.width) / 2;
			buildBttn.y = 372;
			
			buyAllBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380002"),
				width		:170,
				height		:42,	
				fontSize	:26,
				countText	:90
			});
			buyAllBttn.x = (settings.width - buyAllBttn.width) / 2;
			buyAllBttn.y = 372;
			//buyAllBttn.textLabel.y -= 3;
			
			bodyContainer.addChild(buildBttn);
			bodyContainer.addChild(buyAllBttn);
			
			buildBttn.addEventListener(MouseEvent.CLICK, buildEvent);
			buyAllBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
		}
		
		private function buildEvent(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.upgradeCallback(settings.devels);
			bonusList.take();
			close();
		}
		
		override public function dispose():void
		{
			removeEventListener(WindowEvent.ON_CONTENT_UPDATE, checkDevels);
			buildBttn.removeEventListener(MouseEvent.CLICK, buildEvent);
			buyAllBttn.removeEventListener(MouseEvent.CLICK, buyAllEvent);
			
			for each(var item:* in items)
			{
				item.dispose();
				item.removeEventListener(WindowEvent.ON_CONTENT_UPDATE, checkDevels);
				item = null;
			}
			super.dispose();
		}
		
		private function buyAllEvent(e:MouseEvent):void
		{
			if (App.user.stock.take(Stock.FANT, buyPrice))
			{
				var params:Object = { };
				params[Stock.FANT] = buyPrice;
				
				settings.upgradeCallback(params);
				
				bonusList.take();
			}
			
			close();
		}
		
		private function drawDevelsInfo():void{
			
			var bg:Bitmap = backing(500, 230, 50);
			bg.x = (settings.width - bg.width)*.5;
			bg.y = 135;
				
			var develText:TextField = drawText(
				Locale.__e("flash:1382952380003"), 
				{
					fontSize	:24,
					color		:0xfcf5e5,
					borderColor	:0x604b22,
					autoSize	:"left"
				}
			)
				
			develText.x = settings['width'] / 2 - develText.width / 2;
			develText.y = 105;	
			
			bodyContainer.addChild(bg);
			bodyContainer.addChild(develText);
			
			createItems();
		}
		
		public var bonusList:BonusList;
		private function drawBonusInfo():void{
			
			bonusList = new BonusList(settings.bonus[_nextLevel]);
			bodyContainer.addChild(bonusList);
			bonusList.x = 225;
			bonusList.y = 35;
		}
		
		private function drawStageInfo():void{
			
			var textSettings:Object = 
			{
				title		:Locale.__e("flash:1382952380004", [_nextLevel, settings["totalLevels"]]),
				title		:Locale.__e("flash:1382952380004", [_nextLevel, settings["totalLevels"]]),
				fontSize	:32,
				color		:0x564c45,
				borderColor	:0xf9f2dd,
				autoSize	:"left",
				width		:300	
			}
			
			var titleText:Sprite = titleText(textSettings);
				titleText.x = 60;
				titleText.y = 45;
				bodyContainer.addChild(titleText);
		}
		
		public function createItems():void{
			
			var X:int = 74;
			var Y:int = 150;
			for (var sID:* in settings.devels)
			{	
				var count:uint = settings.devels[sID];
				
				var item:MaterialItem = new MaterialItem({
					sID:sID, 
					need:count, 
					window:this, 
					type:MaterialItem.IN
				});
				
				bodyContainer.addChild(item);
				items.push(item);
				item.addEventListener(WindowEvent.ON_CONTENT_UPDATE, checkDevels);
				
				item.x = X;
				item.y = Y;
				
				X += item.width + 8;
				
				item.checkStatus();
			};
			var itemNum:int = 0;
		}
	}
}

import buttons.Button;
import buttons.MoneyButton;
import core.AvaLoad;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.FriendsWindow;
import wins.WindowEvent;

internal class HelperItem extends Sprite
{
	public var price:uint;
	public var bg:Sprite;
	public var bitmap:Bitmap;
	public var sprite:LayerX;
	public var rentBttn:Button;
	public var fireBttn:Button;
	public var buyBttn:MoneyButton;
	public var win:*;
	
	public var _ready:Boolean = false;
	public var friend:Object;
	public var role:String;
	public var _rent:Boolean = false;
	
	public function HelperItem(role:String, price:uint, win:*)
	{
		this.role = role;
		this.win = win;
		this.price = price;
		bitmap = new Bitmap();
		bg = Window.shadowBacking(115, 115, 10);
		addChild(bg);
		sprite = new LayerX();
		addChild(sprite);
		sprite.addChild(bitmap);
		drawBttns();
		
		sprite.tip = function():Object {
			return { text:Locale.__e("flash:1382952380005")}
		}
		
		var text:TextField = Window.drawText(Locale.__e('flash:1382952380006'), {
			fontSize:20,
			color:0x502f06,
			borderColor:0xf8f2e0
		});
		
		addChild(text);
		text.width = text.textWidth + 5;
		text.x = bg.width / 2 - text.textWidth / 2;
		text.y = -7;
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000, 1);
		shape.graphics.drawRoundRect(0, 0, 106, 106, 16, 16);
		shape.graphics.endFill();
		sprite.mask = shape;
		sprite.addChild(shape);
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y = (bg.height - sprite.height) / 2;
	}
	
	public function checkOnHelper(data:Object = null):void
	{
		if (data != null)
		{
			if (data[role] != null)
			{
				if (data[role] == 0)
				{
					rent = true;
					return;
				}
				else
				{
					friend = App.user.friends.data[data[role]];
					if(friend != null)
						ready = true;
					else
						ready = false;
					return;
				}	
			}
		}
		ready = false;
	}
	
	private var preloader:Preloader = new Preloader();
	public function set ready(value:Boolean):void
	{
		//preloader.x = (background.width)/ 2;
		//preloader.y = (background.height) / 2;
		
		bitmap.x = 0;
		bitmap.y = 0;
		bitmap.filters = [];
		
		_ready = value;
		if (_ready)
		{
			addChild(preloader);
			//Load.loading(this.friend.photo, onLoad);
			new AvaLoad(this.friend.photo, onLoad);
			
			rentBttn.visible = false;
			fireBttn.visible = true;
			buyBttn.visible = false;
		}
		else
		{
			
			addChild(preloader);
			Load.loading(Config.getIcon('Material', 'friends'), onLoad);
			
			//UserInterface.effect(bitmap, 0, 0);
			friend = null;
			rentBttn.visible = true;
			fireBttn.visible = false;
			buyBttn.visible = true;
		}
	}
	public function get ready():Boolean
	{
		return _ready;
	}
	
	public function set rent(value:Boolean):void
	{
		_rent = value;
		
		addChild(preloader);
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height) / 2;
		
		if (_rent)
		{
			rentBttn.visible = false;
			fireBttn.visible = false;
			buyBttn.visible = false;
			bitmap.bitmapData = Window.textures.bearHead;
			
			onLoad(bitmap);
			bitmap.filters = [];
		}
		else
		{
			rentBttn.visible = true;
			fireBttn.visible = false;
			buyBttn.visible = true;
			Load.loading(Config.getIcon('Material', 'friends'), onLoad);
			//UserInterface.effect(bitmap, 0, 0);
		}
		
		
		//bitmap.width = bitmap.bitmapData.width;
		//bitmap.height = bitmap.bitmapData.height;
		//bitmap.x = (106 - bitmap.width) / 2;
		//bitmap.y = (106 - bitmap.height) / 2 + 8;
		
	}
	public function get rent():Boolean
	{
		return _rent;
	}
	
	private function onLoad(data:Bitmap):void
	{
		
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.smoothing = true;
		bitmap.width = data.width;
		bitmap.height = data.height;
		
		if (bitmap.width < 60)
		{
			bitmap.width = 106;
			bitmap.height = 106;
			
			bitmap.x = (bg.width - bitmap.width)/2 - 6
			bitmap.y = (bg.height - bitmap.height)/2 - 8
			return;
		}
		
		bitmap.x = (106 - bitmap.width) / 2;
		bitmap.y = (106 - bitmap.height) / 2 + 3;
	}
	
	private function drawBttns():void
	{
		rentBttn = new Button({
			caption		:Locale.__e("flash:1382952380007"),
			width		:121,
			height		:37,
			fontSize	:25	
		});
				
		fireBttn = new Button({
			caption		:Locale.__e("flash:1382952380008"),
			width		:121,
			height		:37,
			fontSize	:25,	
			bgColor:[0xe0d2b2,0xc0b292]
		});
				
		rentBttn.x = fireBttn.x = bg.width / 2 - rentBttn.width / 2;
		rentBttn.y = fireBttn.y = bg.height;
			
		buyBttn = new MoneyButton({
			caption		:Locale.__e('flash:1382952380009'),
			width		:121,
			height		:37,	
			fontSize	:18,
			countText	:price,
			multiline	:true
			});
		
		buyBttn.x = bg.width / 2 - buyBttn.width / 2;
		buyBttn.y = rentBttn.y + rentBttn.height + 2;
				
		addChild(rentBttn);
		addChild(fireBttn);
		
		addChild(buyBttn);
		
		buyBttn.addEventListener(MouseEvent.CLICK, onRentAction);
		rentBttn.addEventListener(MouseEvent.CLICK, onHireBttn);
		fireBttn.addEventListener(MouseEvent.CLICK, onFireBttn);
	}
	
	private function onHireBttn(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		rentBttn.state = Button.DISABLED;
		
		new FriendsWindow( {
			onSelectFriend:onHireAction,
			onClose:function():void { rentBttn.state = Button.NORMAL; }
		}).show();
	}
	
	private function onFireBttn(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		fireBttn.state = Button.DISABLED;
		
		Post.send({
				ctr:win.settings.target.type,
				act:'fire',
				uID:App.user.id,
				id:win.settings.target.id,
				wID:App.user.worldID,
				sID:win.settings.target.sid,
				role:this.role
			}, onFireEvent);
	}
	
	private function onFireEvent(error:int, data:Object, params:Object):void 
	{
		fireBttn.state = Button.NORMAL;
		if (error) {
			Errors.show(error, data);
			//TODO Отменяем проflash:1382952379993влодство
			return;
		}
		
		App.user.friends.data[friend.uid].hire = 0;
		ready = false;
		dispatchEvent(new WindowEvent("onContentUpdate"));
		win.settings.target.changeHelpers(role, "remove");
	}
	
	private function onHireAction(friend:Object):void
	{
		this.friend = friend;
		
		Post.send({
				ctr:win.settings.target.type,
				act:'hire',
				uID:App.user.id,
				id:win.settings.target.id,
				wID:App.user.worldID,
				fID:friend.uid,
				sID:win.settings.target.sid,
				role:this.role
			}, onHireEvent);
	}
	
	private function onHireEvent(error:int, data:Object, params:Object):void 
	{
		rentBttn.state = Button.NORMAL;
		if (error) {
			Errors.show(error, data);
			//TODO Отменяем проflash:1382952379993влодство
			return;
		}
		
		App.user.friends.data[friend.uid].hire = App.time;
		ready = true;
		dispatchEvent(new WindowEvent("onContentUpdate"));
		win.settings.target.changeHelpers(role, String(friend.uid));
	}

	private function onRentAction(friend:Object):void
	{
		this.friend = friend;
		
		var params:Object = {
				FANT:price
			};
			
		if (!App.user.stock.take(Stock.FANT, price)) 
		{
			return;
		}
		
		rent = true;
		
		Hints.minus(Stock.FANT, price, Window.localToGlobal(rentBttn));
		Post.send({
				ctr:win.settings.target.type,
				act:'hire',
				uID:App.user.id,
				id:win.settings.target.id,
				wID:App.user.worldID,
				sID:win.settings.target.sid,
				rent:1,
				role:this.role
			}, onRentEvent, params);
	}
	
	private function onRentEvent(error:int, data:Object, params:Object):void 
	{
		rentBttn.state = Button.NORMAL;
		if (error) {
			Errors.show(error, data);
			for (var sID:* in params)
			{
				App.user.stock.add(sID, params[sID]);
			}	
			rent = false;
			//TODO Отменяем проflash:1382952379993влодство
			return;
		}
		
		App.user.stock.data[Stock.FANT] = data[Stock.FANT];
		dispatchEvent(new WindowEvent("onContentUpdate"));
		win.settings.target.changeHelpers(role, "rent");
	}
	
	public function dispose():void
	{
		
	}
}