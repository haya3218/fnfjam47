package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):Int = 0;

	public var eventName:String = '';
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var noteQuant:Int = -1;

	public var isRollNote:Bool = false;

	private function set_noteType(value:Int):Int
	{
		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 3: // Hurt note
					reloadNote('HURT');
					if (noteQuant > -1)
					{
						colorSwap.hue = 0;
						colorSwap.saturation = 0;
						colorSwap.brightness = 0;
					}

				default:
					if (noteQuant > -1)
					{
						colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
						colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
						colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;
					}
			}
			noteType = value;
		}
		return value;
	}

	var isPixel:Bool = false;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, isQuant:Bool = false,
			isRoll:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		isRollNote = isRoll;

		x += PlayState.STRUM_X + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if (!inEditor)
			this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if (!isQuant)
		{
			loadNormalAnims();
		}
		else
		{
			loadQuantAnims();
		}
	}

	function reloadNote(?prefix:String = '', ?suffix:String = '')
	{
		var skin:String = PlayState.SONG.arrowSkin;
		if (skin == null || skin.length < 1)
		{
			skin = 'NOTE_assets';
		}

		var animName:String = null;
		if (animation.curAnim != null)
		{
			animName = animation.curAnim.name;
		}

		var blahblah:String = prefix + skin + suffix;
		if (isPixel)
		{
			if (isSustainNote)
			{
				loadGraphic(Paths.image('weeb/pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				loadGraphic(Paths.image('weeb/pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			}
			else
			{
				loadGraphic(Paths.image('weeb/pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('weeb/pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			loadPixelNoteAnims();
		}
		else
		{
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
		}
		animation.play(animName, true);

		if (inEditor)
		{
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNormalAnims()
	{
		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/NOTE_assetsENDS'));
					width = width / 4;
					height = height / 2;
					loadGraphic(Paths.image('weeb/pixelUI/NOTE_assetsENDS'), true, Math.floor(width), Math.floor(height));
				}
				else
				{
					loadGraphic(Paths.image('weeb/pixelUI/NOTE_assets'));
					width = width / 4;
					height = height / 5;
					loadGraphic(Paths.image('weeb/pixelUI/NOTE_assets'), true, Math.floor(width), Math.floor(height));
				}
				loadPixelNoteAnims();

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				isPixel = true;

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');
				loadNoteAnims();
				antialiasing = ClientPrefs.globalAntialiasing;
		}

		if (noteData > -1)
		{
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			x += swagWidth * (noteData % 4);
			if (!isSustainNote)
			{ // Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null && !isRollNote)
		{
			// alpha = 0.6;
			if (ClientPrefs.downScroll)
				flipY = true;

			x += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		if (isRollNote && prevNote != null)
		{
			// alpha = 0.6;
			if (ClientPrefs.downScroll)
				flipY = true;

			x += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purplerollend');
				case 1:
					animation.play('bluerollend');
				case 2:
					animation.play('greenrollend');
				case 3:
					animation.play('redrollend');
			}

			updateHitbox();

			x -= width / 2;

			if (prevNote.isRollNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purpleroll');
					case 1:
						prevNote.animation.play('blueroll');
					case 2:
						prevNote.animation.play('greenroll');
					case 3:
						prevNote.animation.play('redroll');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * (43 / 52) * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		if (!isPixel && noteData > -1)
			reloadNote();
	}

	// taken from forever engine with a few minor tweaks to make it fucking work
	// thanks gedehari and yoshubs
	// https://github.com/Yoshubs/Forever-Engine/blob/master/source/gameFolder/gameObjects/Note.hx
	function loadQuantAnims()
	{
		// actually determine the quant of the note
		if (noteQuant == -1)
		{
			/*
				I have to credit like 3 different people for these LOL they were a hassle
				but its gede pixl and scarlett, thank you SO MUCH for baring with me
			 */
			final quantArray:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

			final beatTimeSeconds:Float = (60 / Conductor.bpm); // beat in seconds
			final beatTime:Float = beatTimeSeconds * 1000; // beat in milliseconds
			// assumed 4 beats per measure?
			final measureTime:Float = beatTime * 4;

			final smallestDeviation:Float = measureTime / quantArray[quantArray.length - 1];

			for (quant in 0...quantArray.length)
			{
				// please generate this ahead of time and put into array :)
				// I dont think I will im scared of those
				final quantTime = (measureTime / quantArray[quant]);
				if ((strumTime + smallestDeviation) % quantTime < smallestDeviation * 2)
				{
					// here it is, the quant, finally!
					noteQuant = quant;
					break;
				}
			}
		}

		// note quants
		// inherit last quant if hold note
		if (isSustainNote && prevNote != null)
			noteQuant = prevNote.noteQuant;

		if (noteData > -1)
		{
			// literally never talk to me again openfl
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		}
		// base quant notes
		if (!isSustainNote)
		{
			loadGraphic(Paths.image('quants/NOTE_quants'), true, 157, 157);

			animation.add('leftScroll', [0 + (noteQuant * 4)]);
			// LOL downscroll thats so funny to me
			animation.add('downScroll', [1 + (noteQuant * 4)]);
			animation.add('upScroll', [2 + (noteQuant * 4)]);
			animation.add('rightScroll', [3 + (noteQuant * 4)]);
		}
		else
		{
			// quant holds
			loadGraphic(Paths.image('quants/HOLD_quants'), true, 109, 52);
			animation.add('hold', [0 + (noteQuant * 4)]);
			animation.add('holdend', [1 + (noteQuant * 4)]);
			animation.add('rollhold', [2 + (noteQuant * 4)]);
			animation.add('rollend', [3 + (noteQuant * 4)]);
		}
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = ClientPrefs.globalAntialiasing;

		//
		if (!isSustainNote)
			animation.play(getArrowFromNumber(noteData) + 'Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null && !isRollNote)
		{
			animation.play('holdend');
			updateHitbox();

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * (43 / 52) * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		if (isRollNote && prevNote != null)
		{
			animation.play('rollend');
			scale.x = 1;
			updateHitbox();

			if (prevNote.isRollNote)
			{
				prevNote.animation.play('rollhold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * (43 / 52) * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	function loadNoteAnims()
	{
		if (noteType != 3)
		{
			if (noteQuant > -1)
			{
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
			}
			else
			{
				animation.addByPrefix('upScroll', 'green note');
				animation.addByPrefix('rightScroll', 'red note');
				animation.addByPrefix('downScroll', 'blue note');
				animation.addByPrefix('leftScroll', 'purple note');
			}
		}
		else
		{
			if (noteQuant > -1)
			{
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');
			}
			else
			{
				animation.addByPrefix('upScroll', 'green note');
				animation.addByPrefix('rightScroll', 'red note');
				animation.addByPrefix('downScroll', 'blue note');
				animation.addByPrefix('leftScroll', 'purple note');
			}
		}

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}

		if (noteType != 3)
		{
			if (isRollNote)
			{
				loadGraphic(Paths.image('quants/HOLD_quants'), true, 109, 52);
				animation.add('purpleroll', [10]);
				animation.add('purplerollend', [11]);
				animation.add('greenroll', [14]);
				animation.add('greenrollend', [15]);
				animation.add('redroll', [2]);
				animation.add('redrollend', [3]);
				animation.add('blueroll', [34]);
				animation.add('bluerollend', [35]);
			}
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims()
	{
		if (isSustainNote)
		{
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		}
		else if (isRollNote)
		{
			animation.add('purplerollend', [PURP_NOTE + 4]);
			animation.add('greenrollend', [GREEN_NOTE + 4]);
			animation.add('redrollend', [RED_NOTE + 4]);
			animation.add('bluerollend', [BLUE_NOTE + 4]);

			animation.add('purpleroll', [PURP_NOTE]);
			animation.add('greenroll', [GREEN_NOTE]);
			animation.add('redroll', [RED_NOTE]);
			animation.add('blueroll', [BLUE_NOTE]);
		}
		else
		{
			animation.add('greenScroll', [GREEN_NOTE + 4]);
			animation.add('redScroll', [RED_NOTE + 4]);
			animation.add('blueScroll', [BLUE_NOTE + 4]);
			animation.add('purpleScroll', [PURP_NOTE + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * (isRollNote ? 0.5 : 0.75)))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			FlxMath.lerp(alpha, 0, 0.17 * (FlxG.updateFramerate / 60));
		}
	}

	public static function getArrowFromNumber(numb:Int)
	{
		// yeah no I'm not writing the same shit 4 times over
		// take it or leave it my guy
		var stringSect:String = '';
		switch (numb)
		{
			case(0):
				stringSect = 'left';
			case(1):
				stringSect = 'down';
			case(2):
				stringSect = 'up';
			case(3):
				stringSect = 'right';
		}
		return stringSect;
		//
	}
}
