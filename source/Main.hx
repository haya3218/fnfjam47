package;

import openfl.display.SpreadMethod;
import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.events.MouseEvent;
import lime.app.Application;
import openfl.system.Capabilities;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import haxe.CallStack;
import haxe.io.Path;
import openfl.events.UncaughtErrorEvent;
#if sys
import sys.io.File;
import sys.FileSystem;
import sys.io.Process;
#end
import Discord.DiscordClient;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsVar:FPS;
	public static var initalWindowX:Int = 0;
	public static var initalWindowY:Int = 0;

	var game:FlxGame;

	private var perspectiveSprite:Sprite3D;
	private var sw:Int;
	private var sh:Int;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		sw = Lib.application.window.width;
		sh = Lib.application.window.height;
		#if sys
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		initalWindowX = Application.current.window.x;
		initalWindowY = Application.current.window.y;

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		var tempSprite:Sprite = new Sprite();
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(200, 100, Math.PI / 2, 0, 0);
		tempSprite.graphics.beginGradientFill(GradientType.LINEAR, [0x555555, 0xdddddd], [1, 1], [0, 255], matrix, SpreadMethod.PAD);
		tempSprite.graphics.drawRect(0, 0, 200, 100);

		perspectiveSprite = new Sprite3D(tempSprite);
		// addChild(perspectiveSprite);
		perspectiveSprite.x = sw / 2;
		perspectiveSprite.y = sh / 2;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, moveMouse);

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		if (fpsVar != null)
		{
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}

	#if sys
	public static function onCrash(e:UncaughtErrorEvent):Void
	{
		// thanks gedehari
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "./log/" + "NotFNF_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/haya3218/fnfjam47";

		if (!FileSystem.exists("./log/"))
			FileSystem.createDirectory("./log/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "pissEater";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (FileSystem.exists("./" + crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);

			#if linux
			crashDialoguePath = "./" + crashDialoguePath;
			#end
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			// I had to do this or the stupid CI won't build :distress:
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}

		DiscordClient.shutdownRichPresence();
		Sys.exit(1);
	}
	#end

	private function moveMouse(e:MouseEvent):Void
	{
		perspectiveSprite.rotX = Std.int(sh / 2 - mouseY);
		perspectiveSprite.rotY = Std.int(sw / 2 - mouseX);
	}
}
