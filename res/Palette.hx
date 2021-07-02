package res;

class Palette {
	var _colors:Array<Color>;

	public var colors(get, never):Array<Color>;

	function get_colors():Array<Color> {
		return _colors;
	}

	var _byLuminance:Array<Int>;

	public var byLuminance(get, never):Array<Int>;

	inline function get_byLuminance() {
		return _byLuminance;
	}

	public var brightestIndex(get, never):Int;

	inline function get_brightestIndex():Int
		return _byLuminance[_byLuminance.length - 1];

	public var darkestIndex(get, never):Int;

	inline function get_darkestIndex():Int
		return _byLuminance[0];

	public function getIndecies():Array<Int> {
		return [for (n in 0..._colors.length) n + 1];
	};

	public inline function rnd():Color {
		return _colors[Math.floor(Math.random() * _colors.length)];
	}

	/**
		1-based color index (0 = transparency)
	 */
	public inline function get(index:Int):Color {
		return _colors[index - 1];
	}

	public function new(rgbColors:Array<Int>) {
		this._colors = rgbColors.map(col -> Color.fromInt24(col));

		_byLuminance = getIndecies();
		_byLuminance.sort((idxa, idxb) -> {
			if (_colors[idxa].luminance == _colors[idxb].luminance)
				return 0;

			if (_colors[idxa].luminance > _colors[idxb].luminance)
				return 1;
			else
				return -1;
		});
	}
}
