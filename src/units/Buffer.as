package units 
{
	import core.Load;
	public class Buffer extends Building
	{
		
		public function Buffer(object:Object) 
		{
			if (!object) object = { };
			super(object);
			
			stockable = false;
			removable = false;
		}
		
		override public function load():void {
			Load.loading(Config.getSwf(type, info.view), onLoad);
		}
		
		override protected function onBuyAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				return;
			}
			this.id = data.id;
			
			App.user.giftsLimit += App.data.storage[sid].count;
		}
		
		override protected function onStockAction(error:int, data:Object, param:Object):void {
			super.onStockAction(error, data, param);
			
			App.user.giftsLimit += App.data.storage[sid].count;
		}
		
		override public function onRemoveAction(error:int, data:Object, params:Object):void {
			if (error) {
				Errors.show(error, data);
				this.visible = true;
				return;
			}
			World.removeBuilding(this);
			uninstall();
			if (params.callback != null) {
				params.callback();
			}
			
			App.user.giftsLimit -= App.data.storage[sid].count;
		}
		
		override public function isPresent():Boolean {
			return false;
		}
		
		override public function click():Boolean {
			return false;
		}
		
	}

}