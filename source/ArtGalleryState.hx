package;

import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class ArtGalleryState extends MusicBeatState
{
	private static var curSelected:Int = 0;
	public static var selectedCategory:String = "";
	public static var selectedCategoryName:String = "";

	var scoreBG:FlxSprite;
	var scoreText:FlxFixedText;
	var diffText:FlxFixedText;

	private var grpCategories:FlxTypedGroup<Alphabet>;

	var categories = [
		"Concept Art",
		//"Concept Songs",
		"Illustrations",
		"Warmup Sketches"
	];

	override function create()
	{
		persistentUpdate = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Art Gallery", null);
		#end

		var bg = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
		bg.setGraphicSize(FlxG.width);
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		//var skarlet:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('skarlet'));
		//skarlet.setGraphicSize(Std.int(skarlet.width * 0.77));
		//skarlet.updateHitbox();
		//skarlet.x = FlxG.width - skarlet.width - 80;
		//skarlet.antialiasing = ClientPrefs.globalAntialiasing;
		//add(skarlet);

		var bars = new FlxSprite().loadGraphic(Paths.image('freeplay/bars'));
		bars.scale.set(0.66, 0.66);
		bars.updateHitbox();
		bars.antialiasing = ClientPrefs.globalAntialiasing;
		add(bars);
		bars.angle = -2;
		bars.screenCenter();

		grpCategories = new FlxTypedGroup<Alphabet>();
		add(grpCategories);

		for (i in 0...categories.length)
		{
			var text:Alphabet = new Alphabet(0, (70 * i) + 30, categories[i], true, false);
			text.isMenuItem = true;
			text.targetY = i - 1;
			text.snap();
			grpCategories.add(text);
		}

		scoreText = new FlxFixedText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSpriteExtra(scoreText.x - 6, 0).makeSolid(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		//add(scoreBG);

		if(curSelected >= categories.length) curSelected = 0;
		//bg.color = songs[curSelected].color;
		//intendedColor = bg.color;

		changeSelection();

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = false;
		persistentDraw = true;
		super.closeSubState();
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(categories.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}
			}
		}

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (accepted)
		{
			persistentDraw = false;
			openSubState(new ArtSubState());
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = categories.length - 1;
		if (curSelected >= categories.length)
			curSelected = 0;

		var bullShit = 0;

		for (item in grpCategories.members)
		{
			//item.targetY = bullShit - curSelected;

			//if (item.targetY == 0)
			FlxTween.cancelTweensOf(item);
			if (bullShit == curSelected) {
				item.alpha = 1;
				FlxTween.tween(item, {xAdd: 75}, 0.15);
			} else {
				item.alpha = 0.6;
				FlxTween.tween(item, {xAdd: 0}, 0.15);
			}

			bullShit++;
		}

		selectedCategory = Paths.formatToSongPath(categories[curSelected]);
		selectedCategoryName = categories[curSelected];
	}
}

class CategoryMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}