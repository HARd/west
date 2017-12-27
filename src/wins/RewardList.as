package wins
{
	import adobe.utils.CustomActions;
	import api.com.adobe.utils.IntUtil;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import units.Factory;
	import units.Techno;
	import units.Unit;
	import units.WorkerUnit;
	
	/**
	 * ...
	 * @author 
	 */
	public class RewardList extends Sprite 
	{
		public var bonus:Object;
		
		private var itemsSprite:Sprite = new Sprite();
		private  var marginX:int = 90;
		private var bg:Bitmap;
		private var bgAlpha:Number;
		private var arrItems:Array = [];
		private var numItems:int = 0;
		
		public function RewardList(bonus:Object, hasBacking:Boolean = true, widthBacking:int = 0, text:String = "Награда:", _alpha:Number = 1, _fontSze:int = 44, _titleY:int = 16, itemTxtSize:int = 56, preTxtItem:String = "", itemScale:Number = 0.74, marginItemTxtX:int = 0, marginItemTxtY:int = 0, hasBackingItem:Boolean = true, textIsRight:Boolean = false)
		{
			bgAlpha = _alpha;
			
			var title:TextField = Window.drawText(
				Locale.__e(text), 
				{
					fontSize	:_fontSze,
					color		:0xffda72,
					border		:true,
					borderSize	:2,
					borderColor	:0x613719,
					autoSize	:"left",
					shadowSize	:2,
					shadowColor	:0x623a17
				}
			);
			for (var itm:* in bonus)
			{
				numItems++;
			}
			
			bg = Window.backing2(widthBacking + 30, 100, 45, "alertBacking", "alertBacking");
			bg.alpha = 0.5;
			if(hasBacking){
				addChildAt(bg, 0);
				bg.y = title.height + 10;
			}
			
			var i:int = 0;
			
			for (var sID:* in bonus)
			{
				var item:RewardItem = new RewardItem(sID, bonus[sID], setPosItems, itemTxtSize, preTxtItem, itemScale, marginItemTxtX, marginItemTxtY, hasBackingItem, textIsRight);
				itemsSprite.addChild(item);
				item.scaleX = item.scaleY = 0.7;
				//item.x = (prevWidth) + xPos;
				//prevWidth = 60 + item.text.textWidth + 8;
				//xPos = item.x;
				i++;
				arrItems.push(item);
			}
			
			
			if (widthBacking == 0) {
				widthBacking = 10 + 100 * i;
			}
			
			addChild(itemsSprite);
			
			if(itemsSprite.height < 100) {
				itemsSprite.y = bg.y + (bg.height - itemsSprite.height) / 2;
			} else {
				itemsSprite.y = 15;
			}
				
			title.x = (bg.width - title.width)/2;
			title.y = _titleY;
			addChild(title);
		}
		
		private var counter:int = 0;
		private function setPosItems():void 
		{
			counter += 1;
			if (counter < numItems) return;
			
			if (counter > arrItems.length) {
				counter -= 1;
				setTimeout(setPosItems, 100);
				return;
			}
			
			var xPos:int = 0;
			var prevWidth:int = 0;
			for (var i:int = 0; i < arrItems.length; i++ )
			{
				arrItems[i].x = (prevWidth) + xPos;
				prevWidth = arrItems[i].width + 8;
				xPos = arrItems[i].x;
			}
			itemsSprite.x = (bg.width - itemsSprite.width) / 2;
		}
		
		public function take():void{
			var childs:int = itemsSprite.numChildren;
			
			//while (childs--) {
			for (var i:int = 0; i < arrItems.length; i++ ) {
				
				var reward:RewardItem = arrItems[i];//itemsSprite.getChildAt(childs) as RewardItem;
				
				/*if (App.data.storage[reward.sID].type == 'Animal' && App.user.stock.check(reward.sID, reward.count)) {
					var rel:Object = { };
					rel[reward.sID] = reward.sID;
					for (var j:int = 0; j < reward.count; j++ ) {
						var position:Object = App.map.heroPosition;
							var unit:Unit = Unit.add( { sid:reward.sID, id:0, x:position.x, z:position.z, rel:rel } );
								(unit as WorkerUnit).born();
								
							unit.stockAction( { sid:reward.sID } );
					}
				}else*/{
					var item:BonusItem = new BonusItem(reward.sID, reward.count);
					var point:Point = Window.localToGlobal(reward);
					item.cashMove(point, App.self.windowContainer);
				}
			}
		}
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class RewardItem extends LayerX
{
	private var icon:Bitmap;
	public var text:TextField;
	public var sID:uint;
	public var count:int;
	public var bg:Bitmap;
	
	//public var sprTip:LayerX = new LayerX();
	
	private var callBack:Function;
	
	private var iconScale:Number;
	private var marginTxtX:int;
	private var marginTxtY:int;
	private var hasBackingItem:Boolean;
	private var textIsRight:Boolean;
	
	public function RewardItem(sID:uint, count:int, _callBack:Function, _size:int = 56, _preText:String = "", iconScale:Number = 0.74, marginTxtX:int = 0, marginTxtY:int = 0, hasBackingItem:Boolean = true, textIsRight:Boolean = false)
	{
		this.marginTxtX = marginTxtX;
		this.marginTxtY = marginTxtY;
		this.iconScale = iconScale;
		this.textIsRight = textIsRight;
		
		this.hasBackingItem = hasBackingItem;
		
		icon = new Bitmap();
		this.sID = sID;
		this.count = count;
		callBack = _callBack;
		
		bg = Window.backing(90, 90, 12, "bonusBacking");
		addChild(bg);
		bg.visible = false;
		
		text = Window.drawText(_preText + String(count),{
			fontSize:_size,
			color	:0xffffff,
			borderColor	:0x754108,
			shadowSize	:1,
			shadowColor	:0x754108,
			autoSize:"left"
		});
			
		text.height = text.textHeight;
		text.width = text.textWidth;
			
		/*if (contains(sprTip)) {
			removeChild(sprTip);
			sprTip = new LayerX();
		}*/
		
		
		//sprTip.addChild(icon);
		//addChild(sprTip);
		
		/*sprTip.tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].text
			}
		}*/
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
		
		text.visible = false;
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad)
	}
	
	private function onLoad(data:Bitmap):void
	{	
		var background:Bitmap;
		background = new Bitmap(new BitmapData(120, 120, true, 0xffffff));
		background.x = 0;
		background.y = 70;
		
		if(hasBackingItem) {
			addChild(background);
		}
		
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xc7c9bb, 1);
		shape.graphics.drawCircle(60, 60, 60);
		shape.graphics.endFill();
		background.bitmapData.draw(shape);
		
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		Size.size(icon, 100, 100);
		//if (sID == 752) iconScale = 0.3;
		icon.scaleX = icon.scaleY = iconScale;

		icon.x = (bg.width - icon.width) / 2 + 15;
		icon.y = (bg.height - icon.height) / 2 + 75;
		
		text.x = (bg.width - text.width) / 2 + 12;
		text.y = bg.height + 75;
		
		if (textIsRight)
		{
			icon.x = 0;
			icon.y = (bg.height - icon.height) / 2;
		
			text.y = (bg.height - text.height) / 2 + marginTxtY;
			text.x = icon.x + icon.width + 8 + marginTxtX;
		}
		
		text.visible = true;
		
		addChild(icon);
		addChild(text);
		
		callBack();
	}
}