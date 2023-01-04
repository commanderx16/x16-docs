<!--
********************************************************************************
NOTICE: This file uses two trailing spaces on some lines to indicate line breaks
for GitHub's Markdown flavor. Do not remove!
********************************************************************************
-->

# Chapter 3: BASIC Programming

## Commodore 64 Compatibility

The Commander X16 BASIC interpreter is 100% backwards-compatible with the Commodore 64 one. This includes the following features:

* All statements and functions
* Strings, arrays, integers, floats
* Max. 80 character BASIC lines
* Printing control characters like cursor control and color codes, e.g.:
	* `CHR$(147)`: clear screen
	* `CHR$(5)`: white text
	* `CHR$(18)`: reverse
	* `CHR$(14)`: switch to upper/lowercase font
	* `CHR$(142)`: switch to uppercase/graphics font
* The BASIC vector table ($0300-0$30B, $0311/$0312)
* SYS arguments in RAM ($030C-$030F).
	* `$030C`: X Register
	* `$030D`: Y Register
	* `$030E`: Status Register/Flags
	* `$030F`: Accumulator

Because of the differences in hardware, the following functions and statements are incompatible between C64 and X16 BASIC programs.

* `POKE`: write to a memory address
* `PEEK`: read from a memory address
* `WAIT`: wait for memory contents
* `SYS`: execute machine language code (when used with ROM code)

The BASIC interpreter also currently shares all problems of the C64 version, like the slow garbage collector.

## New Statements and Functions

There are several new statement and functions. Note that all BASIC keywords (such as `FOR`) get converted into tokens (such as `$81`), and the tokens for the new keywords have not been finalized yet. Therefore, loading BASIC program saved from a different revision of BASIC may mix up keywords.


### BIN$

**TYPE: String Function**  
**FORMAT: BIN$(n)**

**Action:** Return a string representing the binary value of n. If n <= 255, 8 characters are returned and if 255 < n <= 65535, 16 characters are returned.

**EXAMPLE of BIN$ Function:**

	PRINT BIN$(200)   : REM PRINTS 11001000 AS BINARY REPRESENTATION OF 200
	PRINT BIN$(45231) : REM PRINTS 1011000010101111 TO REPRESENT 16 BITS

### BOOT

**TYPE: Command**  
**FORMAT: BOOT**

**Action:** Load and run a PRG file named `AUTOBOOT.X16` from device 8. If the file is not found, nothing is done and no error is printed.

**EXAMPLE of BOOT Statement:**

	BOOT

### CHAR

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

### CLS

**TYPE: Command**  
**FORMAT: CLS**

**Action:** Clears the screen. Same effect as `?CHR$(147);`.

**EXAMPLE of CLS Statement:**

	CLS

### COLOR

**TYPE: Command**  
**FORMAT: COLOR &lt;fgcol&gt;[,&lt;bgcol&gt;]**

**Action:** This command works sets the text mode foreground color, and optionally the background color.

**EXAMPLES of COLOR Statement:**

      COLOR 2   : SET FG COLOR TO RED, KEEP BG COLOR
      COLOR 2,0 : SET FG COLOR TO RED, BG COLOR TO BLACK

### DOS

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

### FMCHORD
**TYPE: Command**  
**FORMAT: FMCHORD &lt;first channel&gt;,&lt;string&gt;**

**Action:** This command uses the same syntax as `FMPLAY`, but instead of playing a series of notes, it will start all of the notes in the string simultaneously on one or more channels. The first parameter to `FMCHORD` is the first channel to use, and will be used for the first note in the string, and subsequent notes in the string will be started on subsequent channels, with the channel after 7 being channel 0.

All macros are supported, even the ones that only affect the behavior of `PSGPLAY` and `FMPLAY`. 

The full set of macros is documented [here](X16%20Reference%20-%20Appendix%20A%20-%20Sound.md#basic-fmplay-and-psgplay-string-macros).

**EXAMPLE of FMCHORD statement:**
```BASIC
10 FMINIT
20 FMVIB 195,10
30 FMINST 1,16:FMINST 2,16:FMINST 3,16 : REM ORGAN
40 FMVOL 1,50:FMVOL 2,50:FMVOL 3,50 : REM MAKE ORGAN QUIETER
50 FMINST 0,11 : REM VIBRAPHONE
60 FMCHORD 1,"O3CG>E T90" : REM START SOME ORGAN CHORDS (CHANNELS 1,2,3)
70 FMPLAY 0,"O4G4.A8G4E2." : REM PLAY MELODY (CHANNEL 0)
80 FMPLAY 0,"O4G4.A8G4E2."
90 FMCHORD 1,"O2G>DB" : REM SWITCH ORGAN CHORDS (CHANNELS 1,2,3)
100 FMPLAY 0,"O5D2D4<B2" : REM PLAY MORE MELODY
110 FMCHORD 1,"O2F" : REM SWITCH ONE OF THE ORGAN CHORD NOTES
120 FMPLAY 0,"R4" : REM PAUSE FOR THE LENGTH OF ONE QUARTER NOTE
130 FMCHORD 1,"O3CEG" : REM SWITCH ALL THREE CHORD NOTES
140 FMPLAY 0,"O5C2C4<G2." : REM PLAY THE REST OF THE MELODY
150 FMCHORD 1,"RRR" : REM RELEASE THE CHANNELS THAT ARE PLAYING THE CHORD
```
This will play the first few lines of *Silent Night* with a vibraphone lead and organ accompaniment.


### FMDRUM
**TYPE: Command**  
**FORMAT: FMDRUM &lt;channel&gt;,&lt;drum number&gt;**

**Action:** Loads a [drum preset](X16%20Reference%20-%20Appendix%20A%20-%20Sound.md#drum-presets "list of drum presets") onto the YM2151 and triggers it. Valid range is from 25 to 87, corresponding to the General MIDI percussion note values. FMDRUM will load a patch preset corresponding to the selected drum into the channel. If you then try to play notes on that same channel without loading an instrument patch, it will use the drum patch that was loaded for the drum sound instead, which may not sound particularly musical.

### FMFREQ
**TYPE: Command**  
**FORMAT: FMFREQ &lt;channel&gt;,&lt;frequency&gt;**

**Action:** Play a note by frequency on the YM2151. The accepted range is in Hz from 17 to 4434. FMFREQ also accepts a frequency of 0 to release the note.

**EXAMPLE of FMFREQ statement:**
```BASIC
0 FMINST 0,160 : REM LOAD PURE SINE PATCH
10 FMINST 1,160 : REM HERE TOO
20 FMFREQ 0,350 : REM PLAY A SINE WAVE AT 350 HZ
30 FMFREQ 1,440 : REM PLAY A SINE WAVE AT 440 HZ ON ANOTHER CHANNEL
40 FOR X=1 TO 10000 : NEXT X : REM DELAY A BIT
50 FMFREQ 0,0 : FMFREQ 1,0 : REM RELEASE BOTH CHANNELS
```
The above BASIC program plays a sound similar to a North American dial tone for a few seconds.

### FMINIT

**TYPE: Command**  
**FORMAT: FMINIT**

**Action:** Initialize YM2151, silence all channels, and load a set of default patches into all 8 channels.

### FMINST

**TYPE: Command**  
**FORMAT: FMINST &lt;channel&gt;,&lt;patch&gt;**

Load an instrument onto the YM2151 in the form of a [patch preset](X16%20Reference%20-%20Appendix%20A%20-%20Sound.md#fm-instrument-patch-presets) into a channel. Valid channels range from 0 to 7. Valid patches range from 0 to 162.

### FMNOTE

**TYPE: Command**  
**FORMAT: FMNOTE &lt;channel&gt;,&lt;note&gt;**

**Action:** Play a note on the YM2151. The note value is constructed as follows. Using hexadecimal notation, the first nybble is the octave, 0-7, and the second nybble is the note within the octave as follows:

| `$x0` | `$x1` | `$x2` | `$x3` | `$x4` | `$x5` | `$x6` | `$x7` | `$x8` | `$x9` | `$xA` | `$xB` | `$xC` | `$xD-$xF` |
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
| Release | C | C&#9839; | D | D&#9839; | E | F | F&#9839; | G | G&#9839; | A | A&#9839; | B | no-op |

Notes can also be represented by negative numbers to skip retriggering, and will thus snap to another note without restarting the playback of the note.

**EXAMPLE of FMNOTE statement:**
```BASIC
0 FMINST 1,64 : REM LOAD SOPRANO SAX
10 FMNOTE 1,$4A : REM PLAYS CONCERT A
20 FOR X=1 TO 5000 : NEXT X : REM DELAYS FOR A BIT
30 FMNOTE 1,0 : REM RELEASES THE NOTE
40 FOR X=1 TO 1000 : NEXT X : REM DELAYS FOR A BIT
50 FMNOTE 1,$3A : REM PLAYS A IN THE 3RD OCTAVE
60 FOR X=1 TO 2500 : NEXT X : REM SHORT DELAY
70 FMNOTE 1,-$3B : REM UP A HALF STEP TO A# WITHOUT RETRIGGERING
80 FOR X=1 TO 2500 : NEXT X : REM SHORT DELAY
90 FMNOTE 1,0 : REM RELEASES THE NOTE
```

### FMPAN

**TYPE: Command**  
**FORMAT: FMPAN &lt;channel&gt;,&lt;panning&gt;**

**Action:** Sets the simple stereo panning on a YM2151 channel. Valid values are as follows:
* 1 = left
* 2 = right
* 3 = both


### FMPLAY
**TYPE: Command**  
**FORMAT: FMPLAY &lt;channel&gt;,&lt;string&gt;**

**Action:** This command is very similar to `PLAY` on other BASICs such as GWBASIC. It takes a string of notes, rests, tempo changes, note lengths, and other macros, and plays all of the notes synchronously.  That is, the FMPLAY command will not return control until all of the notes and rests in the string have been fully played.

The full set of macros is documented [here](X16%20Reference%20-%20Appendix%20A%20-%20Sound.md#basic-fmplay-and-psgplay-string-macros).

**EXAMPLE of FMPLAY statement:**
```BASIC
10 FMINIT : REM INITIALIZE AND LOAD DEFAULT PATCHES, WILL USE E.PIANO
20 FMPLAY 1,"T90 O4 L4" : REM TEMPO 90 BPM, OCTAVE 4, NOTE LENGTH 4 (QUARTER)
30 FMPLAY 1,"CDECCDECEFGREFGR" : REM FIRST TWO LINES OF TUNE
40 FMPLAY 1,"G8A8G8F8EC G8A8G8F8EC" : REM THIRD LINE
50 FMPLAY 1,"C<G>CRC<G>CR" : REM FOURTH LINE
```


### FMVIB
**TYPE: Command**  
**FORMAT: FMVIB &lt;speed&gt;,&lt;depth&gt;**

**Action:** This command sets the LFO speed and the phase and amplitude modulation depth values on the YM2151. The speed value ranges from 0 to 255, and corresponds to an LFO frequency from 0.008 Hz to 32.6 Hz.  The depth value ranges from 0-127 and affects both AMD and PMD.

Only some patch presets (instruments) are sensitive to the LFO. Those are marked in [this table](X16%20Reference%20-%20Appendix%20A%20-%20Sound.md#fm-instrument-patch-presets) with the &#8224; symbol.  The LFO affects all channels equally, and it depends on the instrument as to whether it is affected.

Good values for most instruments are speed somewhere between 190-220. A good light vibrato for most wind instruments would have a depth of 10-15, while tremolo instruments like the Vibraphone or Tremolo Strings are most realistic around 20-30.

**EXAMPLE of FMVIB statement:**
```BASIC
10 FMVIB 200,30
20 FMINST 0,11 : REM VIBRAPHONE
30 FMPLAY 0,"T60 O4 CDEFGAB>C"
40 FMVIB 0,0
50 FMPLAY 0,"C<BAGFEDC"
```
The above BASIC program plays a C major scale with a vibraphone patch, first with a vibrato/tremolo effect, and then plays the scale in reverse with the vibrato turned off.

### FMVOL
**TYPE: Command**  
**FORMAT: FMVOL &lt;channel&gt;,&lt;volume&gt;**

**Action:** This command sets the channel's volume. The volume remains at the requested level until another `FMVOL` command for that channel or `FMINIT` is called.  Valid range is from 0 (completely silent) to 63 (full volume)

### FRAME

**TYPE: Command**  
**FORMAT: FRAME &lt;x1&gt;,&lt;y1&gt;,&lt;x2&gt;,&lt;y2&gt;,&lt;color&gt;**

**Action:** This command draws a rectangle frame on the graphics screen in a given color.

**EXAMPLE of FRAME Statement:**

	10 SCREEN$80
	20 FORI=1TO20:FRAMERND(1)*320,RND(1)*200,RND(1)*320,RND(1)*200,RND(1)*128:NEXT
	30 GOTO20

### GEOS

**TYPE: Command**  
**FORMAT: GEOS**

**Action:** Enter the GEOS UI.

### HEX$

**TYPE: String Function**  
**FORMAT: HEX$(n)**

**Action:** Return a string representing the hexadecimal value of n. If n <= 255, 2 characters are returned and if 255 < n <= 65535, 4 characters are returned.

**EXAMPLE of HEX$ Function:**

	PRINT HEX$(200)   : REM PRINTS C8 AS HEXADECIMAL REPRESENTATION OF 200
	PRINT HEX$(45231) : REM PRINTS B0AF TO REPRESENT 16 BIT VALUE

### JOY

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

### KEYMAP

**TYPE: Command**  
**FORMAT: KEYMAP &lt;string&gt;**

**Action:** This command sets the current keyboard layout. It can be put into an AUTOBOOT file to always set the keyboard layout on boot.

**EXAMPLE of KEYMAP Statement:**

	10 KEYMAP"SV-SE"    :REM SMALL BASIC PROGRAM TO SET LAYOUT TO SWEDISH/SWEDEN
	SAVE"AUTOBOOT.X16"  :REM SAVE AS AUTOBOOT FILE

### LINE

**TYPE: Command**  
**FORMAT: LINE &lt;x1&gt;,&lt;y1&gt;,&lt;x2&gt;,&lt;y2&gt;,&lt;color&gt;**

**Action:** This command draws a line on the graphics screen in a given color.

**EXAMPLE of LINE Statement:**

	10 SCREEN128
	20 FORA=0TO2*\XFFSTEP2*\XFF/200
	30 :  LINE100,100,100+SIN(A)*100,100+COS(A)*100
	40 NEXT

### LOCATE

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

### MON

**TYPE: Command**  
**FORMAT: MON (Alternative: MONITOR)**

**Action:** This command enters the machine language monitor. See the dedicated chapter for a  description.

**EXAMPLE of MON Statement:**

      MON
      MONITOR

### MOUSE

**TYPE: Command**  
**FORMAT: MOUSE &lt;mode&gt;**

**Action:** This command configures the mouse pointer.

| Mode | Description                              |
|------|------------------------------------------|
| 0    | Hide mouse                               |
| 1    | Show mouse, set default mouse pointer    |
| -1   | Show mouse, don't configure mouse cursor |

`MOUSE 1` turns on the mouse pointer and `MOUSE 0` turns it off. If the BASIC program has its own mouse pointer sprite configured, it can use `MOUSE -1`, which will turn the mouse pointer on, but not set the default pointer sprite.

The size of the mouse pointer's area will be configured according to the current screen mode. If the screen mode is changed, the MOUSE statement has to be repeated.

**EXAMPLES of MOUSE Statement:**

	MOUSE 1 : REM ENABLE MOUSE
	MOUSE 0 : REM DISABLE MOUSE

### MX/MY/MB

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

### OLD

**TYPE: Command**  
**FORMAT: OLD**

**Action:** This command recovers the BASIC program in RAM that has been previously deleted using the `NEW` command or through a RESET.

**EXAMPLE of OLD Statement:**

      OLD

### PSET

**TYPE: Command**  
**FORMAT: PSET &lt;x&gt;,&lt;y&gt;,&lt;color&gt;**

**Action:** This command sets a pixel on the graphics screen to a given color.

**EXAMPLE of PSET Statement:**

	10 SCREEN$80
	20 FORI=1TO20:PSETRND(1)*320,RND(1)*200,RND(1)*256:NEXT
	30 GOTO20

### PSGCHORD
**TYPE: Command**  
**FORMAT: PSGCHORD &lt;first voice&gt;,&lt;string&gt;**

**Action:** This command uses the same syntax as `PSGPLAY`, but instead of playing a series of notes, it will start all of the notes in the string simultaneously on one or more voices. The first parameter to `PSGCHORD` is the first voice to use, and will be used for the first note in the string, and subsequent notes in the string will be started on subsequent voices, with the voice after 15 being voice 0.

All macros are supported, even the ones that only affect `PSGPLAY` and `FMPLAY`. 

The full set of macros is documented [here](X16%20Reference%20-%20Appendix%20A%20-%20Sound.md#basic-fmplay-and-psgplay-string-macros).

**EXAMPLE of PSGCHORD statement:**
```BASIC
10 PSGINIT
20 PSGCHORD 15,"O3G>CE" : REM STARTS PLAYING A CHORD ON VOICES 15, 0, AND 1
30 PSGPLAY 14,">C<DGB>CDE" : REM PLAYS A SERIES OF NOTES ON VOICE 14
40 PSGCHORD 15,"RRR" : REM RELEASES CHORD ON VOICES 15, 0, AND 1
50 PSGPLAY 14,"O4CAG>C<A" : REM PLAYS A SERIES OF NOTES ON VOICE 14
60 PSGCHORD 0,"O3A>CF" : REM STARTS PLAYING A CHORD ON VOICES 0, 1, AND 2
70 PSGPLAY 14,"L16FGAB->CDEF4" : REM PLAYS A SERIES OF NOTES ON VOICE 
80 PSGCHORD 0,"RRR" : REM RELEASES CHORD ON VOICES 0, 1, AND 2
```


### PSGFREQ
**TYPE: Command**  
**FORMAT: PSGFREQ &lt;voice&gt;,&lt;frequency&gt;**

**Action:** Play a note by frequency on the VERA PSG. The accepted range is in Hz from 1 to 24319. PSGFREQ also accepts a frequency of 0 to release the note.

**EXAMPLE of PSGFREQ statement:**
```BASIC
10 PSGINIT : REM RESET ALL VOICES TO SQUARE WAVEFORM
20 PSGFREQ 0,350 : REM PLAY A SQUARE WAVE AT 350 HZ
30 PSGFREQ 1,440 : REM PLAY A SQUARE WAVE AT 440 HZ ON ANOTHER VOICE
40 FOR X=1 TO 10000 : NEXT X : REM DELAY A BIT
50 PSGFREQ 0,0 : PSGFREQ 1,0 : REM RELEASE BOTH VOICES
```
The above BASIC program plays a sound similar to a North American dial tone for a few seconds.


### PSGINIT

**TYPE: Command**  
**FORMAT: PSGINIT**

**Action:** Initialize VERA PSG, silence all voices, set volume to 63 on all voices, and set the waveform to pulse and the duty cycle to 63 (50%) for all 16 voices.

### PSGNOTE

**TYPE: Command**  
**FORMAT: PSGNOTE &lt;voice&gt;,&lt;note&gt;**

**Action:** Play a note on the VERA PSG. The note value is constructed as follows. Using hexadecimal notation, the first nybble is the octave, 0-7, and the second nybble is the note within the octave as follows:

| `$x0` | `$x1` | `$x2` | `$x3` | `$x4` | `$x5` | `$x6` | `$x7` | `$x8` | `$x9` | `$xA` | `$xB` | `$xC` | `$xD-$xF` |
|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
| Release | C | C&#9839; | D | D&#9839; | E | F | F&#9839; | G | G&#9839; | A | A&#9839; | B | no-op |

**EXAMPLE of PSGNOTE statement:**
```BASIC
10 PSGNOTE 1,$4A : REM PLAYS CONCERT A
20 FOR X=1 TO 5000 : NEXT X : REM DELAYS FOR A BIT
30 PSGNOTE 1,0 : REM RELEASES THE NOTE
40 FOR X=1 TO 2500 : NEXT X : REM SHORT DELAY
50 PSGNOTE 1,$3A : REM PLAYS A IN THE 3RD OCTAVE
60 FOR X=1 TO 2500 : NEXT X : REM SHORT DELAY
70 PSGNOTE 1,0 : REM RELEASES THE NOTE
```

### PSGPAN

**TYPE: Command**  
**FORMAT: PSGPAN &lt;voice&gt;,&lt;panning&gt;**

**Action:** Sets the simple stereo panning on a VERA PSG voice. Valid values are as follows:
* 1 = left
* 2 = right
* 3 = both

### PSGPLAY
**TYPE: Command**  
**FORMAT: PSGPLAY &lt;voice&gt;,&lt;string&gt;**

**Action:** This command is very similar to `PLAY` on other BASICs such as GWBASIC. It takes a string of notes, rests, tempo changes, note lengths, and other macros, and plays all of the notes synchronously.  That is, the PSGPLAY command will not return control until all of the notes and rests in the string have been fully played.

The full set of macros is documented [here](X16%20Reference%20-%20Appendix%20A%20-%20Sound.md#basic-fmplay-and-psgplay-string-macros).

**EXAMPLE of PSGPLAY statement:**
```BASIC
10 PSGWAV 0,31 : REM PULSE, 25% DUTY
20 PSGPLAY 0,"T180 S0 O5 L32" : REM TEMPO 180 BPM, LEGATO, OCTAVE 5, 32ND NOTES
30 PSGPLAY 0,"C<G>CEG>C<G<A-"
40 PSGPLAY 0,">CE-A-E-A->CE-A-"
50 PSGPLAY 0,"E-<<B->DFB-FB->DFB-F" : REM GRAB YOURSELF A MUSHROOM
```


### PSGVOL
**TYPE: Command**  
**FORMAT: PSGVOL &lt;voice&gt;,&lt;volume&gt;**

**Action:** This command sets the voice's volume. The volume remains at the requested level until another `PSGVOL` command for that voice or `PSGINIT` is called.  Valid range is from 0 (completely silent) to 63 (full volume).

### PSGWAV

**TYPE: Command**  
**FORMAT: PSGWAV &lt;voice&gt;,&lt;w&gt;**

**Action:** Sets the waveform and duty cycle for a PSG voice.
* w = 0-63 -> Pulse: Duty cycle is `(w+1)/128`. A value of 63 means 50% duty.
* w = 64-127 -> Sawtooth (all values have identical effect)
* w = 128-191 -> Triangle (all values have identical effect)
* w = 192-255 -> Noise (all values have identical effect)


### RECT

**TYPE: Command**  
**FORMAT: RECT &lt;x1&gt;,&lt;y1&gt;,&lt;x2&gt;,&lt;y2&gt;,&lt;color&gt;**

**Action:** This command draws a solid rectangle on the graphics screen in a given color.

**EXAMPLE of RECT Statement:**

	10 SCREEN$80
	20 FORI=1TO20:RECTRND(1)*320,RND(1)*200,RND(1)*320,RND(1)*200,RND(1)*256:NEXT
	30 GOTO20

### RESET

**TYPE: Command**  
**FORMAT: RESET**

**Action:** Performs a software reset of the system.

**EXAMPLE of RESET Statement:**

	RESET

### SCREEN

**TYPE: Command**  
**FORMAT: SCREEN &lt;mode&gt;**

**Action:** This command switches screen modes.

For a list of supported modes, see [Chapter 2: Editor](X16%20Reference%20-%2002%20-%20Editor.md). The value of -1 toggles between modes $00 and $03.

**EXAMPLE of SCREEN Statement:**

      SCREEN 3 : REM SWITCH TO 40 CHARACTER MODE
      SCREEN 0 : REM SWITCH TO 80 CHARACTER MODE
      SCREEN -1 : REM SWITCH BETWEEN 40 and 80 CHARACTER MODE

### VPEEK

**TYPE: Integer Function**  
**FORMAT: VPEEK (&lt;bank&gt;, &lt;address&gt;)**

**Action:** Return a byte from the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPEEK Function:**

      PRINT VPEEK(1,$B000) : REM SCREEN CODE OF CHARACTER AT 0/0 ON SCREEN

### VPOKE

**TYPE: Command**  
**FORMAT: VPOKE &lt;bank&gt;, &lt;address&gt;, &lt;value&gt;**

**Action:** Set a byte in the video address space. The video address space has 20 bit addresses, which is exposed as 16 banks of 65536 addresses each.

**EXAMPLE of VPOKE Statement:**

      VPOKE 1,$B000+1,1 * 16 + 2 : REM SETS THE COLORS OF THE CHARACTER
                                   REM AT 0/0 TO RED ON WHITE

### VLOAD

**TYPE: Command**  
**FORMAT: VLOAD &lt;filename&gt;, &lt;device&gt;, &lt;VERA_high_address&gt;, &lt;VERA_low_address&gt;**
	
**Action:** Loads a file directly into VERA RAM. 

**EXAMPLES of VLOAD:**
	
	VLOAD "MYFILE.BIN", 8, 0, $4000  :REM LOADS MYFILE.BIN FROM DEVICE 8 TO VRAM $4000.
	VLOAD "MYFONT.BIN", 8, 1, $F000  :REM LOAD A FONT INTO THE DEFAULT FONT LOCATION ($1F000).

## Other New Features

### Hexadecimal and Binary Literals

The numeric constants parser supports both hex (`$`) and binary (`%`) literals, like this:

      PRINT $EA31 + %1010

The size of hex and binary values is only restricted by the range that can be represented by BASIC's internal floating point representation.

### LOAD into VRAM

In BASIC, the contents of files can be directly loaded into VRAM with the `LOAD` statement. When a secondary address greater than one is used, the KERNAL will now load the file into the VERA's VRAM address space. The first two bytes of the file are used as lower 16 bits of the address. The upper 4 bits are `(SA-2) & 0x0ff` where `SA` is the secondary address.

Examples:

	  10 REM LOAD VERA SETTINGS
	  20 LOAD"VERA.BIN",1,17 : REM SET ADDRESS TO $FXXXX
	  30 REM LOAD TILES
	  40 LOAD"TILES.BIN",1,3 : REM SET ADDRESS TO $1XXXX
	  50 REM LOAD MAP
      60 LOAD"MAP.BIN",1,2 : REM SET ADDRESS TO $0XXXX

### Default Device Numbers

In BASIC, the LOAD, SAVE and OPEN statements default to the last-used IEEE device (device numbers 8 and above), or 8.

## Internal Representation

Like on the C64, BASIC keywords are tokenized.

* The C64 BASIC V2 keywords occupy the range of $80 (`END`) to $CB (`GO`).
* BASIC V3.5 also used $CE (`RGR`) to $FD (`WHILE`).
* BASIC V7 introduced the $CE escape code for function tokens $CE-$02 (`POT`) to $CE-$0A (`POINTER`), and the $FE escape code for statement tokens $FE-$02 (`BANK`) to $FE-$38 (`SLOW`).
* The unreleased BASIC V10 extended the escaped tokens up to $CE-$0D (`RPALETTE`) and $FE-$45 (`EDIT`).

The X16 BASIC aims to be as compatible as possible with this encoding. Keywords added to X16 BASIC that also exist in other versions of BASIC match the token, and new keywords are encoded in the ranges $CE-$80+ and $FE-$80+.

## Auto-Boot

When BASIC starts, it automatically executes the `BOOT` command, which tries to load a PRG file named `AUTOBOOT.X16` from device 8 and, if successful, runs it. Here are some use cases for this:

* An SD card with a game can auto-boot this way.
* An SD card with a collection of applications can show a menu that allows selecting an application to load.
* The user's "work" SD card can contain a small auto-boot BASIC program that sets the keyboard layout and changes the screen colors, for example.
