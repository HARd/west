package effects
{
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import silin.filters.ColorAdjust;
	import wins.Window;
	
	/**
	 * ...
	 * @author 
	 */
	public class Effect extends Sprite
	{
		private var content:*;
		private var layer:*;
		public function Effect(type:String, layer:Sprite, info:Object = null)
		{
			this.layer = layer;
			this.layer.addChild(this);
			
			switch(type)
			{
				case "OrbitalMagic":
						content = new OrbitalMagic(0.2, 360);
					break;
				case "FlashLight":
						content = new FlashLight(info);
					break;
				case "Sparks":
						content = new Sparks();
					break;	
				
			}
			
			if(content != null)
				addChild(content);
		}
		
		public static function light(target:*, brightness:Number = 0, saturation:Number = 1):void {
			if(target is DisplayObject) {
				var mtrx:ColorAdjust = new ColorAdjust();
				mtrx.saturation(saturation);
				mtrx.brightness(brightness);
				target.filters = [mtrx.filter];
			}
		}
		
		public function dispose():void {
			if (content != null) {
				content.dispose();
				removeChild(content);
			}
				
			if (layer is DisplayObject && layer.contains(this))
				layer.removeChild(this); 
				
			content = null;	
		}
		
		public static function wowEffect(sid:*, point:Point = null):void {
			if (!App.data.storage.hasOwnProperty(sid)) return;
			
			var info:Object = App.data.storage[sid];
			
			if (!point) point = new Point(App.self.stage.stageWidth / 2, App.self.stage.stageHeight / 2);
			
			var url:String = Config.getIcon(info.type, info.preview);
			if (info.type == 'Clothing' && [].indexOf('')) {
				// Превью для вещей. Папка images/content. Первое слово до "_"
				var preview:String = info.preview.substring(0, info.preview.indexOf('_')) + '_cloth';
				if (['autumn_cloth', 'winter2_cloth'].indexOf(preview) != -1) {
					url = Config.getImage('content', preview);
				}
			}
			
			Load.loading(url, function(reward:Bitmap):void {
				var rewardCont:Sprite = new Sprite();
				App.self.faderContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow.x = -glow.width / 2;
				glow.y = -glow.height + 90;
				glowCont.addChild(glow);
				var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow2.scaleY = -1;
				glow2.x = -glow2.width / 2;
				glow2.y = glow.height - 90;
				glowCont.addChild(glow2);
				
				if (reward.width > 160) {
					reward.width = 160;
					reward.scaleY = reward.scaleX;
					if (reward.height > 160) {
						reward.height = 160;
						reward.scaleX = reward.scaleY;
					}
				}
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(reward.width, reward.height, true, 0));
				bitmap.bitmapData = reward.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				rewardCont.addChild(bitmap);
				
				rewardCont.x = point.x;
				rewardCont.y = point.y;
				
				function rotate():void {
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				
				TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.2, scaleY:1.2, ease:Cubic.easeInOut, onComplete:function():void {
					setTimeout(function():void {
						App.self.setOffEnterFrame(rotate);
						glowCont.alpha = 0;
						var bttn:* = App.ui.bottomPanel.bttnMainStock;
						var p:Object = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
						SoundsManager.instance.playSFX('takeResource');
						TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:p.x, y:p.y, onComplete:function():void {
							TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {
								if (rewardCont.parent == App.self.faderContainer)
									App.self.faderContainer.removeChild(rewardCont);
							}} );
						}} );
					}, 3000);
				}} );
			});
		}
	}
}