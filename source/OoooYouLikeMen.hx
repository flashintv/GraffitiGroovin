package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class OoooYouLikeMen extends FlxSpriteGroup
{
	public function new()
	{
		super(0, 0);

		for (i in 0...5)
		{
			var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgcircle'));
			spr.scale.set(2.25, 2.25);
			spr.updateHitbox();
			spr.screenCenter();
			spr.scrollFactor.set();
			spr.alpha = 0;
			spr.blend = ADD;
			spr.antialiasing = ClientPrefs.globalAntialiasing;
			spr.moves = false;
			add(spr);
		}
		scrollFactor.set();
	}

	private var circleShit:Float = 0;
	override function update(elapsed:Float)
	{
		circleShit += elapsed * 0.2;
		if (circleShit > 1) circleShit = 0;

		var i:Int = 1;
		for (spr in members)
		{
			var data:Float = circleShit + (0.2 * i);
			if (data > 1) data = data - 1;

			var scal:Float = 2.5 - 1.6 * data;
			spr.scale.set(scal, scal);
			spr.alpha = 0.25 * (1 - data);
			i++;
		}

		super.update(elapsed);
	}
}