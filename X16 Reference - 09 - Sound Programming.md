## Chapter 9: Sound Programming

* VERA PSG and PCM, refer to the [VERA Programmer's Reference](VERA%20Programmer's%20Reference.md).

### YM2151 (OPM) FM Synthesis

The Yamaha YM2151 (OPM) sound chip is an FM synthesizer ASIC in the Commander X16.
It is connected to the system bus at I/O address `0x9F40` (address register) and at `0x9F41` (data register). It has 8 independent voices with 4 FM operators each. Each
voice is capable of left/right/both audio channel output. The operators may be connected in one of 8 pre-defined "connection algorithms" in order to produce a wide
variety of timbres.

#### YM2151 Communication:

There are 3 basic operations to communicate with the YM chip: Reading its status,
address select, and data write. These are performed by reading from or writing to
one of the two I/O addresses as follows:

Address|Name|Read Action|Write Action
--|--|-----|-----
0x9F40|`YM_address`|Undefined (returns ?)|Selects the internal register address where data is written.
0x9F41|`YM_data`|Returns the `YM_status` byte|Writes the value into the currently-selected internal address.

The values stored in the YM's internal registers are write-only. If you need
to know the values in the registers, you must store a copy of the values somewhere in memory as you write updates to the YM.

#### YM Write Procedure

1. Ensure YM is not busy: Check `BUSY` flag by reading from `YM_data`
2. Select the desired internal register address by writing it into `YM_address`
3. Write the new value for this register into `YM_data`

**Notes:**

* You may write into the same register multiple times without repeating a write to `YM_address`.
* You should have a slight pause between writes to `YM_address` and `YM_data`

**Important:** The YM becomes `BUSY` for approximately 150 CPU cycles' (at 8Mhz) whenever it receives a data write. *Any writes into YM_data during this `BUSY` period will be ignored!*

In order to avoid this, you can use the `BUSY` flag which is bit 7 of the `YM status` byte. Read the status byte from `YM_data` (0x9F41). If the top bit (7) is set, the YM may not be written into at this time.
Note that it is not *required* that you read `YM_status`, only that writes occur no less than ~150 CPU cycles apart. For instance, BASIC executes slowly enough that you are in no danger of writing into the YM too fast, so BASIC programs may skip checking `YM_status`.

  **Assembly language example:**

    ym_write:
      BIT YM_data      ; check busy flag
      BMI ym_write     ; wait until busy flag is clear
      STX YM_addr      ; .X = YM register address
      NOP              ; slight pause before writing data
      STY YM_data      ; .Y = Value to be written into YM register
      RTS

      ...
      LDX #$08  ; Select YM register $08 (Key-Off/On)
      LDY #$04  ; Write $04 (Release note on channel 4).
      JSR ym_write
      ...


  **BASIC Example:**

    10 YA=$9F40      : REM YM_ADDRESS
    20 YD=$9F41      : REM YM_DATA
    30 POKE YA,$29   : REM CHANNEL 1 NOTE SELECT
    40 POKE YD,$4A   : REM SET NOTE = CONCERT A
    50 POKE YA,$08   : REM SELECT THE KEY ON/OFF REGISTER
    60 POKE YD,$00+1 : REM RELEASE ANY NOTE ALREADY PLAYING ON CHANNEL 1
    70 POKE YD,$78+1 : REM KEY-ON VOICE 1 TO PLAY THE NOTE
    80 FOR I=1 TO 100 : NEXT I : REM DELAY WHILE NOTE PLAYS
    90 POKE YD,$00+1 : REM RELEASE THE NOTE

### Getting sound out of the YM2151

While there is a large number of parameters that affect the sound of the YM2151, its operation can be thought of in simplified terms if you consider that there are basically three components to deal with: Instrument configuration (patch), voice pitch selection,
and "pressing/releasing" the "key" to trigger and end notes. It's essentially the
same as using a music keyboard. Pressing an instrument button (e.g. Marimba) makes it
sound like a Marimba. Once this is done, you press a key on the keyboard to play a note,
and release it to stop the note. With the YM, loading a patch entails setting all of
the various operator registers for the voice(s) you want the instrument to be on.
On the music keyboard, pitch and note stop/start are done with a single piano key. In the
YM2151, these are two distinct actions.

#### Loading a patch

The patch configuration is by far the most complicated aspect of using the YM. If you take as given that a
voice has a patch loaded, then playing notes on it is fairly straightforward. For the
moment, we will assume a pre-patched voice.

  To get started quickly, here is some BASIC code to patch voice 0 with a marimba tone:

    5 YA=$9F40 : YD=$9F41 : V=0
    10 REM: MARIMBA PATCH FOR YM VOICE 0 (SET V=0..7 FOR OTHER VOICES)
    20 DATA $DC,$00,$1B,$67,$61,$31,$21,$17,$1F,$0A,$DF,$5F,$DE
    30 DATA $DE,$0E,$10,$09,$07,$00,$05,$07,$04,$FF,$A0,$16,$17
    40 READ D
    50 POKE YA,$20+V : POKE YD,D
    60 FOR A=$38 TO $F8 STEP 8
    70 READ D : POKE YA,A+V : POKE YD,D
    80 NEXT A

Once a voice has been patched as above, you can now POKE notes into it with very
few commands for each note.

#### Pitch Control

**YM Registers:**
* `KC` = $28 + channel number
* `KF` = $30 + channel number

For note selection, each voice has two parameters: `KC` (Key Code) and `KF` (Key Fraction).
These are set in register ranges $28 and $30, respectively. The KC codes correspond
directly with the notes of the chromatic scale. The `KF` value can even be ignored
for basic musical playback, being important for vibrato or pitch bend effects. `KF` raises
the pitch selected in `KC` by 1/64th increments of the way up to the next semitone.

Like all registers in the YM, whenever a channel's `KC` or `KF` value is written, it takes effect immediately. If a note is playing, its pitch immediately changes without re-triggering the ADSR envelope. Thus, it is not important whether you write the note first or key the note first.

###### Key Code (KC):
`KC` codes are "conveniently" arranged so that the upper nybble is the octave (0-7) and the
lower nybble is the pitch. The pitches are arranged as follows within an octave:

Note|C#|D|D#|E|F|F#|G|G#|A|A#|B|C
--|-|-|-|-|-|-|-|-|-|-|-|-
Low Nybble (hex)|0|1|2|4|5|6|8|9|A|C|D|E

(Note that every 4th value is skipped.)

Combine the above with an octave to get a note's `KC` value. For instance: concert
A (440hz) is (by sheer coincidence) `$4A`. Middle C is `$3E`, and so forth.

###### Key Fraction (KF):
`KF` values are written into the top 6 bits of the voice's `KF` register. Basically the value is `0, 1<<2, 2<<2, .. 63<<2`

#### Key On/Off: (KON)

YM Register $08 is the register for controlling the key on/off state for all 8 channels.

Patches consist mostly of ADSR envelope parameters, one set for each of the 4 operators
in the channel. Whenever a note begins (key ON), the operators go through the progression
of attack, decay, sustain. Whenever an active note is released (key OFF) it goes through
the release cycle until the volume reaches zero, and remains silent until the next key ON
event. If you are familiar with the C64 SID chip, this is the same as the "gate" bit on
that chip.

The YM2151 allows you to gate the ADSR envelopes of the 4 operators of a channel independently. However, for basic operation, you can simply key all 4 together in a single
write. The value written into register $08 contains both the desired key state (on/off) and the channel number.

* Key ON = $78 + channel number
* Key OFF = $0 + channel number

So to release the note in channel 4: write $08 to `YM_address` ($9F40) and then write $04 to `YM_data` ($9F41).

To begin a note on channel 7, write $08 into `YM_address` and then write $7F ($78+7) into `YM_data`

If the current key state of a channel is not known, you can write key off and then key on immediately (after waiting for the YM busy period to end, of course):

    POKE $9F40,$08 : REM SELECT KEY ON/OFF REGISTER
    POKE $9F41,$07 : REM KEY OFF FOR VOICE 7
    POKE $9F41,$7F : REM KEY ON  FOR VOICE 7

Remember: BASIC is slow enough that you do not need to poll the `YM_status` byte, but assembly and other languages will need to do so.

### Intro Conclusion

This concludes the basic introduction to the YM2151 chip. This should be enough to
get basic utilization of the chip working. In summary, the steps to make sound are to load patch data into the channel(s) desired for playback, then loop through music data sending notes (`KF`) and key off/on events to the chip. For instrument patch settings, you can
either use a music tool such as a chiptune tracker or YM2151 VST plugin to interactively
design a patch, and then write down the various parameter values for entry into the YM,
or use OPM patch files for reference, as they contain the raw bytes in plaintext in the
order used above in the Marimba patch BASIC code example.

### YM2151 Internal Addressing

The YM register address space can be thought of as being divided into 3 ranges:

Range|Type|Description
--|---|----
00 .. 1F|Global Values|Affect individual global parameters such as LFO frequency, noise enable, etc.
20 .. 3F|Channel CFG|Parameters in groups of 8, one per channel. These affect the whole channel.
40 .. FF|Operator CFG|Parameters in groups of 32 - these map to individual operators of each voice.

### YM2151 Register Map

##### Global Registers:
<table>
  <tr>
    <th rowspan="2">Addr</th>
    <th rowspan="2">Register</th>
    <th colspan="8">Bits</th>
    <th rowspan="2">Description</th>
  </tr>
  <tr>
    <th>7</th>
    <th>6</th>
    <th>5</th>
    <th>4</th>
    <th>3</th>
    <th>2</th>
    <th>1</th>
    <th>0</th>
  </tr>
  <tr>
    <td>$01</td>
    <td>Test Register</td>
    <td>!</td>
    <td>!</td>
    <td>!</td>
    <td>!</td>
    <td>!</td>
    <td>!</td>
    <TD>LR</TD>
    <td>!</td>
    <td>
      Bit 1 is the LFO reset bit. Setting it disables the LFO and holds the oscillator at 0. Clearing it enables the LFO.<br />
      All other bits control various test functions and should not be written into.
    </td>
  </tr>
  <tr>
    <td>$08</td>
    <td>Key Control</td>
    <td>.</td>
    <td>C2</td>
    <td>M2</td>
    <td>C1</td>
    <td>M1</td>
    <td colspan="3">CHA</td>
    <td>
      Starts and Releases notes on the 8 channels.<br />
      Setting/Clearing bits for M1,C1,M2,C2 controls the key state
      for those operators on channel CHA.<br />
      NOTE: The operator order is different than the order they
      appear in the Operator configuration registers!
    </td>
  </tr>
  <tr>
    <td>$0F</td>
    <td>Noise Control</td>
    <td>NE</td>
    <td>.</td>
    <td>.</td>
    <td colspan="5">NFRQ</td>
    <td>
      NE = Noise Enable<br />
      NFRQ = Noise Frequency<br />
      When eabled, C2 of channel 7 will use a noise waveform instead
      of a sine waveform.
    </td>
  </tr>
  <tr>
    <td>$10</td>
    <td>Ta High</td>
    <td colspan="8">CLKA1</td>
    <td>Top 8 bits of Timer A period setting</td>
  </tr>
  <tr>
    <td>$11</td>
    <td>Ta Low</td>
    <td>.</td>
    <td>.</td>
    <td>.</td>
    <td>.</td>
    <td>.</td>
    <td>.</td>
    <td colspan="2">CLKA2</td>
    <td>Bottom 2 bits of Timer A period setting</td>
  </tr>
  <tr>
    <td>$12</td>
    <td>Timer B</td>
    <td colspan="8">CLKB</td>
    <td>Timer B period setting</td>
  </tr>
  <tr>
    <td colspan="2"></td>
    <th>7</th>
    <th>6</th>
    <th>5</th>
    <th>4</th>
    <th>3</th>
    <th>2</th>
    <th>1</th>
    <th>0</th>
    <td></td>
  </tr>

  <tr>
    <td>$14</td>
    <td>IRQ Control</td>
    <td>CSM</td>
    <td>.</td>
    <td colspan="2">Clock ACK</td>
    <td colspan="2">IRQ EN</td>
    <td colspan="2">Clock Start</td>
    <td>
      CSM: When a timer expires, trigger note key-on for all channels.<br />
      For the other 3 fields, lower bit = Timer A, upper bit = Timer B.<br />
      Clock ACK: clears the timer's bit in the YM_status byte and acknowledges the IRQ.<br />
    </td>
  </tr>
  <tr>
    <td>$18</td>
    <td>LFO Freq.</td>
    <td colspan="8">LFRQ</td>
    <td>Sets LFO frequency.<br />
    $00 = ~0.008Hz<br />
    $FF = ~32.6Hz</td>
  </tr>
  <tr>
    <td rowspan="2">$19</td>
    <td rowspan="2">LFO Amplitude</td>
    <td>0</td>
    <td colspan="7">AMD</td>
    <td rowspan="2">
      AMD = Amplitude Modulation Depth<br />
      PMD = Phase Modulation (vibrato) Depth<br />
      Bit 7 determines which parameter is being set when writing into
      this register.
    </td>
  </tr>
  <tr>
    <td>1</td>
    <td colspan="7">PMD
  <tr>
    <td>$1B</td>
    <td>CT / LFO Waveform</td>
    <td colspan="2">CT</td>
    <td>.</td>
    <td>.</td>
    <td>.</td>
    <td>.</td>
    <td colspan="2">W</td>
    <td>
      CT: sets output pins CT1 and CT1 high or low. (not connected to anything in X16)<br />
      W: LFO Waveform: 0-4 = Saw, Square, Triange, Noise<br />
      For sawtooth: PM->////  AM->\\\\
    </td>
  </tr>
</table>




##### Channel CFG Registers:
<table>
  <tr>
    <th rowspan="2">Register Range</th>
    <th colspan="8">Register bits</th>
    <th rowspan="2">Description
  </tr>
  <tr>
    <th>7</th>
    <th>6</th>
    <th>5</th>
    <th>4</th>
    <th>3</th>
    <th>2</th>
    <th>1</th>
    <th>0</th>
  </tr>
  <tr>
    <td>$20 + channel</td>
    <td colspan="2">RL</td>
    <td colspan="3">FB</td>
    <td colspan="3">CON</td>
    <td rowspan="4">
      <dl>
        <dt>RL</dt><dd>Right/Left Output Enable</dd>
        <dt>FB</dt><dd>M1 Feedback Level</dd>
        <dt>CON</dt><dd>Operator connection algorithm</dd>
        <dt>KC</dt><dd>Key Code</dd>
        <dt>KF</dt><dd>Key Fraction</dd>
        <dt>PMS</dt><dd>Phase Modulation Sensitivity</dd>
        <dt>AMS</dt><dd>Amplitude Modulation Sensitivity</dd>
      </dl>
    </td>
  </tr>
  <tr>
    <td>$28 + channel</td>
    <td>.</td>
    <td colspan="7">KC</td>
  </tr>
  <tr>
    <td>$30 + channel</td>
    <td colspan="6">KF</td>
    <td>.</td>
    <td>.</td>
  </tr>
  <tr>
    <td>$38 + channel</td>
    <td>.</td>
    <td colspan="3">PMS</td>
    <td>.</td>
    <td>.</td>
    <td colspan="2">AMS</td>
  </tr>
</table>

##### Operator CFG Registers:
<table>
  <tr>
    <th rowspan="2">Register<br />Range</th>
    <th rowspan="2">Operator</th>
    <th colspan="8">Register Bits</th>
    <th rowspan="2">Description</th>
  </tr>
  <tr>
    <th>7</th>
    <th>6</th>
    <th>5</th>
    <th>4</th>
    <th>3</th>
    <th>2</th>
    <th>1</th>
    <th>0</th>
  </tr>
  <tr>
    <td rowspan="4" valign="top">$40</td>
    <td>M1: $40+channel</td>
    <td rowspan="4" >.</td>
    <td rowspan="4" colspan="3">DT1</td>
    <td rowspan="4" colspan="4">MUL</td>
    <td rowspan="4" valign="top">
      <dl>
        <dt>DT1</dt><dd>Detune Amount (fine)</dd>
        <dt>MUL</dt><dd>Frequency Multiplier</dd>
      </dl>
    </td>
  </tr>
  <tr>
    <td>M2: $48+channel</td>
  </tr>
  <tr>
    <td>C1: $50+channel</td>
  </tr>
  <tr>
    <td>C2: $58+channel</td>
  </tr>
  <tr>
    <td rowspan="4" valign="top">$60</td>
    <td>M1: $60+channel</td>
    <td rowspan="4" >.</td>
    <td rowspan="4" colspan="7">TL</td>
    <td rowspan="4" valign="top">
      <dl>
        <dt>TL</dt><dd>Total Level (volume attenuation)<br/>
                       (0=max, $7F=min)
        </dd>
      </dl>
    </td>
  </tr>
  <tr>
    <td>M2: $68+channel</td>
  </tr>
  <tr>
    <td>C1: $70+channel</td>
  </tr>
  <tr>
    <td>C2: $78+channel</td>
  </tr>
  <tr>
    <td rowspan="4" valign="top">$80</td>
    <td>M1: $80+channel</td>
    <td rowspan="4" colspan="2">KS</td>
    <td rowspan="4" >.</td>
    <td rowspan="4" colspan="5">AR</td>
    <td rowspan="4" valign="top">
      <dl>
        <dt>KS</dt><dd>Key Scaling (ADSR rate scaling)</dd>
        <dt>AR</dt><dd>Attack Rate</dd>
      </dl>
    </td>
  </tr>
  <tr>
    <td>M2: $88+channel</td>
  </tr>
  <tr>
    <td>C1: $90+channel</td>
  </tr>
  <tr>
    <td>C2: $98+channel</td>
  </tr>
  <tr>
    <td rowspan="4" valign="top">$A0</td>
    <td>M1: $A0+channel</td>
    <td rowspan="4">A<br />M<br /><br />E<br />n<br />a</td>
    <td rowspan="4" >.</td>
    <td rowspan="4" >.</td>
    <td rowspan="4" colspan="5">D1R</td>
    <td rowspan="4" valign="top">
      <dl>
        <dt>AM-Ena</dt><dd>Amplitude Modulation Enable</dd>
        <dt>D1R</dt><dd>Decay Rate 1<br />
                        (From peak down to sustain level)
        </dd>
      </dl>
    </td>
  </tr>
  <tr>
    <td>M2: $A8+channel</td>
  </tr>
  <tr>
    <td>C1: $B0+channel</td>
  </tr>
  <tr>
    <td>C2: $B8+channel</td>
  </tr>
  <tr>
    <td rowspan="4" valign="top">$C0</td>
    <td>M1: $C0+channel</td>
    <td rowspan="4" colspan="2">DT2</td>
    <td rowspan="4" >.</td>
    <td rowspan="4" colspan="5">D2R</td>
    <td rowspan="4" valign="top">
      <dl>
        <dt>DT2</dt><dd>Detune Amount (coarse)</dd>
        <dt>D2R</dt><dd>Decay Rate 2<br />
                        (During sustain phase)
        </dd>
      </dl>
    </td>
  </tr>
  <tr>
    <td>M2: $C8+channel</td>
  </tr>
  <tr>
    <td>C1: $D0+channel</td>
  </tr>
  <tr>
    <td>C2: $D8+channel</td>
  </tr>
  <tr>
    <td rowspan="4" valign="top">$E0</td>
    <td>M1: $E0+channel</td>
    <td rowspan="4" colspan="4">D1L</td>
    <td rowspan="4" colspan="4">RR</td>
    <td rowspan="4" valign="top">
      <dl>
        <dt>D1L</dt><dd>Decay 1 Level (Sustain level)<br />
                        Level at which decay switches from D1R to D2R
        </dd>
        <dt>RR</dt><dd>Release Rate</dd>
      </dl>
    </td>
  </tr>
  <tr>
    <td>M2: $E8+channel</td>
  </tr>
  <tr>
    <td>C1: $F0+channel</td>
  </tr>
  <tr>
    <td>C2: $F8+channel</td>
  </tr>
</table>
