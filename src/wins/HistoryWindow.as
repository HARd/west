package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class HistoryWindow extends Window
	{
		
		public var items:Array = [];
		public static var history:String = '{"163792:1446211563":{"itemPrice":10000,"paymentID":"8275D40C-23E5-391C-8ED7-A89E232550F4","expired":0,"status":1,"orderCount":1,"amount":10000,"appID":"12023559","transaction_time":1446211563,"uid":"163792","itemID":1227,"transaction_end":1461763563},"163792:1446204660":{"itemPrice":10000,"paymentID":"F43FAA55-07B0-3DDD-8577-A6CD1B155E7C","expired":0,"status":1,"orderCount":1,"amount":10000,"appID":"12023559","transaction_time":1446204660,"uid":"163792","itemID":2221,"transaction_end":1461756660},"163792:1446204693":{"itemPrice":5000,"paymentID":"DECB703F-1868-3B20-A123-B57B3C3AF362","expired":0,"status":0,"orderCount":1,"amount":5000,"appID":"12023559","transaction_time":1446204693,"uid":"163792","itemID":1226,"transaction_end":1461756693},"163792:1446204334":{"itemPrice":250,"paymentID":"1CC9FDF0-BD99-30C2-BF9B-62858DF76CE2","expired":0,"status":1,"orderCount":1,"amount":250,"appID":"12023559","transaction_time":1446204334,"uid":"163792","itemID":2216,"transaction_end":1461756334},"163792:1446711673":{"itemPrice":10000,"paymentID":"D3FAFAB7-8DAD-3409-B2FF-86D8B417E024","expired":0,"status":0,"orderCount":1,"amount":10000,"appID":"12023559","transaction_time":1446711673,"uid":"163792","itemID":1227,"transaction_end":1462263673},"163792:1446204256":{"itemPrice":250,"paymentID":"769D9304-E0FB-31B9-80DC-C84C0E06C8DF","expired":0,"status":1,"orderCount":1,"amount":250,"appID":"12023559","transaction_time":1446204256,"uid":"163792","itemID":2216,"transaction_end":1461756256},"163792:1446453936":{"itemPrice":250,"paymentID":"794DECAF-A082-3043-8652-C45CE9701330","expired":0,"status":1,"orderCount":1,"amount":250,"appID":"12023559","transaction_time":1446453936,"uid":"163792","itemID":1222,"transaction_end":1462005936},"163792:1446211549":{"itemPrice":10000,"paymentID":"F1B3A656-AB67-36EA-B808-C5DE252DD8B0","expired":0,"status":1,"orderCount":1,"amount":10000,"appID":"12023559","transaction_time":1446211549,"uid":"163792","itemID":2221,"transaction_end":1461763549},"163792:1446711665":{"itemPrice":10000,"paymentID":"74600FC8-31AA-3218-908C-A391249B237D","expired":0,"status":0,"orderCount":1,"amount":10000,"appID":"12023559","transaction_time":1446711665,"uid":"163792","itemID":2221,"transaction_end":1462263665},"163792:1446204679":{"itemPrice":10000,"paymentID":"E614F104-3FE4-3940-85B5-D04C50D6A6C9","expired":0,"status":0,"orderCount":1,"amount":10000,"appID":"12023559","transaction_time":1446204679,"uid":"163792","itemID":2221,"transaction_end":1461756679},"163792:1446204838":{"itemPrice":250,"paymentID":"CB5DE324-1238-30EC-B143-05B88749EB6B","expired":0,"status":0,"orderCount":1,"amount":250,"appID":"12023559","transaction_time":1446204838,"uid":"163792","itemID":2216,"transaction_end":1461756838},"163792:1446455717":{"itemPrice":2000,"paymentID":"1B5BFA53-B345-39B7-99EB-7F9463DB6562","expired":0,"status":0,"orderCount":1,"amount":2000,"appID":"12023559","transaction_time":1446455717,"uid":"163792","itemID":1225,"transaction_end":1462007717},"163792:1446204600":{"itemPrice":10000,"paymentID":"F4F34940-2432-370A-B0C3-153EFCA427EA","expired":0,"status":1,"orderCount":1,"amount":10000,"appID":"12023559","transaction_time":1446204600,"uid":"163792","itemID":1227,"transaction_end":1461756600}}';

		public function HistoryWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}		
			
			settings['width'] = 720;
			settings['height'] = 560;
			
			settings['title'] = Locale.__e("flash:1383227541049");
			settings['hasPaginator'] = true;
			settings['itemsOnPage'] = 8;
			
			/*settings['content'] = [];
			var his:Object = JSON.parse(history);
			for each(var item:Object in his) {
				settings.content.push(item);
			}
			settings.content.sortOn('transaction_time', Array.DESCENDING);*/
			
			var sortedContent:Array = [];
			settings['content'] = settings['content'] || [];
			
			for (var i:int = 0; i < settings['content'].length; i++) {
				if (App.isSocial('AI')) 
				{
					settings['content'][i]['itemID']=settings['content'][i].product_code.slice(String(settings['content'][i].product_code).indexOf('_'),settings['content'][i].product_code.length);
					settings['content'][i].status = (settings['content'][i].transaction_end < App.time)?0:1;
					sortedContent.push(settings['content'][i])
				}else if (App.isSocial('GN')) 
				{
					var itemIDArray:Array = settings['content'][i].item_id.split("_");
					if (itemIDArray[1]) 
					{
						settings['content'][i].itemID = "2" + itemIDArray[1];
						settings['content'][i].transaction_time = settings['content'][i].time;
						sortedContent.push(settings['content'][i]);
					}
				}else{
					var _ids:String = String(settings['content'][i].itemID);
					var typeID:* = _ids.substr(0, 1);
					if (typeID == 1 || typeID == 2) {
						sortedContent.push(settings['content'][i])
					}else {
						continue;
					}
				}
			}
			
			sortedContent.sortOn('transaction_time',Array.DESCENDING);
			settings.content = sortedContent;
			
			var cont:Array = [];
			var count:int = 0;
			for (var j:int = 0; j < settings.content.length; j++) 
			{
				if (settings.content[j].status || App.isSocial('GN')) 
				{	
					cont[count] = settings.content[j];
					count++;	
				}
			}
			
			settings.content = cont;
			
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			//settings.content = settings.content.concat(settings.content);
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 50, "alertBacking");
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			exit.x += 20;
			exit.y -= 22;
			paginator.y += 30;
			
			var amount:TextField;
			var transaction_time:TextField;
			var transaction_end:TextField;
			var txnid:TextField
			
			var textSettings:Object = {
				fontSize	:22,
				color:0xffcc00,
				borderColor:0x705535,
				textAlign	:'center'
			}
		
			textSettings['width'] = 102;
			amount 				= Window.drawText(Locale.__e('flash:1383229186583'), textSettings);
			textSettings['width'] = 140;
			transaction_time 	= Window.drawText(Locale.__e('flash:1383229215303'), textSettings);
			textSettings['width'] = 140;
			transaction_end 	= Window.drawText(Locale.__e('flash:1383229242023'), textSettings);
			textSettings['width'] = 164;
			txnid 				= Window.drawText(Locale.__e('flash:1383229266586'), textSettings);
			
			
			amount.height = amount.textHeight;
			transaction_time.height = transaction_time.textHeight;
			transaction_end.height = transaction_end.textHeight;
			txnid.height = txnid.textHeight;
			
			//bodyContainer.addChild(txnid);
			bodyContainer.addChild(amount);
			bodyContainer.addChild(transaction_time);
			bodyContainer.addChild(transaction_end);
			
			/*txnid.x = 34;
			txnid.y = 55;
			
			amount.x = 208;
			amount.y = 55;*/
			
			if (!App.isSocial('GN')) 
			{
				bodyContainer.addChild(transaction_end);
			}
			
			amount.x = 100;
			amount.y = 55;
			
			transaction_time.x = 270;
			transaction_time.y = 55;
			
			transaction_end.x = 440;
			transaction_end.y = 55;
			
			contentChange();
		}
		
		override public function contentChange():void {
			for each(var _item:* in items) {
				bodyContainer.removeChild(_item);
			}
			items = [];

			var itemNum:int = 0;
			for (var i:int = paginator.startCount; i < Math.min(paginator.finishCount, settings.content.length); i++){
			
				var item:HistoryItem = new HistoryItem(settings.content[i], this);
				bodyContainer.addChild(item);
				item.x = (settings.width - item.width)/2;
				item.y = item.height * itemNum + 80;
				items.push(item);
				itemNum++;
				bodyContainer.addChild(item);
			}
		}
		
		override public function drawArrows():void {
			
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 10;
			paginator.arrowLeft.x = -28;
			paginator.arrowLeft.y = y-10;
			
			paginator.arrowRight.x = settings.width - paginator.arrowLeft.width + 28;
			paginator.arrowRight.y = y - 10;
			
			paginator.x -= 30;
			paginator.y -= 10;
		}
		
	}
}

import core.Numbers;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.TextField;
import ui.UserInterface;
import wins.Window;

internal class HistoryItem extends LayerX {
	
	public var amount:TextField;
	public var transaction_time:TextField;
	public var transaction_end:TextField;
	public var txnid:TextField;
	public var moneySID:*;
	public var obj:Object;
	public var count:*;
	
	public function HistoryItem(item:Object, window:*) {
		var _ids:String = String(item.itemID);
		var _id:* = _ids.slice(1,_ids.length);
		obj = App.data.storage[_id];
		for (moneySID in obj.price){
			count = obj.price[moneySID];
			break;
		}	
		
		var bg:Bitmap = Window.backing(620, 46, 10, 'progBarBacking');
		bg.visible = false;
		addChild(bg);
		
		var separator:Bitmap = Window.backingShort(580, 'dividerLine', false);
		separator.scaleY = -1;
		separator.x = 25;
		separator.y = 10;
		separator.alpha = 0.5;		
		addChild(separator);
		
		var color:uint = 0x000000;
		if (item.transaction_end < App.time) {
			color = 0x333333;
		}
		
		var textSettings:Object = {
			color:color,
			fontSize:18,
			textAlign:'left',
			border:false
		}
		
		textSettings['width'] = 140;
		transaction_time 	= Window.drawText(TimeConverter.getDatetime("%Y.%m.%d %H:%i",item.transaction_time), textSettings);
		textSettings['width'] = 140;
		transaction_end 	= Window.drawText(TimeConverter.getDatetime("%Y.%m.%d %H:%i",item.transaction_end), textSettings);
		textSettings['width'] = 180;
		txnid 				= Window.drawText(item.paymentID, textSettings);
		
		var cont:Sprite = new Sprite();
		var fantsIcon:Bitmap = new Bitmap();
		switch(moneySID) {
			case Stock.COINS:
					fantsIcon.bitmapData = UserInterface.textures.coinsIcon;
				break;	
			case Stock.FANT:
					fantsIcon.bitmapData = UserInterface.textures.fantsIcon;
				break;	
		}
		
		fantsIcon.scaleX = fantsIcon.scaleY = 0.6;
		fantsIcon.smoothing = true;
		cont.addChild(fantsIcon);
		
		textSettings['autoSize'] = 'left';
		amount 				= Window.drawText(Numbers.moneyFormat(count), textSettings);
		cont.addChild(amount);
		amount.x = fantsIcon.width + 4;
		amount.y = 2;
		
		
		
		txnid.mouseEnabled = true;
		amount.mouseEnabled = true;
		transaction_time.mouseEnabled = true;
		transaction_end.mouseEnabled = true;
		
		//addChild(txnid);
		addChild(cont);
		addChild(transaction_time);
		addChild(transaction_end);
		
		if (!App.isSocial('GN')) 
		{			
			addChild(transaction_end);
		}
		
		/*txnid.x = 14;
		txnid.y = 12;
		
		cont.x = 188 + (102 - cont.width) / 2;
		cont.y = 12;*/
		
		cont.x = 80;
		cont.y = 15;
		
		transaction_time.x = 250;
		transaction_time.y = 15;
		
		transaction_end.x = 420;
		transaction_end.y = 15;		
	}
}


