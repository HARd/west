package wins {
	
	import adobe.utils.CustomActions;
	import api.ExternalApi;
	import buttons.Button;
	import buttons.CheckboxButton;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import core.Post;
	import core.WallPost;
	import effects.Particles;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import strings.Strings;
	import ui.UserInterface;
	
	public class LevelUpWindow extends Window {
		
		public static const USUAL_LEVEL:uint = 1;
		public static const KEY_LEVEL:uint = 2;
		public static const NEXT_LEVEL:uint = 3;
		public static var needBonusWindow:Boolean = false;
		
		public var items:Array = new Array();
		public var label:Bitmap;
		public var tellBttn:Button;
		public var bg:Bitmap;
		public var screen:Bitmap;
		public var okBttn:Button;
		
		private var checkBox:CheckboxButton;
		private var isShort:Boolean = false;
		
		public var mode:uint = 1;
		public var viewLevel:int = 1;
		public var nextLevel:int = 1;
		public static var keyLevels:Object;
		
		public function LevelUpWindow(settings:Object = null) {
			setKeyLevels();
			mode = USUAL_LEVEL;
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 520;
			settings['height'] = 490;
			settings['hasTitle'] = false;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['itemsOnPage'] = 3;
			settings['escExit'] = false;
			settings['faderClickable'] = false;
			settings['forcedClosing'] = false;
			settings['bonus'] = App.data.levels[App.user.level].bonus;
			settings['content'] = [];
			settings['openSound'] = 'sound_7';
			settings["titleDecorate"] = false;
			settings["background"] = 'alertBacking';
			settings['strong'] = true;
			settings['autoClose'] = false;
			
			viewLevel = settings.forceLevel?settings.forceLevel:App.user.level;
			
			for each(var k:* in keyLevels.levelList) {
				if (int(k) > App.user.level) {
					nextLevel = int(k);
					break;
				}
			}
			
			if (settings.nextKeyLevel) {
				viewLevel = nextLevel;
			}else {
				if (keyLevels.levelList.indexOf(viewLevel) != -1) {
					mode = KEY_LEVEL;
				}
			}
			
			/*for (var sID:* in App.data.storage) {
				var item:Object = App.data.storage[sID];
				if (item.visible != 0) {
					if (item.type == 'Thimbles' || item.type == 'Technology') continue;
					if (item.level && App.user.level == item.level) {
						settings.content.push(sID);
					} else if (item.devel && item.devel.req[1].l == App.user.level) {
						settings.content.push(sID);
					} else if (item.instance && item.instance.level[1] == App.user.level) {
						settings.content.push(sID);
					}
				}
			}*/
			
			var contentLevel:int = settings.showCurrent?keyLevels.hasOwnProperty(viewLevel)?viewLevel:nextLevel:nextLevel;
			if (mode == KEY_LEVEL) contentLevel = viewLevel;
			for (var s:* in keyLevels[contentLevel].bonus) {
				var bInfo:Object = { };
				bInfo[int(s)] = keyLevels[contentLevel].bonus[s];
				settings.content.push(bInfo);
			}
			
			if (settings.nextKeyLevel) mode = NEXT_LEVEL;
			
			if (settings.content.length == 0)
				isShort = true;
			
			super(settings);
		}
		
		private function setKeyLevels():void {
			if (!keyLevels) {
				keyLevels = {levelList:[] };
				for (var lvID:* in App.data.levels) {
					var bonusData:Object = App.data.levels[lvID].bonus;
					if (lvID % 5 == 0) {
					//if (bonusData && bonusData.hasOwnProperty(Stock.FANT) && bonusData[Stock.FANT] >= 3) {
						keyLevels['levelList'].push(int(lvID));
						var sortBonusData:Object = Numbers.copyObject(bonusData);
						var sortArr:Array = [];
						for (var srt:* in sortBonusData) {
							var bData:Object = { };
							bData[srt] = sortBonusData[srt];
							sortArr.push( { sID:int(srt), data:bData } );
						}
						sortArr.sortOn('sID', Array.NUMERIC);
						sortBonusData = new Object();
						for each(var sOne:* in sortArr) {
							sortBonusData[sOne.sID] = sOne.data[sOne.sID];
						}
						keyLevels[lvID] = {bonus:sortBonusData,extra:Numbers.copyObject(App.data.levels[lvID].extra)}
					}
				}
			}
		}
		
		override public function drawBackground():void {
			//
		}
		
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, {scaleX: -0.7, scaleY:0.7});
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, {scaleX:0.7, scaleY:0.7});
			
			paginator.arrowLeft.x = - paginator.arrowLeft.width/2 + 65;
			paginator.arrowLeft.y = 300;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 45;
			paginator.arrowRight.y = 300;
		}
		
		override public function drawBody():void {
			drawLevelInfo();
			
			drawBonusInfo();
			
			exit.visible = false;
			
			var bgHeight:int = settings.height;
			/*if (isShort) {
				bgHeight = 214;
				this.y += 170;
				fader.y -= 170;
			} else {
				var openTxt:TextField = Window.drawText(Locale.__e("flash:1393581153214"), {
				fontSize	:28,
				color		:0xf5fbff,
				borderColor	:0x5d3c03,
				shadowColor	:0x5d3c03,
				shadowSize	:1
				});
				openTxt.width = openTxt.textWidth +5;
				openTxt.height = openTxt.textHeight;
				openTxt.x = settings.width/2 - openTxt.width/2 + 4;
				openTxt.y = bonusList.y + 185;
				
				var separator:Bitmap = Window.backingShort(390, 'dividerLine', false);
				separator.x = 70;
				separator.y = openTxt.y + 20;
				separator.alpha = 0.5;
				bodyContainer.addChild(separator);
				
				var separator2:Bitmap = Window.backingShort(390, 'dividerLine', false);
				//separator2.scaleY = -1;
				separator2.x = 70;
				separator2.y = openTxt.y + 145;
				separator2.alpha = 0.5;
				bodyContainer.addChild(separator2);
				
				bodyContainer.addChild(openTxt);
				
				this.y += 70;	//120
				fader.y -= 70;
			}*/
			
			//var bgHeight:int = settings.height;
			switch(mode) {
				case NEXT_LEVEL:
					bgHeight = 284;
					this.y += 170;
					fader.y -= 170;
				break;
				case USUAL_LEVEL:
					this.y += 80;
					fader.y -= 80;
				break;
				case KEY_LEVEL:
					bgHeight = 317;
					this.y += 140;
					fader.y -= 140;
				break;
			}
			background = new Bitmap();
			layer.addChildAt(background, 0);
			
			okBttn = new Button( {
				borderColor:		[0xfeee7b,0xb27a1a],
				fontColor:			0xffffff,
				fontBorderColor:	0x814f31,
				bgColor:			[0xf5d159, 0xedb130],
				width:				162,
				height:				50,
				fontSize:			32,
				hasDotes:			false,
				caption:			Locale.__e("flash:1393581174933")
			});
			okBttn.name = 'LevelUpWindow_okBttn';
			okBttn.x = (settings.width - okBttn.width)/2;
			okBttn.y = bgHeight - okBttn.height;
			bodyContainer.addChild(okBttn);
			okBttn.addEventListener(MouseEvent.CLICK, onTellBttn);
			
			checkBox = new CheckboxButton();
			checkBox.x = (settings.width - 160) / 2 + 24;
			if(!isShort)
				checkBox.y = okBttn.y - checkBox.height - 12;
			else
				checkBox.y =  0;
			bodyContainer.addChild(checkBox);
			
			if (App.isSocial('HV','YN','YB','MX','SP','AI','GN')) {
				checkBox.visible = false;
			}
			
			if	(App.user.quests.tutorial){
				checkBox.checked = CheckboxButton.UNCHECKED;
				okBttn.showGlowing();
				okBttn.showPointing('right', 0,0, bodyContainer);	
			}else if (Quests.helpInQuest(App.user.quests.currentQID)) {
				checkBox.checked = CheckboxButton.UNCHECKED;
				okBttn.showGlowing();
			}
			
			paginator.itemsCount = settings['content'].length;
			paginator.update();
			contentChange();
			if (isShort) {
				bgHeight = 314;
				checkBox.y =  contentSprite.y + contentSprite.height - 45;
				okBttn.y = checkBox.y + checkBox.height;
			}
			
			background.bitmapData = backing(settings.width, bgHeight, 78, "alertBacking").bitmapData;
			
			if (!settings.nextKeyLevel) {
				var time:int = 150;
				intervalEff = setInterval(function():void {
					if (!coordsEff[countEff]) return;
					var particle:Particles = new Particles();
					particle.init(layer, new Point(coordsEff[countEff].x, coordsEff[countEff].y));
					countEff++;
					if (countEff == 12)
						clearInterval(intervalEff);
				},time);
			
				Load.loading(Config.getImage('level', 'LevelUpAnimalsLeft'), function(data:Bitmap):void {
						var imageLeft:Bitmap = new Bitmap(data.bitmapData);
						imageLeft.x = - imageLeft.width + 90;
						imageLeft.y = settings.height - imageLeft.height;
						bodyContainer.addChildAt(imageLeft, bodyContainer.numChildren - 1);
						
						if (isShort)
							imageLeft.y -= 170;
				});
				
				Load.loading(Config.getImage('level', 'LevelUpAnimalsRight'), function(data:Bitmap):void {
						var imageRight:Bitmap = new Bitmap(data.bitmapData);
						imageRight.x = settings.width - 70;
						imageRight.y = settings.height - imageRight.height;
						bodyContainer.addChildAt(imageRight, bodyContainer.numChildren - 1);
						
						if (isShort)
							imageRight.y -= 170;
						
						if(extra)
							bodyContainer.swapChildren(imageRight, extra);
				});
			}
			
			
			if (App.data.levels[App.user.level].extra && !App.isSocial('ML','HV','YN','YB','MX','SP','AI','GN')) {
				var extra:ExtraItem = new ExtraItem(this);
				extra.x = settings.width - extra.bg.width + 10;
				extra.y = background.height - extra.bg.height + 5;
				bodyContainer.addChild(extra);
			}
			
			if (settings.nextKeyLevel) {
				if (checkBox) {
					checkBox.checked = CheckboxButton.UNCHECKED;
					checkBox.state = Button.DISABLED;
					checkBox.visible = false;
				}
				if (extra) {
					extra.visible = false;
				}
			}
		}
		
		private var countEff:int = 0;
		private var intervalEff:int;
		private var coordsEff:Object = { 
			0:{x:40-100, y:-100},
			1:{x:100-100, y:-110},
			2:{x:160, y:-110},
			3:{x:220-100, y:-120},
			4:{x:380+100, y:-100},
			5:{x:260, y:-120},
			6:{x:190, y:-110},
			7:{x:60, y:-100},
			8:{x:120-100, y:-110},
			9:{x:200, y:-120},
			10:{x:250+100, y:-120},
			11:{x:360+100, y:-100},
			12:{x:220, y:-120}
		};
		
		private function onTellBttn(e:MouseEvent):void {
			if (mode == NEXT_LEVEL) {
				close();
				return;
			}
			if (checkBox) {
				if (checkBox.checked == CheckboxButton.CHECKED && !App.isSocial('HV','YN','YB','MX','SP','AI','GN')) {
					screen = new Bitmap(new BitmapData(settings.width, settings.height, true, 0));
					screen.bitmapData.draw(layer, new Matrix(1, 0, 0, 1));
					needBonusWindow = true;
					WallPost.makePost(WallPost.LEVEL, { callback:getExtraBonus } );
				}
			}
			
			var checkMoneyLevel:Function = function(l:*, s:*) : Boolean {
					if (l == s)
						return true;	
				return false;								
			}
			
			if (checkMoneyLevel(App.data.money.level, App.user.level) && App.user.money < App.time) {
				Post.send( {
					ctr:		'user',
					act:		'money',
					uID:		App.user.id,
					enable:		1
				}, function(error:int, data:Object, params:Object):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
					App.user.money = App.time + (App.data.money.duration || 24) * 3600;
					new BankSaleWindow().show();
					//App.ui.salesPanel.addBankSaleIcon(UserInterface.textures.saleBacking2);
					App.ui.salesPanel.addBankSaleIcon();
				});	
			}
			
			var checkInviteLevel:Function = function(levels:String, s:*) : Boolean {
				var arr:Array = levels.split(',');
				for (var k:int = 0; k < arr.length; k++ ) {
					if (arr[k] == s)	
						return true;	
				}
				return false;								
			}
			
			bonusList.take();
			close();
			
			if (checkInviteLevel(App.data.options.InviteLevels, App.user.level)) {
				if (App.social == 'OK') {
					//App.network.showInviteBox();
				} else if (App.isSocial('ML','FB','NK')) {
					//if(checkBox.checked != CheckboxButton.CHECKED)
					//ExternalApi.apiInviteEvent();
				}	
				//} else
					//setTimeout(function():void { new InviteLostFriendsWindow( { } ).show(); }, 500);
			}
			//bonusList.take();
			//close();
		}
		
		private function getExtraBonus(result:* = null):void { 
			if (App.social == "ML" && result.status != "publishSuccess")
				return;
			
			Post.addToArchive('\n onPostComplete: ' + JSON.stringify(result));
			Post.statisticPost(Post.STATISTIC_WALLPOST);
			WallPost.onPostComplete(result);
			
			if (App.social == 'VK' && !(result != null && result.hasOwnProperty('post_id')))
			{
				needBonusWindow = false;
				ExternalApi.askOpenFullscreen();
				return;
			}
				
			Post.send({
				'ctr':'user',
				'act':'viral',
				'uID':App.user.id,
				'type':'tell'
			}, function(error:*, data:*, params:*):void {
				if (error) {
					//Errors.show(error, data);
					return;
				}
				
				var rewData:Object = { };
				rewData['character'] = 1;
				rewData['title'] = Locale.__e('flash:1406554650287');
				rewData['description'] = Locale.__e('flash:1393518655260');
				rewData['bonus'] = { };
				rewData['bonus']['materials'] = data.bonus;
				
				new QuestRewardWindow( {
					data:rewData,
					levelRew:true,
					forcedClosing:true,
					strong:false,
					callback:function():void{
						needBonusWindow = false;
						ExternalApi.askOpenFullscreen();
					}
				}).show();
				
				App.user.stock.addAll(data.bonus);
			});
		}
		
		public var contentSprite:Sprite = new Sprite();
		override public function contentChange():void {
			if (!contentSprite.parent) {
				
				bodyContainer.addChild(contentSprite);
				var bg:Bitmap = Window.backing(390, 116, 50, 'fadeOutYellow');
				bg.x = 0;
				bg.y = 15;
				bg.alpha = 0.5;
				contentSprite.addChild(bg);
				
				var rewLabel:TextField;
				var rewText:String;
				var rewLabelSettings:Object;
				if (mode == NEXT_LEVEL) {
					rewText = Locale.__e('flash:1382952380000'); // награда
					rewLabelSettings = {
							width:376,
							fontSize:28,
							color:0xf6fcfa,
							borderColor:0x5f400a,
							textAlign:'center'
						}
				}
				if(mode == USUAL_LEVEL){
					rewText = Locale.__e('flash:1458640452741', [String(nextLevel)]); // награда на %s уровне
					rewLabelSettings = {
							width:376,
							fontSize:23,
							color:0xedc556,
							borderColor:0x77500b,
							textAlign:'center'
						}
				}
				if (mode == KEY_LEVEL) {
					rewText = Locale.__e('flash:1382952380000');
					rewLabelSettings = {
							width:376,
							fontSize:30,
							color:0xedc556,
							borderColor:0x77500b,
							textAlign:'center'
						}
				}
				rewLabel = drawText(rewText, rewLabelSettings);
				rewLabel.y = -rewLabel.height / 2;
				contentSprite.addChild(rewLabel);
				addMirrowObjs(contentSprite, 'titleDecRose', (rewLabel.width - rewLabel.textWidth) / 2 - textures.titleDecRose.width, (rewLabel.width - rewLabel.textWidth) / 2 + rewLabel.textWidth + textures.titleDecRose.width , rewLabel.y + (rewLabel.textHeight - textures.titleDecRose.height) / 2);
			}
			
			for each(var _item:* in items) {
				contentSprite.removeChild(_item);
				_item = null;
			}
			
			items = [];
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++){
				var item:OpenedItem = new OpenedItem(settings.content[i], this);
				contentSprite.addChild(item);
				items.push(item);
				var allX:int = (376 - (paginator.finishCount - paginator.startCount) * 116 + 16) / 2;
				item.x = (i - paginator.startCount) * 116 + allX;
				item.y = 20;
			}
			
			contentSprite.x = (settings.width - contentSprite.width) / 2;
			contentSprite.y = (mode != USUAL_LEVEL?95:266) - 15;
			
			var separator:Bitmap = Window.backingShort(contentSprite.width, 'dividerLine', false);
			separator.x = 0;
			separator.y = 15;
			separator.alpha = 0.5;
			contentSprite.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(contentSprite.width, 'dividerLine', false);
			separator2.x = 0;
			separator2.y = 30 + item.height;
			separator2.alpha = 0.5;
			contentSprite.addChild(separator2);
		}
		
		public var bonusList:RewardList;
		private function drawBonusInfo():void{
			bonusList = new RewardList(settings.bonus, false, settings.width - 50, Locale.__e("flash:1382952380000"), 1, 40, 16, 40, '', 1, 0, 0, false);
			bonusList.x = 10;
			bonusList.y = 53;
			
			var bg:Bitmap = Window.backing(390, 116, 50, 'fadeOutWhite');
			bg.x = 70;
			bg.y = bonusList.y + 48;
			bg.alpha = 0.5;
			bodyContainer.addChild(bg);
			
			var separator:Bitmap = Window.backingShort(390, 'dividerLine', false);
			separator.x = 70;
			separator.y = bonusList.y + 48;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(390, 'dividerLine', false);
			separator2.x = 70;
			separator2.y = bonusList.y + 160;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			bodyContainer.addChild(bonusList);
			
			if(mode != USUAL_LEVEL){
				bonusList.visible = false;
				separator.visible = false;
				separator2.visible = false;
			}
		}
		
		private function drawLevelInfo():void {
			var sprite:Sprite = new Sprite();
			label = backingShort(settings.width + 120, 'ribbonYellow', true);
			sprite.x = settings.width / 2 - label.width / 2;
			sprite.y = - 35;
			sprite.addChild(label);
			
			var starIcon:Bitmap = new Bitmap(Window.textures.newLevelTitleDec);
			starIcon.x = sprite.width / 2 - starIcon.width / 2;
			starIcon.y = -100;
			starIcon.smoothing = true;
			sprite.addChild(starIcon);
			
			var textSettings:Object = {
				title		:String(viewLevel),
				fontSize	:72,
				textAlign:"center",
				color		:0xfff69b,
				borderColor	:0x9f570e,
				borderSize: 5,
				sharpness: 0,
				fontBorder	: 0,
				fontBorderGlow:0,
				shadowColor:0x9f570e,
				shadowSize:2
			};
			
			var levelText:TextField = Window.drawText(settings.nextKeyLevel?Locale.__e("flash:1458639782652"):Locale.__e("flash:1393581217883"), {
				fontSize	:settings.nextKeyLevel?46:54,
				color		:0xfffbc2,
				borderColor	:0xaf751b,
				fontBorderSize:1,
				shadowColor:0x6b4126,
				shadowSize:4
				});
			levelText.width = levelText.textWidth +5;
			levelText.height = levelText.textHeight;
			levelText.x = sprite.width/2 - levelText.width/2 + 4;
			levelText.y = label.y + 22;
			sprite.addChild(levelText);
		
			var leveleTitle:Sprite = titleText(textSettings);	
			leveleTitle.x = sprite.width/2 - leveleTitle.width/2;
			leveleTitle.y = label.y - 60;
			sprite.addChild(leveleTitle);
			
			bodyContainer.addChild(sprite);
			
			/*var addBackToImage:Function = function(_cont:Sprite, width:Number, height:Number):void {
				var sp:Sprite = new Sprite();
				sp.graphics.beginFill(0xffffff);
				sp.graphics.drawRect(0, 0, width, height);
				sp.graphics.endFill();		
				_cont.addChildAt(sp, 0);
				//back.x = (width - back.width)/2 + back.width / 2;
				//back.y = (_cont.height - back.height)/2;
			}*/
			
		}
		
		override public function dispose():void {
			clearInterval(intervalEff);
			super.dispose();
		}
	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class OpenedItem extends LayerX {
	
	public var sID:uint;
	public var count:uint = 0;
	public var bitmap:Bitmap = new Bitmap();
	public var window:*;
	
	private var preloader:Preloader = new Preloader();
	
	public function OpenedItem(bData:Object, window:*) {
		for (var i:* in bData) {
			this.sID = i;
			this.count = bData[i];
			break;
		}
		this.window = window;
		
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0xc7c9bb, 1);
		shape.graphics.drawCircle(50, 60, 50);
		shape.graphics.endFill();
		addChild(shape);
		
		addChild(bitmap);
		drawTitle();
		drawCount();
		addChild(preloader);
		preloader.x = (104 - preloader.width) / 2 + 43;
		preloader.y = (124 - preloader.height) / 2 + 46;
		var itemData:Object = App.data.storage[sID];
		tip = function():Object {
			return {
				title: itemData.title,
				text: itemData.description
			};
		}
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}
	
	private function onLoad(data:Bitmap):void {
		removeChild(preloader);
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, 80, 80);
		bitmap.smoothing = true;
		bitmap.x = (104 - bitmap.width) / 2;
		bitmap.y = (124 - bitmap.height) / 2 + 4;
	}
	
	private function drawTitle():void {
		var title:TextField = Window.drawText(App.data.storage[sID].title, {
			color:0x814f31,
			textLeading: -5,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:18,
			multiline:true
		});
		title.wordWrap = true;
		title.width = 104;
		title.y = 6;
		title.x = -2;
		addChild(title);
	}
	
	private function drawCount():void
	{
		if (count == 0) return;
		var countLabel:TextField = Window.drawText('x' + String(this.count), {
			color:0x814f31,
			width:104,
			textLeading: -5,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:24,
			multiline:true
		});
		
		countLabel.y = 124 - countLabel.height - 10;
		addChild(countLabel);
	}
}

import wins.RewardList;

internal class ExtraItem extends Sprite {
	
	public var extra:Object;
	public var bg:Bitmap;
	
	public function ExtraItem(window:*) {
		extra = App.data.levels[App.user.level].extra;
		bg = Window.backing(164, 92, 38, "shareBonusBacking");
		addChild(bg);
		drawTitle();
		drawReward();
	}
	
	private function drawTitle():void {
		var title:TextField = Window.drawText(Locale.__e("flash:1406545004234"), {
			fontSize	:17,
			color		:0x673a1f,
			borderColor	:0xffffff,
			textAlign   :'center',
			multiline   :true,
			wrap        :true
		});
		title.width = bg.width - 10;
		title.x = 5
		title.y = 6;
		addChild(title);
	}
	
	private function drawReward():void {
		var reward:RewardList = new RewardList(extra, false, 0, '', 1, 30, 16, 32, "x", 0.5, -8, 7, false, true);
		addChild(reward);
		reward.x = -10;
		reward.y = bg.height - reward.height - 10;
		
		//var icon:Bitmap = new Bitmap(Window.textures.vaultFury);
		//addChild(icon);
		//icon.x = 114;
		//icon.y = -72;
	}
}