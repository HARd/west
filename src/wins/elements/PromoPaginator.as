import buttons.ImageButton;
import core.Debug;
import flash.display.Sprite;
import flash.events.MouseEvent;
import wins.Window;
import wins.WindowEvent;
import ui.UserInterface;
import ui.QuestIcon;
import ui.SalesPanel;

internal class PromoPaginator extends Sprite{
	
	public var startItem:uint = 0;
	public var endItem:uint = 0;
	public var length:uint = 0;
	public var itemsOnPage:uint = 0;
	
	public var _parent:SalesPanel;
	public var data:Array;
	
	public function PromoPaginator(data:Array, itemsOnPage:uint, _parent:SalesPanel) {
		
		this._parent = _parent;
		this.data = data;
		length = data.length;
		startItem = 0;
		this.itemsOnPage = itemsOnPage;
		endItem = startItem + itemsOnPage;
		trace();
	}
	
	public function up(e:* = null):void {
		if (startItem > 0) {
			startItem -= 2;
			endItem = startItem + itemsOnPage;
			
			_parent.updateSales();
			change();
		}
	}
	
	public function down(e:* = null):void {
		startItem += 2;
		endItem = startItem + itemsOnPage;
		
		_parent.updateSales();
		change();
	}
	
	public function change(isLevelUp:Boolean = false):void {
		
		length = App.user.promos.length;
		
		if (startItem == 0){
			arrowUp.visible = false;
		}else{
			arrowUp.visible = true;
		}	
		
		if(startItem + itemsOnPage >= length)
			arrowDown.visible = false;
		else
			arrowDown.visible = true;
		
		_parent.doCreate(isLevelUp);
	}
	
	public var arrowUp:ImageButton;
	public var arrowDown:ImageButton;
	
	public function drawArrows():void
	{
		if (arrowUp == null && arrowDown == null)
		{
			arrowUp = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:1, sound:'arrow_bttn'});
			arrowDown = new ImageButton(Window.textures.arrowUp, {scaleX:1, scaleY:-1, sound:'arrow_bttn'});
			
			_parent.promoPanel.addChild(arrowUp);
			arrowUp.x = 22;
			
			_parent.promoPanel.addChild(arrowDown);
			arrowDown.x = 22;
			
			arrowUp.addEventListener(MouseEvent.CLICK, up);
			arrowDown.addEventListener(MouseEvent.CLICK, down);
		}
		
		setArrowsPosition();
	}
	
	public function resize(_height:uint, isLevelUp:Boolean = false):void {
		itemsOnPage = Math.floor(_height / 90);
		startItem = 0;
		endItem = startItem + itemsOnPage;
		endItem
		setArrowsPosition();
		change(isLevelUp);
	}
	
	public function setArrowsPosition():void {
		
		arrowUp.y 	= _parent.iconsPosY - arrowUp.height - 10;
		arrowDown.y = _parent.iconsPosY + _parent.iconsHeight;//164;
	}
}