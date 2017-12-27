package wins 
{
	import buttons.Button;
	import core.Numbers;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;

	public class TopAwardWindow extends Window 
	{
		private var bttnTake:Button;
		public function TopAwardWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['width'] 			= 465; //465
			settings['height'] 			= 390;
			settings['title'] 			= Locale.__e('flash:1382952380235');
			settings['hasPaginator'] 	= false;
			settings['hasButtons']		= false;
			
			super(settings);			
		}
		
		private var pic:Bitmap;
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 35, "alertBacking");
			bodyContainer.addChild(background);
			
			pic = new Bitmap(Window.textures.giftWinPic);
			pic.smoothing = true;
			pic.x = (settings.width - pic.width) / 2;
			pic.y -= 250;
			bodyContainer.addChild(pic);
			
			exit.visible = false;
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
				width				: settings.width - 70,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2 + 65;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			
			headerContainer.addChild(titleLabel);
		}
		
		
		override public function drawBody():void {
			bttnTake = new Button( {
				fontSize:	32,
				width:		186,
				height:		50,
				caption:	Locale.__e('flash:1404394519330')
			});
			bttnTake.x = (settings.width - bttnTake.width) / 2;
			bttnTake.y = settings.height - bttnTake.height - 10;
			bodyContainer.addChild(bttnTake);
			bttnTake.addEventListener(MouseEvent.CLICK, onTake);
			
			var desc:TextField = drawText(Locale.__e('flash:1447774242199', String(settings.place)), {
				color:		0xffffff,
				borderColor:0x522a11,
				fontSize:	28,
				autoSize:	'center',
				textAlign:	'center',
				multiline:	true
			});
			desc.wordWrap = true;
			desc.width = 300;
			desc.x = (settings.width - desc.width) / 2;
			desc.y = 80;
			bodyContainer.addChild(desc);
			
			var Xs:int = 110;
			var Ys:int = 170;
			var indent:int = 20;
			var sprite:Sprite = new Sprite();
			bodyContainer.addChild(sprite);
			
			var count:int;
			var i:int;
			var j:int;
			var cnt:int;
			var prize:PrizeItem;
			var treasureName:String;
			var treasure:Object;
			var countPrizes:int;
			var lBonus:String;
			var lTreasure:Object;
			var lTry:Object;
			var lCount:Object;
			var s:*;
			
			if (settings.hasOwnProperty('sid')) {
				desc.text = Locale.__e('flash:1453736302012');
				var bonus:PrizeItem = new PrizeItem(int(settings.sid), this);
				bonus.x = 168;
				bonus.y = Ys;
				bodyContainer.addChild(bonus);
			}else if (settings.hasOwnProperty('lbonus')) {
				desc.text = Locale.__e('flash:1414160740806');
				var league:int = 1;
				for (var l:* in App.data.top[settings.topID].league.lfrom) {
					if (App.data.top[settings.topID].league.lfrom[l] < App.user.level && App.data.top[settings.topID].league.lto[l] > App.user.level) {
						league = l;
						break;
					}
				}
				treasureName = App.data.top[settings.topID].league.lbonus[league].t;
				treasure = App.data.treasures[treasureName][treasureName].item;
				var tryL:Object = App.data.treasures[treasureName][treasureName]['try'];
				var countL:Object = App.data.treasures[treasureName][treasureName].count;
				countPrizes = Numbers.countProps(treasure);
				switch (countPrizes) {
					case 1:
						Xs = 168;
						break;
					case 3:
						Xs = 58;
						indent = 10;
						break;
				}
				for (var sL:* in treasure) {
					if (['Golden', 'Walkgolden'].indexOf(App.data.storage[treasure[sL]].type) == -1) {
							if (int(treasure[sL]) != Stock.FANT)
								continue;
						}
					var prizeL:PrizeItem = new PrizeItem(int(treasure[sL]), this, {count:countL[sL] * tryL[sL]});
					prizeL.x = Xs;
					prizeL.y = Ys;
					bodyContainer.addChild(prizeL);
					
					Xs += prizeL.background.width + indent;
				}
			}else if (App.data.top[settings.topID].hasOwnProperty('tbonus')) { 
				count = Numbers.countProps(App.data.top[settings.topID].tbonus.t);
				for (i = 0; i < count; i++) {
					if (settings.place >= App.data.top[settings.topID].tbonus.s[i] && settings.place <= App.data.top[settings.topID].tbonus.e[i]) {
						treasureName = App.data.top[settings.topID].tbonus.t[i];
						treasure = App.data.treasures[treasureName][treasureName].item;
						countPrizes = Numbers.countProps(treasure);
						
						if (App.data.top[settings.topID].hasOwnProperty('lbonus') && App.user.top.hasOwnProperty(settings.topID)) {
							cnt = Numbers.countProps(App.data.top[settings.topID].lbonus.t);
							for (j = 0; j < cnt; j++) {
								if (App.user.top[settings.topID].count >= App.data.top[settings.topID].lbonus.s[j] && App.user.top[settings.topID].count <= App.data.top[settings.topID].lbonus.e[j]) {
									lBonus = App.data.top[settings.topID].lbonus.t[j];
									lTreasure = App.data.treasures[lBonus][lBonus].item;
									lTry = App.data.treasures[lBonus][lBonus]['try'];
									lCount = App.data.treasures[lBonus][lBonus].count;
									
									countPrizes +=  Numbers.countProps(lTreasure);
								}
							}
						}
						switch (countPrizes) {
							case 1:
								Xs = 168;
								break;
							case 3:
								Xs = 58;
								indent = 10;
								break;
							case 4:
								Xs = 58;
								indent = 6;
								
								if (background)
									bodyContainer.removeChild(background);
								background = backing(575, settings.height, 35, settings.background);
								background.x -= 55;
								bodyContainer.addChildAt(background, 0);
								
								sprite.x = -55;
								break;
						}
						for each (s in treasure) {
							if (['Golden', 'Walkgolden'].indexOf(App.data.storage[s].type) == -1) {
								if (int(s) != Stock.FANT)
									continue;
							}
							prize = new PrizeItem(int(s), this);
							prize.x = Xs;
							prize.y = Ys;
							sprite.addChild(prize);
							
							Xs += prize.background.width + indent;
						}
						if (Numbers.countProps(lTreasure) > 0) {
							for (s in lTreasure) {
								if (['Golden', 'Walkgolden'].indexOf(App.data.storage[lTreasure[s]].type) == -1) {
									if (int(s) != Stock.FANT)
										continue;
								}
								prize = new PrizeItem(int(lTreasure[s]), this, {count:lCount[s] * lTry[s]});
								prize.x = Xs;
								prize.y = Ys;
								sprite.addChild(prize);
								
								Xs += prize.background.width + indent;
							}
						}
					}
				}
			}else if (App.data.top[settings.topID].league.hasOwnProperty('tbonus')) {
				var _league:int = 1;
				for (var lid:* in App.data.top[settings.topID].league.lfrom) {
					if (App.data.top[settings.topID].league.lfrom[lid] < App.user.level && App.data.top[settings.topID].league.lto[lid] > App.user.level) {
						_league = lid;
						break;
					}
				}
				
				count = Numbers.countProps(App.data.top[settings.topID].league.tbonus[_league].t);
				for (i = 0; i < count; i++) {
					if (settings.place >= App.data.top[settings.topID].league.tbonus[_league].s[i] && settings.place <= App.data.top[settings.topID].league.tbonus[_league].e[i]) {
						treasureName = App.data.top[settings.topID].league.tbonus[_league].t[i];
						treasure = App.data.treasures[treasureName][treasureName].item;
						countPrizes = Numbers.countProps(treasure);
						
						if (App.data.top[settings.topID].league.hasOwnProperty('lbonus') && App.user.top.hasOwnProperty(settings.topID)) {
							cnt = Numbers.countProps(App.data.top[settings.topID].league.lbonus[_league].t);
							for (j = 0; j < cnt; j++) {
								if (App.user.top[settings.topID].count >= App.data.top[settings.topID].league.lbonus[_league].d[j] && App.user.top[settings.topID].count <= App.data.top[settings.topID].league.lbonus[_league].p[j]) {
									lBonus = App.data.top[settings.topID].league.lbonus[_league].t[j];
									lTreasure = App.data.treasures[lBonus][lBonus].item;
									lTry = App.data.treasures[lBonus][lBonus]['try'];
									lCount = App.data.treasures[lBonus][lBonus].count;
									
									countPrizes +=  Numbers.countProps(lTreasure);
								}
							}
						}
						switch (countPrizes) {
							case 1:
								Xs = 168;
								break;
							case 3:
								Xs = 58;
								indent = 10;
								break;
							case 4:
								Xs = 58;
								indent = 6;
								
								if (background)
									bodyContainer.removeChild(background);
								background = backing(575, settings.height, 35, settings.background);
								background.x -= 55;
								bodyContainer.addChildAt(background, 0);
								
								sprite.x = -55;
								break;
						}
						for each (s in treasure) {
							if (['Golden', 'Walkgolden'].indexOf(App.data.storage[s].type) == -1) {
								if (int(s) != Stock.FANT)
									continue;
							}
							prize = new PrizeItem(int(s), this);
							prize.x = Xs;
							prize.y = Ys;
							sprite.addChild(prize);
							
							Xs += prize.background.width + indent;
						}
						if (Numbers.countProps(lTreasure) > 0) {
							for (s in lTreasure) {
								if (['Golden', 'Walkgolden'].indexOf(App.data.storage[lTreasure[s]].type) == -1) {
									if (int(s) != Stock.FANT)
										continue;
								}
								prize = new PrizeItem(int(lTreasure[s]), this, {count:lCount[s] * lTry[s]});
								prize.x = Xs;
								prize.y = Ys;
								sprite.addChild(prize);
								
								Xs += prize.background.width + indent;
							}
						}
					}
				}
			}
		}
		
		private function onTake(e:MouseEvent = null):void {
			if (settings.hasOwnProperty('sid')) {
				Post.send( {
					ctr:		'quest',
					act:		'bonus',
					uID:		App.user.id,
					wID:		App.user.worldID,
					qID:		settings.qID,
					mID:		settings.mID
				}, function(error:int, data:Object, params:Object):void {
					if (error) return;
					
					if (data.hasOwnProperty('bonus')) {
						flyMaterial(int(data.bonus), 1);
					}
						
					App.user.quests.data[settings.qID]['bonus'] = 1;
					close();
				});
			}else {
				Post.send( {
					ctr:		'top',
					act:		'tbonus',
					uID:		App.user.id,
					tID:		settings.topID
				}, function(error:int, data:Object, params:Object):void {
					if (error) return;
					
					if (data.hasOwnProperty('bonus')) {					
						for (var s:* in data.bonus) {
							var cnt:int = 0;
							for (var bs:* in data.bonus[s]) {
								cnt = data.bonus[s][bs] * bs;
							}
							
							flyMaterial(int(s), cnt);
						}
					}
						
					App.user.top[settings.topID]['tbonus'] = 1;
					close();
				});
			}
		}
		
		public function flyMaterial(sID:int, count:int):void
		{
			var item:BonusItem = new BonusItem(uint(sID), 0);
			
			var point:Point = Window.localToGlobal(bttnTake);
			point.y += bttnTake.height / 2;
			
			item.cashMove(point, App.self.windowContainer);
			
			App.user.stock.add(int(sID), count);
		}
		
		override public function dispose():void {
			if (bttnTake) bttnTake.removeEventListener(MouseEvent.CLICK, onTake);
			super.dispose();
		}
		
	}

}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.text.TextField;
import wins.Window;
internal class PrizeItem extends LayerX {
	public var background:Bitmap = new Bitmap();
	private var window:*;
	public function PrizeItem(sID:int, window:*, settings:Object = null) {
		this.window = window;	
		
		background = new Bitmap(new BitmapData(110, 110, true, 0xffffff));
		addChild(background);
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xc6c7b9, 1);
		shape.graphics.drawCircle(55, 55, 55);
		shape.graphics.endFill();
		background.bitmapData.draw(shape);
		
		var prizeIcon:Bitmap = new Bitmap();
		addChild(prizeIcon);
		
		if (settings && settings.hasOwnProperty('count')) {
			drawCount(settings.count);
		}
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:*):void {
			prizeIcon.bitmapData = data.bitmapData;
			Size.size(prizeIcon, 100, 100);
			prizeIcon.x = (background.width - prizeIcon.width) / 2;
			prizeIcon.y = 10;
			prizeIcon.smoothing = true;			
		});
	}
	
	private function drawCount(count:int):void {
		var textCount:TextField = Window.drawText('x' + String(count) , {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = background.x + background.width - textCount.width;
		textCount.y = background.y + background.height - 10;
		addChild(textCount);
	}
}