package wins
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author 
	 */
	public class BonusList extends Sprite 
	{
		public var bonus:Object;
		public var settings:Object = {
			hasTitle:true,
			titleText:Locale.__e("flash:1382952380000"),
			background:'upgradeSmallBacking',
			backingShort:false,
			titleX:10,
			titleY:15,
			bgX:0,
			bgY:0,
			bgAlpha:1,
			titleColor:0xFFFFFF,
			titleBorderColor:0x4b390f,
			size:40,
			width: 0,
			shadowColor:0x5c371a,
			shadowSize:0
		}
		
		public function BonusList(bonus:Object, hasBacking:Boolean = true, _settings:Object = null, backingWidth:int = 0)
		{
			var bonusCont:Sprite = new Sprite();
			if (_settings != null) {
				for (var _item:String in _settings)
					this.settings[_item] = _settings[_item];
			}
			
			var X:int = 0;
			if(settings.hasTitle){
				var title:TextField = Window.drawText(
					settings.titleText, 
					{
						fontSize	:32,
						color		:settings.titleColor,//0xFFFFFF,//0x564c45,
						borderColor	:settings.titleBorderColor,//0x252a38,//0xf9f2dd,
						shadowColor	:settings.shadowColor,
						shadowSize	:settings.shadowSize,
						autoSize	:"left"
					}
				);
				
				title.x = settings.titleX + 10;
				title.y = settings.titleY;
				bonusCont.addChild(title);
				X = title.x + title.textWidth + 15;
			}
			
			for (var sID:* in bonus)
			{
				var item:InternalBonusItem = new InternalBonusItem(sID, bonus[sID], settings.size, settings);
				bonusCont.addChild(item);
				item.x = X;
				item.y = 0;
				X += item.text.textWidth + 50;
			}
			
			if (backingWidth > 0) {
				X = backingWidth;
			}
			
			var bg:Bitmap;
			if (!settings.backingShort) {
				bg = Window.backing(X, 65, 12, settings.background);
			}else {
				bg = Window.backingShort(X, settings.background);
			}
			
			if(hasBacking){
				bg.x = settings.bgX;
				bg.y = settings.bgY;
				bg.alpha = settings.bgAlpha;
				bg.smoothing = true;
				addChildAt(bg, 0);
			}
			
			bonusCont.x = bg.width / 2 - bonusCont.width / 2 - 20;
			addChild(bonusCont);
		}
		
		public function take():void{
			var childs:int = numChildren;
			
			while(childs--) {
				if(getChildAt(childs) is InternalBonusItem){
					var reward:InternalBonusItem = getChildAt(childs) as InternalBonusItem ;
								
					var item:BonusItem = new BonusItem(reward.sID, reward.count);
				
					var point:Point = Window.localToGlobal(reward);
					item.cashMove(point, App.self.windowContainer);
				}
			}
		}
	}
}

import core.Load;
import flash.display.Bitmap;
import flash.text.TextField;
import wins.Window;

internal class InternalBonusItem extends LayerX
{
	private var icon:Bitmap;
	public var text:TextField;
	public var sID:uint;
	public var count:int;
	public var size:Number;
	
	public var settings:Object = {
			bonusTextColor:0xFFFFFF,
			bonusBorderColor:0x4b390f
		}
	
	public function InternalBonusItem(sID:uint, count:int, size:Number, _settings:Object = null)
	{
		if (_settings != null) {
				for (var _item:String in _settings)
					this.settings[_item] = _settings[_item];
		}
		
		this.size = size;
		icon = new Bitmap();
		if (sID == 343) sID = 5;
		this.sID = sID;
		this.count = count;
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
		
		text = Window.drawText(String(count),
				{
					fontSize	:28,
					color		:0xf9ffff,
					borderColor	:0x53310c,
					borderSize  :4,
					autoSize	:"left"
				}
			);
			
		text.height = text.textHeight;
		text.x = 35;
		text.y = 60/2 - text.textHeight/2 + 6;
		
		addChild(icon);
		addChild(text);
		
		if (count == 0)
			text.visible = false;
			
		tip = function():Object {
			return {
				title:App.data.storage[this.sID].title,
				text:App.data.storage[this.sID].description
			}
		}
	}
	
	private function onLoad(data:Bitmap):void
	{
		icon.bitmapData = data.bitmapData;
		var scale:Number = size / icon.height;
		icon.scaleX = icon.scaleY = scale;
		icon.y = 60 / 2 - icon.height / 2 + 3;
		icon.smoothing = true;
		//text.x = icon.width+5;
	}
}