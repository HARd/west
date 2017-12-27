package
{
  import core.Load;
  import flash.events.Event;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.media.SoundTransform;
  import flash.utils.setTimeout;
  import flash.utils.Timer;
  import ui.SystemPanel;

  public class SoundsManager
  {
    public static var _instance:SoundsManager;
    public static var _allowInstance:Boolean = false;   

    public var allowSounds:Boolean; 			//разрешение проигрывать музыку 
    public var allowSFX:Boolean; 				//разрешение проигрывать звуковые эффекты
    public var sound:Object = {}; 				//Звуковые эффекты
    public var music:Sound; 					//Музыка
    public var music2:Sound; 					//Музыка
	
    private var effectSoundChannels:Array; 		
	private var dinamicSoundChannels:Array; 
	
	private var bgSoundChannels:Array; 
    private var mMusicChannel:SoundChannel; 	//Единственный звуковой канал для музыки
	
    private const MAX_SOUND_CHANNELS:int = 8; 	//Количество звуков, которые могут проигрываться одновременно
	private var timer:Timer;
	private var data:Object;
	public static var complete:Boolean = false;
	    
		public function SoundsManager()
		{
			if (!_allowInstance)
			{
				throw new Error("Error: Use SoundsManager.instance() instead of the new keyword.");
			}
		  ///initSounds();
		}
		
		public function loadSounds():void
		{
			//var musicLink:String = 'http://aliens.islandsville.com/resources/swf/Sound/music.swf?v=2';
			var musicLink:String = Config.getSwf('Sound', 'musicFinal2');
			//var soundFXLink:String = 'http://aliens.islandsville.com/resources/swf/Sound/soundFX.swf?v=2';
			var soundFXLink:String = Config.getSwf('Sound', 'soundFX');
			Load.loading(musicLink, onMusicLoad);
			//Load.loading(musicLink2, onMusicLoad2);
			Load.loading(soundFXLink, onSoundsLoad);
		}
		
		private function onSoundsLoad(data:*):void
		{
			allowSFX = true;
			
			if (SystemPanel.getSystemCookie(SystemPanel.SOUND) == '0'){
				allowSFX = false;
				App.ui.systemPanel.bttnSystemSound.alpha = 0.5;
			}else{
				allowSFX = true;
				App.ui.systemPanel.bttnSystemSound.alpha = 1;
			}
			
			initSounds(data);
			SoundsManager.complete = true;
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_SOUND_LOAD));
			addAmbience();
		}
		
		private function onMusicLoad(data:*):void
		{
			music = data.music;
			allowSounds = true;
			
			if (SystemPanel.getSystemCookie(SystemPanel.MUSIC) == '0'){
				allowSounds = false;
				App.ui.systemPanel.bttnSystemMusic.alpha = 0.5;
			}else{
				allowSounds = true;
				App.ui.systemPanel.bttnSystemMusic.alpha = 1;
			}
			
			if (App.user.quests.tutorial && !Tutorial.mainTutorialComplete) {
				App.tutorial.initMusic(playMusic);
				return;
			}
			
			playMusic();
			//music2Complete();
			//playPart();
		}
		
		private function onMusicLoad2(data:*):void
		{
			music2 = data.music;
		}
		
		private var counter:int = 0;
		private function playPart():void {
			counter ++;
			if (counter <= 2) {
				mMusicChannel = music.play(0, 1);
			}else {
				if (music2)
					mMusicChannel = music2.play(0, 1);	
				else if (music)
					mMusicChannel = music.play(0, 1);
				counter = 0;
			}
			mMusicChannel.addEventListener(Event.SOUND_COMPLETE, musicPartComplete);
		}
		
		private function musicPartComplete(e:*= null):void {
			mMusicChannel.removeEventListener(Event.SOUND_COMPLETE, musicPartComplete);
			playPart();
		}
		
		public static function get instance():SoundsManager
		{
			if (_instance == null)
			{
				_allowInstance = true;
				_instance = new SoundsManager();
				_allowInstance = false;
			}
			return _instance;
		}
		
		private function initSounds(data:*): void
		{
			sound = new Object();
				
			effectSoundChannels = [];
			if (dinamicSoundChannels == null) dinamicSoundChannels = [];
			
			sound = data.sounds;
		}
		
		public function addDinamicEffect(sound_name:String, object:Object):void
		{
			if (!allowSFX) return;
			
			if (object == null) return;
			
			if (dinamicSoundChannels == null)
				dinamicSoundChannels = [];
			
			var soundObject:Object = {
				snd:sound_name,
				obj:object,
				sc:null
			};
			
			soundObject.sc = createSoundChanel(object, sound_name);
			dinamicSoundChannels.push(soundObject);
		}
		
		private function createSoundChanel(object:Object, sound_name:String):SoundChannel
		{
			var settings:Object = prepareSTPan(object);
			var soundTrans:SoundTransform = new SoundTransform(settings.vol, settings.panning);
			var currentSound:Sound = sound[sound_name];
			if (!currentSound) return null;
			var sndChannel:SoundChannel = currentSound.play(0, 99, soundTrans);
				
			return sndChannel;
		}
		
		public function stopDinamicEffects():void
		{
			if (!dinamicSoundChannels) return;
			for (var i:int = 0; i < dinamicSoundChannels.length; i++)
			{
				if (dinamicSoundChannels[i].sc != null){
					dinamicSoundChannels[i].sc.stop();
				}
			}
			
			if (!effectSoundChannels) return;
			for (i = 0; i < effectSoundChannels.length; i++)
			{
				if (effectSoundChannels[i].sc != null){
					effectSoundChannels[i].sc.stop();
				}
			}	
			effectSoundChannels.splice(0, effectSoundChannels.length);
		}
		
		public function playDinamicEffects():void
		{
			if (dinamicSoundChannels == null)
				return;
				
			for (var i:int = 0; i < dinamicSoundChannels.length; i++)
			{
				dinamicSoundChannels[i].sc = createSoundChanel(dinamicSoundChannels[i].obj, dinamicSoundChannels[i].snd);
			}	
			addAmbience();
		}
		
		public function removeDinamicEffect(object:Object):void
		{
			if (dinamicSoundChannels == null) return;
			for (var i:int = 0; i < dinamicSoundChannels.length; i++)
			{
				if (dinamicSoundChannels[i].obj == object)
				{
					if (dinamicSoundChannels[i].sc != null)
						dinamicSoundChannels[i].sc.stop();
						
					dinamicSoundChannels.splice(i, 1);
				}
			}
		}
		
		//private var counter:int = 1;
		public function playSFX(sound_name:String, object:Object = null, loops:int = 0, vol:Number = 1):void
		{
			if (!allowSFX) return;
			if (!sound[sound_name]) return;
				
			var sndChannel:SoundChannel;
			var currentSound:Sound = sound[sound_name];
			var soundTrans:SoundTransform;
			if (object != null)
			{
				var settings:Object = prepareSTPan(object);
				soundTrans = new SoundTransform(settings.vol, settings.panning);
				
				sndChannel = currentSound.play(0, loops, soundTrans);
				effectSoundChannels.push( { sc:sndChannel, obj:object} )
			}
			else
			{
				soundTrans = new SoundTransform(vol);
				sndChannel = currentSound.play(0, loops, soundTrans);
				effectSoundChannels.push( { sc:sndChannel, obj:null } )
			}
			
			if(sndChannel)
				sndChannel.addEventListener(Event.SOUND_COMPLETE, onEffectComplete);
		}
		
		private function onEffectComplete(e:Event):void
		{
			var thisSoundChannel:SoundChannel = e.currentTarget as SoundChannel;
			thisSoundChannel.removeEventListener(Event.SOUND_COMPLETE, onEffectComplete);
			
			for (var i:int = 0; i < effectSoundChannels.length; i++)
			{
				var obj:Object = effectSoundChannels[i];
				if (obj.sc == thisSoundChannel)
				{
					effectSoundChannels.splice(i, 1);
				}
			}	
		}
		
		public function playMusic():void
		{
			var soundTransform:SoundTransform = new SoundTransform(0.1);//0.14
			
			if (!allowSounds) soundTransform.volume = 0;
			
			if (App.isSocial('MX','YB')) soundTransform.volume = 0;
			
			if (!mMusicChannel) 
			{
				if (music == null) return;
				mMusicChannel = music.play(0, 99, soundTransform);
                //mMusicChannel.addEventListener(Event.SOUND_COMPLETE, musicComplete);
			} else {
				mMusicChannel.soundTransform = soundTransform;
			}
		}
		
		public function disposeMusic():void
		{
			if (mMusicChannel != null)
			{
				mMusicChannel.stop();
				mMusicChannel = null;
			}	
		}
		
		protected static function prepareSTPan(object:Object) : Object {
			
			var posX:int = object.x + App.map.x;
			var posY:int = object.y + App.map.y;
			
			if (posX < -50 || posX > App.self.stage.stageWidth+50)
			{
				return {panning:0, vol:0}
			}
			if (posY < -50 || posY > App.self.stage.stageHeight+50)
			{
				return {panning:0, vol:0}
			}
			
			var volume:Number;
				
			var volumeX:Number = (posX / (App.self.stage.stageWidth / 2))
			if (volumeX > 1) volumeX = (2 - volumeX)
			
			var volumeY:Number = (posY / (App.self.stage.stageHeight/ 2))
			if (volumeY > 1) volumeY = (2 - volumeY)
			
			var pan:Number = (posX / (App.self.stage.stageWidth / 2) - 1.0)
		
			if (volumeX > volumeY)
			{
				volume = volumeY
			}
			else
			{
				volume = volumeX
			}
			
			return {panning:pan, vol:volume}
			//return {panning:1, vol:1}
		}
		
		public function soundReplace(e:* = null):void
		{
			if (!allowSFX || dinamicSoundChannels) return;
			
			for (var i:int = 0; i < dinamicSoundChannels.length; i++)
			{
				var sc:SoundChannel = dinamicSoundChannels[i].sc;
				if (!sc) continue;
				var settings:Object = prepareSTPan(dinamicSoundChannels[i].obj);
				sc.soundTransform = new SoundTransform(settings.vol, settings.panning);
			}
		}
			
		public function setMusic(boolean:Boolean):void
		{
			allowSounds = boolean;
			if (boolean == false)
			{
				disposeMusic();
			}
			else
			{
				playMusic();
			}
			
			SystemPanel.setSystemCookie(SystemPanel.MUSIC, (boolean) ? '1' : '0');
		}
		
		public function setSound(boolean:Boolean):void
		{
			allowSFX = boolean;
			if (boolean == false)
			{
				stopDinamicEffects();
			}
			else
			{
				playDinamicEffects();
			}
			
			SystemPanel.setSystemCookie(SystemPanel.SOUND, (boolean) ? '1' : '0');
		}
		
		public function dispose():void
		{
			stopDinamicEffects();
			dinamicSoundChannels = [];
		}
		
		public function addAmbience():void {
			if (!complete) return;
			
			playSFX('ambience_1',null, 50);
			/*for (var i:int = 0; i < 2; i++){
				var object:Object = getRandomMapPoint();
				addDinamicEffect('ambience_1', object);
			}*/
		}
		
		/*private function getRandomMapPoint():Object {
			
			var padding:int = 300;
			var _x:int = padding + (Math.random() * (Map.mapWidth - padding * 2));
			var _y:int = padding + (Math.random() * (Map.mapHeight - padding * 2));
			
			return {
				x:_x,
				y:_y
			}
		}*/
	}
}
