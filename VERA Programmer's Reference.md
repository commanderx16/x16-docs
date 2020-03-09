# VERA Programmer's Reference

Version 0.9

*Author: Frank van den Hoef*

**This is preliminary documentation and the specification can still change at any point.**

This document describes the **V**ersatile **E**mbedded **R**etro **A**dapter or VERA. The VERA consists of:
- Video generator featuring:
  - Multiple output formats (VGA, NTSC Composite, NTSC S-Video, RGB video) at a fixed resolution of 640x480@60Hz
  - Support for 2 layers, both supporting either tile or bitmap mode.
  - Support for up to 128 sprites.
  - Embedded video RAM of 128kB.
  - Palette with 256 colors selected from a total range of 4096 colors.
- 16-channel Programmable Sound Generator with multiple waveforms (Pulse, Sawtooth, Triangle, Noise)
- High quality PCM audio playback from an 4kB FIFO buffer featuring up to 48kHz 16-bit stereo sound.
- SPI controller for SecureDigital storage.


# Registers

<table>
	<tr>
		<th>Addr</th>
		<th>Name</th>
		<th>Bit&nbsp;7</th>
		<th>Bit&nbsp;6</th>
		<th>Bit&nbsp;5 </th>
		<th>Bit&nbsp;4</th>
		<th>Bit&nbsp;3 </th>
		<th>Bit&nbsp;2</th>
		<th>Bit&nbsp;1 </th>
		<th>Bit&nbsp;0</th>
	</tr>
	<tr>
		<td>$9F20</td>
		<td>ADDRx_L (x=ADDRSEL)</td>
		<td colspan="8" align="center">VRAM Address (7:0)</td>
	</tr>
	<tr>
		<td>$9F21</td>
		<td>ADDRx_M (x=ADDRSEL)</td>
		<td colspan="8" align="center">VRAM Address (15:8)</td>
	</tr>
	<tr>
		<td>$9F22</td>
		<td>ADDRx_H (x=ADDRSEL)</td>
		<td colspan="4" align="center">Address Increment</td>
		<td colspan="1" align="center">DECR</td>
		<td colspan="2" align="center">-</td>
		<td colspan="1" align="center">VRAM Address (16)</td>
	</tr>
	<tr>
		<td>$9F23</td>
		<td>DATA0</td>
		<td colspan="8" align="center">VRAM Data port 0 (read/write)</td>
	</tr>
	<tr>
		<td>$9F24</td>
		<td>DATA1</td>
		<td colspan="8" align="center">VRAM Data port 1 (write only)</td>
	</tr>
	<tr>
		<td>$9F25</td>
		<td>CTRL</td>
		<td colspan="1" align="center">Reset</td>
		<td colspan="5" align="center">-</td>
		<td colspan="1" align="center">DCSEL</td>
		<td colspan="1" align="center">ADDRSEL</td>
	</tr>
	<tr>
		<td>$9F26</td>
		<td>IEN</td>
		<td colspan="1" align="center">IRQ line (8)</td>
		<td colspan="3" align="center">-</td>
		<td colspan="1" align="center">AFLOW</td>
		<td colspan="1" align="center">SPRCOL</td>
		<td colspan="1" align="center">LINE</td>
		<td colspan="1" align="center">VSYNC</td>
	</tr>
	<tr>
		<td>$9F27</td>
		<td>ISR</td>
		<td colspan="4" align="center">Sprite collissions</td>
		<td colspan="1" align="center">AFLOW</td>
		<td colspan="1" align="center">SPRCOL</td>
		<td colspan="1" align="center">LINE</td>
		<td colspan="1" align="center">VSYNC</td>
	</tr>
	<tr>
		<td>$9F28</td>
		<td>IRQLINE_L</td>
		<td colspan="8" align="center">IRQ line (7:0)</td>
	</tr>
	<tr>
		<td>$9F29</td>
		<td>DC_VIDEO (DCSEL=0)</td>
		<td colspan="1" align="center">Current Field</td>
		<td colspan="1" align="center">Sprites Enable</td>
		<td colspan="1" align="center">Layer1 Enable</td>
		<td colspan="1" align="center">Layer0 Enable</td>
		<td colspan="1" align="center">-</td>
		<td colspan="1" align="center">Chroma Disable</td>
		<td colspan="2" align="center">Output Mode</td>
	</tr>
	<tr>
		<td>$9F2A</td>
		<td>DC_HSCALE (DCSEL=0)</td>
		<td colspan="8" align="center">Active Display H-Scale</td>
	</tr>
	<tr>
		<td>$9F2B</td>
		<td>DC_VSCALE (DCSEL=0)</td>
		<td colspan="8" align="center">Active Display V-Scale</td>
	</tr>
	<tr>
		<td>$9F2C</td>
		<td>DC_BORDER (DCSEL=0)</td>
		<td colspan="8" align="center">Border Color</td>
	</tr>
	<tr>
		<td>$9F29</td>
		<td>DC_HSTART (DCSEL=1)</td>
		<td colspan="8" align="center">Active Display H-Start (9:2)</td>
	</tr>
	<tr>
		<td>$9F2A</td>
		<td>DC_HSTOP (DCSEL=1)</td>
		<td colspan="8" align="center">Active Display H-Stop (9:2)</td>
	</tr>
	<tr>
		<td>$9F2B</td>
		<td>DC_VSTART (DCSEL=1)</td>
		<td colspan="8" align="center">Active Display V-Start (8:1)</td>
	</tr>
	<tr>
		<td>$9F2C</td>
		<td>DC_VSTOP (DCSEL=1)</td>
		<td colspan="8" align="center">Active Display V-Stop (8:1)</td>
	</tr>
	<tr>
		<td>$9F2D</td>
		<td>L0_CONFIG</td>
		<td colspan="2" align="center">Map Height</td>
		<td colspan="2" align="center">Map Width</td>
		<td colspan="1" align="center">T256C</td>
		<td colspan="1" align="center">Bitmap Mode</td>
		<td colspan="2" align="center">Color Depth</td>
	</tr>
	<tr>
		<td>$9F2E</td>
		<td>L0_MAPBASE</td>
		<td colspan="8" align="center">Map Base Address (16:9)</td>
	</tr>
	<tr>
		<td>$9F2F</td>
		<td>L0_TILEBASE</td>
		<td colspan="6" align="center">Tile Base Address (16:11)</td>
		<td colspan="1" align="center">Tile Height</td>
		<td colspan="1" align="center">Tile Width</td>
	</tr>
	<tr>
		<td>$9F30</td>
		<td>L0_HSCROLL_L</td>
		<td colspan="8" align="center">H-Scroll (7:0)</td>
	</tr>
	<tr>
		<td>$9F31</td>
		<td>L0_HSCROLL_H</td>
		<td colspan="4" align="center">-</td>
		<td colspan="8" align="center">H-Scroll (11:8)</td>
	</tr>
	<tr>
		<td>$9F32</td>
		<td>L0_VSCROLL_L</td>
		<td colspan="8" align="center">V-Scroll (7:0)</td>
	</tr>
	<tr>
		<td>$9F33</td>
		<td>L0_VSCROLL_H</td>
		<td colspan="4" align="center">-</td>
		<td colspan="8" align="center">V-Scroll (11:8)</td>
	</tr>
	<tr>
		<td>$9F34</td>
		<td>L1_CONFIG</td>
		<td colspan="2" align="center">Map Height</td>
		<td colspan="2" align="center">Map Width</td>
		<td colspan="1" align="center">T256C</td>
		<td colspan="1" align="center">Bitmap Mode</td>
		<td colspan="2" align="center">Color Depth</td>
	</tr>
	<tr>
		<td>$9F35</td>
		<td>L1_MAPBASE</td>
		<td colspan="8" align="center">Map Base Address (16:9)</td>
	</tr>
	<tr>
		<td>$9F36</td>
		<td>L1_TILEBASE</td>
		<td colspan="6" align="center">Tile Base Address (16:11)</td>
		<td colspan="1" align="center">Tile Height</td>
		<td colspan="1" align="center">Tile Width</td>
	</tr>
	<tr>
		<td>$9F37</td>
		<td>L1_HSCROLL_L</td>
		<td colspan="8" align="center">H-Scroll (7:0)</td>
	</tr>
	<tr>
		<td>$9F38</td>
		<td>L1_HSCROLL_H</td>
		<td colspan="4" align="center">-</td>
		<td colspan="8" align="center">H-Scroll (11:8)</td>
	</tr>
	<tr>
		<td>$9F39</td>
		<td>L1_VSCROLL_L</td>
		<td colspan="8" align="center">V-Scroll (7:0)</td>
	</tr>
	<tr>
		<td>$9F3A</td>
		<td>L1_VSCROLL_H</td>
		<td colspan="4" align="center">-</td>
		<td colspan="8" align="center">V-Scroll (11:8)</td>
	</tr>
	<tr>
		<td>$9F3B</td>
		<td>AUDIO_CTRL</td>
		<td colspan="1" align="center">FIFO Full / FIFO Reset</td>
		<td colspan="1" align="center">-</td>
		<td colspan="1" align="center">16-Bit</td>
		<td colspan="1" align="center">Stereo</td>
		<td colspan="4" align="center">PCM Volume</td>
	</tr>
	<tr>
		<td>$9F3C</td>
		<td>AUDIO_RATE</td>
		<td colspan="8" align="center">PCM Sample Rate</td>
	</tr>
	<tr>
		<td>$9F3D</td>
		<td>AUDIO_DATA</td>
		<td colspan="8" align="center">Audio FIFO data (write-only)</td>
	</tr>
	<tr>
		<td>$9F3E</td>
		<td>SPI_DATA</td>
		<td colspan="8" align="center">Data</td>
	</tr>
	<tr>
		<td>$9F3F</td>
		<td>SPI_CTRL</td>
		<td colspan="1" align="center">Busy</td>
		<td colspan="5" align="center">-</td>
		<td colspan="1" align="center">Slow clock</td>
		<td colspan="1" align="center">Select</td>
	</tr>
</table>

## VRAM address space layout

| Address range   | Description                |
| --------------- | -------------------------- |
| $00000 - $1F9BF | Video RAM                  |
| $1F9C0 - $1F9FF | PSG registers              |
| $1FA00 - $F1BFF | Palette                    |
| $1FC00 - $1FFFF | Sprite attributes          |

***Important note:
Video RAM locations 1F9C0-1FFFF contain registers for the PSG/Palette/Sprite attributes. Reading anywhere in VRAM will always read back the 128kB VRAM itself (not the contents of the (write-only) PSG/Palette/Sprite attribute registers). Writing to a location in the register area will write to the registers in addition to writing the value also to VRAM. Since the VRAM contains random values at startup the values read back in the register area will not correspond to the actual values in the write-only registers until they are written to once.
Because of this it is highly recommended to initialize the area from 1F9C0-1FFFF at startup.***


## Video RAM access
The video RAM (VRAM) isn't directly accessible on the CPU bus. VERA only exposes an address space of 32 bytes to the CPU as described in the section [Registers](#registers). To access the VRAM (which is 128kB in size) an indirection mechanism is used. First the address to be accessed needs to be set (ADDRx_L/ADDRx_M/ADDRx_H) and then the data on that VRAM address can be read from or written to via the DATA0/1 register. To make accessing the VRAM more efficient an auto-increment mechanism is present.

There are 2 data ports to the VRAM. Which can be accessed using DATA0 and DATA1. The address and increment associated with the data port is specified in ADDRx_L/ADDRx_M/ADDRx_H. These 3 registers are multiplexed using the ADDR_SEL in the CTRL register. When ADDR_SEL = 0, ADDRx_L/ADDRx_M/ADDRx_H become ADDR0_L/ADDR0_M/ADDR0_H.  
When ADDR_SEL = 1, ADDRx_L/ADDRx_M/ADDRx_H become ADDR1_L/ADDR1_M/ADDR1_H.

By setting the 'Address Increment' field in ADDRx_H, the address will be increment after each access to the data register. The increment register values and corresponding increment amounts are shown in the following table:

| Register value | Increment amount |
| -------------: | ---------------: |
| 0              | 0                |
| 1              | 1                |
| 2              | 2                |
| 3              | 4                |
| 4              | 8                |
| 5              | 16               |
| 6              | 32               |
| 7              | 64               |
| 8              | 128              |
| 9              | 256              |
| 10             | 512              |
| 11             | 40               |
| 12             | 80               |
| 13             | 160              |
| 14             | 320              |
| 15             | 640              |

Setting the **DECR** bit, will decrement instead of increment by the value set by the 'Address Increment' field.

## Reset

When **RESET** in **CTRL** is set to 1, the FPGA will reconfigure itself. All registers will be reset. The palette RAM will be set to its default values.

## Interrupts

Interrupts will be generated for the interrupt sources set in the lower 4 bits of **IEN**.
**ISR** will indicate the interrupts that have occurred. Writing a 1 to one of the lower 3 bits in **ISR** will clear that interrupt status. **AFLOW** can only be cleared by filling the audio FIFO for at least 1/4.

**IRQ_LINE** specifies at which line the **LINE** interrupt will be generated. Note that bit 8 of this value is present in the **IEN** register. For interlaced modes the interrupt will be generated each field and the bit 0 of **IRQ_LINE** is ignored.

The upper 4 (read-only) bits of the **ISR** register contain the [sprite collisions](#sprite-collisions) as determined by the sprite renderer.


## Display composer

The display composer is responsible of combining the output of the 2 layer renderers and the sprite renderer into the image that is sent to the video output.

The video output mode can be selected using OUT_MODE in DC_VIDEO.

| OUT_MODE | Description                                        |
| -------: | -------------------------------------------------- |
| 0        | Video disabled                                     |
| 1        | VGA output                                         |
| 2        | NTSC composite                                     |
| 3        | RGB interlaced, composite sync (via VGA connector) |

Setting **'Chroma Disable'** disables output of chroma in NTSC composite mode and will give a better picture on a monochrome display. *(Setting this bit will also disable the chroma output on the S-video output.)*

**'Current Field'** is a read-only bit which reflects the active interlaced field in composite and RGB modes. (0: even, 1: odd)

Setting **'Layer0 Enable'** / **'Layer1 Enable'** / **'Sprites Enable'** will respectively enable output from layer0 / layer1 and the sprites renderer.

**DC_HSCALE** and **DC_VSCALE** will set the fractional scaling factor of the active part of the display. Setting this value to 128 will output 1 output pixel for every input pixel. Setting this to 64 will output 2 output pixels for every input pixel.

**DC_BORDER** determines the palette index which is used for the non-active area of the screen.

**DC_HSTART**/**DC_HSTOP** and **DC_VSTART**/**DC_VSTOP** determines the active part of the screen. The values here are specified in the native 640x480 display space. HSTART=0, HSTOP=640, VSTART=0, VSTOP=480 will set the active area to the full resolution. Note that the lower 2 bits of **DC_HSTART**/**DC_HSTOP** and the lower 1 bit of **DC_VSTART**/**DC_VSTOP** isn't available. This means that horizontally the start and stop values can be set at a multiple of 4 pixels, vertically at a multiple of 2 pixels.

## Layer 0/1 registers

**'Map Base Address'** specifies the base address of the tile map. *Note that the register only specifies bits 16:9 of the address, so the address is always aligned to a multiple of 512 bytes.*

**'Tile Base Address'** specifies the base address of the tile data. *Note that the register only specifies bits 16:11 of the address, so the address is always aligned to a multiple of 2048 bytes.*
 
**'H-Scroll'** specifies the horizontal scroll offset. A value between 0 and 4095 can be used. Increasing the value will cause the picture to move left, decreasing will cause the picture to move right.

**'V-Scroll'** specifies the vertical scroll offset. A value between 0 and 4095 can be used. Increasing the value will cause the picture to move up, decreasing will cause the picture to move down.

**'Map Width'**, **'Map Height'** specify the dimensions of the tile map:

| Value | Map width / height |
| ----: | ------------------ |
| 0     | 32 tiles           |
| 1     | 64 tiles           |
| 2     | 128 tiles          |
| 3     | 256 tiles          |

**'Tile Width'**, **'Tile Height'** specify the dimensions of a single tile:

| Value | Tile width / height |
| ----: | ------------------- |
| 0     | 8 pixels            |
| 1     | 16 pixels           |

In bitmap modes, the **'H-Scroll (11:8)'** register is used to specify the palette offset for the bitmap.


### Layer display modes

The features of the 2 layers are the same. Each layer supports a few different modes which are specified using **T256C** / **'Bitmap Mode'** / **'Color Depth'** in Lx_CONFIG.

**'Color Depth'** specifies the number of bits used per pixel to encode color information:

| Color Depth | Description |
| ----------: | ----------- |
| 0           | 1 bpp       |
| 1           | 2 bpp       |
| 2           | 4 bpp       |
| 3           | 8 bpp       |

The layer can either operate in tile mode or bitmap mode. This is selected using the **'Bitmap Mode'** bit; 0 selects tile mode, 1 selects bitmap mode.

The handling of 1 bpp tile mode is different from the other tile modes. Depending on the **T256C** bit the tiles use either a 16-color foreground and background color or a 256-color foreground color. Other modes ignore the **T256C** bit.

### Tile mode 1 bpp (16 color text mode)

**T256C** should be set to 0.

**MAP_BASE** points to a tile map containing tile map entries, which are 2 bytes each:

<table>
	<tr>
		<th>Offset</th>
		<th>Bit&nbsp;7</th>
		<th>Bit&nbsp;6</th>
		<th>Bit&nbsp;5</th>
		<th>Bit&nbsp;4</th>
		<th>Bit&nbsp;3</th>
		<th>Bit&nbsp;2</th>
		<th>Bit&nbsp;1</th>
		<th>Bit&nbsp;0</th>
	</tr>
	<tr>
		<td>0</td>
		<td align="center" colspan="8">Character index</td>
	</tr>
	<tr>
		<td>1</td>
		<td align="center" colspan="4">Background color</td>
		<td align="center" colspan="4">Foreground color</td>
	</tr>
</table>

**TILE_BASE** points to the tile data.

Each bit in the tile data specifies one pixel. If the bit is set the foreground color as specified in the map data is used, otherwise the background color as specified in the map data is used.

### Tile mode 1 bpp (256 color text mode)

**T256C** should be set to 1.

**MAP_BASE** points to a tile map containing tile map entries, which are 2 bytes each:

<table>
	<tr>
		<th>Offset</th>
		<th>Bit&nbsp;7</th>
		<th>Bit&nbsp;6</th>
		<th>Bit&nbsp;5</th>
		<th>Bit&nbsp;4</th>
		<th>Bit&nbsp;3</th>
		<th>Bit&nbsp;2</th>
		<th>Bit&nbsp;1</th>
		<th>Bit&nbsp;0</th>
	</tr>
	<tr>
		<td>0</td>
		<td align="center" colspan="8">Character index</td>
	</tr>
	<tr>
		<td>1</td>
		<td align="center" colspan="8">Foreground color</td>
	</tr>
</table>

**TILE_BASE** points to the tile data.

Each bit in the tile data specifies one pixel. If the bit is set the foreground color as specified in the map data is used, otherwise color 0 is used (transparent).

### Tile mode 2/4/8 bpp

**MAP_BASE** points to a tile map containing tile map entries, which are 2 bytes each:

<table>
	<tr>
		<th>Offset</th>
		<th>Bit&nbsp;7</th>
		<th>Bit&nbsp;6</th>
		<th>Bit&nbsp;5</th>
		<th>Bit&nbsp;4</th>
		<th>Bit&nbsp;3</th>
		<th>Bit&nbsp;2</th>
		<th>Bit&nbsp;1</th>
		<th>Bit&nbsp;0</th>
	</tr>
	<tr>
		<td>0</td>
		<td align="center" colspan="8">Tile index (7:0)</td>
	</tr>
	<tr>
		<td>1</td>
		<td align="center" colspan="4">Palette offset</td>
		<td align="center">V-flip</td>
		<td align="center">H-flip</td>
		<td align="center" colspan="2">Tile index (9:8)</td>
	</tr>
</table>

**TILE_BASE** points to the tile data.

Each pixel in the tile data gives a color index of either 0-3 (2bpp), 0-15 (4bpp), 0-255 (8bpp). This color index is modified by the palette offset in the tile map data using the following logic:

* Color index 0 (transparent) and 16-255 are unmodified.
* Color index 1-15 is modified by adding 16 x palette offset.

### Bitmap mode 1/2/4/8 bpp

**MAP_BASE** isn’t used in these modes. **TILE_BASE** points to the bitmap data.

**TILEW** specifies the bitmap width. TILEW=0 results in 320 pixels width and TILEW=1 results in 640 pixels width.

The palette offset (in **'H-Scroll (11:8)'**) modifies the color indexes of the bitmap in the same way as in the tile modes.


## SPI controller

The SPI controller is connected to the SD card connector. The speed of the clock output of the SPI controller can be controlled by the **'Slow Clock'** bit. When this bit is 0 the clock is 12.5MHz, when 1 the clock is about 390kHz. The slow clock speed is to be used during the initialization phase of the SD card. Some SD cards require a clock less than 400kHz during part of the initialization.

A transfer can be started by writing to **SPI_DATA**. While the transfer is in progress the BUSY bit will be set. After the transfer is done, the result can be read from the **SPI_DATA** register.

The chip select can be controlled by writing the **SELECT** bit. Writing 1 will assert the chip-select (logic-0) and writing 0 will release the chip-select (logic-1).


## Palette

The palette translates 8-bit color indexes into 12-bit output colors. The palette has 256 entries, each with the following format:

<table>
	<tr>
		<th>Offset</th>
		<th>Bit&nbsp;7</th>
		<th>Bit&nbsp;6</th>
		<th>Bit&nbsp;5</th>
		<th>Bit&nbsp;4</th>
		<th>Bit&nbsp;3</th>
		<th>Bit&nbsp;2</th>
		<th>Bit&nbsp;1</th>
		<th>Bit&nbsp;0</th>
	</tr>
	<tr>
		<td>0</td>
		<td align="center" colspan="4">Green</td>
		<td align="center" colspan="4">Blue</td>
	</tr>
	<tr>
		<td>1</td>
		<td align="center" colspan="4">-</td>
		<td align="center" colspan="4">Red</td>
	</tr>
</table>

At reset, the palette will contain a predefined palette:

	000,fff,800,afe,c4c,0c5,00a,ee7,d85,640,f77,333,777,af6,08f,bbb
	000,111,222,333,444,555,666,777,888,999,aaa,bbb,ccc,ddd,eee,fff
	211,433,644,866,a88,c99,fbb,211,422,633,844,a55,c66,f77,200,411
	611,822,a22,c33,f33,200,400,600,800,a00,c00,f00,221,443,664,886
	aa8,cc9,feb,211,432,653,874,a95,cb6,fd7,210,431,651,862,a82,ca3
	fc3,210,430,640,860,a80,c90,fb0,121,343,564,786,9a8,bc9,dfb,121
	342,463,684,8a5,9c6,bf7,120,241,461,582,6a2,8c3,9f3,120,240,360
	480,5a0,6c0,7f0,121,343,465,686,8a8,9ca,bfc,121,242,364,485,5a6
	6c8,7f9,020,141,162,283,2a4,3c5,3f6,020,041,061,082,0a2,0c3,0f3
	122,344,466,688,8aa,9cc,bff,122,244,366,488,5aa,6cc,7ff,022,144
	166,288,2aa,3cc,3ff,022,044,066,088,0aa,0cc,0ff,112,334,456,668
	88a,9ac,bcf,112,224,346,458,56a,68c,79f,002,114,126,238,24a,35c
	36f,002,014,016,028,02a,03c,03f,112,334,546,768,98a,b9c,dbf,112
	324,436,648,85a,96c,b7f,102,214,416,528,62a,83c,93f,102,204,306
	408,50a,60c,70f,212,434,646,868,a8a,c9c,fbe,211,423,635,847,a59
	c6b,f7d,201,413,615,826,a28,c3a,f3c,201,403,604,806,a08,c09,f0b

* Color indexes 0-15 contain the C64 color palette.
* Color indexes 16-31 contain a grayscale ramp.
* Color indexes 32-255 contain various hues, saturation levels, brightness levels.

## Sprite attributes

128 entries of the following format:

<table>
	<tr>
		<th>Offset</th>
		<th>Bit&nbsp;7</th>
		<th>Bit&nbsp;6</th>
		<th>Bit&nbsp;5</th>
		<th>Bit&nbsp;Bit&nbsp;4</th>
		<th>Bit&nbsp;3</th>
		<th>Bit&nbsp;2</th>
		<th>Bit&nbsp;1</th>
		<th>Bit&nbsp;0</th>
	</tr>
	<tr>
		<td>0</td>
		<td align="center" colspan="8">Address (12:5)</td>
	</tr>
	<tr>
		<td>1</td>
		<td>Mode</td>
		<td align="center" colspan="3">-</td>
		<td align="center" colspan="4">Address (16:13)</td>
	</tr>
	<tr>
		<td>2</td>
		<td align="center" colspan="8">X (7:0)</td>
	</tr>
	<tr>
		<td>3</td>
		<td align="center" colspan="6">-</td>
		<td align="center" colspan="2">X (9:8)</td>
	</tr>
	<tr>
		<td>4</td>
		<td align="center" colspan="8">Y (7:0)</td>
	</tr>
	<tr>
		<td>5</td>
		<td align="center" colspan="6">-</td>
		<td align="center" colspan="2">Y (9:8)</td>
	</tr>
	<tr>
		<td>6</td>
		<td align="center" colspan="4">Collision mask</td>
		<td align="center" colspan="2">Z-depth</td>
		<td align="center">V-flip</td>
		<td align="center">H-flip</td>
	</tr>
	<tr>
		<td>7</td>
		<td align="center" colspan="2">Sprite height</td>
		<td align="center" colspan="2">Sprite width</td>
		<td align="center" colspan="4">Palette offset</td>
	</tr>
</table>

| Mode | Description |
| ---- | ----------- |
| 0    | 4 bpp       |
| 1    | 8 bpp       |

| Z-depth | Description                           |
| ------- | ------------------------------------- |
| 0       | Sprite disabled                       |
| 1       | Sprite between background and layer 0 |
| 2       | Sprite between layer 0 and layer 1    |
| 3       | Sprite in front of layer 1            |

| Sprite width / height | Description |
| --------------------- | ----------- |
| 0                     | 8 pixels    |
| 1                     | 16 pixels   |
| 2                     | 32 pixels   |
| 3                     | 64 pixels   |

**Rendering Priority** The sprite memory location dictates the order in which it is rendered. The sprite whose attributes are at the lowest location will be rendered in front of all other sprites; the sprite at the highest location will be rendered behind all other sprites, and so forth.

**Palette offset** works in the same way as with the layers.


## Sprite collisions

At the start of the vertical blank **Collisions** in **ISR** is updated. This field indicates which groups of sprites have collided. If the field is non-zero the **SPRCOL** interrupt will be set. The interrupt is generated once per field / frame and can be cleared by making sure the sprites no longer collide.

*Note that collisions are only detected on lines that are actually rendered. This can result in subtle differences between non-interlaced and interlaced video modes.*


## Programmable Sound Generator (PSG)

The audio functionality contains of 2 independent systems. The first is the PSG or Programmable Sound Generator. The second is the PCM (or Pulse-Code Modulation) playback system.

16 entries (channels) of the following format:

<table>
	<tr>
		<th>Offset</th>
		<th>Bit&nbsp;7</th>
		<th>Bit&nbsp;6</th>
		<th>Bit&nbsp;5</th>
		<th>Bit&nbsp;Bit&nbsp;4</th>
		<th>Bit&nbsp;3</th>
		<th>Bit&nbsp;2</th>
		<th>Bit&nbsp;1</th>
		<th>Bit&nbsp;0</th>
	</tr>
	<tr>
		<td>0</td>
		<td align="center" colspan="8">Frequency word (7:0)</td>
	</tr>
	<tr>
		<td>1</td>
		<td align="center" colspan="8">Frequency word (15:8)</td>
	</tr>
	<tr>
		<td>2</td>
		<td align="center" colspan=1">Right</td>
		<td align="center" colspan=1">Left</td>
		<td align="center" colspan=6">Volume</td>
	</tr>
	<tr>
		<td>3</td>
		<td align="center" colspan="2">Waveform</td>
		<td align="center" colspan="6">Pulse width</td>
	</tr>
</table>

**Frequency word** sets the frequency of the sound.
The formula for calculating the output frequency is:

    sample_rate = 25MHz / 512 = 48828.125 Hz

    output_frequency = sample_rate / (2^20) * frequency_word

Thus the output frequency can be set in steps of about 0.0466 Hz.

*Example: to output a frequency of 440Hz (note A4) the **Frequency word** should be set to  440 / (48828.125 / (2^20)) = 9449*

**Volume** controls the volume of the sound with a logarithmic curve; 0 is silent, 63 is the loudest.
The **Left** and **Right** bits control to which output channels the sound should be output.

**Waveform** controls the waveform of the sound:

| Waveform | Description |
| -------: | ----------- |
| 0        | Pulse       |
| 1        | Sawtooth    |
| 2        | Triangle    |
| 3        | Noise       |

**Pulse width** controls the duty cycle of the pulse waveform. A value of 63 will give a 50% duty cycle or square wave, 0 will give a very narrow pulse.

Just like the other waveform types, the frequency of the noise waveform can be controlled using frequency. In this case a higher frequency will give brighter noise and a lower value will give darker noise.


## PCM audio

For PCM playback, VERA contains a 4kB FIFO buffer. This buffer needs to be filled in a timely fashion by the CPU. To facilitate this an **AFLOW** (Audio FIFO low) interrupt can be generated when the FIFO is less than 1/4 filled.

### Audio registers

**PCM Volume** controls the volume of the PCM playback, this has a logarithmic curve. A value of 0 is silence, 15 is the loudest.

**Stereo** sets the data format to stereo. If this bit is 0 (mono), the same audio data is send to both channels.

**16-bit** sets the data format to 16-bit. If this bit is 0, 8-bit data is expected.

**FIFO Full** is a read-only flag that indicated if the FIFO is full. Any writes to the FIFO while this flag is 1 will be ignored. Writing a 1 to this register (**FIFO Reset**) will perform a FIFO reset, which will clear the contents of the FIFO buffer.

**PCM sample rate** controls the speed at which samples are read from the FIFO. A few example values:

| PCM sample rate | Description                                 |
| --------------: | ------------------------------------------- |
| 128             | normal speed   (25MHz / 512 = 48828.125 Hz) |
| 64              | half speed     (24414 Hz)                   |
| 32              | quarter speed  (12207 Hz)                   |
| 0               | stop playback                               |
| *>128*          | *invalid*                                   |

Using a value of 128 will give the best quality (lowest distortion); at this value for every output sample, an input sample from the FIFO is read. Lower values will output the same sample multiple times to the audio DAC. Input samples are always read as a complete set (being 1/2/4 bytes).

*NOTE: When setting up for PCM playback it is adviced to first set the sample rate at 0 to stop playback. First fill the FIFO buffer with some initial data and then set the desired sample rate. This can prevent undesired FIFO underruns.*


### Audio data formats

Audio data is two's complement signed.
Depending on the selected mode the data needs to be written to the FIFO in the following order:

| Mode          | Order in which to write data to FIFO                                                        |
| ------------- | ------------------------------------------------------------------------------------------- |
| 8-bit mono    | \<mono sample\>                                                                             |
| 8-bit stereo  | \<left sample\> \<right sample\>                                                            |
| 16-bit mono   | \<mono sample (7:0)\> \<mono sample (15:8)\>                                                |
| 16-bit stereo | \<left sample (7:0)\> \<left sample (15:8)\> \<right sample (7:0)\> \<right sample (15:8)\> |
