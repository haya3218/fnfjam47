package;

import openfl.system.Capabilities;
import lime.app.Application;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
#if sys
import sys.io.File;
#end

using StringTools;

class CoolUtil
{
	// [Difficulty name, Chart file suffix]
	public static var difficultyStuff:Array<Dynamic> = [['Hard', '-hard']];

	/**
	 * Gets the current difficulty
	 * @return 			Difficulty string
	 */
	public static function difficultyString():String
	{
		return difficultyStuff[PlayState.storyDifficulty][0].toUpperCase();
	}

	/**
	 * Like FlxMath.bound() but better
	 * @param value 	Value that you'd like to clamp
	 * @param min 		Mininum value to clamp to
	 * @param max 		Maximum value to clamp to
	 * @return Float	Clamped float
	 */
	public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		var newValue:Float = value;
		if (newValue < min)
			newValue = min;
		else if (newValue > max)
			newValue = max;
		return newValue;
	}

	/**
	 * Get contents from a file.
	 * @param path 		File path.
	 * @return 			The array of strings separated by \n.
	 */
	public static function coolTextFile(path:String):Array<String>
	{
		#if sys
		var daList:Array<String> = File.getContent(path).trim().split('\n');
		#else
		var daList:Array<String> = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	// uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		if (!Assets.cache.hasSound(Paths.sound(sound, library)))
		{
			FlxG.sound.cache(Paths.sound(sound, library));
		}
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site, "&"]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function fullScreen(bool:Bool = false)
	{
		// BORDERLESS FULLSCREEN COS NORMAL FULLSCREEN IS ASS
		if (bool)
		{
			// gets best screen res from monitor ig and sets coords to 0
			Application.current.window.x = 0;
			Application.current.window.y = 0;
			Application.current.window.width = Std.int(Capabilities.screenResolutionX);
			Application.current.window.height = Std.int(Capabilities.screenResolutionY);
		}
		else
		{
			// sets it back to what the window coords was when you started the game
			Application.current.window.x = Main.initalWindowX;
			Application.current.window.y = Main.initalWindowY;
			Application.current.window.width = FlxG.initialWidth;
			Application.current.window.height = FlxG.initialHeight;
			Application.current.window.x = Main.initalWindowX;
			Application.current.window.y = Main.initalWindowY;
		}
		Application.current.window.borderless = bool;
	}
}
