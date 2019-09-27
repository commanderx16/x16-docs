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
* 2 MB RAM
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
* Most PEEKs and POKEs of addresses in the $0000-$0340 area are compatible with the C64.
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
| $16  | F10                    | same as on C65                     |
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

#### OLD

**TYPE: Command**
**FORMAT: OLD**	

**Action:** This command recovers the BASIC program in RAM that has been previously deleted using the `NEW` command or through a RESET.

**EXAMPLE of OLD Statement:**

      OLD

#### MON

**TYPE: Command**
**FORMAT: MON**

**Action:** This command enters the machine language monitor. See the dedicated chapter for a  description.

**EXAMPLE of MON Statement:**

      MON

#### VPEEK

**TYPE: Integer Function**
**FORMAT: VPEEK (&lt;bank&gt;, &lt;address&gt;)**

**Action:** Return a byte from the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPEEK Statement:**

      PRINT (VPEEK($F,$2000) AND $E0) / 32 : REM PRINTS THE CURRENT MODE (0-7)

#### VPOKE

**TYPE: Command**
**FORMAT: VPOKE &lt;bank&gt;, &lt;address&gt;, &lt;value&gt;**

**Action:** Set a byte in the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPOKE Statement:**

      VPOKE 0,1,1 * 16 + 2 : REM SETS THE COLORS OF THE CHARACTER
                             REM AT 0/0 TO RED ON WHITE

### Other New Features

The numeric constants parser supports both hex (`$`) and binary (`%`) literals, like this:

      PRINT $EA31 + %1010

The size of hex and binary values is only restricted by the range that can be represented by BASIC's internal floating point representation.

In regular BASIC text mode, the video controller supports 16 foreground colors and 16 background colors for each character on the screen. The foreground color can be changed with existing PETSCII control codes. The background color currently has to be set using a POKE statement. The current colors are accessible through memory location $0286 (decimal 646):

|Bits |Description      |
|-----|-----------------|
|0-3  |Foreground color |
|4-7  |Background color |

The following BASIC statement would set the current printing color to white on black, for example:

      POKE 646, 0 * 16 + 1

To set the background color of the complete screen, it just has to be cleared after setting the color:

      PRINT CHR$(147)

In BASIC, both an 80x60 and a 40x30 character text mode is supported. To switch modes, use the following BASIC code:

      IF PEEK($D9)<>40 THEN SYS $FF5F : REM SWITCH TO 40 CHARACTER MODE
      IF PEEK($D9)<>80 THEN SYS $FF5F : REM SWITCH TO 80 CHARACTER MODE

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
* The layout of the zero page ($0000-$00FF), the KERNAL/BASIC variable space ($0200 -$02FF) and the vectors ($0300-$0333) are also fully compatible with the C64.

### Commodore 128 API Compatibility

In addition, the X16 supports a subset of the C128 API additions:

$FF4A: `CLOSE_ALL` – close all files on a device
$FF53: `BOOT_CALL` – boot load program from disk *[not yet implemented]*
$FF8D: `LKUPLA` – search tables for given LA
$FF8A: `LKUPSA` – search tables for given SA
$FF5F: `SWAPPER` – switch between 40 and 80 columns
$FF65: `PFKEY` – program a function key *[not yet implemented]*
$FF74: `FETCH` – LDA (fetvec),Y from any bank
$FF77: `STASH` – STA (stavec),Y to any bank
$FF7A: `CMPARE` – CMP (cmpvec),Y to any bank
$FF7D: `PRIMM` – print string following the caller’s code

Some notes:

* For `SWAPPER`, the user can detect the current mode by reading the zero page location `LLEN` ($D9), which either holds a value of 40 or 80. This is different than on the C128.
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
$FF6E: `JSRFAR` – gosub in another bank

#### Function Name: GETJOY

Purpose: Query the joysticks and store their state in the zeropage
Call address: $FF06 (hex) 65286 (decimal)
Communication registers: None
Preparatory routines: None
Error returns: None
Stack requirements: 0
Registers affected: .A, .X, .Y

**Description:** The routine `GETJOY` retrieves all state from the two joysticks and stores it in the zeropage locations `JOY1` ($EF-$F1) and `JOY2` ($F2-$F4).

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
|0   |BASIC  |BASIC interpreter                                      |
|1-3 |–      |*[Currently unused]*                                   |
|4   |GEOS   |GEOS KERNAL                                            |
|5   |CBDOS  |The computer-based CBM-DOS for FAT32 SD cards          |
|6   |KEYMAP |Keyboard layout tables                                 |
|7   |KERNAL |character sets (uploaded into VRAM), MONITOR, KERNAL   |

**Important**: The layout of the banks is still constantly changing.

### RAM Contents

This is the allocation of fixed RAM in the KERNAL/BASIC environment.

|Addresses  |Description                                                     |
|-----------|----------------------------------------------------------------|
|$0000-$00FF|KERNAL and BASIC zero page variables                            |
|$0100-$01FF|CPU stack                                                       |
|$0000-$07FF|KERNAL and BASIC variables                                      |
|$0800-$9EFF|BASIC program/variables; available to the user                  |

The following zero page locations are unused by KERNAL/BASIC and are available to the user:

|Addresses  |
|-----------|
|$0000-$0002|
|$00FB-$00FE|

In a machine language application that only uses KERNAL, the following zero page locations are also available:

|Addresses  |
|-----------|
|$0000-$008F|
|$00FF|

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

The KERNAL uploads the three character sets to:

* $1E800: ISO-8859-15 (2 KB)
* $1F000: PETSCII upper case/graphics (2 KB)
* $1F800: PETSCII upper/lower case (2 KB)

Application software is free to reuse this part of video RAM if it does not need the character sets. If it needs them again later, it can use the KERNAL call `CINT` ($FF81), which initializes the VERA chip and uploads the character sets.

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
|PB0-7|*[TBD]*         |

The GPIO connections for the Commodore Serial Bus and the mouse PS/2 connection have not been finalized.

<!------->

[^1]: Current development systems have 2 MB of bankable RAM. Actual hardware is currently planned to have an option of either 512 KB or 2 MB of RAM.

[^2]: On systems with 512 KB RAM, DOS uses bank 63, and banks 0-62 are available to the user.

[^3]: The pin assignment of the NES/SNES controller is likely to change.
