<!--
********************************************************************************
NOTICE: This file uses two trailing spaces to indicate line breaks for GitHub's
Markdown flavor. Do not remove!
********************************************************************************
-->

## Chapter 3: KERNAL

The Commander X16 contains a version of KERNAL as its operating system in ROM. It contains

* "Channel I/O" API for abstracting devices
* a variable size screen editor
* a color bitmap graphics API with proportional fonts
* simple memory management
* timekeeping
* drivers
	* PS/2 keyboard and mouse
	* NES/SNES controller
	* Commodore Serial Bus ("IEC")
	* I2C bus

### KERNAL Version

The KERNAL version can be read from location $FF80 in ROM. A value of $FF indicates a custom build. All other values encode the build number. Positive numbers are release versions ($02 = release version 2), two's complement negative numbers are prerelease versions ($FE = $100 - 2 = prerelease version 2).

### Compatibility Considerations

For applications to remain compatible between different versions of the ROM, they can rely upon:

* the KERNAL API

The following features must not be relied upon:

* the zero page and $0200+ memory layout
* direct function offsets in the ROM

### Commodore 64 API Compatibility

The KERNAL fully supports the C64 KERNAL API.

**Channel I/O:**  
$FF90: `SETMSG` – set verbosity  
$FFB7: `READST` – return status byte  
$FFBA: `SETLFS` – set LA, FA and SA  
$FFBD: `SETNAM` – set filename  
$FFC0: `OPEN` – open a channel  
$FFC3: `CLOSE` – close a channel  
$FFC6: `CHKIN` – set channel for character input  
$FFC9: `CHKOUT` – set channel for character output  
$FFCC: `CLRCHN` – restore character I/O to screen/keyboard  
$FFCF: `BASIN` – get character  
$FFD2: `BSOUT` – write character  
$FFD5: `LOAD` – load a file into memory  
$FFD8: `SAVE` – save a file from memory  
$FFE7: `CLALL` – close all channels  

**Commodore Peripheral Bus:**  
$FFB4: `TALK` – send TALK command  
$FFB1: `LISTEN` – send LISTEN command  
$FFAE: `UNLSN` – send UNLISTEN command  
$FFAB: `UNTLK` – send UNTALK command  
$FFA8: `CIOUT` – send byte to peripheral bus  
$FFA5: `ACPTR` – read byte from peripheral bus  
$FFA2: `SETTMO` – set timeout  
$FF96: `TKSA` – send TALK secondary address  
$FF93: `SECOND` – send LISTEN secondary address  

**Memory:**  
$FF9C: `MEMBOT` – read/write address of start of usable RAM  
$FF99: `MEMTOP` – read/write address of end of usable RAM  

**Time:**  
$FFDE: `RDTIM` – read system clock  
$FFDB: `SETTIM` – write system clock  
$FFEA: `UDTIM` – advance clock  

**Other:**  
$FFE1: `STOP` – test for STOP key  
$FFE4: `GETIN` – get character from keyboard  
$FFED: `SCREEN` – get the screen resolution  
$FFF0: `PLOT` – read/write cursor position  
$FFF3: `IOBASE` – return start of I/O area  

Some notes:

* For device #8, the Commodore Peripheral Bus calls first talk to the "Computer DOS" built into the ROM to detect an SD card, before falling back to the Commodore Serial Bus.
* The `IOBASE` call returns $9F60, the location of the first VIA controller.
* The `SETTMO` call has been a no-op since the Commodore VIC-20, and has no function on the X16 either.
* The `MEMTOP` call additionally returns the number of available RAM banks in the .A register.
* The layout of the zero page ($0000-$00FF) and the KERNAL/BASIC variable space ($0200+) are generally **not** compatible with the C64.
* The vectors ($0300-$0333) are fully compatible with the C64.

### Commodore 128 API Compatibility

In addition, the X16 supports a subset of the C128 API additions:

$FF4A: `CLOSE_ALL` – close all files on a device  
$FF8D: `LKUPLA` – search tables for given LA  
$FF8A: `LKUPSA` – search tables for given SA  
$FF62: `DLCHR` - activate a text mode font in the video hardware *[not yet implemented]*  
$FF65: `PFKEY` – program a function key *[not yet implemented]*  
$FF74: `FETCH` – LDA (fetvec),Y from any bank  
$FF77: `STASH` – STA (stavec),Y to any bank  
$FF7A: `CMPARE` – CMP (cmpvec),Y to any bank  
$FF7D: `PRIMM` – print string following the caller’s code  

Some notes:

* `FETCH`, `STASH` and `CMPARE` require the caller to set the zero page location containing the address in memory beforehand. These are different than on the C128:

|Call    |Label   |Address |
|--------|--------|--------|
|`FETCH` |`FETVEC`|$03AF   |
|`STASH` |`STAVEC`|$XXXX   |
|`CMPARE`|`CMPVEC`|$XXXX   |

*[Note: `STASH` and `CMPARE` are currently non-functional.]*

### New API for the Commander X16

There are lots of new APIs. Please note that their addresses and their behavior is still prelimiary and can change between revisions.

Some new APIs use the "16 bit" ABI, which uses virtual 16 bit registers r0 through r15, which are located in zero page locations $02 through $21: r0 = r0L = $02, r0H = $03, r1 = r1L = $04 etc.

The 16 bit ABI generally follows the following conventions:

* arguments
    * word-sized arguments: passed in r0-r5
    * byte-sized arguments: if three or less, passed in .A, .X, .Y; otherwise in 16 bit registers
    * boolean arguments: .C, .N
* return values
	* basic rules as above
    * function takes no arguments: r0-r5, else indirect through passed-in pointer
    * arguments in r0-r5 can be "inout", i.e. they can be updated
* saved/scratch registers
    * r0-r5: arguments (saved)
    * r6-r10: saved
    * r11-r15: scratch
    * .A, .X, .Y, .C, .N: scratch (unless used otherwise)

#### Commodore Peripheral Bus

$FF44: `MACPTR` - read multiple bytes from peripheral bus

##### Function Name: MACPTR

Purpose: Read multiple bytes from the peripheral bus  
Call address: $FF44  
Communication registers: .A, .X, .Y  
Preparatory routines: `FILNAM`, `FILPAR`, `OPEN`, `CHKIN`  
Error returns: None  
Stack requirements: ...  
Registers affected: .A, .X, .Y

**Description:** The routine `MACPTR` is the multi-byte variant of the `ACPTR` KERNAL routine. Instead of returning a single byte in .A, it can read multiple bytes in one call and write them directly to memory.

The number of bytes to be read is passed in the .A register; a value of 0 indicates that it is up to the KERNAL to decide how many bytes to read. A pointer to where the data is supposed to be written is passed in the .X (lo) and .Y (hi) registers.

Upon return, a set .C flag indicates that the device does not support `MACPTR`, and the program needs to read the data byte-by-byte using the `ACPTR` call instead.

If `MACPTR` is supported, .C is clear and .X (lo) and .Y (hi) contain the number of bytes read.

Like with `ACPTR`, the status of the operation can be retrieved using the `READST` KERNAL call.

#### Clock

$FF4D: `clock_set_date_time` - set date and time  
$FF50: `clock_get_date_time` - get date and time  

##### Function Name: clock_set_date_time

Purpose: Set the date and time  
Call address: $FF4D  
Communication registers: r0, r1, r2, r3L  
Preparatory routines: None  
Error returns: None  
Stack requirements: 0  
Registers affected: .A, .X, .Y

**Description:** The routine `clock_set_date_time` sets the system's real-time-clock.

| Register | Contents          |
|----------|-------------------|
| r0L      | year (1900-based) |
| r0H      | month (1-12)	   |
| r1L      | day (1-31)		   |
| r1H      | hours (0-23)	   |
| r2L      | minutes (0-59)	   |
| r2H      | seconds (0-59)	   |
| r3L      | jiffies (0-59)    |

Jiffies are 1/60th seconds.

##### Function Name: clock_get_date_time

Purpose: Get the date and time  
Call address: $FF50  
Communication registers: r0, r1, r2, r3L  
Preparatory routines: None  
Error returns: None  
Stack requirements: 0  
Registers affected: .A, .X, .Y

**Description:** The routine `clock_get_date_time` returns the state of the system's real-time-clock. The register assignment is identical to `clock_set_date_time`.

On the Commander X16, the *jiffies* field is unsupported and will always read back as 0.

#### Keyboard

$FEBD: `kbdbuf_peek` - get first char in keyboard queue and queue length  
$FEC0: `kbdbuf_get_modifiers` - get currently pressed modifiers  
$FEC3: `kbdbuf_put` - append a char to the keyboard queue
$FED2: `keymap` - set or get the current keyboard layout

##### Function Name: kbdbuf_peek

Purpose: Get next char and keyboard queue length  
Call address: $FEBD  
Communication registers: .A, .X  
Preparatory routines: None  
Error returns: None  
Stack requirements: 0  
Registers affected: -

**Description:** The routine `kbdbuf_peek` returns the next character in the keyboard queue in .A, without removing it from the queue, and the current length of the queue in .X. If .X is 0, the Z flag will be set, and the value of .A is undefined.

##### Function Name: kbdbuf_get_modifiers

Purpose: Get currently pressed modifiers  
Call address: $FEC0  
Communication registers: .A  
Preparatory routines: None  
Error returns: None  
Stack requirements: 0  
Registers affected: -

**Description:** The routine `kbdbuf_get_modifiers` returns a bitmask that represents the currently pressed modifier keys in .A:

| Bit | Value | Description  | Comment        |
|-----|-------|--------------|----------------|
| 0   | 1     | Shift        |                |
| 1   | 2     | Alt          | C64: Commodore |
| 2   | 4     | Control      |                |
| 3   | 8     | Logo/Windows | C128: Alt      |
| 4   | 16    | Caps         |                |

##### Function Name: kbdbuf_put

Purpose: Append a char to the keyboard queue  
Call address: $FEC3  
Communication registers: .A  
Preparatory routines: None  
Error returns: None  
Stack requirements: 0  
Registers affected: .X

**Description:** The routine `kbdbuf_put` appends the char in .A to the keyboard queue.

##### Function Name: keymap

Purpose: Set or get the current keyboard layout
Call address: $FED2  
Communication registers: .X , .Y
Preparatory routines: None  
Error returns: .C = 1 in case of error    
Stack requirements: 0  
Registers affected: -

**Description:** If .C is set, the routine `keymap` returns a pointer to a zero-terminated string with the current keyboard layout identifier in .X/.Y. If .C is clear, it sets the keyboard layout to the zero-terminated identifier pointed to by .X/.Y. On return, .C is set in case the keyboard layout is unsupported.

Keyboard layout identifiers are in the form "DE", "DE-CH" etc.

#### Mouse

$FF68: `mouse_config` - configure mouse pointer  
$FF71: `mouse_scan` - query mouse  
$FF6B: `mouse_get` - get state of mouse

##### Function Name: mouse_config

Purpose: Configure the mouse pointer  
Call address: $FF68  
Communication registers: .A, .X, .Y  
Preparatory routines: None  
Error returns: None  
Stack requirements: 0  
Registers affected: .A, .X, .Y

**Description:** The routine `mouse_config` configures the mouse pointer.

The argument in .A specifies whether the mouse pointer should be visible or not, and what shape it should have. For a list of possible values, see the basic statement `MOUSE`.

The arguments in .X and .Y specify the screen resolution in 8 pixel increments. The values .X = 0 and .Y = 0 keep the current resolution.

**EXAMPLE:**

	SEC
	JSR screen_mode ; get current screen size (in 8px) into .X and .Y
	LDA #1
	JSR mouse_config ; show the default mouse pointer

##### Function Name: mouse_scan

Purpose: Query the mouse and save its state  
Call address: $FF71  
Communication registers: None  
Preparatory routines: None  
Error returns: None  
Stack requirements: ?  
Registers affected: .A, .X, .Y

**Description:** The routine `mouse_scan` retrieves all state from the mouse and saves it. It can then be retrieved using `mouse_get`. The default interrupt handler already takes care of this, so this routine should only be called if the interrupt handler has been completely replaced.

##### Function Name: mouse_get

Purpose: Get the mouse state  
Call address: $FF6B  
Communication registers: .X  
Preparatory routines: `mouse_config`  
Error returns: None  
Stack requirements: 0  
Registers affected: .A

**Description:** The routine `mouse_get` returns the state of the mouse. The caller passes the offset of a zero-page location in .X, which the routine will populate with the mouse position in 4 consecutive bytes:

| Offset | Size | Description |
|--------|------|-------------|
| 0      | 2    | X Position  |
| 2      | 2    | Y Position  |

The state of the mouse buttons is returned in the .A register:

| Bit | Description   |
|-----|---------------|
| 0   | Left Button   |
| 1   | Right Button  |
| 2   | Middle Button |

If a button is pressed, the corresponding bit is set.

**EXAMPLE:**

	LDX #$70
	JSR mouse_get ; get mouse position in $70/$71 (X) and $72/$73 (Y)
	AND #1
	BNE BUTTON_PRESSED


#### Joystick

$FF53: `joystick_scan` - query joysticks  
$FF56: `joystick_get` - get state of one joystick

##### Function Name: joystick_scan

Purpose: Query the joysticks and save their state  
Call address: $FF53  
Communication registers: None  
Preparatory routines: None  
Error returns: None  
Stack requirements: 0  
Registers affected: .A, .X, .Y

**Description:** The routine `joystick_scan` retrieves all state from the four joysticks and saves it. It can then be retrieved using `joystick_get`. The default interrupt handler already takes care of this, so this routine should only be called if the interrupt handler has been completely replaced.

##### Function Name: joystick_get

Purpose: Get the state of one of the joysticks  
Call address: $FF56  
Communication registers: .A  
Preparatory routines: `joystick_scan`  
Error returns: None  
Stack requirements: 0  
Registers affected: .A, .X, .Y

**Description:** The routine `joystick_get` retrieves all state from one of the joysticks. The number of the joystick is passed in .A (0 for the keyboard joystick and 1 through 4 for SNES controllers), and the state is returned in .A, .X and .Y.

      .A, byte 0:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                  SNES | B | Y |SEL|STA|UP |DN |LT |RT |

      .X, byte 1:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
                  SNES | A | X | L | R | 1 | 1 | 1 | 1 |
      .Y, byte 2:
                  $00 = joystick present
                  $FF = joystick not present

If a button is pressed, the corresponding bit is zero.

(With a dedicated handler, the API can also be used for other devices with an SNES controller connector. The data returned in .A/.X/Y is just the raw 24 bits returned by the device.)

The keyboard joystick uses the standard SNES9X/ZSNES mapping:

| SNES Button    |Keyboard Key  | Alt. Keyboard Key |
|----------------|--------------|-------------------|
| A              | X            | Left Ctrl         |
| B              | Z            | Left Alt          |
| X              | S            |                   |
| Y              | A            |                   |
| L              | D            |                   |
| R              | C            |                   |
| START          | Enter        |                   |
| SELECT         | Left Shift   |                   |
| D-Pad          | Cursor Keys  |                   |

Note that the keyboard joystick will allow LEFT and RIGHT as well as UP and DOWN to be pressed at the same time, while controllers usually prevent this mechanically.

**How to Use:**

If the default interrupt handler is used:

1) Call this routine.

If the default interrupt handler is disabled or replaced:

1) Call `joystick_scan` to have the system query the joysticks.
2) Call this routine.

**EXAMPLE:**

      JSR joystick_scan
      LDA #0
      JSR joystick_get
      TXA
      AND #128
      BEQ A_PRESSED

#### I2C

$FEC6: `i2c_read_byte` - read a byte from an I2C device  
$FEC9: `i2c_write_byte` - write a byte to an I2C device

##### Function Name: i2c_read_byte

Purpose: Read a byte at a given offset from a given I2C device  
Call address: $FEC6  
Communication registers: .A, .X, .Y  
Preparatory routines: None  
Error returns: .C = 1 in case of error  
Stack requirements: [?]  
Registers affected: .A

**Description:** The routine `i2c_read_byte` reads a single byte at offset .Y from I2C device .X and returns the result in .A. .C is 0 if the read was successful, and 1 if no such device exists.

**EXAMPLE:**

	LDX #$6F ; RTC device
	LDY #$20 ; start of NVRAM inside RTC
	JSR i2c_read_byte ; read first byte of NVRAM

##### Function Name: i2c_write_byte

Purpose: Write a byte at a given offset to a given I2C device  
Call address: $FEC9  
Communication registers: .A, .X, .Y  
Preparatory routines: None  
Error returns: .C = 1 in case of error  
Stack requirements: [?]  
Registers affected: .A

**Description:** The routine `i2c_write_byte` writes the byte in .A at offset .Y of I2C device .X. .C is 0 if the write was successful, and 1 if no such device exists.

**EXAMPLES:**

	LDX #$6F ; RTC device
	LDY #$20 ; start of NVRAM inside RTC
	LDA #'X'
	JSR i2c_write_byte ; write first byte of NVRAM

	LDX #$42 ; System Management Controller
	LDY #$01 ; magic location for system poweroff
	LDA #$00 ; magic value for system poweroff
	JSR i2c_write_byte ; power off the system

#### Sprites

$FEF0: `sprite_set_image` - set the image of a sprite  
$FEF3: `sprite_set_position` - set the position of a sprite

##### Function Name: sprite_set_image

Purpose: Set the image of a sprite  
Call address: $FEF0  
Signature: bool sprite_set_image(byte number: .a, width: .x, height: .y, apply_mask: .c, word pixels: r0, word mask: r1, byte bpp: r2L);  
Error returns: .C = 1 in case of error

**Description:** This function sets the image of a sprite. The number of the sprite is given in .A, The bits per pixel (bpp) in r2L, and the width and height in .X and .Y. The pixel data at r0 is interpreted accordingly and converted into the graphics hardware's native format. If the .C flag is set, the transparency mask pointed to by r1 is applied during the conversion. The function returns .C = 0 if converting the data was successful, and .C = 1 otherwise. Note that this does not change the visibility of the sprite.

**Note**: There are certain limitations on the possible values of width, height, bpp and apply_mask:

* width and height may not exceed the hardware's capabilities.
* Legal values for bpp are 1, 4 and 8. If the hardware only supports lower depths, the image data is converted down.
* apply_mask is only valid for 1 bpp data.

##### Function Name: sprite_set_position

Purpose: Set the position of a sprite or hide it.  
Call address: $FEF3  
Signature: void sprite_set_position(byte number: .a, word x: r0, word y: r1);  
Error returns: None

**Description:** This function shows a given sprite (.A) at a certain position or hides it. The position is passed in r0 and r1. If the x position is negative (>$8000), the sprite will be hidden.

#### Framebuffer

The framebuffer API is a low-level graphics API that completely abstracts the framebuffer by exposing a minimal set of high-performance functions. It is useful as an abstraction and as a convenience library for applications that need high performance framebuffer access.

$FEF6: `FB_init` - enable graphics mode  
$FEF9: `FB_get_info` - get screen size and color depth  
$FEFC: `FB_set_palette` - set (parts of) the palette  
$FEFF: `FB_cursor_position` - position the direct-access cursor  
$FF02: `FB_cursor_next_line` - move direct-access cursor to next line  
$FF05: `FB_get_pixel` - read one pixel, update cursor  
$FF08: `FB_get_pixels` - copy pixels into RAM, update cursor  
$FF0B: `FB_set_pixel` - set one pixel, update cursor  
$FF0E: `FB_set_pixels` - copy pixels from RAM, update cursor  
$FF11: `FB_set_8_pixels` - set 8 pixels from bit mask (transparent), update cursor  
$FF14: `FB_set_8_pixels_opaque` - set 8 pixels from bit mask (opaque), update cursor  
$FF17: `FB_fill_pixels` - fill pixels with constant color, update cursor  
$FF1A: `FB_filter_pixels` - apply transform to pixels, update cursor  
$FF1D: `FB_move_pixels` - copy horizontally consecutive pixels to a different position

All calls are vectored, which allows installing a replacement framebuffer driver.

$02E4: I_FB_init  
$02E6: I_FB_get_info  
$02E8: I_FB_set_palette  
$02EA: I_FB_cursor_position  
$02EC: I_FB_cursor_next_line  
$02EE: I_FB_get_pixel  
$02F0: I_FB_get_pixels  
$02F2: I_FB_set_pixel  
$02F4: I_FB_set_pixels  
$02F6: I_FB_set_8_pixels  
$02F8: I_FB_set_8_pixels_opaque  
$02FA: I_FB_fill_pixels  
$02FC: I_FB_filter_pixels  
$02FE: I_FB_move_pixels

The model of this API is based on the direct-access cursor. In order to read and write pixels, the cursor has to be set to a specific x/y-location, and all subsequent calls will access consecutive pixels at the cursor position and update the cursor.

The default driver supports the VERA framebuffer at a resolution of 320x200 pixels and 256 colors. Using `screen_mode` to set mode $80 will enable this driver.

##### Function Name: FB_init

Signature: void FB_init();  
Purpose: Enter graphics mode.

##### Function Name: FB_get_info

Signature: void FB_get_info(out word width: r0, out word height: r1, out byte color_depth: .a);  
Purpose: Return the resolution and color depth

##### Function Name: FB_set_palette

Signature: void FB_set_palette(word pointer: r0, index: .a, byte count: .x);  
Purpose: Set (parts of) the palette

[Note: This is not yet implemented.]

##### Function Name: FB_cursor_position

Signature: void FB_cursor_position(word x: r0, word y: r1);  
Purpose: Position the direct-access cursor

**Description:** `FB_cursor_position` sets the direct-access cursor to the given screen coordinate. Future operations will access pixels at the cursor location and update the cursor.

##### Function Name: FB_cursor_next_line

Signature: void FB_cursor_next_line(word x: r0);  
Purpose: Move the direct-access cursor to next line

**Description:** `FB_cursor_next_line` increments the y position of the direct-access cursor, and sets the x position to the same one that was passed to the previous `FB_cursor_position` call. This is useful for drawing rectangular shapes, and faster than explicitly positioning the cursor.

##### Function Name: FB_get_pixel

Signature: byte FB_get_pixel();  
Purpose: Read one pixel, update cursor

##### Function Name: FB_get_pixels

Signature: void FB_get_pixels(word ptr: r0, word count: r1);  
Purpose: Copy pixels into RAM, update cursor

**Description:** This function copies pixels into an array in RAM. The array consists of one byte per pixel.

##### Function Name: FB_set_pixel

Signature: void FB_set_pixel(byte color: .a);  
Purpose: Set one pixel, update cursor

##### Function Name: FB_set_pixels

Signature: void FB_set_pixels(word ptr: r0, word count: r1);  
Purpose: Copy pixels from RAM, update cursor

**Description:** This function sets pixels from an array of pixels in RAM. The array consists of one byte per pixel.

##### Function Name: FB_set_8_pixels

Signature: void FB_set_8_pixels(byte pattern: .a, byte color: .x);  
Purpose: Set 8 pixels from bit mask (transparent), update cursor

**Description:** This function sets all 1-bits of the pattern to a given color and skips a pixel for every 0 bit. The order is MSB to LSB. The cursor will be moved by 8 pixels.

##### Function Name: FB_set_8_pixels_opaque

Signature: void FB_set_8_pixels_opaque(byte pattern: .a, byte mask: r0L, byte color1: .x, byte color2: .y);  
Purpose: Set 8 pixels from bit mask (opaque), update cursor

**Description:** For every 1-bit in the mask, this function sets the pixel to color1 if the corresponding bit in the pattern is 1, and to color2 otherwise. For every 0-bit in the mask, it skips a pixel. The order is MSB to LSB. The cursor will be moved by 8 pixels.

##### Function Name: FB_fill_pixels

Signature: void FB_fill_pixels(word count: r0, word step: r1, byte color: .a);  
Purpose: Fill pixels with constant color, update cursor

**Description:** `FB_fill_pixels` sets pixels with a constant color. The argument `step` specifies the increment between pixels. A value of 0 or 1 will cause consecutive pixels to be set. Passing a `step` value of the screen width will set vertically adjacent pixels going top down. Smaller values allow drawing dotted horizontal lines, and multiples of the screen width allow drawing dotted vertical lines.

*[Note: Only the values 0/1 and screen width are currently supported.]*

##### Function Name: FB_filter_pixels

Signature: void FB_filter_pixels(word ptr: r0, word count: r1);  
Purpose: Apply transform to pixels, update cursor

**Description:** This function allows modifying consecutive pixels. The function pointer will be called for every pixel, with the color in .a, and it needs to return the new color in .a.

##### Function Name: FB_move_pixels

Signature: void FB_move_pixels(word sx: r0, word sy: r1, word tx: r2, word ty: r3, word count: r4);  
Purpose: Copy horizontally consecutive pixels to a different position

*[Note: Overlapping regions are not yet supported.]*

#### Graphics

The high-level graphics API exposes a set of standard functions. It allows applications to easily perform some common high-level actions like drawing lines, rectangles and images, as well as moving parts of the screen. All commands are completely implemented on top of the framebuffer API, that is, they will continue working after replacing the framebuffer driver with one that supports a different resolution, color depth or even graphics device.

$FF20: `GRAPH_init` - initialize graphics  
$FF23: `GRAPH_clear` - clear screen  
$FF26: `GRAPH_set_window` - set clipping region  
$FF29: `GRAPH_set_colors` - set stroke, fill and background colors  
$FF2C: `GRAPH_draw_line` - draw a line  
$FF2F: `GRAPH_draw_rect` - draw a rectangle (optionally filled)  
$FF32: `GRAPH_move_rect` - move pixels  
$FF35: `GRAPH_draw_oval` - draw an oval or circle  
$FF38: `GRAPH_draw_image` - draw a rectangular image  
$FF3B: `GRAPH_set_font` - set the current font  
$FF3E: `GRAPH_get_char_size` - get size and baseline of a character  
$FF41: `GRAPH_put_char` - print a character

##### Function Name: GRAPH_init

Signature: void GRAPH_init(word vectors: r0);  
Purpose: Activate framebuffer driver, enter and initialize graphics mode

**Description**: This call activates the framebuffer driver whose vector table is passed in r0. If r0 is 0, the default driver is activated. It then switches the video hardware into graphics mode, sets the window to full screen, initializes the colors and activates the system font.

##### Function Name: GRAPH_clear

Signature: void GRAPH_clear();  
Purpose: Clear the current window with the current background color.

##### Function Name: GRAPH_set_window

Signature: void GRAPH_set_window(word x: r0, word y: r1, word width: r2, word height: r3);  
Purpose: Set the clipping region

**Description:** All graphics commands are clipped to the window. This function configures the origin and size of the window. All 0 arguments set the window to full screen.

*[Note: Only text output and GRAPH_clear currently respect the clipping region.]*

##### Function Name: GRAPH_set_colors

Signature: void GRAPH_set_colors(byte stroke: .a, byte fill: .x, byte background: .y);  
Purpose: Set the three colors

**Description:** This function sets the three colors: The stroke color, the fill color and the background color.

##### Function Name: GRAPH_draw_line

Signature: void GRAPH_draw_line(word x1: r0, word y1: r1, word x2: r2, word y2: r3);  
Purpose: Draw a line using the stroke color

##### Function Name: GRAPH_draw_rect

Signature: void GRAPH_draw_rect(word x: r0, word y: r1, word width: r2, word height: r3, word corner_radius: r4, bool fill: .c);  
Purpose: Draw a rectangle.

**Description:** This function will draw the frame of a rectangle using the stroke color. If `fill` is `true`, it will also fill the area using the fill color. To only fill a rectangle, set the stroke color to the same value as the fill color.

*[Note: The border radius is currently unimplemented.]*

##### Function Name: GRAPH_move_rect

Signature: void GRAPH_move_rect(word sx: r0, word sy: r1, word tx: r2, word ty: r3, word width: r4, word height: r5);  
Purpose: Copy a rectangular screen area to a different location

**Description:** `GRAPH_move_rect` coll copy a rectangular area of the screen to a different location. The two areas may overlap.

*[Note: Support for overlapping is not currently implemented.]*

##### Function Name: GRAPH_draw_oval

Signature: void GRAPH_draw_oval(word x: r0, word y: r1, word width: r2, word height: r3, bool fill: .c);  
Purpose: Draw an oval or a circle

**Description:** This function draws an oval filling the given bounding box. If width equals height, the resulting shape is a circle. The oval will be outlined by the stroke color. If `fill` is `true`, it will be filled using the fill color. To only fill an oval, set the stroke color to the same value as the fill color.

##### Function Name: GRAPH_draw_image

Signature: void GRAPH_draw_image(word x: r0, word y: r1, word ptr: r2, word width: r3, word height: r4);  
Purpose: Draw a rectangular image from data in memory

**Description:** This function copies pixel data from memory onto the screen. The representation of the data in memory has to have one byte per pixel, with the pixels organized line by line top to bottom, and within the line left to right.

##### Function Name: GRAPH_set_font

Signature: void GRAPH_set_font(void ptr: r0);  
Purpose: Set the current font

**Description:** This function sets the current font to be used for the remaining font-related functions. The argument is a pointer to the font data structure in memory, which must be in the format of a single point size GEOS font (i.e. one GEOS font file VLIR chunk). An argument of 0 will activate the built-in system font.

##### Function Name: GRAPH_get_char_size

Signature: (byte baseline: .a, byte width: .x, byte height_or_style: .y, bool is_control: .c) GRAPH_get_char_size(byte c: .a, byte format: .x);  
Purpose: Get the size and baseline of a character, or interpret a control code

**Description:** This functionality of `GRAPH_get_char_size` depends on the type of code that is passed in: For a printable character, this function returns the metrics of the character in a given format. For a control code, it returns the resulting format. In either case, the current format is passed in .x, and the character in .a.

* The format is an opaque byte value whose value should not be relied upon, except for `0`, which is plain text.
* The resulting values are measured in pixels.
* The baseline is measured from the top.

##### Function Name: GRAPH_put_char

Signature: void GRAPH_put_char(inout word x: r0, inout word y: r1, byte c: .a);  
Purpose: Print a character onto the graphics screen

**Description:** This function prints a single character at a given location on the graphics screen. The location is then updated. The following control codes are supported:

* $01: SWAP COLORS
* $04: ATTRIBUTES: UNDERLINE
* $06: ATTRIBUTES: BOLD
* $07: BELL
* $08: BACKSPACE
* $09: TAB
* $0A: LF
* $0B: ATTRIBUTES: ITALICS
* $0C: ATTRIBUTES: OUTLINE
* $0D/$8D: REGULAR/SHIFTED RETURN
* $11/$91: CURSOR: DOWN/UP
* $12: ATTRIBUTES: REVERSE
* $13/$93: HOME/CLEAR
* $14 DEL
* $92: ATTRIBUTES: CLEAR ALL
* all color codes

Notes:

* CR ($0D) SHIFT+CR ($8D) and LF ($0A) all set the cursor to the beginning of the next line. The only difference is that CR and SHIFT+CR reset the attributes, and LF does not.
* BACKSPACE ($08) and DEL ($14) move the cursor to the beginning of the previous character but does not actually clear it. Multiple consecutive BACKSPACE/DEL characters are not supported.
* There is no way to individually disable attributes (underlined, bold, reversed, italics, outline). The only way to disable them is to reset the attributes using code $92, which switches to plain text.
* All 16 PETSCII color codes are supported. Code $01 to swap the colors will swap the stroke and fill colors.
* The stroke color is used to draw the characters, and the underline is drawn using the fill color. In reverse text mode, the text background is filled with the fill color.
* *[BELL ($07), TAB ($09) and SHIFT+TAB ($18) are not yet implemented.]*

#### Console

$FEDB: `console_init` - initialize console mode  
$FEDE: `console_put_char` - print character to console  
$FED8: `console_put_image` - draw image as if it was a character  
$FEE1: `console_get_char` - get character from console  
$FED5: `console_set_paging_message` - set paging message or disable paging

The console is a screen mode that allows text output and input in proportional fonts that support the usual styles. It is useful for rich text-based interfaces.

##### Function Name: console_init

Signature: void console_init(word x: r0, word y: r1, word width: r2, word height: r3);  
Purpose: Initialize console mode.  
Call address: $FEDB

**Description:** This function initializes console mode. It sets up the window (text clipping area) passed into it, clears the window and positions the cursor at the top left. All 0 arguments create a full screen console. You have to switch to graphics mode using `screen_mode` beforehand.

##### Function Name: console_put_char

Signature: void console_put_char(byte char: .a, bool wrapping: .c);  
Purpose: Print a character to the console.  
Call address: $FEDE

**Description:** This function prints a character to the console. The .C flag specifies whether text should be wrapped at character (.C=0) or word (.C=1) boundaries. In the latter case, characters will be buffered until a SPACE, CR or LF character is sent, so make sure the text that is printed always ends in one of these characters.

**Note**: If the bottom of the screen is reached, this function will scroll its contents up to make extra room.

##### Function Name: console_put_image

Signature: void console_put_image(word ptr: r0, word width: r1, word height: r2);  
Purpose: Draw image as if it was a character.  
Call address: $FEE1

**Description:** This function draws an image (in GRAPH_draw_image format) at the current cursor position and advances the cursor accordingly. This way, an image can be presented inline. A common example would be an emoji bitmap, but it is also possible to show full-width pictures if you print a newline before and after the image.

**Notes**:

* If the bottom of the screen is reached, this function will scroll its contents up to make extra room.
* Subsequent line breaks will take the image height into account, so that the new cursor position is below the image.

##### Function Name: console_get_char

Signature: (byte char: .a) console_get_char();  
Purpose: Get a character from the console.  
Call address: $FEE1

**Description:** This function gets a character to the console. It does this by collecting a whole line of character, i.e. until the user presses RETURN. Then, the line will be sent character by character.

This function allows editing the line using BACKSPACE/DEL, but does not allow moving the cursor within the line, write more than one line, or using control codes.

##### Function Name: console_set_paging_message

Signature: void console_set_paging_message(word message: r0);  
Purpose: Set the paging message or disable paging.  
Call address: $FED5

**Description:** The console can halt printing after a full screen height worth of text has been printed. It will then show a message, wait for any key, and continue printing. This function sets this message. A zero-terminated text is passed in r0. To turn off paging, call this function with r0 = 0 - this is the default.

**Note:** It is possible to use control codes to change the text style and color. Do not use codes that change the cursor position, like CR or LF. Also, the text must not overflow one line on the screen.

#### Other

$FEE4: `memory_fill` - fill memory region with a byte value  
$FEE7: `memory_copy` - copy memory region  
$FEEA: `memory_crc` - calculate CRC16 of memory region  
$FEED: `memory_decompress` - decompress LZSA2 block  
$FECF: `entropy_get` - get 24 random bits  
$FF44: `monitor` - enter machine language monitor  
$FF47: `enter_basic` - enter BASIC  
$FF5F: `screen_mode` - get/set screen mode  
$FF62: `screen_set_charset` - activate 8x8 text mode charset

##### Function Name: memory_fill

Signature: void memory_fill(word address: r0, word num_bytes: r1, byte value: .a);  
Purpose: Fill a memory region with a byte value.  
Call address: $FEE4

**Description:** This function fills the memory region specified by an address (r0) and a size in bytes (r1) with the constant byte value passed in .A. r0 and .A are preserved, r1 is destroyed.

If the target address is in the $9F00-$9FFF range, all bytes will be written to the same address (r0), i.e. the address will not be incremented. This is useful for filling VERA memory ($9F23 or $9F24), for example.

##### Function Name: memory_copy

Signature: void memory_copy(word source: r0, word target: r1, word num_bytes: r2);  
Purpose: Copy a memory region to a different region.  
Call address: $FEE7

**Description:** This function copies one memory region specified by an address (r0) and a size in bytes (r2) to a different region specified by its start address (r1). The two regions may overlap. r0 and r1 are preserved, r2 is destroyed.

Like with `memory_fill`, source and destination addresses in the $9F00-$9FFF range will not be incremented during the copy. This allows, for instance, uploading data from RAM to VERA (destination of $9F23 or $9F24), downloading data from VERA (source $9F23 or $9F24) or copying data inside VERA (source $9F23, destination $9F24). This functionality can also be used to upload, download or transfer data with other I/O devices that have an 8 bit data port.

##### Function Name: memory_crc

Signature: (word result: r2) memory_crc(word address: r0, word num_bytes: r1);  
Purpose: Calculate the CRC16 of a memory region.  
Call address: $FEEA

**Description:** This function calculates the CRC16 checksum of the memory region specified by an address (r0) and a size in bytes (r1). The result is returned in r2. r0 is preserved, r1 is destroyed.

Like `memory_fill`, this function does not increment the address if it is in the range of $9F00-$9FFF, which allows checksumming VERA memory or data streamed from any other I/O device.

##### Function Name: memory_decompress

Signature: void memory_decompress(word input: r0, inout word output: r1);  
Purpose: Decompress an LZSA2 block  
Call address: $FEED

**Description:** This function decompresses an LZSA2-compressed data block from the location passed in r0 and outputs the decompressed data at the location passed in r1. After the call, r1 will be updated with the location of the last output byte plus one.

**Notes**:

* To create compressed data, use the `lzsa` tool[^1] like this:
`lzsa -r -f2 <original_file> <compressed_file>`
* This function cannot be used to decompress data in-place, as the output data would overwrite the input data before it is consumed. Therefore, make sure to load the input data to a different location.
* It is possible to have the input data stored in banked RAM, with the obvious 8 KB size restriction.

##### Function Name: entropy_get

Purpose: Get 24 random bits  
Call address: $FECF  
Communication registers: .A, .X, .Y  
Preparatory routines: None  
Error returns: None  
Registers affected: .A, .X, .Y

**Description:** This routine returns 24 somewhat random bits in registers .A, .X, and .Y. In order to get higher-quality random numbers, this data should be fed into a pseudo-random number generator.

**How to Use:**
1) Call this routine.

**EXAMPLE:**

    ; throw a dice
    again:
      JSR entropy_get
      STX tmp   ; combine 24 bits
      EOR tmp   ; using exclusive-or
      STY tmp   ; to get a higher-quality
      EOR tmp   ; 8 bit random value
      STA tmp
      LSR
      LSR
      LSR
      LSR       ; combine resulting 8 bits
      EOR tmp   ; to get 4 bits
      AND #7    ; we're down to values 0-7
      CMP #0
      BEQ again ; 0 is illegal
      CMP #7
      BEQ again ; 7 is illegal
      ORA #$30  ; convert to ASCII
      JMP $FFD2 ; print character

##### Function Name: monitor

Purpose: Enter the machine language monitor  
Call address: $FF44  
Communication registers: None  
Preparatory routines: None  
Error returns: Does not return  
Stack requirements: Does not return  
Registers affected: Does not return

**Description:** This routine switches from BASIC to machine language monitor mode. It does not return to the caller. When the user quits the monitor, it will restart BASIC.

**How to Use:**
1) Call this routine.

**EXAMPLE:**

      JMP monitor

##### Function Name: enter_basic

Purpose: Enter BASIC  
Call address: $FF47  
Communication registers: .C  
Preparatory routines: None  
Error returns: Does not return

**Description:** Call this to enter BASIC mode, either through a cold start (.C=1) or a warm start (.C=0).

**EXAMPLE:**

	CLC
	JMP enter_basic ; returns to the "READY." prompt


##### Function Name: screen_mode

Purpose: Get/Set the screen mode  
Call address: $FF5F  
Communication registers: .A, .X, .Y, .C  
Preparatory routines: None  
Error returns: .C = 1 in case of error  
Stack requirements: 4  
Registers affected: .A, .X, .Y

**Description:** If .C is set, a call to this routine gets the current screen mode in .A, the width (in tiles) of the screen in .X, and the height (in tiles) of the screen in .Y. If .C is clear, it sets the current screen mode to the value in .A. For a list of possible values, see the basic statement `SCREEN`. If the mode is unsupported, .C will be set, otherwise cleared.

**EXAMPLE:**

	LDA #$80
	CLC
	JSR screen_mode ; SET 320x200@256C MODE
	BCS FAILURE

##### Function Name: screen_set_charset

Purpose: Activate a 8x8 text mode charset  
Call address: $FF62

Communication registers: .A, .X, .Y  
Preparatory routines: None  
Stack requirements: [?]  
Registers affected: .A, .X, .Y

**Description:** A call to this routine uploads a character set to the video hardware and activates it. The value of .A decides what charset to upload:

| Value | Description          |
|-------|----------------------|
| 0     | use pointer in .X/.Y |
| 1     | ISO                  |
| 2     | PET upper/graph      |
| 3     | PET upper/lower      |

If .A is zero, .X (lo) and .Y (hi) contain a pointer to a 2 KB RAM area that gets uploaded as the new 8x8 character set. The data has to consist of 256 characters of 8 bytes each, top to bottom, with the MSB on the left and set bits representing the foreground color.

**EXAMPLE:**

	LDA #0
	LDX #<MY_CHARSET
	LDY #>MY_CHARSET
	JSR screen_set_charset ; UPLOAD CUSTOM CHARSET "MY_CHARSET"

##### Function Name: JSRFAR

Purpose: Execute a routine on another RAM or ROM bank  
Call address: $FF6E  
Communication registers: None  
Preparatory routines: None  
Error returns: None  
Stack requirements: 4  
Registers affected: None

**Description:** The routine `JSRFAR` enables code to execute some other code located on a specific RAM or ROM bank. This works independently of which RAM or ROM bank the currently executing code is residing in.
The 16 bit address and the 8 bit bank number have to follow the instruction stream. The `JSRFAR` routine will switch both the ROM and the RAM bank to the specified bank and restore it after the routine's `RTS`. Execution resumes after the 3 byte arguments.
**Note**: The C128 also has a `JSRFAR` function at $FF6E, but it is incompatible with the X16 version.

**How to Use:**
1) Call this routine.

**EXAMPLE:**

      JSR JSRFAR
      .WORD $C000 ; ADDRESS
      .BYTE 1     ; BANK

### Custom Keyboard Scan Code Handler

On receiving a keyboard scan code, the KERNAL jumps to the address stored in $032E-032F. This makes it possible to implement custom scan code handlers that extend or override the default behavior of the KERNAL.

Input set by the KERNAL: .X = PS/2 prefix, .A = PS/2 scan code, carry clear if key down and set if key up event.

Return from a custom handler with RTS. The KERNAL will continue handling the scan code according to the values of .X, .A and carry. To remove a keypress, return .A = 0.

```
;EXAMPLE: A custom handler that prints "A" on Alt key down

setup:
    sei
    lda #<keyhandler
    sta $032e
    lda #>keyhandler
    sta $032f
    cli
    rts

keyhandler:
    php         ;Save input on stack
    pha
    phx

    bcs exit    ;C=1 is key up

    cmp #$11    ;Alt key scan code
    bne exit

    lda #'a'
    jsr $ffd2

exit:
    plx		;Restore input
    pla
    plp
    rts		;Return control to Kernal
```

---

[^1]: [https://github.com/emmanuel-marty/lzsa](https://github.com/emmanuel-marty/lzsa)
