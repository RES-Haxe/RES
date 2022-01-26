package res.extra;

import res.display.FrameBuffer;
import res.timeline.Timeline;

using res.display.Sprite;

class Splash extends Scene {
	final scene:Scene;

	public function new(scene:Scene) {
		super();

		this.scene = scene;
	}

	override public function init() {
		var timeline = new Timeline();

		timeline.after(1, (_) -> {
			if (scene != null)
				res.setScene(scene, true);
		});

		updateList.push(timeline);
	}

	override function render(frameBuffer:FrameBuffer) {
		frameBuffer.clear(clearColorIndex);

		final sp = res.rom.sprites['res_logo'];

		frameBuffer.drawSprite(sp, Std.int((frameBuffer.width - sp.width) / 2), Std.int((frameBuffer.height - sp.height) / 2));
	}
}
