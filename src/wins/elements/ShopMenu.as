package wins.elements 
{
	import buttons.MenuButton;
	import core.Numbers;
	import flash.events.MouseEvent;
	import wins.ShopWindow;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author 
	 */
	public class ShopMenu extends Sprite
	{
		
		public var menuBttns:Array = [];
		public var subBttns:Array = [];
		public var window:ShopWindow;
		
		public static var _currBtn:int = 0;
		
		public var menuSettings:Object = {
			100:	{ order:0, 	title:Locale.__e("flash:1382952379743") }, // новое
			2:		{ order:1,	title:Locale.__e("flash:1410167506188") },//Растения
			4:		{ order:2,	title:Locale.__e("flash:1382952380292") },//Производство
			3:		{ order:3,	title:Locale.__e("flash:1382952380294") },// decor
			7:		{ order:4,	title:Locale.__e("flash:1382952380295") },//Важное
			13:		{ order:5,	title:Locale.__e("flash:1396612503921") },//Ресурсы
			14: 	{ order:6,	title:Locale.__e("flash:1402910864995") }//Животные
		};
		
		private var __arrSquence:Array;
		public function get arrSquence():Array {
			if (__arrSquence)
				return __arrSquence;
			
			if (App.self.flashVars.debug == 1) {
				__arrSquence = [100, 2, 4, 3, 7, 14, 13];
			}else {
				__arrSquence = [100, 2, 4, 3, 7, 14];
			}
			
			for (var i:int = 0; i < __arrSquence.length; i++ ) {
				if (Numbers.countProps(ShopWindow.shop[__arrSquence[i]]) == 0) {
					__arrSquence.splice(i, 1);
					i--;
				}
			}
			
			/*var worldInfo:Object = App.data.storage[App.user.worldID];
			if (worldInfo.lshop == 1 ) {
				__arrSquence.shift();
			}*/
			
			return __arrSquence;
		}
		
		public function ShopMenu(window:ShopWindow)
		{
			this.window = window;
			drawSubmenuBg();
			
			for (var i:int = 0; i < arrSquence.length; i++ ) {
				if (!menuSettings.hasOwnProperty(arrSquence[i])) continue;
				
				for (var item:* in menuSettings) {
					
					if (item == arrSquence[i]) {
						var settings:Object = menuSettings[item];
						settings['type'] = item;
						settings['fontSize'] = App.lang == 'jp' ? 18 : 23;
						settings['widthPlus'] = 35;
						
						if (item == 3 && App.user.worldID == 555) settings.title = Locale.__e('flash:1435054686292');
						
						// Для раздела новое
						if (settings.order == 0) {
							settings["bgColor"] = [0xf3d155, 0xeeb42f];
							settings["bevelColor"] = [0xfef181, 0xbe7d19];
							settings['fontColor'] = 0xfbfffe;
							settings["fontBorderColor"] = 0x7d4f2d;
							settings['active'] = {
								bgColor:				[0xeeb42f, 0xf3d155],
								bevelColor:				[0xbe7d19, 0xfef181],
								fontColor:				0xfbfffe,
								fontBorderColor:		0x7d4f2d				//Цвет обводки шрифта		
							}
						}
						
						var bttn:MenuButton = new MenuButton(settings);
						menuBttns.push(bttn);
						bttn.addEventListener(MouseEvent.CLICK, onMenuBttnSelect);
						
						if (window.settings.section == item) {
							_currBtn = i;
							bttn.selected = true;
						}
					}
				}
			}
			
			if (menuBttns.length <= _currBtn) _currBtn = 0;
			if (menuBttns.length == 0) return;
			//menuBttns[_currBtn].selected = true;
			
			var bttnsContainer:Sprite = new Sprite();
			
			var offset:int = 0;
			for (i = 0; i < menuBttns.length; i++)
			{
				menuBttns[i].x = offset;
				offset += menuBttns[i].settings.width + 4;
				bttnsContainer.addChild(menuBttns[i]);
			}
			
			bttnsContainer.x = ( submenuBg.width - bttnsContainer.width ) / 2;
			addChild(bttnsContainer);
			
			this.x = (window.settings.width - submenuBg.width) / 2;
			this.y = 5;
		}
		
		public function setMarket(market:int):void {
			for (var i:int = 0; i < arrSquence.length; i ++ ) {
				if (arrSquence[i] == market) {
					ShopMenu._currBtn = i;
					menuBttns[i].selected = true;
				}else {
					menuBttns[i].selected = false;
				}
			}
		}
		
		private function clearSubmenu():void {
			
			for each(var bttn:SubMenuBttn in subBttns) 
			{
				submenuContainer.removeChild(bttn);
			}
			if(submenuContainer) removeChild(submenuContainer);
			submenuContainer = null
			subBttns = [];
		}
		
		private var submenuContainer:Sprite
		private function drawSubmenu(section:int):void {
			
			var childs:Object = menuSettings[section]['childs'];
			childs['all'] = { order:0,	title:Locale.__e("flash:1382952380301"), childs:[]};
			
			for (var item:* in childs) {
				var settings:Object = childs[item];
					settings['type'] = item;
					settings['onMouseDown'] = onSubMenuBttnSelect;
					settings['height'] = 36;
					settings['parentSection'] = section;
					
					if (item != 'all')
						childs['all'].childs.push(item);
					
				subBttns.push(new SubMenuBttn(settings));
			}
			subBttns.sortOn('order');
			submenuContainer = new Sprite();
			
			var offset:int = 0;
			for (var i:int = 0; i < subBttns.length; i++)
			{
				subBttns[i].x = offset;
				offset += subBttns[i].settings.width + 4;
				submenuContainer.addChild(subBttns[i]);
			}
			
			submenuContainer.x = 10;// (submenuBg.width - submenuContainer.width ) / 2;
			submenuContainer.y = submenuBg.y + 2;
			addChild(submenuContainer);
			
			//subBttns[0].selected = true;
			subBttns[0].dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
		}
		
		private var submenuBg:Sprite;
		private function drawSubmenuBg():void 
		{
			submenuBg = new Sprite();
			submenuBg.graphics.lineStyle(0x000000, 0, 0, true);	
			submenuBg.graphics.beginFill(0xb8a574);
			submenuBg.graphics.drawRoundRect(0, 0, window.settings.width - 120, 40, 25, 25);
			submenuBg.graphics.endFill();
			//this.addChild(submenuBg);
			submenuBg.y = 45;
		}
		
		public function onMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:MenuButton in menuBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			
			ShopWindow.history.section = arrSquence[menuBttns.indexOf(e.currentTarget)];
			
			_currBtn = menuBttns.indexOf(e.currentTarget);
			
			clearSubmenu();
			
			if (menuSettings[e.currentTarget.type].hasOwnProperty('childs'))
				drawSubmenu(e.currentTarget.type);
			else	
				window.setContentSection(e.currentTarget.type);
		}		
		
		public function onSubMenuBttnSelect(e:MouseEvent):void
		{
			for each(var bttn:SubMenuBttn in subBttns) {
				bttn.selected = false;
			}
			e.currentTarget.selected = true;
			
			if (e.currentTarget.type == 'all')
				window.setContentSection(e.currentTarget.settings.childs);	
			else
				window.setContentSection([e.currentTarget.type]);	
			
		}	
	}
}

import buttons.MenuButton;
internal class SubMenuBttn extends MenuButton
{
	public function SubMenuBttn(settings:Object = null) {
		
		settings["bgColor"] = settings.bgColor || [0xa0c8e1, 0x73a1b1];
		settings["bevelColor"] = settings.bevelColor || [0xb9e0f1, 0x528296];
		settings["fontBorderColor"] = settings.fontBorderColor || 0x4b818d;
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
