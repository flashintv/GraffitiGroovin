function onCreate()
	setProperty("customPhillyInsert", -1)

	makeAnimatedLuaSprite('bg', 'BG_NEON', -483, -310)
	addAnimationByPrefix('bg','cool','BACK',24,true)
	objectPlayAnimation('bg','cool',false)
	scaleObject('bg', 1.2, 1.2)
	setScrollFactor('bg', 0.9, 0.9);
	addLuaSprite('bg', false)

	makeAnimatedLuaSprite('floor', 'FRONT2', -483, -310)
	addAnimationByPrefix('floor','dance','Floor front',24,true)
	objectPlayAnimation('floor','dance',false)
	scaleObject('floor', 1.2, 1.2)
	setScrollFactor('floor', 1, 1);
	addLuaSprite('floor', false)
	
	makeAnimatedLuaSprite('floor2', 'FRONT2', -483, -310+getProperty('floor.height')-1)
	addAnimationByPrefix('floor2','dance','Floor front',24,true)
	objectPlayAnimation('floor2','dance',false)
	scaleObject('floor2', 1.2, 1.2)
	setScrollFactor('floor2', 1, 1);
	setProperty('floor2.flipY', true)
	addLuaSprite('floor2', false)

   	makeAnimatedLuaSprite('boppers', 'CROWD', -550, 350)
	addAnimationByPrefix('boppers', 'idle', 'crowd')
	scaleObject('boppers', 1.2, 1.2)
	addLuaSprite('boppers', true)
end

function onBeatHit()
    objectPlayAnimation('boppers', 'idle', true)
end

local defaultNotePos = {}
local spin = 2
 
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
    
    if curStep >= 5000 then 
        setProperty("camHUD.angle", 0)
    end
end