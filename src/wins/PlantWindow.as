package wins 
{
	import buttons.Button;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class PlantWindow extends Window 
	{
		
		private var descText:TextField;
		private var growBttn:Button;
		
		public var items:Vector.<MaterialItem> = new Vector.<MaterialItem>;
		
		public const LEFT_MARGIN:int = 80;
		public const MATERIAL_MARGIN:int = 170;
		
		public function PlantWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['title'] = settings['title'] || '';
			settings['titleDecorate'] = false;
			settings['fontSize'] = 34;
			settings['shadowSize'] = 4;
			settings['shadowColor'] = 0x5a3d2f;
			settings['fontBorderColor'] = 0xac783c;
			settings['description'] = settings['description'] || Locale.__e('');
			settings['content'] = settings['content'] || [];
			settings['height'] = 370;
			settings['hasPaginator'] = false;
			settings['width'] = settings['width'] || (settings.content.length * MATERIAL_MARGIN + LEFT_MARGIN * 2);
			
			super(settings);
		}
		
		override public function drawBody():void {
			titleLabel.y = 0;
			
			descText = drawText(settings.description, {
				color:		0x542e0a,
				borderColor:0xfaeddd,
				fontSize:	21,
				textAlign:	'center',
				wrap:		true,
				multiline:	true,
				width:		settings.width - 60
			});
			descText.x = (settings.width - descText.width) / 2;
			descText.y = 20;
			bodyContainer.addChild(descText);
			
			growBttn = new Button( {
				width:		170,
				height:		50,
				caption:	Locale.__e('flash:1382952380090')
			});
			growBttn.x = (settings.width - growBttn.width) / 2;
			growBttn.y = settings.height - growBttn.height - 40;
			bodyContainer.addChild(growBttn);
			growBttn.addEventListener(MouseEvent.CLICK, onGrow);
			
			onStockChange();
			contentChange();
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
		}
		
		override public function contentChange():void {
			
			var array:Array = [];
			for each(var obj:Object in settings.content) {
				obj['order'] = App.data.storage[obj.sid].order
				array.push(obj);
			}
			array.sortOn('order', Array.NUMERIC);
			
			for (var i:int = 0; i < array.length; i++) {
				
				var item:MaterialItem = new MaterialItem( {
					sID:		array[i].sid,
					need:		array[i].need,
					window:		this,
					type:		MaterialItem.IN,
					backingRadius:	70,
					backingColor:	0xc8cabc
				});
				item.x = LEFT_MARGIN + i * MATERIAL_MARGIN;
				item.y = 75;
				
				items.push(item);
				bodyContainer.addChild(item);
			}
		}
		
		private function onGrow(e:MouseEvent):void {
			if (growBttn.mode == Button.DISABLED) return;
			
			if (settings.hasOwnProperty('callback') && (settings.callback is Function)) {
				settings.callback();
			}
			
			close();
		}
		
		private function onStockChange(e:AppEvent = null):void {
			var items:Object = { };
			for (var i:int = 0; i < settings.content.length; i++) {
				items[settings.content[i].sid] = settings.content[i].need;
			}
			
			if (App.user.stock.checkAll(items, true)) {
				growBttn.visible = true;
			}else {
				growBttn.visible = false;
			}
		}
		
		override public function dispose():void {
			growBttn.removeEventListener(MouseEvent.CLICK, onGrow);
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockChange);
			
			super.dispose();
		}
	}

}