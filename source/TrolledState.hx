package;

import haxe.Exception;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.text.FlxText;

class TrolledState extends MusicBeatState
{
	var sonic:FlxSprite;

	override function create()
	{
		super.create();

		sonic = new FlxSprite().loadGraphic(Paths.image('boo', 'shared'));
		sonic.setGraphicSize(FlxG.width, FlxG.height);
		sonic.updateHitbox();
		add(sonic);

		FlxG.sound.playMusic(Paths.sound('hill', 'shared'), 1, true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			throw new Exception("trolled");
		}
	}
}
