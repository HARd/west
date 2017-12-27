package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Security;
	

	public class PanelsLib extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		[Embed(source = "Textures/InterCalendarIco.png")]
		private var InterCalendarIco:Class;
		public var interCalendarIco:BitmapData = new InterCalendarIco().bitmapData;
		
		
		[Embed(source = "Textures/posts/PostsPic_game.png")]
		private var PostGame:Class;
		public var postGame:BitmapData = new PostGame().bitmapData;
		
		[Embed(source = "Textures/posts/PostsPic_level.png")]
		private var PostLevel:Class;
		public var postLevel:BitmapData = new PostLevel().bitmapData;
		
		[Embed(source = "Textures/posts/PostsPic_searchpng.png")]
		private var PostSearch:Class;
		public var postSearch:BitmapData = new PostSearch().bitmapData;
		
		[Embed(source = "Textures/posts/PostsPic_territory.png")]
		private var PostTerritory:Class;
		public var postTerritory:BitmapData = new PostTerritory().bitmapData;
		
		
		[Embed(source="Textures/GoldenFrontierLogo.png")]
		private var GoldenFrontierLogo:Class;
		public var goldenLogo:BitmapData = new GoldenFrontierLogo().bitmapData;
		
		[Embed(source="Textures/Lens.png")]
		private var Lens:Class;
		public var lens:BitmapData = new Lens().bitmapData;
		
		[Embed(source="Textures/cursors/CursorDefaultSmall.png")]
		private var CursorDefaultSmall:Class;
		public var cursorDefaultSmall:BitmapData = new CursorDefaultSmall().bitmapData;
		
		[Embed(source="Textures/cursors/CursorBacket64.png")]
		private var Backet:Class;
		public var backet:BitmapData = new Backet().bitmapData;
		
		[Embed(source="Textures/cursors/CursorAxe64.png")]
		private var Axe:Class;
		public var axe:BitmapData = new Axe().bitmapData;
		
		[Embed(source="Textures/cursors/CursorPick64.png")]
		private var Pick:Class;
		public var pick:BitmapData = new Pick().bitmapData;
		
		[Embed(source="Textures/cursors/CursorGoldenPick64.png")]
		private var GoldenPick:Class;
		public var goldenPick:BitmapData = new GoldenPick().bitmapData;
		
		[Embed(source="Textures/cursors/CursorShears64.png")]
		private var Secateurs:Class;
		public var secateurs:BitmapData = new Secateurs().bitmapData;
		
		[Embed(source="Textures/cursors/CursorSickle64.png")]
		private var Sickle:Class;
		public var sickle:BitmapData = new Sickle().bitmapData;
		
		[Embed(source="Textures/cursors/Dynamite.png")]
		private var Dynamite:Class;
		public var dynamite:BitmapData = new Dynamite().bitmapData;
		
		[Embed(source="Textures/cursors/Brush.png")]
		private var Brush:Class;
		public var brush:BitmapData = new Brush().bitmapData;
		
		[Embed(source="Textures/cursors/Hammer.png")]
		private var Hammer:Class;
		public var hammer:BitmapData = new Hammer().bitmapData;
		
		[Embed(source="Textures/cursors/Miner.png")]
		private var Miner:Class;
		public var miner:BitmapData = new Miner().bitmapData;
		
		[Embed(source="Textures/cursors/Loupe.png")]
		private var Loupe:Class;
		public var loupe:BitmapData = new Loupe().bitmapData;
		
		[Embed(source="Textures/cursors/Bochka.png")]
		private var Bochka:Class;
		public var bochka:BitmapData = new Bochka().bitmapData;
		//////////////////////////////////////////////////////////////////////////////////////////////////////////
		[Embed(source="Textures/unit_icons/SmileNegative.png")]
		private var SmileNegative:Class;
		public var smileNegative:BitmapData = new SmileNegative().bitmapData;
		
		[Embed(source="Textures/unit_icons/SmilePositive.png")]
		private var SmilePositive:Class;
		public var smilePositive:BitmapData = new SmilePositive().bitmapData;
		
		[Embed(source = "Textures/TutorialArrow.png")]
		private var TutorialArrow:Class;
		public var tutorialArrow:BitmapData = new TutorialArrow().bitmapData;
		
		[Embed(source="Textures/QuestArrow.png")]
		private var QuestArrow:Class;
		public var questArrow:BitmapData = new QuestArrow().bitmapData;
		
		[Embed(source="Textures/Bubble.png")]
		private var Bubble:Class;
		public var bubble:BitmapData = new Bubble().bitmapData;
		
		[Embed(source = "Textures/DialogBacking.png")]
		private var DialogBacking:Class;
		public var dialogBacking:BitmapData = new DialogBacking().bitmapData;
		
		[Embed(source="Textures/DialogTail.png")]
		private var DialogTail:Class;
		public var dialogTail:BitmapData = new DialogTail().bitmapData;
		
		[Embed(source="Textures/salesPanel/SaleBacking1.png")]
		private var SaleBacking1:Class;
		public var saleBacking1:BitmapData = new SaleBacking1().bitmapData;
		
		
		[Embed(source="Textures/salesPanel/SaleBacking2.png")]
		private var SaleBacking2:Class;
		public var saleBacking2:BitmapData = new SaleBacking2().bitmapData;
		
		[Embed(source="Textures/salesPanel/SaleBacking3.png")]
		private var SaleBacking3:Class;
		public var saleBacking3:BitmapData = new SaleBacking3().bitmapData;
		
		[Embed(source="Textures/salesPanel/SaleBacking11.png")]
		private var SaleBacking11:Class;
		public var saleBacking11:BitmapData = new SaleBacking11().bitmapData;
		
		[Embed(source="Textures/BuildIcon.png")]
		private var BuildIcon:Class;
		public var buildIcon:BitmapData = new BuildIcon().bitmapData;
		
		[Embed(source="Textures/bank/Hole.png")]
		private var Hole:Class;
		public var hole:BitmapData = new Hole().bitmapData;
		
		[Embed(source="Textures/bank/SaleLabelBank.png")]
		private var SaleLabelBank:Class;
		public var saleLabelBank:BitmapData = new SaleLabelBank().bitmapData;
		
		[Embed(source="Textures/bank/mixieLogo.png")]
		private var MixieLogo:Class;
		public var mixieLogo:BitmapData = new MixieLogo().bitmapData;
		
		[Embed(source="Textures/bank/LabelUCJap.png")]
		private var LabelUCJap:Class;
		public var labelUCJap:BitmapData = new LabelUCJap().bitmapData;
		
		[Embed(source="Textures/bank/LabelUCEng.png")]
		private var LabelUCEng:Class;
		public var labelUCEng:BitmapData = new LabelUCEng().bitmapData;
		
		[Embed(source="Textures/bank/LabelUC1.png")]
		private var LabelUC1:Class;
		public var labelUC1:BitmapData = new LabelUC1().bitmapData;
		
		[Embed(source="Textures/bank/LabelBDJap.png")]
		private var LabelBDJap:Class;
		public var labelBDJap:BitmapData = new LabelBDJap().bitmapData;
		
		[Embed(source="Textures/bank/LabelBDEng.png")]
		private var LabelBDEng:Class;
		public var labelBDEng:BitmapData = new LabelBDEng().bitmapData;
		
		[Embed(source="Textures/bank/LabelBD1.png")]
		private var LabelBD1:Class;
		public var labelBD1:BitmapData = new LabelBD1().bitmapData;
		
		[Embed(source="Textures/bank/BonusRedRibbon.png")]
		private var BonusRedRibbon:Class;
		public var bonusRedRibbon:BitmapData = new BonusRedRibbon().bitmapData;
		
		[Embed(source="Textures/bank/BankItemBackingBonus.png")]
		private var BankItemBackingBonus:Class;
		public var bankItemBackingBonus:BitmapData = new BankItemBackingBonus().bitmapData;
		
		[Embed(source="Textures/CoinsIcon.png")]
		private var CoinsIcon:Class;
		public var coinsIcon:BitmapData = new CoinsIcon().bitmapData;
		
		[Embed(source="Textures/CoinsIcon_jp.png")]
		private var CoinsIcon_jp:Class;
		public var coinsIcon_jp:BitmapData = new CoinsIcon_jp().bitmapData;
		
		[Embed(source="Textures/EnergyIcon.png")]
		private var EnergyIcon:Class;
		public var energyIcon:BitmapData = new EnergyIcon().bitmapData;
		
		[Embed(source="Textures/FantsIcon.png")]
		private var FantsIcon:Class;
		public var fantsIcon:BitmapData = new FantsIcon().bitmapData;
		
		[Embed(source="Textures/ExpIcon.png")]
		private var ExpIcon:Class;
		public var expIcon:BitmapData = new ExpIcon().bitmapData;
		
		[Embed(source="Textures/FoodIcon.png")]
		private var FoodIcon:Class;
		public var foodIcon:BitmapData = new FoodIcon().bitmapData;
		
		[Embed(source = "Textures/AddBttnBlue.png")]
		private var AddBttnBlue:Class;
		public var addBttnBlue:BitmapData = new AddBttnBlue().bitmapData;
		
		[Embed(source = "Textures/AddBttnGreen.png")]
		private var AddBttnGreen:Class;
		public var addBttnGreen:BitmapData = new AddBttnGreen().bitmapData;
		
		[Embed(source = "Textures/AddBttnWhite.png")]
		private var AddBttnWhite:Class;
		public var addBttnWhite:BitmapData = new AddBttnWhite().bitmapData;
		
		[Embed(source = "Textures/AddBttnYellow.png")]
		private var AddBttnYellow:Class;
		public var addBttnYellow:BitmapData = new AddBttnYellow().bitmapData;
		
		[Embed(source = "Textures/BackingLeft.png")]
		private var BackingLeft:Class;
		public var backingLeft:BitmapData = new BackingLeft().bitmapData;
		
		[Embed(source = "Textures/BackingRight.png")]
		private var BackingRight:Class;
		public var backingRight:BitmapData = new BackingRight().bitmapData;
		
		[Embed(source = "Textures/BttnCollection.png")]
		private var BttnCollection:Class;
		public var bttnCollection:BitmapData = new BttnCollection().bitmapData;
		
		[Embed(source = "Textures/BttnCursor.png")]
		private var BttnCursor:Class;
		public var bttnCursor:BitmapData = new BttnCursor().bitmapData;
		
		[Embed(source = "Textures/BttnGift.png")]
		private var BttnGift:Class;
		public var bttnGift:BitmapData = new BttnGift().bitmapData;
		
		[Embed(source = "Textures/BttnMap.png")]
		private var BttnMap:Class;
		public var bttnMap:BitmapData = new BttnMap().bitmapData;
		
		[Embed(source = "Textures/BttnShop.png")]
		private var BttnShop:Class;
		public var bttnShop:BitmapData = new BttnShop().bitmapData;
		
		[Embed(source = "Textures/BttnStop.png")]
		private var BttnStop:Class;
		public var bttnStop:BitmapData = new BttnStop().bitmapData;
		
		[Embed(source = "Textures/BttnStorage.png")]
		private var BttnStorage:Class;
		public var bttnStorage:BitmapData = new BttnStorage().bitmapData;
		
		[Embed(source = "Textures/CounterBacking.png")]
		private var CounterBacking:Class;
		public var counterBacking:BitmapData = new CounterBacking().bitmapData;
		
		[Embed(source = "Textures/CursorIconDelete.png")]
		private var CursorIconDelete:Class;
		public var cursorIconDelete:BitmapData = new CursorIconDelete().bitmapData;
		
		[Embed(source = "Textures/CursorIconMove.png")]
		private var CursorIconMove:Class;
		public var cursorIconMove:BitmapData = new CursorIconMove().bitmapData;
		
		[Embed(source = "Textures/CursorIconRotare.png")]
		private var CursorIconRotare:Class;
		public var cursorIconRotare:BitmapData = new CursorIconRotare().bitmapData;
		
		[Embed(source = "Textures/CursorIconStorage.png")]
		private var CursorIconStorage:Class;
		public var cursorIconStorage:BitmapData = new CursorIconStorage().bitmapData;
		
		[Embed(source = "Textures/DefaultNeiborAvatar.png")]
		private var DefaultNeiborAvatar:Class;
		public var defaultNeiborAvatar:BitmapData = new DefaultNeiborAvatar().bitmapData;
		
		[Embed(source = "Textures/ErrorPic.png")]
		private var ErrorPic:Class;
		public var errorPic:BitmapData = new ErrorPic().bitmapData;
		
		[Embed(source = "Textures/FriendFreeSlot.png")]
		private var FriendFreeSlot:Class;
		public var friendFreeSlot:BitmapData = new FriendFreeSlot().bitmapData;
		
		[Embed(source = "Textures/FriendMove.png")]
		private var FriendMove:Class;
		public var friendMove:BitmapData = new FriendMove().bitmapData;
		
		[Embed(source = "Textures/FriendMoveAll.png")]
		private var FriendMoveAll:Class;
		public var friendMoveAll:BitmapData = new FriendMoveAll().bitmapData;
		
		[Embed(source = "Textures/FriendsLevel.png")]
		private var FriendsLevel:Class;
		public var friendsLevel:BitmapData = new FriendsLevel().bitmapData;
		
		[Embed(source = "Textures/FriendSlot.png")]
		private var FriendSlot:Class;
		public var friendSlot:BitmapData = new FriendSlot().bitmapData;
		
		[Embed(source = "Textures/FriendsPanelBacking.png")]
		private var FriendsPanelBacking:Class;
		public var friendsPanelBacking:BitmapData = new FriendsPanelBacking().bitmapData;
		
		[Embed(source = "Textures/FriendVisited.png")]
		private var FriendVisited:Class;
		public var friendVisited:BitmapData = new FriendVisited().bitmapData;
		
		[Embed(source = "Textures/GuestEnergy.png")]
		private var GuestEnergy:Class;
		public var guestEnergy:BitmapData = new GuestEnergy().bitmapData;
		
		[Embed(source = "Textures/IconCollection.png")]
		private var IconCollection:Class;
		public var iconCollection:BitmapData = new IconCollection().bitmapData;
		
		[Embed(source = "Textures/IconCursor.png")]
		private var IconCursor:Class;
		public var iconCursor:BitmapData = new IconCursor().bitmapData;
		
		[Embed(source = "Textures/IconGift.png")]
		private var IconGift:Class;
		public var iconGift:BitmapData = new IconGift().bitmapData;
		
		[Embed(source = "Textures/IconMap.png")]
		private var IconMap:Class;
		public var iconMap:BitmapData = new IconMap().bitmapData;
		
		[Embed(source = "Textures/IconShop.png")]
		private var IconShop:Class;
		public var iconShop:BitmapData = new IconShop().bitmapData;
		
		[Embed(source = "Textures/IconStop.png")]
		private var IconStop:Class;
		public var iconStop:BitmapData = new IconStop().bitmapData;
		
		[Embed(source = "Textures/IconStorage.png")]
		private var IconStorage:Class;
		public var iconStorage:BitmapData = new IconStorage().bitmapData;
		
		[Embed(source = "Textures/IconWorker.png")]
		private var IconWorker:Class;
		public var iconWorker:BitmapData = new IconWorker().bitmapData;
		
		[Embed(source = "Textures/NewTerritoryIcon.png")]
		private var NewTerritoryIcon:Class;
		public var newTerritoryIcon:BitmapData = new NewTerritoryIcon().bitmapData;
		
		[Embed(source = "Textures/OptionsAnimationIco.png")]
		private var OptionsAnimationIco:Class;
		public var optionsAnimationIco:BitmapData = new OptionsAnimationIco().bitmapData;
		
		[Embed(source = "Textures/OptionsFullscreenIco.png")]
		private var OptionsFullscreenIco:Class;
		public var optionsFullscreenIco:BitmapData = new OptionsFullscreenIco().bitmapData;
		
		[Embed(source = "Textures/OptionsMusicIco.png")]
		private var OptionsMusicIco:Class;
		public var optionsMusicIco:BitmapData = new OptionsMusicIco().bitmapData;
		
		[Embed(source = "Textures/OptionsScreenshot.png")]
		private var OptionsScreenshot:Class;
		public var optionsScreenshot:BitmapData = new OptionsScreenshot().bitmapData;
		
		[Embed(source = "Textures/OptionsSoundIco.png")]
		private var OptionsSoundIco:Class;
		public var optionsSoundIco:BitmapData = new OptionsSoundIco().bitmapData;
		
		[Embed(source = "Textures/OptionsZoomInIco.png")]
		private var OptionsZoomInIco:Class;
		public var optionsZoomInIco:BitmapData = new OptionsZoomInIco().bitmapData;
		
		[Embed(source = "Textures/OptionsSnowIco.png")]
		private var OptionsSnowIco:Class;
		public var optionsSnowIco:BitmapData = new OptionsSnowIco().bitmapData;
		
		[Embed(source = "Textures/OptionsZoomOutIco.png")]
		private var OptionsZoomOutIco:Class;
		public var optionsZoomOutIco:BitmapData = new OptionsZoomOutIco().bitmapData;
		
		[Embed(source="Textures/OptionsBacking.png")]
		private var OptionsBacking:Class;
		public var optionsBacking:BitmapData = new OptionsBacking().bitmapData;
		
		[Embed(source="Textures/OptionsHideBttn.png")]
		private var OptionsHideBttn:Class;
		public var optionsHideBttn:BitmapData = new OptionsHideBttn().bitmapData;
		
		[Embed(source = "Textures/PanelBucks.png")]
		private var PanelBucks:Class;
		public var panelBucks:BitmapData = new PanelBucks().bitmapData;
		
		[Embed(source = "Textures/PanelEnergy.png")]
		private var PanelEnergy:Class;
		public var panelEnergy:BitmapData = new PanelEnergy().bitmapData;
		
		[Embed(source = "Textures/PanelExp.png")]
		private var PanelExp:Class;
		public var panelExp:BitmapData = new PanelExp().bitmapData;
		
		[Embed(source = "Textures/PanelMoney.png")]
		private var PanelMoney:Class;
		public var panelMoney:BitmapData = new PanelMoney().bitmapData;
		
		[Embed(source = "Textures/PanelWorkers.png")]
		private var PanelWorkers:Class;
		public var panelWorkers:BitmapData = new PanelWorkers().bitmapData;
		
		[Embed(source = "Textures/ProgressBarEnergy.png")]
		private var ProgressBarEnergy:Class;
		public var progressBarEnergy:BitmapData = new ProgressBarEnergy().bitmapData;
		
		[Embed(source = "Textures/ProgressBarExp.png")]
		private var ProgressBarExp:Class;
		public var progressBarExp:BitmapData = new ProgressBarExp().bitmapData;
		
		[Embed(source = "Textures/QuestHuntsmanIco.png")]
		private var QuestHuntsmanIco:Class;
		public var questHuntsmanIco:BitmapData = new QuestHuntsmanIco().bitmapData;
		
		[Embed(source = "Textures/QuestLadyIco.png")]
		private var QuestLadyIco:Class;
		public var questLadyIco:BitmapData = new QuestLadyIco().bitmapData;
		
		[Embed(source = "Textures/SellBttn.png")]
		private var SellBttn:Class;
		public var sellBttn:BitmapData = new SellBttn().bitmapData;
		
		[Embed(source="Textures/Shadow.png")]
		private var Shadow:Class;
		public var shadow:BitmapData = new Shadow().bitmapData;
		
		[Embed(source="Textures/BackingRightGuest.png")]
		private var BackingRightGuest:Class;
		public var backingRightGuest:BitmapData = new BackingRightGuest().bitmapData;
		
		
		// Cursor
		
		//[Embed(source = "Textures/cursors/CursorAxe.png")]
		//private var CursorAxe:Class;
		//public var cursorAxe:BitmapData = new CursorAxe().bitmapData;
		//
		//[Embed(source = "Textures/cursors/CursorPick.png")]
		//private var CursorPick:Class;
		//public var cursorPick:BitmapData = new CursorPick().bitmapData;
		//
		//
		//[Embed(source = "Textures/cursors/CursorShears.png")]
		//private var CursorShears:Class;
		//public var cursorShears:BitmapData = new CursorShears().bitmapData;
		//
		//[Embed(source = "Textures/cursors/CursorSickle.png")]
		//private var CursorSickle:Class;
		//public var cursorSickle:BitmapData = new CursorSickle().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorBuildingIn.png")]
		private var CursorBuildingIn:Class;
		public var cursorBuildingIn:BitmapData = new CursorBuildingIn().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorDefault.png")]
		private var CursorDefault:Class;
		public var cursorDefault:BitmapData = new CursorDefault().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorLocked.png")]
		private var CursorLocked:Class;
		public var cursorLocked:BitmapData = new CursorLocked().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorMove.png")]
		private var CursorMove:Class;
		public var cursorMove:BitmapData = new CursorMove().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorRemove.png")]
		private var CursorRemove:Class;
		public var cursorRemove:BitmapData = new CursorRemove().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorRotate.png")]
		private var CursorRotate:Class;
		public var cursorRotate:BitmapData = new CursorRotate().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorStock.png")]
		private var CursorStock:Class;
		public var cursorStock:BitmapData = new CursorStock().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorStoneCollect.png")]
		private var CursorStoneCollect:Class;
		public var cursorStoneCollect:BitmapData = new CursorStoneCollect().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorTake.png")]
		private var CursorTake:Class;
		public var cursorTake:BitmapData = new CursorTake().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorWaterDrop.png")]
		private var CursorWaterDrop:Class;
		public var cursorWaterDrop:BitmapData = new CursorWaterDrop().bitmapData;
		
		[Embed(source = "Textures/cursors/CursorWoodCollect.png")]
		private var CursorWoodCollect:Class;
		public var cursorWoodCollect:BitmapData = new CursorWoodCollect().bitmapData;
		
		[Embed(source = "Textures/WishlistPlusBttn.png")]
		private var WishlistPlusBttn:Class;
		public var wishlistPlusBttn:BitmapData = new WishlistPlusBttn().bitmapData;
		
		
		[Embed(source = "Textures/WishlistHasBttn.png")]
		private var WishlistHasBttn:Class;
		public var wishlistHasBttn:BitmapData = new WishlistHasBttn().bitmapData;		
		
		[Embed(source = "Textures/BankLogo.png")]
		private var BankLogo:Class;
		public var bankLogo:BitmapData = new BankLogo().bitmapData;	
		
		[Embed(source = "Textures/Treasure.png")]
		private var Treasure:Class;
		public var treasure:BitmapData = new Treasure().bitmapData;
		
		[Embed(source = "Textures/InterBankSale.png")]
		private var InterBankSale:Class;
		public var interBankSale:BitmapData = new InterBankSale().bitmapData;
		
		[Embed(source = "Textures/WheelArrow.png")]
		private var WheelArrow:Class;
		public var wheelArrow:BitmapData = new WheelArrow().bitmapData;
		
		[Embed(source = "Textures/WheelOfFortune.png")]
		private var WheelOfFortune:Class;
		public var wheelOfFortune:BitmapData = new WheelOfFortune().bitmapData;
		
		[Embed(source = "Textures/PuzzleIco.png")]
		private var PuzzleIco:Class;
		public var puzzleIco:BitmapData = new PuzzleIco().bitmapData;
		
		[Embed(source = "Textures/CommunityIco.png")]
		private var CommunityIco:Class;
		public var communityIco:BitmapData = new CommunityIco().bitmapData;
		
		[Embed(source = "Textures/Community.jpg")]
		private var Community:Class;
		public var community:BitmapData = new Community().bitmapData;
		
		[Embed(source = "Textures/FreebyBttn.png")]
		private var FreebyBttn:Class;
		public var freebyBttn:BitmapData = new FreebyBttn().bitmapData;
		
		[Embed(source = "Textures/FrancsIco.png")]
		private var FrancsIco:Class;
		public var francsIco:BitmapData = new FrancsIco().bitmapData;
		
		[Embed(source = "Textures/ShareIco.png")]
		private var ShareIco:Class;
		public var shareIco:BitmapData = new ShareIco().bitmapData;
		
		[Embed(source = "Textures/RichRedNewLabel.png")]
		private var RichRedNewLabel:Class;
		public var richRedNewLabel:BitmapData = new RichRedNewLabel().bitmapData;
		
		[Embed(source = "Textures/HelloweenMoneyIco.png")]
		private var HelloweenMoneyIco:Class;
		public var helloweenMoneyIco:BitmapData = new HelloweenMoneyIco().bitmapData;
		
		[Embed(source = "Textures/FriendsActionBonusBacking.png")]
		private var FriendsActionBonusBacking:Class;
		public var friendsActionBonusBacking:BitmapData = new FriendsActionBonusBacking().bitmapData;
		
		[Embed(source = "Textures/FriendsBonusRoundBacking.png")]
		private var FriendsBonusRoundBacking:Class;
		public var friendsBonusRoundBacking:BitmapData = new FriendsBonusRoundBacking().bitmapData;
		
		[Embed(source = "Textures/InterSleepIco.png")]
		private var InterSleepIco:Class;
		public var interSleepIco:BitmapData = new InterSleepIco().bitmapData;
		
		[Embed(source = "Textures/SilverCoin.png")]
		private var SilverCoin:Class;
		public var silverCoin:BitmapData = new SilverCoin().bitmapData;
		
		[Embed(source = "Textures/InterExpDynamiteIco.png")]
		private var InterExpDynamiteIco:Class;
		public var interExpDynamiteIco:BitmapData = new InterExpDynamiteIco().bitmapData;
		
		[Embed(source = "Textures/ExpShipPic.png")]
		private var ExpShipPic:Class;
		public var expShipPic:BitmapData = new ExpShipPic().bitmapData;
		
		
		
		
		
		// Minigame
		[Embed(source = "Textures/SelectIcon.png")]
		private var SelectIcon:Class;
		public var selectIcon:BitmapData = new SelectIcon().bitmapData;
		
		[Embed(source = "Textures/SelectIconPuzzle.png")]
		private var SelectIconPuzzle:Class;
		public var selectIconPuzzle:BitmapData = new SelectIconPuzzle().bitmapData;
		
		[Embed(source = "Textures/PuzzleIcon.png")]
		private var PuzzleIcon:Class;
		public var puzzleIcon:BitmapData = new PuzzleIcon().bitmapData;
		
		[Embed(source = "Textures/PuzzleBrownIcon.png")]
		private var PuzzleBrownIcon:Class;
		public var puzzleBrownIcon:BitmapData = new PuzzleBrownIcon().bitmapData;
		
		[Embed(source = "Textures/PointEmpty.png")]
		private var PointEmpty:Class;
		public var pointEmpty:BitmapData = new PointEmpty().bitmapData;
		
		[Embed(source = "Textures/PointTarget.png")]
		private var PointTarget:Class;
		public var pointTarget:BitmapData = new PointTarget().bitmapData;
		
		[Embed(source = "Textures/PointSelect.png")]
		private var PointSelect:Class;
		public var pointSelect:BitmapData = new PointSelect().bitmapData;
		
		[Embed(source = "Textures/IconExpansion.png")]
		private var IconExpansion:Class;
		public var iconExpansion:BitmapData = new IconExpansion().bitmapData;
		
		[Embed(source = "Textures/RoadYellow.png")]
		private var RoadYellow:Class;
		public var roadYellow:BitmapData = new RoadYellow().bitmapData;
		
		[Embed(source = "Textures/RoadBlue.png")]
		private var RoadBlue:Class;
		public var roadBlue:BitmapData = new RoadBlue().bitmapData;
		
		[Embed(source = "Textures/PriceView.png")]
		private var PriceView:Class;
		public var priceView:BitmapData = new PriceView().bitmapData;
		
		[Embed(source = "Textures/PriceView2.png")]
		private var PriceView2:Class;
		public var priceView2:BitmapData = new PriceView2().bitmapData;
		
		[Embed(source = "Textures/CouponIco.png")]
		private var CouponIco:Class;
		public var couponIco:BitmapData = new CouponIco().bitmapData;
		
		[Embed(source = "Textures/WorkerIco.png")]
		private var WorkerIco:Class;
		public var workerIco:BitmapData = new WorkerIco().bitmapData;
		
		[Embed(source = "Textures/VoucherIco.png")]
		private var VoucherIco:Class;
		public var voucherIco:BitmapData = new VoucherIco().bitmapData;
		
		
		// Underground
		
		[Embed(source = "Textures/PointYellow.png")]
		private var PointYellow:Class;
		public var pointYellow:BitmapData = new PointYellow().bitmapData;
		
		[Embed(source = "Textures/ground1.png")]
		private var Ground1:Class;
		public var ground1:BitmapData = new Ground1().bitmapData;
		
		[Embed(source = "Textures/ground2.png")]
		private var Ground2:Class;
		public var ground2:BitmapData = new Ground2().bitmapData;
		
		[Embed(source = "Textures/ground3.png")]
		private var Ground3:Class;
		public var ground3:BitmapData = new Ground3().bitmapData;
		
		[Embed(source = "Textures/ground4.png")]
		private var Ground4:Class;
		public var ground4:BitmapData = new Ground4().bitmapData;
		
		[Embed(source = "Textures/ground5.png")]
		private var Ground5:Class;
		public var ground5:BitmapData = new Ground5().bitmapData;
		
		[Embed(source = "Textures/ground6.png")]
		private var Ground6:Class;
		public var ground6:BitmapData = new Ground6().bitmapData;
		
		[Embed(source = "Textures/ground7.png")]
		private var Ground7:Class;
		public var ground7:BitmapData = new Ground7().bitmapData;
		
		[Embed(source = "Textures/stoneBlocker.png")]
		private var StoneBlocker:Class;
		public var stoneBlocker:BitmapData = new StoneBlocker().bitmapData;
		
		
		public function PanelsLib():void 
		{
		
		}
	}
}