function onCreate()
	makeAnimatedLuaSprite('bg', 'halloween/BG', -800, -332);
	addAnimationByPrefix('bg', 'idle', 'bg0', 24, true);
	addAnimationByPrefix('bg', 'lighting', 'bg_lightning', 24, false);
	scaleObject('bg', 2, 2);
	addLuaSprite('bg', false)

	makeAnimatedLuaSprite('cassette', 'cd', 540, 588)
	addAnimationByPrefix('cassette', 'idle', 'boombox', 24, false);
	scaleObject('cassette', 1.4, 1.4);
	setProperty('cassette.flipX', true);
	addLuaSprite('cassette', false)

	setPropertyFromClass('GameOverSubstate', 'characterName', 'skarlet-spooky-dead');
end

function onGameOverStart()
	setProperty('camFollow.y', getProperty('camFollow.y') + 100);
end

local defaultNotePos = {}
local spin = 2

lightningStrikeBeat = 0;
lightningOffset = 8;

function lightningStrikeShit()
	playSound('thunder_'..getRandomInt(1, 2));
	objectPlayAnimation('bg', 'lighting');

	lightningStrikeBeat = curBeat;
	lightningOffset = getRandomInt(8, 24);

	--playAnim('boyfriend', 'scared', true);
	--playAnim('gf', 'scared', true);
end

function onSongStart()
for i = 0, 7 do
	defaultNotePos[i] = {
		getPropertyFromGroup('strumLineNotes', i, 'x'),
		getPropertyFromGroup('strumLineNotes', i, 'y')
	}
	end
end

function onUpdate(elapsed)
	if curStep >= 0 and curStep < 5000 then
		local songPos = getPropertyFromClass('Conductor', 'songPosition') / 1000 --How long it will take.
		setProperty("camHUD.angle", spin * math.sin(songPos))
	end

	if curStep == 5000 then 
		setProperty("camHUD.angle", 0)
	end

	if getProperty('bg.animation.curAnim.name') == 'lighting' and getProperty('bg.animation.curAnim.finished') then
		objectPlayAnimation('bg', 'idle');
	end
end

function onBeatHit()
	--10% chance per beat hit
	if getRandomBool(10) and curBeat > lightningStrikeBeat + lightningOffset then
		debugPrint('a')
		lightningStrikeShit();
	end

	objectPlayAnimation("cassette", "idle", true)
end