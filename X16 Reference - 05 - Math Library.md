## Chapter 5: Math Library

The Commander X16 contains a floating point Math library with a precision of 40 bits, which corresponds to 9 decimal digits. It is a stand-alone derivative of the library contained in Microsoft BASIC. Except for the different base address, it is compatible with the C128 and C65 libraries.

The following functions are available from machine language code after setting the ROM bank to 4.

### Format Conversions

| C128  | C65   | X16   | Symbol   | Description                            |
|-------|-------|-------|----------|----------------------------------------|
| $AF00 | $7F00 | $FE00 | `AYINT`  | convert floating point to integer      |
| $AF03 | $7F03 | $FE03 | `GIVAYF` | convert integer to floating point      |
| $AF06 | $7F06 | $FE06 | `FOUT`   | convert floating point to ASCII string |
| $AF09 | $7F09 | $FE09 | `VAL_1`  | convert ASCII string to floating point<br/>*[not yet implemented]*|
| $AF0C | $7F0C | $FE0C | `GETADR` | convert floating point to an address   |
| $AF0F | $7F0F | $FE0F | `FLOATC` | convert address to floating point      |

### Math Functions

| C128  | C65   | X16   | Symbol   | Description                            |
|-------|-------|-------|----------|----------------------------------------|
| $AF12 | $7F12 | $FE12 | `FSUB`   | MEM - FACC                             |
| $AF15 | $7F15 | $FE15 | `FSUBT`  | ARG - FACC                             |
| $AF18 | $7F18 | $FE18 | `FADD`   | MEM + FACC                             |
| $AF1B | $7F1B | $FE1B | `FADDT`  | ARG + FACC                             |
| $AF1E | $7F1E | $FE1E | `FMULT`  | MEM * FACC                             |
| $AF21 | $7F21 | $FE21 | `FMULTT` | ARG * FACC                             |
| $AF24 | $7F24 | $FE24 | `FDIV`   | MEM / FACC                             |
| $AF27 | $7F27 | $FE27 | `FDIVT`  | ARG / FACC                             |
| $AF2A | $7F2A | $FE2A | `LOG`    | compute natural log of FACC            |
| $AF2D | $7F2D | $FE2D | `INT`    | perform BASIC INT() on FACC            |
| $AF30 | $7F30 | $FE30 | `SQR`    | compute square root of FACC            |
| $AF33 | $7F33 | $FE33 | `NEGOP`  | negate FACC                            |
| $AF36 | $7F36 | $FE36 | `FPWR`   | raise ARG to the MEM power             |
| $AF39 | $7F39 | $FE39 | `FPWRT`  | raise ARG to the FACC power            |
| $AF3C | $7F3C | $FE3C | `EXP`    | compute EXP of FACC                    |
| $AF3F | $7F3F | $FE3F | `COS`    | compute COS of FACC                    |
| $AF42 | $7F42 | $FE42 | `SIN`    | compute SIN of FACC                    |
| $AF45 | $7F45 | $FE45 | `TAN`    | compute TAN of FACC                    |
| $AF48 | $7F48 | $FE48 | `ATN`    | compute ATN of FACC                    |
| $AF4B | $7F4B | $FE4B | `ROUND`  | round FACC                             |
| $AF4E | $7F4E | $FE4E | `ABS`    | absolute value of FACC                 |
| $AF51 | $7F51 | $FE51 | `SIGN`   | test sign of FACC                      |
| $AF54 | $7F54 | $FE54 | `FCOMP`  | compare FACC with MEM                  |
| $AF57 | $7F57 | $FE57 | `RND_0`  | generate random floating point number  |

### Movement

| C128  | C65   | X16   | Symbol   | Description                            |
|-------|-------|-------|----------|----------------------------------------|
| $AF5A | $7F5A | $FE5A | `CONUPK` | move RAM MEM to ARG                    |
| $AF5D | $7F5D | $FE5D | `ROMUPK` | move ROM MEM to ARG                    |
| $AF60 | $7F60 | $FE60 | `MOVFRM` | move RAM MEM to FACC                   |
| $AF63 | $7F63 | $FE63 | `MOVFM`  | move ROM MEM to FACC                   |
| $AF66 | $7F66 | $FE66 | `MOVMF`  | move FACC to MEM                       |
| $AF69 | $7F69 | $FE69 | `MOVFA`  | move ARG to FACC                       |
| $AF6C | $7F6C | $FE6C | `MOVAF`  | move FACC to ARG                       |

### X16 Additions

The following calls are not part of the C128/C65 API.

| X16   | Symbol   | Description                                     |
|-------|----------|-------------------------------------------------|
| $FE6F | FADDH    | FAC += .5                                       |
| $FE72 | ZEROFC   | FAC = 0                                         |
| $FE75 | NORMAL   | Normalize FAC                                   |
| $FE78 | NEGFAC   | FAC = -FAC                                      |
| $FE7B | MUL10    | FAC *= 10                                       |
| $FE7E | DIV10    | FAC /= 10                                       |
| $FE81 | MOVEF    | ARG = FAC                                       |
| $FE84 | SGN      | FAC = sgn(FAC)                                  |
| $FE87 | FLOAT    | FAC = (u8).A                                    |
| $FE8A | FLOATS   | FAC = (s16)facho+1:facho                        |
| $FE8D | QINT     | facho:facho+1:facho+2:facho+2 = u32(FAC)        |
| $FE90 | FINLOG   | FAC += (s8).A                                   |
| $FE93 | FOUTC    | Convert FAC to ASCIIZ string at fbuffr - 1 + .Y |
| $FE96 | POLYX    | Polynomial Evaluation 1 (SIN/COS/ATN/LOG)       |
| $FE99 | POLY     | Polynomial Evaluation 2 (EXP)                   |

### Notes

* The full documentation of these functions can be found in the book [C128 Developers Package for Commodore 6502 Development](http://www.zimmers.net/anonftp/pub/cbm/schematics/computers/c128/servicemanuals/C128_Developers_Package_for_Commodore_6502_Development_(1987_Oct).pdf).
* `RND_0`: For .Z=1, the C128 and C65 versions get entropy from the CIA timers. The X16 version takes entropy from .A/.X/.Y instead. So in order to get a "real" random number, you would use code like this:

        LDA #$00
        PHP
        JSR entropy_get ; KERNAL call to get entropy into .A/.X/.Y
        PLP             ; restore .Z=1
        JSR RND_0
* The calls `FADDT`, `FMULTT`, `FDIVT` and `FPWRT` were broken on on the C128/C65. They are fixed on the X16.
* For more information on the additional calls, refer to [Mapping the Commodore 64](http://unusedino.de/ec64/technical/project64/mapping_c64.html) by Sheldon Leemon, ISBN 0-942386-23-X, but note these errata:
   * `FMULT` at $BA28 adds mem to FAC, not ARG to FAC
   * `NORMAL` at $B8D7 is incorrectly documented as being at $B8FE
