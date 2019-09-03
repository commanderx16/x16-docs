# Commander X16 Programmer's Reference Guide



## BASIC Programming

### Commodore 64 Compatibility

The Commander X16 BASIC interpreter is 100% backwards-compatible with the Commodore 64 one. This includes the following features:

* All statements and functions
* Strings, arrays, integers, floats
* Max 80 character BASIC lines
* Printing "quote mode" control characters like cursor control and color codes, e.g.:
	* `CHR$(147)`: clear screen
	* `CHR$(5)`: white text
	* `CHR$(18)`: reverse
	* `CHR$(14)`: switch to upper/lowercase font

Because of the differences in hardware, the following functions and statements are incompatible between C64 and X16 BASIC programs.

* `POKE`: write to a memory address
* `PEEK`: read from a memory address
* `WAIT`: wait for memory contents
* `SYS`: execute machine language code

The BASIC interpreter also currently shares all problems of the C64 version, like the slow garbage collector.

### New Statements and Functions

There are several new statement and functions. Note that all BASIC keywords (such as `FOR`) get converted into tokens (such as `$81`), and the tokens for the new keywords have not been finalized yet. Therefore, loading BASIC program saved from a different revision of BASIC may mix up keywords.

#### DOS

**TYPE: Command**
**FORMAT: DOS &lt;string&gt;**	

#### MON

**TYPE: Command**
**FORMAT: MON**

#### VPEEK

**TYPE: Integer Function**
**FORMAT: VPEEK (&lt;bank&gt;, &lt;address&gt;)**

#### VPOKE

**TYPE: Command**
**FORMAT: VPOKE &lt;bank&gt;, &lt;address&gt;, &lt;value&gt;**

### Other New Features

The numeric constants parser supports both hex (`$`) and binary (`%`) literals, like this:

      PRINT $EA31 + %1010

The size of hex and binary values is only restricted by the range that can be represented by BASIC's internal floating point representation.

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

* The Commodore Peripheral Bus calls first talk to the "Computer DOS" built into the ROM to detect an SD card, before falling back to the Commodore Serial Bus.
* The `IOBASE` call returns $9F60, the location of the first VIA controller.
* The `SETTMO` call has been a no-op since the Commodore VIC-20, and has no function on the X16 either.

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

One note:

* For `SWAPPER`, the user can detect the current mode by reading the zero page location `LLEN` ($D9), which either holds a value of 40 or 80. This is different than on the C128.

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

**Description:** The routine `GETJOY` restrieves all state from the two joysticks and stores it in the zeropage locations `JOY1` and `JOY2`.

Each of these symbols consist of 3 bytes with the following layout:

      byte 0:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
              NES  | A | B |SEL|STA|UP |DN |LT |RT |
              SNES | B | Y |SEL|STA|UP |DN |LT |RT |
      
      byte 1:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
              NES  | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
              SNES | A | X | L | R | 1 | 1 | 1 | 1 |
      byte 2:
              $00 = joystick present
              $FF = joystick not present

* Presence can be detected by checking byte 2.
* NES vs. SNES can be detected by checking bits 0-3 in byte 1.
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



## Memory Map



## Video Programming

## Sound Programming

## I/O Programming