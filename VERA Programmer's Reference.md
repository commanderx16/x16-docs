# VERA Programmer's Reference

Version 0.8

*Author: Frank van den Hoef*

**This is preliminary documentation and the specification can still change at any point.**

This document describes the **V**ideo **E**nhanced **R**etro **A**dapter video-module.

# External address space

<table>
	<tr>
		<th>Reg</th>
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
		<td>0</td>
		<td>$9F20</td>
		<td>VERA_ADDR_LO</td>
		<td colspan="8" align="center">Address (7:0)</td>
	</tr>
	<tr>
		<td>1</td>
		<td>$9F21</td>
		<td>VERA_ADDR_MID</td>
		<td colspan="8" align="center">Address (15:8)</td>
	</tr>
	<tr>
		<td>2</td>
		<td>$9F22</td>
		<td>VERA_ADDR_HI</td>
		<td colspan="4" align="center">Increment</td>
		<td colspan="4" align="center">Address (19:16)</td>
	</tr>
	<tr>
		<td>3</td>
		<td>$9F23</td>
		<td>VERA_DATA0</td>
		<td colspan="8" align="center">Data port 0</td>
	</tr>
	<tr>
		<td>4</td>
		<td>$9F24</td>
		<td>VERA_DATA1</td>
		<td colspan="8" align="center">Data port 1</td>
	</tr>
	<tr>
		<td>5</td>
		<td>$9F25</td>
		<td>VERA_CTRL</td>
		<td align="center">RESET</td>
		<td colspan="6" align="center">-</td>
		<td align="center">ADDRSEL</td>
	</tr>
	<tr>
		<td>6</td>
		<td>$9F26</td>
		<td>VERA_IEN</td>
		<td colspan="4" align="center">-</td>
		<td align="center">UART</td>
		<td align="center">SPRCOL</td>
		<td align="center">LINE</td>
		<td align="center">VSYNC</td>
	</tr>
	<tr>
		<td>7</td>
		<td>$9F27</td>
		<td>VERA_ISR</td>
		<td colspan="4" align="center">-</td>
		<td align="center">UART</td>
		<td align="center">SPRCOL</td>
		<td align="center">LINE</td>
		<td align="center">VSYNC</td>
	</tr>
</table>

When RESET is set to 1, the FPGA will reconfigure itself. All registers will be reset. The palette RAM will be set to its default values.

If ADDR_SEL = 0, register 0/1/2 contain address of data port 0, otherwise register 0/1/2 contain address of data port 1.

After each access of one of the data ports the corresponding address is increment by the value associated with the corresponding increment field:

| Increment value | Increment amount |
| --------------- | ---------------- |
| 0               | 0                |
| 1               | 1                |
| 2               | 2                |
| 3               | 4                |
| 4               | 8                |
| 5               | 16               |
| 6               | 32               |
| 7               | 64               |
| 8               | 128              |
| 9               | 256              |
| 10              | 512              |
| 11              | 1024             |
| 12              | 2048             |
| 13              | 4096             |
| 14              | 8192             |
| 15              | 16384            |

Interrupts will be generated for the interrupt sources set in VERA_IEN. VERA_ISR will indicate interrupts that have occurred. Writing a 1 to a position in VERA_ISR will clear that interrupt status.

## Internal address space

| Address range   | Description                |
| --------------- | -------------------------- |
| $00000 - $1FFFF | Video RAM                  |
| $F0000 - $F001F | Display composer registers |
| $F1000 - $F11FF | Palette                    |
| $F2000 - $F200F | Layer 0 registers          |
| $F3000 - $F300F | Layer 1 registers          |
| $F4000 - $F400F | Sprite registers           |
| $F5000 - $F53FF | Sprite attributes          |
| $F6000 - $F6xxx | Audio                      |
| $F7000 - $F7001 | SPI                        |
| $F8000 - $F8003 | UART                       |

## Display composer

<table>
	<tr>
		<th>Register</th>
		<th>Name</th>
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
		<td>DC_VIDEO</td>
		<td align="center">CURRENT_FIELD (RO)</td>
		<td align="center" colspan="4">-</td>
		<td align="center">CHROMA_DISABLE</td>
		<td align="center" colspan="2">OUT_MODE</td>
	</tr>
	<tr>
		<td>1</td>
		<td>DC_HSCALE</td>
		<td align="center" colspan="8">HSCALE</td>
	</tr>
	<tr>
		<td>2</td>
		<td>DC_VSCALE</td>
		<td align="center" colspan="8">VSCALE</td>
	</tr>
	<tr>
		<td>3</td>
		<td>DC_BORDER_COLOR</td>
		<td align="center" colspan="8">BORDER_COLOR</td>
	</tr>
	<tr>
		<td>4</td>
		<td>DC_HSTART_L</td>
		<td align="center" colspan="8">HSTART (7:0)</td>
	</tr>
	<tr>
		<td>5</td>
		<td>DC_HSTOP_L</td>
		<td align="center" colspan="8">HSTOP (7:0)</td>
	</tr>
	<tr>
		<td>6</td>
		<td>DC_VSTART_L</td>
		<td align="center" colspan="8">VSTART (7:0)</td>
	</tr>
	<tr>
		<td>7</td>
		<td>DC_VSTOP_L</td>
		<td align="center" colspan="8">VSTOP (7:0)</td>
	</tr>
	<tr>
		<td>8</td>
		<td>DC_STARTSTOP_H</td>
		<td align="center" colspan="2">-</td>
		<td align="center">VSTOP (8)</td>
		<td align="center">VSTART (8)</td>
		<td align="center" colspan="2">HSTOP (9:8)</td>
		<td align="center" colspan="2">HSTART (9:8)</td>
	</tr>
	<tr>
		<td>9</td>
		<td>DC_IRQ_LINE_L</td>
		<td align="center" colspan="8">IRQ_LINE (7:0)</td>
	</tr>
	<tr>
		<td>10</td>
		<td>DC_IRQ_LINE_H</td>
		<td align="center" colspan="7">-</td>
		<td align="center">IRQ_LINE (8)</td>
	</tr>
</table>

| OUT\_MODE | Description                                     |
| --------- | ----------------------------------------------- |
| 0         | Video disabled                                  |
| 1         | VGA output                                      |
| 2         | NTSC composite                                  |
| 3         | RGB interlaced, composite sync (via VGA output) |

Setting **CHROMA_DISABLE** disables output of chroma in NTSC composite mode and will give a better picture on a monochrome display.

**CURRENT_FIELD** is a read-only field which reflects the active interlaced field in composite and RGB modes. (0: even, 1: odd)

**HSCALE** and **VSCALE** will set the fractional scaling factor of the display. Setting this value to 128 will output 1 output pixel for every input pixel. Setting this to 64 will output 2 output pixels for every input pixel.

**BORDER_COLOR** determines the palette index which is used for the non-active area of the screen.

**HSTART**/**HSTOP** and **VSTART**/**VSTOP** determines the active part of the screen. The values here are specified in the native 640x480 display space. HSTART=0, HSTOP=640, VSTART=0, VSTOP=480 will set the active area to the full resolution.

**IRQ_LINE** specifies at which line the **LINE** interrupt will be generated. For interlaced modes the interrupt will be generated each field and the LSB of **IRQ_LINE** is ignored.

TODO:

* Hardware ID
* Palette selection
* Per layer active area
* Per layer scaling
* Remapping transparent index 0 to other entry

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

* Color indexes 0-15 contain the C64 color palette.
* Color indexes 16-31 contain a grayscale ramp.
* Color indexes 32-255 contain various hues, saturation levels, brightness levels.

## Layer 0/1 registers

<table>
	<tr>
		<th>Register</th>
		<th>Name</th>
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
		<td>Ln_CTRL0</td>
		<td align="center" colspan="3">MODE</td>
		<td align="center" colspan="4">-</td>
		<td align="center">EN</td>
	</tr>
	<tr>
		<td>1</td>
		<td>Ln_CTRL1</td>
		<td align="center" colspan="2">-</td>
		<td align="center">TILEH</td>
		<td align="center">TILEW</td>
		<td align="center" colspan="2">MAPH</td>
		<td align="center" colspan="2">MAPW</td>
	</tr>
	<tr>
		<td>2</td>
		<td>Ln_MAP_BASE_L</td>
		<td align="center" colspan="8">MAP_BASE (9:2)</td>
	</tr>
	<tr>
		<td>3</td>
		<td>Ln_MAP_BASE_H</td>
		<td align="center" colspan="8">MAP_BASE (17:10)</td>
	</tr>
	<tr>
		<td>4</td>
		<td>Ln_TILE_BASE_L</td>
		<td align="center" colspan="8">TILE_BASE (9:2)</td>
	</tr>
	<tr>
		<td>5</td>
		<td>Ln_TILE_BASE_H</td>
		<td align="center" colspan="8">TILE_BASE (17:10)</td>
	</tr>
	<tr>
		<td>6</td>
		<td>Ln_HSCROLL_L</td>
		<td align="center" colspan="8">HSCROLL (7:0)</td>
	</tr>
	<tr>
		<td>7</td>
		<td>Ln_HSCROLL_H</td>
		<td align="center" colspan="4">-</td>
		<td align="center" colspan="4">HSCROLL (11:8)</td>
	</tr>
	<tr>
		<td>8</td>
		<td>Ln_VSCROLL_L</td>
		<td align="center" colspan="8">VSCROLL (7:0)</td>
	</tr>
	<tr>
		<td>9</td>
		<td>Ln_VSCROLL_H</td>
		<td align="center" colspan="4">-</td>
		<td align="center" colspan="4">VSCROLL (11:8)</td>
	</tr>
</table>

In bitmap modes (5/6/7), the following changes apply:

<table>
	<tr>
		<th>Register</th>
		<th>Name</th>
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
		<td>7</td>
		<td>Ln_BM_PAL_OFFS</td>
		<td align="center" colspan="4">-</td>
		<td align="center" colspan="4">BM_PALETTE_OFFSET</td>
	</tr>
</table>

The layer can be enabled or disabled by setting or clearing the **EN** bit.

**MAP_BASE** specifies the base address where tile map data is fetched from. (Note that the registers don’t specify the lower 2 bits, so the address is always aligned to a multiple of 4 bytes.)

**TILE_BASE** specifies the base address where tile data is fetched from. (Note that the registers don’t specify the lower 2 bits, so the address is always aligned to a multiple of 4 bytes.)
 
**HSCROLL** specifies the horizontal scroll offset. A value between 0 and 4095 can be used. Increasing the value will cause the picture to move left, decreasing will cause the picture to move right.

**YSCROLL** specifies the vertical scroll offset. A value between 0 and 4095 can be used. Increasing the value will cause the picture to move up, decreasing will cause the picture to move down.

**MAPW**, **MAPH** specify the map width and map height respectively:

| Value | Map width / height |
| ----- | ------------------ |
| 0     | 32 tiles           |
| 1     | 64 tiles           |
| 2     | 128 tiles          |
| 3     | 256 tiles          |

**TILEW**, **TILEH** specify the tile width and tile height respectively:

| Value | Tile width / height |
| ----- | ------------------- |
| 0     | 8                   |
| 1     | 16                  |

### Layer display modes

Each layer supports a few different display modes, which can be selected using the MODE field:

| Mode | Description                                                                       |
| ---- | --------------------------------------------------------------------------------- |
| 0    | Tile mode 1bpp (per-tile 16 color foreground and background color)                |
| 1    | Tile mode 1bpp (per-tile 256 color foreground color and fixed background color 0) |
| 2    | Tile mode 2bpp                                                                    |
| 3    | Tile mode 4bpp                                                                    |
| 4    | Tile mode 8bpp                                                                    |
| 5    | Bitmap mode 2bpp                                                                  |
| 6    | Bitmap mode 4bpp                                                                  |
| 7    | Bitmap mode 8bpp                                                                  |

### Mode 0 – 16 color text mode

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

**TILE_BASE** points to the character data. This data is organized as 8 bytes per character entry. Each byte represents 1 line of character data, where bit 7 represents the left-most pixel and bit 0 the right-most pixel. If the bit is set the foreground color is used, otherwise the background color.

### Mode 1 – 256 color text mode

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

**TILE_BASE** points to the character data. This data is organized as 8 bytes per character entry. Each byte represents 1 line of character data, where bit 7 represents the left-most pixel and bit 0 the right-most pixel. If the bit is set the foreground color is used, otherwise color 0 is used.

### Mode 2/3/4 – Tile mode 2/4/8bpp

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

TODO: explanation of tile data memory organization

### Mode 5/6/7 – Bitmap mode 2/4/8bpp

**MAP_BASE** isn’t used in these modes. **TILE_BASE** points to the bitmap data.

**TILEW** specifies the bitmap width. TILEW=0 results in 320 pixels width and TILEW=1 results in 640 pixels width.

**BM_PALETTE_OFFSET** modifies the color indexes of the bitmap in the same way as in the tile modes.

TODO: explanation of bitmap data memory organization

## Sprite registers

<table>
	<tr>
		<th>Register</th>
		<th>Name</th>
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
		<td>SPR_CTRL</td>
		<td align="center" colspan="7">-</td>
		<td align="center">EN</td>
	</tr>
	<tr>
		<td>1</td>
		<td>SPR_COLLISION</td>
		<td align="center" colspan="4">-</td>
		<td align="center" colspan="4">Collision mask</td>
	</tr>
</table>

At the start of the vertical blank **Collision mask** is updated. This field indicates which groups of sprites have collided. If the field is non-zero the **SPRCOL** interrupt will be set. The interrupt is generated once per field / frame and can be cleared by making sure the sprites no longer collide.

Collisions are only detected on lines that are actually rendered.

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
| 0                     | 8 px        |
| 1                     | 16 px       |
| 2                     | 32 px       |
| 3                     | 64 px       |

**Rendering Priority** The sprite memory location dictates the order in which it is rendered.  The sprite whose attributes are at the lowest location, $F5000, will be rendered above all other sprites; the sprite at the highest location will be rendered below all other sprites, and so forth.

**Palette offset** works in the same way as with the layers.

## SPI registers

<table>
	<tr>
		<th>Register</th>
		<th>Name</th>
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
		<td>SPI_DATA</td>
		<td align="center" colspan="8">DATA</td>
	</tr>
	<tr>
		<td>1</td>
		<td>SPI_CTRL</td>
		<td align="center" colspan="6">-</td>
		<td align="center">BUSY</td>
		<td align="center">SELECT</td>
	</tr>
</table>

The SPI controller is connected to the SD card connector. The data rate is fixed at 12.5MHz.

Start a transfer by writing to SPI_DATA. While the transfer is in progress the BUSY bit will be set. After the transfer is done, the result can be read from the SPI_DATA register.

The chip select can be controlled by writing the SELECT bit. Writing 1 will assert the chip-select (logic-0) and writing 0 will release the chip-select (logic-1).

## UART registers

<table>
	<tr>
		<th>Register</th>
		<th>Name</th>
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
		<td>UART_DATA</td>
		<td align="center" colspan="8">DATA</td>
	</tr>
	<tr>
		<td>1</td>
		<td>UART_STATUS</td>
		<td align="center" colspan="6">-</td>
		<td align="center">TXBUSY</td>
		<td align="center">RXFIFO not empty</td>
	</tr>
	<tr>
		<td>2</td>
		<td>UART_BAUDDIV_L</td>
		<td align="center" colspan="8">BAUDDIV (7:0)</td>
	</tr>
	<tr>
		<td>3</td>
		<td>UART_BAUDDIV_H</td>
		<td align="center" colspan="8">BAUDDIV (15:8)</td>
	</tr>
</table>

The UART has a 512 bytes receive FIFO and a single byte transmit buffer. The BAUDDIV has to be set to select the desired baudrate. The resulting baudrate is 25000000 / (BAUDDIV+1). The default baudrate at reset is 1Mbps.

Bit 0 in UART_STATUS indicates whether DATA is available. If so, data can be read by reading from UART_DATA. After this read bit 0 is updated.

To send a byte, first check if TXBUSY is clear, then write the data to UART_DATA. While the UART is transmitting TXBUSY will be set.

An interrupt can be generated when data is available in the RX FIFO. Use the UART bit in the VERA_IEN and VERA_ISR registers for this.
