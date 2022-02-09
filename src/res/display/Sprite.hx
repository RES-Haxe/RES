package res.display;

import haxe.io.Bytes;
import res.tools.MathTools.wrapi;

using res.tools.BytesTools;

typedef SpriteAnimation = {
	var name:String;
	var from:Int;
	var to:Int;
	var direction:Int;
}

typedef DrawSpriteOptions = {
	var ?width:Int;
	var ?height:Int;
	var ?scrollX:Int;
	var ?scrollY:Int;
	var ?frame:Int;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?wrap:Bool;
};

class SpriteFrame {
	public final data:Bytes;
	public final duration:Int;

	public function new(data:Bytes, duration:Int) {
		this.data = data;
		this.duration = duration;
	}
}

class Sprite {
	public final name:String;

	public final frames:Array<SpriteFrame>;
	public final animations:Map<String, SpriteAnimation>;

	public final width:Int;
	public final height:Int;

	public function new(?name:String = null, width:Int, height:Int, ?frames:Array<SpriteFrame>, ?animations:Map<String, SpriteAnimation>) {
		this.name = name;
		this.width = width;
		this.height = height;
		this.frames = frames != null ? frames : [];
		this.animations = animations != null ? animations : [];

		for (frame in frames)
			if (frame.data.length != width * height)
				throw 'Invalid frame size';
	}

	public function addAnimation(name:String, from:Int, to:Int, direction:Int) {
		animations[name] = {
			name: name,
			from: from,
			to: to,
			direction: direction
		};
	}

	public function addFrame(data:Bytes, duration:Int) {
		if (data.length != width * height)
			throw 'Invalid frame size';

		frames.push(new SpriteFrame(data, duration));
	}

	public function createObject(?x:Float = 0, ?y:Float = 0, ?colorMap:ColorMap):SpriteObject {
		var obj = new SpriteObject(this, colorMap);
		obj.x = x;
		obj.y = y;
		return obj;
	}

	/**
		Draw a sprite

		@param frameBuffer
		@param sprite
		@param x
		@param y
		@param opts Draw sprite options:
		@param opts.width Width of the area to draw sprite to
		@param opts.height Height of the area to draw sprite to 
		@param opts.scrollX X Scrolling
		@param opts.scrollY Y Scrolling
		@param opts.frame Animation frame index
		@param opts.flipX
		@param opts.flipY
		@param opts.wrap
		@param colorMap
	 */
	public static function drawSprite(frameBuffer:FrameBuffer, sprite:Sprite, ?x:Int = 0, ?y:Int = 0, ?opts:DrawSpriteOptions, ?colorMap:ColorMap) {
		opts = opts == null ? {} : opts;

		final frameIndex = opts.frame == null ? 0 : opts.frame;

		final frame = sprite.frames[frameIndex];

		final lines:Int = opts.height == null ? sprite.height : opts.height;
		final cols:Int = opts.width == null ? sprite.width : opts.width;

		final flipX = opts.flipX == null ? false : opts.flipX;
		final flipY = opts.flipY == null ? false : opts.flipY;

		final wrap = opts.wrap == null ? false : opts.wrap;

		final scrollX = opts.scrollX == null ? 0 : opts.scrollX;
		final scrollY = opts.scrollY == null ? 0 : opts.scrollY;

		final fromX:Int = x;
		final fromY:Int = y;

		for (scanline in 0...lines) {
			if (!((!wrap && (scanline < 0 || scanline >= frameBuffer.height)))) {
				for (col in 0...cols) {
					final spriteCol = wrapi((flipX ? sprite.width - 1 - col : col) + scrollX, sprite.width);
					final spriteLine = wrapi((flipY ? sprite.height - 1 - scanline : scanline) + scrollY, sprite.height);

					final sampleIndex:Int = frame.data.getxy(sprite.width, spriteCol, spriteLine);

					if (sampleIndex != 0) {
						final screenX:Int = wrap ? wrapi(fromX + col, frameBuffer.width) : fromX + col;
						final screenY:Int = wrap ? wrapi(fromY + scanline, frameBuffer.height) : fromY + scanline;

						if (wrap || (screenX >= 0 && screenY >= 0 && screenX < frameBuffer.width && screenY < frameBuffer.height)) {
							final colorIndex = colorMap == null ? sampleIndex : colorMap.get(sampleIndex);
							frameBuffer.setIndex(screenX, screenY, colorIndex);
						}
					}
				}
			}
		}
	}

	/**
		Draw a sprite using a pivot.

		Pivot is a point in the sprite's space to use as the origing.

		Pivot is defined by `px` and `py` arguments

		For example is the pivot is `px=0.0, py=0.0` the the sprite will be drawn as usual as the origin will be at the left top of the sprite.
		If both `px` and `py` equal to `0.5` (default values) the the origin will be in the center of the sprite


		```
		0,0 +--------+ 1,0
			|        |
			| Sprite |
			|        |
		0,1 +--------+ 1,1
		```

		@param frameBuffer FrameBuffer to draw the sprite on
		@param sprite Sprite to draw
		@param x Origin X position
		@param y Origin Y position
		@param px Relative X position of the pivot in the sprite's space
		@param py Relative Y position of the pivot in the sprite's space
		@param opts Draw sprite options:
		@param opts.width Width of the area to draw sprite to
		@param opts.height Height of the area to draw sprite to 
		@param opts.scrollX X Scrolling
		@param opts.scrollY Y Scrolling
		@param opts.frame Animation frame index
		@param opts.flipX
		@param opts.flipY
		@param opts.wrap
		@param colorMap
	 */
	public static function drawSpritePivot(frameBuffer:FrameBuffer, sprite:Sprite, x:Int, y:Int, ?px:Float = 0.5, ?py:Float = 0.5, ?opts, ?colorMap)
		drawSprite(frameBuffer, sprite, Math.floor(x - sprite.width * px), Math.floor(y - sprite.height * py), opts, colorMap);
}
