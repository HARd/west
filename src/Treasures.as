package
{
	import flash.geom.Point;
	import units.Lantern;
	
	/**
	 * ...
	 * @author 
	 */
	public class Treasures
	{
		public static const bonusDropArea:Object = { w:250, h:150 };
		public static const TIME_DELAY:int = 100;
		
		public static function onError(error:int):void
		{
			
		}
		
		public static function treasureToObject(treasure:Object):Object {
			var result:Object = { };
			
			for (var s:* in treasure) {
				if (treasure[s] is int) {
					result[s] = treasure[s];
				}else{
					result[s] = 0;
					for (var count:* in treasure[s]) {
						result[s] = int(treasure[s][count]) * int(count);
					}
				}
			}
			
			return result;
		}
		
		public static function convert(data:Object):Object {
			var result:Object = { };
			for (var sID:* in data) {
				result[sID] = { }
				result[sID][data[sID]] = 1;
				//result[sID]['1'] = data[sID];
			}
			return result;
		}
		
		/**
		 * Обрабатываем полученный бонус
		 * @param	data
		 */
		private static var timeToDrop:int = 0;
		
		public static function bonus(data:Object, targetPoint:Point, destObject:* = null, addToStock:Boolean = true, callback:Function = null, onFinish:Function = null, dropArea:Object = null):void
		{
			timeToDrop = 0;
			for (var _sID:Object in data)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data[sID])
				{
					var nominal:uint = Number(_nominal);
					var count:uint = Number(data[sID][_nominal]);
				}
				
				if (sID == 933 || sID == 1580 || sID == 1624) {
					App.user.stock.add(sID, nominal);
					continue;
				}
				
				if (sID == 27 && count == 1 && nominal > 1) { //золотой самородок
					count = nominal;
					nominal = 1;
				}
				
				if (sID == Stock.COINS || sID == Stock.FANTASY || sID == Stock.EXP || sID == Stock.FANT || sID == 27) {
					var num:int = nominal * count;
					addBonusItems(num, sID, targetPoint, dropArea, addToStock);
				}else {
					var item:*;
					
					for (var i:int = 0; i < count; i++)
					{
						if(App.data.storage[sID].type == 'Lamp')
						{
							item = new Lantern( { sid:sID, 
								position: {
									x:targetPoint.x,
									y:targetPoint.y + 200
								}
							});
							continue;
						}
						
						if (destObject) {
							item = new BonusItem(sID, nominal, true, destObject, dropArea);
						}else{
							item = new BonusItem(sID, nominal, true, null, dropArea);
							if (addToStock)
								App.user.stock.add(sID, nominal);//false
						}
						
						item.x = targetPoint.x;
						item.y = targetPoint.y;
						
						if (dropArea)
							dropArea.addChild(item);
						else
							App.map.mTreasure.addChild(item);
						
						item.move(timeToDrop);
						
						timeToDrop += TIME_DELAY;
					}
				}
				
				if(callback != null)
					item.onStartDrop = callback;
					
				
			}
			
			if (item !=null && onFinish != null){
				item.onCash = onFinish;
			}
			SoundsManager.instance.playSFX('reward_1');
		}
		
		public static const NOMINAL_1:int = 1;
		public static const NOMINAL_2:int = 15;
		public static const NOMINAL_3:int = 100;
		
		public static function addBonusItems(count:int, sid:int, targetPoint:Point, dropArea:Object = null, addToStock:Boolean = true):void
		{
			var item:*;
			
			var i:int = 0;
			
			var nominalType1:int = NOMINAL_1;
			var nominalType2:int = NOMINAL_2;
			var nominalType3:int = NOMINAL_3;
			
			var countType1:int = 0;
			var countType2:int = 0;
			var countType3:int = 0;
			
			var leftCount:int = count ;
			
			if (count < nominalType2) {
				countType1 = count;
			}else if (count < nominalType3) {
				countType2 = Math.floor(count / nominalType2);
				countType1 = count - countType2 * nominalType2;
			}else {
				countType3 = Math.floor(count / nominalType3);
				leftCount -= countType3 * nominalType3;
				countType2 = Math.floor(leftCount / nominalType2);
				countType1 = leftCount - countType2 * nominalType2;
			}
			
			for (i = 0; i < countType1; i++ ) {
				addItem(sid, nominalType1, dropArea);
			}
			
			for (i = 0; i < countType2; i++ ) {
				addItem(sid, nominalType2, dropArea);
			}
			
			for (i = 0; i < countType3; i++ ) {
				addItem(sid, nominalType3, dropArea);
			}
			
			if (addToStock)
				App.user.stock.add(sid, count);
			
			function addItem(_sid:int, _nominal:int, dropArea:Object = null):void
			{
				item = new BonusItem(_sid, _nominal, true, null, dropArea);
				item.x = targetPoint.x;
				item.y = targetPoint.y;
				
				if (dropArea)
					dropArea.addChild(item);
				else
					App.map.mTreasure.addChild(item);
				
				item.move(timeToDrop);
				timeToDrop += TIME_DELAY;
			}
		}
		
		/**
		 * Обрабатываем полученный бонус пакетами
		 * @param	data
		 */
		public static function packageBonus(data:Object, targetPoint:Point, onFinish:Function = null):void
		{
			var packges:Array = [];
			var coins:Object = {};
			var exp:Object = {};
			var materials:Object = {};
			var collections:Object = {};
			
			for (var _sID:* in data)
			{
				switch(_sID) 
				{
					case Stock.COINS:
							coins[Stock.COINS] = data[Stock.COINS];
						break;
						
					case Stock.EXP:
							exp[Stock.EXP] = data[Stock.EXP];
						break;	
						
					default:
							if (App.data.storage[_sID].mtype == 4)
								collections[_sID] = data[_sID];
							else
								materials[_sID] = data[_sID];
						break;
				}
			}
			
			packges.push(coins);
			packges.push(exp);
			packges.push(materials);
			packges.push(collections);
			
			for (var i:int = 0; i < packges.length; i++) {
				var pack:BonusPack = new BonusPack(packges[i], targetPoint, i);
			}
			
			if(onFinish != null)
			pack.onFinish = onFinish;
		}
		
		public static function generate(type:String, view:String):Object {
			
			var items:Array = [];
			var response:Object = {};
			var treasure:Object = App.data.treasures[type][view];
			var probabilities:String = ""
			
			for (var i:* in treasure['item']) {
				items.push( { sID:treasure['item'][i], id:i } );
			}
			items.sortOn(sID);
			
			
			for (i = 0; i < items.length; i++) {
				
				var id:int = items[i].id;
				var count:int = treasure['count'][id];
				var probability:Number = treasure['probability'][id];
				var _try:int = treasure['try'][i];
				var sID:uint = items[i].sID;
				
				
				for (var j:int = 0; j < _try; j++) {
					var random:Number = int(Math.random() * 999);
					probabilities += Treasures.toFormat(random);
					
					if (random < probability * 10)
						
						if (response[sID] == null)
							response[sID] = 1;
						else
							response[sID] ++;
				}
			}
			
			return response;
		}
		
		public static function toFormat(value:int):String {
			var str:String = String(value);
			if (str.length == 1){
				return '00' + str;
			}else if (str.length == 2){
				return '0' + str;
			}
			return str;
		}
		
		// Объекты клада
		public static function getTreasureItems(treasure:String, subtreasure:String = ''):Object {
			var result:Object = { };
			var treasureInfo:Object;
			
			if (App.data.treasures.hasOwnProperty(treasure)) {
				if (subtreasure.length > 0 && App.data.treasures[treasure].hasOwnProperty(subtreasure)) {
					treasureInfo = App.data.treasures[treasure][subtreasure];
				}else if (App.data.treasures[treasure].hasOwnProperty(treasure)) {
					treasureInfo = App.data.treasures[treasure][treasure];
				}
				
				if (treasureInfo && treasureInfo.item is Array && treasureInfo.item.length > 0) {
					for (var i:int = 0; i < treasureInfo.item.length; i++) {
						result[treasureInfo.item[i]] = treasureInfo.count[i] * treasureInfo['try'][i];
					}
				}
				
				if (treasureInfo && treasureInfo.item is Object) {
					for (var s:* in treasureInfo.item) {
						result[treasureInfo.item[s]] = treasureInfo.count[s] * treasureInfo['try'][s];
					}
				}
			}
			
			return result;
		}
	}
}


import flash.geom.Point;
import flash.utils.setTimeout;

internal class BonusPack {
	
	private var data:Object;
	private var targetPoint:Point;
	public var onFinish:Function = null;
	
	public function BonusPack(data:Object, targetPoint:Point, i:int) 
	{
		this.data = data;
		this.targetPoint = targetPoint;
		setTimeout(bonus, (i * 1000) + 10);
	}
	
	public function bonus():void 
	{
		if (onFinish != null)
		{
			trace('');
		}
		Treasures.bonus(data, targetPoint,null, true, null, onFinish);
		data = null;
		targetPoint = null;
	}
}