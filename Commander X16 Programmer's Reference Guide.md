# Commander X16 Programmer's Reference Guide

*Michael Steil, mist64@mac.com*

*This is the PRELIMINARY Programmer's Reference Guide for the Commander X16 computer. Every and any information in this document can change, as the product is still in development!*

**Table of contents**

<!-- generated with https://github.com/ekalinin/github-markdown-toc -->

* [Overview](#overview)
* [BASIC Programming](#basic-programming)
	* [Commodore 64 Compatibility](#commodore-64-compatibility)
	* [ISO Mode](#iso-mode)
	* [New Control Characters](#new-control-characters)
	* [New Statements and Functions](#new-statements-and-functions)
		* [DOS](#dos)
		* [MON](#mon)
		* [VPEEK](#vpeek)
		* [VPOKE](#vpoke)
	* [Other New Features](#other-new-features)
	* [Internal Representation](#internal-representation)
* [KERNAL](#kernal)
	* [Commodore 64 API Compatibility](#commodore-64-api-compatibility)
	* [Commodore 128 API Compatibility](#commodore-128-api-compatibility)
	* [New API for the Commander X16](#new-api-for-the-commander-x16)
	* [KERNAL Version](#kernal-version)
	* [Compatibility Considerations](#compatibility-considerations)
		* [Function Name: GETJOY](#function-name-getjoy)
		* [Function Name: JSRFAR](#function-name-jsrfar)
		* [Function Name: MONITOR](#function-name-monitor)
* [Machine Language Monitor](#machine-language-monitor)
* [Memory Map](#memory-map)
	* [Banked Memory](#banked-memory)
	* [ROM Allocations](#rom-allocations)
	* [RAM Contents](#ram-contents)
	* [I/O Area](#io-area)
* [Video Programming](#video-programming)
* [Sound Programming](#sound-programming)
* [I/O Programming](#io-programming)


## Overview

The Commander X16 is a modern home computer in the philosophy of Commodore computers like the VIC-20 and the C64.

**Features:**

* 8-bit 65C02 CPU at 8 MHz
* 512 KB or 2 MB RAM
* 128 KB ROM
* VERA video controller
	* up to 640x480 resolution
	* 256 colors from a palette of 4096
	* 128 sprites
	* VGA, NTSC and RGB output
* *[sound controller TBD]*
* Connectivity:
	* PS/2 keyboard and mouse
	* 2 NES/SNES controllers
	* SD card
	* Commodore Serial Bus ("IEC")
	* several free GPIOs ("user port")

As a modern sibling of the line of Commodore home computers, the Commander X16 is resaonably compatible with computers of that line.

* Pure BASIC programs are fully backwards compatible with the VIC-20 and the C64.
* POKEs for video and audio are not compatible with any Commodore computer. (There are no VIC or SID controllers, for example.)
* Pure machine language programs ($FF81+ KERNAL API) are compatible with Commodore computers.

## BASIC Programming

### Commodore 64 Compatibility

The Commander X16 BASIC interpreter is 100% backwards-compatible with the Commodore 64 one. This includes the following features:

* All statements and functions
* Strings, arrays, integers, floats
* Max. 80 character BASIC lines
* Printing "quote mode" control characters like cursor control and color codes, e.g.:
	* `CHR$(147)`: clear screen
	* `CHR$(5)`: white text
	* `CHR$(18)`: reverse
	* `CHR$(14)`: switch to upper/lowercase font
	* `CHR$(142)`: switch to uppercase/graphics font

Because of the differences in hardware, the following functions and statements are incompatible between C64 and X16 BASIC programs.

* `POKE`: write to a memory address
* `PEEK`: read from a memory address
* `WAIT`: wait for memory contents
* `SYS`: execute machine language code

The BASIC interpreter also currently shares all problems of the C64 version, like the slow garbage collector.

### ISO Mode

In addition to PETSCII, the X16 also supports the ISO-8859-15 character encoding. In ISO-8859-15 mode ("ISO mode"):

* The character set is switched from Commodore-style (with PETSCII drawing characters) to a new ASCII/ISO-8859-15 compatible set, which covers most Western European writing systems.
* The encoding (`CHR$()` in BASIC and `BSOUT` in machine language) now complies with ASCII and ISO-8859-15.
* The keyboard driver will return ASCII/ISO-8859-15 codes.

This is the encoding:

	   0123456789ABCDEF
	0x|                |
	1x|                |
	2x| !"#$%&'()*+,-./|
	3x|0123456789:;<=>?|
	4x|@ABCDEFGHIJKLMNO|
	5x|PQRSTUVWXYZ[\]^_|
	6x|`abcdefghijklmno|
	7x|pqrstuvwxyz{|}~ |
	8x|                |
	9x|                |
	Ax| ¡¢£€¥Š§š©ª«¬ ®¯|
	Bx|°±²³Žµ¶·ž¹º»ŒœŸ¿|
	Cx|ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏ|
	Dx|ÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞß|
	Ex|àáâãäåæçèéêëìíîï|
	Fx|ðñòóôõö÷øùúûüýþÿ|

ISO mode can be enabled and disabled using two new control codes:

* `CHR$($0F)`: enable ISO mode
* `CHR$($8F)`: disable ISO mode (default)

You can also enable ISO mode in direct mode by pressing Ctrl+`O`.

**Important:** In ISO mode, BASIC keywords need to be written in upper case, that is, they have to be entered with the Shift key down, and abbreviating keywords is no longer possible.

### New Control Characters

The following PETSCII control characters have been added compared to the C64:

| Code | Descrption             | Comment                            |
|------|------------------------|------------------------------------|
| $09  | TAB                    | same as on C128/C65; key code only |
| $0F  | enable ISO mode        |                                    |
| $10  | F9                     | same as on C65                     |
| $18  | Shift + TAB            | same as on C128/C65; key code only |
| $15  | F10                    | same as on C65                     |
| $16  | F11                    | same as on C65                     |
| $17  | F12                    | same as on C65                     |
| $83  | RUN                    | same as on C65                     |
| $84  | HELP                   | same as on C65                     |
| $8F  | disable ISO mode       |                                    |

Some of these codes are also supported on the C128 or the C65.

### Keyboard Layouts

Pressing the `F9` key cycles through the available keyboard layouts.

### New Statements and Functions

There are several new statement and functions. Note that all BASIC keywords (such as `FOR`) get converted into tokens (such as `$81`), and the tokens for the new keywords have not been finalized yet. Therefore, loading BASIC program saved from a different revision of BASIC may mix up keywords.


#### GEOS

**TYPE: Command**
**FORMAT: GEOS**

**Action:** Enter the GEOS UI.

#### CHAR

**TYPE: Command**
**FORMAT: CHAR &lt;x&gt;,&lt;y&gt;,&lt;color&gt;,&lt;string&gt;**

**Action:** This command draws a text string on the graphics screen in a given color.

The string can contain printable ASCII characters (`CHR$($20)` to `CHR$($7E)`), as well as the following GEOS control codes:

| Code | Description     |
|------|-----------------|
| 13   | Carriage Return |
| 14   | Underline       |
| 18   | Reverse         |
| 24   | Bold            |
| 25   | Italics         |
| 26   | Outline         |
| 27   | Plain text      |

**EXAMPLE of CHAR Statement:**

	10 SCREEN$80
	20 A$="The quick brown fox jumps over the lazy dog."
	24 CHAR0,6,0,A$
	30 CHAR0,6+12,0,CHR$(14)+A$
	40 CHAR0,6+12*2,0,CHR$(18)+A$
	50 CHAR0,6+12*3,0,CHR$(24)+A$
	60 CHAR0,6+12*4,0,CHR$(25)+A$
	70 CHAR0,6+12*5,0,CHR$(26)+A$

#### COLOR

**TYPE: Command**
**FORMAT: COLOR &lt;fgcol&gt;[,&lt;bgcol&gt;]**

**Action:** This command works sets the text mode foreground color, and optionally the background color.

**EXAMPLES of COLOR Statement:**

      COLOR 2   : SET FG COLOR TO RED, KEEP BG COLOR
      COLOR 2,0 : SET FG COLOR TO RED, BG COLOR TO BLACK

#### DOS

**TYPE: Command**
**FORMAT: DOS &lt;string&gt;**

**Action:** This command works with the command/status channel or the directory of a Commodore DOS device and has different functionality depending on the type of argument.

* Without an argument, `DOS` prints the status string of the current device.
* With a string argument of `"8"` or `"9"`, it switches the current device to the given number.
* With an argument starting with `"$"`, it shows the directory of the device.
* Any other argument will be sent as a DOS command.

**EXAMPLES of DOS Statement:**

      DOS"$"          : REM SHOWS DIRECTORY
      DOS"S:BAD_FILE" : REM DELETES "BAD_FILE"
      DOS             : REM PRINTS DOS STATUS, E.G. "01,FILES SCRATCHED,01,00"

#### FRAME

**TYPE: Command**
**FORMAT: FRAME &lt;x1&gt;,&lt;y1&gt;,&lt;x2&gt;,&lt;y2&gt;,&lt;color&gt;**

**Action:** This command draws a rectangle frame on the graphics screen in a given color.

**EXAMPLE of FRAME Statement:**

	10 SCREEN$80
	20 FORI=1TO20:FRAMERND(1)*320,RND(1)*200,RND(1)*320,RND(1)*200,RND(1)*128:NEXT
	30 GOTO20

#### LINE

**TYPE: Command**
**FORMAT: LINE &lt;x1&gt;,&lt;y1&gt;,&lt;x2&gt;,&lt;y2&gt;,&lt;color&gt;**

**Action:** This command draws a line on the graphics screen in a given color.

**EXAMPLE of LINE Statement:**

	10 SCREEN128
	20 FORA=0TO2*\XFFSTEP2*\XFF/200
	30 LINE100,100,100+SIN(A)*100,100+COS(A)*100
	40 NEXT

#### MON

**TYPE: Command**
**FORMAT: MON**

**Action:** This command enters the machine language monitor. See the dedicated chapter for a  description.

**EXAMPLE of MON Statement:**

      MON

#### MOUSE

**TYPE: Command**
**FORMAT: MOUSE &lt;mode&gt;**

**Action:** This command configures the mouse pointer.

| Mode | Description                              |
|------|------------------------------------------|
| 0    | Hide mouse                               |
| 1    | Show mouse, set default mouse pointer    |
| $FF  | Show mouse, don't configure mouse cursor |

`MOUSE 1` turns on the mouse pointer and `MOUSE 0` turns it off. If the BASIC program has its own mouse pointer sprite configured, it can use `MOUSE $FF`, which will turn the mouse pointer on, but not set the default pointer sprite.

**EXAMPLES of MOUSE Statement:**

	MOUSE 1 : REM ENABLE MOUSE
	MOUSE 0 : REM DISABLE MOUSE

#### MX/MY/MB

**TYPE: Integer Function**
**FORMAT: MX**
**FORMAT: MY**
**FORMAT: MB**

**Action:** Return the horizontal (`MX`) or vertical (`MY`) position of the mouse pointer, or the mouse button state (`MB`).

`MB` returns the sum of the following values depending on the state of the buttons:

| Value | Button |
|-------|--------|
| 0     | none   |
| 1     | left   |
| 2     | right  |
| 4     | third  |

**EXAMPLE of MX/MY/MB Functions:**

	REM SIMPLE DRAWING PROGRAM
	10 SCREEN$80
	20 MOUSE1
	25 OB=0
	30 TX=MX:TY=MY:TB=MB
	35 IFTB=0GOTO25
	40 IFOBTHENLINEOX,OY,TX,TY,16
	50 IFOB=0THENPSETTX,TY,16
	60 OX=TX:OY=TY:OB=TB
	70 GOTO30

#### OLD

**TYPE: Command**
**FORMAT: OLD**

**Action:** This command recovers the BASIC program in RAM that has been previously deleted using the `NEW` command or through a RESET.

**EXAMPLE of OLD Statement:**

      OLD

#### PSET

**TYPE: Command**
**FORMAT: PSET &lt;x&gt;,&lt;y&gt;,&lt;color&gt;**

**Action:** This command sets a pixel on the graphics screen to a given color.

**EXAMPLE of PSET Statement:**

	10 SCREEN$80
	20 FORI=1TO20:PSETRND(1)*320,RND(1)*200,RND(1)*256:NEXT
	30 GOTO20

#### RECT

**TYPE: Command**
**FORMAT: RECT &lt;x1&gt;,&lt;y1&gt;,&lt;x2&gt;,&lt;y2&gt;,&lt;color&gt;**

**Action:** This command draws a solid rectangle on the graphics screen in a given color.

**EXAMPLE of RECT Statement:**

	10 SCREEN$80
	20 FORI=1TO20:RECTRND(1)*320,RND(1)*200,RND(1)*320,RND(1)*200,RND(1)*256:NEXT
	30 GOTO20

#### SCREEN

**TYPE: Command**
**FORMAT: SCREEN &lt;mode&gt;**

**Action:** This command switches the screen mode. Modes $80 (128) and above are graphics modes.

| Mode | Description | Comment |
|------|-------------|---------|
| $00  | 40x30 text  |         |
| $01  | 80x30 text  | (currently unsupported) |
| $02  | 80x60 text  |
| $80  | 320x200@256c<br/>40x25 text | |
| $81  | 640x400@16c | (currently unsupported) |

The value of $FF (255) toggles between modes $00 and $02.

#### VPEEK

**TYPE: Integer Function**
**FORMAT: VPEEK (&lt;bank&gt;, &lt;address&gt;)**

**Action:** Return a byte from the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPEEK Function:**

      PRINT (VPEEK($F,$2000) AND $E0) / 32 : REM PRINTS THE CURRENT MODE (0-7)

#### VPOKE

**TYPE: Command**
**FORMAT: VPOKE &lt;bank&gt;, &lt;address&gt;, &lt;value&gt;**

**Action:** Set a byte in the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPOKE Statement:**

      VPOKE 0,1,1 * 16 + 2 : REM SETS THE COLORS OF THE CHARACTER
                             REM AT 0/0 TO RED ON WHITE

#### VLOAD

*TODO*

### Other New Features

The numeric constants parser supports both hex (`$`) and binary (`%`) literals, like this:

      PRINT $EA31 + %1010

The size of hex and binary values is only restricted by the range that can be represented by BASIC's internal floating point representation.

In regular BASIC text mode, the video controller supports 16 foreground colors and 16 background colors for each character on the screen. The new `COLOR` statement (described above) allows changing the foreground color and optionally the background color. Machine code programs can currently write the to the `color` location ($02CC) in the KERNAL variables area, which has the following layout:

|Bits |Description      |
|-----|-----------------|
|0-3  |Foreground color |
|4-7  |Background color |

To set the background color of the complete screen, it just has to be cleared after setting the color:

      PRINT CHR$(147)

In BASIC, both an 80x60 and a 40x30 character text mode is supported. To switch modes, use the BASIC statement `SCREEN`:

      SCREEN 0 : REM SWITCH TO 40 CHARACTER MODE
      SCREEN 2 : REM SWITCH TO 80 CHARACTER MODE
      SCREEN 255 : REM SWITCH BETWEEN 40 and 80 CHARACTER MODE

In BASIC, the contents of files can be directly loaded into VRAM with the `LOAD` statement. When a secondary address greater than one is used, the KERNAL will now load the file into the VERA's VRAM address space. The first two bytes of the file are used as lower 16 bits of the address. The upper 4 bits are `(SA-2) & 0x0ff` where `SA` is the secondary address.

Examples:

	  10 REM LOAD VERA SETTINGS
	  20 LOAD"VERA.BIN",1,18 : REM SET ADDRESS TO $FXXXX
	  30 REM LOAD TILES
	  40 LOAD"TILES.BIN",1,3 : REM SET ADDRESS TO $1XXXX
	  50 REM LOAD MAP
      60 LOAD"MAP.BIN",1,2 : REM SET ADDRESS TO $0XXXX

### Internal Representation

Like on the C64, BASIC keywords are tokenized.

* The C64 BASIC V2 keywords occupy the range of $80 (`END`) to $CB (`GO`).
* BASIC V3.5 also used $CE (`RGR`) to $FD (`WHILE`).
* BASIC V7 introduced the $CE escape code for function tokens $CE-$02 (`POT`) to $CE-$0A (`POINTER`), and the $FE escape code for statement tokens $FE-$02 (`BANK`) to $FE-$38 (`SLOW`).
* The unreleased BASIC V10 extended the escaped tokens up to $CE-$0D (`RPALETTE`) and $FE-$45 (`EDIT`).

The X16 BASIC aims to be as compatible as possible with this encoding. Keywords added to X16 BASIC that also exist in other versions of BASIC match the token, and new keywords are encoded in the ranges $CE-$80+ and $FE-$80+.

## KERNAL

The Commander X16 contains a version of KERNAL as its operating system in ROM. It contains

* a 40/80 character screen driver
* a PS/2 keyboard driver
* a PS/2 mouse driver
* an NES/SNES controller driver
* a Commodore Serial Bus ("IEC") driver *[not yet working]*
* an RS-232 driver *[not yet working]*
* "Channel I/O" for abstracting devices
* simple memory management
* timekeeping

### KERNAL Version

The KERNAL version can be read from location $FF80 in ROM. A value of $FF indicates a custom build. All other values encode the build number. Positive numbers are release versions ($02 = release version 2), two's complement negative numbers are prerelease versions ($FE = $100 - 2 = prerelease version 2).

### Compatibility Considerations

For applications to remain compatible between different versions of the ROM, they can rely upon:

* the KERNAL API

The following is guaranteed to remain mostly stable:

* the $0000-$03FF memory layout

And the following features must not be relied upon:

* direct function offsets in the ROM

That is, don't jump into undocumented ROM code directly, or reuse undocumented data constants in ROM.

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
$FFA8: `IECOUT` – send byte to serial bus
$FFA5: `IECIN` – read byte from serial bus
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
* The layout of the zero page ($0000-$00FF) and the KERNAL/BASIC variable space ($0200-$02FF) are generally **not** compatible with the C64.
* The vectors ($0300-$0333) are fully compatible with the C64.

### Commodore 128 API Compatibility

In addition, the X16 supports a subset of the C128 API additions:

$FF4A: `CLOSE_ALL` – close all files on a device
$FF53: `BOOT_CALL` – boot load program from disk *[not yet implemented]*
$FF8D: `LKUPLA` – search tables for given LA
$FF8A: `LKUPSA` – search tables for given SA
$FF65: `PFKEY` – program a function key *[not yet implemented]*
$FF74: `FETCH` – LDA (fetvec),Y from any bank
$FF77: `STASH` – STA (stavec),Y to any bank
$FF7A: `CMPARE` – CMP (cmpvec),Y to any bank
$FF7D: `PRIMM` – print string following the caller’s code

Some notes:

* `FETCH`, `STASH` and `CMPARE` require the caller to set the zero page location containing the address in memory beforehand. These are different than on the C128:

|Call    |Label   |Address |
|--------|--------|--------|
|`FETCH` |`FETVEC`|$0384   |
|`STASH` |`STAVEC`|$03A6   |
|`CMPARE`|`CMPVEC`|$03C2   |

### New API for the Commander X16

There are a few new APIs. Please note that their addresses and their behavior is still prelimiary and can change between revisions.

$FF00: `MONITOR` – enter montior
$FF06: `GETJOY` – query joysticks
$FF09: `MOUSE` – control mouse
$FF6E: `JSRFAR` – gosub in another bank
$FF5F: `SCRMOD` – get/set screen mode

#### Function Name: GETJOY

Purpose: Query the joysticks and store their state in the zeropage
Call address: $FF06 (hex) 65286 (decimal)
Communication registers: None
Preparatory routines: None
Error returns: None
Stack requirements: 0
Registers affected: .A, .X, .Y

**Description:** The routine `GETJOY` retrieves all state from the two joysticks and stores it in the memory locations `JOY1` ($02BC-$02BE) and `JOY2` ($02BF-$02C1).

Each of these symbols consist of 3 bytes with the following layout:

      byte 0:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
              NES  | A | B |SEL|STA|UP |DN |LT |RT |
              SNES | B | Y |SEL|STA|UP |DN |LT |RT |

      byte 1:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
              NES  | 0 | 0 | 0 | 0 | 0 | 0 | 0 | X |
              SNES | A | X | L | R | 1 | 1 | 1 | 1 |
      byte 2:
              $00 = joystick present
              $FF = joystick not present

If joystick 1 is not present, it will fall back to returning the state of the keyboard, if present:

|Keyboard Key  | NES Equivalent |
|--------------|----------------|
|Ctrl          | A 		|
|Alt 	       | B		|
|Space         | SELECT         |
|Enter         | START		|
|Cursor Up     | UP		|
|Cursor Down   | DOWN		|
|Cursor Left   | LEFT		|
|Cursor Right  | RIGHT		|

* Presence of a joystick can be detected by checking byte 2.
* The type of controller is encoded in bits 0-3 in byte 1:

|Value|Type               |
|-----|-------------------|
|0000 |NES		  |
|0001 |keyboard (NES-like)|
|1111 |SNES		  |

* If a button is pressed, the corresponding bit is zero.
* Note that bits 6 and 7 in byte 0 map to different buttons on NES and SNES.

**How to Use:**
1) Call this routine.
2) Read joystick state from `JOY1` and `JOY2`.

**EXAMPLE:**

      JSR GETJOY
      LDA JOY1
      AND #128
      BEQ NES_A_PRESSED

#### Function Name: JSRFAR

Purpose: Execute a routine on another RAM or ROM bank
Call address: $FF6E (hex) 65390 (decimal)
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

#### Function Name: MONITOR

Purpose: Enter the machine language monitor
Call address: $FF00 (hex) 65280 (decimal)
Communication registers: None
Preparatory routines: None
Error returns: Does not return
Stack requirements: Does not return
Registers affected: Does not return

**Description:** This routine switches from BASIC to machine language monitor mode. It does not return to the caller. When the user quits the monitor, it will restart BASIC.

**How to Use:**
1) Call this routine.

**EXAMPLE:**

      JMP MONITOR

#### Function Name: MOUSE

Purpose: Configure the mouse pointer
Call address: $FF09 (hex) 65289 (decimal)
Communication registers: .A, .X
Preparatory routines: None
Error returns: None
Stack requirements: 0
Registers affected: .A, .X, .Y

**Description:** The routine `MOUSE` configures the mouse pointer.

The argument in .A specifies whether the mouse pointer should be visible or not, and what shape it should have. For a list of possible values, see the basic statement `MOUSE`.

The argument in .X specifies the scale. Use a scale of 1 for a 640x480 screen, and a scale of 2 for a 320x240 screen. A value of 0 does not change the scale.

**EXAMPLE:**

	LDA #1
	JSR MOUSE ; show the default mouse pointer

#### Function Name: SCRMOD

Purpose: Set the screen mode
Call address: $FF5F (hex) 65375 (decimal)
Communication registers: .A
Preparatory routines: None
Error returns: .C = 1 in case of error
Stack requirements: [?]
Registers affected: .A, .X, .Y

**Description:** A call to this routine, with the carry flag
set, sets the current screen mode to the value in .A. For a list of possible values, see the basic statement `SCREEN`. A call with the carry bit clear returns the current mode in .A.

**EXAMPLE:**

	LDA #$80
	SEC
	JSR SCRMOD ; SET 320x200@256C MODE
	BCS FAILURE

## Machine Language Monitor

The built-in machine language monitor can be started with the `MON` BASIC command. It is based on the monitor of the Final Cartridge III and supports all its features. See the [Final Cartridge III Manual](https://rr.pokefinder.org/rrwiki/images/7/70/Final_Cartridge_III_english_Manual.pdf) more more information.

If you invoke the monitor by mistake, you can exit with by typing `X`, followed by the `RETURN` key.

Some features specific to this monitor are:
* The `I` command prints a CBM-ASCII-encoded memory dump.
* The `EC` command prints a binary memory dump. This is also useful for character sets.
* Scrolling the screen with the cursors or F3/F5 will continue memory dumps and disassemblies, and even disassemble backwards.

The following additions have been made:

* The instruction set extensions of the 65C02 are supported.
* The `O` command takes an 8 bit hex value as an argument and sets it as the ROM and RAM bank for reading and writing memory contents. The following example disassembles the beginning of the CBDOS ROM on bank 5:

      O05
      DC000 C015

* The `OV` command takes a 4 bit hex value as an argument and sets it as the bank in the video address space for reading and writing memory contents. The following example shows the character ROM in the video controller's address space:

      OV1
      ECF000 F00F

*[TODO: Full documentation]*

## Memory Map

The Commander X16 has 64 KB of ROM and 2,088 KB (2 MB[^1] + 40 KB) of RAM. Some of the ROM and RAM is always visible at certain address ranges, while the remaining ROM and RAM is banked into one of two address windows.

This is an overview of the X16 memory map:

|Addresses  |Description                                                       |
|-----------|------------------------------------------------------------------|
|$0000-$9EFF|Fixed RAM (40 KB minus 256 bytes)								   |
|$9F00-$9FFF|I/O Area (256 bytes)											   |
|$A000-$BFFF|Banked RAM (8 KB window into one of 256 banks for a total of 2 MB)|
|$C000-$FFFF|Banked ROM (16 KB window into one of 8 banks for a total of 128 KB) |

### Banked Memory

The RAM bank (0-255) defaults to 255, and the ROM bank (0-7) defaults to 7 on RESET. The RAM bank can be configured through VIA#1 PA0-7 ($9F61), and the ROM bank through VIA#1 PB0-2 ($9F60). See section "I/O Programming" for more information.

### ROM Allocations

This is the allocation of the banks of banked ROM:

|Bank|Name   |Description                                            |
|----|-------|-------------------------------------------------------|
|0   |KERNAL |character sets (uploaded into VRAM), MONITOR, KERNAL   |
|1   |KEYBD  |Keyboard layout tables                                 |
|2   |CBDOS  |The computer-based CBM-DOS for FAT32 SD cards          |
|3   |GEOS   |GEOS KERNAL                                            |
|4   |BASIC  |BASIC interpreter                                      |
|5-7 |–      |*[Currently unused]*                                   |

**Important**: The layout of the banks is still constantly changing.

### RAM Contents

This is the allocation of fixed RAM in the KERNAL/BASIC environment.

|Addresses  |Description                                                     |
|-----------|----------------------------------------------------------------|
|$0000-$007F|User zero page                                                  |
|$0080-$00FF|KERNAL and BASIC zero page variables                            |
|$0100-$01FF|CPU stack                                                       |
|$0200-$07FF|KERNAL and BASIC variables                                      |
|$0800-$9EFF|BASIC program/variables; available to the user                  |

The following zero page locations are completely unused by KERNAL/BASIC and are available to the user:

|Addresses  |
|-----------|
|$0000-$007F|

In a machine language application that only uses KERNAL, the following zero page locations are also available:

|Addresses  |
|-----------|
|$00A9-$00FF|

This is the allocation of banked RAM in the KERNAL/BASIC environment.

|Bank   |Description               |
|-------|--------------------------|
|0-254  |Available to the user     |
|255[^2]|DOS buffers and variables |

### I/O Area

This is the memory map of the I/O Area:

|Addresses  |Description                  |
|-----------|-----------------------------|
|$9F00-$9F1F|Reserved for audio controller|
|$9F20-$9F3F|VERA video controller		  |
|$9F40-$9F5F|Reserved					  |
|$9F60-$9F6F|VIA I/O controller #1		  |
|$9F70-$9F7F|VIA I/O controller #2		  |
|$9F80-$9F9F|Real time clock			  |
|$9FA0-$9FBF|Future Expansion			  |
|$9FC0-$9FDF|Future Expansion			  |
|$9FE0-$9FFF|Future Expansion			  |

## Video Programming

The VERA video chip supports resolutions up to 640x480 with up to 256 colors from a palette of 4096, two layers of either a bitmap or tiles, 128 sprites of up to 64x64 pixels in size. It can output VGA as well as a 525 line interlaced signal, either as NTSC or as RGB (Amiga-style).

See the [VERA Programmer's Reference](VERA%20Programmer's%20Reference.md) for the complete reference.

**IMPORTANT**: The VERA register layout has changed between 0.7 and 0.8. Here is the old documentation: [vera-module v0.7.pdf](https://github.com/commanderx16/x16-docs/blob/master/old/vera-module%20v0.7.pdf)

The KERNAL uploads the current character sets (PETSCII graphics, PETSCII upper/lower or ISO-8859-15) to $0F800, i.e. the top of video RAM bank 0.

Application software is free to reuse this part of video RAM if it does not need the character set. If it needs them again later, it can use the KERNAL call `CINT` ($FF81), which initializes the VERA chip and uploads the PETSCII graphics character set, or print character code $0E too trigger an upload of the PETSCII upper/lower chcracter set, or $0F for the ISO character set.

## Sound Programming

*[TODO]*

## I/O Programming

There are two 65C22 "Versatile Interface Adapter" (VIA) I/O controllers in the system, VIA#1 at address $9F60 and VIA#2 at address $9F70. The IRQ out lines of both VIAs are connected to the IRQ in line of the CPU.

The following tables describe the connections of the GPIO ports:

**VIA#1**

|Pin  |Description |
|-----|------------|
|PA0-7|RAM bank    |
|PB0-2|ROM bank    |
|PB3-7|*[TBD]*     |

**VIA#2**

|Pin  |Description     |
|-----|------------    |
|PA0  |KBD PS/2 DAT    |
|PA1  |KBD PS/2 CLK    |
|PA2  |TBD             |
|PA3  |JOY1/2 LATCH[^3]|
|PA4  |JOY1 DATA       |
|PA5  |JOY1/2 CLK      |
|PA6  |JOY2 DATA       |
|PA7  |*[TBD]*         |
|PB0  |MOUSE PS/2 DAT  |
|PB1  |MOUSE PS/2 CLK  |
|PB2-7|*[TBD]*         |

The GPIO connections for the Commodore Serial Bus and the mouse PS/2 connection have not been finalized.

<!------->

[^1]: Current development systems have 2 MB of bankable RAM. Actual hardware is currently planned to have an option of either 512 KB or 2 MB of RAM.

[^2]: On systems with 512 KB RAM, DOS uses bank 63, and banks 0-62 are available to the user.

[^3]: The pin assignment of the NES/SNES controller is likely to change.
