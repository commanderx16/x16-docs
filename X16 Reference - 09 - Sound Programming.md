## Chapter 9: Sound Programming

* VERA PSG and PCM, refer to the [VERA Programmer's Reference](VERA%20Programmer's%20Reference.md).

### YM2151 (OPM) FM Synthesis

The Yamaha YM2151 (OPM) synthesis chip is an FM synthesis device in the Commander X16.
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

* 1: Ensure YM is not busy: Check `BUSY` flag by reading from `YM_data`
* 2: Select the desired internal register address by writing it into `YM_address`
* 3: Write the new value for this register into `YM_data`

**Notes:**

* You may write into the same register multiple times without repeating a write to `YM_address`.
* You should have a slight pause between writes to `YM_address` and `YM_data`

**Important:** The YM becomes `BUSY` for approximately 150 CPU cycles' (at 8Mhz) whenever it receives a data write. *Any writes into YM_data during this `BUSY` period will be ignored!*

In order to avoid this, you can use the `BUSY` flag which is bit 7 of the `YM status` byte. Read the status byte from `YM_data` (0x9F41). If the top bit (7) is set, the YM may not be written into at this time.
Note that it is not *required* that you read `YM_status`, only that writes occur no less than ~150 CPU cycles apart. For instance, BASIC executes slowly enough that you are in no danger of writing into the YM too fast, so BASIC programs may skip checking `YM_status`.

  **Assembly language example:**

      ...
      LDX #$08  ; .X = YM internal register address
      LDY #$04  ; .Y = Value to be written there
      JSR ym_write
      ...

    ym_write:
      BIT YM_data      ; check busy flag
      BMI ym_write     ; wait until busy flag is clear
      STX YM_addr      ; select YM register $08 (Key-Off/On)
      NOP              ; slight pause before writing data
      STY YM_data      ; write $04 into YM internal register $08.
      RTS

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

### YM2151 Internal Addressing

The YM register address space can be thought of as being divided into 3 ranges:

Range|Type|Description
--|---|----
00 .. 1F|Global Values|Affect individual global parameters such as LFO frequency, noise enable, etc.
20 .. 3F|Channel CFG|Parameters in groups of 8, one per channel. Affect the whole channel.
40 .. FF|Operator CFG|Parameters in groups of 32 - these map to individual operators of each voice.
