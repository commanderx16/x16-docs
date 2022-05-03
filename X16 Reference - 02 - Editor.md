## Chapter 2: Editor

The X16 has a built-in screen editor that is backwards-compatible with the C64, but has many new features.

### Modes

The editor's default mode is 80x60 text mode. The following text mode resolutions are supported:

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

Mode $80 contains two layers: a text layer on top of a graphics screen. In this mode, text color 0 is translucent instead of black.

To switch modes, use the BASIC statement `SCREEN` or the KERNAL API `screen_mode`. In BASIC, the F4 key toggles between modes 0 (80x60) and 3 (40x30).

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
* `CHR$($8F)`: enable PETSCII mode (default)

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

### Scrolling

The C64 editor could only scroll the screen up (when overflowing the last line or printing or entering DOWN on the last line). The X16 editor scrolls both ways: When the cursor is on the first line and UP is printed or entered, the screen contents scroll down by a line.

### New Control Characters

This is the set of all supported PETSCII control characters. Entries in bold indicate new codes compared to the C64:

| Code |                            |                           | Code |
|------|----------------------------|---------------------------|------|
| $00  | NULL                       | **VERBATIM MODE**         | $80  |
| $01  | **SWAP COLORS**            | COLOR: ORANGE             | $81  |
| $02  <td colspan=2 align="center"> PAGE DOWN/UP               | $82  |
| $03  <td colspan=2 align="center"> STOP/RUN                   | $83  |
| $04  | **END**                    | **HELP**                  | $84  |
| $05  | COLOR: WHITE               | F1                        | $85  |
| $06  | **MENU**                   | F3                        | $86  |
| $07  | **BELL**                   | F5                        | $87  |
| $08  | **BACKSPACE**              | F7                        | $88  |
| $09  | **TAB**                    | F2                        | $89  |
| $0A  | **LF**                     | F4                        | $8A  |
| $0B  | -                          | F6                        | $8B  |
| $0C  | -                          | F8                        | $8C  |
| $0D  <td colspan=2 align="center"> REGULAR/SHIFTED RETURN     | $8D  |
| $0E  <td colspan=2 align="center"> CHARSET: LOWER/UPPER CASE  | $8E  |
| $0F  <td colspan=2 align="center"> **CHARSET: ISO ON/OFF**    | $8F  |
| $10  | **F9**                     | COLOR: BLACK              | $90  |
| $11  <td colspan=2 align="center"> CURSOR: DOWN/UP            | $91  |
| $12  <td colspan=2 align="center"> REVERSE ON/OFF             | $92  |
| $13  <td colspan=2 align="center"> HOME/CLEAR                 | $93  |
| $14  <td colspan=2 align="center"> DEL/INSERT                 | $94  |
| $15  | **F10**                    | COLOR: BROWN              | $95  |
| $16  | **F11**                    | COLOR: LIGHT RED          | $96  |
| $17  | **F12**                    | COLOR: DARK GRAY          | $97  |
| $18  | **SHIFT+TAB**              | COLOR: MIDDLE GRAY        | $98  |
| $19  | **FWD DEL**                | COLOR: LIGHT GREEN        | $99  |
| $1A  | -                          | COLOR: LIGHT BLUE         | $9A  |
| $1B  | ESC                        | COLOR: LIGHT GRAY         | $9B  |
| $1C  | COLOR: RED                 | COLOR: PURPLE             | $9C  |
| $1D  | CURSOR: RIGHT              | CURSOR: LEFT              | $9D  |
| $1E  | COLOR: GREEN               | COLOR: YELLOW             | $9E  |
| $1F  | COLOR: BLUE                | COLOR: CYAN               | $9F  |

**Notes:**

* $01: SWAP COLORS swaps the foreground and background colors in text mode
* $07/$08/$09/$0A/$18/$1B: have been added for ASCII compatibility *[$08/$09/$0A/$18 are NYI]*
* $80: VERBATIM MODE prints the next character (only!) as a glyph without interpretation. This is similar to quote mode, but also includes codes CR ($0D) and DEL ($14).
* F9-F12: these codes match the C65 additions
* $84: This code is generated when pressing SHIFT+END.
* Additionally, the codes $04/$06/$0B/$0C are interpreted when printing in graphics mode using `GRAPH_put_char`.

### Keyboard Layouts

The editor supports multiple keyboard layouts.

#### ROM Keyboard Layouts

After boot, the US layout ("EN-US") is active. Pressing the `F9` key cycles through the keyboard layouts stored in ROM, in the following order:

* EN-US
* EN-GB
* DE
* SV-SE
* IT
* PL
* HU
* ES
* FR
* DE-CH
* FR-BE
* PT-BR

Additionally, the BASIC command `KEYMAP` allows activating a specific keyboard layout. It can be added to the auto-boot file.

#### Loadable Keyboard Layouts

The tables for the active keyboard layout reside in banked RAM, at $A000 on bank 0:

| Adresses    | Description |
|-------------|-------------|
| $A000-$A07F | Table 0     |
| $A080-$A0FF | Table 1     |
| $A100-$A17F | Table 2     |
| $A180-$A1FF | Table 3     |
| $A200-$A27F | Table 4     |
| $A280-$A07F | Table 5     |
| $A300-$A37F | Table 6     |
| $A380-$A3FF | Table 7     |
| $A400-$A47F | Table 8     |
| $A480-$A4FF | Table 9     |
| $A500-$A57F | Table 10    |
| $A580-$A58F | big-endian bitfield:<br/>PS/2 scancodes for which Caps means Shift |
| $A590-$A595 | uppercase ASCIIZ locale (e.g. "EN-US") |

The first byte of each of the 11 tables is the table identifier which contains the encoding and the combination of modifiers that this table is for.

| Bit | Description        |
|-----|--------------------|
| 7   | 0: PETSCII, 1: ISO |
| 6-3 | always 0           |
| 2   | Ctrl               |
| 1   | Alt                |
| 0   | Shift              |

AltGr is represented by Ctrl+Alt. Empty tables have an ID of $FF.

The identifier is followed by 127 output codes for the scancode inputs 1-127. (Note that the regular PS/2 scancode for the F7 key is $83, but in these tables, F7 has a scancode of $02.)

Keys with $E0/$E1-prefixed PS/2 scancodes (cursor keys etc.) are hardcoded and cannot be changed using these tables.

Custom layouts can be loaded from disk like this:

	LOAD"KEYMAP",8,0,$A000

Here is an example that activates a layout derived from "EN-US", with unshifted Y and Z swapped in PETSCII mode:

	100 KEYMAP"EN-US"                                 :REM START WITH US LAYOUT
	110 POKE0,0                                       :REM ACTIVATE RAM BANK 0
	120 FORI=0TO11:B=$A000+128*I:IFPEEK(B)<>0THENNEXT :REM SEARCH FOR TABLE $00
	130 POKEB+$1A,ASC("Y")                            :REM SET SCAN CODE $1A ('Z') to 'Y'
	140 POKEB+$35,ASC("Z")                            :REM SET SCAN CODE $35 ('Y') to 'Z'
	170 REM
	180 REM *** DOING THE SAME FOR SHIFTED CHARACTERS
	190 REM *** IS LEFT AS AN EXERCISE TO THE READER

#### Custom Keyboard Scancode Handler

If you need more control over the translation of scancodes into PETSCII/ISO codes, or if you need to intercept any key down or up event, you can hook the custom scancode handler vector at $032E/$032F.

On all key down and key up events, the keyboard driver calls this vector with

* .X: PS/2 prefix ($00, $E0 or $E1)
* .A: PS/2 scancode
* .C: clear if key down, set if key up event

The handler has to return a key event the same way in .X/.A/.C.

* To remove a keypress so that it is not added to the keyboard queue, return .A = 0.
* To manually add a key to the keyboard queue, use the `kbdbuf_put` KERNAL API.

You can even write a completely custom keyboard translation layer:
* Place the code at $A000-$A58F – this is safe, since the tables won't be used in this case.
* Fill the locale at $A590.
* For every scancode that should produce a PETSCII/ISO code, use `kbdbuf_put` to store it in the keyboard buffer.
* For all scancodes, return .A = 0.


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

    cmp #$11    ;Alt key scancode
    bne exit

    lda #'a'
    jsr $ffd2

exit:
    plx		;Restore input
    pla
    plp
    rts
```
