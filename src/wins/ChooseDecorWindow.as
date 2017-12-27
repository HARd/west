package wins 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	public class ChooseDecorWindow extends Window 
	{
		
		public function ChooseDecorWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 450;
			settings['height'] 			= 520;
			settings['title'] 			= settings.title || '';
			settings['parentDecor'] 	= settings.parentDecor || null;
			settings['parentSID']		= settings.parentSID || 0;
			settings['hasPaginator'] 	= true;
			settings['hasButtons']		= false;
			settings['itemsOnPage'] 	= 1;
			var items:Array = [];
			
			for (var _sid:* in App.data.storage) {
				if (App.data.storage[_sid].type == 'Decor' && App.data.storage[_sid].dtype == 2 && App.data.storage[_sid].parent == settings.parentSID)
					items.push({sid:_sid, item:App.data.storage[_sid]});
			}
			
			if (items.length == 0) {
				
				for (var sid:* in App.data.storage) {
					if (App.data.storage[sid].type == 'Decor' && App.data.storage[sid].dtype == 2 && App.data.storage[sid].parent == App.data.storage[settings.parentSID].parent)
						items.push({sid:sid, item:App.data.storage[sid]});
				}
			}
			
			settings['content']         = items;
			
			super(settings);
		}
	
		override public function drawBody():void {	
			var description:TextField = drawText(Locale.__e('flash:1435312332686'), {
				color:0x532b07,
				border:true,
				borderColor:0xfde1c9,
				fontSize:24,
				multiline:true,
				autoSize: 'center',
				textAlign:"center"
			});
			description.wordWrap = true;
			description.width = 350;
			description.x = (settings.width - description.width) / 2;
			description.y = 20;
			bodyContainer.addChild(description);
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.update();
				paginator.onPageCount = 1;
			}
			
			contentChange();
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		override public function contentChange():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			bodyContainer.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 100;
			//itemsContainer.x = (settings.width - itemsContainer.width)/ 2;
			itemsContainer.y = Ys;
			if (settings.content.length == 0) {
				var description:TextField = drawText(Locale.__e('flash:1435303214174'), {
					color:0x532b07,
					border:true,
					borderColor:0xfde1c9,
					fontSize:26,
					multiline:true,
					autoSize: 'center',
					textAlign:"center"
				});
				description.wordWrap = true;
				description.width = 550;
				description.x = (settings.width - description.width) / 2;
				description.y = (settings.height - description.height) / 2 - 30;
				bodyContainer.addChild(description);
				
				paginator.itemsCount = 0;
				paginator.update();
				return;
			}
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:DecorItem = new DecorItem(this, { sID:settings.content[i].sid, hut:settings.content[i] } );
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.bg.width + 20;
			}
			
			itemsContainer.x = (settings.width - itemsContainer.width) / 2;
		}
		
		public override function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			super.dispose();
		}
	
	}

}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import units.Decor;
import units.Unit;
import wins.ChooseDecorWindow;
import wins.ShopWindow;
import wins.SimpleWindow;
import wins.Window;

internal class DecorItem extends Sprite
{
	public var window:*;
	public var item:Object;
	public var bg:Sprite;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttnChange:Button;
	public var bttnBuy:MoneyButton;
	private var preloader:Preloader = new Preloader();
	
	public function DecorItem(window:ChooseDecorWindow, data:Object)
	{
		this.sID = data.sID;
		this.item = App.data.storage[sID];
		this.window = window;
		
		bg = new Sprite();
		var background:Bitmap = Window.backing(220, 250, 10, "itemBacking");
		bg.addChild(background);
		addChild(bg);
		
		bg.addChild(preloader);
		//preloader.scaleX = preloader.scaleY = 0.8;
		preloader.x = 110;
		preloader.y = 125;
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawBttns();
	}
	
	private var unit:Unit;
	private var decorCoords:Object;
	private function onChange(e:MouseEvent):void 
	{
		if (App.user.stock.count(sID) == 0) {
			new SimpleWindow( {
				title:item.title,
				text: Locale.__e('flash:1426239741751'),
				popup:true
			}).show();
			return;
		}
		var settings:Object = { sid:sID, fromStock:true };
		unit = Unit.add(settings);
		(unit as Decor).callback = deleteParent;
		decorCoords = { x:window.settings.parentDecor.coords.x, z:window.settings.parentDecor.coords.z };
		unit.stockAction({coords:{x:window.settings.parentDecor.coords.x, z:window.settings.parentDecor.coords.z}});
		window.close();
	}
	
	public function deleteParent():void {
		window.settings.parentDecor.removable = true;
		window.settings.parentDecor.takeable = false;
		window.settings.parentDecor.onApplyRemove();
		unit.placing(decorCoords.x, 0, decorCoords.z);
		App.map.sorted.push(unit);
		App.map.sorting();
	}
	
	private function onBuy(e:MouseEvent):void 
	{
		ShopWindow.show( { find:[sID] } );
		window.close();
	}
	
	private function onLoad(data:Bitmap):void {
		if (preloader) {
			bg.removeChild(preloader);
		}
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 180, 180);
		addChildAt(bitmap, 1);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 + 35;
		bitmap.smoothing = true;
	}
	
	private function drawTitle():void {
		var title:TextField = Window.drawText(item.title, {
			color:0x532b07,
			border:true,
			borderColor:0xfde1c9,
			fontSize:26,
			multiline:true,
			autoSize: 'center',
			textAlign:"center"
		});
		title.wordWrap = true;
		title.width = 220;
		title.x = (bg.width - title.width) / 2;
		title.y = 20;
		addChild(title);
	}
	
	private function drawBttns():void 
	{
		var count:int;
		for (var _sid:* in item.price) {
			count = item.price[_sid];
		}
		var bttnSettingsBuy:Object = {
			caption:Locale.__e("flash:1382952379751"),
			countText:	count,
			width:110,
			height:36,
			fontSize:24,
			borderColor:[0xcefc97, 0x5f9c11],
			fontColor:0xFFFFFF,
			fontBorderColor:0x4d7d0e,
			bevelColor:[0xcefc97,0x5f9c11]
		}
		bttnSettingsBuy["bgColor"] = [0xa2f545, 0x7bc21e];
		bttnSettingsBuy["borderColor"] = [0xffffff, 0xffffff];
		bttnSettingsBuy["bevelColor"] = [0xcefd93, 0x609d14];
		bttnSettingsBuy["fontColor"] = 0xffffff;
		bttnSettingsBuy["fontBorderColor"] = 0x4d8314;
		bttnSettingsBuy["greenDotes"] = false;
		
		bttnBuy = new MoneyButton(bttnSettingsBuy);
		
		addChild(bttnBuy);
		bttnBuy.x = (bg.width - bttnBuy.width) / 2;
		bttnBuy.y = bg.height + 10;
		bttnBuy.addEventListener(MouseEvent.CLICK, onBuy);
		
		var bttnSettingsChange:Object = {
			caption:Locale.__e("flash:1435302740685"),
			width:110,
			height:36,
			fontSize:26
		}
		
		bttnChange = new Button(bttnSettingsChange);
		
		addChild(bttnChange);
		bttnChange.x = (bg.width - bttnChange.width) / 2;
		bttnChange.y = bg.height + 10;
		bttnChange.addEventListener(MouseEvent.CLICK, onChange);
		
		if (App.user.stock.count(sID) > 0) {
			bttnBuy.visible = false;
			bttnChange.visible = true;
		} else {
			bttnBuy.visible = true;
			bttnChange.visible = false;
		}
		
		if (isCraft(sID)) {
			bttnChange.y = bttnBuy.y + bttnBuy.height;
			bttnChange.visible = true;
			bttnBuy.visible = true;
		}
	}
	
	private function isCraft(sid:uint):Boolean {
		var finded:Boolean = false;
			var linked:Boolean = false; var whereCraft:Array = [];
			for (var s:* in App.data.storage) {
				if (App.data.storage[s].hasOwnProperty('outs')) {
					var outs:Object = App.data.storage[s].outs;
					for (var out:* in outs) {
						if (int(out) == sid) {
							//whereCraft.push(int(s));
							finded = true;
						}
					}
				}
				
				if (/*App.data.storage[s].type == 'Tree' && */App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel.hasOwnProperty('rew')) {
					for (var craft_lvl:* in App.data.storage[s].devel.rew) {
						for (var materialID:* in App.data.storage[s].devel.rew[craft_lvl]) {
							if (int(materialID) == int(sid)) {
								//whereCraft.push(int(s));
								finded = true;
							}
						}
					}
				}
				
				if (App.data.storage[s].hasOwnProperty('devel') && App.data.storage[s].devel.hasOwnProperty('craft')/*App.data.storage[s].hasOwnProperty('crafting')*/) {
					var crafting:Array = [];
					for (var craft_lvl2:* in App.data.storage[s].devel.craft) {
						crafting = crafting.concat(App.data.storage[s].devel.craft[craft_lvl2]);
					}
					for each(var cft:* in crafting) {
						if (App.data.crafting.hasOwnProperty(cft) && App.data.crafting[cft].out == int(sid)) {
							//whereCraft.push(int(s));
							finded = true;
						} else if (App.data.crafting.hasOwnProperty(cft) && App.data.storage[App.data.crafting[cft].out].hasOwnProperty('bonus'))
						{
							var obj:Object = App.data.storage[App.data.crafting[cft].out].bonus;
							for (var item:* in obj)
							{
								if (item == sid)
								{
									//whereCraft.push(int(s));
									finded = true;
								}
							}
						}
					}
				}
			}
			
			return finded;
	}
	
	public function dispose():void {
		bttnChange.removeEventListener(MouseEvent.CLICK, onChange);
		bttnBuy.removeEventListener(MouseEvent.CLICK, onBuy);
	}
}