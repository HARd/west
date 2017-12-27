package wins  {
	
	import buttons.Button;
	import buttons.ChangedButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class GuestRewardsWindow extends Window {
		
		public var rel:Array = new Array;
		private var descText:TextField = new TextField();
		
		public function GuestRewardsWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 655;
			settings['height'] = 430;
			settings['title'] = Locale.__e('flash:1448441785301');
			settings['background'] = 'alertBacking';
			settings['hasPaginator'] = false;
			
			super(settings);
			rel = [];
			var numb:int = 0;
			for each (var material:* in App.data.storage) {
				if (material.type == 'Guests') {
					rel[numb] = material;
					numb++;
				}
			}
			trace('rel');
			rel.sortOn('count', Array.NUMERIC);
			
			App.self.addEventListener(AppEvent.ON_CHANGE_GUEST_FANTASY, reDraw);		//потом будет ?
			//findTargetPage(settings);
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
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - 8;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private var guestRewards:Array;
		private var priceBttn:Button;
		override public function drawBody():void {
			guestRewards = [];
			drawDesc();
			
			var up_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			up_devider.x = 75;
			up_devider.y = descText.y + descText.height + 10;
			up_devider.width = settings.width - 150;
			up_devider.alpha = 0.6;
			
			var bgW:Bitmap = Window.backing(up_devider.width, 174, 50, 'fadeOutWhite');
			bgW.alpha = 0.4;
			bgW.x = (settings.width - bgW.width) / 2;
			bgW.y = up_devider.y;
			bodyContainer.addChild(bgW);
			
			bodyContainer.addChild(up_devider);
			
			var down_devider:Bitmap = new Bitmap(Window.textures.dividerLine);
			down_devider.x = up_devider.x;
			down_devider.width = up_devider.width;
			down_devider.y = up_devider.y + 170;
			down_devider.alpha = 0.6;
			bodyContainer.addChild(down_devider);
			
			//var glowing:Bitmap = new Bitmap(Window.textures.glow);
			//timerContainer.addChild(glowing);
			//glowing.smoothing = true;
			//glowing.alpha = .5;
			//glowing.scaleX = glowing.scaleY = 0.6;
			//glowing.x = -40;
			//glowing.y = -40;
			
			contentChange();
			drawButton();
		}
		
		private function drawDesc():void {
			descText = Window.drawText(Locale.__e('flash:1427203835675'), {
				color:0x542d0a,
				borderColor:0xf8e6d2,
				textAlign:"center",
				autoSize:"center",
				fontSize:24,
				multiline: true,
				wrap: true
			});
			descText.width = settings.width - 170;
			descText.x = (settings.width - descText.width) / 2;
			descText.y = 25;
			bodyContainer.addChild(descText);
		}
		
		private function drawButton():void {
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952380242"),
				bgColor:[0xf5d057, 0xeeb331],
				bevelColor:[0xfff17f, 0xbf7e1a],
				borderColor:[0xc2ab8e, 0x3d3e01],
				fontSize:30,
				fontBorderColor:0x814f31,
				width:162,
				height:52,
				hasDotes:false
			};
			priceBttn = new Button(bttnSettings);
			bodyContainer.addChild(priceBttn);
			priceBttn.x = (settings.width - priceBttn.width) / 2;
			priceBttn.y = settings.height - 95;
			priceBttn.addEventListener(MouseEvent.CLICK, close);
		}
		
		private function reDraw(e:AppEvent = null):void {
			contentChange();
		}
		
		override public function contentChange():void {
			for each(var item:GuestRewardItem in guestRewards) {
				if(item.parent)item.parent.removeChild(item);
				item.dispose();
				item = null;
			}
			guestRewards = [];
			if (progressBacking)
			bodyContainer.removeChild(progressBacking);
			progressBacking = null;
			if (progressBar)
			bodyContainer.removeChild(progressBar);
			progressBar = null;
			if (count)
			bodyContainer.removeChild(count);
			count = null;
			
			var posX:int = 75;
			var currentNumb:int = 0;
			var posStartX:int = -12;
			var current:Boolean = false;
			
			for (var j:int = 0; j < rel.length; j++ ) {
				if (rel[j].count <= App.user.stock.data[Stock.COUNTER_GUESTFANTASY]) {
					currentNumb = j + 1;
					if (currentNumb > rel.length - 1) {
						currentNumb = rel.length - 1;
					}
				}
			}
			
			for (var i:int = 0; i < rel.length; i++ ) {
				if (currentNumb == i &&(rel[i].count > App.user.stock.data[Stock.COUNTER_GUESTFANTASY])) {
					current = true;
				} else {
					current = false;
				}
				
				item = new GuestRewardItem(rel[i].sid, rel[i], this, current);
				item.x = posStartX + posX + 20;
				item.y = 90;
				bodyContainer.addChild(item);
				
				posX += item.width + 10;
				
				guestRewards.push(item);
			}
			
			var progressIcon:Bitmap = new Bitmap(UserInterface.textures.guestEnergy);
			progressIcon.x = 90;
			progressIcon.y = 270;
			progressIcon.scaleX = progressIcon.scaleY = 0.8;
			progressIcon.smoothing = true;
			bodyContainer.addChild(progressIcon);
			
			var progressBacking:Bitmap = Window.backingShort(400, 'progBarBacking');
			progressBacking.x = 170;
			progressBacking.y = 290;
			bodyContainer.addChild(progressBacking);
			
			var progressBar:ProgressBar = new ProgressBar({ win:this, width:400 + 16, isTimer:false, scale:.7});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = progressBacking.y - 4;
			bodyContainer.addChild(progressBar);
			
			progressBar.start();
			progressBar.progress = getProgress(rel[currentNumb].count);
			
			var count:TextField = Window.drawText(getProgressTxt(rel[currentNumb].count), {
				color:			0xffffff,
				borderColor:	0x754108,
				fontSize:		30,
				shadowColor:	0x754108,
				shadowSize:		1
			});
			count.width = count.textWidth + 10;
			count.x = progressBacking.x + (progressBacking.width - count.textWidth) / 2;
			count.y = progressBacking.y;
			bodyContainer.addChild(count);
		}
		
		private function getProgressTxt(need:int):String {
			var needItems:int = need;
			var haveItems:int;
			
			haveItems = App.user.stock.data[Stock.COUNTER_GUESTFANTASY];
			
			if (haveItems > needItems) haveItems = needItems;
			
			var rez:String = String(haveItems) + "/" + String(needItems)
			return rez;
		}
		
		private function getProgress(need:int):Number {
			var needItems:int = need;
			var haveItems:int;
			
			haveItems = App.user.stock.data[Stock.COUNTER_GUESTFANTASY];
			
			if (haveItems > needItems) haveItems = needItems;
			
			var rez:Number =  haveItems / needItems;
			if (rez > 1) rez = 1;
			
			return rez;
		}
		
		override public function dispose():void {
			App.self.removeEventListener(AppEvent.ON_CHANGE_GUEST_FANTASY, reDraw);
			super.dispose();
		}
	}
}

import com.adobe.images.BitString;
import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import ui.UserInterface;
import wins.GuestRewardsWindow;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;

internal class GuestRewardItem extends LayerX {
	
	private var window:GuestRewardsWindow;
	public var id:int;
	public var count:int;
	public var sid:int;
	private var _height:Number;
	private var _width:Number;
	private var canGlowing:Boolean = true;
	private var current:Boolean = false;
	//private var background:Bitmap;
	private var background:Shape;
	private var guestGlow:Bitmap;
	private var guestIcon:Bitmap;
	private var bitmap:Bitmap = new Bitmap();
	private var mark:Bitmap = new Bitmap();
	public var reward:Object = { };
	
	public function GuestRewardItem(id:int, reward:Object, window:GuestRewardsWindow, current:Boolean = false, doGlow:Boolean = false) {
		this.window = window;
		this.current = current;
		update(id, reward, doGlow);
	}
	
	public function update(id:int, reward:Object, doGlow:Boolean = false):void {
		this.reward = reward;
		this.id = id;
		for (var sid:* in reward.outs) {
			this.sid = sid; 
			this.count = reward.outs[sid];
			break;
		}
		clearBody();
		drawBody();
		
		if (doGlow) glowing();
	}
	
	private function clearBody():void {
		if (background && background.parent)
			background.parent.removeChild(background);
		
		background = null;
		
		if (bitmap && bitmap.parent)
			bitmap.parent.removeChild(bitmap);
		
		bitmap = new Bitmap();
		
		if (guestGlow && guestGlow.parent)
			guestGlow.parent.removeChild(guestGlow);
		
		guestGlow = null;
		guestGlow = new Bitmap();
		
		if (guestIcon && guestIcon.parent)
			guestIcon.parent.removeChild(guestIcon);
		
		guestIcon = null;
		guestIcon = new Bitmap();
	}
	
	private function drawBody():void {
		drawRewardInfo();
		drawInfo();
	}
	
	private var offset:int = 20;
	private var title:String;
	private	var text:String;
	private function drawRewardInfo():void {
		background = new Shape();
		if (reward.count <= App.user.stock.data[Stock.COUNTER_GUESTFANTASY] || current) {
			//background = new Bitmap(Window.textures.instCharBacking);
			background.graphics.beginFill(0xb0beb5, 1);
			background.graphics.drawCircle(45, 95, 45);
			background.graphics.endFill();
		} else {
			//background = new Bitmap(Window.textures.instCharBackingDisabled);
			background.graphics.beginFill(0xb1c0b9, 1);
			background.graphics.drawCircle(45, 95, 45);
			background.graphics.endFill();
		}
		addChild(background);
		
		guestGlow  = new Bitmap(Window.textures.glow);
		guestGlow.scaleX = guestGlow.scaleY = 0.4;
		
		guestGlow.x = background.x - guestGlow.width / 2 + background.width / 2;
		guestGlow.y = 45 - guestGlow.height / 2 + background.height / 2;
		addChild(guestGlow);
		
		Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoadImage);
		addChild(bitmap);
		
		for each(var counts:* in reward.outs)
			break;
		
		var count:TextField = Window.drawText('x' + counts, {
			color:			0xffffff,
			borderColor:	0x754108,
			borderSize:		2,
			shadowColor:	0x754108,
			shadowSize:		2,
			fontSize:		26
		});
		
		guestIcon.x = background.x + (background.width - guestIcon.width - count.textWidth) / 2;
		
		count.width = count.textWidth + 10;
		count.x = background.x + (background.width - count.textWidth) + 15;
		count.y = 56 + (background.height - count.height);
		addChild(count);
		
		mark = new Bitmap(Window.textures.checkMark);
		mark.x = background.x + (background.width - mark.width) / 2;
		mark.y = 40 + (background.height - mark.height) / 2;
		addChild(mark);
		
		if (reward.count <= App.user.stock.data[Stock.COUNTER_GUESTFANTASY] || current) {
			if (current) {
				guestGlow.alpha = 1;
				mark.alpha = 0;
				title = Locale.__e('flash:1427211986691');
				text = Locale.__e('flash:1427212036975', [String(reward.count), String(count.text).substring(1, String(count.text).length), String(App.data.storage[sid].title)]);
			} else {
				mark.alpha = 1;
				guestGlow.alpha = 0;
				title = Locale.__e('flash:1427212076861');
			}
		} else {
			mark.alpha = 0;
			guestGlow.alpha = 0;
			title = Locale.__e('flash:1427211986691');
			text = Locale.__e('flash:1427212036975', [String(reward.count), String(count.text).substring(1, String(count.text).length), String(App.data.storage[sid].title)]);
		}
		
		tip = function():Object {
			return {
				title:title,
				text:text
			}
		}
	}
	
	private function onLoadImage(data:Object):void {
		bitmap.bitmapData = data.bitmapData;
		//bitmap.scaleX = bitmap.scaleY = 1.2;
		
		if (bitmap.width > background.width - offset) {
			bitmap.width = 	background.width - offset;
			bitmap.scaleY = bitmap.scaleX;
		}
		/*if (bitmap.height>background.height-offset) {
			bitmap.height = 	background.height - offset;
			bitmap.scaleX = bitmap.scaleY;
		}*/
		bitmap.x = background.x + (background.width - bitmap.width) / 2;
		bitmap.y = 50 + (background.height - bitmap.height) / 2;
		//bitmap.x = (settings.width - bitmap.width) / 2;
		//bitmap.y = 40 + (background.height - bitmap.height) / 2 - 5;
		bitmap.smoothing = true;
		//bodyContainer.addChild(bitmap);
	}
	
	private function drawInfo():void {
		guestIcon  = new Bitmap(UserInterface.textures.guestEnergy);
		guestIcon.scaleX = guestIcon.scaleY = .4;
		guestIcon.smoothing = true;
		addChild(guestIcon);
		
		var count:TextField = Window.drawText(reward.count, {
			color:			0xffffff,
			borderColor:	0x754108,
			borderSize:		2,
			shadowColor:	0x754108,
			shadowSize:		2,
			fontSize:		30
		});
		
		guestIcon.x = background.x + (background.width - guestIcon.width - count.textWidth) / 2;
		guestIcon.y = 10
		
		count.width = count.textWidth + 10;
		count.x = guestIcon.x + guestIcon.width;
		count.y = guestIcon.y;
		addChild(count);
	}
	
	public function glowing():void {
		customGlowing(this, glowing);	
	}
	
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null && canGlowing) {
					callback();
				}else if(!canGlowing){
					TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 7, blurX:1, blurY:1 } });
				}
			}});	
		}});
	}
	
	private function stopGlowing():void {
		canGlowing = false;
		window.settings.find = 0;
	}
	
	public function dispose():void {
		clearBody();
		window = null;
		//mission = null;
		//achive = null;
	}
	
	public override function get height():Number {
		return background.height;
	}
	
	public override function  get width():Number {
		return background.width;
	}
}