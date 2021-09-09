package;

import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
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
	var soundInputs:Array<Int> = [];

	var so:Bool = false;

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
		soundList = sharedSounds;

		soundInputs = [];

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

		soundText.y -= 150;
		soundNum.y -= 150;

		FlxG.sound.music.stop();

		so = false;
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
			soundInputs.push(parsedNum);

			if (parsedNum == 1)
			{
				if (so)
				{
					var songLowercase:String = 'testnotwo';
					var poop:String = Highscore.formatSong(songLowercase, 0);

					PlayState.SONG = Song.loadFromJson(poop, songLowercase);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 0;
					PlayState.storyWeek = 0;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.camera.fade(FlxColor.WHITE, 0.31);
					FlxG.sound.play(Paths.sound('confirmMenu'));
					new FlxTimer().start(2, function(_)
					{
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
			}
			else
			{
				so = false;
			}
		}

		if (!so)
		{
			if (FlxG.keys.pressed.U && FlxG.keys.pressed.H && FlxG.keys.pressed.E && FlxG.keys.pressed.K && FlxG.keys.pressed.W)
			{
				so = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
		}
	}

	function soundSelect()
	{
		if (soundInputs == [12, 15, 12])
			MusicBeatState.switchState(new TrolledState());

		var prefix = "";
		if (Std.parseInt(soundNum.text) < 10)
			prefix = "0";
		var secondText = prefix + Std.parseInt(soundNum.text);
		soundNum.text = secondText;

		if (FlxG.keys.justPressed.RIGHT)
		{
			var secondText = Std.string(Std.parseInt(soundNum.text) + 1);
			soundNum.text = secondText;
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			var secondText = Std.string(Std.parseInt(soundNum.text) - 1);
			soundNum.text = secondText;
		}

		if (soundNum.text == "-1")
		{
			soundNum.text = Std.string(soundList.length - 1);
		}

		if (soundNum.text == "" + (soundList.length))
		{
			soundNum.text = "00";
		}
	}
}
