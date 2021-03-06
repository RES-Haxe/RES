package res.tiles;

import res.display.FrameBuffer;
import res.tools.MathTools.wrap;
import res.types.InterruptResult;

using Math;

class Tilemap {
	var map:Array<Array<TilePlace>> = [[]];

	public var tileset:Tileset;

	/** Number of Horizontal tiles **/
	public var hTiles:Int;

	/** Number of Vertical tiles **/
	public var vTiles:Int;

	public var colorMap:IndexMap;

	public var indexMap:Array<Int> = null;

	/**
		Width of the tilemap in pixels
	 */
	public var pixelWidth(get, never):Int;

	function get_pixelWidth():Int
		return hTiles * tileset.tileWidth;

	/**
		Height of the tilemap in pixels
	 */
	public var pixelHeight(get, never):Int;

	function get_pixelHeight():Int
		return vTiles * tileset.tileHeight;

	/** X screen coordinate of the left-top corner of the area to draw tilemap at */
	public var x:Int = 0;

	/** Y screen coordinate of the left-top corner of the area to draw tilemap at */
	public var y:Int = 0;

	/** Width of the area to draw tilemap at in pixels */
	public var width:Int;

	/** Height of the area to draw tilemap at in pixels */
	public var height:Int;

	public var scrollX:Float = 0;
	public var scrollY:Float = 0;

	public var wrapX:Bool = true;
	public var wrapY:Bool = true;

	/**
		Create a new tilemap based on another one

		Useful for creating tilemap instances from tilemaps in ROM
	 */
	public static function create(src:Tilemap, ?tileset:Tileset) {
		final tilemap = src.clone();
		tilemap.tileset = tileset != null ? tileset : tilemap.tileset;
		return tilemap;
	}

	public function new(?tileset:Tileset, hTiles:Int, vTiles:Int, ?width:Int = 100, ?height:Int = 100, ?colorMap:IndexMap) {
		this.tileset = tileset;
		this.width = width;
		this.height = height;
		this.colorMap = colorMap == null ? new IndexMap([]) : colorMap;

		resize(hTiles, vTiles);
	}

	public function clear() {
		for (line in 0...vTiles) {
			if (map[line] == null)
				map[line] = [for (_ in 0...hTiles) null];

			for (col in 0...hTiles) {
				empty(col, line);
			}
		}
	}

	public function clone():Tilemap {
		var cloned = new Tilemap(tileset, hTiles, vTiles, colorMap);
		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final t = get(col, line);

				cloned.set(col, line, t.index, t.flipX, t.flipY, t.rot90cw, t.data);
			}
		}

		return cloned;
	}

	public function fill(tileIndex:Int) {
		for (line in map)
			for (index in 0...line.length)
				line[index].index = tileIndex;
	}

	/**
		Set the size of the tilemap to fit the frame buffer
	 */
	public function fullscreen(fb:FrameBuffer) {
		x = y = 0;
		width = fb.width;
		height = fb.height;
	}

	inline public function inBounds(tileCol:Int, tileLine:Int):Bool {
		return (tileLine >= 0 && tileLine < vTiles && tileCol >= 0 && tileCol < hTiles);
	}

	public function get(tileCol:Int, tileLine:Int):Null<TilePlace> {
		if (inBounds(tileCol, tileLine))
			return map[tileLine][tileCol];
		else
			return null;
	}

	public function empty(tileCol:Int, tileLine:Int) {
		map[tileLine][tileCol] = null;
	}

	public function place(x:Int, y:Int, place:TilePlace) {
		if (inBounds(x, y)) {
			map[y][x] = place;
		} else
			throw 'Out of tile map bounds (col: $x, line: $y, size: $hTiles x $vTiles)';
	}

	/**
		Called before each line of the tilemap raster is being drawn

		@param screenLine Line number on the screen (frame buffer)
		@param tilemapLine Line number within the tilemap

		@return
			`DROP` - to drop the given line
			`HALT` - to stop drawing the tilemap altogether 
			`NONE` - to do nothing
	 */
	public dynamic function rasterInrpt(screenLine:Int, tilemapLine:Int):InterruptResult
		return NONE;

	public function set(tileCol:Int, tileLine:Int, tileIndex:Int, flipX:Bool = false, flipY:Bool = false, rot90cw:Bool = false, ?colorMap:IndexMap,
			?data:Dynamic) {
		place(tileCol, tileLine, {
			index: tileIndex,
			flipX: flipX,
			flipY: flipY,
			rot90cw: rot90cw,
			colorMap: colorMap,
			data: data
		});
	}

	/**
		Resize the tilemap

		@param newHTiles new horizontal amount of tiles
		@param newVTiles new vertical amount of tiles
	 */
	public function resize(newHTiles:Int, ?newVTiles:Int) {
		hTiles = newHTiles;
		vTiles = newVTiles == null ? vTiles : newVTiles;

		map.resize(vTiles);

		for (i in 0...map.length) {
			if (map[i] == null)
				map[i] = [for (_ in 0...hTiles) null];
		}
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
		final rfy = tile.rot90cw ? tileset.tileWidth - 1 - fx : fy;

		final ffx = tile.flipX ? tileset.tileWidth - 1 - rfx : rfx;
		final ffy = tile.flipY ? tileset.tileHeight - 1 - rfy : rfy;

		final tileIndex = indexMap == null ? tile.index : indexMap[tile.index];

		return tileset.getIndex(tileIndex, ffx, ffy);
	}

	/**
		Draw the tilemap

		@param frameBuffer FrameBuffer to render to
	 */
	public function render(frameBuffer:FrameBuffer) {
		if (tileset == null)
			return;

		for (line in 0...height) {
			final screenScanline = y + line;

			if (screenScanline >= 0 && screenScanline < frameBuffer.height) {
				switch rasterInrpt(screenScanline, line) {
					case DROP:
						continue;
					case HALT:
						break;
					case NONE:
				}

				final tileScanline:Int = wrapY ? (wrap(line + scrollY, pixelHeight)).floor() : (line + scrollY).floor();

				if (tileScanline < 0 || tileScanline >= pixelHeight)
					continue;

				var tileLineIndex:Int = (tileScanline / tileset.tileHeight).floor();

				if (tileLineIndex >= vTiles)
					tileLineIndex = tileLineIndex % vTiles;

				final inTileScanline:Int = tileScanline % tileset.tileHeight;

				for (col in 0...width) {
					final screenCol:Int = x + col;

					if (screenCol >= 0 && screenCol < frameBuffer.width) {
						final tileCol:Int = wrapX ? (wrap(col + scrollX, pixelWidth)).floor() : (col + scrollX).floor();

						if (tileCol < 0 || tileCol >= pixelWidth)
							continue;

						var tileColIndex:Int = (tileCol / tileset.tileWidth).floor();

						if (tileColIndex >= hTiles)
							tileColIndex = tileColIndex % hTiles;

						final inTileCol:Int = tileCol % tileset.tileWidth;

						final tilePlace = get(tileColIndex, tileLineIndex);

						if (tilePlace != null && tilePlace.index - 1 < tileset.numTiles) {
							final tileColorIndex:Int = readTilePixel(tileColIndex, tileLineIndex, inTileCol, inTileScanline);
							final paletteColorIndex:Int = tilePlace.colorMap != null ? tilePlace.colorMap.get(tileColorIndex) : colorMap == null ? tileColorIndex : colorMap[tileColorIndex];

							frameBuffer.set(screenCol, screenScanline, paletteColorIndex);
						}
					}
				}
			}
		}
	}
}
