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
| $00  | NULL                       | VERBATIM MODE             | $80  |
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
* $80: VERBATIM MODE prints the next character (only!) as a glyph without interpretation. This is similar to quote mode, but also includes codes CR ($13) and DEL ($14).
* F9-F12, HELP: these codes match the C65 additions

### Keyboard Layouts

The editor supports multiple keyboard layouts. The default is the US layout ("EN-US"). Pressing the `F9` key cycles through the available keyboard layouts, in the following order:

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
