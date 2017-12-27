package wins 
{
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import buttons.Button;
	import core.Load;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	public class FBFreebieWindow extends Window 
	{
		
		private var helpBttn:Button;
		private var descLabel:TextField;
		private var rewardContainer:Sprite;
		private var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var inviteBttn:Button;
		private var sendBacking:Bitmap;
		private var sendIcon:Bitmap;
		private var sendLabel:TextField;
		private var giftBttn:Button;
		private var icon:Bitmap;
		private var countLabel:TextField;
		
		public var targetID:int = 686;
		
		public var items:Vector.<CIcon> = new Vector.<CIcon>;
		
		private var awardID:int = 1;
		private var awardList:Array = [];
		private var awards:Object;
		private var data:Object;
		
		public function FBFreebieWindow(settings:Object=null)
		{
			if (!settings) settings = { };
			
			data = App.data.award[awardID];
			
			awards = App.user.storageRead('awards', { } );
			if (!awards[awardID]) awards[awardID] = {};
			
			settings['title'] = data.title;
			settings['width'] = settings['width'] || 700;
			settings['height'] = settings['height'] || 550;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 1;
			
			
			super(settings);
			
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.y -= 100;
			paginator.arrowRight.y -= 100;
		}
		
		override public function drawBody():void {
			// Description
			var desc_text:String = data.description;
			descLabel = drawText(desc_text, {
				width:		settings.width - 120,
				fontSize:	24,
				color:		0x614605,
				borderColor:0xf0e6c1,
				textAlign:  'center',
				wrap:		true,
				multiline:	true
			});
			descLabel.x = settings.width * 0.5 - descLabel.width * 0.5;
			descLabel.y = 50;
			bodyContainer.addChild(descLabel);
			
			
			// Content
			rewardContainer = new Sprite();
			bodyContainer.addChild(rewardContainer);
			
			
			for (var id:* in data.devel.req) {
				for (var sid:* in data.devel.bonus[id]) break;
				
				awardList.push( {
					sid:		sid,
					value:		data.devel.bonus[id][sid],
					count:		data.devel.req[id].count,
					id:			id,
					window:		this
				});
			}
			awardList.sortOn('count', Array.NUMERIC);
			
			for (var i:int = 0; i < awardList.length; i++) {
				var item:CIcon = new CIcon(awardList[i]);
				items.push(item);
				rewardContainer.addChild(item);
			}
			
			paginator.itemsCount = awardList.length - 4 + 1;
			paginator.update();
			
			contentChange();
			
			
			
			// Progress
			drawProgress();
			
			
			// Counter
			icon = new Bitmap();
			icon.x = progressBar.x - 6;
			icon.y = progressBar.y - 3;
			icon.scaleX = icon.scaleY = 0.4;
			bodyContainer.addChild(icon);
			
			countLabel = drawText('x' + String(App.user.stock.count(targetID)), {
				width:			160,
				textAlign:		'center',
				color:			0xffffff,
				borderColor:	0x754209,
				fontSize:		32
			});
			countLabel.x = progressBar.x - 60;
			countLabel.y = progressBar.y + 40;
			bodyContainer.addChild(countLabel);
			
			
			// Invite
			inviteBttn = new Button( {
				width:		160,
				height:		50,
				caption:	Locale.__e('flash:1382952380197')
			});
			inviteBttn.x = settings.width * 0.5 - inviteBttn.width * 0.5;
			inviteBttn.y = 350;
			bodyContainer.addChild(inviteBttn);
			inviteBttn.addEventListener(MouseEvent.CLICK, onInvite);
			
			// Gift
			sendBacking = backing(settings.width, 125, 50, 'dialogueBackingDec');
			sendBacking.x = settings.width * 0.5 - sendBacking.width * 0.5;
			sendBacking.y = 420;
			bodyContainer.addChild(sendBacking);
			
			sendIcon = new Bitmap();
			sendIcon.x = sendBacking.x + 30;
			sendIcon.y = sendBacking.y + 20;
			sendIcon.scaleX = sendIcon.scaleY = 0.7;
			bodyContainer.addChild(sendIcon);
			
			sendLabel = drawText(Locale.__e('flash:1437389435043'), {
				width:		370,
				fontSize:	22,
				color:		0x614605,
				borderColor:0xf0e6c1,
				wrap:		true,
				multiline:	true,
				border:		true
			});
			sendLabel.x = sendBacking.x + 110;
			sendLabel.y = sendBacking.y + sendBacking.height * 0.5 - sendLabel.height * 0.5;
			bodyContainer.addChild(sendLabel);
			
			giftBttn = new Button( {
				width:			136,
				height:			48,
				caption:		Locale.__e('flash:1382952380118')
			});
			giftBttn.x = sendBacking.x + 475;
			giftBttn.y = sendBacking.y + 32;
			bodyContainer.addChild(giftBttn);
			giftBttn.addEventListener(MouseEvent.CLICK, onGift);
			if (!giftable)
				giftBttn.state = Button.DISABLED;
				
			if (!App.user.stock.check(targetID, 1))
				giftBttn.state = Button.DISABLED;
			
			Load.loading(Config.getIcon(App.data.storage[targetID].type, App.data.storage[targetID].preview), function(data:Bitmap):void {
				sendIcon.bitmapData = data.bitmapData;
				sendIcon.smoothing = true;
				
				icon.bitmapData = data.bitmapData;
				icon.smoothing = true;
			});
		}
		
		private function countUpdate():void {
			countLabel.text = 'x' + String(App.user.stock.count(targetID));
		}
		
		private function onInvite(e:MouseEvent):void {
			ExternalApi.apiInviteEvent();
		}
		
		// Help
		private function onHelp(e:MouseEvent):void {
			new SimpleWindow( {
				popup:		true,
				title:		settings.title,
				text:		Locale.__e('flash:1435137714546')
			}).show();
		}
		
		// Gift
		private function onGift(e:MouseEvent):void {
			if (giftBttn.mode == Button.DISABLED) return;
			
			new NotifWindow( {
				title:		settings.title,
				inviteText:	'',
				buttonText:	Locale.__e('flash:1382952380118'),
				popup:		true,
				notifyType: NotifWindow.TYPE_FREEBIE,
				type:		NotifWindow.FRIENDS,
				callback:	gift
			}).show();
		}
		
		// Progress
		private function drawProgress():void {
			progressBacking = Window.backingShort(settings.width - 120 - 16, "progBarBacking");
			progressBacking.x = settings.width * 0.5 - progressBacking.width * 0.5;
			progressBacking.y = 264;
			bodyContainer.addChild(progressBacking);
			
			progressBar = new ProgressBar( {
				win:		this,
				width:		settings.width - 120,
				isTimer:    false
			});
			progressBar.x = progressBacking.x - 8;
			progressBar.y = 260;
			bodyContainer.addChild(progressBar);
			setProgress();
			progressBar.start();
			
			var numberOfParts:int = awardList.length;
			for (var i:int = 1; i < numberOfParts + 1; i++) {
				var divider:Shape = new Shape();
				divider.graphics.beginFill(0xffffff, 1);
				divider.graphics.lineStyle(2, 0x754209, 1, false);
				divider.graphics.drawRoundRect(0, 0, 6, 36, 6, 6);
				divider.graphics.endFill();
				divider.x = progressBar.x + (progressBar.width - 60) * i / numberOfParts;
				divider.y = progressBar.y;
				bodyContainer.addChild(divider);
				
				var textLabel:TextField = drawText(awardList[i-1].count, {
					fontSize:			28,
					autoSize:			'center',
					textAlign:			'center',
					color:				0xffffff,
					borderColor:		0x754209
				});
				textLabel.x = divider.x + divider.width * 0.5 - textLabel.width * 0.5;
				textLabel.y = divider.y + divider.height + 3;
				bodyContainer.addChild(textLabel);
			}
		}
		
		public function setProgress():void {
			if (progressBar)
				progressBar.progress = progress();
			
			function progress():Number {
				var count:int = App.user.stock.count(targetID);
				var prev:int = 0;
				var maxPercent:Number = (progressBar.width - 50) / progressBar.width;
				var value:Number = 0
				
				for (var i:int = 0; i < awardList.length; i++) {
					if (awardList[i].count > count) {
						value = maxPercent * (i / awardList.length) + (1 / awardList.length) * maxPercent * ((count - prev) / (awardList[i].count - prev));
						break;
					}
					
					prev = awardList[i].count;
				}
				
				if (value == 0 && i >= awardList.length - 1) {
					value = maxPercent * (i / awardList.length) + maxPercent * (1 / awardList.length) * ((count - prev) / prev);
				}
				
				if (value > 1) value = 1;
				
				return value;
			}
		}
		
		override public function contentChange():void {
			for (var i:int = 0; i < items.length; i++)
				items[i].visible = false;
			
			for (i = paginator.page; i < paginator.page + 4; i++) {
				if (items.length <= i) continue;
				
				items[i].visible = true;
				items[i].x = 150 * (i - paginator.page);
				items[i].y = 0;
			}
			
			rewardContainer.x = settings.width * 0.5 - rewardContainer.width * 0.5;
			rewardContainer.y = 110;
		}
		
		public function checkStatus(id:*):Boolean {
			if (awards[awardID][id])
				return false;
			
			return true;
		}
		
		public function take(id:*, callback:Function):void {
			Post.send( {
				ctr:		'award',
				act:		'storage',
				wID:		App.map.id,
				uID:		App.user.id,
				aID:		awardID,
				id:			String(id)
			}, function(error:int, data:Object, params:Object):void {
				if (!error) {
					awards[awardID][id] = App.time;
					//App.user.storageStore('award', awards);
					
					// Bonus
					for (var i:int = 0; i < items.length; i++) {
						if (items[i].id == id) {
							BonusItem.takeRewards(data.bonus, items[i]);
						}
					}
					
					App.user.stock.addAll(data.bonus);
					App.ui.upPanel.update();
				}
				
				callback();
			});
		}
		
		public function gift(fiD:*):void {
			if (awards[awardID].hasOwnProperty('gift') && awards[awardID]['gift']) {
				giftBttn.state = Button.DISABLED;
				return;
			}
			
			giftBttn.state = Button.DISABLED;
			
			Post.send( {
				ctr:		'award',
				act:		'gift',
				wID:		App.map.id,
				uID:		App.user.id,
				aID:		awardID,
				id:			String(id),
				fID:		String(fiD)
			}, function(error:int, data:Object, params:Object):void {
				if (!error) {
					awards[awardID]['gift'] = 1;
					App.user.storageStore('awards', awards);
					App.user.stock.take(targetID, 1);
					countUpdate();
					
					giftBttn.state = Button.DISABLED;
				}else {
					new SimpleWindow( {
						title:		'',
						text:		Locale.__e('flash:1406275629192'),
						buttonText:	Locale.__e('flash:1382952380298'),
						isImg:		true,
						popup:		true
					}).show();
					giftBttn.state = Button.NORMAL;
				}
				
				Window.closeAll();
			});
		}
		
		private function get giftable():Boolean {
			try {
				if (awards[awardID]['gift'] == 1)
					return false;
			}catch (e:*) { }
			
			return true;
		}
		
		override public function close(e:MouseEvent = null):void {
			while (items.length) {
				var item:CIcon = items.shift();
				item.dispose();
			}
			
			super.close(e);
		}
	}
}

import buttons.Button;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import ui.UserInterface;
import wins.FBFreebieWindow;
import wins.Window;

internal class CIcon extends LayerX {
	
	private var backing:Sprite;
	private var image:Bitmap;
	private var mark:Bitmap;
	private var icon:Bitmap;
	private var valueLabel:TextField;
	private var countLabel:TextField;
	private var takeBttn:Button;
	
	public var sid:int = 0;
	public var id:*;
	public var count:int = 0;
	public var info:Object;
	public var window:FBFreebieWindow;
	public var value:int = 0;
	
	public function CIcon(params:Object) {
		sid = params.sid;
		id = params.id;
		info = App.data.storage[sid];
		count = params.count;
		window = params.window;
		value = params.value;
		
		backing = new Sprite();
		backing.graphics.beginFill(0xcbd4cf);
		backing.graphics.drawCircle(60, 60, 60);
		backing.graphics.endFill();
		addChild(backing);
		
		if (!info) {
			var tf:TextField = Window.drawText('Unreal object', {
				width:			100,
				textAlign:		'center',
				color:			0xffffff,
				borderColor:	0x754209,
				fontSize:		20
			});
			addChild(tf);
			
			return;
		}
		
		draw();
	}
	
	public function draw():void {
		image = new Bitmap();
		addChild(image);
		Load.loading(Config.getIcon(info.type, info.preview), onImageLoad);
		
		icon = new Bitmap();
		icon.x = 12;
		icon.y = (backing.height - icon.height) / 2;
		addChild(icon);
		Load.loading(Config.getIcon(App.data.storage[window.targetID].type, App.data.storage[window.targetID].preview), onIconLoad);
		
		mark = new Bitmap(Window.textures.checkMark);
		mark.x = (backing.width - mark.width) / 2;
		mark.y = backing.height - mark.height + 4;
		addChild(mark);
		
		valueLabel = Window.drawText(count.toString(), {
			width:			80,
			textAlign:		'left',
			color:			0xffffff,
			borderColor:	0x754209,
			fontSize:		28
		});
		valueLabel.x = icon.x + 35;
		valueLabel.y = backing.y + 15;
		addChild(valueLabel);
		
		countLabel = Window.drawText('x' + value.toString(), {
			color:0x6e461e,
			borderColor:0xffffff,
			textAlign:"left",
			autoSize:"left",
			fontSize:25
		});
		countLabel.x = (backing.width - countLabel.width) / 2;
		countLabel.y = backing.y - 10;
		addChild(countLabel);
		
		takeBttn = new Button( {
			width:		100,
			height:		32,
			caption:	Locale.__e('flash:1382952379737')
		});
		takeBttn.x = 10;
		takeBttn.y = backing.height - takeBttn.height * 0.5 - 5;
		addChild(takeBttn);
		addEventListener(MouseEvent.CLICK, onTake);
		
		checkStatus();
	}
	
	private function onImageLoad(data:Bitmap):void {
		image.bitmapData = data.bitmapData;
		image.smoothing = true;
		Size.size(image, backing.width * 0.85, backing.height * 0.85);
		image.x = backing.x + backing.width * 0.5 - image.width * 0.5;
		image.y = backing.y + backing.height * 0.5 - image.height * 0.5;
	}
	
	private function onIconLoad(data:Bitmap):void {
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		icon.scaleX = icon.scaleY = 0.3;
	}
	
	public function checkStatus():void {
		takeBttn.state = Button.NORMAL;
		
		if (window.checkStatus(id)) {
			mark.visible = false;
			
			if (App.user.stock.count(window.targetID) >= count) {
				takeBttn.visible = true;
				takeBttn.state = Button.NORMAL;
				icon.visible = false;
				valueLabel.visible = false;
				/*icon.y = backing.height - 60;
				valueLabel.y = icon.y + 5;*/
			}else {
				takeBttn.visible = false;
				takeBttn.state = Button.DISABLED;
				icon.y = backing.height - 42;
				valueLabel.y = icon.y + 5;
			}
		}else {
			takeBttn.visible = false;
			takeBttn.state = Button.DISABLED;
			mark.visible = true;
			icon.visible = false;
			valueLabel.visible = false;
			//icon.y = backing.height - 42;
			//valueLabel.y = icon.y + 5;
		}
	}
	
	private function onTake(e:MouseEvent):void {
		if (takeBttn.mode == Button.DISABLED) return;
		takeBttn.state = Button.DISABLED;
		
		window.take(id, checkStatus);
	}
	
	public function dispose():void {
		takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
		takeBttn.dispose();
		takeBttn = null;
		
		if (parent)
			parent.removeChild(this);
	}
}