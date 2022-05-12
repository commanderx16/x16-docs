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

### Default Layout

On boot, the US layout (`EN-US`) is active:

* In PETSCII mode, it matches the US layout where possible, and can reach all PETSCII symbols.
* In ISO mode, it matches the Macintosh US keyboard and can reach all ISO-8859-1 characters, some of which either through (Shift+)Alt/AltGr (e.g. Alt+Shift+`q` will produce `Œ`) or by combining certain (Shift+)Alt/AltGr keys with a second key (e.g. Alt+`u` followed by `a` will produce `ä`).


| Key  | Alt  | S+Alt | Key  | Alt  | S+Alt | Key  | Alt  | S+Alt | Key  | Alt  | S+Alt |
|-----|---|---|---|---|-----|-----|---|---|-----|---|---|
| `1` | ¡ |   | `Q` | œ | Œ | `A` |   |   | `Z` |   |   |
| `2` |   | € | `W` |   |   | `S` | ß |   | `X` | . |   |
| `3` | £ |   | `E` |   |   | `D` | ð | Ð | `C` |   |   |
| `4` | ¢ |   | `R` | ® | ‰ | `F` |   |   | `V` |   |   |
| `5` | § |   | `T` | Þ | þ | `G` | © |   | `B` |   |   |
| `6` |   |   | `Y` | ¥ |   | `H` |   |   | `N` |   |   |
| `7` | ¶ |   | `U` |   |   | `J` |   |   | `M` |   |   |
| `8` |   | ° | `I` |   |   | `K` |   |   | `,` |   |   |
| `9` | ª | · | `O` | ø |   | `L` |   |   | `.` |   |   |
| `0` | º |   | `P` |   |   | `;` |   |   | `/` | ÷ | ¿ |
| `-` |   |   | `[` |   |   | `'` | æ | Æ |
| `=` |   | ± | `]` |   |   |
|     |   |   | `\` | « | » |


#### ROM Keyboard Layouts

Pressing the `F9` key cycles through the keyboard layouts stored in ROM, in the following order:

| Identifier  | Description                         | Code                                       |
|-------------|-------------------------------------|--------------------------------------------|
| `EN-US`     | United States (with Mac extensions) | -                                          |
| `EN-US/INT` | United States - International       | [00020409](http://kbdlayout.info/00020409) |
| `EN-GB`     | United Kingdom                      | [00000809](http://kbdlayout.info/00000809) |
| `SV-SE`     | Swedish                             | [0000041D](http://kbdlayout.info/0000041D) |
| `DE-DE`     | German                              | [00000407](http://kbdlayout.info/00000407) |
| `DA-DK`     | Danish                              | [00000406](http://kbdlayout.info/00000406) |
| `IT-IT`     | Italian                             | [00000410](http://kbdlayout.info/00000410) |
| `PL-PL`     | Polish (Programmers)                | [00000415](http://kbdlayout.info/00000415) |
| `NB-NO`     | Norwegian                           | [00000414](http://kbdlayout.info/00000414) |
| `HU-HU`     | Hungarian                           | [0000040E](http://kbdlayout.info/0000040E) |
| `ES-ES`     | Spanish                             | [0000040A](http://kbdlayout.info/0000040A) |
| `FI-FI`     | Finnish                             | [0000040B](http://kbdlayout.info/0000040B) |
| `PT-BR`     | Portuguese (Brazil ABNT)            | [00000416](http://kbdlayout.info/00000416) |
| `CS-CZ`     | Czech                               | [00000405](http://kbdlayout.info/00000405) |
| `JA-JP`     | Japanese                            | [00000411](http://kbdlayout.info/00000411) |
| `FR-FR`     | French                              | [0000040C](http://kbdlayout.info/0000040C) |
| `DE-CH`     | Swiss German                        | [00000807](http://kbdlayout.info/00000807) |
| `EN-US/DVO` | United States - Dvorak              | [00010409](http://kbdlayout.info/00010409) |
| `ET-EE`     | Estonian                            | [00000425](http://kbdlayout.info/00000425) |
| `FR-BE`     | Belgian French                      | [0000080C](http://kbdlayout.info/0000080C) |
| `EN-CA`     | Canadian French                     | [00001009](http://kbdlayout.info/00001009) |
| `IS-IS`     | Icelandic                           | [0000040F](http://kbdlayout.info/0000040F) |
| `PT-PT`     | Portuguese                          | [00000816](http://kbdlayout.info/00000816) |
| `HR-HR`     | Croatian                            | [0000041A](http://kbdlayout.info/0000041A) |
| `SK-SK`     | Slovak                              | [0000041B](http://kbdlayout.info/0000041B) |
| `SL-SI`     | Slovenian                           | [00000424](http://kbdlayout.info/00000424) |
| `LV-LV`     | Latvian                             | [00000426](http://kbdlayout.info/00000426) |
| `LT-LT`     | Lithuanian IBM                      | [00000427](http://kbdlayout.info/00000427) |

All remaining keyboards are based on the respective Windows layouts. `EN-US/INT` differs from `EN-US` only in Alt/AltGr combinations and some dead keys.

The BASIC command `KEYMAP` allows activating a specific keyboard layout. It can be added to the auto-boot file, e.g.:

	10 KEYMAP"NB-NO"
	SAVE"AUTOBOOT.X16

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
| $A590-$A66F | dead key table |
| $A670-$A67E | ASCIIZ identifier (e.g. "EN-US/MAC") |

The first byte of each of the 11 tables is the table ID which contains the encoding and the combination of modifiers that this table is for.

| Bit | Description        |
|-----|--------------------|
| 7   | 0: PETSCII, 1: ISO |
| 6-3 | always 0           |
| 2   | Ctrl               |
| 1   | Alt                |
| 0   | Shift              |

* AltGr is represented by Ctrl+Alt.
* ID $C6 represents Alt *or* AltGr (ISO only)
* ID $C7 represents Shift+Alt *or* Shift+AltGr (ISO only)
* Empty tables have an ID of $FF.

The identifier is followed by 127 output codes for the scancode inputs 1-127.

* The regular PS/2 scancode for the F7 key is $83, but in these tables, F7 has a scancode of $02.
* Dead keys (i.e. keys that don't generate anything by themselves but modify the next key) have a code of 0 and are further described in the dead key table (ISO only)
* Keys that produce nothing have an entry of 0. (They can be distinguished from dead keys as they don't have an entry in the dead key table.)

Keys with $E0/$E1-prefixed PS/2 scancodes (cursor keys etc.) are hardcoded and cannot be changed using these tables.

The dead key table has one section for every dead key with the following layout:

| Byte | Description                                  |
|------|----------------------------------------------|
| 0    | dead key ID (PETSCII/ISO and Shift/Alt/Ctrl) |
| 1    | dead key scancode                            |
| 2    | full length of this table in bytes           |
| 3    | first additional key ISO code                |
| 4    | first effective key ISO code                 |
| 5    | second additional key ISO code               |
| 6    | second effective key ISO code                |
| ...  | ...                                          |
| n-1  | terminator 0xFF                              |


Custom layouts can be loaded from disk like this:

	LOAD"KEYMAP",8,0,$A000

Here is an example that activates a layout derived from "EN-US/MAC", with unshifted Y and Z swapped in PETSCII mode:

	100 KEYMAP"EN-US/MAC"                             :REM START WITH US LAYOUT
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
