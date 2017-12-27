package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	public class DayleftWindow extends Window 
	{
		
		private var titleImage:Bitmap;
		private var subbacking:Bitmap;
		private var titleTextLabel:TextField;
		private var descTextLabel:TextField;
		private var applyBttn:Button;
		
		public var bonus:Object;
		
		public function DayleftWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = settings.width || 530;
			settings['height'] = settings.height || 370;
			settings['hasPaginator'] = false;
			settings['faderAsClose'] = settings.faderAsClose || false;
			settings['hasTitle'] = settings.hasTitle || false;
			settings['title'] = settings.title || '';
			settings['background'] = settings.background || 'questBacking';
			bonus = settings.bonus || { };
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			//subbacking = backing(490, 230, 50, 'dialogueBacking');
			subbacking = backing(settings.width - 30, 230, 50, 'dialogueBacking');
			subbacking.x = (settings.width - subbacking.width) / 2;
			subbacking.y = 126;
			bodyContainer.addChild(subbacking);
			
			titleImage = new Bitmap();
			bodyContainer.addChild(titleImage);
			Load.loading(Config.getImage('content', 'daysleft_bonus'), onTitleImageLoad);
			
			titleTextLabel = drawText(Locale.__e('flash:1413800714577'), {
				color:			0xf6fffa,
				borderColor:	0xb88558,
				autoSize:		'center',
				fontSize:		35
			});
			titleTextLabel.filters = titleTextLabel.filters.concat([new GlowFilter(0x815c28, 1, 4, 4, 16)]);
			titleTextLabel.x = (settings.width - titleTextLabel.width) / 2;
			titleTextLabel.y = 8;
			bodyContainer.addChild(titleTextLabel);
			
			descTextLabel = drawText(Locale.__e('flash:1413800890484'), {
				color:			0xfbfff9,
				borderColor:	0x5c3a1e,
				textAlign:		'center',
				fontSize:		26,
				width:			settings.width - 30
			});
			descTextLabel.x = (settings.width - descTextLabel.width) / 2;
			descTextLabel.y = titleTextLabel.y + titleTextLabel.height + 15;
			bodyContainer.addChild(descTextLabel);
			
			applyBttn = new Button( {
				width:		250,
				height:		54,
				caption:	Locale.__e('flash:1382952379786')
			});
			applyBttn.x = (settings.width - applyBttn.width) / 2;
			applyBttn.y = settings.height - 28;
			bodyContainer.addChild(applyBttn);
			applyBttn.addEventListener(MouseEvent.CLICK, onApply);
			
			//drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, 44, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 4, settings.height - 38, false, false, true, 1, 1);
			drawMirrowObjs('diamondsTop', settings.width / 2 - titleTextLabel.width / 2 - 8, settings.width / 2 + titleTextLabel.width / 2 + 8, titleTextLabel.y + 4, true, true);
			
			exit.y -= 18;
			
			contentChange();
		}
		
		private function onApply(e:Event):void {
			if (applyBttn.mode == Button.DISABLED) return;
			applyBttn.state = Button.DISABLED;
			exit.visible = false;
			
			apply();
		}
		private function apply():void {
			var window:* = this;
			
			Post.send({
				ctr:'bonus',
				act:'lack',
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				exit.visible = true;
				if (error || !data.bonus) {
					close();
				}else{
					App.user.stock.addAll(data.bonus);
					BonusItem.takeRewards(data.bonus, applyBttn);
					timeoutClose(1000);
				}
			});
		}
		
		public function onTitleImageLoad(data:Bitmap):void {
			titleImage.bitmapData = data.bitmapData;
			titleImage.smoothing = true;
			titleImage.x = (settings.width - titleImage.width) / 2;
			titleImage.y = -250;
		}
		
		override public function drawFader():void {
			super.drawFader();
			this.y += 115;
			fader.y -= 115;
		}
		
		public var container:Sprite;
		public var items:Vector.<DayleftItem> = new Vector.<DayleftItem>;
		override public function contentChange():void {
			const ITEM_MARGIN:int = 0;
			var currX:int = 0;
			
			clear();
			
			if (!container) {
				container = new Sprite();
				bodyContainer.addChild(container);
			}
			
			for (var s:String in bonus) {
				var item:DayleftItem = new DayleftItem(s, bonus[s]);
				item.x = currX;
				container.addChild(item);
				
				currX += item.width + ITEM_MARGIN;
			}
			
			container.x = (settings.width - container.width) / 2;
			container.y = subbacking.y + (subbacking.height - container.height) / 2;
		}
		
		private var timeout:int = 0;
		public function timeoutClose(delay:int):void {
			if (timeout == 0) {
				timeout = setTimeout(function():void {
					timeout = 0;
					close();
				}, delay);
			}
		}
		public function clear():void {
			while (items.length > 0) {
				var item:DayleftItem = items.shift();
				item.dispose();
			}
		}
		override public function dispose():void {
			if (timeout > 0) clearTimeout(timeout);
			clear();
			
			super.dispose();
		}
	}

}


import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import units.Anime;
import wins.Window;

internal class DayleftItem extends Sprite {
	
	public var count:uint;
	public var sID:uint;
	
	public var background:Bitmap;
	public var bitmap:Bitmap;
	public var title:TextField;
	private var sprite:LayerX;
	
	private var preloader:Preloader = new Preloader();
	
	public function DayleftItem(sid:*, count:int = 0):void {
		
		sID = int(sid);
		this.count = count;
		
		var backType:String = 'itemBacking';
		background = Window.backing(150, 190, 10, backType);
		background.visible = false;
		addChild(background);
		
		sprite = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		drawTitle();
		if (count > 1) {
			drawCount();
		}
		
		addChild(preloader);
		preloader.x = (background.width)/ 2;
		preloader.y = (background.height) / 2 - 15;
		
		var type:String = App.data.storage[sID].type;
		var preview:String = App.data.storage[sID].preview;
		
		if (['Golden','Gamble'].indexOf(App.data.storage[sID].type) >= 0) {
			Load.loading(Config.getSwf(App.data.storage[sID].type, App.data.storage[sID].view), onLoadAnimate);
		}else {
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
		}
	}
	public function onPreviewComplete(data:Bitmap):void
	{
		removeChild(preloader);
		
		bitmap.bitmapData = data.bitmapData;
		bitmap.scaleX = bitmap.scaleY = 1;
		bitmap.smoothing = true;
		bitmap.x = (background.width - bitmap.width)/ 2;
		bitmap.y = (background.height - bitmap.height) / 2;
		
		addTip();
	}
	private function onLoadAnimate(swf:*):void {
		removeChild(preloader);
		
		addTip();
		
		var anime:Anime = new Anime(swf, {w:background.width - 20, h:background.height - 20, animal:((App.data.storage[sID].type == 'Animal') ? true : false)});
		anime.x = (background.width - anime.width) / 2;
		anime.y = (background.height - anime.height) / 2 - 10;
		sprite.addChild(anime);
	}
	
	private function addTip():void {
		sprite.tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			};
		}
	}
	
	public function drawTitle():void {
		title = Window.drawText(String(App.data.storage[sID].title), {
			color:0x7b3a1c,
			borderColor:0xfbfdf0,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = background.width - 10;
		title.y = 10;
		title.x = 5;
		addChild(title);
	}
	
	public function drawCount():void {
		var countText:TextField = Window.drawText(String(count), {
			color:0xfbd21e,
			borderColor:0x714700,
			textAlign:"center",
			autoSize:"center",
			fontSize:32,
			textLeading:-6,
			multiline:true
		});
		countText.wordWrap = true;
		countText.width = background.width - 10;
		countText.y = background.height -40;
		countText.x = 5;
		addChild(countText);
	}
	
	public function dispose():void {
		if (parent) {
			parent.removeChild(this);
		}
	}
}
