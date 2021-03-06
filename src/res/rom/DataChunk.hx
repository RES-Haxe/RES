package res.rom;

import haxe.io.Bytes;

class DataChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(DATA, name, data);
	}

	public function getBytes():Bytes {
		return data;
	}
}
