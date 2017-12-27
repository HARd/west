package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Thappy;
	import wins.IslandChallengeWindow;
	import wins.Window;
	import ui.UserInterface;



	public class TeamsRewardItems  extends Window {
		private var giftContainer:Sprite = new Sprite();
		private var teamID:int;
		private var kicks:*;
			public function TeamsRewardItems(_teamID:int,settings:Object=null) 
			{
				if (!settings) settings = { };
				
				settings['width'] =  540;
				settings['height'] =  490;
				settings['title'] = Locale.__e ("flash:1414160740806");
				settings['hasPaginator'] = false;
				settings['popup'] = true;
				settings['background'] = 'alertBacking';
				
				teamID = _teamID;
				
				var obj:Object = App.data.storage[settings.target.sid];
				kicks = obj.teams[teamID].levels.c;
				super(settings);
			}
			
			override public function drawBackground():void {
				background =  backing(settings.width, settings.height, 50, "alertBacking");;
				layer.addChild(background);
			}
			
			override public function drawBody():void {
				drawGifts ();
			}	
			private function drawGifts():void {
				bodyContainer.addChild(drawGift( { x:60, y:20, num:0, sizeX:132,sizeY:182,bg:"itemBacking" } ));
				bodyContainer.addChild(drawGift( { x:205, y:20, num:1, sizeX:132,sizeY:182,bg:"itemBacking" } ));
				bodyContainer.addChild(drawGift( { x:350, y:20, num:2, sizeX:132, sizeY:182, bg:"itemBacking" } ));
				bodyContainer.addChild(drawGift( { x:132, y:205, num:3, sizeX:132,sizeY:182,bg:"itemBacking" } ));
				bodyContainer.addChild(drawGift( { x:277, y:205, num:4, sizeX:132,sizeY:182,bg:"itemBackingYellow" } ));
			}
				
			private function drawGift(items:Object):LayerX {
				var gift:Bitmap;
				var giftCont:LayerX;
				var giftBacking:Bitmap;
				giftCont = new LayerX();
				giftBacking = backing(items.sizeX, items.sizeY, 50, items.bg);
				giftBacking.x = 0;
				giftBacking.y = 0;
				giftCont.addChild (giftBacking);
				
				var sid:int;
				var giftItems:Object;
				var giftText:String;
				if (items.num  == Numbers.countProps(settings.target.info.teams[settings.target.team].levels.t)) {
					var giftTreasure:String;
					giftTreasure = App.data.storage[settings.target.sid].teams[teamID].info.loss;
					giftItems = App.data.treasures[giftTreasure][giftTreasure].item;
					for each (var s:* in giftItems) 
						giftText = String(s);
					for each(s in giftItems) 
						sid = int(s);
					var superReward:TextField = drawText( Locale.__e('flash:1467623379606') , {
						textAlign:		'center',
						autoSize:		'center',
						width:			giftBacking.width - 20,
						multiline:		true,
						wrap:			true,
						fontSize:		22,
						color:			0x6b401a,
						borderColor:	0xfffcff,
						distShadow:		0
					});
					superReward.x = giftBacking.x + (giftBacking.width - superReward.width) / 2;
					superReward.y = 10;
					giftCont.addChild(superReward);
				}
				else{
					var trName:String = settings.target.info.teams[teamID].levels.t[items.num];
					giftItems = App.data.treasures[trName][trName].item;
					var giftCount:Object = App.data.treasures[trName][trName].count;
					for each(s in giftCount) 
						giftText = String(s);
					for each(s in giftItems) 
						sid = int(s);
				}
				giftCont.x = items.x;
				giftCont.y = items.y;
				gift = new Bitmap();
				giftCont.addChild(gift);
				giftCont.tip = function():Object {
					return { title:App.data.storage[sid].title, text:App.data.storage[sid].description };
				}
				
				var giftsLabel:TextField = drawText( 'x' + giftText , {
					textAlign:		'center',
					autoSize:		'center',
					fontSize:		32,
					color:			0xfffcff,
					borderColor:	0x6b401a,
					distShadow:		0
				});
				giftsLabel.x = 3*giftBacking.width/4 - 10;
				giftsLabel.y = 3*giftBacking.height/4 - 10;
				giftCont.addChild(giftsLabel);
				
				var preloader:Preloader = new Preloader();
				preloader.x = giftBacking.width / 2;
				preloader.y = giftBacking.height / 2;
				giftCont.addChild(preloader);
				Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), function(data:Bitmap):void {
					giftCont.removeChild(preloader);
					preloader = null;
					
					gift.bitmapData = data.bitmapData;
					
					if (gift.width > giftBacking.width - 20) {
						gift.width = giftBacking.width - 20;
						gift.scaleY = gift.scaleX;
					}
					if (gift.height > giftBacking.height - 20) {
						gift.height = giftBacking.height - 20;
						gift.scaleX = gift.scaleY;
					}
					gift.x = giftBacking.x + (giftBacking.width - gift.width) / 2;
					gift.y = giftBacking.y + (giftBacking.height - gift.height) / 2;
				});
				return giftCont;
			}
		}

}