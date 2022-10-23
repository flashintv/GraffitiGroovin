function onCreate()
    makeLuaSprite('bg', 'basket/city_shit', -1100, -750)
    addLuaSprite('bg', false)
    makeLuaSprite('court', 'basket/floor', -1100, -750)
    addLuaSprite('court', false)

   	makeAnimatedLuaSprite('cassette', 'cd', 500, 600)
	addAnimationByPrefix('cassette', 'idle', 'boombox', 24, false);
	addLuaSprite('cassette', false)
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
    
    if curStep == 5000 then 
        setProperty("camHUD.angle", 0)
    end
end

function onBeatHit()
	playAnim("cassette", "idle", true)
end