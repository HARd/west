package wins
{
	import flash.events.Event;
	
	public class WindowEvent extends Event
	{
		public static const ON_BEFORE_OPEN:String 			= "onBeforeOpen";
		public static const ON_AFTER_OPEN:String 			= "onAfterOpen";
		public static const ON_BEFORE_CLOSE:String 			= "onBeforeClose";
		public static const ON_AFTER_CLOSE:String 			= "onAfterClose";
		public static const ON_BEFORE_CONTENT_CHANGE:String = "onBeforeContentChange";
		public static const ON_AFTER_CONTENT_CHANGE:String 	= "onAfterContentChange";
		
		public static const ON_CONTENT_REQUEST:String 		= "onContentRequest";
		public static const ON_PAGE_CHANGE:String 			= "onPageChange";
		public static const ON_CONTENT_UPDATE:String 		= "onContentUpdate";
		
		public static const ON_CONFIRM:String 		= "onConfirm";
		public static const ON_CANCEL:String 		= "onCancel";
		public static const ON_OK:String 			= "onOk";
		
		public static const ON_HUT_UPDATE:String 	= "onHutUpdate";
		public static const ON_PROGRESS:String 		= "onProgress";
		
		public var customMessage:String = "";
		
		public function WindowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			super(type, bubbles, cancelable);
		}
	}
}