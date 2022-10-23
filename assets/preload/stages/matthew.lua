function onCreate()
	makeAnimatedLuaSprite('gym', 'gym', -600, -400);
	addAnimationByPrefix('gym', 'anim', 'bg bump', 24, false);
	scaleObject('gym', 1.45, 1.45);
	addLuaSprite('gym');
	
	makeAnimatedLuaSprite('bag', 'bag', 1000, -320);
	addAnimationByPrefix('bag', 'idle', 'bag idle', 24, true);
	addAnimationByPrefix('bag', 'hit', 'hit', 24, false);
	addAnimationByPrefix('bag', 'knockout', 'knockout', 24, false);
	scaleObject('bag', 1.1, 1.1);
	setProperty('bag.offset.x', 0);
	setProperty('bag.offset.y', 0);
	addLuaSprite('bag', true);

	setProperty('bag.origin.y', getProperty('bag.origin.y') - 300);
end

angleShit = 0;
originalAngle = 1.5;
curAngle = 1.5;

bagFrameTiming = 0;
bagSwingFramerate = 12;

function onUpdate(elapsed)
	animName = getProperty('bag.animation.curAnim.name');
	if animName ~= 'idle' and getProperty('bag.animation.curAnim.finished') then
		if animName == 'knockout' then
			setProperty('bag.visible', false);
		end
		objectPlayAnimation('bag', 'idle', true);
		setProperty('bag.offset.x', 0);
		setProperty('bag.offset.y', 0);
		animName = 'idle';
	end
	
	if animName == 'idle' then
		bagFrameTiming = bagFrameTiming + elapsed;
		while bagFrameTiming >= 1 / bagSwingFramerate do
			moveBag();
			bagFrameTiming = bagFrameTiming - (1 / bagSwingFramerate);
		end
	else
		setProperty('bag.angle', 0);
	end
end

--[[function onBeatHit()
	if curBeat % 4 == 1 then
		doHit();
	end
end]]

function moveBag()
	angleShit = angleShit + (5 * (24 / bagSwingFramerate));
	curAngle = lerp(curAngle, originalAngle, math.min(1, 0.05));
	if math.abs(curAngle - originalAngle) < 0.5 then
		curAngle = originalAngle;
	end
	setProperty('bag.angle', math.sin(angleShit * math.pi / 180) * curAngle)
end

function doHit()
	objectPlayAnimation('bag', 'hit', true);
	setProperty('bag.offset.x', 28);
	setProperty('bag.offset.y', 1);
	--curAngle = 5;
	angleShit = 0;
end

function lerp(a, b, t)
	return a + (b - a) * t
end