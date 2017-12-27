package  
{
	import api.ExternalApi;
	import core.Log;
	import core.Post;
	import wins.HistoryWindow;
	public class Payments 
	{		
		
		public static var history:Array = [];
		
		public function Payments() 
		{
			
		}
		
		public static function getHistory(show:Boolean = true):void {
			
			Post.send({
				'ctr':'orders',
				'act':'get',
				'uID':App.user.id
			}, function(error:*, result:*, params:*):void {
				
				if (error) {
					trace(error);
					return;
				}
				
				history = [];
				for each(var item:Object in result.history) {
					history.push(item);
				}
				history.sortOn('transaction_time', Array.DESCENDING);
				
				App.self.setOffTimer(onExpirePayment);
				App.self.setOnTimer(onExpirePayment);
				
				if(show){
					if (!App.user.quests.tutorial && history.length > 0)
						new HistoryWindow( { content:history } ).show();
				}
			});
		}
		
		public static function onExpirePayment():void {
			for each(var item:Object in history) {
				//txnid
				if (item.status == 0 && item.transaction_end < App.time) {
					Post.send({
						'ctr':'orders',
						'act':'expire',
						'uID':App.user.id
					}, function(error:*, result:*, params:*):void {
						if (!error) {
							for each(var txnid:String in result.orders) {
								for(var id:* in history) {
									if (history[id].txnid == txnid) {
										history[id].status = 1;
									}
								}	
							}
							if(result[Stock.FANT] != undefined){
								App.user.stock.put(Stock.FANT, result[Stock.FANT]);
							}
						}
					});
					break;
				}
			}
		}
		
		public static function price(price:*):String {
			
			price = int(price);
			
			switch(App.social) {
				case "HV":
					price = int(price) / 100;
					return Locale.__e('%d €', [price]);
					
				case "VK":
				case "DM":
					return Locale.__e('flash:1382952379985', [price]);
				
				case "OK":
					return Locale.__e('%d ОК', [price]);
				
				case "ML":
					return Locale.__e('[%d мэйлик|%d мэйлика|%d мэйликов]', [price]);
				
				case "NK":
					return Locale.__e('%d €GB', [price]);
				
				case "MX":
					return Locale.__e('%d pt.', [price]);
				
				case "YN":
					return Locale.__e('%d USD', [price]);
				
				case "YB":
					return Locale.__e('%d モバコイン', [price]);
					
				case "AI":
					return Locale.__e('%d ゲソコイン', [price]);
					
				case "GN":
					return Locale.__e('%d ゲソコイン', [price]);
					
				case "FB":
					var inverse:int = 1;// (App.network.hasOwnProperty('currency')) ? App.network.currency.usd_exchange_inverse : 99;
					if (App.network.hasOwnProperty('currency')) {
						Log.alert('App.network.hasOwnProperty(currency)');
						inverse = App.network.currency.usd_exchange_inverse;
						price = price * App.network.currency.usd_exchange_inverse;
					} else return price;
					//price = price * inverse;
					price = int(price * 100) / 100;
					return price + ' ' + App.network.currency.user_currency; 
				
				case 'FS':
					return Locale.__e('%d ФМ', [price]);
					
				default:
					return String(price);
			}
		}
		
		public static function buy(params:Object = null):void {
			Log.alert(params);
			if (!params) return;
			
			Log.alert('BEGIN BUY ACTION');
			
			if (!params['type']) params['type'] = 'promo';
			
			var object:Object;
			
			if (params.type == 'promo') {
				
				switch(App.social) {
					case 'PL':
					case 'SP':
					//case 'YB':
						if (App.user.stock.take(Stock.FANT, params.price, function():void {
							Post.send({
								ctr:'Promo',
								act:'buy',
								uID:App.user.id,
								pID:params.id || 0,
								ext:App.social
							},function(error:*, data:*, addon:*):void {
								if (params.callback != null)
									callback();
							});
						})){
							Post.send({
								ctr:'Promo',
								act:'buy',
								uID:App.user.id,
								pID:params.id || 0,
								ext:App.social
							},function(error:*, data:*, addon:*):void {
								if (params.callback != null)
									callback();
							});
						}else {
							if (params.error != null)
								params.error();
						}
						break;
					case 'GN':
						object = {
							itemId:		params.money+"_" + params.id,
							price:		params.price,
							money:		'promo',
							amount:		1,
							itemName:	params.title,
							item:		params.type + '_' + params.id,
							callback:	function():void {
								callback();
							}					
						};
						ExternalApi.apiPromoEvent(object);
					break;
					default:
						if (App.social == 'FB') {
							ExternalApi.apiNormalScreenEvent();
							object = {
								id:		 		params.id,
								type:			'promo',
								title: 			params['title'] || '',
								description: 	params['description'] || '',
								callback:		callback
							};
						}else{
							object = {
								count:			1,
								money:			'promo',
								type:			'item',
								item:			'promo_'+params.id,
								votes:			params.price,
								title: 			params['title'] || '',
								description: 	params['description'] || '',
								tnidx:			App.user.id + App.time + '-' + params['money'] + "_" + params.id,
								callback: 		callback,
								icon:			params['icon'] || ''
							}
						}
						ExternalApi.apiPromoEvent(object);
						break;
				}
				
			}else if (params.type == 'bigsale') {
				
				switch(App.social) {
					case 'PL':
					case 'SP':
					//case 'YB':
						if (App.user.stock.take(Stock.FANT, params.price, function():void {
							Post.send({
								ctr:'Stock',
								act:'bigsale',
								uID:App.user.id,
								sID:params.id.substring(0,params.id.indexOf('_')),
								pos:params.id.substring(params.id.indexOf('_')+1,params.id.length)
							},function(error:*, data:*, addon:*):void {
								if(!error){
									App.user.stock.add(params.sID, params.count, true);
									if (params.callback != null)
										callback();
								}
							});
						})){
							Post.send({
								ctr:'Stock',
								act:'bigsale',
								uID:App.user.id,
								sID:params.id.substring(0,params.id.indexOf('_')),
								pos:params.id.substring(params.id.indexOf('_')+1,params.id.length)
							},function(error:*, data:*, addon:*):void {
								if(!error){
									//App.user.stock.add(params.sID, params.count, true);
									if (params.callback != null)
										callback();
								}
							});
						}else {
							if (params.error != null)
								params.error();
						}
						return;
					default:
						if (App.social == 'FB') {
							object = {
								id:		 		params.id.replace('_','#'),//window.action.id+'#'+item.id,
								type:			params.type,
								callback:		callback
							};
						}else{
							object = {
								count:			params.count,
								money:			params.type,
								type:			'item',
								item:			params.type + '_' + params.id,
								votes:			params.price,
								title: 			params['title'] || '',
								description: 	params['description'] || '',
								tnidx:			App.user.id + App.time + '-' + params['money'] + "_" + params.id,
								callback: 		callback
							}
						}
						ExternalApi.apiBalanceEvent(object);
				}
				
			}else if (params.type == 'item') {
				
				switch(App.social) {
					/*case 'YB':
						object = {
							id:		 	params.money + '_' + params.id + '_' + params.extra,
							item:		params['money'] + '_' + params.id,
							price:		params.price,
							type:		params.type,
							count: 		params.count,
							callback:	callback
						};
						Log.alert(object);
						break;*/
					case 'FB':
						object = {
							id:		 		params.id,
							type:			params.money,
							callback:		callback
						};
						break;
					default:
						object = {
							money: 			params['money'] || '',
							type:			params.type,
							item:			params['money'] + '_' + params.id,
							votes:			params.price,
							sid:			params.id,
							count:			params.count,
							title: 			params['title'] || '',
							description: 	params['description'] || '',
							icon:			params['icon'] || '',
							tnidx:			App.user.id + App.time + '-' + params['money'] + "_" + params.id,
							callback:		callback
						}
				}
				
				ExternalApi.apiBalanceEvent(object);
			}else if (params.type == 'energy') {
				Log.alert(params.money);
				switch(App.social) {
					case 'FB':
						object = {
							id:		 		params.id,
							type:			params.type,
							callback:		callback
						};
						break;
					default:
						object = {
							money: 		params.type,
							type:		'item',
							item:		params.type+"_"+params.id,
							votes:		params.price,
							sid:		params.id,
							count:		params.count,
							title:		params.title,
							description:	params.description || '',
							icon:		params.icon,
							tnidx:		App.user.id + App.time + '-' + params.type + "_" + params.id,
							callback:	params.callback
						}
				}
				
				ExternalApi.apiBalanceEvent(object);
			}
			
			function callback():void {
				if (params.callback != null)
					params.callback();
			}
		}
	}

}