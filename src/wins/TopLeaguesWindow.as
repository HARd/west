package wins
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Exchange;
	import wins.elements.TopItem;
	
	public class TopLeaguesWindow extends TopWindow
	{
		private var descLabel:TextField;
		private var back:Bitmap;
		private var container:Sprite;
		private var infBttn:Button;
		private var league1Bttn:ImageButton;
		private var league2Bttn:ImageButton;
		private var league3Bttn:ImageButton;
		private var takeRewardBttn:Button;
		private var timerLabel:TextField;
		private var league:int = 1;
		
		public function TopLeaguesWindow(settings:Object = null)
		{
			if (!settings)
				settings = {};
			
			settings['width'] = settings['width'] || 790;
			settings['height'] = settings['height'] || 670;
			settings['title'] = settings['title'] || '';
			settings['true'] = false;
			settings['description'] = App.data.top[settings.target.topID].description;
			settings['spliceOver'] = settings['spliceOver'] || 0; // Обрезать все что меньше
			settings['points'] = settings['points'] || 0;
			settings['material'] = settings['material'] || 0;
			settings['background'] = 'alertBacking';
			
			max = settings['max'] || 100;
			
			if (App.data.storage[settings.material])
				material = App.data.storage[settings.material];
			
			var ownerHere:Boolean = false;
			var list:Array = [];
			for each (var object:Object in settings.content) {
				list.push(object);
			}
			settings.content = list;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				if (settings.content[i].uID == App.user.id)
				{
					ownerHere = true;
					settings.content[i].points = settings.points;
				}
				if (settings.content[i].points < settings.spliceOver)
				{
					settings.content.splice(i, 1);
					i--;
				}
			}
			settings.content.sortOn('points', Array.NUMERIC | Array.DESCENDING);
			
			if (settings.content.length > max)
				settings.content.splice(max, settings.content.length - max);
			
			for (i = 0; i < settings.content.length; i++) {
				settings.content[i]['num'] = String(i + 1);
			}
			
			super(settings);
			
			sections = 4;
		}
		
		override public function drawBody():void {
			titleLabel.y += 10;
			
			for (var l:* in App.data.top[settings.topID].league.lfrom) {
				if (App.data.top[settings.topID].league.lfrom[l] < App.user.level && App.data.top[settings.topID].league.lto[l] > App.user.level) {
					league = l;
					break;
				}
			}
			
			back = new Bitmap(new BitmapData(settings.width - 106, 450, true, 0xffff00));
			back.x = settings.width / 2 - back.width / 2;
			back.y = 180;
			bodyContainer.addChild(back);
			
			descLabel = drawText(settings.description, {textAlign: 'center', fontSize: App.isSocial('YB','MX','AI','GN') ? 17 : 21, color: 0xe8e8e6, borderColor: 0x542f14, multiline: true, wrap: true, width: 430});
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 25;
			bodyContainer.addChild(descLabel);
			
			var separator:Bitmap = Window.backingShort(back.width - 10, 'dividerLine', false);
			separator.x = back.x + 10;
			separator.y = back.y;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(back.width - 10, 'dividerLine', false);
			separator2.x = back.x + 10;
			separator2.y = back.y + back.height;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			drawButtons();
			
			var skip:Boolean = true;
			var posY:int = 0;
			for (var i:int = 0; i < sections; i++) {
				var height:int = Math.floor((back.height - MARGIN * 2) / 5);
				if (i == 0 || i == sections - 1)
					height += MARGIN;
				var bmd:BitmapData = new BitmapData(back.width, height, true, 0x66FFFFFF);
				
				if (!skip) {
					back.bitmapData.draw(bmd, new Matrix(1, 0, 0, 1, 0, posY));
					skip = true;
				}
				else {
					skip = false;
				}
				posY += bmd.height;
			}
			
			container = new Sprite();
			container.x = back.x;
			container.y = back.y;
			bodyContainer.addChild(container);
			
			infBttn = new Button({width: 130, height: 45, fontSize: 20, caption: Locale.__e('flash:1440499603885')});
			infBttn.x = descLabel.x + descLabel.width;
			infBttn.y = descLabel.y + descLabel.height * 0.5 - infBttn.height * 0.5;
			bodyContainer.addChild(infBttn);
			infBttn.addEventListener(MouseEvent.CLICK, onInfoWindow);
			
			var cont:Sprite = new Sprite();
			bodyContainer.addChild(cont);
			
			var rateDescLabel:TextField = drawText(Locale.__e('flash:1440494930989') + ':', {autoSize: 'center', textAlign: 'center', color: 0xf0feff, borderColor: 0x562d19, fontSize: 21});
			rateDescLabel.x = 0;
			rateDescLabel.y = 4;
			cont.addChild(rateDescLabel);
			
			var rateIcon:Bitmap;
			if (material) {
				rateIcon = new Bitmap();
				cont.addChild(rateIcon);
				Load.loading(Config.getIcon(material.type, material.preview), function(data:Bitmap):void
					{
						rateIcon.bitmapData = data.bitmapData;
						rateIcon.smoothing = true;
						Size.size(rateIcon, 30, 30);
						rateIcon.x = rateDescLabel.x + rateDescLabel.width + 6;
						rateIcon.y = rateDescLabel.y + rateDescLabel.height * 0.5 - rateIcon.height * 0.5;
					});
			}
			
			var rateLabel:TextField = drawText(String(settings.points), {width: 200, textAlign: 'left', color: 0x77feff, borderColor: 0x043b74, fontSize: 28});
			rateLabel.x = (rateIcon) ? rateDescLabel.x + rateDescLabel.width + 40 : rateDescLabel.x + rateDescLabel.width + 10;
			cont.addChild(rateLabel);
			cont.x = 90;
			cont.y = settings.height - cont.height - 80;
			
			var placeDescLabel:TextField = drawText(Locale.__e('flash:1475491161567'), {autoSize: 'center', textAlign: 'center', color: 0xf0feff, borderColor: 0x562d19, fontSize: 21});
			placeDescLabel.x = 500;
			placeDescLabel.y = 4;
			cont.addChild(placeDescLabel);
			
			var placeLabel:TextField = drawText(calcPlace(), {width: 200, textAlign: 'left', color: 0x77feff, borderColor: 0x043b74, fontSize: 28});
			placeLabel.x = placeDescLabel.x + placeDescLabel.width + 10;
			cont.addChild(placeLabel);
			
			paginator.onPageCount = sections;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			paginator.x -= 40;
			paginator.y += 12;
			
			drawTimer();
			
			contentChange();
			
			if (ExchangeWindow.depthShow > 0 || HappyWindow.depthShow > 0) {
				ExchangeWindow.depthShow = 0;
				HappyWindow.depthShow = 0;
				onInfoWindow();
			}
		}
		
		public function calcPlace():String {
			for (var i:int = 0; i < sections; i++) {
				if (paginator.page * sections + i >= settings.content.length)
					continue;
				var params:Object = settings.content[paginator.page * sections + i];
				if (params['uID'] == App.user.id) {
					return String(params['num']);
				}
			}
			return '-';
		}
		
		public function drawButtons():void {
			league1Bttn = new ImageButton(Window.texture('interHomeBttnBronze'));
			league1Bttn.x = 80;
			league1Bttn.y = 105;
			bodyContainer.addChild(league1Bttn);
			
			var topBttnText1:TextField = Window.drawText(Locale.__e('flash:1457968002169'), {
				textAlign:		'center',
				fontSize:		30,
				color:			0xFFFFFF,
				borderColor:	0x8b4023,
				shadowSize:		1,
				multiline:		true,
				width:			league1Bttn.width - 20
			});
			topBttnText1.x = 10;
			topBttnText1.y = (league1Bttn.height - topBttnText1.height) / 2;
			league1Bttn.addChild(topBttnText1);
			league1Bttn.name = 'league1';
			league1Bttn.addEventListener(MouseEvent.CLICK, onOpenLeague);
			
			league2Bttn = new ImageButton(Window.texture('interHomeBttnGray'));
			league2Bttn.x = league1Bttn.x + league1Bttn.width + 15;
			league2Bttn.y = 105;
			bodyContainer.addChild(league2Bttn);
			
			var topBttnText2:TextField = Window.drawText(Locale.__e('flash:1457968020193'), {
				textAlign:		'center',
				fontSize:		30,
				color:			0xFFFFFF,
				borderColor:	0x5d4843,
				shadowSize:		1,
				multiline:		true,
				width:			league2Bttn.width - 20
			});
			topBttnText2.x = 10;
			topBttnText2.y = (league2Bttn.height - topBttnText2.height) / 2;
			league2Bttn.addChild(topBttnText2);
			league2Bttn.name = 'league2';
			league2Bttn.addEventListener(MouseEvent.CLICK, onOpenLeague);
			
			league3Bttn = new ImageButton(Window.texture('homeBttn'));
			league3Bttn.x = league2Bttn.x + league2Bttn.width + 15;
			league3Bttn.y = 105;
			bodyContainer.addChild(league3Bttn);
			
			var topBttnText3:TextField = Window.drawText(Locale.__e('flash:1457968031528'), {
				textAlign:		'center',
				fontSize:		30,
				color:			0xFFFFFF,
				borderColor:	0x623e1c,
				shadowSize:		1,
				multiline:		true,
				width:			league3Bttn.width - 20
			});
			topBttnText3.x = 10;
			topBttnText3.y = (league3Bttn.height - topBttnText3.height) / 2;
			league3Bttn.addChild(topBttnText3);
			league3Bttn.name = 'league3';
			league3Bttn.addEventListener(MouseEvent.CLICK, onOpenLeague);
			
			if (App.user.level <= App.data.top[settings.target.topID].league.lto[1]) {
				league1Bttn.selected = true;
				league1Bttn.startGlowing();
			}else if (App.user.level > App.data.top[settings.target.topID].league.lfrom[2] && App.user.level <= App.data.top[settings.target.topID].league.lto[2]) {
				league2Bttn.selected = true;
				league2Bttn.startGlowing();
			}else if (App.user.level > App.data.top[settings.target.topID].league.lfrom[3]) {
				league3Bttn.selected = true;
				league3Bttn.startGlowing();
			}
			
			takeRewardBttn = new Button( {
				caption:Locale.__e('flash:1393579618588'),
				height:league1Bttn.height - 15,
				width:175
			});
			takeRewardBttn.x = league3Bttn.x + league3Bttn.width + 20;
			takeRewardBttn.y = league1Bttn.y + 7;
			bodyContainer.addChild(takeRewardBttn);
			takeRewardBttn.addEventListener(MouseEvent.CLICK, onTake);
			
			if (App.user.top.hasOwnProperty(settings.target.topID) && App.user.top[settings.target.topID].hasOwnProperty('tbonus') &&  App.user.top[settings.target.topID]['tbonus'] > 0) {
				takeRewardBttn.state = Button.DISABLED;
				if (App.data.top[settings.target.topID].league.hasOwnProperty('lbonus')) {
					var count:int = Numbers.countProps(App.data.top[settings.target.topID].league.lbonus[league].t);
					for (var i:int = 0; i < count; i++) {
						if (App.user.top[settings.target.topID].count >= App.data.top[settings.target.topID].league.lbonus[league].d[i] && App.user.top[settings.target.topID].count <= App.data.top[settings.target.topID].league.lbonus[league].p[i]) {
							takeRewardBttn.state = Button.ACTIVE;
						}
					}
				}
			} else if (!App.user.top.hasOwnProperty(settings.target.topID) || settings.target.expire - App.time > 0) {
				takeRewardBttn.state = Button.DISABLED;
			}
		}
		
		private function onOpenLeague(e:MouseEvent):void {
			buttonsSelected(false);
			e.currentTarget.selected = true;
			e.currentTarget.startGlowing();
			
			var leagueNum:int = 1;
			switch (e.currentTarget.name) {
				case 'league1':
					leagueNum = 1;break;
				case 'league2':
					leagueNum = 2;break;
				case 'league3':
					leagueNum = 3;break;
			}
			getRate(App.data.top[settings.target.topID].league.lfrom[leagueNum] + 1);
		}
		
		private function buttonsSelected(selected:Boolean = true):void {
			league1Bttn.selected = selected;
			league1Bttn.hideGlowing();
			league2Bttn.selected = selected;
			league2Bttn.hideGlowing();
			league3Bttn.selected = selected;
			league3Bttn.hideGlowing();
		}
		
		public function onTake(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			Post.send( {
				ctr:		'top',
				act:		'tbonus',
				uID:		App.user.id,
				tID:		settings.target.topID
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('bonus')) {
					var bonus:Object = data.bonus;
					if (Numbers.countProps(bonus) > 0 && typeof(bonus[Numbers.firstProp(bonus).val]) == 'number')
						bonus = Treasures.treasureToObject(data.bonus);
					
					for (var s:* in bonus) {
						flyMaterial(int(s), 1);
					}
				}
				
				if (data.take && App.user.top.hasOwnProperty(settings.target.topID))
					App.user.top[settings.target.topID]['tbonus'] = App.user.level;
				
				if (takeRewardBttn)
					takeRewardBttn.state = Button.DISABLED;
			});
		}
		
		public function flyMaterial(sID:int, count:int):void
		{
			var item:BonusItem = new BonusItem(uint(sID), 0);
			
			var point:Point = Window.localToGlobal(takeRewardBttn);
			point.y += takeRewardBttn.height / 2;
			
			item.cashMove(point, App.self.windowContainer);
			
			App.user.stock.add(int(sID), count);
		}
		
		public function onInfoWindow(e:MouseEvent = null):void
		{
			if (infBttn.mode == Button.DISABLED)
				return;
				
			if (App.isSocial('VK', 'DM', 'FS', 'ML', 'OK')) return;
				
			if (settings.target.topID >= 14) {
				new TopInfoWindow( {
					popup:true,
					topID:settings.target.topID
				}).show();
				//var content:Object = { };
				//var leg:int = 1;
				//if (league1Bttn.mode == Button.ACTIVE) {
					//leg = 1;
				//}else if (league2Bttn.mode == Button.ACTIVE) {
					//leg = 2;
				//}else {
					//leg = 3;
				//}
				//
				//for (var i:* in App.data.top[settings.target.topID].league.tbonus[leg].d) {
					//content[i + 1] = { };
					//content[i + 1]['text'] = App.data.top[settings.target.topID].league.tbonus[leg].d[i];
					//content[i + 1]['icon'] = App.data.top[settings.target.topID].league.tbonus[leg].i[i];	
				//}
				//new InfoWindow( { 
					//popup:true,
					//content:content
				//} ).show();
				return;
			}
				
			new InfoWindow( { 
				popup:true,
				qID:String(settings.target.topID) + '00' + getHelp()
			} ).show();
		}
		
		private function getHelp():String {
			var help:String = '3';
			
			if ([1735,1736,1712,1994,1991,1988,1753,1752,1751].indexOf(HappyWindow.find) != -1 || league1Bttn.mode == Button.ACTIVE) {
				help = '1';
			}else if ([1743,1741,1745,1993,1990,1987,1756,1755,1754].indexOf(HappyWindow.find) != -1 || league2Bttn.mode == Button.ACTIVE) {
				help = '2';
			}else if ([1744,1742,1746,1992,1989,1986,1759,1758,1757].indexOf(HappyWindow.find) != -1) {
				help = '3';
			}
			HappyWindow.find = 0;
			
			return help;
		}
		
		override public function contentChange():void
		{
			clear();
			
			for (var i:int = 0; i < sections; i++) {
				if (paginator.page * sections + i >= settings.content.length)
					continue;
				var params:Object = settings.content[paginator.page * sections + i];
				
				params['width'] = back.width;
				params['height'] = Math.floor((back.height - MARGIN * 2) / 5);
				
				var item:TopItem = new TopItem(params, this);
				item.x = 0;
				item.y = MARGIN + i * Math.floor((back.height - MARGIN * 2) / 5);
				container.addChild(item);
				items.push(item);
			}
		
		}
		
		private function clear():void
		{
			while (items.length > 0) {
				var item:TopItem = items.shift();
				item.dispose();
			}
		}
		
		private var timerBacking:Bitmap;
		private var timerDescLabel:TextField;		
		private function drawTimer():void
		{
			timerBacking = new Bitmap(Window.textures.iconGlow, 'auto', true);
			timerBacking.scaleX = 0.6;
			timerBacking.scaleY = 1;
			timerBacking.x = 80;
			timerBacking.y = -20;
			timerBacking.alpha = 0.7;
			bodyContainer.addChild(timerBacking);
			
			var text:String = Locale.__e('flash:1382952379794').replace('%s', '');
			timerDescLabel = drawText(text, {width: timerBacking.width, textAlign: 'center', fontSize: 25, color: 0xfdfde5, borderColor: 0x7c523a, shadowSize: 1});
			timerDescLabel.x = timerBacking.x + (timerBacking.width - timerDescLabel.width) / 2;
			timerDescLabel.y = timerBacking.y + 20;
			bodyContainer.addChild(timerDescLabel);
			
			timerLabel = drawText('', {width: 200, textAlign: 'center', fontSize: 38, color: 0xfde676, borderColor: 0x743e1a, shadowSize: 2});
			timerLabel.x = timerDescLabel.x + timerDescLabel.width * 0.5 - timerLabel.width * 0.5;
			timerLabel.y = timerDescLabel.y + timerDescLabel.height - 5;
			bodyContainer.addChild(timerLabel);
			
			App.self.setOnTimer(timer);
		}
		
		private function timer():void
		{
			if (timerLabel && settings.target) {
				var time:int = settings.target.expire - App.time;
				if (time < 0)
				{
					App.self.setOffTimer(timer);
					timerLabel.visible = false;
					timerBacking.visible = false;
					timerDescLabel.visible = false;
					time = 0;
					
					if (Exchange.take == 0)
						infBttn.showGlowing();
				}
				timerLabel.text = TimeConverter.timeToStr(time);
				
				if (time <= 0) {
					App.self.setOffTimer(timer);
					timerLabel.visible = false;
					timerDescLabel.visible = false;
					timerBacking.visible = false;
				}
			}
		}
		
		private function getRate(league:int = 1):void {
			Post.send( {
				ctr:		'top',
				act:		'users',
				uID:		App.user.id,
				tID:		settings.target.topID,
				league:		league
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('users')) {
					settings.content = [];
					var rates:Object = data['users'] || { };
					
					for (var id:* in rates) {
						if (App.user.id == id) {
							settings.points = rates[id]['points'];
						}
						
						rates[id]['uID'] = id;
					}
					if (App.user.top.hasOwnProperty(settings.target.topID)) {
						settings.points = (settings.points > App.user.top[settings.target.topID].count) ? settings.points : App.user.top[settings.target.topID].count;
					}
					
					var list:Array = [];
					for each (var object:Object in rates) {
						list.push(object);
					}
					settings.content = list;
					for (var i:int = 0; i < settings.content.length; i++) {
						if (settings.content[i].uID == App.user.id) {
							settings.content[i].points = settings.points;
						}
						if (settings.content[i].points < settings.spliceOver) {
							settings.content.splice(i, 1);
							i--;
						}
					}
					settings.content.sortOn('points', Array.NUMERIC | Array.DESCENDING);
					
					if (settings.content.length > max)
						settings.content.splice(max, settings.content.length - max);
					
					for (i = 0; i < settings.content.length; i++) {
						settings.content[i]['num'] = String(i + 1);
					}
					
					paginator.itemsCount = settings.content.length;
					paginator.update();
					
					contentChange();
				}				
			});
		}
		
		override public function dispose():void{
			clear();
			infBttn.removeEventListener(MouseEvent.CLICK, onInfoWindow);
			takeRewardBttn.removeEventListener(MouseEvent.CLICK, onTake);
			App.self.setOffTimer(timer);
			
			super.dispose();
		}
	
	}

}