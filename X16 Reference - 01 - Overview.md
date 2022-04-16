## Chapter 1: Overview

The Commander X16 is a modern home computer in the philosophy of Commodore computers like the VIC-20 and the C64.

**Features:**

* 8-bit 65C02 CPU at 8 MHz
* 512 KB or 2 MB RAM
* 512 KB ROM
* VERA video controller
	* up to 640x480 resolution
	* 256 colors from a palette of 4096
	* 128 sprites
	* VGA, NTSC and RGB output
* three sound generators
	* Yamaha YM2151: 8 channels, FM synthesis
	* VERA PSG: 16 channels, 4 waveforms
	* VERA PCM: 48 kHz, 16 bit, stereo
* Connectivity:
	* PS/2 keyboard and mouse
	* 4 NES/SNES controllers
	* SD card
	* Commodore Serial Bus ("IEC")
	* many free GPIOs ("user port")

As a modern sibling of the line of Commodore home computers, the Commander X16 is reasonably compatible with computers of that line.

* Pure BASIC programs are fully backwards compatible with the VIC-20 and the C64.
* POKEs for video and audio are not compatible with any Commodore computer. (There are no VIC or SID chips, for example.)
* Pure machine language programs ($FF81+ KERNAL API) are compatible with Commodore computers.
