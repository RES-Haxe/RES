# RES

RES is a minimalist pixel game engine written in Haxe. 

RES is a game engine where you actually control every pixel that is displayed on the screen.

Thanks to Haxe RES is super portable and can run on a huge number of platforms, including (but not limited to):

- Windows/Linux/MacOS
- Browser (HTML5)
- Mobile (Android/iOS)

## Table of Contents

- [RES](#res)
  - [Table of Contents](#table-of-contents)
  - [Talk is cheap. Show me the code.](#talk-is-cheap-show-me-the-code)
  - [Getting the Engine](#getting-the-engine)
    - [Installation](#installation)

## Talk is cheap. Show me the code.

The simplest program using RES would look like this:

```haxe
// Main.hx
import res.RES;
import res.bios.html5.BIOS;
import res.display.FrameBuffer;
import res.rom.Rom;

function main() {
	RES.boot(new BIOS(), {
		resolution: PIXELS(256, 240),
		rom: Rom.embed('rom'),
		main: (res) -> {
			return {
				update: (timeDelta:Float) -> {},
				render: (frameBuffer:FrameBuffer) -> {
					frameBuffer.clear(res.rom.palette.darkest);
					frameBuffer.set(128, 120, res.rom.palette.brightest);
				}
			}
		}
	});
}

```

Assuming the Haxe compiler and the `res` and `res-html5` libraries are installed (more on this in the [Installation](#installation) section, this program can be compiled to JavaScript with the following command:

```bash
haxe -main Main -lib res -lib res-html5 --js main.js
```

## Getting the Engine

TBD

### Installation

TBD