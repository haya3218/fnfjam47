package;

import flixel.util.FlxColor;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.math.FlxPoint;
import sys.FileSystem;
import haxe.Exception;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.text.FlxText;

using StringTools;

class SmthState extends MusicBeatState
{
	var sonic:FlxSprite;
	var soundList:Array<String> = [];
	var soundNum:FlxText;

	override function create()
	{
		super.create();

		sonic = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		// sonic.setGraphicSize(FlxG.width, FlxG.height);
		// sonic.updateHitbox();
		add(sonic);

		// FlxG.sound.playMusic(Paths.sound('hill', 'shared'), 1, true);

		// put in sounds in soundList array
		soundList = FileSystem.readDirectory('assets/sounds/');
		var sharedSounds = FileSystem.readDirectory('assets/shared/sounds/');
		soundList = soundList.concat(sharedSounds);

		var soundText = new FlxText().setFormat(Paths.font("cd.otf"), 32, FlxColor.fromRGB(0, 163, 255), CENTER);
		soundText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 5);
		soundText.screenCenter(XY);
		soundText.text = "SOUND TEST";
		// soundText.y += 70;
		soundText.x -= soundText.width / 2;
		add(soundText);

		// var numbers:String = "0123456789*";
		// var font = FlxBitmapFont.fromMonospace('assets/fonts/soundtestfont.png', numbers, FlxPoint.get(8, 8), null, FlxPoint.get(2, 0));
		soundNum = new FlxText().setFormat(Paths.font("soundtest.otf"), 32, FlxColor.WHITE, CENTER);
		soundNum.screenCenter(XY);
		soundNum.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 5);
		soundNum.text = "00";
		soundNum.y += 70;
		soundNum.x -= soundNum.width / 2;
		add(soundNum);

		FlxG.sound.music.stop();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		soundSelect();

		if (controls.BACK)
		{
			MusicBeatState.switchState(new FreeplayState());
		}

		if (controls.ACCEPT)
		{
			var parsedNum:Int = Std.parseInt(soundNum.text);
			FlxG.sound.playMusic(Paths.sound(soundList[parsedNum].replace('.ogg', ''), 'shared'), 1, false);
		}
	}

	function soundSelect()
	{
		var prefix = "";
		if (Std.parseInt(soundNum.text) < 10)
			prefix = "0";
		var secondText = prefix + Std.parseInt(soundNum.text);
		soundNum.text = secondText;

		if (FlxG.keys.justPressed.RIGHT)
		{
			var prefix = "";
			if (Std.parseInt(soundNum.text) < 10)
				prefix = "0";
			var secondText = prefix + (Std.parseInt(soundNum.text) + 1);
			soundNum.text = secondText;
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			var prefix = "";
			if (Std.parseInt(soundNum.text) < 10)
				prefix = "0";
			var secondText = prefix + (Std.parseInt(soundNum.text) - 1);
			soundNum.text = secondText;
		}

		if (soundNum.text == "0-1")
		{
			soundNum.text = Std.string(soundList.length);
		}

		if (soundNum.text == "" + (soundList.length))
		{
			soundNum.text = "00";
		}
	}
}
