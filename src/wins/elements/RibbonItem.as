package wins.elements 
{
	import api.ExternalApi;
	import buttons.Button;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Cursor;
	import ui.Hints;
	import ui.UserInterface;
	import units.Factory;
	import units.Field;
	import units.Sphere;
	import units.Techno;
	import units.Unit;
	import wins.actions.BanksWindow;
	import wins.elements.PriceLabel;
	import wins.HeroWindow;
	import wins.SimpleWindow;
	import wins.Window;

	public class RibbonItem extends LayerX {
		
		public var background:Bitmap;
		public var title:TextField;
		public var description:TextField;
		
		private var settings:Object = {
			title:'Header',
			icons:true,
			decorated:true,
			sale:false
		}
		
		private var ribbonPars:Object = {
			'gold':{height:90},
			'pink':{height:90}
		};
		
		public static var titleParams:Object = {
				fontSize			: 48,
				autoSize			: "center",
				textAlign			: "center",
				color				: 0xffffff,
				borderSize			: 4,
				borderColor			: 0xc4964e,
				shadowSize			: 4,
				shadowColor			: 0x503f33
		};
		
		public static var descriptionParams:Object = {
				fontSize			: 28,
				autoSize			: "center",
				textAlign			: "center",
				color				: 0xf7efbc,
				borderSize			: 2,
				borderColor			: 0x854115,
				shadowSize			: 2,
				shadowColor			: 0x854115
		};
		
		public function RibbonItem(_settings:Object = null) {
			for (var prop:* in _settings) {
				this.settings[prop] = _settings[prop];
			}
			drawBody();
		}
		
		public function drawBody():void {
			drawBackground();			
			drawTitle();
			if(settings.decorated)
			drawDecorations();
		}
		
		public function drawDecorations():void {
			
			var textureName:String = 'titleDecRose';
			var decWd:* =  Window.textures[textureName];
			var tempCont:Sprite = new Sprite();
			Window.addMirrowObjs(tempCont, textureName, title.x - decWd.width + 23, title.x + title.width + decWd.width - 20, title.y + (title.height - decWd.height) / 2 + 5);
			addChild(tempCont);
			swapChildren(title, tempCont);
		}
		
		public function drawTitle():void {
			title = Window.drawText(settings.title, titleParams);
			title.width = title.textWidth + 5;
			title.height = title.textHeight + 5;
			title.x = background.x + (background.width - title.width) / 2;
			title.y = (90 - title.height)/2 + 10;
			addChild(title);
			if (settings.hasDescription) {
				title.y = (90 - title.height) / 2 - 35;
				drawDescription();
			}
		}
		
		public function drawDescription():void {
			description = Window.drawText(settings.description, descriptionParams);
			description.width = description.textWidth + 5;
			description.height = description.textHeight + 5;
			
			description.x = background.x + (background.width - description.width) / 2;
			description.y = (90 - title.height)/2 + 20;
			addChild(description);
		}
		
		public function drawBackground():void {
			var rWd:int = Window.textures.ribbonYellow.width/2;
			background = Window.backingShort(settings.width+2*rWd, 'ribbonYellow');
			background.x = -rWd;
			addChild(background);
		}
	}
}