package wins 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class AchivementsWindow extends Window
	{
		private static var isPremShoed:Boolean = false;
		public static function checkAchProgress(ind:int):void
		{
			
			if (App.user.mode == User.GUEST) return;
			if (App.user.ach[ind]) {
				for (var mis:* in App.user.ach[ind]) {
					if (App.user.ach[ind][mis] < 1000000000 && App.data.ach[ind].missions[mis].need <= App.user.ach[ind][mis]) {
						if (AchivementMsgWindow.showed.indexOf(App.data.ach[ind].ID) != -1)
							continue;
							
						if (mis == 1 && App.user.level <= 5 && !isPremShoed) {
							isPremShoed = true;
							new AchivementPremiumWindow().show();
						}else {
							App.ui.bottomPanel.hideFriendsPanel();
							//App.ui.bottomPanel.bttns[3].hidePointing();
							new AchivementMsgWindow(App.data.ach[ind], mis).show();
						}
						//App.ui.bottomPanel.updateAchiveCounter();
					}
				}
			}
			
		}
		
		
		public var totalMissions:int;
		public var achivements:Array = [];
		
		public function AchivementsWindow(settings:Object = null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 770;
			settings['height'] = 590;
			settings['title'] = Locale.__e('flash:1412772505008');
			settings['background'] = 'shopBackingMain';
			settings["itemsOnPage"] = 4;
			
			settings["page"] = 0;
			
			totalMissions = 0;
			
			super(settings);
			
			for (var ach:* in App.data.ach) {
				var item:Achivement = new Achivement(ach, App.data.ach[ach], this);
				trace(App.data.ach[ach].ID);
				if (App.data.ach[ach].ID != '21')
					achivements.push(item);
			}
			
			achivements.sortOn(['indDone', 'numMission'], [Array.NUMERIC]);
			
			findTargetPage(settings);
		}
		override public function drawExit():void 
		{
			super.drawExit();
			exit.x = settings.width - 50;
			exit.y = -15;
		}

		private function findTargetPage(settings:Object):void 
		{
			if (settings.find != null) {
				
				for (var i:int = 0; i < achivements.length; i++ ) {
					if (achivements[i].id == settings.find) {
						achivements.unshift(achivements[i]);
						return;
					}
				}
			}
		}
		
		override public function drawArrows():void {
				
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = 470;
			paginator.arrowLeft.x = 120;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width - 120 - paginator.arrowRight.width;
			paginator.arrowRight.y = y;
			
			paginator.x = int((settings.width - paginator.width)/2 - 40);
			paginator.y = int(settings.height - paginator.height - 25);
		}
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			background.y = - 15;
			layer.addChild(background);
		}
		override public function drawBody():void 
		{
			titleLabel.y -= 3;
			
			drawDesc();
			
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -46, true, true);
			drawMirrowObjs('diamonds', 22, settings.width - 22, settings.height - 128);
			
			paginator.itemsCount = 0;
			//for (var ach:* in App.data.ach) {
				//paginator.itemsCount++;
			//}
			paginator.itemsCount = achivements.length;
			
			paginator.page = settings.page;
			paginator.update();
			contentChange();
		}
		
		private var missionsCount:TextField;
		private function drawDesc():void 
		{
			var title:TextField = Window.drawText(Locale.__e('flash:1393518655260'), {
				color:0xffffff,
				borderColor:0x7b4003,
				textAlign:"center",
				autoSize:"center",
				fontSize:26
			});
			bodyContainer.addChild(title);
			title.x = (settings.width - title.textWidth) / 2;
			title.y = -2;
			
			var doneCont:Sprite = new Sprite();
			var missionsDone:TextField = Window.drawText(Locale.__e('flash:1393579829632'), {
				color:0xffffff,
				borderColor:0x7b4003,
				textAlign:"center",
				autoSize:"center",
				fontSize:26
			});
			
			doneCont.addChild(missionsDone);
			missionsDone.y = -5;
			missionsDone.x = 20;
			
			missionsCount = Window.drawText(String(0) + "/" + String(totalMissions), {
				color:0xffe760,
				borderColor:0x7b4003,
				textAlign:"center",
				autoSize:"left",
				fontSize:36
			});
			missionsCount.width = missionsCount.textWidth + 10;
			doneCont.addChild(missionsCount);
			missionsCount.x = (missionsDone.textWidth - missionsCount.textWidth) / 2 + 10;
			missionsCount.y = missionsDone.y + missionsDone.textHeight - 5;
			
			if(missionsCount.x < 0){
				missionsDone.x = Math.abs(missionsCount.x);
				missionsCount.x = 0;
			}
			
			bodyContainer.addChild(doneCont);
			doneCont.x = 30;
			doneCont.y = -24;
		}
		
		override public function contentChange():void 
		{
			
			for each(var item:Achivement in achivements) {
				if(item.parent)item.parent.removeChild(item);
				item.dispose();
				item = null;
			}
			achivements.splice(0, achivements.length);
			achivements = [];
			
			for (var ach:* in App.data.ach) {
				var doGlow:Boolean = false;
				if (settings.find == ach) doGlow = true;
				item = new Achivement(ach, App.data.ach[ach], this, doGlow);
				
				if (App.data.ach[ach].ID != '21')
					achivements.push(item);
			}
			
			var arr:Array = [];
			for (var j:int = 0; j < achivements.length; j++ ) {
				if (achivements[j].indDone == 0) {
					arr.push(achivements[j]);
					achivements.splice(j, 1);
					j--;
				}
			}
			
			if(arr.length > 0){
				for (j = 0; j < achivements.length; j++ ) {
					arr.push(achivements[j]);
				}
				achivements.splice(0, achivements.length);
				achivements = arr;
			}
			
			var posY:int = 40;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++ ) {
				item = achivements[i];
				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.background.width) / 2;
				item.y = posY - 2;
				posY += item.height + 6;
			}
			
			setDoneMissions();
		}
		
		public function setDoneMissions():void 
		{
			var doneMiss:int = 0;
			var totalMiss:int = 0;
			for (var i:int = 0; i < achivements.length; i++ ) {
				var ach:Achivement = achivements[i];
				doneMiss += ach.getDoneMissions();
				totalMiss += ach.totalStars;
			}
			if (doneMiss < 0) doneMiss = 0;
			missionsCount.text = String(doneMiss) + "/" + String(totalMiss);
		}
		
		public function changeCurrent(ind:int):void
		{
			for (var i:int = 0; i < achivements.length; i++ ) {
				var item:Achivement = achivements[i];
				if (item.id == ind) {
					item.update(ind, App.data.ach[ind]);
				}
			}
		}
		
		private function getDoneMissions():int 
		{
			return 100;
		}
		
	}

}
import api.ExternalApi;
import buttons.Button;
import com.greensock.easing.Elastic;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Post;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.ProgressBar;
import wins.AchivementsWindow;
import wins.AchivementMsgWindow;


internal class Achivement extends Sprite {
	
	public var background:Bitmap;
	public var bitmap:Bitmap = new Bitmap();
	
	public var achive:Object = { };
	public var mission:Object = { };
	
	public var id:int;
	
	private var window:AchivementsWindow;
	
	public var totalStars:int;
	private var openStars:int;
	public var numMission:int = 0;
	
	private var isAllDone:Boolean = false;
	private var missionDone:Boolean = false;
	
	public var indDone:int = 0;
	
	public function Achivement(id:int, achive:Object, window:AchivementsWindow, doGlow:Boolean = false) {
		this.window = window;
		update(id, achive, doGlow);
	}
	
	public function update(id:int, achive:Object, doGlow:Boolean = false):void
	{
		indDone = 0;
		missionDone = false;
		isAllDone = false;
		numMission = 0;
		
		this.achive = achive;
		this.id = id;
		
		numMission = getMission();
		if (numMission > getTotalMissions()) 
			isAllDone = true;
		else 
			missionDone = checkEndMission(numMission);
		
		if (!missionDone) indDone = 1;
			
		totalStars = 3;
		openStars = numMission - 1;
		
		if (openStars > totalStars) openStars = totalStars;
		if (isAllDone) openStars = totalStars;
		
		var count:int = 1;
		for (var mis:* in achive.missions) {
			if (count == numMission) {
				mission = achive.missions[mis];
				break;
			}
			count++;
		}
		
		clearBody();
		drawBody();
		
		if (doGlow) glowing();
	}
	
	private function clearBody():void 
	{	
		if (background && background.parent)
			background.parent.removeChild(background);
		background = null;
		
		if (bitmap && bitmap.parent)
			bitmap.parent.removeChild(bitmap);
		bitmap = null;
		
		if (starsCont && starsCont.parent)
			starsCont.parent.removeChild(starsCont);
		starsCont = null;
		starsCont = new Sprite();
		
		if (infoCont && infoCont.parent)
			infoCont.parent.removeChild(infoCont);
		infoCont = null;
		infoCont = new Sprite();
		
		if (takeBttn) {
			takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
			takeBttn.dispose();
		}
		takeBttn = null;
		
		if (rewardCont && rewardCont.parent)
			rewardCont.parent.removeChild(rewardCont);
		rewardCont = null;
		rewardCont = new Sprite();
	}
	
	private function checkEndMission(num:int):Boolean 
	{
		if (App.user.ach[id]) {
			var count:int = 1;
			for (var mis:* in achive.missions) {
				if (count == num) {
					if (achive.missions[mis].need <= App.user.ach[id][mis])
						return true;
					
					break;
				}
				count++;
			}
		}
		
		return false;
	}
	
	private function getTotalMissions():int 
	{
		var num:int = 0;
		for (var cnt:* in achive.missions) {
			num++;
		}
		return num;
	}
	
	private function getMission():int 
	{
		var num:int = 1;
		for (var cnt:* in App.user.ach[id]) {
			if (App.user.ach[id][cnt] > 1000000000)
				num++;
		}
		
		if (num == 0) num = 1;
		return num;
	}
	
	private function drawBody():void 
	{
		background = Window.backing2(700, 105, 44, 'questTaskBackingTop', 'questTaskBackingBot'); //бэк верхний
		background.alpha = 0.5;
		addChild(background);
		
		drawStars();
		
		drawInfo();
		
		drawBttn();
		
		drawRewardInfo();
	}
	
	private var tweenStart:TweenLite;
	private var starsCont:Sprite = new Sprite();
	private function drawStars():void 
	{	
		var i:int;
		var posX:int = 0;
		var posY:int = 10;
		
		for ( i = 0; i < totalStars; i++ ) {
			var star:Bitmap = new Bitmap(UserInterface.textures.achieveEmptyStar);
			star.smoothing = true;
			starsCont.addChild(star);
			star.x = posX;
			star.y = posY;
			
			posX += star.width - 6;
		}
		
		posX = 4;
		posY = 15;
		
		var starGlow:Bitmap;
		var doGlow:Boolean = false;
		
		if (missionDone && !isAllDone) {
			openStars += 1;
			doGlow = true;
		}
		
		for (i = 0; i < openStars; i++ ) {
			var star2:Bitmap = new Bitmap(UserInterface.textures.expIcon);
			star2.scaleX = star2.scaleY = 1.3;
			star2.smoothing = true;
			starsCont.addChild(star2);
			star2.x = posX;
			star2.y = posY;
			
			posX += star2.width + 4;
			
			if (doGlow && i == (openStars - 1)) {
				star2.alpha = 0;
				starGlow = star2;
			}
		}
		
		if(starGlow)
			tweenStart = TweenLite.to(starGlow, 0.5, {onComplete:function():void { starGlow.alpha = 0; glowStar(starGlow); }} ); 
		
		addChild(starsCont);
		starsCont.x = 18;
		starsCont.y = background.y + 5;
	}
	
	private var margX:int = 4;
	private var margY:int = 4;
	private var tweenGlow1:TweenLite;
	private var tweenGlow2:TweenLite;
	private function glowStar(star:Bitmap):void
	{
		tweenGlow1 = TweenLite.to(star, 0.8, {x:star.x-margX, y:star.y-margY, alpha:1, scaleX:1.5, scaleY:1.5, ease:Elastic.easeOut, onComplete:function():void {
			tweenGlow2 = TweenLite.to(star, 0.8, {x:star.x+margX, y:star.y+margY, alpha:0, scaleX:1.3, scaleY:1.3, onComplete:function():void {
				glowStar(star);
			}});
		}});
	}
	
	private var infoCont:Sprite = new Sprite();
	private function drawInfo():void 
	{
		var title:TextField = Window.drawText(achive.title, {
			color:0xffe760,
			borderColor:0x6c491c,
			textAlign:"center",
			autoSize:"center",
			fontSize:26
		});
		title.width = title.textWidth + 10;
		infoCont.addChild(title);
		title.x = 0;
		title.y = 5;
		
		if (!missionDone) {
			var txt:String; 
			if (isAllDone)
				txt = achive.description;
			else
				txt = mission.description;
				
			var desc:TextField = Window.drawText(txt, {
				color:0xffffff,
				borderColor:0x654d30,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				distShadow:0,
				multiline:true,
				wrap:true
			});
			desc.width = 200;
			if (desc.height <= 30)
			{
				title.y = 15;
			};
			infoCont.addChild(desc);
			desc.x = (title.textWidth - desc.width) / 2;
			desc.y = title.y + title.textHeight + 2;
			
			if(desc.x < 0){
				title.x = Math.abs(desc.x);
				desc.x = 0;
			}
		}
		
		addChild(infoCont);
		infoCont.x = 340 - infoCont.width / 2;
		infoCont.y = 4;
		if (isAllDone) {
			infoCont.x += 50;
		}
	}
	
	private var takeBttn:Button;
	private function drawBttn():void 
	{
		if (missionDone && !isAllDone) {
			takeBttn = new Button( {
				caption:Locale.__e("flash:1393579618588"),
				fontSize:24,
				width:190,
				hasDotes:false,
				height:44,
				greenDotes:false,
				bgColor:				[0xa8f84a,0x74bc17],	
				borderColor:			[0x4d7b83,0x4d7b83],	
				bevelColor:				[0xc8fa8f, 0x5f9c11],
				fontColor:				0xffffff,				
				fontBorderColor:		0x4d7d0e
			});
			addChild(takeBttn);
			takeBttn.x = 340 - takeBttn.width / 2;
			takeBttn.y = background.height - takeBttn.height - 16;
			
			takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		}
	}
	
	private var rewardCont:Sprite = new Sprite();
	private function drawRewardInfo():void 
	{	
		if (isAllDone) {
			var bg:Bitmap = new Bitmap(Window.textures.questCheckmarkSlot);
			var mark:Bitmap = new Bitmap(Window.textures.checkMarkBig);
			
			bg.x = 4;
			mark.x = 12;
			rewardCont.addChild(bg);
			rewardCont.addChild(mark);
		}else {
			var progressBacking:Bitmap = Window.backingShort(240, "prograssBarBacking3");
			progressBacking.x = -50;
			rewardCont.addChild(progressBacking);
			
			var progressBar:ProgressBar = new ProgressBar( { win:this, width:244, isTimer:false});
			progressBar.x = progressBacking.x - 2;
			progressBar.y = progressBacking.y - 2;
			rewardCont.addChild(progressBar);
			progressBar.start();
			progressBar.progress = getProgress();
			
			var count:TextField = Window.drawText(getProgressTxt(), {
				color:			0xffffff,
				borderColor:	0x654317,
				fontSize:		34
			});
			count.width = count.textWidth + 10;
			count.x = (progressBacking.width - count.textWidth) / 2 - 40;
			count.y = 2;
			rewardCont.addChild(count);
			
			var bonusCont:Sprite = new Sprite();
			
			var rewardTxt:TextField = Window.drawText(Locale.__e('flash:1382952380000'), {
				color:0xffffff,
				borderColor:0x654317,
				textAlign:"left",
				autoSize:"left",
				fontSize:28
			});
			rewardTxt.height = rewardTxt.textHeight;
			bonusCont.addChild(rewardTxt);
			rewardTxt.y = 10;
			rewardTxt.x = -45;
			
			for (var _ind:* in mission.bonus) {
				break;
			}
			var icon:Bitmap = new Bitmap();
			Load.loading(Config.getIcon(App.data.storage[_ind].type, App.data.storage[_ind].preview), function(data:*):void { 
				icon.bitmapData = data.bitmapData;
				icon.scaleX = icon.scaleY = 0.4;
				icon.smoothing = true;
				bonusCont.addChild(icon);
				icon.x = rewardTxt.x + 90;
				icon.y = rewardTxt.y + rewardTxt.height / 2 - icon.height / 2;
			} );
			
			var settings:Object = {
			color:0xffaec7,
			borderColor:0x931d4e
			};

			if (App.data.storage[_ind].preview == "honey")
			{
				 settings = {
				color:0xffdb65,
				borderColor:0x775002
			};
			}
			
			var countTxt:TextField = Window.drawText(getBonus(), {
				color:settings.color,
				borderColor:settings.borderColor,
				textAlign:"left",
				autoSize:"left",
				fontSize:32
			});
			if (App.data.storage[_ind] == 2) 
			{
				countTxt.textColor = 0xffdb65;
				countTxt.borderColor = 0x775002;
			}

			countTxt.height = countTxt.textHeight;
			bonusCont.addChild(countTxt);
			countTxt.x = rewardTxt.x + 133;
			countTxt.y = 10;
			
			bonusCont.x = (progressBacking.width - bonusCont.width) / 2;
			bonusCont.y = progressBacking.height - 8;
			rewardCont.addChild(bonusCont);
		}
		
		rewardCont.x = 608 - rewardCont.width / 2;
		rewardCont.y = (background.height - rewardCont.height) / 2;
		addChild(rewardCont);
	}
	
	private function getBonus():String 
	{
		var indMat:int;
		
		for (var _ind:* in mission.bonus) {
			indMat = _ind;
			break;
		}
		
		var bonus:int = mission.bonus[_ind];
		
		return String(bonus);
	}
	
	private function getProgressTxt():String 
	{
		var needItems:int = mission.need;
		var haveItems:int;
		if (App.user.ach[id])
			haveItems = getHaveItems();
		else 
			haveItems = 0;
			
		if (haveItems > needItems) haveItems = needItems;
		
		var rez:String = String(haveItems) + "/" + String(needItems)
		return rez;
	}
	
	private function getHaveItems():int {
		var num:int = 1;
		for (var ind:* in App.user.ach[id]) {
			if (num == numMission) {
				return App.user.ach[id][ind]
			}
			num ++;
		}
		return 0;
	}
	
	private function getProgress():Number 
	{
		var needItems:int = mission.need;
		var haveItems:int;
		if (App.user.ach[id])
			haveItems = App.user.ach[id][numMission];
		else 
			haveItems = 0;
			
		var rez:Number =  haveItems / needItems;
		if (rez > 1) rez = 1;
		
		return rez;
	}
	
	
	private function onTake(e:MouseEvent):void 
	{
		for (var i:int = 0; i < AchivementMsgWindow.showed.length; i++ ) {
			if (AchivementMsgWindow.showed[i] == id) AchivementMsgWindow.showed.splice(i,1);
		}
		var indMissiont:int;
		var count:int = 1;
		
		
		for (var cnt:* in App.user.ach[id]) {
			if (numMission == count) {
				indMissiont = cnt;
				break;
			}
				
			count++;
		}
		sendPost();
		stopGlowing();
		Post.send({
			ctr:'ach',
			act:'take',
			uID:App.user.id,
			qID:id,
			mID:indMissiont
		}, onTakeBonus);
	}
	
	private function onTakeBonus(error:int, data:Object, params:Object):void 
	{
		if (error) {
			Errors.show(error, data);
			return;
		}	
		if (data.bonus) {
			for (var bns:* in data.bonus) {
				App.user.stock.add(bns, data.bonus[bns]);
				
				var pnt:Point = Window.localToGlobal(takeBttn)
				var pntThis:Point = new Point(pnt.x, pnt.y + 10);
				Hints.plus(bns, data.bonus[bns], pntThis, false, window);
				
				flyMaterial();
			}
		}
		
		//Делаем push в _6e
		if (App.social == 'FB') {
			ExternalApi.og('get','achievement');
		}
		
		App.user.ach[id][numMission] = App.time;
		
		window.changeCurrent(id);
		window.setDoneMissions();
		
		//App.ui.bottomPanel.updateAchiveCounter();
		
	}
	
	public function sendPost():void {
		//WallPost.makePost(WallPost.ACHIVE, {title:achive.title});
	}
	
	private function flyMaterial():void
	{
		for (var _ind:* in mission.bonus) {
			break;
		}
		
		var item:BonusItem = new BonusItem(_ind, 0);
		
		var point:Point = Window.localToGlobal(takeBttn);
		item.cashMove(point, App.self.windowContainer);
	}
	
	public function getDoneMissions():int
	{
		var sts:int = openStars;
		
		return sts;
	}
	
	public function glowing():void 
	{
		customGlowing(this, glowing);	
	}
		
	private var canGlowing:Boolean = true;
	private function customGlowing(target:*, callback:Function = null):void {
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null && canGlowing) {
					callback();
				}else if(!canGlowing){
					TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 7, blurX:1, blurY:1 } });
				}
			}});	
		}});
	}
	
	private function stopGlowing():void
	{
		canGlowing = false;
		window.settings.find = 0;
	}
	
	public function dispose():void 
	{
		clearBody();
		
		window = null;
		mission = null;
		achive = null;
	}
}