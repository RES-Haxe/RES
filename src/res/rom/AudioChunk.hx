package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.audio.AudioData;

class AudioChunk extends RomChunk {
	public function new(name, data) {
		super(AUDIO, name, data);
	}

	public function getAudio():AudioData {
		final input = new BytesInput(data);

		final channels = input.readByte();
		final rate = input.readUInt24();
		final bps = input.readByte();
		final dataLen = input.readUInt24();
		final data = Bytes.alloc(dataLen);
		input.readBytes(data, 0, dataLen);

		return new AudioData(name, channels, rate, bps, data);
	}
}