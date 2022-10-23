package;

import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
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

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	private var floatSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxFixedText;
	var diffText:FlxFixedText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<FlxText>;
	private var grpSelectors:FlxTypedGroup<FlxSprite>;
	private var curPlaying:Bool = false;

	var characterSkarlet:FlxSprite;
	var characterMatt:FlxSprite;

	/*private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;*/

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		var bg = new FlxSprite().loadGraphic(Paths.image('freeplay/bg'));
		bg.setGraphicSize(FlxG.width);
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		add(new OoooYouLikeMen());

		characterSkarlet = new FlxSprite(0, 0).loadGraphic(Paths.image('renders/skarlet'));
		characterSkarlet.setGraphicSize(Std.int(characterSkarlet.width * 0.77));
		characterSkarlet.updateHitbox();
		characterSkarlet.x = FlxG.width - characterSkarlet.width - 80;
		characterSkarlet.antialiasing = ClientPrefs.globalAntialiasing;
		characterSkarlet.alpha = 0.00001;
		add(characterSkarlet);

		//characterMatt = new FlxSprite(0, 0).loadGraphic(Paths.image('renders/matt'));
		//characterMatt.setGraphicSize(Std.int(characterMatt.width * 0.77));
		//characterMatt.updateHitbox();
		//characterMatt.x = FlxG.width - characterMatt.width - 80;
		//characterMatt.antialiasing = ClientPrefs.globalAntialiasing;
		//characterMatt.alpha = 0.00001;
		//add(characterMatt);

		grpSelectors = new FlxTypedGroup<FlxSprite>();
		add(grpSelectors);
		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		var vinyl:FlxSprite = new FlxSprite();
		vinyl.frames = Paths.getSparrowAtlas('freeplay/record');
		vinyl.animation.addByPrefix('vinyl', 'vinyl', 24);
		vinyl.animation.play('vinyl', true);
		vinyl.setGraphicSize(Std.int(vinyl.width * 0.7));
		vinyl.updateHitbox();
		add(vinyl);
		vinyl.screenCenter(Y);
		vinyl.y += vinyl.height * 0.045;
		vinyl.x = vinyl.width * -0.43;
		vinyl.antialiasing = ClientPrefs.globalAntialiasing;

		var bars = new FlxSprite().loadGraphic(Paths.image('freeplay/bars'));
		bars.scale.set(0.66, 0.66);
		bars.updateHitbox();
		bars.antialiasing = ClientPrefs.globalAntialiasing;
		add(bars);
		bars.angle = -2;
		bars.screenCenter();

		scoreText = new FlxFixedText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSpriteExtra(scoreText.x - 6, 0).makeSolid(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxFixedText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		//bg.color = songs[curSelected].color;
		//intendedColor = bg.color;

		for (i in 0...songs.length)
		{
			var size = 80;
			var songText:FlxText = new FlxText(380, FlxG.height / 2 - (size / 2) + 20, songs[i].songName, size);
			songText.setFormat(Paths.font("collegeb.ttf"), size, FlxColor.WHITE, RIGHT);
			songText.scrollFactor.set();
			songText.updateHitbox();
			if(songText.width > 412)
			{
				var daScaly = 412 / songText.width;
				songText.scale.set(daScaly, 1);
				songText.x += (1 - daScaly) * 560;
			}
			songText.origin.x = -songText.x - 42;
			songText.antialiasing = ClientPrefs.globalAntialiasing;
			//songText.origin.y = -(songText.y - songText.height + center.y);
			grpSongs.add(songText);
			//trace(songText.origin);
			//songText.origin.set(-songText.x + songText.origin.x + center.x - FlxG.width / 2, songText.y + songText.origin.y - center.y);
			//songText.angle = -90 + (45 * i);
		}
		WeekData.setDirectoryFromWeek();

		for (i in 0...grpSongs.members.length)
		{
			var spr:FlxSprite = new FlxSprite(410);
			spr.frames = Paths.getSparrowAtlas('freeplay/frames');
			spr.animation.addByPrefix('unselected', 'frame unselected', 24);
			spr.animation.addByPrefix('selected', 'frame white', 24);
			spr.animation.play('unselected', true);
			spr.antialiasing = ClientPrefs.globalAntialiasing;
			spr.scale.set(0.85, 0.85);
			spr.updateHitbox();
			spr.screenCenter(Y);
			//spr.x -= 50;
			spr.y += 30;
			spr.origin.x = -spr.x + 10;
			//spr.origin.y = (spr.y - spr.frameHeight + center.y);
			grpSelectors.add(spr);
		}

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		changeSelection();
		changeDiff();

		var textBG:FlxSprite = new FlxSpriteExtra(0, FlxG.height - 26).makeSolid(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		//add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		floatSelected = curSelected;
		updatePositions();
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	function updatePositions(?elapsed:Float = 0)
	{
		var add:Float = 8 * elapsed;
		if(curSelected < floatSelected) add = -add;

		if(Math.abs(floatSelected - curSelected) <= Math.abs(add))
			floatSelected = curSelected;
		else
			floatSelected += add;

		var bullShit:Int = 0;
		for (item in grpSongs.members)
		{
			item.angle = 45 * (bullShit - floatSelected);
			item.visible = (item.angle > -110 && item.angle < 200);
			var selec:FlxSprite = grpSelectors.members[bullShit];
			selec.angle = item.angle;
			selec.visible = item.visible;
			bullShit++;
		}
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}

		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
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
					changeDiff();
				}
			}
		}

		if(floatSelected != curSelected)
		{
			updatePositions(elapsed);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			/*if(colorTween != null) {
				colorTween.cancel();
			}*/
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			if(instPlaying != curSelected)
			{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				Paths.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;
				instPlaying = curSelected;
				#end
			}
		}

		else if (accepted)
		{
			
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			if(!Song.doesChartExist(poop, songLowercase)) {
				var key = Song.getChartPath(poop, songLowercase);
	
				showMessage('Chart $key doesnt exist', 1);
				return;
			}

			persistentUpdate = false;
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsSongJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.jsonSong(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.jsonSong(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			/*if(colorTween != null) {
				colorTween.cancel();
			}*/

			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		/*var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}*/

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		/*for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;*/

		for (item in grpSongs.members)
		{
			var selec = grpSelectors.members[bullShit];
			item.color = FlxColor.WHITE;
			selec.animation.play('unselected');
			if (bullShit - curSelected == 0)
			{
				item.color = FlxColor.BLACK;
				selec.animation.play('selected');
			}
			bullShit++;
		}

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
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