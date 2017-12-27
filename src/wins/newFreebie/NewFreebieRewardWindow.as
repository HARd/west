package wins.newFreebie 
{
	import flash.display.Bitmap;
	import wins.Window;
	
	/**
	 * ...
	 * @author ...
	 */
	public class NewFreebieRewardWindow extends Window 
	{
		private var _boyntyData:BountyForLevel;
		
		private var _itemsBG:Bitmap;
		
		private var _dataProvider:Array;
		private var _items:Vector.<BountyItem>;
		
		public function NewFreebieRewardWindow(bountyData:BountyForLevel, settings:Object=null) 
		{
			settings["itemsOnPage"] = 5;
			settings["width"] = 640;
			settings["height"] = 605;
			settings["background"] = "alertBacking";
			settings["title"] = Locale.__e("flash:1458918152235");
			
			super(settings);
			
			_boyntyData = bountyData;
			
			initContent();
		}
		
		override public function drawBody():void 
		{
			super.drawBody();
			
			Window.addMirrowObjs(bodyContainer, "upgradeDec", -5, settings.width + 5, 40, false, false, false, 1, -1);
			Window.addMirrowObjs(bodyContainer, "upgradeDec", -5, settings.width + 5, settings.height - 100, false, false, false, 1, 1);
			Window.addMirrowObjs(bodyContainer, "upgradeDec", settings.width * .5 - 220, settings.width * .5 + 220, -45);
			
			//_itemsBG = backing(580, 540, 50, "shopBackingSmall2");
			//_itemsBG.x = (settings.width - _itemsBG.width) * .5;
			//_itemsBG.y = (settings.height - _itemsBG.height) * .5 - 35;
			//bodyContainer.addChild(_itemsBG);
			
			contentChange();
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			exit.y -= 25;
		}
		
		override public function drawArrows():void 
		{
			super.drawArrows();
			
			paginator.arrowLeft.x -= 40;
			paginator.arrowLeft.y = (settings.height - paginator.arrowLeft.height) * .5;
			
			paginator.arrowRight.x += 40;
			paginator.arrowRight.y = (settings.height - paginator.arrowRight.height) * .5;
		}
		
		override public function createPaginator():void 
		{
			super.createPaginator();
			paginator.itemsCount = _dataProvider.length;
			paginator.visible = !(paginator.itemsCount <= paginator.onPageCount);
		}
		
		
		private function initContent():void
		{
			if (!_dataProvider)
				_dataProvider = [];
				
			for (var key:String in _boyntyData.itemsForUsers)
			{
				_dataProvider.push( { numUsers:int(key), data:_boyntyData.itemsForUsers[key] } );
			}
			
			_dataProvider.sortOn("numUsers", Array.NUMERIC);
		}
		
		
		override public function contentChange():void 
		{
			if (!_items)
			{
				_items = new Vector.<BountyItem>();
			}
			else
			{
				var numItems:int = _items.length;
				var currentItem:BountyItem;
				for (var i:int = 0; i < numItems; i++) 
				{
					currentItem = _items.shift();
					
					if (bodyContainer.contains(currentItem))
						bodyContainer.removeChild(currentItem);
					
					currentItem.dispose();
					currentItem = null;
				}
			}
			
			var startX:int = 47.5;
			var startY:int = 10;
			
			var dY:int = 4;
			
			var startIndex:int = paginator.startCount;
			var endIndex:int = (_dataProvider.length > startIndex + paginator.onPageCount) ? (startIndex + paginator.onPageCount) : (_dataProvider.length - 1);			
			var k:int = 1;
			
			for (var j:int = startIndex; j <= endIndex; j++) 
			{
				currentItem = new BountyItem(_boyntyData.sid, _boyntyData.level, _dataProvider[j].numUsers, _boyntyData.itemsForUsers[_dataProvider[j].numUsers], k);
				currentItem.x = startX;
				currentItem.y = startY + (currentItem.height + dY) * _items.length;
				bodyContainer.addChild(currentItem);
				_items.push(currentItem);
				
				k++;
			}
		}	
	}
}
import buttons.Button;
import com.adobe.images.BitString;
import core.Load;
import core.Numbers;
import core.Post;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import silin.filters.ColorAdjust;
import wins.Window;
import wins.newFreebie.NewFreebieModel;

internal class BountyItem extends LayerX
{
	private static const WIDTH:int = 545;
	private static const HEIGHT:int = 100;
	
	private var _bgContainer:Sprite;
	private var _bg:Bitmap;
	
	private var _title:TextField
	private var _title2:TextField;  //flash:1453737306722
	
	private var _targetLevel:int;
	private var _numFriends:int;
	private var _sid:String;
	
	private var _applyBttn:Button;
	
	private var _checkmarkContainer:Sprite;
	
	private var _checkmark:Bitmap;
	private var _checkmarkSlot:Bitmap;
	
	private var _itemsBG:Sprite;
	
	private var _itemsData:Object;
	
	public function BountyItem(sid:String, targetLevel:int = 0, numFriends:int = 0, itemsData:Object = null, index:int = 2)
	{
		_sid = sid;
		_targetLevel = targetLevel;
		_numFriends = numFriends;
		_itemsData = itemsData;
		
		_bgContainer = new Sprite();
		addChild(_bgContainer);
		
		var backingName:String = "itemBacking";		
		_bg = Window.backing(WIDTH, HEIGHT, 30, backingName);
		_bgContainer.addChild(_bg);
		_bg.visible = false;
		
		if (index % 2 != 0) {
			var whiteBg:Bitmap = Window.backing(this.width, this.height, 50, 'fadeOutWhite');
			whiteBg.alpha = 0.4;
			addChild(whiteBg);
		}
		
		_title = Window.drawText(Locale.__e("flash:1458918197268", Number(_numFriends)), {
			width:190,
			fontSize:22,
			color:0x8A4830,
			borderColor:0xFFFDF3,
			textAlign:"center"
		});
		
		_title.x = 15;
		_title.y = (height - _title.textHeight) * 0.5 - 15;
		addChild(_title);
		
		
		var text:String;
		if (_numFriends == 1)
			text = Locale.__e("flash:1458918221100", [String(targetLevel)]);
		else
			text = Locale.__e("flash:1458918234164", [String(targetLevel)]);
		
		_title2 = Window.drawText(text, {
			width:190,
			fontSize:22,
			color:0xFFFDF3,
			borderColor:0x8A4830,
			textAlign:"center"
		});
		
		_title2.x = 15;
		_title2.y = (height - _title2.textHeight) * 0.5 + 10;
		addChild(_title2);
		
		drawItems();
		
		_applyBttn = new Button( { 
			width:120,
			height:45,
			caption:Locale.__e("flash:1382952379737")
		} );
		_applyBttn.x = width - _applyBttn.width - 20;
		_applyBttn.y = (height - _applyBttn.height) * .5;
		_applyBttn.addEventListener(MouseEvent.CLICK, onApplyBttnClick);
		addChild(_applyBttn);
		
		
		_checkmarkContainer = new Sprite();
		
		_checkmarkSlot = new Bitmap(Window.textures["checkmarkSlot"]);
		_checkmarkContainer.addChild(_checkmarkSlot)
		_checkmarkSlot.visible = false;
		
		_checkmarkContainer.x = _applyBttn.x + ((_applyBttn.width - _checkmarkContainer.width) * .5);
		_checkmarkContainer.y = (height - _checkmarkContainer.height) * 0.5;
		addChild(_checkmarkContainer);
		
		_checkmark = new Bitmap(Window.textures["checkMark"]);
		_checkmark.x = 0;
		_checkmark.y = (_bg.height - _checkmark.height) / 2 - 10;
		_checkmarkContainer.addChild(_checkmark);
		
		updateState();
	}
	
	private function drawItems():void 
	{
		if (!_itemsBG)
		{
			_itemsBG = new Sprite();
			_itemsBG.graphics.lineStyle(3, 0xC9A25F, 0.7);
			_itemsBG.graphics.drawRoundRect(0, 0, 190, 60, 30, 30);
			
			_itemsBG.x = 190;
			_itemsBG.y = (height - _itemsBG.height) * 0.5 + 1;
			addChild(_itemsBG);
		}
		
		var startX:int = 10;
		
		var itemInfo:Object;
		var counter:int = 0;
		for (var key:String in _itemsData)
		{
			var item:MaterialItem = new MaterialItem(int(key), _itemsData[key]);
			item.mouseChildren = false;
			item.mouseEnabled = false;
			item.x = startX + (90 * counter);
			item.y = 5;
			_itemsBG.addChild(item);
			counter++;
		}
	}
	
	private var _mtrx:ColorAdjust;
	private function updateState():void
	{
		var invitedFriendsOverLevel:int = NewFreebieModel.instance.numInvitedFriendsOverLevel(_targetLevel);
		
		if (!_mtrx)
		{
			_mtrx = new ColorAdjust();
			_mtrx.saturation(0.5);
		}
		
		var backingName:String;
		if (NewFreebieModel.instance.isBountyTaken(_targetLevel, _numFriends))
		{
			_applyBttn.state = Button.DISABLED;
			_applyBttn.visible = false;
			_checkmarkContainer.visible = true;
		}
		else if (invitedFriendsOverLevel < _numFriends)
		{
			_applyBttn.state = Button.DISABLED
			_checkmarkContainer.visible = false;
		}
		else
		{
			_applyBttn.state = Button.NORMAL;
			_applyBttn.visible = true;
			_checkmarkContainer.visible = false;
		}
	}
	
	private function onApplyBttnClick(e:MouseEvent):void 
	{
		if (_applyBttn.mode == Button.DISABLED)
			return;
			
		var sendObject:Object = {
			ctr:"user",
			act:"take",
			uID:App.user.id,
			wID:App.user.worldID,
			bounty:_sid,
			count:_numFriends
		};
		
		Post.send(sendObject, applyCallback);
		_applyBttn.state = Button.DISABLED;
	}
	
	private function applyCallback(error:int, data:Object, params:Object):void 
	{
		if (error) {
			Errors.show(error, data);
			return;
		}
		
		//var data:Object = { };
		//data['bonus'] = { "4":5, "140":10 };
		NewFreebieModel.instance.setTakenBounty(_targetLevel, _numFriends);
		if(data.hasOwnProperty('bonus')) {
			BonusItem.takeRewards(data.bonus, this, 0);
			App.user.stock.addAll(data.bonus);
		}
		updateState();
	}
	
	public function dispose():void
	{
		_applyBttn.addEventListener(MouseEvent.CLICK, removeEventListener);
	}
}

internal class MaterialItem extends Sprite
{
	private var _sid:int;
	private var _count:int;
	
	private var _icon:Bitmap;
	private var _textCount:TextField;
	
	public function MaterialItem(sid:int, count:int)
	{	
		_textCount = Window.drawText("x" + String(count), { 
			width:55,
			fontSize:26,
			color:0xfffff7,
			borderColor:0x7f3d00,
			height: 32
		} );
		_textCount.x = 40;
		_textCount.y = 18;
		_textCount.mouseEnabled = false;
		addChild(_textCount);
		
		var itemInfo:Object = App.data.storage[sid];
		Load.loading(Config.getIcon(itemInfo.type, itemInfo.preview), onIconLoad);
	}
	
	private function onIconLoad(data:Bitmap):void
	{
		_icon = new Bitmap(data.bitmapData);
		_icon.smoothing = true;
		Size.size(_icon, 50, 50);
		addChildAt(_icon, 0);
	}
}