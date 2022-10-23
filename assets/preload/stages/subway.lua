function onCreate()
	makeLuaSprite('bg', 'BG', -483, -310)
	scaleObject('bg', 1.2, 1.2)
	setScrollFactor('bg', 0.9, 0.9);
	addLuaSprite('bg', false)

	makeLuaSprite('floor', 'FRONT', -483, -310)
	scaleObject('floor', 1.2, 1.2)
	setScrollFactor('floor', 1, 1);
	addLuaSprite('floor', false)
	
	makeLuaSprite('floor2', 'FRONT', -483, -310+getProperty('floor.height')-1)
	scaleObject('floor2', 1.2, 1.2)
	setScrollFactor('floor2', 1, 1);
	setProperty('floor2.flipY', true)
	addLuaSprite('floor2', false)
	
	close()
end