package units 
{
	
	import com.google.analytics.ecommerce.Item;
	import com.greensock.TweenLite;
	import core.Post;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import ui.Hints;
	import wins.CompressorWindow;
	import wins.SimpleWindow;
	
	public class Compressor extends Walkgolden 
	{
		public var list:Array;
		
		public function Compressor(object:Object) 
		{
			started = object.started || 0;
			
			super(object);
				
			tip = function():Object {
				return {
					title:info.title,
					text:info.description
				};
			}
		}
		
		override public function click():Boolean 
		{					
			openProductionWindow();			
			return true;
		}
		
		public function openProductionWindow():void {
			if ((info.targets is Array) && info.targets.indexOf('Wanimal') != -1)
				info.targets.push('Dragon');
			
			list = Map.findUnitsByType(info.targets);
			
			if (!list || list.length == 0) {
				new SimpleWindow( {
					title:		info.title,
					text:		Locale.__e('flash:1454074244626')
				}).show();
			}else{
				new CompressorWindow( {
					target:	 	this,
					units:		list
				}).show();
			}
		}
		
		public function onCompressAction(unitSID:*):void {
			if (!App.data.storage[unitSID]) return;
			
			Post.send( {
				ctr:		type,
				act:		'compress',
				sID:		sid,
				id:			id,
				wID:		App.map.id,
				uID:		App.user.id,
				tID:		unitSID
			}, onCompressEvent, {sid:unitSID});
		}
		private function onCompressEvent(error:int, data:Object, params:Object):void {
			if (error) return;
			
			started = data.started;
			
			var unit:* = Map.findUnit(params.sid, data.id);
			unit.setStarted(data.reset);
			effectCount = unit.icount;
			unit.icount = data.icount;
			//unit.aura();
			
			effectUnit = unit as Unit;
			effectUnitsList = Map.findUnits([params.sid]);
			
			compressEffect();
		}
		
		private var effectCount:int;
		private var effectUnitsList:Array;
		private var effectUnit:Unit;
		private function compressEffect():void {
			
			/*effectUnit = null;
			effectUnitsList = Map.findUnits([unitSID]);
			
			for (var i:int = 0; i < effectUnitsList.length; i++) {
				if (effectUnitsList[i].id == unitID) {
					effectUnit = effectUnitsList[i] as Unit;
				}
			}*/
			
			if (!effectUnit) return;
			
			Cursor.type = 'move';
			effectUnit.move = true;
			App.map.moved = effectUnit;
			
			effectUnitsList.splice(effectUnitsList.indexOf(effectUnit), 1);
			
			setTimeout(compressMove, 100);
			
		}
		private function compressMove():void {
			if (!effectUnitsList || effectUnitsList.length == 0 || !Map.ready) return;
			
			var unit:Unit = effectUnitsList.shift() as Unit;
			
			TweenLite.to(unit, 0.1, { x:effectUnit.x, y:effectUnit.y, onComplete:function():void {
				if (!unit) return;
				
				effectCount += unit['icount'] || 1;
				
				unit.uninstall();
				Hints.text('x' + effectCount.toString(), 8, new Point(effectUnit.x, effectUnit.y), false, App.map);
				
				TweenLite.to(effectUnit, 0.1, { scaleX:1.25, scaleY:1.25, onComplete:function():void {
					TweenLite.to(effectUnit, 0.1, { scaleX:1, scaleY:1 });
				}});
				
				setTimeout(compressMove, 80);
				
			}} );
		}
		
		override public function goHome(_movePoint:Object = null):void {
				clearTimeout(timer);
				if (!walkable) return;
				
				if (_framesType != Personage.STOP) {
					var newtime:uint = Math.random() * 5000 + 5000;
					timer = setTimeout(goHome, newtime);
					return;
				}
				
				if (isRemove)
					return;
				
				if (move) {
					var time:uint = Math.random() * 5000 + 5000;
					timer = setTimeout(goHome, time);
					return;
				}
				
				if (workStatus == BUSY)
					return;
				
				var place:Object;
				if (_movePoint != null) {
					place = _movePoint;
				}else if (homeCoords != null) { 
					place = findPlaceNearTarget({info:homeCoords.info, coords:homeCoords.coords}, homeRadius);
				}else {
					place = findPlaceNearTarget({info:{area:{w:1,h:1}},coords:{x:this.movePoint.x, z:this.movePoint.y}}, homeRadius);
				}
				
				framesType = Personage.WALK;
				initMove(
					place.x,
					place.z,
					onGoHomeComplete
				);
		}
		
		public function onBoostAction(callback:Function = null):void {
			
			if (!App.user.stock.take(Stock.FANT, info.skip))
				return;
			
			Post.send( {
				ctr:	type,
				act:	'boost',
				uID:	App.user.id,
				wID:	App.map.id,
				sID:	sid,
				id:		id
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				started = data.started;
				
				if (callback != null)
					callback();
				
			});
			
		}
		
		override public function showIcon():void
		{
			clearIcon();
		}
	}

}