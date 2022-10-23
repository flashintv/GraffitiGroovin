function onCreate()
	addHaxeLibrary('Character');
	runHaxeCode([[
		game = PlayState.instance;
		pump = new Character(game.dad.x + 230, game.dad.y - 80, 'pump');
		game.insert(game.members.indexOf(game.dadGroup) - 1, pump);
	]]);
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	note = 'notes.members['..id..']';
	if noteType == 'Alt Character' or noteType == 'Both Characters' then
		anim = getProperty('singAnimations['..direction..']');
		runHaxeCode([[
			pump.playAnim(']]..anim..[[', true);
			pump.holdTimer = 0;
		]]);
	end
end

function onCountdownTick(counter)
	if counter % 2 == 0 then
		pumpDance();
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		pumpDance();
	end
end

function pumpDance()
	if not getProperty('inCutscene') then
		runHaxeCode([[
			pump.dance();
		]]);
	end
end