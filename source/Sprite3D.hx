package;

import flixel.FlxCamera;
import openfl.geom.Matrix;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.PerspectiveProjection;
import openfl.geom.Point;
import openfl.geom.Matrix3D;
import openfl.geom.Utils3D;
import openfl.geom.Vector3D;
import openfl.display.Stage;
import openfl.Lib;
import openfl.Vector;
import openfl.display.TriangleCulling;

/**
 * A 3D sprite. Nothing else. Just a fake 3D-esque sprite that rotates on all axis that 3D can support.
 * 
 * Source: http://blog.swishscripts.com/2018/05/17/perspective-distortion-using-openfl/
 */
class Sprite3D extends Sprite
{
	private var bmpData:BitmapData;
	private var pProjection:PerspectiveProjection;
	private var plane:Sprite = new Sprite();
	private var mat:Matrix3D = new Matrix3D();
	private var proj:Matrix3D;

	private var vertices:Vector<Float>;
	private var uvt:Vector<Float> = Vector.ofArray([0.0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0]);
	private var indices:Vector<Int> = Vector.ofArray([0, 1, 3, 1, 2, 3]);
	private var projectedPoints:Vector<Float>;

	public var rotX(get, set):Float;

	private var _rotX:Float = 0;

	public var rotY(get, set):Float;

	private var _rotY:Float = 0;

	public var dumb:Bool = false;

	private var _camera:FlxCamera;

	public function new(inputDisplayObject:DisplayObject, isDumb:Bool = false, matrix:Matrix = null, cam:FlxCamera = null)
	{
		super();

		dumb = isDumb;

		_camera = cam;

		if (_camera == null)
		{
			bmpData = new BitmapData(Math.ceil(inputDisplayObject.width), Math.ceil(inputDisplayObject.height), true, 0x55ff0000);
			bmpData.draw(inputDisplayObject, matrix, null, null, null, ClientPrefs.globalAntialiasing);

			vertices = Vector.ofArray([-Math.ceil(inputDisplayObject.width) / 2,
				-Math.ceil(inputDisplayObject.height) / 2, 0, Math.ceil(inputDisplayObject.width) / 2,
				-Math.ceil(inputDisplayObject.height) / 2, 0, Math.ceil(inputDisplayObject.width) / 2, Math.ceil(inputDisplayObject.height) / 2, 0,
				-Math.ceil(inputDisplayObject.width) / 2, Math.ceil(inputDisplayObject.height) / 2, 0.0
			]);
		}
		else
		{
			bmpData = new BitmapData(Math.ceil(_camera.width), Math.ceil(_camera.height), true, 0x00000000);
			bmpData.draw(_camera.flashSprite, _camera.flashSprite.transform.matrix, null, null, null, ClientPrefs.globalAntialiasing);

			vertices = Vector.ofArray([-Math.ceil(_camera.width) / 2,
				-Math.ceil(_camera.height) / 2, 0, Math.ceil(_camera.width) / 2,
				-Math.ceil(_camera.height) / 2, 0,
				Math.ceil(_camera.width) / 2, Math.ceil(_camera.height) / 2, 0,
				-Math.ceil(_camera.width) / 2, Math.ceil(_camera.height) / 2, 0.0
			]);
		}

		pProjection = new PerspectiveProjection();
		pProjection.fieldOfView = 55;
		proj = pProjection.toMatrix3D();
		addChild(plane);
		render();
	}

	public static function newCamera(cam:FlxCamera)
	{
		return new Sprite3D(cam.flashSprite, false, cam.flashSprite.transform.matrix, cam);
	}

	private function render():Void
	{
		// quite performant
		if (_camera != null)
		{
			bmpData = new BitmapData(Math.ceil(_camera.width), Math.ceil(_camera.height), true, 0x00000000);
			bmpData.draw(_camera.flashSprite, _camera.flashSprite.transform.matrix, null, null, null, ClientPrefs.globalAntialiasing);
		}
		mat.identity();
		mat.appendRotation(_rotY, Vector3D.Y_AXIS);
		mat.appendRotation(_rotX, Vector3D.X_AXIS);
		mat.appendTranslation(0, 0, 480.245531742791);
		mat.append(proj);

		projectedPoints = new Vector<Float>();
		Utils3D.projectVectors(mat, vertices, projectedPoints, uvt);
		plane.graphics.clear();
		plane.graphics.beginBitmapFill(bmpData, null, false, true);
		plane.graphics.drawTriangles(projectedPoints, indices, uvt, TriangleCulling.NONE);
		plane.graphics.endFill();
	}

	public function get_rotX():Float
	{
		return _rotX;
	}

	public function set_rotX(value:Float):Float
	{
		_rotX = value;
		render();
		return _rotX;
	}

	public function get_rotY():Float
	{
		return _rotY;
	}

	public function set_rotY(value:Float):Float
	{
		_rotY = value;
		render();
		return _rotY;
	}
}
