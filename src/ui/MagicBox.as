package ui 
{
	import com.greensock.TweenLite;
	import core.Load;
	import core.Post;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import units.Anime;
	import wins.Window;
	
	public class MagicBox extends LayerX
	{
		
		public static const WAIT:uint = 0;
		public static const READY:uint = 1;
		
		public static var storageStart:int = 0;
		public static var storageTime:int = 0;
		public static var storageID:int = 0;
		public static var bonusID:int = NaN;
		
		private var _state:uint = 99;
		private var glowCont:Sprite;
		private var textCont:Sprite;
		private var bitmap:Bitmap;
		private var anime:Anime;
		private var preloader:Preloader;
		private var backing:Bitmap;
		private var timerLabel:TextField;
		private var textAnime:Boolean = true;
		
		public function MagicBox() {
			backing = new Bitmap(Window.textures.buildingsLockedBacking, 'auto', true);
			backing.scaleX = backing.scaleY = 0.75;
			addChild(backing);
			
			var glow:Bitmap = new Bitmap(Window.textures.glow, 'auto', true);
			glow.scaleX = 0.2;
			glow.scaleY = 0.38;
			glow.x = -glow.width / 2;
			glow.y = -glow.height / 2;
			glow.alpha = 0.5;
			glowCont = new Sprite();
			glowCont.addChild(glow);
			glowCont.x = glow.width / 2 + (backing.width - glowCont.width) / 2;
			glowCont.y = glow.height / 2 + (backing.height - glowCont.height) / 2;
			glowCont.visible = false;
			addChild(glowCont);
			
			timerLabel = Window.drawText('', {
				width:		backing.width,
				fontSize:		22,
				color:			0xfdfdfd,
				borderColor:	0x794515,
				textAlign:		'center'
			});
			
			textCont = new Sprite();
			textCont.x = backing.x + timerLabel.width / 2 - 5;
			textCont.y = backing.y + backing.height - timerLabel.height/2 + 10 ;
			
			textCont.addChild(timerLabel);
			//timerLabel.x = backing.x + 5;
			//timerLabel.y = backing.y + backing.height - timerLabel.height + 10;
			addChild(textCont);
			
			if (!App.user.quests.data.hasOwnProperty(App.data.bonus['1'].quest) || App.user.quests.data[App.data.bonus['1'].quest].finished == 0) {
				visible = false;
				return;
			}else {
				visible = true;
			}
			
			tip = function():Object {
				return {
					title:App.data.bonus['1'].title,		//Locale.__e("flash:1413192105251"),
					text:App.data.bonus['1'].description	//Locale.__e("flash:1413192192977")
				};
			}
			
			if (storageStart + storageTime > App.time) {
				state = WAIT;
			}else {
				state = READY;
			}
			
			App.self.setOnEnterFrame(glowRotation);
			addEventListener(MouseEvent.CLICK, onBoxClick);
		}
		
		public static function init():Boolean {
			var s:String = '1';
			if (!App.data.bonus || !App.data.bonus[s]) return false;
			
			var quest:int = App.data.bonus[s].quest;
			/*App.user.storageStore('bonus', { '1': [ 0, App.user.quests.data[quest].finished + App.data.bonus[s].devel.req[1].t ] } );
			return false;*/
			
			if (App.user.quests.data.hasOwnProperty(quest) && App.user.quests.data[quest].finished > 0) {
				var data:Object = App.user.storageRead('bonus', null);
				
				if (!data || !data[s]) {
					data = { };
					storageID = 0;
					data[s] = [ 0, App.time ];
					App.user.storageStore('bonus', data);
				}else {
					storageID = data[s][0];
				}
				
				if (App.data.bonus[s].devel.req[storageID + 1]) {
					storageStart = data[s][1];
					storageTime = App.data.bonus[s].devel.req[storageID + 1].t;
					bonusID = 1;
					
					return true;
				}
			}else {
				return true;
			}
			
			return false;
		}
		
		public function onBoxClick(e:MouseEvent):void {
			if (storageStart + storageTime < App.time) {
			
				Post.send( {
					ctr:	'bonus',
					act:	'storage',
					uID:	App.user.id,
					sID:	bonusID
				}, function(error:int, data:Object, params:Object):void {
					if (error) return;
					
					if (data.sbonus) {
						var object:Object = {
							time:		data.sbonus['1']['1'],
							id:			data.sbonus['1']['0']
						}
						
						if (data.bonus) {
							var point:Point = new Point(App.self.stage.stageWidth - App.map.x - 110, App.self.stage.stageHeight - App.map.y - 120);
							Treasures.bonus(Treasures.convert(data.bonus), point);
						}
						
						storageStart = object.time;
						storageID = object.id;
						if (App.data.bonus['1'].devel.req[storageID + 1].t) {
							storageTime = App.data.bonus['1'].devel.req[storageID + 1].t;
						}else {
							hide();
							dispose();
							return;
						}
						
						state = WAIT;
					}
					
				});
			}
		}
		
		public function get state():uint {
			return _state;
		}
		public function set state(value:uint):void {
			if (value != _state) {
				_state = value;
				checkState();
				
				if (_state == WAIT) {
					glowCont.visible = false;
					if (anime) {
						anime.visible = true;
						TweenLite.to(anime, 1, { alpha:1 } );
					}
					if (bitmap) {
						TweenLite.to(bitmap, 1, { alpha:0, onComplete:function():void {
							bitmap.visible = false;
						}} );
					}
				}else if (_state == READY) {
					glowCont.visible = true;
					if (bitmap) {
						bitmap.visible = true;
						TweenLite.to(bitmap, 1, { alpha:1 } );
					}
					if (anime) {
						TweenLite.to(anime, 1, { alpha:0, onComplete:function():void {
							anime.visible = false;
						}} );
					}
				}
			}
		}
		
		private var isTimer:Boolean = false;
		public function checkState():void {
			if (state == WAIT) {
				if (!isTimer) {
					isTimer = true;
					timerLabel.visible = true;
					
					App.self.setOnTimer(timer);
					App.self.setOffTimer(tweenLabelText);
				}
				
				if (!anime) {
					Load.loading(Config.getSwf('Content', 'dragon_box'), onLoad);
				}
			}else if (state == READY) {
				isTimer = false;
				//timerLabel.visible = false;
				
				timerLabel.text = Locale.__e("flash:1414160740806");
				timerLabel.x = -timerLabel.textWidth / 2;
				timerLabel.y = -timerLabel.textHeight / 2;
				App.self.setOnTimer(tweenLabelText);
				
				App.self.setOffTimer(timer);
				
				if (!bitmap) {
					Load.loading(Config.getIcon('Content', 'dragon_box'), onIconLoad);
				}
			}
		}
		
		private function tweenLabelText():void
		{
			if (textAnime)
			{
				textAnime = false;
				timerLabel.text = Locale.__e("flash:1414160740806");
				timerLabel.x = -timerLabel.textWidth / 2;
				timerLabel.y = -timerLabel.textHeight / 2;
					TweenLite.to(textCont, 0.2, { scaleX:1.1, scaleY:1.1, onCompleteParams:[textCont], onComplete:function(... args):void {
					TweenLite.to(textCont, 0.2, {scaleX:1, scaleY:1 } );
				}} );
			}
			else
				textAnime = true;
		}
		
		private function onLoad(swf:*):void {
			if (anime && contains(anime)) removeChild(anime);
			
			anime = new Anime(swf, { w:80, h:80 } );
			anime.x = backing.x + (backing.width - anime.width) / 2;
			anime.y = backing.y + (backing.height - anime.height) / 2;
			addChildAt(anime, getChildIndex(textCont));
		}
		private function onIconLoad(data:Bitmap):void {
			if (bitmap && contains(bitmap)) removeChild(bitmap);
			
			bitmap = new Bitmap(data.bitmapData, 'auto', true);
			bitmap.smoothing = true;
			bitmap.x = backing.x + (backing.width - bitmap.width) / 2 + 2;
			bitmap.y = backing.y + (backing.height - bitmap.height) / 2 - 4;
			addChildAt(bitmap, getChildIndex(textCont));
		}
		
		public function glowRotation(e:Event = null):void {
			if (glowCont.visible) {
				glowCont.rotation += 0.5;
			}
		}
		public function timer():void {
			var time:int = storageStart + storageTime - App.time;
			if (time > 0) {
				timerLabel.text = TimeConverter.timeToStr(time);
				timerLabel.x = -timerLabel.textWidth / 2;
				timerLabel.y = -timerLabel.textHeight / 2;
			}else {
				state = READY;
			}
		}
		
		public function show():void {
			this.visible = true;
			this.alpha = 0;
			TweenLite.to(this, 0.3, { alpha:1 } );
		}
		public function hide():void {
			this.visible = true;
			TweenLite.to(this, 0.3, { alpha:0, onCompleteParams:[this], onComplete:function(... args):void {
				args[0].visible = false;
			}} );
		}
		
		public function dispose():void {
			if (anime && contains(anime)) removeChild(anime);
			App.self.setOffTimer(timer);
			App.self.setOffEnterFrame(glowRotation);
		}
	}

}