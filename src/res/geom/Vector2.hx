package res.geom;

class Vector2 {
	public var x:Float;
	public var y:Float;

	public var xi(get, never):Int;

	inline function get_xi()
		return Std.int(x);

	public var yi(get, never):Int;

	inline function get_yi()
		return Std.int(y);

	public inline function new(?x:Float = 0, ?y:Float) {
		set(x, y);
	}

	public function clone():Vector2 {
		return new Vector2(x, y);
	}

	public static function from(xy:{x:Float, y:Float}):Vector2 {
		return new Vector2(xy.x, xy.y);
	}

	public static function fromi(xy:{x:Int, y:Int}):Vector2 {
		return new Vector2(xy.x, xy.y);
	}

	/**
		Sums two 2-component vectors

		@param a
		@param b
	 */
	public static function sum(a:{x:Float, y:Float}, b:{x:Float, y:Float}):{x:Float, y:Float} {
		return {x: a.x + b.x, y: a.y + b.y};
	}

	public static function arr(a:Array<Float>):{x:Float, y:Float} {
		return {
			x: a[0],
			y: a[1]
		};
	}

	public static function xy(?x:Float = 0, ?y:Float) {
		return new Vector2(x, y);
	}

	/**
		Create a Vector from a difference of two vectors (`b - a`)
	 */
	public static function diff(a:{x:Float, y:Float}, b:{x:Float, y:Float}) {
		return xy(b.x - a.x, b.y - a.y);
	}

	public function add(v:Vector2):Vector2 {
		return addxy(v.x, v.y);
	}

	public function addxy(x:Float, y:Float):Vector2 {
		this.x += x;
		this.y += y;
		return this;
	}

	public function length() {
		return Math.sqrt(length2());
	}

	public function length2() {
		return x * x + y * y;
	}

	public function mult(v:Vector2) {
		multxy(v.x, v.y);
		return this;
	}

	public function multxy(x:Float, y:Float):Vector2 {
		this.x *= x;
		this.y *= y;
		return this;
	}

	public function mults(scalar:Float):Vector2 {
		multxy(scalar, scalar);
		return this;
	}

	/**
		Set the length of the vector
	 */
	public function normalize(len:Float = 1):Vector2 {
		final l = length();
		if (l != 0)
			set(x / l * len, y / l * len);
		else
			set(0);

		return this;
	}

	public function set(x:Float, ?y:Float):Vector2 {
		this.x = x;
		this.y = y == null ? x : y;
		return this;
	}

	public function toRad():Float {
		return Math.atan2(y, x);
	}

	public function toString():String {
		return '($x, $y)';
	}
}
