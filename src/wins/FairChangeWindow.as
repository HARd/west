package wins 
{		
	import core.Numbers;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	public class FairChangeWindow extends Window
	{
		
		private var textLabel:TextField;
		public var onPageCount:int = 4;
		
		
		public function FairChangeWindow(settings:Object = null)
		{
			settings['width'] = settings.width || 620;
			settings['height'] = settings.height || 300;
			settings['hasArrows'] = true;
			settings['hasArrows'] = true;
			settings['itemsOnPage'] = 1;
			settings['hasButtons'] = false;
			settings['hasAnimations'] = false;
			settings['hasTitle'] = true;
			settings['faderAlpha'] = 0.6;
			settings['title'] = Locale.__e('flash:1417008887851');
			
			settings.content = initContent(settings);
			super(settings);
		}
		
		override public function drawBackground():void {
				
		}
		
		public function initContent(settings:Object):Array {
		
			var content:Array = [];
			for (var formID:* in settings.forms.req) {
				var reqObject:Object = settings.forms.req[formID];
				reqObject['id'] = formID;
				content.push(reqObject);
			}
			
			//level = settings.target.level - (settings.target.totalLevels -  settings.target.craftLevels);
			return content;
		}
		
		
		public var container:Sprite;
		override public function drawBody():void {
			container = new Sprite();
			bodyContainer.addChild(container);
			container.x = settings.width / 2;
			container.y = 210;
			
			paginator.itemsCount = settings.content.length - (onPageCount - 1);
			paginator.update();
			contentChange();
			
			textLabel = drawText(Locale.__e('flash:1417016386225'), {
				autoSize:		'center',
				textAlign:		'center',
				color:			0xfefffd,
				borderColor:	0x603604,
				fontSize:		28
			});
			textLabel.x = (settings.width - textLabel.width) / 2;
			textLabel.y = 240;
			bodyContainer.addChild(textLabel);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -46, true, true);
		}

		public var items:Array = [];
		private var ANGLE:Number = 8.5;
		override public function contentChange():void 
		{
			clear();
			
			var angle:Number = 5;
			var pos:int = 0;
			
			var X:int = 75;
			var Y:int = 0;
			
			for (var i:int = 0; i < onPageCount; i++) {
				var obj:Object = settings.content[i + paginator.page];
				
				var item:CastleIcon = new CastleIcon( {
					obj:			obj,
					title:			obj.n,
					//lock:			(target.views.indexOf(int(s)) == -1) ? false : true,
					onClick:		onIconClick,
					window:			this
				});
				items.push(item);
				container.addChild(item);
				
				item.x = 1100 * Math.sin((-((onPageCount - 1) * ANGLE / 2) + ANGLE * pos) * Math.PI / 180);
				item.y = 1000 - 1100 * Math.cos((-((onPageCount - 1) * ANGLE / 2) + ANGLE * pos) * Math.PI / 180);
				pos ++;
				//X += 150;
			}
			
			setFocusView(settings.target.view);
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.x -= 90;
			paginator.arrowRight.x += 90;
			paginator.arrowLeft.y += 30;
			paginator.arrowRight.y += 10;
			paginator.arrowLeft.rotation -= 15;
			paginator.arrowRight.rotation += 15;
		}
		
		private function onIconClick(e:MouseEvent):void {
			var item:CastleIcon = e.currentTarget as CastleIcon;
			
			new FairRecipeWindow( {
				title:item.params.obj.n +' '+Locale.__e('flash:1417001576768'),
				sID:item.id,
				requires:settings.forms.obj[item.id],
				openAction:onOpen,
				win:this,
				hasDescription:true,
				prodItem:item,
				target:settings.target
			}).show();
		}
		
		private function onOpen(id:int):void {
			setFocusView(id);
			settings.openAction(id);
			close();
		}
		
		public function setFocusView(id:*):void {
			for (var s:* in items) {
				if (items[s].id == id) {
					items[s].glow();
				}else {
					items[s].hide();
				}
			}
		}
		public function clear():void {
			while (items.length > 0) {
				var item:* = items.shift();
				container.removeChild(item);
				item.dispose();
			}
		}
		
	}	
}	
import core.Load;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import silin.filters.ColorAdjust;
import wins.Window;
		
internal class CastleIcon extends LayerX {
	
	public var id:*;
	private var titleLabel:TextField;
	private var lock:Bitmap;
	private var back:Bitmap;
	private var icon:Bitmap;
	private var preloader:Preloader;
	private var colorAdjust:ColorAdjust;
	
	public var params:Object = {
		scale:		1
	}
	
	public function CastleIcon (params:Object):void {
		
		if (params) {
			for (var s:* in params)
				this.params[s] = params[s];
		}
		
		id = params.obj.id;
		
		draw();
		
		this.scaleX = this.scaleY = this.params.scale;
	}
	
	
	public function draw():void 
	{
		colorAdjust = new ColorAdjust();
		this.filters = [colorAdjust.filter];
		
		back = new Bitmap(Window.textures.referalRoundBacking, 'auto', true);
		back.x = -back.width / 2;
		back.y = -back.height / 2;
		addChild(back);
		
		/*preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = this.params.scale;
		addChild(preloader);*/
		
		icon = new Bitmap();
		addChild(icon);
		Load.loading(Config.getIcon('Fair', params.obj.v), onLoad)
		
		lock = new Bitmap(Window.textures.lock, 'auto', true);
		lock.x = -lock.width / 2;
		lock.y = back.height / 2 - lock.height + 12;
		if (params['lock'] == false) {
			addChild(lock);
			
			/*var mtrx:ColorAdjust = new ColorAdjust();
			mtrx.saturation(0);
			icon.filters = [mtrx.filter];*/
		}
		
		titleLabel = Window.drawText(params.obj.n, {
			width:			back.width,
			textAlign:		'center',
			color:			0xfffef8,
			borderColor:	0x5a3200,
			fontSize:		25
		});
		titleLabel.x = -titleLabel.width / 2;
		titleLabel.y = -back.height / 2 - 10;
		addChild(titleLabel);
		//Load.loading(url, onLoad);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.ROLL_OVER, onOver);
		addEventListener(MouseEvent.ROLL_OUT, onOut);
	}
	
	private function onLoad(data:Bitmap):void {
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		icon.x = -icon.width / 2;
		icon.y = -icon.height / 2 + 10;
	}
	
	private function get url():String {
		return params.link || '';
	}
	
	private function onClick(e:MouseEvent):void {
		if (params.onClick != null)
			params.onClick(e);
	}
	private function onOver(e:MouseEvent):void {
		var mtrx:ColorAdjust = new ColorAdjust();
		mtrx.brightness(0.1);
		this.filters = [mtrx.filter];
	}
	private function onOut(e:MouseEvent):void {
		var mtrx:ColorAdjust = new ColorAdjust();
		mtrx.brightness(0);
		this.filters = [mtrx.filter];
	}
	
	public function glow():void {
		back.filters = [new GlowFilter(0xfff492, 1, 24, 24, 4)];
	}
	public function hide():void {
		back.filters = null;
	}
	
	public function onOpen():void {
		if (lock && !contains(lock))
			addChild(lock);
		
		/*var mtrx:ColorAdjust = new ColorAdjust();
		mtrx.saturation(1);
		icon.filters = [mtrx.filter];*/
		
		params.window.close();
	}
	
	public function dispose():void {
		removeEventListener(MouseEvent.CLICK, onClick);
		removeEventListener(MouseEvent.ROLL_OVER, onOver);
		removeEventListener(MouseEvent.ROLL_OUT, onOut);
	}
}	