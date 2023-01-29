# Chapter 10: Commander X16 Programmer's Reference Guide

## I/O Programming

There are two 65C22 "Versatile Interface Adapter" (VIA) I/O controllers in the system, VIA#1 at address $9F00 and VIA#2 at address $9F10. The IRQ out lines of VIA#1 is connected to the CPU's NMI line, while the IRQ out line of VIA#2 is connected to the CPU's IRQ line.

The-following tables describe the connections of the I/O pins:

**VIA#1**


|Pin  |Name      | Description                     |
|-----|----------|---------------------------------|
| PA0 | I2CDATA  | I2C Data                        |
| PA1 | I2CCLK   | I2C Clock                       |
| PA2 | NESLATCH | NES LATCH (for all controllers) |
| PA3 | NESCLK   | NES CLK   (for all controllers) |
| PA4 | NESDAT3  | NES DATA  (controller 3)        |
| PA5 | NESDAT2  | NES DATA  (controller 2)        |
| PA6 | NESDAT1  | NES DATA  (controller 1)        |
| PA7 | NESDAT0  | NES DATA  (controller 0)        |
| PB0 | _Unused_ |                                 |
| PB1 | _Unused_ |                                 |
| PB2 | _Unused_ |                                 |
| PB3 | SERATNO  | Serial ATN  out                 |
| PB4 | SERCLKO  | Serial CLK  out                 |
| PB5 | SERDATAO | Serial DATA out                 |
| PB6 | SERCLKI  | Serial CLK  in                  |
| PB7 | SERDATAI | Serial DATA in                  |
| CA1 | _Unused_ |                                 |
| CA2 | _Unused_ |                                 |
| CB1 | IECSRQ   |                                 |
| CB2 | _Unused_ |                                 |

The KERNAL uses Timer 2 for timing transmissions on the Serial Bus.

**VIA#2**

The second VIA is completely unused by the system. All its 16 GPIOs and 4 handshake I/Os can be freely used.

### I2C Bus

The Commander X16 contains an I2C bus, which is implemented through two pins of VIA#1. The system management controller (SMC) and the real-time clock (RTC) are connected through this bus. The KERNAL APIs `i2c_read_byte` and `i2c_write_byte` allow talking to these devices.

#### System Management Controller

The system management controller (SMC) is device $42 on the I2C bus. It controls the power and activity LEDs, and can be used to power down the system or inject RESET and NMI signals.

| Register | Value    | Description               |
|----------|----------|---------------------------|
| $01      | $00      | Power off                 |
| $01      | $01      | Hard reboot               |
| $02      | $00      | Inject RESET              |
| $03      | $00      | Inject NMI                |
| $04      | $00..$FF | Power LED brightness      |
| $05      | $00..$FF | Activity LED brightness   |
| $07      | -        | Read from keyboard buffer |
| $18      | -        | Read ps2 status           |
| $19      | $00..$FF | Send ps2 command          |
| $21      | -        | Read from mouse buffer    |

#### Real-Time-Clock

The Commander X16 contains a battery-backed Microchip MCP7940N real-time-clock (RTC) chip as device $6F. It provide a real-time clock/calendar, two alarms and 64 bytes of RAM.

| Register | Description        |
|----------|--------------------|
| $00      | Clock seconds      |
| $01      | Clock minutes      |
| $02      | Clock hours        |
| $03      | Clock weekday      |
| $04      | Clock day          |
| $05      | Clock month        |
| $06      | Clock year         |
| $07      | Control            |
| $08      | Oscillator trim    |
| $09      | *reserved*         |
| $0A      | Alarm 0 seconds    |
| $0B      | Alarm 0 minutes    |
| $0C      | Alarm 0 hours      |
| $0D      | Alarm 0 weekday    |
| $0E      | Alarm 0 day        |
| $0F      | Alarm 0 month      |
| $10      | *reserved*         |
| $11      | Alarm 1 seconds    |
| $12      | Alarm 1 minutes    |
| $13      | Alarm 1 hours      |
| $14      | Alarm 1 weekday    |
| $15      | Alarm 1 day        |
| $16      | Alarm 1 month      |
| $17      | *reserved*         |
| $18      | Power-fail minutes |
| $19      | Power-fail hours   |
| $1A      | Power-fail day     |
| $1B      | Power-fail month   |
| $1C      | Power-up minutes   |
| $1D      | Power-up hours     |
| $1E      | Power-up day       |
| $1F      | Power-up month     |
| $20-$5F  | 64 Bytes SRAM      |

For more information, please refer to this device's datasheet.
