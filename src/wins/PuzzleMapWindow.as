package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ui.UserInterface;
	public class PuzzleMapWindow extends Window 
	{
		public static const MAP_PART_1:uint = 587;
		public static const MAP_PART_2:uint = 588;
		public static const MAP_PART_3:uint = 589;
		
		private static var amuletArr:Array = [MAP_PART_1, MAP_PART_2, MAP_PART_3]
		private var posArr:Array = [ { x: 0 + 83, y: 152 }, { x: 313 + 83, y: 0 }, { x: 0 + 83, y: 0 } ]
		
		private var searchBttn:ImageButton;
		
		public static function checkAmuletPart(part:uint):Boolean
		{
			for (var i:int = 0; i < amuletArr.length; i++) 
			{
				if (amuletArr[i] == part)
				return true;
			}
			return false;
		}
		
		public function PuzzleMapWindow(settings:Object=null) 
		{
			if (settings == null)
			{
				settings = new Object();
			}
			
			settings['width'] = 740;
			settings['height'] = 600;
			settings["find"] = settings.find || false;
			settings['hasPaginator'] = false;
			settings['title'] = Locale.__e('flash:1435667376071');
			
			super(settings);			
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing2(settings.width, settings.height, 50, 'shopBackingTop', 'shopBackingBotWithRope');
			background.y = -15;
			layer.addChild(background);		
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,	
				shadowColor			: settings.shadowColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true,
				shadowSize			:4
			});
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -35;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			//headerContainer.y = 37;
			headerContainer.mouseEnabled = false;
		}
		
		private var goBttn:Button;
		override public function drawBody():void
		{
			exit.x += 10;
			exit.y -= 15;
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, drawMap);
			drawMap();
		}
		
		private function showHelp(e:MouseEvent):void
		{
			new SimpleWindow( {
				title: Locale.__e('flash:1396961967928'), 
				text: Locale.__e('flash:1435677373405'), 
				popup: true,
				offsetY: -100,
				height: 350
			}).show();
		}
		
		private var backItems:Array;
		private var missionsCount:TextField;
		private var bitmap:Bitmap = new Bitmap();		
		private function drawMap(e:AppEvent = null):void
		{
			var text:TextField = Window.drawText(Locale.__e('flash:1435667767947'), {
				fontSize: 28,
				color: 0xfbf9e2,
				borderColor: 0x672e13
			});
			missionsCount = Window.drawText(String(0) + "/" + String(amuletArr.length), {color: 0xffe760, borderColor: 0x7b4003, textAlign: "center", autoSize: "left", fontSize: 36});
			
			var countExistElements:uint = 0;
			for each (var itm:PuzzleBackItem in backItems)
			{
				if (itm.parent)
					itm.parent.removeChild(itm);
				itm.dispose();
				itm = null;
			}
			backItems = [];
			
			Load.loading(Config.getImage('map', 'PuzzleMapFull'), function(data:*):void
			{
				bitmap.bitmapData = data.bitmapData;
				//bitmap.y -= 41;
				bitmap.x = (settings.width - bitmap.width) / 2;
			});
			bodyContainer.addChild(bitmap);
			for (var i:int = 0; i < amuletArr.length; i++)
			{
				if (!App.user.stock.check(amuletArr[i]))
				{
					var item:PuzzleBackItem = new PuzzleBackItem({id: i, pos: posArr[i]}, this)
					backItems.push(item);
					bodyContainer.addChild(item);
				}
				else
				{
					countExistElements++;
				}
			}
			
			if (settings.find) {
				var p:int = 0;
				for (var it:* in amuletArr) {
					if (amuletArr[it] == settings.find) {
						p = it;
					}
				}
				var puzzleitem:PuzzleBackItem = new PuzzleBackItem({id: p, pos: posArr[p], find:settings.find}, this)
				backItems.push(puzzleitem);
				bodyContainer.addChild(puzzleitem);
			}
			bodyContainer.addChild(text);
			bodyContainer.addChild(missionsCount);
			
			text.x = settings.width - 380;
			text.y = 15;
			
			missionsCount.text = String(countExistElements) + "/" + String(amuletArr.length);
			missionsCount.x = text.x + text.textWidth + 5;
			missionsCount.y = 13;
			
			searchBttn = new ImageButton(UserInterface.textures.lens);
			bodyContainer.addChild(searchBttn);
			searchBttn.x = missionsCount.x + missionsCount.textWidth + 20;
			searchBttn.y = missionsCount.y;
			searchBttn.addEventListener(MouseEvent.CLICK, showHelp);
			
			goBttn = new Button( {
				width:185,
				height:62,
				fontSize:36,
				hasDotes:false,
				caption:Locale.__e("flash:1394010224398")
			});
			
			
			bodyContainer.addChild(goBttn);			
			goBttn.addEventListener(MouseEvent.CLICK, close);
			goBttn.x = (settings.width - goBttn.width) / 2;
			goBttn.y = settings.height - goBttn.height - 40;
			
			if (countExistElements < amuletArr.length) {
				goBttn.visible = false;
			} else {
				goBttn.visible = true;
			}
		}
		
		private var items:Array;
		private function drawAmuletItems():void
		{
			items = [];
			for (var i:int = 0; i < amuletArr.length; i++)
			{
				if (App.user.stock.check(amuletArr[i]))
				{
					
					var item:PuzzleItem = new PuzzleItem( { id: i, pos: posArr[i] }, this);
					items.push(item);
					bodyContainer.addChild(item);
				}
			}
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, drawMap);
			if (bitmap)
				bodyContainer.removeChild(bitmap);
			bitmap = null;
			super.dispose();
		}
		
	}

}
import buttons.Button;
import com.greensock.TweenMax;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import wins.PuzzleMapWindow;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;

internal class PuzzleItem extends Sprite
{
	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:Button;
	private var _parent:*;
	private var preloader:Preloader = new Preloader();	
	
	public function PuzzleItem(item:Object, parent:PuzzleMapWindow)
	{
		
		this._parent = parent;
		this.item = item;
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		addChild(preloader);
		preloader.x = item.pos.x;
		preloader.y = item.pos.y;
		preloader.scaleX = preloader.scaleY = 0.67;
		
		Load.loading(Config.getImage('map', 'PuzzleMapPiece' + (item.id + 1)), function(data:*):void
			{
				if (preloader)
				{
					removeChild(preloader)
					preloader = null
				}
				
				bitmap.bitmapData = data.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = item.pos.x;
				bitmap.y = item.pos.y;
			
			})
	
	}
	
	public function dispose():void
	{
		
	}

}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;

internal class PuzzleBackItem extends Sprite
{
	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:Button;
	private var _parent:*;
	private var preloader:Preloader = new Preloader();
	
	public function PuzzleBackItem(item:Object, parent:PuzzleMapWindow)
	{
		
		this._parent = parent;
		this.item = item;
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		addChild(preloader);
		preloader.x = item.pos.x;
		preloader.y = item.pos.y;
		preloader.scaleX = preloader.scaleY = 0.67;
		
		Load.loading(Config.getImage('map', 'PuzzleMapPiece' + (item.id + 1)), function(data:*):void
		{
			if (preloader)
			{
				removeChild(preloader)
				preloader = null
			}
			
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = item.pos.x;
			bitmap.y = item.pos.y;
			
			if (item.find) {
				TweenMax.to(bitmap, 3, { alpha:0, onComplete:dispose } );
			}
		})	
	}
	
	public function dispose():void
	{
		if (bitmap && bitmap.parent)
			bitmap.parent.removeChild(bitmap);
		bitmap = null;
	
	}

}