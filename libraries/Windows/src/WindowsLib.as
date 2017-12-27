package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	
	
	public class WindowsLib extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
		
		
		// ---------------------------------------------------------------------------------------------------
		
		
		[Embed(source = "Textures/ActionGlow.png")]
		private var ActionGlow:Class;
		public var actionGlow:BitmapData = new ActionGlow().bitmapData;
		
		
		[Embed(source = "Textures/ShowMeBttn.png")]
		private var ShowMeBttn:Class;
		public var showMeBttn:BitmapData = new ShowMeBttn().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile1.png")]
		private var Tile1:Class;
		public var tile1:BitmapData = new Tile1().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile10.png")]
		private var Tile10:Class;
		public var tile10:BitmapData = new Tile10().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile2.png")]
		private var Tile2:Class;
		public var tile2:BitmapData = new Tile2().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile3.png")]
		private var Tile3:Class;
		public var tile3:BitmapData = new Tile3().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile4.png")]
		private var Tile4:Class;
		public var tile4:BitmapData = new Tile4().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile5.png")]
		private var Tile5:Class;
		public var tile5:BitmapData = new Tile5().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile6.png")]
		private var Tile6:Class;
		public var tile6:BitmapData = new Tile6().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile7.png")]
		private var Tile7:Class;
		public var tile7:BitmapData = new Tile7().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile8.png")]
		private var Tile8:Class;
		public var tile8:BitmapData = new Tile8().bitmapData;
		
		[Embed(source = "Textures/Calendar/Tile9.png")]
		private var Tile9:Class;
		public var tile9:BitmapData = new Tile9().bitmapData;
		
		[Embed(source = "Textures/Calendar/WorkerHouseBacking.png")]
		private var WorkerHouseBacking:Class;
		public var workerHouseBacking:BitmapData = new WorkerHouseBacking().bitmapData;
		
		[Embed(source = "Textures/TimerBacking.png")]
		private var TimerBacking:Class;
		public var timerBacking:BitmapData = new TimerBacking().bitmapData;
		
		
		// ---------------------------------------------------------------------------------------------------
		
		
		[Embed(source="Textures/BoosterSaleBacking.png")]
		private var BoosterSaleBacking:Class;
		public var boosterSaleBacking:BitmapData = new BoosterSaleBacking().bitmapData;
		
		[Embed(source="Textures/CommGiftWin.png")]
		private var CommGiftWin:Class;
		public var commGiftWin:BitmapData = new CommGiftWin().bitmapData;
		
		[Embed(source="Textures/ShareBonusBacking.png")]
		private var ShareBonusBacking:Class;
		public var shareBonusBacking:BitmapData = new ShareBonusBacking().bitmapData;
		
		[Embed(source="Textures/Treasure.png")]
		private var Treasure:Class;
		public var treasure:BitmapData = new Treasure().bitmapData;
		
		[Embed(source="Textures/AlertBackingEmpty.png")]
		private var AlertBackingEmpty:Class;
		public var alertBackingEmpty:BitmapData = new AlertBackingEmpty().bitmapData;
		
		[Embed(source="Textures/ArrowNewYellow.png")]
		private var ArrowNewYellow:Class;
		public var arrowNewYellow:BitmapData = new ArrowNewYellow().bitmapData;
		
		// Есть в панелях
		[Embed(source="Textures/ArrowNewYellowWWhite.png")]
		private var ArrowNewYellowWWhite:Class;
		public var arrowNewYellowWWhite:BitmapData = new ArrowNewYellowWWhite().bitmapData;
		
		[Embed(source="Textures/DialogueBacking.png")]
		private var DialogueBacking:Class;
		public var dialogueBacking:BitmapData = new DialogueBacking().bitmapData;
		
		[Embed(source="Textures/DialogueBackingDec.png")]
		private var DialogueBackingDec:Class;
		public var dialogueBackingDec:BitmapData = new DialogueBackingDec().bitmapData;
		
		[Embed(source="Textures/GoldenNuggetIco.png")]
		private var GoldenNuggetIco:Class;
		public var goldenNuggetIco:BitmapData = new GoldenNuggetIco().bitmapData;
		
		[Embed(source="Textures/UpgradeDec.png")]
		private var UpgradeDec:Class;
		public var upgradeDec:BitmapData = new UpgradeDec().bitmapData;
		
		[Embed(source="Textures/InterSaleBackingBlue.png")]
		private var InterSaleBackingBlue:Class;
		public var interSaleBackingBlue:BitmapData = new InterSaleBackingBlue().bitmapData;
		
		[Embed(source="Textures/InterSaleBackingGreen.png")]
		private var InterSaleBackingGreen:Class;
		public var interSaleBackingGreen:BitmapData = new InterSaleBackingGreen().bitmapData;
		
		[Embed(source="Textures/InterSaleBackingOrange.png")]
		private var InterSaleBackingOrange:Class;
		public var interSaleBackingOrange:BitmapData = new InterSaleBackingOrange().bitmapData;
		
		[Embed(source="Textures/InterSaleBackingYellow.png")]
		private var InterSaleBackingYellow:Class;
		public var interSaleBackingYellow:BitmapData = new InterSaleBackingYellow().bitmapData;
		
		[Embed(source="Textures/CheckboxEmpty.png")]
		private var CheckboxEmpty:Class;
		public var checkboxEmpty:BitmapData = new CheckboxEmpty().bitmapData;
		
		[Embed(source="Textures/QuestCompleTitleDec.png")]
		private var QuestCompleTitleDec:Class;
		public var questCompleTitleDec:BitmapData = new QuestCompleTitleDec().bitmapData;
		
		[Embed(source="Textures/CheckboxWMark.png")]
		private var CheckboxWMark:Class;
		public var checkboxWMark:BitmapData = new CheckboxWMark().bitmapData;
		
		
		[Embed(source="Textures/GoalsChatsHuntsman.png")]
		private var GoalsChatsHuntsman:Class;
		public var goalsChatsHuntsman:BitmapData = new GoalsChatsHuntsman().bitmapData;
		
		[Embed(source="Textures/GoalsChatsLady.png")]
		private var GoalsChatsLady:Class;
		public var goalsChatsLady:BitmapData = new GoalsChatsLady().bitmapData;
		
		[Embed(source="Textures/GoalsChatsGuide.png")]
		private var GoalsChatsGuide:Class;
		public var goalsChatsGuide:BitmapData = new GoalsChatsGuide().bitmapData;
		
		[Embed(source="Textures/GoalsChatsMiner.png")]
		private var GoalsChatsMiner:Class;
		public var goalsChatsMiner:BitmapData = new GoalsChatsMiner().bitmapData;
		
		[Embed(source="Textures/GoalsChatsMiner2.png")]
		private var GoalsChatsMiner2:Class;
		public var goalsChatsMiner2:BitmapData = new GoalsChatsMiner2().bitmapData;
		
		[Embed(source="Textures/GoalsChatsBigMarie.png")]
		private var GoalsChatsBigMarie:Class;
		public var goalsChatsBigMarie:BitmapData = new GoalsChatsBigMarie().bitmapData;
		
		[Embed(source="Textures/GoalsChatsSheriff.png")]
		private var GoalsChatsSheriff:Class;
		public var goalsChatsSheriff:BitmapData = new GoalsChatsSheriff().bitmapData;
		
		[Embed(source="Textures/GoalsChatsBandit.png")]
		private var GoalsChatsBandit:Class;
		public var goalsChatsBandit:BitmapData = new GoalsChatsBandit().bitmapData;
		
		[Embed(source="Textures/TravelPic.png")]
		private var TravelPic:Class;
		public var travelPic:BitmapData = new TravelPic().bitmapData;
		
		[Embed(source="Textures/MoneyIco.png")]
		private var MoneyIco:Class;
		public var moneyIco:BitmapData = new MoneyIco().bitmapData;
		
		[Embed(source="Textures/MoneyIco_jp.png")]
		private var MoneyIco_jp:Class;
		public var moneyIco_jp:BitmapData = new MoneyIco_jp().bitmapData;
		
		[Embed(source="Textures/InterAddBttnGreen.png")]
		private var InterAddBttnGreen:Class;
		public var interAddBttnGreen:BitmapData = new InterAddBttnGreen().bitmapData;
		
		[Embed(source="Textures/FoodIco.png")]
		private var FoodIco:Class;
		public var foodIco:BitmapData = new FoodIco().bitmapData;
		
		[Embed(source="Textures/DownloadBacking.png")]
		private var DownloadBacking:Class;
		public var  downloadBacking:BitmapData = new DownloadBacking().bitmapData;
		
		[Embed(source="Textures/Crown.png")]
		private var Crown:Class;
		public var crown:BitmapData = new Crown().bitmapData;
		
		[Embed(source="Textures/ReferalRoundBacking.png")]
		private var ReferalRoundBacking:Class;
		public var referalRoundBacking:BitmapData = new ReferalRoundBacking().bitmapData;
		
		[Embed(source="Textures/CursorsPanelItemBg.png")]
		private var CursorsPanelItemBg:Class;
		public var cursorsPanelItemBg:BitmapData = new CursorsPanelItemBg().bitmapData;
		
		[Embed(source="Textures/CursorsPanelBg2.png")]
		private var CursorsPanelBg2:Class;
		public var cursorsPanelBg2:BitmapData = new CursorsPanelBg2().bitmapData;		
		
		[Embed(source="Textures/CursorsPanelBg3.png")]
		private var CursorsPanelBg3:Class;
		public var cursorsPanelBg3:BitmapData = new CursorsPanelBg3().bitmapData;
		
		[Embed(source="Textures/BankItemBacking.png")]
		private var BankItemBacking:Class;
		public var bankItemBacking:BitmapData = new BankItemBacking().bitmapData;		
		
		
		[Embed(source="Textures/FriendSlot.png")]
		private var FriendSlot:Class;
		public var friendSlot:BitmapData = new FriendSlot().bitmapData;
		
		[Embed(source="Textures/BarterArrowYellow.png")]
		private var BarterArrowYellow:Class;
		public var barterArrowYellow:BitmapData = new BarterArrowYellow().bitmapData;
		
		[Embed(source="Textures/BarterCenterBacking.png")]
		private var BarterCenterBacking:Class;
		public var barterCenterBacking:BitmapData = new BarterCenterBacking().bitmapData;
		
		[Embed(source="Textures/NewLevelTitleDec.png")]
		private var NewLevelTitleDec:Class;
		public var newLevelTitleDec:BitmapData = new NewLevelTitleDec().bitmapData;
		
		[Embed(source="Textures/ProgBarBacking.png")]
		private var ProgBarBacking:Class;
		public var progBarBacking:BitmapData = new ProgBarBacking().bitmapData;
		
		[Embed(source="Textures/PrograssBarBacking.png")]
		private var PrograssBarBacking:Class;
		public var prograssBarBacking:BitmapData = new PrograssBarBacking().bitmapData;
		
		[Embed(source="Textures/ShopBackingBotWithRope.png")]
		private var ShopBackingBotWithRope:Class;
		public var shopBackingBotWithRope:BitmapData = new ShopBackingBotWithRope().bitmapData;
		
		[Embed(source="Textures/DecorStar.png")]
		private var DecorStar:Class;
		public var decorStar:BitmapData = new DecorStar().bitmapData;
		
		//[Embed(source="Textures/InterQuestIcoLady.png")]
		//private var InterQuestIcoLady:Class;
		//public var interQuestIcoLady:BitmapData = new InterQuestIcoLady().bitmapData;
		
		[Embed(source="Textures/CollectionCenterBacking.png")]
		private var CollectionCenterBacking:Class;
		public var collectionCenterBacking:BitmapData = new CollectionCenterBacking().bitmapData;
		
		[Embed(source="Textures/InterAddBttnYellow.png")]
		private var InterAddBttnYellow:Class;
		public var interAddBttnYellow:BitmapData = new InterAddBttnYellow().bitmapData;
		
		[Embed(source="Textures/StockBackingTopWithoutSlate.png")]
		private var StockBackingTopWithoutSlate:Class;
		public var stockBackingTopWithoutSlate:BitmapData = new StockBackingTopWithoutSlate().bitmapData;
		
		[Embed(source="Textures/Points.png")]
		private var Points:Class;
		public var points:BitmapData = new Points().bitmapData;
		
		[Embed(source="Textures/Arrow.png")]
		private var Arrow:Class;
		public var arrow:BitmapData = new Arrow().bitmapData;
		
		[Embed(source="Textures/CloseBttn.png")]
		private var CloseBttn:Class;
		public var closeBttn:BitmapData = new CloseBttn().bitmapData;
		
		[Embed(source = "Textures/DeleteBttn.png")]
		private var DeleteBttn:Class;
		public var deleteBttn:BitmapData = new DeleteBttn().bitmapData;
		
		[Embed(source="Textures/ItemBacking.png")]
		private var ItemBacking:Class;
		public var itemBacking:BitmapData = new ItemBacking().bitmapData;
		
		[Embed(source = "Textures/ShopBackingBot.png")]
		private var ShopBackingBot:Class;
		public var shopBackingBot:BitmapData = new ShopBackingBot().bitmapData;
		
		[Embed(source = "Textures/ShopBackingTop.png")]
		private var ShopBackingTop:Class;
		public var shopBackingTop:BitmapData = new ShopBackingTop().bitmapData;
		
		[Embed(source = "Textures/ShopTitleBacking.png")]
		private var ShopTitleBacking:Class;
		public var shopTitleBacking:BitmapData = new ShopTitleBacking().bitmapData;
		
		[Embed(source="Textures/StockBackingBot.png")]
		private var StockBackingBot:Class;
		public var stockBackingBot:BitmapData = new StockBackingBot().bitmapData;
		
		[Embed(source="Textures/StockBackingTop.png")]
		private var StockBackingTop:Class;
		public var stockBackingTop:BitmapData = new StockBackingTop().bitmapData;
		
		[Embed(source="Textures/StockTitleBacking.png")]
		private var StockTitleBacking:Class;
		public var stockTitleBacking:BitmapData = new StockTitleBacking().bitmapData;
		
		
		
		[Embed(source="Textures/TitleDecRose.png")]
		private var TitleDecRose:Class;
		public var titleDecRose:BitmapData = new TitleDecRose().bitmapData;
		
		[Embed(source="Textures/Checkmark.png")]
		private var CheckMark:Class;
		public var checkMark:BitmapData = new CheckMark().bitmapData;
		
		[Embed(source="Textures/CheckmarkSlim.png")]
		private var CheckmarkSlim:Class;
		public var checkmarkSlim:BitmapData = new CheckmarkSlim().bitmapData;
		
		[Embed(source = "Textures/AlertBacking.png")]
		private var AlertBacking:Class;
		public var alertBacking:BitmapData = new AlertBacking().bitmapData;
		
		[Embed(source = "Textures/CheckmarkSlot.png")]
		private var CheckmarkSlot:Class;
		public var checkmarkSlot:BitmapData = new CheckmarkSlot().bitmapData;
		
		[Embed(source = "Textures/BackingBot.png")]
		private var BackingBot:Class;
		public var backingBot:BitmapData = new BackingBot().bitmapData;
		
		[Embed(source = "Textures/CollectionRewardBacking.png")]
		private var CollectionRewardBacking:Class;
		public var collectionRewardBacking:BitmapData = new CollectionRewardBacking().bitmapData;
		
		[Embed(source = "Textures/DividerLine.png")]
		private var DividerLine:Class;
		public var dividerLine:BitmapData = new DividerLine().bitmapData;
		
		//[Embed(source = "Textures/EllipsisBlue.png")]
		//private var EllipsisBlue:Class;
		//public var ellipsisBlue:BitmapData = new EllipsisBlue().bitmapData;
		
		[Embed(source = "Textures/FadeOutWhite.png")]
		private var FadeOutWhite:Class;
		public var fadeOutWhite:BitmapData = new FadeOutWhite().bitmapData;
		
		[Embed(source = "Textures/FadeOutYellow.png")]
		private var FadeOutYellow:Class;
		public var fadeOutYellow:BitmapData = new FadeOutYellow().bitmapData;
		
		[Embed(source="Textures/RibbonYellow.png")]
		private var RibbonYellow:Class;
		public var ribbonYellow:BitmapData = new RibbonYellow().bitmapData;
		
		[Embed(source="Textures/Glow.png")]
		private var Glow:Class;
		public var glow:BitmapData = new Glow().bitmapData;
		
		[Embed(source="Textures/SmallArrow.png")]
		private var SmallArrow:Class;
		public var smallArrow:BitmapData = new SmallArrow().bitmapData;
		
		[Embed(source="Textures/QuestIconBacking.png")]
		private var QuestIconBacking:Class;
		public var questIconBacking:BitmapData = new QuestIconBacking().bitmapData;
		
		[Embed(source="Textures/IconGlow.png")]
		private var IconGlow:Class;
		public var iconGlow:BitmapData = new IconGlow().bitmapData;
		
		[Embed(source = "Textures/GlowShine.png")]
		private var GlowShine:Class;
		public var glowShine:BitmapData = new GlowShine().bitmapData;
		
		//[Embed(source = "Textures/GlowRound.png")]
		//private var GlowRound:Class;
		//public var glowRound:BitmapData = new GlowRound().bitmapData;
		
		[Embed(source = "Textures/IconBack.png")]
		private var IconBack:Class;
		public var iconBack:BitmapData = new IconBack().bitmapData;
		
		[Embed(source = "Textures/IconBack2.png")]
		private var IconBack2:Class;
		public var iconBack2:BitmapData = new IconBack2().bitmapData;
		
		//[Embed(source = "Textures/ItemCounterBackingBig.png")]
		//private var ItemCounterBackingBig:Class;
		//public var itemCounterBackingBig:BitmapData = new ItemCounterBackingBig().bitmapData;
		
		//[Embed(source = "Textures/ItemCounterBackingSmall.png")]
		//private var ItemCounterBackingSmall:Class;
		//public var itemCounterBackingSmall:BitmapData = new ItemCounterBackingSmall().bitmapData;
		
		[Embed(source="Textures/SearchDeleteBttn.png")]
		private var SearchDeleteBttn:Class;
		public var searchDeleteBttn:BitmapData = new SearchDeleteBttn().bitmapData;
		
		[Embed(source = "Textures/GoldRibbon.png")]
		private var GoldRibbon:Class;
		public var goldRibbon:BitmapData = new GoldRibbon().bitmapData;
		
		[Embed(source="Textures/StripNew.png")]
		private var StripNew:Class;
		public var stripNew:BitmapData = new StripNew().bitmapData;
		
		[Embed(source="Textures/UpgradeArrow.png")]
		private var UpgradeArrow:Class;
		public var upgradeArrow:BitmapData = new UpgradeArrow().bitmapData;
		
		[Embed(source="Textures/IconProduction.png")]
		private var IconProduction:Class;
		public var iconProduction:BitmapData = new IconProduction().bitmapData;
		
		[Embed(source = "Textures/Timer.png")]
		private var Timer:Class;
		public var timer:BitmapData = new Timer().bitmapData;
		
		[Embed(source="Textures/TimerSmall.png")]
		private var TimerSmall:Class;
		public var timerSmall:BitmapData = new TimerSmall().bitmapData;
		
		[Embed(source = "Textures/HomeBttn.png")]
		private var HomeBttn:Class;
		public var homeBttn:BitmapData = new HomeBttn().bitmapData;
		
		//[Embed(source="Textures/HomePanel.png")]
		//private var HomePanel:Class;
		//public var homePanel:BitmapData = new HomePanel().bitmapData;
		
		
		// Progress Bar
		
		[Embed(source = "Textures/ProgressBar.png")]
		private var ProgressBar:Class;
		public var progressBar:BitmapData = new ProgressBar().bitmapData;
		
		//[Embed(source="Textures/ProgressBarGrey.png")]
		//private var ProgressBarGrey:Class;
		//public var progressBarGrey:BitmapData = new ProgressBarGrey().bitmapData;
		
		[Embed(source = "Textures/ProgressBarLine.png")]
		private var ProgressBarLine:Class;
		public var progressBarLine:BitmapData = new ProgressBarLine().bitmapData;
		
		//[Embed(source = "Textures/ProgressBarGreen.png")]
		//private var ProgressBarGreen:Class;
		//public var progressBarGreen:BitmapData = new ProgressBarGreen().bitmapData;
		
		[Embed(source = "Textures/ProgressBarYellow.png")]
		private var ProgressBarYellow:Class;
		public var progressBarYellow:BitmapData = new ProgressBarYellow().bitmapData;
		
		[Embed(source="Textures/ProgressBarProduction.png")]
		private var ProgressBarProduction:Class;
		public var progressBarProduction:BitmapData = new ProgressBarProduction().bitmapData;
		
		[Embed(source = "Textures/ProgressBarAction.png")]
		private var ProgressBarAction:Class;
		public var progressBarAction:BitmapData = new ProgressBarAction().bitmapData;
		
		[Embed(source="Textures/ProgressBarActionLine.png")]
		private var ProgressBarActionLine:Class;
		public var progressBarActionLine:BitmapData = new ProgressBarActionLine().bitmapData;
		
		[Embed(source="Textures/ItemBackingPink.png")]
		private var ItemBackingPink:Class;
		public var itemBackingPink:BitmapData = new ItemBackingPink().bitmapData;
		
		[Embed(source="Textures/ItemBackingYellow.png")]
		private var ItemBackingYellow:Class;
		public var itemBackingYellow:BitmapData = new ItemBackingYellow().bitmapData;
		
		[Embed(source="Textures/ItemBackingBlue.png")]
		private var ItemBackingBlue:Class;
		public var itemBackingBlue:BitmapData = new ItemBackingBlue().bitmapData;
		
		[Embed(source="Textures/ItemBackingGreen.png")]
		private var ItemBackingGreen:Class;
		public var itemBackingGreen:BitmapData = new ItemBackingGreen().bitmapData;
		
		//[Embed(source="Textures/BrickTile.png")]
		//private var BrickTile:Class;
		//public var brickTile:BitmapData = new BrickTile().bitmapData;
		
		[Embed(source="Textures/GoalsChatsWoodcutter.png")]
		private var GoalsChatsWoodcutter:Class;
		public var goalsChatsWoodcutter:BitmapData = new GoalsChatsWoodcutter().bitmapData;
		
		[Embed(source="Textures/ForageIco.png")]
		private var ForageIco:Class;
		public var forageIco:BitmapData = new ForageIco().bitmapData;
		
		[Embed(source="Textures/GiftWinPic.png")]
		private var GiftWinPic:Class;
		public var giftWinPic:BitmapData = new GiftWinPic().bitmapData;
		
		[Embed(source="Textures/TravelPicDoor.png")]
		private var TravelPicDoor:Class;
		public var travelPicDoor:BitmapData = new TravelPicDoor().bitmapData;
		
		[Embed(source="Textures/GoalsChatsSailor.png")]
		private var GoalsChatsSailor:Class;
		public var goalsChatsSailor:BitmapData = new GoalsChatsSailor().bitmapData;
		
		//[Embed(source="Textures/InterQuestIcoSailor.png")]
		//private var InterQuestIcoSailor:Class;
		//public var interQuestIcoSailor:BitmapData = new InterQuestIcoSailor().bitmapData;
		
		[Embed(source="Textures/FoodIcoBoost.png")]
		private var FoodIcoBoost:Class;
		public var foodIcoBoost:BitmapData = new FoodIcoBoost().bitmapData;
		
		[Embed(source="Textures/FrancsIco.png")]
		private var FrancsIco:Class;
		public var francsIco:BitmapData = new FrancsIco().bitmapData;
		
		
		
		[Embed(source="Textures/CursorMenuBacking.png")]
		private var CursorMenuBacking:Class;
		public var cursorMenuBacking:BitmapData = new CursorMenuBacking().bitmapData;
		
		[Embed(source="Textures/Plus.png")]
		private var Plus:Class;
		public var plus:BitmapData = new Plus().bitmapData;
		
		[Embed(source="Textures/Equals.png")]
		private var Equals:Class;
		public var equals:BitmapData = new Equals().bitmapData;
		
		[Embed(source="Textures/GiftBttn.png")]
		private var GiftBttn:Class;
		public var giftBttn:BitmapData = new GiftBttn().bitmapData;
		
		[Embed(source="Textures/GoalsChatsTommy.png")]
		private var GoalsChatsTommy:Class;
		public var goalsChatsTommy:BitmapData = new GoalsChatsTommy().bitmapData;
		
		[Embed(source = "Textures/Bttn.png")]
		private var Bttn:Class;
		public var bttn:BitmapData = new Bttn().bitmapData;
		
		
		/*[Embed(source = "Textures/QuestHeaderTop.png")]
		private var QuestHeaderTop:Class;
		public var questHeaderTop:BitmapData = new QuestHeaderTop().bitmapData;*/
		
		[Embed(source = "Textures/QuestHeaderBottom.png")]
		private var QuestHeaderBottom:Class;
		public var questHeaderBottom:BitmapData = new QuestHeaderBottom().bitmapData;
		
		
		//[Embed(source="Textures/PresentDecor.png")]
		//private var PresentDecor:Class;
		//public var presentDecor:BitmapData = new PresentDecor().bitmapData;
		
		[Embed(source = "Textures/StageLine.png")]
		private var StageLine:Class;
		public var stageLine:BitmapData = new StageLine().bitmapData;
		
		[Embed(source ="Textures/StageEmpty.png")]
		private var StageEmpty:Class;
		public var stageEmpty:BitmapData = new StageEmpty().bitmapData;
		
		//[Embed(source="Textures/StageComplete.png")]
		//private var StageComplete:Class;
		//public var stageComplete:BitmapData = new StageComplete().bitmapData;
		
		/*[Embed(source="Textures/ArrowMain.png")]
		private var ArrowMain:Class;
		public var arrowMain:BitmapData = new ArrowMain().bitmapData;*/
		
		[Embed(source="Textures/QuestDailyIco.png")]
		private var QuestDailyIco:Class;
		public var questDailyIco:BitmapData = new QuestDailyIco().bitmapData;
		
		[Embed(source ="Textures/StagesEmptySlot.png")]
		private var StagesEmptySlot:Class;
		public var stagesEmptySlot:BitmapData = new StagesEmptySlot().bitmapData;
		
		[Embed(source="Textures/StagesCompleteSlot.png")]
		private var StagesCompleteSlot:Class;
		public var stagesCompleteSlot:BitmapData = new StagesCompleteSlot().bitmapData;
		
		[Embed(source="Textures/IndianBacking.png")]
		private var IndianBacking:Class;
		public var indianBacking:BitmapData = new IndianBacking().bitmapData;
		
		[Embed(source="Textures/DailyBacking.png")]
		private var DailyBacking:Class;
		public var dailyBacking:BitmapData = new DailyBacking().bitmapData;
		
		[Embed(source="Textures/DecWeb.png")]
		private var DecWeb:Class;
		public var decWeb:BitmapData = new DecWeb().bitmapData;
		
		[Embed(source="Textures/HelloweenMoneyIco.png")]
		private var HelloweenMoneyIco:Class;
		public var helloweenMoneyIco:BitmapData = new HelloweenMoneyIco().bitmapData;
		
		[Embed(source="Textures/InterSearchBttn.png")]
		private var InterSearchBttn:Class;
		public var interSearchBttn:BitmapData = new InterSearchBttn().bitmapData;
		
		[Embed(source="Textures/SearchPanelBacking.png")]
		private var SearchPanelBacking:Class;
		public var searchPanelBacking:BitmapData = new SearchPanelBacking().bitmapData;
		
		[Embed(source="Textures/QuestManagerBacking.png")]
		private var QuestManagerBacking:Class;
		public var questManagerBacking:BitmapData = new QuestManagerBacking().bitmapData;
		
		[Embed(source="Textures/GreenBttn.png")]
		private var GreenBttn:Class;
		public var greenBttn:BitmapData = new GreenBttn().bitmapData;
		
		[Embed(source="Textures/HomePanelBacking.png")]
		private var HomePanelBacking:Class;
		public var homePanelBacking:BitmapData = new HomePanelBacking().bitmapData;
		
		[Embed(source="Textures/WinterBacking.png")]
		private var WinterBacking:Class;
		public var winterBacking:BitmapData = new WinterBacking().bitmapData;
		
		[Embed(source="Textures/WinterDec.png")]
		private var WinterDec:Class;
		public var winterDec:BitmapData = new WinterDec().bitmapData;
		
		[Embed(source="Textures/InterHelpBttn.png")]
		private var InterHelpBttn:Class;
		public var interHelpBttn:BitmapData = new InterHelpBttn().bitmapData;
		
		[Embed(source="Textures/RouletteDec.png")]
		private var RouletteDec:Class;
		public var rouletteDec:BitmapData = new RouletteDec().bitmapData;
		
		[Embed(source="Textures/RouletteGiftButton.png")]
		private var RouletteGiftButton:Class;
		public var rouletteGiftButton:BitmapData = new RouletteGiftButton().bitmapData;
		
		[Embed(source="Textures/RouletteGiftIco.png")]
		private var RouletteGiftIco:Class;
		public var rouletteGiftIco:BitmapData = new RouletteGiftIco().bitmapData;
		
		[Embed(source="Textures/WoodPaperBacking.png")]
		private var WoodPaperBacking:Class;
		public var woodPaperBacking:BitmapData = new WoodPaperBacking().bitmapData;
		
		[Embed(source="Textures/RouletteIco.png")]
		private var RouletteIco:Class;
		public var rouletteIco:BitmapData = new RouletteIco().bitmapData;
		
		[Embed(source="Textures/QuestionMark.png")]
		private var QuestionMark:Class;
		public var questionMark:BitmapData = new QuestionMark().bitmapData;
		
		[Embed(source="Textures/GoalsChatsShepherd.png")]
		private var GoalsChatsShepherd:Class;
		public var goalsChatsShepherd:BitmapData = new GoalsChatsShepherd().bitmapData;
		
		[Embed(source="Textures/GoalsChatsLadyPink.png")]
		private var GoalsChatsLadyPink:Class;
		public var goalsChatsLadyPink:BitmapData = new GoalsChatsLadyPink().bitmapData;
		
		[Embed(source="Textures/GoalsChatsNewBoy.png")]
		private var GoalsChatsNewBoy:Class;
		public var goalsChatsNewBoy:BitmapData = new GoalsChatsNewBoy().bitmapData;
		
		[Embed(source="Textures/SaleRibbon.png")]
		private var SaleRibbon:Class;
		public var saleRibbon:BitmapData = new SaleRibbon().bitmapData;
		
		[Embed(source="Textures/WoodPaperBackingDark.png")]
		private var WoodPaperBackingDark:Class;
		public var woodPaperBackingDark:BitmapData = new WoodPaperBackingDark().bitmapData;
		
		[Embed(source="Textures/RouletteDecGold.png")]
		private var RouletteDecGold:Class;
		public var rouletteDecGold:BitmapData = new RouletteDecGold().bitmapData;
		
		[Embed(source="Textures/RouletteBackingTop.png")]
		private var RouletteBackingTop:Class;
		public var rouletteBackingTop:BitmapData = new RouletteBackingTop().bitmapData;
		
		[Embed(source="Textures/RouletteBackingBot.png")]
		private var RouletteBackingBot:Class;
		public var rouletteBackingBot:BitmapData = new RouletteBackingBot().bitmapData;
		
		[Embed(source="Textures/RouletteGoldDecCentre.png")]
		private var RouletteGoldDecCentre:Class;
		public var rouletteGoldDecCentre:BitmapData = new RouletteGoldDecCentre().bitmapData;
		
		[Embed(source="Textures/RouletteTreeDecBase.png")]
		private var RouletteTreeDecBase:Class;
		public var rouletteTreeDecBase:BitmapData = new RouletteTreeDecBase().bitmapData;
		
		[Embed(source="Textures/RouletteTreeDecCentre.png")]
		private var RouletteTreeDecCentre:Class;
		public var rouletteTreeDecCentre:BitmapData = new RouletteTreeDecCentre().bitmapData;
		
		[Embed(source="Textures/RouletteTreeDecUp.png")]
		private var RouletteTreeDecUp:Class;
		public var rouletteTreeDecUp:BitmapData = new RouletteTreeDecUp().bitmapData;
		
		[Embed(source="Textures/RouletteCenterBacking.png")]
		private var RouletteCenterBacking:Class;
		public var rouletteCenterBacking:BitmapData = new RouletteCenterBacking().bitmapData;
		
		[Embed(source="Textures/GiftBoxPicRoulette1.png")]
		private var GiftBoxPicRoulette1:Class;
		public var giftBoxPicRoulette1:BitmapData = new GiftBoxPicRoulette1().bitmapData;
		
		[Embed(source="Textures/GiftBoxPicRoulette2.png")]
		private var GiftBoxPicRoulette2:Class;
		public var giftBoxPicRoulette2:BitmapData = new GiftBoxPicRoulette2().bitmapData;
		
		[Embed(source="Textures/GiftBoxPicRoulette3.png")]
		private var GiftBoxPicRoulette3:Class;
		public var giftBoxPicRoulette3:BitmapData = new GiftBoxPicRoulette3().bitmapData;
		
		[Embed(source="Textures/OpenBoxPicRoulette1.png")]
		private var OpenBoxPicRoulette1:Class;
		public var openBoxPicRoulette1:BitmapData = new OpenBoxPicRoulette1().bitmapData;
		
		[Embed(source="Textures/OpenBoxPicRoulette2.png")]
		private var OpenBoxPicRoulette2:Class;
		public var openBoxPicRoulette2:BitmapData = new OpenBoxPicRoulette2().bitmapData;
		
		[Embed(source="Textures/OpenBoxPicRoulette3.png")]
		private var OpenBoxPicRoulette3:Class;
		public var openBoxPicRoulette3:BitmapData = new OpenBoxPicRoulette3().bitmapData;
		
		[Embed(source="Textures/SaleMinusFiftyPercentRibbon.png")]
		private var SaleMinusFiftyPercentRibbon:Class;
		public var saleMinusFiftyPercentRibbon:BitmapData = new SaleMinusFiftyPercentRibbon().bitmapData;
		
		[Embed(source="Textures/BonusLabelBlue.png")]
		private var BonusLabelBlue:Class;
		public var bonusLabelBlue:BitmapData = new BonusLabelBlue().bitmapData;
		
		[Embed(source="Textures/PatricCoinIco.png")]
		private var PatricCoinIco:Class;
		public var patricCoinIco:BitmapData = new PatricCoinIco().bitmapData;
		
		[Embed(source="Textures/ShopBackingBotGreen.png")]
		private var ShopBackingBotGreen:Class;
		public var shopBackingBotGreen:BitmapData = new ShopBackingBotGreen().bitmapData;
		
		[Embed(source="Textures/ShopBackingTopGreen.png")]
		private var ShopBackingTopGreen:Class;
		public var shopBackingTopGreen:BitmapData = new ShopBackingTopGreen().bitmapData;
		
		[Embed(source="Textures/SaintPatrickDecor.png")]
		private var SaintPatrickDecor:Class;
		public var saintPatrickDecor:BitmapData = new SaintPatrickDecor().bitmapData;
		
		[Embed(source="Textures/SaintPatrickDecorVertical.png")]
		private var SaintPatrickDecorVertical:Class;
		public var saintPatrickDecorVertical:BitmapData = new SaintPatrickDecorVertical().bitmapData;
		
		[Embed(source="Textures/InterHomeBttnBronze.png")]
		private var InterHomeBttnBronze:Class;
		public var interHomeBttnBronze:BitmapData = new InterHomeBttnBronze().bitmapData;
		
		[Embed(source="Textures/InterHomeBttnGray.png")]
		private var InterHomeBttnGray:Class;
		public var interHomeBttnGray:BitmapData = new InterHomeBttnGray().bitmapData;
		
		[Embed(source="Textures/SmileIco.png")]
		private var SmileIco:Class;
		public var smileIco:BitmapData = new SmileIco().bitmapData;
		
		//Freebie		
		[Embed(source="Textures/Freebie/NewFribyGiftPic1.png")]
		private var NewFribyGiftPic1:Class;
		public var newFribyGiftPic1:BitmapData = new NewFribyGiftPic1().bitmapData;
		
		[Embed(source="Textures/Freebie/NewFribyGiftPic2.png")]
		private var NewFribyGiftPic2:Class;
		public var newFribyGiftPic2:BitmapData = new NewFribyGiftPic2().bitmapData;
		
		[Embed(source="Textures/Freebie/NewFribyGiftPic3.png")]
		private var NewFribyGiftPic3:Class;
		public var newFribyGiftPic3:BitmapData = new NewFribyGiftPic3().bitmapData;
		
		[Embed(source="Textures/Freebie/NewFribyGiftPic4.png")]
		private var NewFribyGiftPic4:Class;
		public var newFribyGiftPic4:BitmapData = new NewFribyGiftPic4().bitmapData;
		
		[Embed(source="Textures/SweetMedalIco.png")]
		private var SweetMedalIco:Class;
		public var sweetMedalIco:BitmapData = new SweetMedalIco().bitmapData;
		
		[Embed(source="Textures/IventShopBackingChocolateDown.png")]
		private var IventShopBackingChocolateDown:Class;
		public var iventShopBackingChocolateDown:BitmapData = new IventShopBackingChocolateDown().bitmapData;
		
		[Embed(source="Textures/IventShopBackingChocolateUP.png")]
		private var IventShopBackingChocolateUP:Class;
		public var iventShopBackingChocolateUP:BitmapData = new IventShopBackingChocolateUP().bitmapData;
		
		[Embed(source="Textures/TravBalanceArrow.png")]
		private var TravBalanceArrow:Class;
		public var travBalanceArrow:BitmapData = new TravBalanceArrow().bitmapData;
		
		[Embed(source="Textures/ExpBackingBot.png")]
		private var ExpBackingBot:Class;
		public var expBackingBot:BitmapData = new ExpBackingBot().bitmapData;
		
		[Embed(source="Textures/ExpBackingTop.png")]
		private var ExpBackingTop:Class;
		public var expBackingTop:BitmapData = new ExpBackingTop().bitmapData;
		
		[Embed(source="Textures/BowRibbonPic.png")]
		private var BowRibbonPic:Class;
		public var bowRibbonPic:BitmapData = new BowRibbonPic().bitmapData;
		
		[Embed(source="Textures/WoodenChest.png")]
		private var WoodenChest:Class;
		public var woodenChest:BitmapData = new WoodenChest().bitmapData;
		
		[Embed(source="Textures/GoldBacking.png")]
		private var GoldBacking:Class;
		public var goldBacking:BitmapData = new GoldBacking().bitmapData;
		
		[Embed(source="Textures/GoldTitleDec.png")]
		private var GoldTitleDec:Class;
		public var goldTitleDec:BitmapData = new GoldTitleDec().bitmapData;
		
		[Embed(source="Textures/BottomBacking2.png")]
		private var BottomBacking2:Class;
		public var bottomBacking2:BitmapData = new BottomBacking2().bitmapData;
		
		[Embed(source="Textures/GoldTitleDec2.png")]
		private var GoldTitleDec2:Class;
		public var goldTitleDec2:BitmapData = new GoldTitleDec2().bitmapData;
		
		[Embed(source="Textures/TopBacking.png")]
		private var TopBacking:Class;
		public var topBacking:BitmapData = new TopBacking().bitmapData;
		
		[Embed(source="Textures/BottomBacking1.png")]
		private var BottomBacking1:Class;
		public var bottomBacking1:BitmapData = new BottomBacking1().bitmapData;
		
		[Embed(source="Textures/BottomBacking3.png")]
		private var BottomBacking3:Class;
		public var bottomBacking3:BitmapData = new BottomBacking3().bitmapData;
		
		[Embed(source="Textures/GoldBackingTop.png")]
		private var GoldBackingTop:Class;
		public var goldBackingTop:BitmapData = new GoldBackingTop().bitmapData;
		
		[Embed(source="Textures/Platinum.png")]
		private var Platinum:Class;
		public var platinum:BitmapData = new Platinum().bitmapData;
		
		[Embed(source="Textures/GemsIco.png")]
		private var GemsIco:Class;
		public var gemsIco:BitmapData = new GemsIco().bitmapData;
		
		[Embed(source="Textures/HalloweenBacking.png")]
		private var HalloweenBacking:Class;
		public var halloweenBacking:BitmapData = new HalloweenBacking().bitmapData;
		
		[Embed(source="Textures/DecPumpkin.png")]
		private var DecPumpkin:Class;
		public var decPumpkin:BitmapData = new DecPumpkin().bitmapData;
		
		[Embed(source="Textures/HalloweenTopBacking.png")]
		private var HalloweenTopBacking:Class;
		public var halloweenTopBacking:BitmapData = new HalloweenTopBacking().bitmapData;
		
		[Embed(source="Textures/PetEnergyIcon.png")]
		private var PetEnergyIcon:Class;
		public var petEnergyIcon:BitmapData = new PetEnergyIcon().bitmapData;
		
		//fog
		[Embed(source="Textures/Fog/f1.png")]
		private var F1:Class;
		public var f1:BitmapData = new F1().bitmapData;
		
		[Embed(source="Textures/Fog/f2.png")]
		private var F2:Class;
		public var f2:BitmapData = new F2().bitmapData;
		
		[Embed(source="Textures/Fog/f3.png")]
		private var F3:Class;
		public var f3:BitmapData = new F3().bitmapData;
		
		[Embed(source="Textures/Fog/f4.png")]
		private var F4:Class;
		public var f4:BitmapData = new F4().bitmapData;
		
		public function Windows():void
		{
			
		}
	}
}