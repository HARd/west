package wins {
	
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class InfoWindow extends Window {
		
		public static var contents:Object;
		public function InfoWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
			settings['background'] 		= settings.background || 'alertBacking';
			settings['mirrorDecor'] 	= settings.mirrorDecor || 'titleDecRose';
			settings['width'] 			= 585;
			settings['height'] 			= 485;
			settings['title'] 			= Locale.__e('flash:1382952380254');
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= false;
			settings['hasTitle'] 		= true;
			settings['faderClickable'] 	= true;
			settings['faderAlpha'] 		= 0.6;
			settings['popup'] 			= true;
			settings['caption'] 		= settings.caption || Locale.__e('flash:1382952380298');
			
			if (App.user.worldID == Travel.SAN_MANSANO) settings['background'] =  'goldBacking';
			
			if (settings.hasOwnProperty('qID')) {
				contents = info[settings.qID];
				
				if (Numbers.countProps(info[settings.qID]) == 2) {
					settings['height'] = 20 + 92 * (Numbers.countProps(info[settings.qID]) + 2);
				}else {
					settings['height'] = 50 + 92 * (Numbers.countProps(info[settings.qID]) + 2);
				}
			} if (settings.hasOwnProperty('content')) {
				contents = settings.content;
				
				if (Numbers.countProps(contents) == 2) {
					settings['height'] = 20 + 92 * (Numbers.countProps(contents) + 2);
				}else {
					settings['height'] = 50 + 92 * (Numbers.countProps(contents) + 2);
				}
			}
			
			//trace(Numbers.countProps(info[settings.qID]));
			super(settings);
		}
		
		public static var info:Object = {
			'55': {
				1: {
					text:Locale.__e('flash:1427386895585'),
					icon:'HelpPicAnimals1'
				},
				2: {
					text:Locale.__e('flash:1427387022155'),
					icon:'HelpPicAnimals2'
				},
				3: {
					text:Locale.__e('flash:1427387385242'),
					icon:'HelpPicAnimals3'
				}
			},
			'23': {
				1: {
					text:Locale.__e('flash:1427447598694'),
					icon:'HelpPicTrade1'
				},
				2: {
					text:Locale.__e('flash:1427447678573'),
					icon:'HelpPicTrade2'
				},
				3: {
					text:Locale.__e('flash:1427447715195'),
					icon:'HelpPicTrade3'
				}
			},
			'54': {
				1: {
					text:Locale.__e('flash:1427447984712'),
					icon:'HelpPicNugget1'
				},
				2: {
					text:Locale.__e('flash:1427448047520'),
					icon:'HelpPicNugget2'
				},
				3: {
					text:Locale.__e('flash:1427448085469'),
					icon:'HelpPicNugget3'
				}
			},
			'32': {
				1: {
					text:Locale.__e('flash:1427448191912'),
					icon:'HelpPicWorker1'
				},
				2: {
					text:Locale.__e('flash:1427448246270'),
					icon:'HelpPicWorker2'
				},
				3: {
					text:Locale.__e('flash:1427448281291'),
					icon:'HelpPicWorker3'
				}
			},
			'8001': {
				1: {
					text:Locale.__e('flash:1458036452667'),
					icon:1736
				},
				2: {
					text:Locale.__e('flash:1458036465873'),
					icon:1735
				},
				3: {
					text:Locale.__e('flash:1458036481209'),
					icon:1712
				}
			},
			'8002': {
				1: {
					text:Locale.__e('flash:1458036494074'),
					icon:1741
				},
				2: {
					text:Locale.__e('flash:1458036504889'),
					icon:1743
				},
				3: {
					text:Locale.__e('flash:1458036516697'),
					icon:1712
				}
			},
			'8003': {
				1: {
					text:Locale.__e('flash:1458036529250'),
					icon:1742
				},
				2: {
					text:Locale.__e('flash:1458036541145'),
					icon:1744
				},
				3: {
					text:Locale.__e('flash:1458036552041'),
					icon:1746
				}
			},
			'12001': {
				1: {
					text:Locale.__e('flash:1458036452667'),
					icon:1994
				},
				2: {
					text:Locale.__e('flash:1458036465873'),
					icon:1991
				},
				3: {
					text:Locale.__e('flash:1458036481209'),
					icon:1988
				}
			},
			'12002': {
				1: {
					text:Locale.__e('flash:1458036494074'),
					icon:1993
				},
				2: {
					text:Locale.__e('flash:1458036504889'),
					icon:1990
				},
				3: {
					text:Locale.__e('flash:1458036516697'),
					icon:1987
				}
			},
			'12003': {
				1: {
					text:Locale.__e('flash:1458036529250'),
					icon:1992
				},
				2: {
					text:Locale.__e('flash:1458036541145'),
					icon:1989
				},
				3: {
					text:Locale.__e('flash:1458036552041'),
					icon:1986
				}
			},
			'100100': {
				1: {
					text:Locale.__e('flash:1456820283021'),
					icon:'HelpPicCityHall01'
				},
				2: {
					text:Locale.__e('flash:1456820362206'),
					icon:'HelpPicCityHall02'
				},
				3: {
					text:Locale.__e('flash:1456820388663'),
					icon:'HelpPicCityHall03'
				}
			},
			'100200': {
				1: {
					text:Locale.__e('flash:1455720160466'),
					icon:'HelpPicSafe01'
				},
				2: {
					text:Locale.__e('flash:1455720415234'),
					icon:(App.lang == 'ru')?'HelpPicSafe02':'HelpPicSafe02Eng'
				},
				3: {
					text:Locale.__e('flash:1455720459572'),
					icon:'HelpPicSafe03'
				},
				4: {
					text:Locale.__e('flash:1455720500146'),
					icon:'HelpPicSafe04'
				}
			},
			'100300': {
				1: {
					text:Locale.__e('flash:1454425642808'),
					icon:1519
				},
				2: {
					text:Locale.__e('flash:1454425608425'),
					icon:1517
				}
			},
			'100400': {
				1: {
					text:Locale.__e('flash:1453895223875'),
					icon:'HelpPicPosterity1'
				},
				2: {
					text:Locale.__e('flash:1453895241474'),
					icon:'HelpPicPosterity2'
				},
				3: {
					text:Locale.__e('flash:1453895259342'),
					icon:'HelpPicPosterity3'
				}
			},
			'100500': {
				1: {
					text:Locale.__e('flash:1440169744667'),
					icon:'banker'
				},
				2: {
					text:Locale.__e('flash:1440169782044'),
					icon:'coffee_house'
				}
			},
			'100600': {
				1: {
					text:Locale.__e('flash:1441896291617'),
					icon:869
				},
				2: {
					text:Locale.__e('flash:1443616810836'),
					icon:946
				}
			},
			'100700': {
				1: {
					text:Locale.__e('flash:1445604787495'),
					icon:'HelpGardenPic1'
				},
				2: {
					text:Locale.__e('flash:1445604821453'),
					icon:'HelpGardenPic2'
				},
				3: {
					text:Locale.__e('flash:1445604854149'),
					icon:'HelpGardenPic3'
				}
			},
			'100800': {
				1: {
					text:Locale.__e('flash:1447752299824'),
					icon:1151
				},
				2: {
					text:Locale.__e('flash:1447752334747') + '\n' + App.data.storage[1150].description,
					icon:1150
				}
			},
			'top13': {
				1: {
					text:Locale.__e('flash:1467714558756'),
					icon:2315
				},
				2: {
					text:Locale.__e('flash:1467714604516'),
					icon:2314
				}
			},
			'tophelp13': {
				1: {
					text:Locale.__e('flash:1467734010438'),
					icon:2284
				},
				2: {
					text:Locale.__e('flash:1467734065285'),
					icon:2314
				},
				3: {
					text:Locale.__e('flash:1467734110773'),
					icon:2315
				}
			},
			'1198': {
				1: {
					text:Locale.__e('flash:1450794278866'),
					icon:'HelpPicCave1'
				},
				2: {
					text:Locale.__e('flash:1450794294075'),
					icon:'HelpPicCave2'
				},
				3: {
					text:Locale.__e('flash:1450794309963'),
					icon:'HelpPicCave3'
				}
			},
			'2099': {
				1: {
					text:Locale.__e('flash:1465552379283'),
					icon:'HelpPicCave1'
				},
				2: {
					text:Locale.__e('flash:1465552438802'),
					icon:'HelpPicCave2'
				},
				3: {
					text:Locale.__e('flash:1465552486393'),
					icon:'HelpPicCave3'
				}
			},
			'2195': {
				1: {
					text:Locale.__e('flash:1465552379283'),
					icon:'HelpPicCave1'
				},
				2: {
					text:Locale.__e('flash:1465552438802'),
					icon:'HelpPicCave2'
				},
				3: {
					text:Locale.__e('flash:1465552486393'),
					icon:'HelpPicCave3'
				}
			},
			'2673': {
				1: {
					text:Locale.__e('flash:1465552379283'),
					icon:'HelpPicCave1'
				},
				2: {
					text:Locale.__e('flash:1465552438802'),
					icon:'HelpPicCave2'
				},
				3: {
					text:Locale.__e('flash:1465552486393'),
					icon:'HelpPicCave3'
				}
			},
			'777': {
				1: {
					text:Locale.__e('flash:1452782164267'),
					icon:'HelpPicRoulette1'
				},
				2: {
					text:Locale.__e('flash:1452782313206'),
					icon:'HelpPicRoulette2'
				},
				3: {
					text:Locale.__e('flash:1452782338285'),
					icon:'HelpPicRoulette3'
				},
				4: {
					text:Locale.__e('flash:1452782456661'),
					icon:'HelpPicRoulette4'
				},
				5: {
					text:Locale.__e('flash:1452782492333'),
					icon:'HelpPicRoulette5'
				}
			},
			'freebie': {
				1: {
					text:Locale.__e('flash:1458906448839'),
					icon:'NewFribyHelpPic1'
				},
				2: {
					text:Locale.__e('flash:1458906471667'),
					icon:'NewFribyHelpPic2'
				},
				3: {
					text:Locale.__e('flash:1458906496659'),
					icon:'NewFribyHelpPic3'
				}
			},
			'expedition2099': {
				1: {
					text:Locale.__e('flash:1465300695510'),
					icon:'ExpHelpPic3'
				},
				2: {
					text:Locale.__e('flash:1465300726235'),
					icon:'ExpHelpPic4'
				},
				3: {
					text:Locale.__e('flash:1465300744873'),
					icon: 2106
				},
				4: {
					text:Locale.__e('flash:1465806505521'),
					icon:2100
				}
			},
			'expedition2195': {
				1: {
					text:Locale.__e('flash:1465300695510'),
					icon:'ExpHelpPic3'
				},
				2: {
					text:Locale.__e('flash:1465300726235'),
					icon:'ExpHelpPic4'
				},
				3: {
					text:Locale.__e('flash:1465983758870'),
					icon: 2221
				},
				4: {
					text:Locale.__e('flash:1465983867958'),
					icon:2242
				}
			},
			'expedition2673': { 
				1: {
					text:Locale.__e('flash:1465300695510'),
					icon:'ExpHelpPic3'
				},
				2: {
					text:Locale.__e('flash:1465300726235'),
					icon:'ExpHelpPic4'
				},
				3: {
					text:Locale.__e('flash:1465983758870'),
					icon: 2221
				},
				4: {
					text:Locale.__e('flash:1465983867958'),
					icon:2242
				}
			},
			'ship': {
				1: {
					text:Locale.__e('flash:1465305963416'),
					icon:'ExpHelpPic1'
				},
				2: {
					text:Locale.__e('flash:1465305993501'),
					icon:'ExpHelpPic2'
				}
			},
			'event': {
				1: {
					text:Locale.__e('flash:1465564214659'),
					icon:'HelpPicChocolate1'
				},
				2: {
					text:Locale.__e('flash:1465564231857'),
					icon:'HelpPicChocolate2'
				},
				3: {
					text:Locale.__e('flash:1465564245209'),
					icon:'HelpPicChocolate3'
				}
			},
			'minigame': {
				1: {
					text:Locale.__e('flash:1465831851053'),
					icon:'MiniGameHelp1'
				},
				2: {
					text:Locale.__e('flash:1465831893582'),
					icon:'MiniGameHelp2'
				},
				3: {
					text:Locale.__e('flash:1465831956180'),
					icon:'MiniGameHelp3'
				},
				4: {
					text:Locale.__e('flash:1465831973297'),
					icon:'MiniGameHelp4'
				}
			},
			'minigame_mine': {
				1: {
					text:Locale.__e('flash:1472547645589'),
					icon:'HelpPicMine_3'					
				},
				2: {
					text:Locale.__e('flash:1472547602462'),
					icon:'HelpPicMine_1'					
				},
				3: {
					text:Locale.__e('flash:1472547621438'),
					icon:'HelpPicMine_2'
				},
				4: {
					text:Locale.__e('flash:1472631557683'),
					icon:'HelpPicMine_5'
				},
				5: {
					text:Locale.__e('flash:1472547664549'),
					icon:'HelpPicMine_4'
				}
			},
			'halloween': {
				1: {
					text:Locale.__e('flash:1476256184691'),
					icon:'eldorado_help2'					
				},
				2: {
					text:Locale.__e('flash:1476256280613'),
					icon:'eldorado_help4'					
				},
				3: {
					text:Locale.__e('flash:1476256322108'),
					icon:'eldorado_help5'
				}
			},
			'lost_cave': {
				
				1: {
					text:Locale.__e('flash:1477483371046'),
					icon:'HelpPic1'					
				},
				2: {
					text:Locale.__e('flash:1477483474804'),
					icon:'HelpPic2'					
				},
				3: {
					text:Locale.__e('flash:1477483566348'),
					icon:'HelpPic3'
				},
				4: {
					text:Locale.__e('flash:1477483601491'),
					icon:'HelpPic4'
				}
			},
			'pet_house': {
				
				1: {
					text:Locale.__e('flash:1479819063179'),
					icon:'HuskieHelpIcon1'					
				},
				2: {
					text:Locale.__e('flash:1479819160274'),
					icon:'HuskieHelpIcon2'					
				},
				3: {
					text:Locale.__e('flash:1479819211818'),
					icon:'HuskieHelpIcon3'
				}
			},
			'fox_invader': {
				
				1: {
					text:Locale.__e('flash:1479895536525'),
					icon:'foxHelp10'					
				},
				2: {
					text:Locale.__e('flash:1479895423033'),
					icon:'foxHelp20'					
				},
				3: {
					text:Locale.__e('flash:1479895183568'),
					icon:'foxHelp30'
				}
			},
			'eldorado_invader': {
				
				1: {
					text:Locale.__e('flash:1481119604491'),
					icon:'eldorado_help1'					
				},
				2: {
					text:Locale.__e('flash:1481119627100'),
					icon:'eldorado_help2'					
				},
				3: {
					text:Locale.__e('flash:1481119650504'),
					icon:'eldorado_help3'
				}
			}
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
				thickness			: 50,
				mirrorDecor			: settings.mirrorDecor
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			headerContainer.y = 32;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			var i:int;
			var item:HelpItem;
			if (settings.hasOwnProperty('qID')) {
				for (i = 1; i < Numbers.countProps(info[settings.qID]) + 1; i++ ) {
					if (!info[settings.qID].hasOwnProperty(i)) continue;
					item = new HelpItem(i, info[settings.qID][i].text, settings.qID);
					item.x = 53;
					item.y = 40 + (i - 1) * (item.background.height + 20);
					bodyContainer.addChild(item);
				}
			} else {
				for (i = 1; i < Numbers.countProps(contents) + 1; i++ ) {
					if (!settings.content.hasOwnProperty(i)) continue;
					item = new HelpItem(i, contents[i].text, '');
					item.x = 53;
					item.y = 40 + (i - 1) * (item.background.height + 20);
					bodyContainer.addChild(item);
				}
			}
			
			var bttn:Button = new Button( {  width:194, height:53, caption:settings.caption } );
			bodyContainer.addChild(bttn);
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 25;
			bttn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function onClick(e:MouseEvent):void {
			if (settings.callback) settings.callback();
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			App.user.onStopEvent();
			super.close();
		}
	}
}

import buttons.ImageButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.InfoWindow;
import wins.GambleWindow;
import wins.Window;

internal class HelpItem extends Sprite {
	
	public var background:Shape = new Shape();
	public var iconBitmap:Bitmap = new Bitmap();
	public var descriptionLabel:TextField;
	public var helpNum:int;
	public var descText:String;
	public var qID:String;
	
	public function HelpItem(helpNum:int, descText:String, qID:String):void {		
		this.helpNum = helpNum;
		this.descText = descText;
		this.qID = qID;
		background.graphics.beginFill(0xffffff, 0);
		background.graphics.drawRect(0, 0, 480, 92);
		background.graphics.endFill();
		addChild(background);
		
		var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
		up_devider.x = 75;
		up_devider.y = 0;
		up_devider.width = background.width - 200;
		up_devider.alpha = 0.6;
		addChild(up_devider);
		
		var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
		down_devider.x = up_devider.x;
		down_devider.width = up_devider.width;
		down_devider.y = background.height - 4;
		down_devider.alpha = 0.6;
		addChild(down_devider);
		
		drawCircles();
		addChild(iconBitmap);
		drawDescription();
		
		if (qID == '100800' && helpNum == 1) {
			var searchBttn:ImageButton = new ImageButton(UserInterface.textures.lens);
			addChild(searchBttn);
			searchBttn.x = 440;
			searchBttn.y = -15;
			searchBttn.addEventListener(MouseEvent.CLICK, showHelp);
		}
		
		if (qID != '') {
			if (InfoWindow.info[qID][helpNum].icon is int) {
				Load.loading(Config.getIcon(App.data.storage[InfoWindow.info[qID][helpNum].icon].type, App.data.storage[InfoWindow.info[qID][helpNum].icon].preview), onLoad);
			}else {
				Load.loading(Config.getImageIcon('help', InfoWindow.info[qID][helpNum].icon, 'png'), onLoad);
			}
		} else {
			if (InfoWindow.contents[helpNum].icon is int) {
				Load.loading(Config.getIcon(App.data.storage[InfoWindow.contents[helpNum].icon].type, App.data.storage[InfoWindow.contents[helpNum].icon].preview), onLoad);
			}else {
				Load.loading(Config.getImageIcon('help', InfoWindow.contents[helpNum].icon, 'png'), onLoad);
			}
		}
	}
	
	private function showHelp(e:MouseEvent):void {
		new GambleWindow( {
			sID:1151,
			popup:true
		}).show();
	}
	
	private var circle:Shape;
	public function drawCircles():void {
		circle = new Shape();
		circle.graphics.beginFill(0xb1c0b9, 1);
		circle.graphics.drawCircle(0, 0, 46);
		circle.graphics.endFill();
		circle.x = background.width - 70;
		circle.y = background.height / 2;
		addChild(circle);
	}
	
	public function drawDescription():void {
		var numPrms:Object = {
				color			:0xf7ffe8,
				borderColor		:0xb77e24,
				shadowColor		:0x50413e,
				shadowSize		:4,
				multiline		:true,
				wrap			:true,
				textAlign		:'center',
				fontSize		:70
		};
		var numberLabel:TextField = Window.drawText(String(helpNum), numPrms);
		numberLabel.width = numberLabel.textWidth + 5;
		numberLabel.x = 30;
		numberLabel.y = (background.height - numberLabel.textHeight) / 2;
		addChild(numberLabel);
		
		var textSize:int = 26;
		do {
			var descPrms:Object = {
					color			:0x5a2e09,
					border			:false,
					width			:280,
					multiline		:true,
					wrap			:true,
					textAlign		:'left',
					fontSize		:textSize
			};
			descriptionLabel = Window.drawText(descText, descPrms);
			descriptionLabel.x = 80;
			descriptionLabel.y = (background.height - descriptionLabel.height) / 2 + 2;
			textSize--;
		}while (descriptionLabel.height >= 85)
		addChild(descriptionLabel);
	}
	
	private var scaleCirc:Number = 1.2;
	private var sprite:LayerX = new LayerX();
	public function onLoad(data:Bitmap):void {
		addChild(sprite);
		
		iconBitmap.bitmapData = data.bitmapData;
		Size.size(iconBitmap, 100, 100);
		iconBitmap.x = circle.x - iconBitmap.width / 2;
		iconBitmap.y = circle.y - iconBitmap.height / 2;
		
		sprite.tip = function():Object { 
			if (qID != '') {
				if (InfoWindow.info[qID][helpNum].icon is int) {
					return {
						title:App.data.storage[InfoWindow.info[qID][helpNum].icon].title,
						text:App.data.storage[InfoWindow.info[qID][helpNum].icon].description
					};
				}
			}else {
				if (InfoWindow.contents[helpNum].icon is int) {
					return {
						title:App.data.storage[InfoWindow.contents[helpNum].icon].title,
						text:App.data.storage[InfoWindow.contents[helpNum].icon].description
					};
				}
			}
			
			return null;
		};
		
		sprite.addChild(iconBitmap);
	}
}