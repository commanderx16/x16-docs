## Chapter 2: BASIC Programming

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

### Background Color

In regular BASIC text mode, the video controller supports 16 foreground colors and 16 background colors for each character on the screen.

The new "swap fg/bg color" code is useful to change the background color of the cursor, like this:

	PRINT CHR$(1);   : REM SWAP FG/BG
	PRINT CHR$($1C); : REM SET FG COLOR TO RED
	PRINT CHR$(1);   : REM SWAP FG/BG

The new BASIC instruction `COLOR` makes this easier, but the trick above can also be used from machine code programs.

To set the background color of the complete screen, it just has to be cleared after setting the color:

      PRINT CHR$(147);

### New Control Characters

This is the set of all supported PETSCII control characters. Descriptions in bold indicate new codes compared to the C64:

| Code |                            |                           | Code |
|------|----------------------------|---------------------------|------|
| $00  | NULL                       | -                         | $80  |
| $01  | **SWAP COLORS**            | COLOR: ORANGE             | $81  |
| $02  <td colspan=2 align="center"> -                          | $82  |
| $03  <td colspan=2 align="center"> STOP/RUN                   | $83  |
| $04  | **ATTRIBUTES: UNDERLINE**  | **HELP**                  | $84  |
| $05  | COLOR: WHITE               | F1                        | $85  |
| $06  | **ATTRIBUTES: BOLD**       | F3                        | $86  |
| $07  | **BELL**                   | F5                        | $87  |
| $08  | **BACKSPACE**              | F7                        | $88  |
| $09  | **TAB**                    | F2                        | $89  |
| $0A  | **LF**                     | F4                        | $8A  |
| $0B  | **ATTRIBUTES: ITALICS**    | F6                        | $8B  |
| $0C  | **ATTRIBUTES: OUTLINE**    | F8                        | $8C  |
| $0D  <td colspan=2 align="center"> REGULAR/SHIFTED RETURN     | $8D  |
| $0E  <td colspan=2 align="center"> CHARSET: LOWER/UPPER CASE  | $8E  |
| $0F  <td colspan=2 align="center"> **CHARSET: ISO ON/OFF**    | $8F  |
| $10  | **F9**                     | COLOR: BLACK              | $90  |
| $11  <td colspan=2 align="center"> CURSOR: DOWN/UP            | $91  |
| $12  | ATTRIBUTES: REVERSE        | ATTRIBUTES: CLEAR ALL     | $92  |
| $13  <td colspan=2 align="center"> HOME/CLEAR                 | $93  |
| $14  <td colspan=2 align="center"> DEL/INSERT                 | $94  |
| $15  | **F10**                    | COLOR: BROWN              | $95  |
| $16  | **F11**                    | COLOR: LIGHT RED          | $96  |
| $17  | **F12**                    | COLOR: DARK GRAY          | $97  |
| $18  | **SHIFT+TAB**              | COLOR: MIDDLE GRAY        | $98  |
| $19  | -                          | COLOR: LIGHT GREEN        | $99  |
| $1A  | -                          | COLOR: LIGHT BLUE         | $9A  |
| $1B  | -                          | COLOR: LIGHT GRAY         | $9B  |
| $1C  | COLOR: RED                 | COLOR: PURPLE             | $9C  |
| $1D  | CURSOR: RIGHT              | CURSOR: LEFT              | $9D  |
| $1E  | COLOR: GREEN               | COLOR: YELLOW             | $9E  |
| $1F  | COLOR: BLUE                | COLOR: CYAN               | $9F  |

**Notes:**

* $01: SWAP COLORS swaps the foreground and background colors in text mode
* $04/$06/$0B/$0C: the new attribute change codes only have an effect in graphics mode
* $07/$08/$09/$0A/$18: have been added for ASCII compatibility *[NYI]*
* $08/$09: Charset switch enable/disable not supported
* F9-F12, HELP: these codes match the C65 additions

### Keyboard Layouts

Pressing the `F9` key cycles through the available keyboard layouts.

### New Statements and Functions

There are several new statement and functions. Note that all BASIC keywords (such as `FOR`) get converted into tokens (such as `$81`), and the tokens for the new keywords have not been finalized yet. Therefore, loading BASIC program saved from a different revision of BASIC may mix up keywords.


#### BIN$

**TYPE: String Function**
**FORMAT: BIN$(n)**

**Action:** Return a string representing the binary value of n. If n <= 255, 8 characters are returned and if 255 < n <= 65535, 16 characters are returned.

**EXAMPLE of BIN$ Function:**

	PRINT BIN$(200)   : REM PRINTS 11001000 AS BINARY REPRESENTATION OF 200
	PRINT BIN$(45231) : REM PRINTS 1011000010101111 TO REPRESENT 16 BITS

#### CHAR

**TYPE: Command**
**FORMAT: CHAR &lt;x&gt;,&lt;y&gt;,&lt;color&gt;,&lt;string&gt;**

**Action:** This command draws a text string on the graphics screen in a given color.

The string can contain printable ASCII characters (`CHR$($20)` to `CHR$($7E)`), as well most PETSCII control codes.

**EXAMPLE of CHAR Statement:**

	10 SCREEN$80
	20 A$="The quick brown fox jumps over the lazy dog."
	24 CHAR0,6,0,A$
	30 CHAR0,6+12,0,CHR$($04)+A$   :REM UNDERLINE
	40 CHAR0,6+12*2,0,CHR$($06)+A$ :REM BOLD
	50 CHAR0,6+12*3,0,CHR$($0B)+A$ :REM ITALICS
	60 CHAR0,6+12*4,0,CHR$($0C)+A$ :REM OUTLINE
	70 CHAR0,6+12*5,0,CHR$($12)+A$ :REM REVERSE

#### CLS

**TYPE: Command**
**FORMAT: CLS**

**Action:** Clears the screen. Same effect as `?CHR$(147);`.

**EXAMPLE of CLS Statement:**

	CLS

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

#### GEOS

**TYPE: Command**
**FORMAT: GEOS**

**Action:** Enter the GEOS UI.

#### HEX$

**TYPE: String Function**
**FORMAT: HEX$(n)**

**Action:** Return a string representing the hexadecimal value of n. If n <= 255, 2 characters are returned and if 255 < n <= 65535, 4 characters are returned.

**EXAMPLE of HEX$ Function:**

	PRINT HEX$(200)   : REM PRINTS C8 AS HEXADECIMAL REPRESENTATION OF 200
	PRINT HEX$(45231) : REM PRINTS B0AF TO REPRESENT 16 BIT VALUE

#### JOY

**TYPE: Integer Function**
**FORMAT: JOY(n)**

**Action:** Return the state of a joystick.

`JOY(1)` through `JOY(4)` return the state of SNES controllers connected to the system, and `JOY(0)` returns the state of the "keyboard joystick", a set of keyboard keys that map to the SNES controller layout. See [`joystick_get`](#function-name-joystick_get) for details.

If no controller is connected to the SNES port (or no keyboard is connected), the function returns -1. Otherwise, the result is a bit field, with pressed buttons `OR`ed together:

| Value  | Button |
|--------|--------|
| $800   | A      |
| $400   | X      |
| $200   | L      |
| $100   | R      |
| $080   | B      |
| $040   | Y      |
| $020   | SELECT |
| $010   | START  |
| $008   | UP     |
| $004   | DOWN   |
| $002   | LEFT   |
| $001   | RIGHT  |

Note that this bitfield is different from the `joystick_get` KERNEL API one. Also note that the keyboard joystick will allow LEFT and RIGHT as well as UP and DOWN to be pressed at the same time, while controllers usually prevent this mechanically.

**EXAMPLE of JOY Function:**

	10 REM DETECT CONTROLLER, FALL BACK TO KEYBOARD
	20 J = 0: FOR I=1 TO 4: IF JOY(I) >= 0 THEN J = I: GOTO40
	30 NEXT
	40 :
	50 V=JOY(J)
	60 PRINT CHR$(147);V;": ";
	70 IF V = -1 THEN PRINT"DISCONNECTED ": GOTO50
	80 IF V AND 8 THEN PRINT"UP ";
	90 IF V AND 4 THEN PRINT"DOWN ";
	100 IF V AND 2 THEN PRINT"LEFT ";
	110 IF V AND 1 THEN PRINT"RIGHT ";
	120 GOTO50

#### LINE

**TYPE: Command**
**FORMAT: LINE &lt;x1&gt;,&lt;y1&gt;,&lt;x2&gt;,&lt;y2&gt;,&lt;color&gt;**

**Action:** This command draws a line on the graphics screen in a given color.

**EXAMPLE of LINE Statement:**

	10 SCREEN128
	20 FORA=0TO2*\XFFSTEP2*\XFF/200
	30 :  LINE100,100,100+SIN(A)*100,100+COS(A)*100
	40 NEXT

#### LOCATE

**TYPE: Command**
**FORMAT: LOCATE &lt;line&gt;[,&lt;column&gt;]**

**Action:** This command positions the text mode cursor at the given location. The values are 1-based. If no column is given, only the line is changed.

**EXAMPLE of LOCATE Statement:**

	100 REM DRAW CIRCLE ON TEXT SCREEN
	110 SCREEN0
	120 R=25
	130 X0=40
	140 Y0=30
	150 FORT=0TO360STEP1
	160 :  X=X0+R*COS(T)
	170 :  Y=Y0+R*SIN(T)
	180 :  LOCATEY,X:PRINTCHR$($12);" ";
	190 NEXT

#### MON

**TYPE: Command**
**FORMAT: MON (Alternative: MONITOR)**

**Action:** This command enters the machine language monitor. See the dedicated chapter for a  description.

**EXAMPLE of MON Statement:**

      MON
      MONITOR

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

The size of the mouse pointer's area will be configured according to the current screen mode. If the screen mode is changed, the MOUSE statement has to be repeated.

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

#### RESET

**TYPE: Command**
**FORMAT: RESET**

**Action:** Performs a software reset of the system.

**EXAMPLE of RESET Statement:**

	RESET

#### SCREEN

**TYPE: Command**
**FORMAT: SCREEN &lt;mode&gt;**

**Action:** This command switches the screen mode. Modes $80 (128) and above are graphics modes.

| Mode | Description |
|------|-------------|
| $00  | 80x60 text  |
| $01  | 80x30 text  |
| $02  | 40x60 text  |
| $03  | 40x30 text  |
| $04  | 40x15 text  |
| $05  | 20x30 text  |
| $06  | 20x15 text  |
| $80  | 320x200@256c<br/>40x25 text |
| $81  | 640x400@16c* |

* [currently unimplemented]

The value of $FF (255) toggles between modes $00 and $03.

Note that in text/graphics mode ($80), text color 0 is now translucent instead of black.

#### VPEEK

**TYPE: Integer Function**
**FORMAT: VPEEK (&lt;bank&gt;, &lt;address&gt;)**

**Action:** Return a byte from the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPEEK Function:**

      PRINT VPEEK(1,$B000) : REM SCREEN CODE OF CHARACTER AT 0/0 ON SCREEN

#### VPOKE

**TYPE: Command**
**FORMAT: VPOKE &lt;bank&gt;, &lt;address&gt;, &lt;value&gt;**

**Action:** Set a byte in the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPOKE Statement:**

      VPOKE 1,$B000+1,1 * 16 + 2 : REM SETS THE COLORS OF THE CHARACTER
                                   REM AT 0/0 TO RED ON WHITE

#### VLOAD

**TYPE: Command**
	**FORMAT: VLOAD &lt;filename&gt;, &lt;device&gt;, &lt;VERA_high_address&gt;, &lt;VERA_low_address&gt;**
	
**Action:** Loads a file directly into VERA RAM. 

**EXAMPLES of VLOAD:**
	
	VLOAD "MYFILE.BIN", 8, 0, $4000  :REM LOADS MYFILE.BIN FROM DEVICE 8 TO VRAM $4000.
	VLOAD "MYFONT.BIN", 8, 1, $F000  :REM LOAD A FONT INTO THE DEFAULT FONT LOCATION ($1F000).

### Other New Features

#### Hexadecimal and Binary Literals

The numeric constants parser supports both hex (`$`) and binary (`%`) literals, like this:

      PRINT $EA31 + %1010

The size of hex and binary values is only restricted by the range that can be represented by BASIC's internal floating point representation.

#### Different Text Modes

In BASIC, both an 80x60 and a 40x30 character text mode is supported. To switch modes, use the BASIC statement `SCREEN`:

      SCREEN 3 : REM SWITCH TO 40 CHARACTER MODE
      SCREEN 0 : REM SWITCH TO 80 CHARACTER MODE
      SCREEN 255 : REM SWITCH BETWEEN 40 and 80 CHARACTER MODE

#### LOAD into VRAM

In BASIC, the contents of files can be directly loaded into VRAM with the `LOAD` statement. When a secondary address greater than one is used, the KERNAL will now load the file into the VERA's VRAM address space. The first two bytes of the file are used as lower 16 bits of the address. The upper 4 bits are `(SA-2) & 0x0ff` where `SA` is the secondary address.

Examples:

	  10 REM LOAD VERA SETTINGS
	  20 LOAD"VERA.BIN",1,17 : REM SET ADDRESS TO $FXXXX
	  30 REM LOAD TILES
	  40 LOAD"TILES.BIN",1,3 : REM SET ADDRESS TO $1XXXX
	  50 REM LOAD MAP
      60 LOAD"MAP.BIN",1,2 : REM SET ADDRESS TO $0XXXX

#### Default Device Numbers

In BASIC, the LOAD, SAVE and OPEN statements default to the last-used IEEE device (device numbers 8 and above), or 8.

### Internal Representation

Like on the C64, BASIC keywords are tokenized.

* The C64 BASIC V2 keywords occupy the range of $80 (`END`) to $CB (`GO`).
* BASIC V3.5 also used $CE (`RGR`) to $FD (`WHILE`).
* BASIC V7 introduced the $CE escape code for function tokens $CE-$02 (`POT`) to $CE-$0A (`POINTER`), and the $FE escape code for statement tokens $FE-$02 (`BANK`) to $FE-$38 (`SLOW`).
* The unreleased BASIC V10 extended the escaped tokens up to $CE-$0D (`RPALETTE`) and $FE-$45 (`EDIT`).

The X16 BASIC aims to be as compatible as possible with this encoding. Keywords added to X16 BASIC that also exist in other versions of BASIC match the token, and new keywords are encoded in the ranges $CE-$80+ and $FE-$80+.
