package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import buttons.CheckboxButton;
	import buttons.MenuButton;
	import buttons.MoneyButton;
	import com.flashdynamix.motion.extras.TextPress;
	import core.Debug;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	public class InvitesWindow extends Window 
	{
		public static const NEIGHBORS:uint = 0;
		public static const REQUESTS:uint = 1;
		public static const SEARCH:uint = 2;
		
		public static var chooseRandom:Array = [];
		
		private var back:Bitmap;
		private var menuContainer:Sprite;
		private var swContainer:Sprite;
		public var descText:TextField;
		public var searchFriend:SearchFriend;
		public var shareInfo:ShareInfo;
		private var checkBox:CheckboxButton;
		
		public function InvitesWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			settings["title"] = Locale.__e("flash:1416400472057");
			settings["width"] = 720;
			settings["height"] = 570+20;
			settings["hasPaginator"] = true;
			settings["background"] = 'alertBacking';
			settings["subwindow"] = InvitesWindow.SEARCH;
			
			super(settings);
			//maker();
			//App.invites; App.user.friends.data
		}
		
		public function set state(value:uint):void {
			settings.subwindow = value;
		}
		public function get state():uint {
			return settings.subwindow;
		}
		
		/*override public function drawBackground():void {
			var background:Bitmap = backing(settings.width + 50, settings.height + 50, 50, "alertBacking");
			layer.addChild(background);
		}*/
		
		override public function drawBody():void 
		{
			exit.x -= 10;
			exit.y -= 6;
			
			titleLabel.y += 15;
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 10, settings.width / 2 + settings.titleWidth / 2 + 10, -50, true, true);
			//drawMirrowObjs('diamonds', 22, settings.width - 21, settings.height - 120);
			//drawMirrowObjs('diamonds', 22, settings.width - 22, 40, false, false, false, 1, -1);
			
			var decor:Bitmap = new Bitmap(Window.textures.dividerLine);
			decor.alpha = 0.8;
			decor.width = settings.width - 200;
			decor.x = (settings.width - decor.width) / 2;
			decor.y = 65;
			bodyContainer.addChild(decor);
			
			drawBttns();
			drawDescription();
			
			swContainer = new Sprite();
			bodyContainer.addChild(swContainer);
			
			checkBox = new CheckboxButton( {
				captionChecked:Locale.__e('flash:1444318416215'),
				captionUnchecked:Locale.__e('flash:1444318416215'),
				textFieldWidth:280,
				checked:int(2 - App.user.hidden)
			});
			checkBox.x = 83;
			checkBox.y = settings.height - 107;
			bodyContainer.addChild(checkBox);
			checkBox.addEventListener(Event.CHANGE, onCheckBoxChange);
			
			makeSubWindow(settings.subwindow);
		}
		
		override public function drawArrows():void {
			super.drawArrows();
			
			paginator.arrowLeft.x -= 25;
			paginator.arrowRight.x += 25;
			paginator.arrowLeft.y += 8;
			paginator.arrowRight.y += 8;
			
			paginator.x -= 30;
			paginator.y += 19;
			
			if (!paginator.visible) {
				paginator.arrowLeft.visible = paginator.visible;
				paginator.arrowRight.visible = paginator.visible;
			}
		}
		
		public function makeSubWindow(subwindow:uint):void {
			clear();
			
			switch(subwindow) {
				case SEARCH:
					drawSearch();
					break;
				case REQUESTS:
					drawRequests();
					break;
				case NEIGHBORS:
					drawNeighbors();
					break;
				default:
					drawSearch();
			}
		}
		
		private function clear():void {
			clearContent();
			while (swContainer.numChildren > 0) {
				var child:* = swContainer.getChildAt(0);
				if (child.hasOwnProperty('dispose') && child.dispose != null && ((child is Button) || (child is FriendItem))) {
					child.dispose();
				}
				if (swContainer.contains(child)) {
					swContainer.removeChild(child);
				}
			}
		}
		
		private var bttns:Object = {
			0:{label:'flash:1382952380191', name:0, description:'flash:1444318512198'},
			1:{label:'flash:1382952380190', name:1, description:'flash:1444318361279'},
			2:{label:'flash:1382952380073', name:2, description:'flash:1444318116863'}
		};
		private const MENU_BTTN_MARGIN:int = 12;
		private function drawBttns():void {
			menuContainer = new Sprite();
			menuContainer.y = 6;
			bodyContainer.addChild(menuContainer);
			
			var count:int = 0;
			for (var s:String in bttns) {
				
				var bttn:MenuButton = new MenuButton( {
					width:		120,
					height:		40,
					title:		Locale.__e(bttns[s].label),
					fontSize:	22
				});
				bttn.name = bttns[s].name;
				bttn.x = bttn.width * count + MENU_BTTN_MARGIN * count;
				bttn.y = 10;
				bttn.addEventListener(MouseEvent.CLICK, onMenuClick);
				menuContainer.addChild(bttn);
				count++;
			}
			
			updateBttn();
		}
		
		private function updateBttn():void {
			for (var i:int = 0; i < menuContainer.numChildren; i++) {
				var bttn:* = menuContainer.getChildAt(i);
				if (int(bttn.name) == state) {
					bttn.state = Button.ACTIVE;
				}else {
					bttn.state = Button.NORMAL;
				}
			}
			
			menuContainer.x = (settings.width - menuContainer.width) / 2;
		}
		private function onMenuClick(e:MouseEvent):void {
			var id:int = int(e.currentTarget.name);
			if ([NEIGHBORS, REQUESTS, SEARCH].indexOf(id) >= 0) {
				state = id;
				makeSubWindow(id);
			}
			updateBttn();
			//App.invites.init(function():void {})
		}
		private function drawDescription():void {
			descText = drawText('', {
				multiline:		true,
				fontSize:		24,
				color:			0x773c18,
				borderColor:	0xfbf1d9,
				textAlign:		'center',
				autoSize:		'center'
			});
			descText.width = settings.width - 120;
			descText.wordWrap = true;
			bodyContainer.addChild(descText);
			descText.x = (settings.width - descText.width) / 2;
			descText.y = 74;
		}
		
		// Body's
		private function drawSearch():void {
			back = backing(settings.width - 120, 200, 50, 'dialogueBacking');
			back.x = (settings.width - back.width) / 2;
			back.y = 110;
			swContainer.addChild(back);
			
			// Search
			searchFriend = new SearchFriend( { window:this } );
			searchFriend.x = 30;
			searchFriend.y = back.y + back.height + 20;
			swContainer.addChild(searchFriend);
			
			// Share
			shareInfo = new ShareInfo();
			shareInfo.x = searchFriend.x + 388;
			shareInfo.y = searchFriend.y - 15;
			swContainer.addChild(shareInfo);
			
			if (App.invites.random.length > 0) {
				if (chooseRandom.length == 0) {
					while (true) {
						var index:int = Math.floor((Math.random()) * App.invites.random.length);
						var random:Object = App.invites.random[index];
						for (var j:int = 0; j < chooseRandom.length; j++) {
							if (chooseRandom[j]['_id'] == random['_id']) {
								random = null;
								break;
							}
						}
						if (random) chooseRandom.push(random);
						if (chooseRandom.length >= 4 || chooseRandom.length == App.invites.random.length) {
							break;
						}
					}
				}
				
				for (var i:int = 0; i < chooseRandom.length; i++) {
					var item:FriendItem = new FriendItem( {
						width:		ITEMS_WIDTH,
						height:		170,
						type:		FriendItem.ADD,
						info:		chooseRandom[i]
					});
					item.x = back.x + 14 + (ITEMS_WIDTH + 4) * i;
					item.y = back.y + 14;
					swContainer.addChild(item);
				}
			}
			
			checkBox.visible = false;
			paginator.hide();
			
			descText.text = Locale.__e(bttns[state].description);
		}
		private function drawRequests():void {
			back = backing(settings.width - 120, 370, 50, 'dialogueBacking');
			back.x = (settings.width - back.width) / 2;
			back.y = 110;
			swContainer.addChild(back);
			
			descText.text = Locale.__e(bttns[state].description);
			
			checkBox.visible = true;
			
			updateRequests();
		}
		public function updateRequests(resetPage:Boolean = true):void {
			initContent();
			
			if (!paginator.visible) {
				paginator.visible = true;
				paginator.arrowRight.visible = true;
				paginator.arrowLeft.visible = true;
			}
			
			paginator.onPageCount = 8;
			paginator.itemsCount = content.length;
			paginator.page = (!resetPage) ? paginator.page : 0;
			paginator.update();
			
			contentChange();
		}
		private function drawNeighbors():void {
			back = backing(settings.width - 120, 370, 50, 'dialogueBacking');
			back.x = (settings.width - back.width) / 2;
			back.y = 110;
			swContainer.addChild(back);
			
			descText.text = Locale.__e(bttns[state].description);
			
			updateNeighbors();
		}
		public function updateNeighbors(resetPage:Boolean = true):void {
			alwaysFriendContent();
			
			if (!paginator.visible) {
				paginator.visible = true;
				paginator.arrowRight.visible = true;
				paginator.arrowLeft.visible = true;
			}
			
			checkBox.visible = true;
			
			paginator.onPageCount = 8;
			paginator.itemsCount = content.length;
			paginator.page = (!resetPage) ? paginator.page : 0;
			paginator.update();
			
			contentChange();
		}
		
		private var items:Vector.<FriendItem> = new Vector.<FriendItem>;
		private const ITEMS_MARGIN:int = 10;
		private const ITEMS_WIDTH:int = 140;
		private const ITEMS_HEIGHT:int = 170;
		override public function contentChange():void {
			clearContent();
			
			for (var i:int = 0; i < paginator.onPageCount; i++) {
				var index:int = i + paginator.page * paginator.onPageCount;
				
				if (content.length <= index) continue;
				
				var item:FriendItem = new FriendItem( {
					type:		content[index].type,
					width:		ITEMS_WIDTH,
					height:		ITEMS_HEIGHT,
					info:		content[index],
					window:		this
				});
				item.x = back.x + 14 + (i % 4) * (ITEMS_WIDTH + ITEMS_MARGIN);
				item.y = back.y + 14 + Math.floor(i / 4) * (ITEMS_HEIGHT + ITEMS_MARGIN);
				swContainer.addChild(item);
				items.push(item);
			}
		}
		private function clearContent():void {
			while (items.length > 0) {
				var item:FriendItem = items.shift();
				item.dispose();
			}
		}
		
		public function initContent():void {
			content = [];
			
			var object:Object;
			for each (object in App.invites.invited) {
				if (!object['photo']) object['photo'] = '';
				object['type'] = FriendItem.CANCEL;
				
				if (object.hasOwnProperty('time') && object.time > 0)
					content.push(object);
			}
			for each (object in App.invites.requested) {
				if (!object['photo']) object['photo'] = '';
				object['type'] = FriendItem.APPLY;
				
				if (object.hasOwnProperty('time') && object.time > 0)
					content.push(object);
			}
			content.sortOn('time', Array.NUMERIC | Array.DESCENDING);
		}
		public function alwaysFriendContent():void 
		{
			content = [];
			//Log.alert('alwaysFriendContent');
			//Log.alert('App.network.appFriends: '+App.network.appFriends);
			//Log.alert('App.user.friends.data: '+App.user.friends.uid);
			
			for (var id:String in App.user.friends.data) 
			{
				
				if (id == '1') continue;
				if (App.network.appFriends.indexOf(id)== -1) {
					var object:Object = App.user.friends.data[id];
					object['type'] = FriendItem.NEIGHBORS;
					content.push(App.user.friends.data[id]);
				}
			}
			content.sortOn('level', Array.NUMERIC | Array.DESCENDING);
		}
		
		private var checkSend:Boolean = false;
		private function onCheckBoxChange(e:Event):void {
			if (checkSend) return;
			checkSend = true;
			
			Post.send( {
				ctr:'invites',
				act:'visibility',
				uID:App.user.id,
				hidden:int(2 - checkBox.checked)
			}, function(error:int, data:Object, params:Object):void {
				checkSend = false;
				if (!error) {
					App.user.hidden = int(2 - checkBox.checked);
				}
			});
		}
		
		override public function dispose():void {
			super.dispose();
			
			checkBox.removeEventListener(Event.CHANGE, onCheckBoxChange);
		}
		
	}
}


import buttons.Button;
import buttons.ImageButton;
import com.greensock.easing.Bounce;
import com.greensock.easing.Cubic;
import com.greensock.TweenLite;
import core.AvaLoad;
import core.Debug;
import core.Load;
import core.Post;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.utils.setTimeout;
import ui.UserInterface;
import wins.Window;

internal class FriendItem extends LayerX {
	
	public static const ADD:uint = 1;
	public static const APPLY:uint = 2;
	public static const CANCEL:uint = 3;
	public static const NEIGHBORS:uint = 4;
	
	private var back:Bitmap;
	private var image:Sprite;
	private var imageBack:Sprite;
	private var deleteBttn:ImageButton;
	private var friendLabel:TextField;
	private var preloader:Preloader;
	private var addBttn:Button;
	private var applyBttn:Button;
	private var cancelBttn:Button;
	
	private var window:*;
	
	public var params:Object  = {
		width:			120,
		height:			220,
		link:			'none',
		canDelete:		false,
		name:			'?',
		type:			0
	}
	
	public function FriendItem(params:Object = null) {
		if (!params) params = { };
		for (var s:String in params) {
			this.params[s] = params[s];
		}
		
		if (this.params['info'] && this.params.info.hasOwnProperty('aka')) {
			this.params.name = this.params.info['aka'];
		}else if (this.params['info'] && this.params.info.hasOwnProperty('first_name')){
			this.params.name = this.params.info['first_name'];
		}
		
		window = params.window;
		
		draw();
	}
	
	private function draw():void {
		back = Window.backing(params.width, params.height, 30, 'itemBacking');
		addChild(back);
		
		preloader = new Preloader();
		preloader.scaleX = preloader.scaleY = 0.6;
		preloader.x = back.width / 2;
		preloader.y = back.height / 2;
		addChild(preloader);
		
		deleteBttn = new ImageButton(Window.textures.searchDeleteBttn);
		deleteBttn.x = back.width - deleteBttn.width + 4;
		deleteBttn.y = -4;
		addChild(deleteBttn);
		deleteBttn.addEventListener(MouseEvent.CLICK, onCancel);
		if (params.type == ADD) {
			deleteBttn.visible = false;
		}
		
		imageBack = new Sprite();
		imageBack.graphics.beginFill(0xba944d, 1);
		imageBack.graphics.drawRoundRect(0, 0, 74, 74, 22, 22);
		imageBack.graphics.endFill();
		imageBack.x = (back.width - imageBack.width) / 2;
		imageBack.y = (back.height - imageBack.height) / 2 - 6;
		addChild(imageBack);
		
		image = new Sprite();
		addChild(image);
		Post.addToArchive('link ' + link);
		if (link == 'none') {
			onLoad(new Bitmap(UserInterface.textures.defaultNeiborAvatar, 'auto', true));
		}else {
			new AvaLoad(link, onLoad);
			//Load.loading(link, onLoad);
		}
		
		friendLabel = Window.drawText(params.name, {
			width:			back.width,
			fontSize:		24,
			color:			0x773b16,
			borderColor:	0xfbf2eb,
			textAlign:		'center'
		});
		friendLabel.x = (back.width - friendLabel.width) / 2;
		friendLabel.y = 10;
		addChild(friendLabel);
		
		if (params.type == ADD) {
			if (App.invites.invited.hasOwnProperty(params.info._id)) {
				addedInfo();
			}else{
				addBttn = new Button( {
					width:		back.width - 36,
					height:		38,
					caption:	Locale.__e('flash:1415782880933'),
					fontSize:		16
				});
				addBttn.x = (back.width - addBttn.width) / 2;
				addBttn.y = back.height - addBttn.height - 10;
				addChild(addBttn);
				addBttn.addEventListener(MouseEvent.CLICK, onInvite);
			}
		}
		
		if (params.type == APPLY) {
			applyBttn = new Button( {
				width:		back.width - 36,
				height:		38,
				caption:	Locale.__e('flash:1382952379786'),
				fontSize:		20
			});
			applyBttn.x = (back.width - applyBttn.width) / 2;
			applyBttn.y = back.height - applyBttn.height - 10;
			addChild(applyBttn);
			applyBttn.addEventListener(MouseEvent.CLICK, onApply);
		}
		
		if (params.type == CANCEL) {
			cancelBttn = new Button( {
				width:			back.width - 36,
				height:			38,
				caption:		Locale.__e('flash:1382952380008'),
				fontSize:		20,
				bgColor:		[0xfba56c,0xf45e43],	//Цвета градиента
				borderColor:	[0xfba56c,0xf45e43],	//Цвета градиента
				bevelColor:		[0xfdccab,0xd04b28]
			});
			cancelBttn.x = (back.width - cancelBttn.width) / 2;
			cancelBttn.y = back.height - cancelBttn.height - 10;
			addChild(cancelBttn);
			cancelBttn.addEventListener(MouseEvent.CLICK, onCancel);
		}
	}
	
	private function onLoad(data:*):void {
		removeChild(preloader);
		preloader = null;
		
		var bitmap:Bitmap = new Bitmap(data.bitmapData, 'auto', true);
		bitmap.width = bitmap.height = 70;
		image.addChild(bitmap);
		
		var maska:Shape = new Shape();
		maska.graphics.beginFill(0xba944d, 1);
		maska.graphics.drawRoundRect(0, 0, 70, 70, 20, 20);
		maska.graphics.endFill();
		image.addChild(maska);
		
		bitmap.mask = maska;
		
		image.x = imageBack.x + (imageBack.width - image.width) / 2;
		image.y = imageBack.y + (imageBack.height - image.height) / 2;
	}
	
	private function get link():String {
		if (params['info'] && params['info']['photo']) {
			return params.info.photo;
		}else if (params['link']) {
			return params.link;
		}
		
		return '';
	}
	
	private function addedInfo():void {
		var addedLabel:TextField = Window.drawText('', {
			fontSize:		20,
			color:			0x773b16,
			borderColor:	0xfbf2eb,
			textAlign:		'center',
			autoSize:		'center',
			multiline:		true,
			textLeading:	-8
		});
		addedLabel.width = back.width - 20;
		addedLabel.wordWrap = true;
		addedLabel.text = Locale.__e('flash:1406648774876');
		addedLabel.x = (back.width - addedLabel.width) / 2;
		addedLabel.y = back.height - addedLabel.height - 5;
		addChild(addedLabel);
	}
	
	private function onInvite(e:MouseEvent):void {
		addBttn.state = Button.DISABLED;
		App.invites.invite(params.info._id, function():void {
			addBttn.visible = false;
			addedInfo();
		});
	}
	private function onApply(e:MouseEvent):void {
		applyBttn.state = Button.DISABLED;
		App.invites.accept(params.info._id, function():void {
			window.updateRequests(false);
		});
	}
	private function onCancel(e:MouseEvent):void {
		if (cancelBttn) {
			cancelBttn.state = Button.DISABLED;
		}
		if (params.type == NEIGHBORS) {
			App.invites.reject(params.info.uid, function():void {
				window.updateNeighbors(false);
			});
		}else if (params.type == APPLY || params.type == CANCEL) {
			App.invites.reject(params.info._id, function():void {
				window.updateRequests(false);
			});
		}
	}
	
	
	public function dispose():void {
		if (addBttn) addBttn.removeEventListener(MouseEvent.CLICK, onInvite);
		if (applyBttn) applyBttn.removeEventListener(MouseEvent.CLICK, onApply);
		if (cancelBttn) cancelBttn.removeEventListener(MouseEvent.CLICK, onCancel);
		if (parent) parent.removeChild(this);
	}
}


internal class SearchFriend extends Sprite {
	
	private var loader:Preloader;
	private var descIDLabel:TextField;
	public var searchInputLabel:TextField;
	private var searchPlaha:Bitmap;
	private var searchBack:Shape;
	private var clearBttn:ImageButton;
	private var iconBack:Bitmap;
	private var akaLabel:TextField;
	private var image:Sprite;
	private var searchBttn:Button;
	private var addBttn:Button;
	
	public var defaulText:String = '?';// Locale.__e('flash:1393584218977');
	private var window:*;
	
	public function SearchFriend(window:*) {
		
		this.window = window;
		
		this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		
		descIDLabel = Window.drawText(Locale.__e('flash:1444318212867'), {
			width:			420,
			textAlign:		'center',
			color:			0xf9ffff,
			borderColor:	0x593711,
			fontSize:		25
		});
		addChild(descIDLabel);
		
		iconBack = new Bitmap(Window.texture('friendFreeSlot'), 'auto', true);
		iconBack.x = 40;
		iconBack.y = descIDLabel.y + descIDLabel.height;
		addChild(iconBack);
		
		akaLabel = Window.drawText(defaulText, {
			width:			iconBack.width,
			fontSize:		20,
			color:			0x773b16,
			borderColor:	0xfbf2eb,
			textAlign:		'center'
		});
		akaLabel.x = iconBack.x + (iconBack.width - akaLabel.width) / 2;
		akaLabel.y = iconBack.y - 14;
		addChild(akaLabel);
		
		searchPlaha = new Bitmap(UserInterface.textures.lens, 'auto', true); 
		searchPlaha.x = iconBack.x + iconBack.width + 20;
		searchPlaha.y = descIDLabel.y + descIDLabel.height + 10;
		addChild(searchPlaha);
		
		loader = new Preloader();
		loader.scaleX = loader.scaleY = 0.28;
		loader.x = searchPlaha.x + searchPlaha.width / 2;
		loader.y = searchPlaha.y + searchPlaha.height / 2;
		addChild(loader);
		loader.visible = false;
		
		searchBack = new Shape();
		searchBack.graphics.beginFill(0xf1d9ab, 1);
		searchBack.graphics.drawRoundRect(0, 0, 170, 24, 10, 10);
		searchBack.graphics.endFill();
		searchBack.filters = [new GlowFilter(0x71330c, 1, 4, 4, 16)];
		searchBack.x = searchPlaha.x + searchPlaha.width + 6;
		searchBack.y = searchPlaha.y + 6;
		addChild(searchBack);
		
		searchInputLabel = Window.drawText('', {
			width:			170,
			textAlign:		'center',
			color:			0x56330b,
			borderColor:	0,
			borderSize:		0,
			fontSize:		22,
			input:			true
		});
		searchInputLabel.x = searchBack.x + (searchBack.width - searchInputLabel.width) / 2;
		searchInputLabel.y = searchBack.y + (searchBack.height - searchInputLabel.height) / 2 + 4;
		searchInputLabel.maxChars = 40;
		
		addChild(searchInputLabel);
		
		clearBttn = new ImageButton(Window.textures.searchDeleteBttn);
		clearBttn.x = searchInputLabel.x + searchInputLabel.width + 6;
		clearBttn.y = searchPlaha.y + 5;
		clearBttn.addEventListener(MouseEvent.CLICK, onClear);
		addChild(clearBttn);
		
		searchBttn = new Button( {
			width:		120,
			height:		38,
			caption:	Locale.__e('flash:1405687705056'),
			fontSize:	22
		});
		searchBttn.x = searchBack.x + (searchBack.width - searchBttn.width) / 2;
		searchBttn.y = searchBack.y + searchBack.height + 15;
		searchBttn.addEventListener(MouseEvent.CLICK, onSearch);
		addChild(searchBttn);
		
		addBttn = new Button( {
			width:		90,
			height:		34,
			caption:	Locale.__e('flash:1415782880933'),
			fontSize:	18,
			radius:		12
		});
		addBttn.x = iconBack.x + (iconBack.width - addBttn.width) / 2;
		addBttn.y = iconBack.y + iconBack.height + 10;
		addBttn.addEventListener(MouseEvent.CLICK, onAdd);
		addChild(addBttn);
		addBttn.state = Button.DISABLED;
		
		drawAva();
	}
	
	private function onAdd(e:MouseEvent):void {
		if (addBttn.mode == Button.DISABLED) return;
		
		if (findID.length > 0 && !App.invites.invited.hasOwnProperty(findID)) {
			App.invites.invite(findID, function():void {
				addBttn.state = Button.DISABLED;
			});
		}
	}
	
	private function onSearch(e:MouseEvent):void {
		if (searchBttn.mode == Button.DISABLED) return;
		search(searchInputLabel.text);
	}
	
	private var searchTimeout:int = 0;
	private var findID:String = '';
	private function onSearchTimeout():void {
		searchTimeout = 0;
		searchBttn.state = Button.NORMAL;
	}
	public function search(id:String):void {
		if (id.length == 0) return;
		searchBttn.state = Button.DISABLED;
		loader.visible = true;
		App.invites.search(id, searchComplete);
	}
	private function searchComplete(data:Object):void {
		loader.visible = false;
		searchTimeout = setTimeout(onSearchTimeout, 2000);
		if (data && data._id) {
			if (App.invites.canInvite(data._id)) {
				addBttn.state = Button.NORMAL;
				findID = data['_id'] || '';
			}
			drawAva(data);
			akaLabel.text = data['aka'] || defaulText;
		}else {
			addBttn.state = Button.DISABLED;
			drawAva(null);
			findID = '';
		}
	}
	public function drawAva(data:Object = null):void {
		if (!data) {
			data = { aka:defaulText, photo:'default' };
		}
		
		if (image) {
			if (contains(image)) removeChild(image);
			image = null;
		}
		
		image = new Sprite();
		addChild(image);
		
		if (!data['photo'] || data['photo'] == 'default') {
			onLoad(new Bitmap(UserInterface.textures.defaultNeiborAvatar, 'auto', true));
		}else {
			//Load.loading(data.photo, onLoad);
			new AvaLoad(data.photo, onLoad);
		}
		
		function onLoad(bitmap:Bitmap):void {
			
			var bitmap:Bitmap = new Bitmap(bitmap.bitmapData, 'auto', true);
			bitmap.width = bitmap.height = 70;
			image.addChild(bitmap);
			
			var maska:Shape = new Shape();
			maska.graphics.beginFill(0xba944d, 1);
			maska.graphics.drawRoundRect(0, 0, 70, 70, 16, 16);
			maska.graphics.endFill();
			image.addChild(maska);
			
			bitmap.mask = maska;
			
			image.x = iconBack.x + (iconBack.width - image.width) / 2;
			image.y = iconBack.y + (iconBack.height - image.height) / 2 + 4;
			image.filters = [new GlowFilter(0xbd934b, 1, 4, 4, 16)];
		}
	}
	
	private function onClear(e:MouseEvent):void {
		searchInputLabel.text = '';
		findID = '';
		drawAva();
		addBttn.state = Button.DISABLED;
	}
	
	private function onRemove(e:Event):void {
		clearBttn.removeEventListener(MouseEvent.CLICK, onClear);
		this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
	}
}

internal class ShareInfo extends Sprite {
	
	private var searchInputLabel:TextField;
	private var descTellLabel:TextField;
	
	public function ShareInfo() {
		
		var back:Bitmap = Window.backing(240, 190, 53, 'itemBacking');
		back.x = 0;
		addChild(back);
		
		descTellLabel = Window.drawText('', {
			textAlign:		'center',
			autoSize:		'center',
			color:			0xf9ffff,
			borderColor:	0x593711,
			fontSize:		23,
			textLeading:	-30
		});
		descTellLabel.width = 230;
		descTellLabel.multiline = true;
		descTellLabel.wordWrap = true;
		descTellLabel.text = Locale.__e('flash:1444318300686');
		descTellLabel.x = back.x + (back.width - descTellLabel.width) / 2;
		descTellLabel.y = 15;
		addChild(descTellLabel);
		
		/*var searchBack:Shape = new Shape();
		searchBack.graphics.beginFill(0xf1d9ab, 1);
		searchBack.graphics.drawRoundRect(0, 0, 170, 24, 10, 10);
		searchBack.graphics.endFill();
		searchBack.filters = [new GlowFilter(0x71330c, 1, 4, 4, 16)];
		searchBack.x = descTellLabel.x + (descTellLabel.width - searchBack.width) / 2;
		searchBack.y = descTellLabel.y + descTellLabel.height + 5;
		addChild(searchBack);*/
		
		searchInputLabel = Window.drawText(App.user.id, {
			width:			240,
			textAlign:		'center',
			color:			0xffedbc,
			borderColor:	0x774522,
			borderSize:		3,
			fontSize:		30
		});
		searchInputLabel.x = descTellLabel.x + (descTellLabel.width - searchInputLabel.width) / 2;
		searchInputLabel.y = descTellLabel.y + descTellLabel.height + 4;
		searchInputLabel.selectable = true;
		searchInputLabel.mouseEnabled = true;
		addChild(searchInputLabel);
		
		var copyBttn:Button = new Button( {
			width:		120,
			height:		44,
			caption:	Locale.__e('flash:1415792106179'),
			fontSize:	22
		});
		copyBttn.x = descTellLabel.x + (descTellLabel.width - copyBttn.width) / 2;
		copyBttn.y = searchInputLabel.y + searchInputLabel.height - 4;
		copyBttn.addEventListener(MouseEvent.CLICK, onCopy);
		addChild(copyBttn);
		
		
		
	}
	
	private function jump():void {
		var pos:Number = descTellLabel.x + (descTellLabel.width - searchInputLabel.width) / 2;
		TweenLite.to(searchInputLabel, 0.3, { x:pos - 12, scaleX:1.1, scaleY:1.1, ease:Cubic.easeOut, onComplete:function():void {
			TweenLite.to(searchInputLabel, 0.4, { x:pos, scaleX:1, scaleY:1, ease:Bounce.easeOut } );
		}} );
	}
	
	private function onCopy(e:MouseEvent):void {
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, App.user.id);
		jump();
	}
}
