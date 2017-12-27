package
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		public static const ON_USER_COMPLETE:String 		= "onUserComplete";
		public static const ON_OWNER_COMPLETE:String 		= "onOwnerComplete";
		public static const ON_MAP_COMPLETE:String 			= "onMapComplete";
		public static const ON_GAME_COMPLETE:String 		= "onGameComplete";
		public static const ON_NETWORK_COMPLETE:String 		= "onNetworkComplete";
		public static const AFTER_BUY:String 				= "onAfterBuy";
		public static const ON_MOUSE_UP:String 				= "onMouseUp";
		public static const ON_MOUSE_DOWN:String 			= "onMouseDown";
		public static const ON_LEVEL_UP:String 				= "onLevelUp";
		public static const ON_FINISH:String 				= "onFinish";
		public static const ON_UI_LOAD:String 				= "onUILoad";
		public static const ON_AFTER_PACK:String 			= "onAfterPack";
		public static const ON_QUEST_WINDOW_OPEN:String 	= "onQuestWindowOpen";
		public static const ON_START_TUTORIAL:String 		= "onStartTutorial";
		public static const ON_FINISH_TUTORIAL:String 		= "onFinishTutorial";
		public static const ON_INTRO_FINISH:String 			= "onIntroFinish";
		public static const ON_UNIT_CHANGE_POSITION:String	= 'onUnitChangePosition';
		public static const ON_RESIZE:String				= 'onResize';
		public static const ON_STOCK_ACTION:String 			= "onStockAction";
		
		public static const ON_UI_ANIMATION:String			= 'onUIAnimation';
		
		public static const ON_SOUND_LOAD:String 			= "onSoundLoad";
		public static const ON_CHANGE_EFIR:String 			= "onChangeEfir";
		
		public static const ON_MAP_CLICK:String 			= "onMapClick";
		public static const ON_MAP_TOUCH:String 			= "onMapTouch";
		public static const ON_CHANGE_STOCK:String 			= "onChangeStock";
		
		public static const ON_CHANGE_FANTASY:String 		= "onChangeFantasy";
		
		
		public static const ON_TRADE_FLY_BACK:String 		= "onTradeFlyBack";
		
		public static const ON_CLOSE_INFO:String 			= "onCloseInfo";
		public static const ON_CLOSE_INFO_TRES:String 		= "onCloseInfoTres";
		public static const ON_TECHNO_CHANGE:String 		= "onTechnoChange";
		
		public static const ON_CLOSE_BANK:String 			= "onCloseBank";
		
		public static const ON_STOP_MOVE:String 			= "onStopMove";
		
		public static const ON_WHEEL_MOVE:String 			= "onWheelMove";
		public static const ON_QUEUE_COMPLETE:String		= 'onQueueComplete';
		public static const FEED_COMPLETE:String			= 'feedComplete';
		public static const ON_DELETE_FAKE_HUT:String		= 'hutDelete';
		public static const ON_CHANGE_GUEST_FANTASY:String	= 'onChangeGuestFantasy';
		public static const TAKE_FANTS:String				= 'onTakeFants';
		
		
		
		public var params:Object;
		public var customMessage:String = "";
		
		public function AppEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, params:Object = null):void
		{
			super(type, bubbles, cancelable);
			
			this.params = params;
		}
	}
}