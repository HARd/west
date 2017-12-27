package units 
{
	import astar.AStarNodeVO;
	import core.Post;
	import ui.Cursor;
	/**
	 * ...
	 * @author 
	 */
	public class Fake extends Decor
	{
		private var getTip:Function = null;
		public function Fake(object:Object) 
		{
			super(object);
			
			if (object.callback) callback = object.callback;
			if (object.getTip) getTip = object.getTip;
			moveable = false;
			clickable = false;
			touchable = false;
			removable = false;
			rotateable = false;
			stockable = false;
			
			switch(sid) {
				case 276:
				case 277:
				case 297:
					moveable = true;
					removable = true;
					clickable = true;
					touchable = true;
					rotateable = true;
					stockable = true;
					break;
				case 784:
					moveable = false;
					removable = false;
					clickable = true;
					touchable = true;
					rotateable = false;
					stockable = false;
					break;
			}
			
			tip = function():Object {
				if (getTip != null) {
					return getTip();
				}

				return {
					title:info.title,
					text:info.description
				};
			};
		}
		
		public function onDeleteHut(e:* = null):void {
			App.self.removeEventListener(AppEvent.ON_DELETE_FAKE_HUT, onDeleteHut);
			//uninstall();
			removable = true;
			remove();
			free();
		}
		
		override public function onApplyRemove(callback:Function = null):void
		{
			Post.send( {
				ctr:this.type,
				act:'remove',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				id:this.id
			}, onRemoveAction, {callback:callback});
			
			this.visible = false;
		}
		
		override public function onLoad(data:*):void {
			var level:int = 0;
			if (sid == 275 && App.user.world.zones.indexOf(182) != -1) {
				level = 1;
			}
			
			textures = data;
			var levelData:Object = textures.sprites[level];
			draw(levelData.bmp, levelData.dx, levelData.dy);
			
			framesType = info.view;
			if (textures && textures.hasOwnProperty('animation')) 
				initAnimation();
				
			if (sid == 781) {
				var qID:int = 297;
				if (App.user.quests.data.hasOwnProperty(qID) && App.user.quests.data[qID].finished > 0)
				{
					onDeleteHut();
				} else {
					App.self.addEventListener(AppEvent.ON_DELETE_FAKE_HUT, onDeleteHut);
				}
			}
		}
		
		override public function calcState(node:AStarNodeVO):int
		{
			return EMPTY;
		}
		
		override public function buyAction():void 
		{
			Post.send( {
				ctr:this.type,
				act:'buy',
				uID:App.user.id,
				wID:App.user.worldID,
				sID:this.sid,
				x:coords.x,
				z:coords.z
			}, onBuyAction);
		}
		
		override public function click():Boolean {
			if (callback != null) {
				callback();
				return true;
			}
			if (!super.click()) return false;
			
			return true;
		}
		override public function set touch(touch:Boolean):void 
		{
			if (sid != 784) return;
			
			super.touch = touch;
		}
	}
}