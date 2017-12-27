package wins.elements 
{
	import buttons.Button;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import silin.filters.ColorAdjust;
	import ui.UserInterface;
	import wins.Window;
	
	public class WorldItem extends LayerX 
	{
		private var container:Sprite;
		public var bg:Bitmap;
		public var bitmap:Bitmap;
		private var underTxt:Bitmap;
		private var title:TextField;
		
		public var sID:*;
		public var window:*;
		public var info:Object;
		public var scale:Number = 0;
		private var preloader:Preloader;
		
		public var available:Boolean = true;
		
		public var params:Object = {
			hasBacking:	true,
			hasTitle:	true,
			scale:		0.6,
			fontSize:	22,
			align:		'none',
			hasTitle:	true,
			jump:		true,
			info:		'',
			closed:		true,
			clickable:	true
		}
		
		public function WorldItem(params:Object) 
		{
			for (var s:String in params)
				this.params[s] = params[s];
			
			sID = this.params.sID;
			window = this.params.window;
			scale = this.params.scale;
			
			if (!App.data.storage.hasOwnProperty(sID)) return;
			
			draw();
		}
		
		public function draw():void {
			
			info = App.data.storage[sID];
			this.params.info = info.title;
			
			container = new Sprite();
			addChild(container);
			
			bg = new Bitmap(Window.textures.referalRoundBacking, 'auto', true);
			bg.scaleX = bg.scaleY = scale;
			bg.visible = this.params.hasBacking;
			container.addChild(bg);
			bg.visible = false;
			
			if (this.params.align == 'center') {
				bg.x = -bg.width / 2;
				bg.y = -bg.height / 2;
			}
			
			preloader = new Preloader();
			preloader.scaleX = preloader.scaleY = 0.5;
			preloader.x = bg.x + bg.width / 2;
			preloader.y = bg.y + bg.height / 2;
			addChild(preloader);
			
			bitmap = new Bitmap();
			container.addChild(bitmap);
			Load.loading(link, onLoad);
			
			if (!this.params.clickable) alpha = 0.5;
			if (this.params.hasTitle) drawDesc();
			
			container.addEventListener(MouseEvent.CLICK, onClick);
			container.addEventListener(MouseEvent.ROLL_OVER, onOver);
			container.addEventListener(MouseEvent.ROLL_OUT, onOut);
			
			tip = function():Object {
				return {
					title:info.title
				}
			}
		}
		
		public function get link():String {
			if (params.hasOwnProperty('link') && params.link.length > 0) {
				return params.link;
			}
			
			return Config.getIcon(info.type, info.preview);
		}
		
		public function onClick(e:MouseEvent = null):void {
			if (params.clickable == false) return;
			
			if (params.jump) jump();
			
			if (App.user.mode == User.OWNER && sID != App.map.id && App.user.worlds.hasOwnProperty(sID)) {
				Travel.goTo(sID);
			}else if (App.user.mode == User.GUEST) {
				Travel.friend = Travel.currentFriend;
				Travel.onVisitEvent(sID);
			}
			
			if (window && window.hasOwnProperty('closeAll') && window.closeAll != null) window.closeAll();
		}
		private function onOver(e:MouseEvent):void {
			if (available) effect(0.1);
		}
		private function onOut(e:MouseEvent):void {
			if (available) effect();
		}
		public function effect(count:Number = 0, saturation:Number = 1):void {
			var mtrx:ColorAdjust;
			mtrx = new ColorAdjust();
			mtrx.saturation(saturation);
			mtrx.brightness(count);
			this.filters = [mtrx.filter];
		}
		
		public function onLoad(data:Bitmap):void {
			if (preloader && contains(preloader)) removeChild(preloader);
			
			//bitmap.scaleX = bitmap.scaleY = scale * 0.98;
			bitmap.bitmapData = data.bitmapData;
			bitmap.smoothing = true;
			bitmap.x = bg.x + (bg.width - bitmap.width) / 2;//20 * scale;
			bitmap.y = bg.y + (bg.height - bitmap.height) / 2;//16 * scale;
		}
		
		private function drawDesc(descParams:Object = null):void {
			
			if (!descParams) descParams = { };
			descParams['backingWidth'] = descParams['backingWidth'] || 160;
			
			underTxt = Window.backingShort(descParams.backingWidth, 'nameLocBacking');
			underTxt.smoothing = true;
			underTxt.x = (bg.width - underTxt.width) / 2;
			underTxt.y = bg.height - underTxt.height + 10;
			addChild(underTxt);
			
			title = Window.drawText(params.info, {
				fontSize:params.fontSize,
				color:0xf6fff8,
				borderColor:0x7e4f35,
				multiline:true,
				textAlign:"center",
				width:bg.width
			});
			
			addChild(title);
			title.x = underTxt.x + (underTxt.width - title.width) / 2;
			title.y = underTxt.y + (underTxt.height - title.textHeight) / 2 - 3;
		}
		
		public function jump():void {
			var item:WorldItem = this;
			TweenLite.to(item, 0.4, { scaleX:1.1, scaleY:1.1, ease:Cubic.easeOut, onComplete:function():void {
				TweenLite.to(item, 0.4, { scaleX:1, scaleY:1, ease:Bounce.easeOut } );
			}} );
		}
		
		public function dispose():void {
			if (container) {
				container.removeEventListener(MouseEvent.CLICK, onClick);
				container.removeEventListener(MouseEvent.ROLL_OVER, onOver);
				container.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			}
			
			if (parent) parent.removeChild(this);
		}	
		
	}

}