package;

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

class TextureWrapperShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header
	
	uniform float scrollX;
	uniform float scrollY;
	
	void main()
	{
		//take our displacement amount and modulo it by the size of the texture (1.0)
		vec2 coord = vec2(mod(openfl_TextureCoordv.x + scrollx, 1.0), mod(openfl_TextureCoordv.y + scrolly, 1.0));
		
		//sample this point
		vec4 sampled = texture2D(bitmap, coord);
		
		//apply to texture
		gl_FragColor = sampled;
	}')

    public function new() { 
        super(); 
    }
}

class TextureWrapper extends FlxBasic
{
    public var shader:TextureWrapperShader = new TextureWrapperShader();
    private var scrolledX:Float = 0;
    private var scrolledY:Float = 0;
    private var scrollByX:Float = 0;
    private var scrollByY:Float = 0;

	public function new(sprite:FlxSprite, scrollX:Float = 0, scrollY:Float = 0)
	{
        if (sprite != null)
            sprite.shader = shader;
        else
            active = false;
		scrollByX = scrollX;
		scrollByY = scrollY;
        super();
	}

    public function changeSpeed(scrollX:Float = 0, scrollY:Float = 0)
    {
        scrollByX = scrollX;
		scrollByY = scrollY;
    }

	override function update(elapsed:Float)
	{
        scrolledX += scrollByX;
        scrolledY += scrollByY;
		shader.scrollX.value = [scrolledX];
		shader.scrollY.value = [scrolledY];
        super.update(elapsed);
	}
}
