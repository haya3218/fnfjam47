package;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;

class SelectableText extends FlxText
{
	public var yMult:Float = 70;
	public var targetY:Int = 0;

	override function update(elapsed:Float)
	{
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);

		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48), lerpVal);

		super.update(elapsed);
	}
}
