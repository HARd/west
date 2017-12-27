package 
{
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import wins.Window;
	import core.Post;

	public class Console extends Sprite
	{
		public static var loadProgress:Array = [];
		public var text:TextField;
		private var opened:Boolean = false;
		public function Console()
		{
			
		}
		
		public static function addLoadProgress(text:String):void {
			loadProgress.push(text);
		}
		
		public function log(data:String):void
		{
			if (opened) {
				text.appendText(data)
				text.scrollV = text.numLines - 8;
			}
		}
		
		public function open():void
		{
			if (opened) {
				close();
				return;
			}
			
			this.graphics.beginFill(0x000000, 0.5);
			this.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight / 3);
			this.graphics.endFill();
			
			text = Window.drawText("", {
				fontSize:18,
				border:false,
				multiline:true
			});
			
			addChild(text);
			text.selectable = true;
			text.height = App.self.stage.stageHeight / 3 - 10;
			text.width = App.self.stage.stageWidth - 20;
			text.x = 10;
			text.y = 10;
			text.mouseWheelEnabled = true;
			text.mouseEnabled = true;
			
			App.self.addChild(this);
			showArchive();
			
			opened = true;
		}
		
		private function showArchive():void
		{
			var archive:Array = Post.archive;
			var L:uint = archive.length;
			for (var i:int = 0; i < L; i++)
			{
				text.appendText(archive[i]);
			}
			
			text.scrollV = text.numLines - 8;
		}
		
		public function close():void
		{
			this.graphics.clear();
			removeChild(text);
			
			App.self.removeChild(this);
			opened = false;
		}
		
		public var debugWindow:DebugWindow
		public function openDebug():void {
			
			if (debugWindow != null){
				App.map.mTreasure.removeChild(debugWindow);
				debugWindow.dispose();
				debugWindow = null;
				return;
			}
			debugWindow = new DebugWindow();
			App.map.mTreasure.addChild(debugWindow);
			debugWindow.x = App.map.mouseX + 10;
			debugWindow.y = App.map.mouseY - 20;
		}
	}
}

import astar.AStarNodeVO;
import core.IsoConvert;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;
internal class DebugWindow extends Sprite
{
	public function DebugWindow() 
	{
		drawBg();
		drawContent();
	}
	
	private var object:* = null;
	private var _text:TextField;
	
	private function drawContent():void {
		
		_text = Window.drawText(" ",{
			color:0xFFFFFF,
			fontSize:14
		});
		addChild(_text);
		
		_text.x = 5;
		_text.y = 5;
		_text.height = bg.height - 10;
		_text.width = bg.width - 10;
		
		App.self.setOnEnterFrame(update);
	}
	
	private function update(e:* = null):void {
		var point:Object = IsoConvert.screenToIso(App.map.mouseX, App.map.mouseY, true);
		var node:AStarNodeVO = null;
		var _node:AStarNodeVO = null;
		if (App.map._aStarWaterNodes.hasOwnProperty(point.x)){
			if (App.map._aStarWaterNodes[point.x].hasOwnProperty(point.z))
			{
				//node = App.map._aStarWaterNodes[point.x][point.z];
				node = App.map._aStarNodes[point.x][point.z];
			}
		}	
		
		if (node == null) return;
		_text.text = "X: " +point.x + "  Z: " +point.z + "\n";
		_text.appendText("b: " +node.b + "  p: " +node.p + "\n");
		_text.appendText("object: " +node.object + "\n");
		_text.appendText("isWall: " +node.isWall + "\n");
	}
	
	/*private var Y:int = 5;
	private var X:int = 5;
	private function addLine(_name:String):void {
		
		var nameText:TextField = Window.drawText(_name + ": ",{
			color:0xFFFFFF,
			fontSize:14
		});
		
		addChild(nameText);
		nameText.x = X;
		nameText.y = Y;
		
		var dataText:TextField = Window.drawText("  ",{
			color:0xFFFFFF,
			fontSize:14
		});
		
		addChild(dataText);
		dataText.x = nameText.x + nameText.textWidth + 5;
		dataText.y = Y;
		
		Y += nameText.textHeight + 5;
	}*/
	
	private var bg:Sprite;
	private function drawBg():void {
		bg = new Sprite();
		bg.graphics.beginFill(0x000000, 0.5);
		bg.graphics.drawRoundRect(0, 0, 150, 90, 12, 12);
		bg.graphics.endFill();
		
		addChild(bg);
	}
	
	public function dispose():void {
		App.self.setOffEnterFrame(update);
	}	
}

