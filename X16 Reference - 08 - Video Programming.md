## Chapter 7: Video Programming

The VERA video chip supports resolutions up to 640x480 with up to 256 colors from a palette of 4096, two layers of either a bitmap or tiles, 128 sprites of up to 64x64 pixels in size. It can output VGA as well as a 525 line interlaced signal, either as NTSC or as RGB (Amiga-style).

See the [VERA Programmer's Reference](VERA%20Programmer's%20Reference.md) for the complete reference.

The X16 KERNAL uses the following video memory layout:

|Addresses    |Description                                   |
|-------------|----------------------------------------------|
|$00000-$12BFF|320x240@256c Bitmap                           |
|$12C00-$12FFF|*unused*                                      |
|$13000-$1AFFF|Sprites ($1000 per sprite)                    |
|$1B000-$1EBFF|Text Mode                                     |
|$1EC00-$1EFFF|*unused*                                      |
|$1F000-$1F7FF|Charset                                       |
|$1F800-$1F9BF|*unused*                                      |
|$1F9C0-$1FFFF|VERA internal (PSG, Palette, Sprite Registers)|

Application software is free to use any part of video RAM if it does not use the corresponding KERNAL functionality. To restore text mode, call `CINT` ($FF81).
