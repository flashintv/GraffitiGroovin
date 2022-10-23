function onCreate()
	addHaxeLibrary('Boyfriend');
	runHaxeCode([[
		game = PlayState.instance;
		nikku = new Boyfriend(game.boyfriend.x + 310, game.boyfriend.y + 175, 'nikku');
		game.insert(game.members.indexOf(game.boyfriendGroup) - 1, nikku);
	]]);

	makeLuaSprite('thunderFlash', nil, -200, -100);
	setScrollFactor('thunderFlash', 0, 0);
	makeGraphic('thunderFlash', screenWidth * 1.2, screenHeight * 1.2, 'FFFFFF');
	setBlendMode('thunderFlash', 'ADD'); --this works *kind of* like photoshop's blend modes
	addLuaSprite('thunderFlash', true);
	setProperty('thunderFlash.alpha', 0);

	-- PRECACHE SOUNDS TO PREVENT STUTTERS
	precacheSound('thunder_1');
	precacheSound('thunder_2');
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	note = 'notes.members['..id..']';
	if noteType == 'Alt Character' or noteType == 'Both Characters' then
		anim = getProperty('singAnimations['..direction..']');
		runHaxeCode([[
			nikku.playAnim(']]..anim..[[', true);
			nikku.holdTimer = 0;
		]]);
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
	note = 'notes.members['..id..']';
	if noteType == 'Alt Character' or noteType == 'Both Characters' then
		anim = getProperty('singAnimations['..direction..']')..'miss';
		runHaxeCode([[
			nikku.playAnim(']]..anim..[[', true);
			nikku.holdTimer = 0;
		]]);
	end
end

function onCountdownTick(counter)
	nikkuDance();
end

function onBeatHit()
	nikkuDance();
end

function nikkuDance()
	if not getProperty('inCutscene') then
		isHoldingKeys = false;

		runHaxeCode([[
			isHoldingKeys = (game.controls.NOTE_LEFT || game.controls.NOTE_RIGHT || game.controls.NOTE_UP || game.controls.NOTE_DOWN);
			if (!StringTools.startsWith(nikku.animation.curAnim.name, 'sing') ||
				(nikku.holdTimer > Conductor.stepCrochet * 0.0011 * nikku.singDuration &&
				StringTools.startsWith(nikku.animation.curAnim.name, 'sing') && !isHoldingKeys &&
				!StringTools.endsWith(nikku.animation.curAnim.name, 'miss')))
			{
				nikku.dance();
			}
		]]);
	end
end

function onUpdatePost(elapsed)
	runHaxeCode([[
		if (StringTools.startsWith(nikku.animation.curAnim.name, 'sing'))
		{
			nikku.holdTimer += ]]..elapsed..[[;
			isHoldingKeys = (game.controls.NOTE_LEFT || game.controls.NOTE_RIGHT || game.controls.NOTE_UP || game.controls.NOTE_DOWN);
			if(nikku.holdTimer > Conductor.stepCrochet * 0.0011 * nikku.singDuration &&
			StringTools.startsWith(nikku.animation.curAnim.name, 'sing') && !StringTools.endsWith(nikku.animation.curAnim.name, 'miss') && !isHoldingKeys)
			{
				nikku.dance();
			}
		}
		else
		{
			nikku.holdTimer = 0;
		}

		if (nikku.animation.curAnim.finished && StringTools.endsWith(nikku.animation.curAnim.name, 'miss'))
		{
			nikku.dance();
		}
	]])
end