package buttons 
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import wins.Window;
	
	public class CheckboxButton extends Button
	{
		public static var countOpens:int = 0;
		
		public static const CHECKED:int = 1;
		public static const UNCHECKED:int = 2;
		
		public var checkedBg:Bitmap;
		public var uncheckedBg:Bitmap;
		

		public function CheckboxButton(settings:Object = null) 
		{
			var defaults:Object = {
				fontSize:17,
				fontSizeUnceked:17,
				fontColor:0x885127,
				fontBorderColor:0x96bedb,
				textFieldWidth:200,
				
				captionChecked:Locale.__e('flash:1396608121799'),
				captionUnchecked:Locale.__e('flash:1396608121799')
			}
			
			if (settings == null) {
				settings = new Object();
			}
			
			for (var property:* in settings) {
				defaults[property] = settings[property];
			}
			
			if (countOpens > 1) {
				countOpens = 0;
				User.checkBoxState = CHECKED;
			}
			
			countOpens++;
			
			defaults['checked'] = settings.checked || User.checkBoxState;
			
			if ((App.user.level < 5 || App.user.quests.tutorial) && defaults.checked == 1)
				defaults.checked = 2;
			
			settings = defaults;
			defaults = null;
			
			super(settings);
			//textLabel.y = 6;
			textLabel.y = uncheckedBg.y + uncheckedBg.height / 2 - textLabel.height / 2;
			
			textLabel.filters = null;
			//textLabel.visible = false;
			addEventListener(MouseEvent.CLICK, onStatusChange);
		}
		
		override public function dispose():void {
			removeEventListener(MouseEvent.CLICK, onStatusChange);
			
			super.dispose();
		}
		
		public function freeze():void {
			removeEventListener(MouseEvent.CLICK, onStatusChange);
		}
		
		override protected function drawBottomLayer():void{
			
			
			checkedBg = new Bitmap(Window.textures.checkboxWMark);
			
			checkedBg.x = -2;
			uncheckedBg = new Bitmap(Window.textures.checkboxEmpty);
			uncheckedBg.x = -2;
			uncheckedBg.y = 6;
			
			if (settings.checked == CheckboxButton.CHECKED) {
				uncheckedBg.visible = false;
				checkedBg.visible = true;
			}else {
				uncheckedBg.visible = true;
				checkedBg.visible = false;
			}
			
			bottomLayer.addChild(checkedBg);
			bottomLayer.addChild(uncheckedBg);
			
			addChild(bottomLayer);
		}
		
		public function set checked(status:int):void {
			if (status == CheckboxButton.CHECKED) {
				uncheckedBg.visible = false;
				checkedBg.visible = true;
				
				textLabel.text = settings.captionChecked;
				style.size = settings.fontSize;
				//textLabel.y = 6;
				textLabel.x = 20;
			}else {
				uncheckedBg.visible = true;
				checkedBg.visible = false;
				
				textLabel.text = settings.captionUnchecked;
				style.size = settings.fontSizeUnceked;
				//textLabel.y = 6;
				textLabel.x = 20;
			}
			settings.checked = status;
			
			textLabel.setTextFormat(style);
			textLabel.y = uncheckedBg.y + uncheckedBg.height / 2 - textLabel.height / 2;
		}
		
		public function get checked():int {
			return int(settings.checked);
		}
		
		
		override protected function drawTopLayer():void {
			super.drawTopLayer();
			
			style.leading = -2;
			
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			textLabel.multiline = true;
			textLabel.wordWrap = true;
			textLabel.width = settings.textFieldWidth;
			textLabel.x = 16;
			
			
			
			this.checked = settings.checked;
			
			textLabel.setTextFormat(style);	
		}
		
		public function onStatusChange(e:MouseEvent):void {
			if (mode == Button.DISABLED) {
				return;
			}
			
			if (this.checked == CheckboxButton.CHECKED) {
				this.checked = CheckboxButton.UNCHECKED;
				User.checkBoxState = CheckboxButton.UNCHECKED;
			}else {
				this.checked = CheckboxButton.CHECKED;
				User.checkBoxState = CheckboxButton.CHECKED;
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		override protected function MouseOver(e:MouseEvent):void {
			if(mode == Button.NORMAL){
				effect(0.1);
			}
		}
		
		override protected function MouseOut(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0);
			}
		}
		
		override protected function MouseDown(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect( -0.1);
				SoundsManager.instance.playSFX(settings.sound);	
				if(onMouseDown != null){
					onMouseDown(e);
				}					
			}
		}
		
		override protected function MouseUp(e:MouseEvent):void {			
			if(mode == Button.NORMAL){
				effect(0.1);
				if(onMouseUp != null){
					onMouseUp(e);
				}
			}
		}
	}

}