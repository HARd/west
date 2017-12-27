package wins 
{
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class TravelPayWindow extends Window 
	{
		
		public var travelBttn:Button;
		public var container:Sprite;
		public var worldID:int = User.HOME_WORLD;
		
		private var descLabel:TextField;
		
		public function TravelPayWindow(settings:Object=null) 
		{
			
			if (!settings) settings = { };
			settings['width'] = 60;
			settings['height'] = 380;
			settings['hasPaginator'] = false;
			settings['popup'] = true;
			
			worldID = settings['worldID'] || User.HOME_WORLD;
			settings['title'] = App.data.storage[worldID].title || Locale.__e('flash:1418286565591');
			settings['content'] = settings['content'] || {};
			
			settings['width'] += Numbers.countProps(settings.content) * 160 + 60;
			if (settings['width'] < 500)
				settings['width'] = 500;
			
			super(settings);
			
		}
		
		override public function drawBody():void {
			
			exit.x -= 4;
			exit.y -= 6;
			
			/*var backing:Bitmap = Window.backing(settings.width - 60, 200, 40, 'storageBackingSmall');
			bodyContainer.addChild(backing);
			backing.x = (settings.width/2 - backing.width/2);
			backing.y = 80;*/
			
			/*drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -44, true, true);
			drawMirrowObjs('storageWoodenDec', 6, settings.width - 6, 48, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', 6, settings.width - 6, settings.height - 88, false, false, true, 1, 1);*/
			
			descLabel = drawText(Locale.__e('flash:1418285724686'), {
				fontSize:28,
				color:0xffffff,
				borderColor:0x623518,
				autoSize:"center",
				textAlign:'center',
				multiline:true
			});
			descLabel.wordWrap = true;
			descLabel.width = (settings.width - 40 > 100) ? (settings.width - 40) : 100;
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 10;
			bodyContainer.addChild(descLabel);
			
			travelBttn = new Button( {
				width:		180,
				height:		48,
				caption:	Locale.__e('flash:1382952380219')
			});
			travelBttn.x  = (settings.width - travelBttn.width) / 2;
			travelBttn.y = settings.height - 90;
			bodyContainer.addChild(travelBttn);
			travelBttn.addEventListener(MouseEvent.CLICK, onTravel);
			onUpdateOutMaterial();
			
			container = new Sprite();
			bodyContainer.addChild(container);
			
			contentChange();
		}
		
		override public function contentChange():void {
			
			for (var s:* in settings.content) {
				var inItem:MaterialItem = new MaterialItem({
					sID:int(s),
					need:settings.content[s],
					window:this, 
					type:MaterialItem.IN,
					color:0x5a291c,
					borderColor:0xfaf9ec,
					bitmapDY: 0,
					bgItemY:38,
					bgItemX:20,
					backingColor:0xbbbbbb
				});
				
				inItem.x = container.numChildren * (inItem.background.width - 30);
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				container.addChild(inItem);
			}
			
			container.x = (settings.width - container.width) / 2;
			container.y = descLabel.y + descLabel.height + 25;
		}
		
		public function onUpdateOutMaterial(e:WindowEvent = null):void {
			if (App.user.stock.checkAll(settings.content)) {
				travelBttn.visible = true;
			}else {
				travelBttn.visible = false;
			}
		}
		
		public function onTravel(e:MouseEvent):void {
			if (App.user.stock.checkAll(settings.content)) {
				App.user.stock.takeAll(settings.content);
				
				Travel.goTo(worldID);
				
				if (settings['window']) settings.window.close();
				close();
			}
		}
		
		override public function dispose():void {
			travelBttn.removeEventListener(MouseEvent.CLICK, onTravel);
			travelBttn.dispose();
			
			super.dispose();
		}
	}

}