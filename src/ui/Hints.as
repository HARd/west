package ui
{
	import core.Numbers;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	public class Hints
	{
		public static const ADD_MATERIAL:int 		= 1;
		public static const ADD_EXP:int 			= 2;
		public static const COINS:int			    = 3;
		public static const ALERT:int 				= 4;
		public static const ENERGY:int 				= 5;
		public static const TEXT_RED:int			= 6;
		public static const BANKNOTES:int			= 7;
		public static const FANT:int			    = 8;
		public static const REMOVE_MATERIAL:int 	= 9;
		
		public static var delay:uint				= 500;
		public static var flightDist:int			= -80;
		
		public static function getSettings(ID:int):Object {
			
			var settings:Object = {}
			switch(ID)
			{
				// + монеты и материалы
				case 1:
					settings = {
							color				:0xf5f1c4,		// Белый,
							borderColor 		:0x342319		// Темносерый
						};
					break;	
					
					// + опыт
				case 2:
					settings = {
							color				:0xffee62,	// Светло желтый
							borderColor 		:0x4c2b0d	// Бледнобежевый
						};
					break;
					// - монеты
				case 3:
					settings = {
						color				:0xffd523,		// Желтый,
						borderColor 		:0x6d3400		// коричневый
					};
					break;
					// alert
				case 4:
					settings = {
						color				: 0xd0ff74,		// Салатовый
						borderColor 		: 0x26600a		// Зеленый
					};
					break;
					
					// energy
				case 5:
					settings = {
						color				:0xd4ffff,// 0x6FB7D2,
						borderColor 		:0x1b2e60// 0x142F8B
					};
					break;
					
					// energy
				case 6:
					settings = {
						color				: 0xD21E27,
						borderColor 		: 0x510000
					};
					break;
					
					// add banknotes	
				case 7:
					settings = {
						color				: 0x7fb4fa,//0xA3D637,
						borderColor 		: 0x382662
					};
					break;
					
					
					
					
					
				case 8:
					settings = {
						color				: 0xd0ff74,		// Салатовый
						borderColor 		: 0x26600a		// Зеленый
					};
					break;	
					
				// Запрет (красное)
				case 9:
					settings = {
						color				: 0xff632c,		// Оранжевый
						borderColor 		: 0x591f0b		// Коричневый
					};
					break;	
			}
			
				settings["borderSize"] 		= 4;
				settings["fontBorderGlow"] 	= 4;
				
				return settings;
		}
		
		public static function plus(sID:uint, count:uint, position:Point, _delay:Boolean = false, layer:Sprite = null, timeOut:int = 0):void
		{
			var settings_Numbs:Object;
			var settings_Text:Object;
			var hasTitle:Boolean = true;
			
			switch(App.data.storage[sID].view)
			{
				case "Reals":
					settings_Numbs 	= getSettings(Hints.FANT);
					settings_Text	= getSettings(Hints.FANT);
					break;
				case "Material":
					settings_Numbs 	= getSettings(Hints.ADD_MATERIAL);
					settings_Text	= getSettings(Hints.ADD_MATERIAL);
					break;
				case "Energy":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text	= getSettings(Hints.ENERGY);
					break;
				case "coins":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.COINS);
					settings_Text 	= getSettings(Hints.COINS);
					break;
				case "exp":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ADD_EXP);
					settings_Text 	= getSettings(Hints.ADD_EXP);
					break;
				case "ether":
					hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text 	= getSettings(Hints.ENERGY);
					break;
				default:
					settings_Numbs 	= getSettings(Hints.ADD_MATERIAL);
					settings_Text 	= getSettings(Hints.ADD_MATERIAL);
					break
			}
			
			settings_Numbs['text'] =  "+" + count;
			if(hasTitle)
				settings_Text['text'] =  App.data.storage[sID].title;
			
			settings_Numbs['fontSize'] = 24;
			settings_Numbs['textAlign'] = 'right';
			settings_Text['fontSize'] = 16;
			settings_Text['textAlign'] = 'left';
			
			if ([Stock.EXP, Stock.FANT, Stock.COINS, Stock.ENERGY].indexOf(sID) >= 0) settings_Text = sID;
			if (timeOut > 0)
				setTimeout(function():void {new Hint([settings_Numbs, settings_Text], _delay, position, layer); }, timeOut);
			else 
				new Hint([settings_Numbs, settings_Text], _delay, position, layer);
		}
		
		public static function minus(sID:uint, price:uint, position:Point, _delay:Boolean = false, layer:Sprite = null, timeOut:int = 0):void
		{
			var settings_Numbs:Object;
			var settings_Text:Object;
			
			switch(sID)
			{
				case Stock.FANTASY:
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text	= getSettings(Hints.ENERGY);
					break;
				case Stock.COINS:
					settings_Numbs 	= getSettings(Hints.COINS);
					settings_Text 	= getSettings(Hints.COINS);
					break;
				case Stock.FANT:
					settings_Numbs 	= getSettings(Hints.FANT);
					settings_Text 	= getSettings(Hints.FANT);
					break;
				case Stock.EXP:
					settings_Numbs 	= getSettings(Hints.ADD_EXP);
					settings_Text 	= getSettings(Hints.ADD_EXP);
					break;
				default:
					settings_Numbs 	= getSettings(Hints.REMOVE_MATERIAL);
					settings_Text 	= getSettings(Hints.REMOVE_MATERIAL);
					break
			}
			
			settings_Numbs['text'] =  "-"+price;
			settings_Text['text'] =  App.data.storage[sID].title;
			
			settings_Numbs['fontSize'] = 26;
			settings_Numbs['textAlign'] = 'right';
			settings_Text['fontSize'] = 18;
			settings_Text['textAlign'] = 'left';
			
			if ([Stock.EXP, Stock.FANT, Stock.COINS, Stock.ENERGY].indexOf(sID) >= 0) settings_Text = sID;
			if (timeOut > 0)
				setTimeout(function():void {new Hint([settings_Numbs, settings_Text], _delay, position, layer); }, timeOut);
			else
				new Hint([settings_Numbs, settings_Text], _delay, position, layer);
		}
		
		public static function text(text:String, type:int, position:Point, _delay:Boolean = false, layer:Sprite = null):void
		{
			var settings_Text:Object = getSettings(type);
					
			settings_Text['text'] =  text;
			settings_Text['fontSize'] = 20;
			settings_Text['textAlign'] = 'left';
			
			new Hint([settings_Text], _delay, position, layer);
		}
		
		public static function buy(target:*):void
		{
			var info:Object = target.info;
			var point:Point = new Point(target.x * App.map.scaleX + App.map.x, target.y * App.map.scaleY + App.map.y);
			var price:Object;
			
			if (info.hasOwnProperty('instance'))
			{  
				//var countOnMap:int = World.getBuildingCount(info.sid);
				var countOnMap:int = Map.findUnits([int(info.sid)]).length;
				
				if (info.hasOwnProperty('instance')) 
				{
					countOnMap = Storage.instanceGet(info.sid);
				}else 
				{
					countOnMap = World.getBuildingCount(info.sid);
				}
				
				if (info.hasOwnProperty('instance') && App.user.stock.data && App.user.stock.data.hasOwnProperty(info.sid) /*&& item.type == 'Building'*/) 
				{
					countOnMap += App.user.stock.count(info.sid);
				}
				
				if (!info.instance.cost.hasOwnProperty(countOnMap + 1)) {
					while (!info.instance.cost.hasOwnProperty(countOnMap + 1) && countOnMap > 0) {
						countOnMap --;
					}
				}
				price = info.instance.cost[countOnMap + 1];
			}else {
				price = Storage.price(target.sid);
			}
			
			if (!price && info.instance.cost.hasOwnProperty(1)) price = info.instance.cost[1];
			
			var counter:int = 0;
			for (var sid:* in price) {
				Hints.minus(int(sid), price[sid], point, false, null, counter);
				counter += 300;
			}
		}
		
		public static function plusAll(data:Object, position:Point, layer:Sprite):void
		{
			var count:uint = 0;
			var counter:int = 0;
			var sID:*;
			
			for(sID in data){    
				count = data[sID];
				Hints.plus(sID, count, position, false, layer, counter);
				counter += 500;
			}
		}

	}
}

	import com.greensock.easing.Strong;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import com.greensock.*
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import wins.Window;
	import ui.Hints;
	import ui.UserInterface;
	
	internal class Hint extends Sprite
	{
		private var container:Sprite = new Sprite();
		private var bitmap:Bitmap;
		private var hintsLayer:Sprite;
		private var timer:Timer
		private var position:Point
		
		public function Hint(labels:Array, delay:Boolean, position:Point, layer:Sprite = null)
		{
			this.position = position;
			
			if (layer) 
				hintsLayer = layer;
			else	
				hintsLayer = App.self.tipsContainer;
				
			createLabels(labels);
			draw();
			
			if (delay == false)
			{
				init();
			}
			else
			{
				timer = new Timer(Hints.delay, 1);
				timer.addEventListener(TimerEvent.TIMER, onComplete);
				timer.start();
			}
			
			//hintsLayer.mouseEnabled = false;
			//hintsLayer.mouseChildren = false;
		}
		
		private function init():void
		{
			move();
			this.x = position.x;
			this.y = position.y;
			hintsLayer.addChild(this);
		}
		
		private function draw():void
		{
			var bitmapData:BitmapData = new BitmapData(container.width, container.height, true, 0x00000000);
			var mt:Matrix = new Matrix();
			mt.translate(0, container.height/2);
			bitmapData.draw(container, mt);
			bitmap = new Bitmap(bitmapData);
			bitmap.smoothing = true;
			addChild(bitmap);
			bitmap.x = -bitmap.width / 2;
			container = null;
		}
		
		private function move():void
		{
			TweenLite.to(bitmap, 4, { y:Hints.flightDist, onComplete:moveComplete, ease:Strong.easeOut } );
			TweenLite.to(this, 2, { alpha:0, ease:Strong.easeIn } );
		}	
		
		private function onComplete(e:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER, onComplete);
			init();
		}
		
		
		private function createLabels(labels:Array):void
		{
			var X:int = 0;
			var Y:int = 0;
			for each(var label:Object in labels)
			{
				if (label is Number) 
				{
					var icon:Bitmap;
					var item:Object = App.data.storage[label];
					
					if (item.type == 'Material') {
						icon = new Bitmap();
						
						switch(label) {
							case Stock.COINS:	icon.bitmapData = UserInterface.textures.coinsIcon;		break;
							case Stock.FANT:	icon.bitmapData = UserInterface.textures.fantsIcon;		break;
							case Stock.EXP:		icon.bitmapData = UserInterface.textures.expIcon;		break;
							case Stock.ENERGY:	icon.bitmapData = UserInterface.textures.energyIcon;	break;
						}
						
						icon.smoothing = true;
						icon.scaleX = icon.scaleY = 0.7;
						container.addChild(icon);
						icon.x = X + 4;
						icon.y = -icon.height / 2 - 2;
					}
					
					X += icon.width;
				}else {
					var textLabel:TextField = Window.drawText(label.text, label);
					
					textLabel.x = X;
					textLabel.width  = textLabel.textWidth + 4;
					textLabel.height = textLabel.textHeight + 4;
					
					textLabel.y = -textLabel.height / 2;
					
					container.addChild(textLabel);
					X += textLabel.width;	
				}
			}	
		}
		
		private function moveComplete():void
		{
			if(hintsLayer.contains(this)){
				hintsLayer.removeChild(this);
			}
		}
	}

