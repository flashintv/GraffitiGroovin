local amountOfSteps = 450
local signPass = {}

function onCreate()
	setProperty('customPhillyInsert', -1)

	addHaxeLibrary('BGSprite', '')
	addHaxeLibrary('FlxBackdrop', 'flixel.addons.display')
	addHaxeLibrary("VarTween", "flixel.tweens.misc")

	runHaxeCode([[
		var game = PlayState.instance;
		var position = game.members.indexOf(game.gfGroup)-1;

		var add = function(object){
			game.insert(position, object);
			position++;
		}


		//streetstyle
		var sky = new BGSprite('outside/sky', 'philly', -382, -404, 0.95, 0.95, ["sky"], true);
		sky.scale.set(1.15, 1.15);
		sky.updateHitbox();
		sky.antialiasing = ClientPrefs.globalAntialiasing;
		add(sky);

		var farbuildings = new FlxBackdrop(Paths.image('outside/far buildings', 'philly'), 1, 1, true, false);
		farbuildings.y = -504; 
		farbuildings.velocity.x -= 450;
		farbuildings.antialiasing = ClientPrefs.globalAntialiasing;
		add(farbuildings);

		var buildings = new FlxBackdrop(Paths.image('outside/buildings', 'philly'), 1, 1, true, false);
		buildings.x = -1137;
		buildings.y = -334;
		buildings.velocity.x -= 1650;
		buildings.antialiasing = ClientPrefs.globalAntialiasing;
		add(buildings);

		var darkbuildings = new FlxBackdrop(Paths.image('outside/buildings darker', 'philly'), 1, 1, true, false);
		darkbuildings.x = 500;
		darkbuildings.y = -250;
		darkbuildings.velocity.x -= 1850;
		darkbuildings.antialiasing = ClientPrefs.globalAntialiasing;
		add(darkbuildings);

		var stage_back = new BGSprite('stageback', 'shared', -100, 805, 1, 1);
		stage_back.antialiasing = ClientPrefs.globalAntialiasing;
		add(stage_back);

		var poles = new FlxBackdrop(Paths.image('outside/poles', 'philly'), 1, 1, true, false);
		poles.y = 444;
		poles.velocity.x -= 1950;
		poles.antialiasing = ClientPrefs.globalAntialiasing;
		add(poles);

		var tricky_ad = new BGSprite('outside/ad_tricky', 'philly', 3500, 234);
		tricky_ad.antialiasing = ClientPrefs.globalAntialiasing;
		add(tricky_ad);
		setVar("ad", tricky_ad);

		var train = new BGSprite('outside/train', 'philly', -343, 542, 1, 1);
		train.antialiasing = ClientPrefs.globalAntialiasing;
		add(train);


		//streetstyle
		var wallX = 343;
		var tunnelWall = new BGSprite('tunnel/walls', 'philly', wallX, -320, 1, 0.6);
		tunnelWall.active = true;
		tunnelWall.scale.set(1.1, 1.1);
		tunnelWall.updateHitbox();
		tunnelWall.velocity.x -= 9000;
		setVar("tunnelWall", tunnelWall);
		add(tunnelWall);
		tunnelWall.visible = false;
		
		var tunnelWall2 = new BGSprite('tunnel/walls', 'philly', wallX + tunnelWall.width - 2, -320, 1, 0.6);
		tunnelWall2.active = true;
		tunnelWall2.scale.set(1.1, 1.1);
		tunnelWall2.updateHitbox();
		tunnelWall2.velocity.x -= 9000;
		tunnelWall2.flipX = true;
		add(tunnelWall2);
		setVar("tunnelWall2", tunnelWall2);
		tunnelWall2.visible = false;

		var tunnelTrain = new BGSprite('tunnel/train shaded', 'philly', -343, 542, 1, 1);
		tunnelTrain.antialiasing = ClientPrefs.globalAntialiasing;
		setVar("tunnelTrain", tunnelTrain);
		add(tunnelTrain);
		tunnelTrain.visible = false;

		var tunnelTrans = new BGSprite('tunnel/wall', 'philly', wallX, -320, 0, 0);
		tunnelTrans.active = true;
		tunnelTrans.velocity.x -= 12000;
		game.add(tunnelTrans);
		setVar("tunnelTrans", tunnelTrans);
		tunnelTrans.visible = false;
	]])

	makeAnimatedLuaSprite('dropBg', 'tunnel/drop_bg', -900, -350);
	scaleObject('dropBg', 1.9, 1.9);
	addAnimationByPrefix('dropBg', 'idle', 'tunnel loop', 24, true);
	setScrollFactor('dropBg', 0.75, 0.75);
	setObjectOrder('dropBg', getObjectOrder('dadGroup')-1);
	setProperty('dropBg.visible', false);
end

function onUpdate(elapsed)
	runHaxeCode([[
		var tunnelWall = getVar("tunnelWall");
		var tunnelWall2 = getVar("tunnelWall2");
		if(tunnelWall.x < -tunnelWall.width)
		{
			tunnelWall.x = tunnelWall2.x + tunnelWall2.width - 2;
			setVar("tunnelWall", tunnelWall2);
			setVar("tunnelWall2", tunnelWall);
		}
	]]);

	if transitionback then
		runHaxeCode([[
			var tunnelWall = getVar("tunnelWall");
			var tunnelWall2 = getVar("tunnelWall2");
			var tunnelTrans = getVar("tunnelTrans");
			if (tunnelTrans.x <= -tunnelTrans.width)
			{
				tunnelTrans.visible = false;
			}
			else if (tunnelTrans.x < -200)
			{
				tunnelWall.visible = false;
				tunnelWall2.visible = false;
				getVar("tunnelTrain").visible = false;
				PlayState.instance.boyfriendGroup.visible = true;
				PlayState.instance.triggerEventNote('Change Character', 'boyfriend', PlayState.SONG.player1);
				PlayState.instance.triggerEventNote('Change Character', 'dad', PlayState.SONG.player2);
			}
		]]);

		if boyfriendName == 'bf-epic' and getProperty('boyfriendGroup.visible') then
			transitionback = false;
			onthedrop = false;
			ontunnel = false;
			setProperty('dropBg.visible', false);
		end
	elseif ontunnel then
		runHaxeCode([[
			var tunnelTrans = getVar("tunnelTrans");
			if(tunnelTrans.x < 200 && PlayState.instance.boyfriend.curCharacter != 'bf-graffiti')
			{
				PlayState.instance.triggerEventNote('Change Character', 'boyfriend', 'bf-graffiti');
				PlayState.instance.triggerEventNote('Change Character', 'dad', 'skarlet-graffiti');
				PlayState.instance.modchartSprites.get('dropBg').visible = false;
				PlayState.instance.boyfriendGroup.visible = true;
				getVar("tunnelTrain").visible = true;
			}
		]]);
	elseif onthedrop then
		runHaxeCode([[
			var tunnelTrans = getVar("tunnelTrans");
			if(tunnelTrans.x < 200 && PlayState.instance.dad.curCharacter != 'skarlet-neonsolo')
			{
				PlayState.instance.triggerEventNote('Change Character', 'dad', 'skarlet-neonsolo');
			}
		]]);

		if getProperty('dad.curCharacter') == 'skarlet-neonsolo' then
			setProperty('cameraSpeed', 2);
			setProperty('dropBg.visible', true);
			setProperty('boyfriendGroup.visible', false);

			dropCamera();
			setProperty('camFollowPos.x', getProperty('camFollow.x'));
			setProperty('camFollowPos.y', getProperty('camFollow.y'));
		end
	end
end

local MIN_TIME = 95
function onCreatePost()
	--songTime = getProperty("vocals.length")
	time = getRandomInt(10,amountOfSteps)
	table.insert(signPass, time)
	if getRandomBool(50) then
		adtime = getRandomInt(10,amountOfSteps)
		while (adtime-MIN_TIME <= time and adtime+MIN_TIME >= time) do
			adtime = getRandomInt(10,amountOfSteps)
			break
		end
		table.insert(signPass, adtime)
	end

	
end

--[[
	im required to do this because
	when i try to manually add a tween to modchartTweens in PlayState
	it doesn't and does work at the same time

	(it doesnt work ingame)
	(but works in hscript)
]]--

function onPause()
	runHaxeCode([[
		getVar("adTween").active = false;
	]])
end

function onResume()
	runHaxeCode([[
		getVar("adTween").active = true;
	]])
end

function onStepHit()
	for _,step in ipairs(signPass) do
		if curStep == step then
			runHaxeCode([[
				var ad = getVar("ad");
				setVar("adTween", FlxTween.tween(ad, {x:-2500}, 1, {onComplete:function(twn){
					ad.x = 3500;
				}}));
			]])
		end
	end
end

onthedrop = false;
ontunnel = false;
transitionback = false;
function onEvent(name, value1, value2)
	if name == 'Streetstyle Neon' then
		transitionback = false;
		setProperty('cameraSpeed', 1);
		val1 = math.floor(tonumber(value1));
		if val1 < 1 then
			if ontunnel or onthedrop then
				runHaxeCode([[
					getVar('tunnelTrans').x = FlxG.width;
				]])
				transitionback = true;
			end
		end
	
		if not transitionback then
			runHaxeCode([[
				getVar("tunnelWall").visible = false;
				getVar("tunnelWall2").visible = false;
				getVar("tunnelTrans").visible = false;
			]]);
			onthedrop = false;
		end
		ontunnel = false;

		if val1 == 1 then
			ontunnel = true;
			runHaxeCode([[
				var tunnelWall = getVar("tunnelWall");
				var tunnelWall2 = getVar("tunnelWall2");
				var tunnelTrans = getVar("tunnelTrans");
				tunnelWall.visible = true;
				tunnelWall2.visible = true;
				tunnelTrans.visible = true;

				var posX = 2600;
				tunnelTrans.x = FlxG.width;
				tunnelWall.x = posX;
				tunnelWall2.x = posX + tunnelWall.width - 2;
			]]);
		elseif val1 == 2 then
			onthedrop = true;
			runHaxeCode([[
				var tunnelTrans = getVar("tunnelTrans");
				tunnelTrans.visible = true;
				tunnelTrans.x = FlxG.width;
			]]);
		end
	end
end

function onMoveCamera(focus)
	if onthedrop then
		dropCamera();
	end
end

animCamOffset = {
	{-40, 0}, --left
	{0, -40}, --down
	{0, 40}, --up
	{40, 0} --right
};

function opponentNoteHit(id, direction, noteType, isSustainNote)
	onMoveCamera('dad');
end

function dropCamera()
	cameraSetTarget('dad');
	animName = getProperty('dad.animation.curAnim.name');
	anims = getProperty('singAnimations');

	animOffsetX = 0;
	animOffsetY = 0;

	for i = 1, #anims do
		intendedAnim = anims[i];
		if stringStartsWith(animName, intendedAnim) then
			
			setProperty('camFollow.x', getProperty('camFollow.x') + animCamOffset[i][1]);
			setProperty('camFollow.y', getProperty('camFollow.y') - animCamOffset[i][2]);
			return;
		end
	end
end