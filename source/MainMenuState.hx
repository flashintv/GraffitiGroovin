package;

import flixel.math.FlxPoint;
import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<MenuItem>;
	var visualMenuItems:FlxTypedGroup<MenuItem>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'story',
		'freeplay',
		'options',
		'credits',
		'art'
	];

	var magenta:FlxSprite;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mmbg'));
		bg.scrollFactor.set(0.03, 0.03);
		bg.setGraphicSize(Std.int(bg.width * 0.72));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		add(new OoooYouLikeMen());

		var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mmbars'));
		bars.scrollFactor.set(0, 0.012);
		bars.setGraphicSize(Std.int(bars.width * 0.68));
		bars.updateHitbox();
		bars.screenCenter();
		bars.antialiasing = ClientPrefs.globalAntialiasing;
		add(bars);

		var skarlet:FlxSprite = new FlxSprite().loadGraphic(Paths.image('renders/skarlet'));
		skarlet.scrollFactor.set(0.07, 0.07);
		skarlet.setGraphicSize(Std.int(skarlet.width * 0.87));
		skarlet.updateHitbox();
		skarlet.x = FlxG.width - skarlet.width - 35;
		skarlet.y = FlxG.height - skarlet.height + 210;
		skarlet.antialiasing = ClientPrefs.globalAntialiasing;
		add(skarlet);

		camFollow = new FlxPoint(0, 0);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		//add(camFollow);
		//add(camFollowPos);

		/*magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set();
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);*/

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<MenuItem>();
		visualMenuItems = new FlxTypedGroup<MenuItem>();
		add(visualMenuItems);

		var scale:Float = 0.85;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 150 - (Math.max(4, 4) - 4) * 80;
			var menuItem:MenuItem = new MenuItem(0, (i * 155)  + offset - 110);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " black", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.moves = false;
			menuItems.add(menuItem);
			visualMenuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 0);
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			menuItem.screenCenter(X);
			menuItem.x -= menuItem.width / 2 + 120;

			switch(optionShit[i])
			{
				case 'story':
					menuItem.x += 20;
					menuItem.y -= 10;
				case 'options':
					menuItem.y += 50;
				case 'credits':
					menuItem.x += 40;
					menuItem.y -= 15;
				case 'art':
					menuItem.x += 720;
					menuItem.y -= 70;
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Graffiti Groovin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}


			/*if(FlxG.keys.justPressed.H) {
				MusicBeatState.switchState(new ArtGalleryState());
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
			}*/

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:MenuItem)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							var daChoice:String = optionShit[curSelected];
							if (daChoice == 'story')
							{
								FlxG.camera.fade(FlxColor.WHITE, 1, true);
							}

							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								switch (daChoice)
								{
									case 'story':
										//MusicBeatState.switchState(new StoryMenuState());
										loadWeek();
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									//case 'mods':
									//	MusicBeatState.switchState(new ModsMenuState());
									#end
									#if ACHIEVEMENTS_ALLOWED
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									#end
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'art':
										MusicBeatState.switchState(new ArtGalleryState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:MenuItem)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			spr.z = 0;

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}

				spr.z = 1;
				var mid = spr.getGraphicMidpoint();
				camFollow.set(mid.x, mid.y - add);
				mid.put();
				spr.centerOffsets();
			}
		});

		visualMenuItems.sort(byZ, FlxSort.ASCENDING);
	}

	public static inline function byZ(Order:Int, Obj1:MenuItem, Obj2:MenuItem):Int
	{
		return FlxSort.byValues(Order, Obj1.z, Obj2.z);
	}

	function loadWeek()
	{
		// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

		var songArray:Array<String> = [];
		var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).songs;

		for (i in 0...leWeek.length) {
			songArray.push(leWeek[i][0]);
		}

		// Nevermind that's stupid lmao
		PlayState.storyPlaylist = songArray;
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

		var diff:Int = Math.floor(Math.max(0, CoolUtil.defaultDifficulties.indexOf('Hard')));
		PlayState.storyDifficulty = diff;

		var diffic:String = CoolUtil.getDifficultyFilePath(diff);
		if(diffic == null) diffic = '';
		//trace('diff: $diff, diffic: $diffic');

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;

		LoadingState.loadAndSwitchState(new PlayState(), true);
		FreeplayState.destroyFreeplayVocals();
	}
}

class MenuItem extends FlxSprite {
	public var z:Int = 0;

	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		antialiasing = ClientPrefs.globalAntialiasing;
	}
}