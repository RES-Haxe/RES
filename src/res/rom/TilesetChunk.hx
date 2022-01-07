package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.tiles.Tileset;

typedef TilesetJson = {
	size:Int
};

class TilesetChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(TILESET, name, data);
	}

	public function getTileset():Tileset {
		final bi = new BytesInput(data);

		final tileWidth = bi.readByte();
		final tileHeight = bi.readByte();
		final numTiles = bi.readInt32();

		final tileset = new Tileset(tileWidth, 16, 16);

		for (_ in 0...numTiles) {
			final tileData = Bytes.alloc(tileWidth * tileHeight);
			bi.readBytes(tileData, 0, tileData.length);
			tileset.createTile(tileData);
		}

		return tileset;
	}
}
