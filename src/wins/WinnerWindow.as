package wins 
{
	import buttons.Button;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import com.flashdynamix.motion.plugins.MovieClipTween;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import effects.OrbitalMagic;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import units.Thappy;
	import wins.Window;
	import ui.UserInterface;
	import com.greensock.easing.Cubic;
	import flash.utils.setTimeout;
	
	public class WinnerWindow extends Window
	{
		private var headerBmp:Bitmap;
		public static var target: Thappy;
		public static var alreadyInitialized:Boolean = false;
		public function WinnerWindow (settings:Object = null) {
		
			if (!settings) settings = { };
			settings['width'] =  500;
			settings['height'] =  450;
			settings['hasPaginator'] = false;
			settings['background'] = 'alertBacking';
			settings['hasExit'] = false;
			
			if (isWinner() )
				settings['title'] = Locale.__e ('flash:1466770887713');
			else 
				settings['title'] = Locale.__e('flash:1466770854568');
			super(settings);
			
		}
		public static function init (callback:Function):void
		{
			alreadyInitialized = true;
			callback();			
		}
		override public function close(e:MouseEvent = null):void 
		{
			alreadyInitialized = false;
			super.close(e);
		}
		override public function drawBackground():void {
			background =  backing(settings.width, settings.height, 50, settings['background']);;
			layer.addChild(background);
		}
		
		override public function drawBody():void {
			titleLabel.scaleX = titleLabel.scaleY = 0.7;
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = 115;
			
			drawDesc();
			drawGift();
		}
		
		protected function drawDesc():void {
			var teamFlag:Bitmap = new Bitmap();
			bodyContainer.addChild(teamFlag);
			var _name:String = target.viewTeam[target.team];			
			var descLabelText:String ;
			if (isWinner() )
				descLabelText = Locale.__e( 'flash:1466770935159');
			else
				descLabelText = Locale.__e( 'flash:1466770912784');
			
			var descLabel:TextField = drawText(descLabelText, {
				textAlign:		'center',
				autoSize:		'center',
				fontSize:		22,
				color:			0xfffcff,
				borderColor:	0x6b401a,
				distShadow:		0,
				width:			settings.width - 100
			});
			
			descLabel.wordWrap = true;
			
			bodyContainer.addChild(descLabel);
			Load.loading(Config.getImage("Thappy", _name), function(data:Bitmap):void {
				teamFlag.bitmapData = data.bitmapData;
				teamFlag.x = (settings.width - teamFlag.width) / 2 - 10;
				teamFlag.y = -teamFlag.height / 3;
				teamFlag.smoothing = true;
				
				descLabel.x = 50;
				descLabel.y = teamFlag.y + teamFlag.height + 10;
			});
		}
		
		public static function isWinner():Boolean {
			if (target.rate[target.team] > target.rate[Thappy.LEFT] || target.rate[target.team] > target.rate[Thappy.RIGHT])
				return true;
			else
				return false;
		}
		
		public var itemsContainer:Sprite = new Sprite();
		private function drawGift():void {	
			var separator:Bitmap = Window.backingShort(270, 'dividerLine', false);
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 240;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(270, 'dividerLine', false);
			separator2.x = separator.x;
			separator2.y = 375;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			var bg:Bitmap = Window.backing(270, 130, 50, 'fadeOutWhite');
			bg.alpha = 0.4;
			bg.x = separator.x;
			bg.y = 245;
			bodyContainer.addChild(bg);
			
			var title:TextField = Window.drawText(Locale.__e('flash:1440499603885'), {
				color:0xfcf164,
				fontSize:32,
				borderColor:0x752f00
			});
			title.width = title.textWidth + 10;
			title.x = bg.x + (bg.width - title.width)/2;
			title.y = 220;
			bodyContainer.addChild(title);
			
			drawMirrowObjs('titleDecRose', title.x + (title.width - title.textWidth) / 2 - 75, title.x + (title.width - title.textWidth) / 2 + title.textWidth + 75, title.y + (title.height - 40) / 2, false, false, false, 1, 1,bodyContainer);
		
			bodyContainer.addChild(itemsContainer);
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 265;
			itemsContainer.y = Ys;
			
			var giftTreasure:String;
			if (isWinner()) {
				giftTreasure = App.data.storage[target.sid].teams[target.team].info.win;
			} else {
				giftTreasure = App.data.storage[target.sid].teams[target.team].info.loss;
			}
			var giftItems:Object = App.data.treasures[giftTreasure][giftTreasure].item;
			var giftCounts:Object = App.data.treasures[giftTreasure][giftTreasure].count;
			var bonus:Object = { };
			for (var s:* in giftItems) {
				bonus[giftItems[s]] = giftCounts[s];
			}
			for (var i:* in bonus)
			{
				var item:PrizeItem = new PrizeItem(i, bonus[i], this);
				item.x = Xs;
				itemsContainer.addChild(item);
				
				Xs += item.background.width + 10;
			}
			
			itemsContainer.x = (settings.width - itemsContainer.width) / 2;
			
			if (!takeBttn){
				takeBttn = new Button({
					width: 		140,
					height:		48,
					caption:	Locale.__e('flash:1382952379737')
				});
				
				takeBttn.x = settings.width / 2 - takeBttn.width / 2;
				takeBttn.y = settings.height - takeBttn.height;
				takeBttn.addEventListener(MouseEvent.CLICK, onTakeBttnClick);
				if (target.takeBonus != 1)
					bodyContainer.addChild (takeBttn);
			}
			
		}
		private function onTakeBttnClick(e:MouseEvent):void 
		{
			target.takeBonus = 1;
			target.removable = true;
			Post.send({
				ctr:target.type,
				act:'bonus',
				uID:App.user.id,
				id:target.id,
				wID:App.user.worldID,
				sID:target.sid,
				tID:target.topID
			}, function(error:*, data:*, params:*):void 
			{
				if (error) {
					Errors.show(error, data);
					return;
				}
				
				//wauEffect();
				App.user.stock.addAll(data.cbonus);
				//App.user.stock.addAll(data.bbonus);
				flyBonus(data.cbonus);
				close();
			})
		}
		
		private function flyBonus(data:Object):void {
			var targetPoint:Point = Window.localToGlobal(takeBttn);
			targetPoint.y += takeBttn.height / 2;
			for (var _sID:Object in data)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data[sID])
				{
					var nominal:uint = Number(_nominal);
					var count:uint = Number(data[sID][_nominal]);
				}
				
				var item:*;
				
				for (var i:int = 0; i < count; i++)
				{
					item = new BonusItem(sID, nominal);
					App.user.stock.add(sID, nominal);	

					item.cashMove(targetPoint, App.self.windowContainer)
				}			
			}
			SoundsManager.instance.playSFX('reward_1');
	}
		
		private var takeBttn:Button;
		private var rewardCont:LayerX = new LayerX();
		protected var reward:Bitmap = new Bitmap();
		protected function wauEffect():void {
			if (reward.bitmapData != null) {
				var rewardCont:Sprite = new Sprite();
				App.self.contextContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				
				var glow:Bitmap = new Bitmap(UserInterface.textures.actionGlow);
				glow.x = -glow.width / 2;
				glow.y = -glow.height + 90;
				glowCont.addChild(glow);
				
				var glow2:Bitmap = new Bitmap(UserInterface.textures.actionGlow);
				glow2.scaleY = -1;
				glow2.x = -glow2.width / 2;
				glow2.y = glow.height - 90;
				glowCont.addChild(glow2);
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(reward.width, reward.height, true, 0));
				bitmap.bitmapData = reward.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				rewardCont.addChild(bitmap);
				
				rewardCont.x = layer.x + bodyContainer.x + this.rewardCont.x;
				rewardCont.y = layer.y + bodyContainer.y + this.rewardCont.y;
				
				function rotate():void {
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				
				TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
					setTimeout(function():void {
						App.self.setOffEnterFrame(rotate);
						glowCont.alpha = 0;
						var bttn:* = App.ui.bottomPanel.bttnMainStock;
						var _p:Object = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
						SoundsManager.instance.playSFX('takeResource');
						TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
							TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {}} );
						}} );
					}, 3000)
				}} );
			}
		}
	}

}


import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.text.TextField;
import wins.Window;
internal class PrizeItem extends LayerX {
	public var background:Bitmap = new Bitmap();
	private var shape:Shape;
	private var window:*;
	public function PrizeItem(sID:int, count:int, window:*, settings:Object = null) {
		this.window = window;	
		
		background = new Bitmap(new BitmapData(100, 100, true, 0xffffff));
		addChild(background);
		
		shape = new Shape();
		shape.graphics.beginFill(0xc6c7b9, 1);
		shape.graphics.drawCircle(50, 50, 50);
		shape.graphics.endFill();
		background.bitmapData.draw(shape);
		
		var prizeIcon:Bitmap = new Bitmap();
		addChild(prizeIcon);
		
		if (count != 0) {
			drawCount(count);
		}
		
		tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
		
		drawTitle(sID);
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), function(data:*):void {
			prizeIcon.bitmapData = data.bitmapData;
			Size.size(prizeIcon, 80, 80);
			prizeIcon.x = (background.width - prizeIcon.width) / 2;
			prizeIcon.y = 10;
			prizeIcon.smoothing = true;			
		});
	}
	
	private function drawCount(count:int):void {
		var textCount:TextField = Window.drawText('x' + String(count) , {
			color:0x7b3e07,
			fontSize:26,
			borderColor:0xffffff
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = background.x + background.width - textCount.width;
		textCount.y = background.y + background.height - 25;
		addChild(textCount);
	}
	
	private function drawTitle(sid:int):void {
		var textCount:TextField = Window.drawText(App.data.storage[sid].title, {
			color:0xffffff,
			fontSize:20,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = background.x + (background.width - textCount.width)/2;
		textCount.y = 0;
		addChild(textCount);
	}
}
