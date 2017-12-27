package wins.elements 
{
	import buttons.MenuButton;
	import flash.events.MouseEvent;
	import wins.actions.BanksWindow;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class BankMenu extends Sprite
	{
		public static var COINS:int = 1;
		public static var REALS:int = 0;
		public static var SETS:int = 2;
		
		public var menuBttns:Array = [];
		public var subBttns:Array = [];
		public var window:*;
		
		public static var _currBtn:int = 0;
		
		public var menuSettings:Object = {
				1: {type:'Coins', order:1,	title:App.data.storage[Stock.COINS].title },
				2: {type:'Reals', order:2,	title:App.data.storage[Stock.FANT].title }
			};
			
		public var arrSquence:Array = [2, 1];
			
		public function BankMenu(window:*)
		{
			this.window = window;
			//drawSubmenuBg();
			
			for (var i:int = 0; i < arrSquence.length; i++ ) {
				for (var item:* in menuSettings) {
					if (item == arrSquence[i]) {
						var settings:Object = menuSettings[item];
							settings['type'] = settings.type;
							settings['onMouseDown'] = onMenuBttnSelect;
							settings['fontSize'] = 24;
							
							settings['widthPlus'] = 60;
							settings['width'] = 140;
							
							switch(settings.type) {
								case BanksWindow.REALS:
									settings["bgColor"] = [0xfdb29f, 0xed7483];
									settings["bevelColor"] = [0xfeb19f, 0xe87383];
									settings["fontBorderColor"] = 0x993a40;
									settings["fontCountColor"] = 0xFFFFFF;
									settings["fontCountBorder"] = 0x354321;
									settings["fontBorderSize"] = 3;
									settings['active'] = {
										bgColor:				[0xc4606c, 0xd29484],//[0x47750b,0x74bc17],
										bevelColor:				[0xe87383, 0xfeb19f],//[0x335309,0x7ecb19],	
										fontBorderColor:		0x993a40				//Цвет обводки шрифта
									}
								break;
								case BanksWindow.COINS:
									settings["bgColor"] = [0xf5d057, 0xeeb331];
									settings["bevelColor"] = [0xfff17f, 0xbf7e1a];
									settings["fontBorderColor"] = 0x3f4a6f;
									settings["fontBorderColor"] = 0x814f31;
									settings['active'] = {
										bgColor:				[0xab7a0b,0xeeb432],
										bevelColor:				[0x6f4d02,0xf1c35e],	
										fontBorderColor:		0x6d3f23				//Цвет обводки шрифта		
									}
								break;
								case BanksWindow.SETS:
									settings["bgColor"] = [0x82c9f7, 0x5cabdd];
									settings["bevelColor"] = [0xc2e2f4, 0x3384b2];
									settings["fontBorderColor"] = 0x3f4a6f;
									settings["fontBorderColor"] = 0x426da1;
									settings['active'] = {
										bgColor:				[0x105f91,0x5cabdd],
										bevelColor:				[0x0c4b73,0x61addc],	
										fontBorderColor:		0x346297				//Цвет обводки шрифта		
									}
								break;
							}
							
							
						menuBttns.push(new MenuButton(settings));
					}
				}
			}
			//menuBttns.sortOn('order');
			
			menuBttns[_currBtn].selected = true;
			
			var bttnsContainer:Sprite = new Sprite();
			var bttnOffset:int = 30;
			var offset:int = 0;
			
			// Если есть какие-то дополнительные кнопки акций или т.п.
			if (window is BanksWindow && window.clickCont) {
				bttnOffset = 15;
				offset = 20;
			}
			
			for (i = 0; i < menuBttns.length; i++)
			{
				menuBttns[i].x = offset;
				offset += menuBttns[i].settings.width + bttnOffset;
				bttnsContainer.addChild(menuBttns[i]);
			}
			
			bttnsContainer.x = 0;// ( submenuBg.width - bttnsContainer.width ) / 2;
			addChild(bttnsContainer);
			
			this.x = 184;//(window.settings.width - submenuBg.width) / 2;
			this.y = 0;
		}
		
		public function onMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:MenuButton in menuBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			
			_currBtn = menuBttns.indexOf(e.currentTarget);
			
			window.setContentSection([e.currentTarget.type]);
		}		
		
	}
}

import buttons.MenuButton;
internal class SubMenuBttn extends MenuButton
{
	public function SubMenuBttn(settings:Object = null) {
		
		settings["bgColor"] = settings.bgColor || [0xcfbd8c, 0xb19d6f];	
		settings["bevelColor"] = settings.bevelColor || [0x7d6d44, 0x70603a];	
		settings["fontColor"] = settings.fontColor || 0xffffff;				
		settings["fontBorderColor"] = settings.fontBorderColor || 0x786840
		settings["shadow"] = false;
		
		settings["active"] = {
				bgColor:				[0xf7efd2,0xfffade],
				bevelColor:				[0x7f6e43,0x7f6e43],	
				fontColor:				0x705f36,	
				fontBorderColor:		0xffffff	
			}
		super(settings);
	}
}
