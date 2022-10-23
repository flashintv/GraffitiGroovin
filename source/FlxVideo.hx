#if web
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
#else
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import vlc.VlcBitmap;
import openfl.Lib;
#end
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

class FlxVideo extends FlxBasic {
	#if VIDEOS_ALLOWED
	public var finishCallback:Void->Void = null;

	#if desktop
	public static var vlcBitmap:VlcBitmap;
	public var onSkip:Void->Void = null;
	#end

	public var skipSprite:SkipSprite;
	public var holdingTime:Float = 0;
	private var holdingKey:Bool = false;

	private var acceptKeys:Array<FlxKey> = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('accept'));
	private var skipSpriteScale:Float = 0.5;
	private var skipSpriteBitmap:BitmapData = null;

	public function new(name:String) {
		super();

		lastTime = Lib.getTimer();

		#if web
		var player:Video = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		var netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function() {
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
			if(event.info.code == "NetStream.Play.Complete") {
				netStream.dispose();
				if(FlxG.game.contains(player)) FlxG.game.removeChild(player);

				if(finishCallback != null) finishCallback();
			}
		});
		netStream.play(name);

		#elseif desktop
		// by Polybius, check out PolyEngine! https://github.com/polybiusproxy/PolyEngine

		vlcBitmap = new VlcBitmap();
		vlcBitmap.set_height(FlxG.stage.stageHeight);
		vlcBitmap.set_width(FlxG.stage.stageHeight * (16 / 9));

		vlcBitmap.onComplete = onVLCComplete;
		vlcBitmap.onError = onVLCError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, videoEnterFrame);
		vlcBitmap.repeat = 0;
		vlcBitmap.inWindow = false;
		vlcBitmap.fullscreen = false;
		videoEnterFrame(null);

		FlxG.addChildBelowMouse(vlcBitmap);
		vlcBitmap.play(checkFile(name));

		skipSpriteBitmap = Paths.image('skipcutscene').bitmap;
		skipSprite = new SkipSprite(0, 0, skipSpriteBitmap);
		onResize(null);
		skipSprite.alpha = 0.5;
		FlxG.addChildBelowMouse(skipSprite);

		FlxG.stage.addEventListener(Event.RESIZE, onResize);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		#end
	}
	
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		if(getKeyIsAccept(eventKey))
		{
			holdingKey = true;
		}
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		if(getKeyIsAccept(eventKey))
		{
			holdingKey = false;
			holdingTime = 0;
		}
	}

	private function getKeyIsAccept(key:FlxKey):Bool
	{
		if(key != NONE)
		{
			for (k in acceptKeys)
			{
				if(key == k)
				{
					return true;
				}
			}
		}
		return false;
	}

	#if desktop
	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}

	public static function onFocus() {
		if(vlcBitmap != null) {
			vlcBitmap.resume();
		}
	}

	public static function onFocusLost() {
		if(vlcBitmap != null) {
			vlcBitmap.pause();
		}
	}

	public var lastTime:Float = 0;
	public var fadeTime:Float = 4;
	function videoEnterFrame(e:Event)
	{
		// skip image
		var curTime:Float = Lib.getTimer();
		var elapsed:Float = (curTime - lastTime) / 1000;
		if(holdingKey)
		{
			holdingTime += elapsed;
			fadeTime = 0;
			skipSprite.alpha = Math.min(1, 0.1 + (holdingTime * 0.9));
			if(holdingTime >= 1)
			{
				trace('Skipped cutscene');
				holdingTime = 1;
				if(onSkip != null)
				{
					onSkip();
				}

				onVLCComplete();
				return;
			}
		}
		else if(vlcBitmap != null && skipSprite != null)
		{
			fadeTime -= elapsed;
			if(fadeTime < 0) fadeTime = 0;

			skipSprite.alpha = Math.max(0, 0.5 - (((4 - fadeTime) / 4) * 0.4));
		}
		lastTime = curTime;

		// shitty volume fix
		vlcBitmap.volume = 0;
		if(!FlxG.sound.muted && FlxG.sound.volume > 0.01) { //Kind of fixes the volume being too low when you decrease it
			vlcBitmap.volume = FlxG.sound.volume * 0.5 + 0.5;
		}
	}

	function onResize(e:Event)
	{
		var mult = (FlxG.stage.stageHeight / FlxG.height);
		skipSprite.scaleX = skipSpriteScale * mult;
		skipSprite.scaleY = skipSpriteScale * mult;

		skipSprite.x = (FlxG.width - ((skipSpriteBitmap.width + 80) * skipSpriteScale)) * mult;
		skipSprite.y = (FlxG.height - ((skipSpriteBitmap.height + 72) * skipSpriteScale)) * mult;
	}

	public function onVLCComplete()
	{
		vlcBitmap.stop();
		// Clean player, just in case!
		if(vlcBitmap != null)
		{
			vlcBitmap.dispose();
		}

		if (FlxG.game.contains(vlcBitmap))
		{
			FlxG.game.removeChild(vlcBitmap);
		}

		if (FlxG.game.contains(skipSprite))
		{
			FlxG.game.removeChild(skipSprite);
		}

		if (finishCallback != null)
		{
			finishCallback();
		}
		FlxG.stage.removeEventListener(Event.ENTER_FRAME, videoEnterFrame);
		FlxG.stage.removeEventListener(Event.RESIZE, onResize);

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
	}


	function onVLCError()
		{
			trace("An error has occured while trying to load the video.\nPlease, check if the file you're loading exists.");
			if (finishCallback != null) {
				finishCallback();
			}
		}
	#end
	#end
}

class SkipSprite extends Sprite
{
	public function new(x:Float, y:Float, ?image:BitmapData)
	{
		super();
		this.x = x;
		this.y = y;

		if(image != null) {
			//graphics.beginBitmapFill(image);
			//graphics.endFill();
			trace('creating image');
			graphics.beginBitmapFill(image, null, false, ClientPrefs.globalAntialiasing);
			graphics.drawRect (0, 0, image.width, image.height);
		}
	}
}