package res.devtools.tilemaps;

import res.devtools.tilesets.TilesetMenu;
import res.ui.Menu;
import res.ui.MenuScene;

class TilemapMenu extends MenuScene {
	public function new(res:Res) {
		var menu = new Menu(res.createDefaultTextmap([res.palette.brightestIndex]));

		menu.addItem('[ + Create ]', () -> {
			res.pushScene(TilesetMenu, (tileset:Tileset) -> {
				if (tileset != null) {
					res.pushScene(new TilemapSettings(res, tileset), (tilemap:Tilemap) -> {
						trace('!!!!');
						if (tilemap != null) {
							res.setScene(new TilemapEditor(res, tilemap));
						}
					});
				}
			});
		});

		for (name => tilemap in res.tilemaps) {
			menu.addItem('* ${name}', () -> {});
		}

		menu.addItem('[ ← Back ]', () -> {
			res.popScene();
		});

		super(res, menu);
	}
}