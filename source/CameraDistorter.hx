package;

import openfl.geom.Vector3D;
import openfl.geom.Matrix3D;
import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;

class CameraDistorter
{
	private var _camera:FlxCamera;

	public var mat3D:Matrix3D;

	public var skewX:Float = 0;
	public var skewY:Float = 0;
	public var rotX:Float = 0;
	public var rotY:Float = 0;

	public function new(camera:FlxCamera, _skewX:Float = 0, _skewY:Float = 0, _rotX:Float = 0, _rotY:Float = 0)
	{
		_camera = camera;
		skewX = _skewX;
		skewY = _skewY;
		rotX = _rotX;
		rotY = _rotY;

		mat3D = new Matrix3D();
		mat3D.identity();
		mat3D.appendTranslation(0, 0, 480.245531742791);
		mat3D.appendRotation(rotX, Vector3D.X_AXIS);
		mat3D.appendRotation(rotY, Vector3D.Y_AXIS);
		mat3D.rawData[0] = Math.cos(skewX);
		mat3D.rawData[5] = Math.cos(skewX);
		mat3D.rawData[1] = Math.sin(skewY);
		mat3D.rawData[4] = Math.sin(skewY);

		_camera.flashSprite.transform.matrix3D = mat3D;
	}

	public function set_skewX(value:Float)
	{
		mat3D.rawData[0] = 0;
		mat3D.rawData[5] = 0;
		mat3D.rawData[0] = Math.cos(value);
		mat3D.rawData[5] = Math.cos(value);

		_camera.flashSprite.transform.matrix3D = mat3D;
	}

	public function set_skewY(value:Float)
	{
		mat3D.rawData[1] = 0;
		mat3D.rawData[4] = 0;
		mat3D.rawData[1] = Math.sin(value);
		mat3D.rawData[4] = Math.sin(value);

		_camera.flashSprite.transform.matrix3D = mat3D;
	}

	public function set_rotX(value:Float)
	{
		mat3D.appendRotation(value, Vector3D.X_AXIS);

		_camera.flashSprite.transform.matrix3D = mat3D;
	}

	public function set_rotY(value:Float)
	{
		mat3D.appendRotation(value, Vector3D.Y_AXIS);

		_camera.flashSprite.transform.matrix3D = mat3D;
	}
}
