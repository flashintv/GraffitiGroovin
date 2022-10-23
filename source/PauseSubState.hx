package;

import flixel.math.FlxPoint;
import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<PauseItem>;
	var visualMenuShit:FlxTypedGroup<PauseItem>;

	var menuItems:Array<String> = [];
	//var menuItemsOG:Array<String> = ['Resume', 'Restart', 'Difficulty', 'Exit'];
	var menuItemsOG:Array<String> = ['Resume', 'Restart', 'Botplay', 'Exit'];
	var difficultyChoices = [];
	var diffMap:Map<String, Int> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxFixedText;
	var skipTimeText:FlxFixedText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	var wall:FlxSprite;

	public function new()
	{
		super();
		/*if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');

			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Practice Mode');
			menuItemsOG.insert(5 + num, 'Botplay');
		}*/

		var chartName:String = PlayState.SONG.song;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			diffMap[diff] = i;

			var diffSong = Highscore.formatSong(chartName, i);

			if(Song.doesChartExist(diffSong, chartName)) {
				difficultyChoices.push(diff);
			}
		}
		if(difficultyChoices.length < 2) menuItemsOG.remove('Difficulty'); //No need to change difficulty if there is only one!
		difficultyChoices.push('BACK');

		menuItems = menuItemsOG;

		trace("Loading Pause Music");

		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		trace("Finished Loading Pause Music");

		var bg = new FlxSpriteExtra().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.00001;
		bg.scrollFactor.set();
		bg.moves = false;
		add(bg);

		wall = new FlxSprite();
		wall.frames = Paths.getSparrowAtlas("pause/wall");
		wall.animation.addByPrefix("idle", "wall3", 24);
		wall.animation.play("idle");
		wall.setGraphicSize(0, FlxG.height + 30 + 60);
		wall.updateHitbox();
		wall.antialiasing = ClientPrefs.globalAntialiasing;
		wall.y -= 60;
		wall.x -= 130;
		wall.x += 17;
		wall.scale.scale(1.08);
		wall.moves = false;
		add(wall);

		var levelInfo:FlxFixedText = new FlxFixedText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxFixedText = new FlxFixedText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxFixedText = new FlxFixedText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxFixedText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		if(PlayState.chartingMode) {
			var chartingText:FlxFixedText = new FlxFixedText(20, 15 + 101, 0, "CHARTING MODE", 32);
			chartingText.scrollFactor.set();
			chartingText.setFormat(Paths.font('vcr.ttf'), 32);
			chartingText.x = FlxG.width - (chartingText.width + 20);
			chartingText.y = FlxG.height - (chartingText.height + 20);
			chartingText.updateHitbox();
			add(chartingText);
		}

		blueballedTxt.alpha = 0.00001;
		levelDifficulty.alpha = 0.00001;
		levelInfo.alpha = 0.00001;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<PauseItem>();
		visualMenuShit = new FlxTypedGroup<PauseItem>();
		//add(grpMenuShit);
		add(visualMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		startTweens();
	}

	function startTweens()
	{
		var time = 0.2;
		var add = 600;

		wall.x -= add;
		FlxTween.tween(wall, {x: wall.x + add}, time, {ease: FlxEase.quadOut});

		for (item in grpMenuShit) {
			item.x -= add;
			FlxTween.tween(item, {x: item.x + add}, time, {ease: FlxEase.quadOut});
		}
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (pauseMusic != null && pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var selectedDiff = diffMap[daSelected];
					var poop = Highscore.formatSong(name, selectedDiff);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = selectedDiff;
					MusicBeatState.resetState();
					if(FlxG.sound.music != null) {
						FlxG.sound.music.volume = 0;
					}
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					skipTimeTracker = null;

					if(skipTimeText != null)
					{
						skipTimeText.kill();
						remove(skipTimeText);
						skipTimeText.destroy();
					}
					skipTimeText = null;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
				case 'Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Exit":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new MainMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic = FlxDestroyUtil.destroy(pauseMusic);

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			//item.targetY = bullShit - curSelected;
			if(bullShit - curSelected == 0) {
				item.playAnim("selected");
				item.z = 1;
			} else {
				item.playAnim("idle");
				item.z = 0;
			}
			bullShit++;

			/*item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}*/
		}

		visualMenuShit.sort(byZ, FlxSort.ASCENDING);
	}

	public static inline function byZ(Order:Int, Obj1:PauseItem, Obj2:PauseItem):Int
	{
		return FlxSort.byValues(Order, Obj1.z, Obj2.z);
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			//var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			//item.isMenuItem = true;
			//item.targetY = i;
			var item = new PauseItem(0, 140 * i + 70);
			item.x = 0;

			var anim = menuItems[i].toLowerCase();

			item.frames = Paths.getSparrowAtlas('pause/' + anim);
			item.animation.addByPrefix('idle', anim + "0", 24);
			item.animation.addByPrefix('selected', anim + " white", 24);
			item.playAnim('idle');
			item.scale.set(0.666, 0.666);


			switch(anim) {
				case "resume":
					item.x += 100;
					item.y += -100;
					item.idleOffset.set(30, 35);
					//item.y -= 60;
					//item.y += -40;
				case "restart":
					item.scale.set(0.55, 0.55);
					item.x += 45;
					item.y += 5;
					item.idleOffset.set(30, 40);
				case "botplay":
					item.scale.set(0.58, 0.58);
					item.x += 75;
					item.y += 30;
					item.idleOffset.set(0, 20);
				case "exit":
					item.scale.set(0.58, 0.58);
					item.x += 265 - 5;
					item.y += -20;
					item.idleOffset.set(25, 10);
			}

			item.updateHitbox();

			grpMenuShit.add(item);
			visualMenuShit.add(item);

			/*if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxFixedText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}*/
		}
		curSelected = 0;
		changeSelection();
	}

	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}

class PauseItem extends FlxSprite {
	public var z:Int = 0;

	public var idleOffset = new FlxPoint();

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		antialiasing = ClientPrefs.globalAntialiasing;
		moves = false;
	}

	var isIdle = false;

	public function playAnim(name:String, force:Bool = false) {
		animation.play(name, force);

		isIdle = name == "idle";
	}

	public override function draw() {
		var oldX = x;
		var oldY = y;
		if(isIdle) {
			x += idleOffset.x;
			y += idleOffset.y;
		}
		super.draw();
		x = oldX;
		y = oldY;
	}
}