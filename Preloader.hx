package;

import flixel.system.FlxBasePreloader;
import openfl.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.Lib;
import flixel.FlxG;

@:bitmap("art/load.png") class LogoImage extends BitmapData
{
}

class Preloader extends FlxBasePreloader
{
	public function new(MinDisplayTime:Float = 1, ?AllowedURLs:Array<String>)
	{
		super(MinDisplayTime, AllowedURLs);
	}

	var logo:Sprite;

	override function create():Void
	{
		this._width = Lib.current.stage.stageWidth;
		this._height = Lib.current.stage.stageHeight;
		Lib.current.stage.color = null;

		var ratio:Float = this._width / 2560; // This allows us to scale assets depending on the size of the screen.

		logo = new Sprite();
		logo.addChild(new Bitmap(new LogoImage(0, 0))); // Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
		logo.scaleX = logo.scaleY = ratio;
		logo.x = ((this._width) / 2) - ((logo.width) / 2);
		logo.y = (this._height / 2) - ((logo.height) / 2);
		addChild(logo); // Adds the graphic to the NMEPreloader's buffer.

		super.create();
	}

	override function update(Percent:Float):Void
	{
		super.update(Percent);
	}
}
