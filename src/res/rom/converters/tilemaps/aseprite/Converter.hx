package res.rom.converters.tilemaps.aseprite;

import ase.chunks.CelChunk;
import ase.types.ChunkType;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import res.rom.converters.tilesets.aseprite.Converter.createTilesetChunk;
import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var chunks:Array<RomChunk> = [];

	public static function createChunks(bytes:Bytes, name:String):Array<RomChunk> {
		final result:Array<RomChunk> = [];

		final aseSprite = ase.Ase.fromBytes(bytes);

		final aseTilesetChunks:Array<ase.chunks.TilesetChunk> = cast aseSprite.firstFrame.chunkTypes[ChunkType.TILESET];
		final hasTileset = aseTilesetChunks != null && aseTilesetChunks.length != 0;

		if (hasTileset) {
			final createdTilesets:Map<Int, TilesetChunk> = [];

			for (layerIndex => layer in aseSprite.layers) {
				if (layer.chunk.layerType == Tilemap) {
					final celChunk:CelChunk = aseSprite.frames[0].cel(layerIndex).chunk;

					if (celChunk.celType == CompressedTilemap) {
						final tilemapName = '${name}_${layer.name}';

						if (!createdTilesets.exists(layer.chunk.tilesetIndex)) {
							final aseChunk = (() -> {
								for (chunk in aseTilesetChunks) {
									if (chunk.id == layer.chunk.tilesetIndex)
										return chunk;
								}

								return null;
							})();

							final newTilesetChunk = createTilesetChunk(tilemapName, aseChunk);
							createdTilesets[layer.chunk.tilesetIndex] = newTilesetChunk;
							result.push(newTilesetChunk);
							newTilesetChunk;
						}

						final bo = new BytesOutput();
						bo.writeByte(tilemapName.length);
						bo.writeString(tilemapName);
						bo.writeInt32(celChunk.width);
						bo.writeInt32(celChunk.height);

						final inp = new BytesInput(celChunk.tilemapData);

						for (_ in 0...celChunk.height) {
							for (_ in 0...celChunk.width) {
								final tileData = inp.readInt32();

								final tileId = tileData & celChunk.bitmaskTileId;

								bo.writeUInt16(tileId);
								bo.writeByte(tileData & celChunk.bitmaskXFlip); // flipX
								bo.writeByte(tileData & celChunk.bitmaskYFlip); // flipY
								bo.writeByte(tileData & celChunk.bitmask90CWRotation); // rot90cw
							}
						}

						result.push(new TilemapChunk(tilemapName, bo.getBytes()));
					}
				}
			}
		} else
			trace('No tilesets in $name');

		return result;
	}

	override function process(fileName:String, palette:Palette) {
		final bytes = File.getBytes(fileName);

		chunks = createChunks(bytes, makeName(fileName));

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return chunks;
	}
}
