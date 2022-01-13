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

	public static function drawSprite(frameBuffer:FrameBuffer, sprite:Sprite, ?x:Int = 0, ?y:Int = 0, ?width:Int, ?height:Int, ?frameIndex:Int = 0,
			?flipX:Bool = false, ?flipY:Bool = false, ?wrapping:Bool = true, ?colorMap:ColorMap) {
		final frame = sprite.frames[frameIndex];

		final lines:Int = height == null ? sprite.height : height;
		final cols:Int = width == null ? sprite.width : width;

		final fromX:Int = x;
		final fromY:Int = y;

		for (scanline in 0...lines) {
			if (!((!wrapping && (scanline < 0 || scanline >= frameBuffer.frameHeight)))) {
				for (col in 0...cols) {
					final spriteCol = wrapi(flipX ? sprite.width - 1 - col : col, sprite.width);
					final spriteLine = wrapi(flipY ? sprite.height - 1 - scanline : scanline, sprite.height);

					final sampleIndex:Int = frame.data.getxy(sprite.width, spriteCol, spriteLine);

					if (sampleIndex != 0) {
						final screenX:Int = wrapping ? wrapi(fromX + col, frameBuffer.frameWidth) : fromX + col;
						final screenY:Int = wrapping ? wrapi(fromY + scanline, frameBuffer.frameHeight) : fromY + scanline;

						if (wrapping
							|| (screenX >= 0 && screenY >= 0 && screenX < frameBuffer.frameWidth && screenY < frameBuffer.frameHeight)) {
							final colorIndex = colorMap == null ? sampleIndex : colorMap.get(sampleIndex);
							if (colorIndex != 0)
								frameBuffer.setIndex(screenX, screenY, colorIndex);
						}
					}
				}
			}
		}
	}
}
