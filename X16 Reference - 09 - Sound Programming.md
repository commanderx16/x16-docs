## Chapter 9: Sound Programming

* VERA PSG and PCM, refer to the [VERA Programmer's Reference](VERA%20Programmer's%20Reference.md).

### YM2151 (OPM) FM Synthesis

The Yamaha YM2151 (OPM) sound chip is an FM synthesizer ASIC in the Commander X16.
It is connected to the system bus at I/O address `0x9F40` (address register) and at `0x9F41` (data register). It has 8 independent voices with 4 FM operators each. Each
voice is capable of left/right/both audio channel output. The four operators of each channel may be connected in one of 8 pre-defined "connection algorithms" in order to produce a wide variety of timbres.

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

1. Ensure YM is not busy (see Write Timing below).
2. Select the desired internal register address by writing it into `YM_address`.
3. Write the new value for this register into `YM_data`.

*Note:* You may write into the same register multiple times without repeating a write to `YM_address`. The same register will be updated with each data write.

#### Write Timing: ####

**The YM2151 is sensitive to the speed at which you write data into it. If you
make writes when it is not ready to receive them, they will be dropped and the sound output will be corrupted.**

You must include a delay between writes to the address select register ($9F40) and the subsequent data write. 10 CPU cycles is the recommended minimum delay.


The YM becomes `BUSY` for approximately 150 CPU cycles' (at 8Mhz) whenever it receives a data write. *Any writes into YM_data during this `BUSY` period will be ignored!*

In order to avoid this, you can use the `BUSY` flag which is bit 7 of the `YM status` byte. Read the status byte from `YM_data` (0x9F41). If the top bit (7) is set, the YM may not be written into at this time. Note that it is not *required* that you read `YM_status`, only that writes occur no less than ~150 CPU cycles apart. For instance, BASIC executes slowly enough that you are in no danger of writing into the YM too quickly, so BASIC programs may skip checking `YM_status`.

Lastly, the `BUSY` flag sometimes takes a (very) short period before it goes high. This has only been observed when IMMEDIATELY polling the flag after a write into `YM_data.` As long as your code does not do so, this quirk should not be an issue.

#### Example Code: ####

  **Assembly Language:**

    check_busy:
      BIT YM_data      ; check busy flag
      BMI check_busy   ; wait until busy flag is clear
      LDA #$08         ; Select YM register $08 (Key-Off/On)
      STA YM_addr      ;
      NOP              ;<-+
      NOP              ;  |
      NOP              ;  +--slight pause before writing data
      NOP              ;  |
      NOP              ;<-+
      LDA #$04         ; Write $04 (Release note on channel 4).
      STA YM_data
      RTS

  **BASIC:**

    10 YA=$9F40      : REM YM_ADDRESS
    20 YD=$9F41      : REM YM_DATA
    30 POKE YA,$29   : REM CHANNEL 1 NOTE SELECT
    40 POKE YD,$4A   : REM SET NOTE = CONCERT A
    50 POKE YA,$08   : REM SELECT THE KEY ON/OFF REGISTER
    60 POKE YD,$00+1 : REM RELEASE ANY NOTE ALREADY PLAYING ON CHANNEL 1
    70 POKE YD,$78+1 : REM KEY-ON VOICE 1 TO PLAY THE NOTE
    80 FOR I=1 TO 100 : NEXT I : REM DELAY WHILE NOTE PLAYS
    90 POKE YD,$00+1 : REM RELEASE THE NOTE

### YM2151 Internal Addressing

The YM register address space can be thought of as being divided into 3 ranges:

Range|Type|Description
--|---|----
00 .. 1F|Global Values|Affect individual global parameters such as LFO frequency, noise enable, etc.
20 .. 3F|Channel CFG|Parameters in groups of 8, one per channel. These affect the whole channel.
40 .. FF|Operator CFG|Parameters in groups of 32 - these map to individual operators of each voice.

### YM2151 Register Map

##### Global Settings:
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

### YM2151 Register Details

#### Global Parameters:

**LR** (LFO Reset)

Register $01, bit 1

Setting this bit will disable the LFO and hold it at level 0. Clearing this bit
allows the LFO to operate as normal. (See LFRQ for further info)

**KON** (KeyON)

Register $08

* Bits 0-2: Channel_Number

* Bits 3-6: Operator M1, C1, M2, C2 control bits:
  * 0: Releases note on operator
  * 0->1: Triggers note attack on operator
  * 1->1: No effect

Use this register to start/stop notes. Typically, all 4 operators are triggered/released
together at once. Writing a value of $78+channel_number will start a note on all 4 OPs,
and writing a value of $00+channel_number will stop a note on all 4 OPs.

**NE** (Noise Enable)

Register $0F, Bit 7

When set, the C2 operator of channel 7 will use a noise waveform instead of a sine.

**NFRQ** (Noise Frequency)

Register $0F, Bits 0-4

Sets the noise frequency, $00 is the lowest and $1F is the highest. NE bit must be
set in order for this to have any effect. Only affects operator C2 on channel 7.

**CLKA1** (Clock A, high order bits)

Register $10, Bits 0-7

This is the high-order value for Clock A (a 10-bit value).

**CLKA2** (Clock A, low order bits)

Register $11, Bits 0-1

Sets the 2 low-order bits for Clock A (a 10-bit value).

Timer A's period is
Computed as (64*(1024-ClkA)) / PhiM ms.  (PhiM = 3579.545Khz)

**CLKB** (Clock B)

Register $12, Bits 0-7

Sets the Clock B period. The period for Timer B is computed as (1024*(256-CLKB)) / PhiM ms. (PhiM = 3579.545Khz)

**CSM**

Register $14, Bit 7

When set, the YM2151 will generate a KeyON attack on all 8 channels whenever TimerA overflows.

**Clock ACK**

Register $14, Bits 4-5

Clear (acknowledge) IRQ status generated by TimerA and TimerB (respectively).

**IRQ EN**

Register $14, Bits 2-3

When set, enables IRQ generation when TimerA or TimerB (respectively) overflow.
The IRQ status of the two timers is checked by reading from the YM2151_STATUS byte.
Bit 0 = Timer A IRQ status, and Bit 1 = Timer B IRQ status. Note that these status
bits are only active if the timer has overflowed AND has its IRQ_EN bit set.

**Clock Start**

Register $14, Bits 0-1

When set, these bits clear the TimerA and TimerB (respectively) counters and starts
it running.

**LFRQ** (LFO Frequency)

Register $18, Bits 0-7

Sets the LFO frequency.
* $00 = ~0.008Hz
* $FF = ~32.6Hz

Note that even setting the value zero here results in a positive LFO frequency. Any channels sensitive to the LFO will still be affected by the LFO unless the `LR` bit is set in register $01 to completely disable it.

**AMD** (Amplitude Modulation Depth)

Register $19 Bits 0-6, Bit 7 clear

Sets the peak strength of the LFO's Amplitude Modulation effect. Note that bit 7 of the value written into $19 must be clear in order to set the AMD. If bit 7 is set, the write will be interpreted as PMD.

**PMD** (Phase Modulation Depth)

Register $19 Bits 0-6, Bit 7 set

Sets the peak strength of the LFO's Phase Modulation effect. Note that bit 7 of the value written into $19 must be set in order to set the PMD. If bit 7 is clear, the value is interpreted as AMD.

**CT** (Control pins)

Register $1B, Bits 6-7

These bits set the electrical state of the two CT pins to on/off. These pins are not connected to anything in the X16 and have no effect.

**W** (LFO Waveform)

Register $1B, Bits 0-1

Sets the LFO waveform:
0: Sawtooth, 1: Square (50% duty cycle), 2: Triangle, 3: Noise

#### Channel Control Parameters:

**RL** (Right/Left output enable)

Register $20 (+ channel), Bits 6-7

Setting/Clearing these bits enables/disables audio output for the selected channel. (bit6=left, bit7=right)

**FB** (M1 Self-Feedback)

Register $20 (+ channel), bits 3-5

Sets the amount of self feedback on operator M1 for the selected channel. 0=none, 7=max

**CON** (Connection Algorithm)

Register $20 (+ channel), bits 0-2

Sets the selected channel to connect the 4 operators in one of 8 arrangements.

  [insert picture here]

**KC** (Key Code - Note selection)

Register $28 + channel, bits 0-6

Sets the octave and semitone for the selected channel.
Bits 4-6 specify the octave (0-7) and bits 0-3 specify the semitone:

0|1|2|4|5|6|8|9|A|C|D|E
-|-|-|-|-|-|-|-|-|-|-|-
c#|d|d#|e|f|f#|g|g#|a|a#|b|c

Note that natural C is at the TOP of the selected octave, and that
each 4th value is skipped. Thus if concert A (A-4, 440hz) is KC=$4A, then middle C is KC=$3E

**KF** (Key Fraction)

Register $30 + channel, Bits 2-7

Raises the pitch by 1/64th of a semitone * the KF value.

**PMS** (Phase Modulation Sensitivity)

Register $38 + channel, Bits 4-6

Sets the Phase Modulation (vibrato) sensitivity of the selected channel. The resulting vibrato depth is determined by the combination of the global PMD setting (see above) modified by each channel's PMS.

Sensitivity values: (+/- cents)

0|1|2|3|4|5|6|7
-|-|-|-|-|-|-|-
0|5|10|20|50|100|400|700

**AMS** (Amplitude Modulation Sensitivity)

Register $38 + channel, Bits 0-1

Sets the Amplitude Modulation sensitivity of the selected channel. Note that each operator may individually enable or disable this effect on its output by setting/clearing the AMS-Ena bit (see below). Operators acting as outputs will exhibit a tremolo effect (varying volume) and operators acting as modulators will vary their effectiveness on the timbre when enabled for amplitude modulation.

Sensitivity values: (dB)

0|1|2|3
-|-|-|-
0|23.90625|47.8125|95.625

#### Operator Control Parameters:

Operators are arranged as follows:

name|M1|M2|C1|C2
-|-|-|-|-
index|0|1|2|3

These are the names used throughout this document for consistency, but they may function as either modulators or carriers, depending on which `CON` ALG is used.

The Operator Control parameters are mapped to channels/operators as follows: Register + 8\*op + channel. You may also choose to think of these register addresses as using bits 0-2 = channel, bits 3-4 = operator, and bits 5-7 = parameter. This reference will refer to them using the address range, e.g. $60-$7F = TL. To set TL for channel 2, operator 1, the register address would be $6A ($60 + 1\*8 + 2).


**DT1** (Detune 1 - fine detune)

Registers $40-$5F, Bits 4-6

Detunes the operator from the channel's main pitch. Values 0 and 4=no detuning.
Values 1-3=detune up, 5-7 = detune down.<br/>
The amount of detuning varies with pitch. It decreases as the channel's pitch increases.

**MUL** (Frequency Multiplier)

Registers $40-$5F, Bits 0-3

If MUL=0, it multiplies the operator's frequency by 0.5<br/>
Otherwise, the frequency is multiplied by the value in MUL (1,2,3...etc)

**TL** (Total Level - attenuation)

Registers $60-$7F, Bits 0-6

This is essentially "volume control" - It is an attenuation value, so $00 = maximum level and $7F is minimum level. On output operators, this is the volume output by that operator. On modulating operators, this affects the amount of modulation done to other operators.

**KS** (Key Scaling)

Registers $80-$9F, Bits 6-7

Controls the speed of the ADSR progression. The KS value sets four different levels of scaling. Key scaling increases along with the pitch set in KC. 0=min, 3=max

**AR** (Attack Rate)

Registerss $80-$9F, Bits 0-4

Sets the attack rate of the ADSR envelope. 0=slowest, $1F=fastest

**AMS-Enable** (Amplitude Modulation Sensitivity Enable)

Registers $A0-$BF, Bit 7

If set, the operator's output level will be affected by the LFO according to the channel's AMS setting. If clear, the operator will not be affected.

**D1R** (Decay Rate 1)

Registers $A0-$BF, Bits 0-4

Controls the rate at which the level falls from peak down to the sustain level (D1L). 0=none, $1F=fastest.

**DT2** (Detune 2 - coarse)

Registers $C0-$DF, Bits 6-7

Sets a strong detune amount to the operator's frequency. Yamaha suggests that this is most useful for sound effects. 0=off,

**D2R** (Decay Rate 2)

Registers $C0-$DF, Bits 0-4

Sets the Decay2 rate, which takes effect once the level has fallen from peak down to the sustain level (D1L). This rate continues
until the level reaches zero or until the note is released.

0=none, $1F=fastest

**D1L**

Registers $E0-$FF, Bits 4-7

Sets the level at which the ADSR envelope changes decay rates from D1R to D2R. 0=minimum (no D2R), $0F=maximum (immediately at peak, which effectively disables D1R)


**RR**

Registers $E0-$FF, Bitst 0-3

Sets the rate at which the level drops to zero when a note is released. 0=none, $0F=fastest

<br/>

___

## Getting sound out of the YM2151 (a brief tutorial)

While there is a large number of parameters that affect the sound of the YM2151, its operation can be thought of in simplified terms if you consider that there are basically three components to deal with: Instrument configuration (patch), voice pitch selection,
and "pressing/releasing" the "key" to trigger (begin) and release (end) notes. It's essentially the
same as using a music keyboard. Pressing an instrument button (e.g. Marimba) makes the keyboard
sound like a Marimba. Once this is done, you press a key on the keyboard to play a note,
and release it to stop the note. With the YM, loading a patch (pressing the Marimba button) entails setting all of
the various operators' registers on the voice(s) you want the instrument to be used on.
On the music keyboard, pitch and note stop/start are done with a single piano key. In the
YM2151, these are two distinct actions.

For this tutorial, we will start with the simplest operation, (triggering notes) and proceed to note selection, and finally patch configuration.

### Triggering and Releasing Notes: ###

**Key On/Off (KON) Register ($08):**

This is probably the most important single register in the YM2151. It is used to trigger and release notes. It controls the key on/off state for all 8 channels. A note is triggered whenever its key state changes from off to on, and is released whenever the state changes from on to off. Repeated writes of the same state (off->off or on->on) have no effect.

Whenever an operator is triggered, it progresses through the states of attack, decay1, and sustain/decay2. Whenever an active note is released, it enters the release state where the volume decreases until reaching zero. It then remains silent until the next time the operator is triggered. If you are familiar with the C64 SID chip, this is the same behavior as the "gate" bit on that chip.

Key state and voice selection are both contained in the value written into the KON register as follows:

* Key ON = $78 + channel number
* Key OFF = $0 + channel number

**Simple Examples:**

To release the note in channel 4: write $08 to `YM_address` ($9F40) and then write $04 ($00+4) to `YM_data` ($9F41).

To begin a note on channel 7, write $08 into `YM_address` to select the KON register. Then write $7F ($78+7) into `YM_data`

If the current key state of a channel is not known, you can write key off and then key on immediately (after waiting for the YM busy period to end, of course):

    POKE $9F40,$08 : REM SELECT KEY ON/OFF REGISTER
    POKE $9F41,$07 : REM KEY OFF FOR VOICE 7
    POKE $9F41,$7F : REM KEY ON  FOR VOICE 7

*Remember: BASIC is slow enough that you do not need to poll the `YM_status` byte, but assembly and other languages will need to do so.*

The ADSR parameters will be discussed in more detail later.

**Advanced:**

Each channel (voice) of the YM2151 uses 4 operators which can be gated together or independently. Independent triggering gives lots of advanced possibilities. To trigger and release operators independently, you use different values than $78 or $00. These values are composed by 4 bits which signal the on/off state for each operator.

Suppose a note is playing on channel 2 with all 4 operators active. You can release only the M1 operator by writing $72 into register $08.

**The KON value format:**
<table>
  <tr>
    <td>7</td>
    <td>6</td>
    <td>5</td>
    <td>4</td>
    <td>3</td>
    <td>2</td>
    <td>1</td>
    <td>0</td>
  </tr>
  <tr>
    <td> - </td>
    <td>C2</td>
    <td>M2</td>
    <td>C1</td>
    <td>M1</td>
    <td colspan="3">Channel</td>
  </tr>
</table>

### Pitch Control

**YM Registers:**
* `KC` = $28 + channel number
* `KF` = $30 + channel number

For note selection, each voice has two parameters: `KC` (Key Code) and `KF` (Key Fraction).
These are set in register ranges $28 and $30, respectively. The KC codes correspond
directly to the notes of the chromatic scale. Each value maps to a specific octave & semitone. The `KF` value can even be ignored
for basic musical playback. It is mostly useful for vibrato or pitch bend effects. `KF` raises
the pitch selected in `KC` in 1/64th increments of the way up to the next semitone.

Like all registers in the YM, whenever a channel's `KC` or `KF` value is written, it takes effect immediately. If a note is playing, its pitch immediately changes. When triggering new notes, it is not important whether you write the pitch or key the note first. This happens quickly in real-time and you will not hear any real difference. Changing the pitch without re-triggering the ADSR envelope is how to achieve pitch slides or a legato effect.

###### Key Code (KC):

`KC` codes are "conveniently" arranged so that the upper nybble is the octave (0-7) and the
lower nybble is the pitch. The pitches are arranged as follows within an octave:

Note|C#|D|D#|E|F|F#|G|G#|A|A#|B|C
--|-|-|-|-|-|-|-|-|-|-|-|-
Low Nybble (hex)|0|1|2|4|5|6|8|9|A|C|D|E

(Note that every 4th value is skipped.)

Combine the above with an octave to get a note's `KC` value. For instance: concert A (440hz) is (by sheer coincidence) `$4A`. Middle C is `$3E`, and so forth.

###### Key Fraction (KF):
`KF` values are written into the top 6 bits of the voice's `KF` register. Basically the value is `0, 1<<2, 2<<2, .. 63<<2`

### Loading a patch

The patch configuration is by far the most complicated aspect of using the YM. If you take as given that a voice has a patch loaded, then playing notes on it is fairly straightforward. For the
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

Once a voice has been patched as above, you can now POKE notes into it with very few commands for each note.

Patches consist mostly of ADSR envelope parameters. A complete patch contains values for the $20 range register (LR|FB|CON), for the $38 range register (AMS|PMS), and 4 values for each of the parameter ranges starting at $40. (4 operators per voice means 4 values per parameter). Since this is a huge amount of flexibility, it is recommended to experiment with instrument creation in an application such as a chip tracker or VST, as the creative process of instrument design is very hands-on and subjective.


### Using the LFO

There is a single global LFO in the YM2151 which can affect the level (volume) and/or pitch of all 8 channels simultaneously. It has a single frequency and waveform setting which must be shared among all channels, and shared between both phase and amplitude modulation. The global parameters `AMD` and `PMD` act as modifiers to the sensitivity settings of the channels. While the frequency and waveform of the LFO pattern must be shared, the depths of the two types of modulation are independent of each other.

You can re-trigger the LFO by setting and then clearing the `LR` bit in the test register ($01).

#### Vibrato:

Use Phase Modulation on the desired channels. The `PMS` parameter for each channel allows them to vary their vibrato depths individually. Channels with `PMS` set to zero will have no vibrato. The values given earlier in the `PMS` parameter description represent their maximum amount of affect. These values are modified by the global `PMD.` A `PMD` valie of $7F means 100% effectiveness, $40 means all channels' vibrato depths will be reduced by half, etc.

The vibrato speed is global, depending solely on the value set to `LFRQ.`

#### Amplitude Modulation:

Amplitude modulation works similarly to phase modulation, except that the intensity is a combination of the per-channel `AMS` value modified by the global `AMD` value. Additionally, within channels having non-zero amplitude modulation sensitivity, individual operators must have their `AMS-en` bit enabled in order to be affected by the modulation.

If the active operators are acting as carriers (generating output directly), then amplitude modulation will vary the volume of the sound being produced by that operator. This can be described as a "tremelo" effect. If the operators are acting as modulators, then the timbre of the voice will vary as the output level of the affected operators increases and decreases. You may simultaneously enable amplitude modulation on both types of operators.

The amplitude modulation speed is global, depending solely on the value set to `LFRQ.`
