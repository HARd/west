package units 
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	import wins.OpenZoneWindow;
	import wins.SimpleWindow;
	import wins.Window;
	public class Exresource extends Resource 
	{
		public var resource_state:int = 0;
		public function Exresource(object:Object) 
		{
			
			super(object);
			
			if (object.hasOwnProperty('state')) {
				if (info.unlimited == 1 && object.state == 2)
					object.state = 0;
				
				this.resource_state = object.state;
			}
			
			rotateable = false;
			removable = false;
			stockable = false;
			
			tip = function():Object {
				if (resource_state == 2) {
					return {
						title:info.title,
						text:info.description
					};
				}
				if (end != 0) {
					if (end > App.time) {
						return {
							title:info.title,
							text:Locale.__e('flash:1444636170940', TimeConverter.timeToStr(end - App.time)),
							timer:true
						}
					}else {
						return {
							title:info.title,
							text:Locale.__e('flash:1445959408602')
						}
					}
				}
				
				if (info.hasOwnProperty('require')) {
					var normalMaterials:Array = [];
					for (var rid:* in info.require) {
						// Если не системный
						if (App.data.storage.hasOwnProperty(rid) && App.data.storage[rid].mtype != 3) {
							normalMaterials.push(rid);
						}
					}
					
					if (App.user.mode == User.GUEST) {
						rid = 6;
						normalMaterials = [rid];
					}
					
					if (normalMaterials.length > 0) {
						var bitmap:Bitmap = new Bitmap(new BitmapData(50,50,true,0));
						Load.loading(Config.getIcon(App.data.storage[rid].type, App.data.storage[rid].preview), function(data:Bitmap):void {
							bitmap.bitmapData.draw(data, new Matrix(0.5, 0, 0, 0.5));
						});
						
						return {
							title:info.title,
							text:info.description,
							desc:Locale.__e('flash:1383042563368'),
							icon:bitmap,
							iconScale:0.6,
							count:(App.user.mode == User.GUEST) ? 1 : info.require[rid]
						};
					}
				}
				
				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		override public function onLoad(data:*):void {
			super.onLoad(data);
			textures = data;
			updateLevel();
		}
		
		public function updateLevel(checkRotate:Boolean = false):void 
		{
			if (textures == null) return;
			
			var levelData:Object;			
			levelData = textures.sprites[resource_state];
			
			if (checkRotate && rotate == true) {
				flip();
			}
			
			if (resource_state != 0)
			{
				var backBitmap:Bitmap = new Bitmap(bitmap.bitmapData);
				backBitmap.x = bitmap.x;
				backBitmap.y = bitmap.y;
				addChildAt(backBitmap, 0);
				
				bitmap.alpha = 0;
				
				App.ui.flashGlowing(this, 0xFFF000);
				
				TweenLite.to(bitmap, 0.4, { alpha:1, onComplete:function():void {
					removeChild(backBitmap);
					backBitmap = null;
				}});
			}
			
			if (levelData) draw(levelData.bmp, levelData.dx, levelData.dy);
		}
		
		override public function click():Boolean {
			if (!checkBuilding()) return false;
			
			switch (resource_state) {
				case 0:
					openConstructWindow();
					break;
				case 1:
					super.click();
					break;
				case 2:
					new SimpleWindow( {
						title:Locale.__e('flash:1382952379893'),
						text:Locale.__e('flash:1475238158810'),
						popup:true
					}).show();
					break;
			}
			
			return true;
		}
		
		public function checkBuilding():Boolean {
			if (info.hasOwnProperty('ref')) {
				for (var sid:* in info.ref) {
					var lvl:int = info.ref[sid];
				}
				
				var build:Array = Map.findUnits([sid]);
				if (build.length > 0) {
					for each (var b:* in build) {
						if (b.level >= lvl)
							return true;
					}
					
					App.map.focusedOn(build[0], true);
				}
				
				return false;
			}
			
			return true;
		}
		
		public function openConstructWindow():void {
			new OpenZoneWindow( {
				target:this,
				requires:	info['in'],
				title:		info.title,
				description:info.description,
				onUpgrade:	startAction
			}).show();
		}
		
		public function startAction():void {
			if (!App.user.stock.takeAll(info['in'])) return;
			
			Window.closeAll();
			
			Post.send({
				ctr:'exresource',
				act:'start',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				resource_state = 1;
				capacity = info.count;
				
				updateLevel();
			} );
		}
		
		override public function takeResource(count:uint = 1):void
		{
			if (capacity - count >= 0)	
				capacity -= count;
			if (capacity == 0) {
				if (info.hasOwnProperty('unlimited') && info.unlimited == 1) {
					resource_state = 0;
					updateLevel();
				}else {
					resource_state = 2;
					updateLevel();
				}
			}
		}
		
		override public function set balance(toogle:Boolean):void {
			if (resource_state == 2) return;
			
			super.balance = toogle;
		}
		
	}

}