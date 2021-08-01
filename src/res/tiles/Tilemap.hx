package res.tiles;

import res.tools.MathTools.wrapi;

class Tilemap extends Renderable {
	var map:Array<Array<TilePlace>>;

	public final tileset:Tileset;

	public final hTiles:Int;
	public final vTiles:Int;

	public var onScanline:Int->Void;

	public var colorMap:Array<Int> = null;

	public var indexMap:Array<Int> = null;

	public var pixelWidth(get, never):Int;

	function get_pixelWidth():Int
		return hTiles * tileset.tileSize;

	public var pixelHeight(get, never):Int;

	function get_pixelHeight():Int
		return vTiles * tileset.tileSize;

	public var scrollX(default, set):Int = 0;

	function set_scrollX(val:Int):Int {
		return scrollX = wrapi(val, pixelWidth);
	}

	public var scrollY(default, set):Int = 0;

	function set_scrollY(val:Int):Int {
		return scrollY = wrapi(val, pixelHeight);
	}

	public function new(tileset:Tileset, hTiles:Int, vTiles:Int, ?colorMap:Array<Int>) {
		this.tileset = tileset;
		this.hTiles = hTiles;
		this.vTiles = vTiles;
		this.colorMap = colorMap;
		this.map = [for (_ in 0...vTiles) [for (_ in 0...hTiles)
			({
				index:0, rot90cw:false, flipY:false, flipX:false
			})]];
	}

	public function clear() {
		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				map[line][col].index = 0;
				map[line][col].flipX = false;
				map[line][col].flipY = false;
				map[line][col].rot90cw = false;
			}
		}
	}

	public function clone():Tilemap {
		var cloned = new Tilemap(tileset, hTiles, vTiles, colorMap);
		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final t = get(col, line);

				cloned.set(col, line, t.index, t.flipX, t.flipY, t.rot90cw);
			}
		}

		return cloned;
	}

	public function fill(tileIndex:Int) {
		for (line in map)
			for (index in 0...line.length)
				line[index].index = tileIndex;
	}

	inline function inBounds(tileCol:Int, tileLine:Int):Bool {
		return (tileLine >= 0 && tileLine < map.length && tileCol >= 0 && tileCol < map[tileLine].length);
	}

	public function get(tileCol:Int, tileLine:Int):Null<TilePlace> {
		if (inBounds(tileCol, tileLine))
			return map[tileLine][tileCol];
		else
			return null;
	}

	public function set(tileCol:Int, tileLine:Int, tileIndex:Int, flipX:Bool = false, flipY:Bool = false, rot90cw:Bool = false) {
		if (inBounds(tileCol, tileLine)) {
			map[tileLine][tileCol].index = tileIndex;
			map[tileLine][tileCol].flipX = flipX;
			map[tileLine][tileCol].flipY = flipY;
			map[tileLine][tileCol].rot90cw = rot90cw;
		} else
			throw 'Out of tile map bounds (col: $tileCol, line: $tileLine, size: $hTiles x $vTiles)';
	}

	/**
		Get pixel from a tile to render

		@param tx tile column
		@param ty tile row
		@param fx x pixel in tile without rotation nor flipping
		@param fy y pixel in tile without rotation nor flipping
	 */
	function readTilePixel(tx:Int, ty:Int, fx:Int, fy:Int):Int {
		final tile = map[ty][tx];
		final rfx = tile.rot90cw ? fy : fx;
		final rfy = tile.rot90cw ? tileset.tileSize - 1 - fx : fy;

		final ffx = tile.flipX ? tileset.tileSize - 1 - rfx : rfx;
		final ffy = tile.flipY ? tileset.tileSize - 1 - rfy : rfy;

		final tileIndex = indexMap == null ? tile.index - 1 : indexMap[tile.index - 1] - 1;

		return tileset.get(tileIndex).indecies.get(ffy * tileset.tileSize + ffx);
	}

	/**
		Render the tilemap

		@param frameBuffer Frame buffer to render at
	 */
	override public function render(frameBuffer:FrameBuffer) {
		for (screenScanline in 0...frameBuffer.frameHeight) {
			if (onScanline != null)
				onScanline(screenScanline);

			var tileScanline:Int = screenScanline + scrollY;
			var tileLineIndex:Int = Math.floor(tileScanline / tileset.tileSize);

			if (tileLineIndex >= map.length)
				tileLineIndex = tileLineIndex % map.length;

			final inTileScanline:Int = tileScanline % tileset.tileSize;

			for (screenCol in 0...frameBuffer.frameWidth) {
				var tileCol:Int = screenCol + scrollX;
				var tileColIndex:Int = Math.floor(tileCol / tileset.tileSize);

				if (tileColIndex >= map[tileLineIndex].length)
					tileColIndex = tileColIndex % map[tileLineIndex].length;

				final inTileCol:Int = tileCol % tileset.tileSize;

				final tilePlace = map[tileLineIndex][tileColIndex];

				if (tilePlace.index > 0 && tilePlace.index - 1 < tileset.numTiles) {
					final tileColorIndex:Int = readTilePixel(tileColIndex, tileLineIndex, inTileCol, inTileScanline);

					if (tileColorIndex != 0) {
						final paletteColorIndex:Int = colorMap == null ? tileColorIndex : colorMap[tileColorIndex - 1];

						frameBuffer.setIndex(screenCol, screenScanline, paletteColorIndex);
					}
				}
			}
		}
	}
}
