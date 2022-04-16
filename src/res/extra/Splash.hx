package res.extra;

import haxe.io.BytesOutput;
import res.display.FrameBuffer;
import res.text.Font;
import res.tiles.Tilemap;
import res.tiles.Tileset;
import res.timeline.Timeline;
import res.tools.MathTools.wrap;

using Std;
using res.display.Painter;
using res.display.Sprite;

class Splash extends State {
	static final TIME:Int = 1;
	static final BAR_SIZE:Int = 8;

	final stateFn:Void->State;

	var font:Font;
	var scroll:Int = 0;
	var timeline = new Timeline();

	var bgMap:Tilemap;

	public function new(stateFn:Void->State) {
		super();
		this.stateFn = stateFn;
	}

	override public function init() {
		timeline.after(TIME, (_) -> {
			final state = stateFn();
			if (state != null)
				res.setState(state, true);
		});

		font = res.rom.fonts['num'];

		if (font == null)
			font = res.defaultFont;

		final tilesBytes = new BytesOutput();

		for (index in res.rom.palette.indecies) {
			for (_ in 0...BAR_SIZE)
				for (_ in 0...BAR_SIZE)
					tilesBytes.writeByte(index);
		}

		final tileset = new Tileset(BAR_SIZE, BAR_SIZE, tilesBytes.getBytes());

		bgMap = new Tilemap(tileset, res.rom.palette.numColors, 1, res.frameBuffer.width, res.frameBuffer.height);

		bgMap.scanlineInrpt = (screenLine, _) -> {
			bgMap.scrollX = -(scroll + Math.sin(screenLine / res.frameBuffer.height * (Math.PI * 2 * 2)) * 32);
			return NONE;
		};

		for (c in 0...res.rom.palette.indecies.length)
			bgMap.set(c, 0, c);
	}

	override function update(dt:Float) {
		timeline.update(dt);
	}

	override function render(frameBuffer:FrameBuffer) {
		frameBuffer.clear(clearColorIndex);

		bgMap.render(frameBuffer);

		final sp = res.rom.sprites['splash'];

		final bg = res.rom.palette.darkestIndex;

		frameBuffer.circle((frameBuffer.width / 2).int(), (frameBuffer.height / 2 + 2).int(), 25, bg, bg);

		frameBuffer.drawSprite(sp, Std.int((frameBuffer.width - sp.width) / 2), Std.int((frameBuffer.height - sp.height) / 2));

		if (font != null)
			font.drawPivot(frameBuffer, 'v${RES.VERSION}', Std.int(frameBuffer.width / 2), Std.int(frameBuffer.height / 2 + sp.height / 2) + 2, 0.5, 0);

		scroll = wrap(scroll + 1, res.rom.palette.numColors * BAR_SIZE);
	}
}
