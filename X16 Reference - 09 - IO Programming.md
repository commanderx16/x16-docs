# Chapter 9: Commander X16 Programmer's Reference Guide

## I/O Programming

There are two 65C22 "Versatile Interface Adapter" (VIA) I/O controllers in the system, VIA#1 at address $9F60 and VIA#2 at address $9F70. The IRQ out lines of VIA#1 is connected to the CPU's NMI line, while the IRQ out line of VIA#2 is connected to the CPU's IRQ line.

The following tables describe the connections of the I/O pins:

**VIA#1**


|Pin  |Name      | Description                     |
|-----|----------|---------------------------------|
| PA0 | PS2KDAT  | PS/2 DATA keyboard              |
| PA1 | PS2KCLK  | PS/2 CLK  keyboard              |
| PA2 | NESLATCH | NES LATCH (for all controllers) |
| PA3 | NESCLK   | NES CLK   (for all controllers) |
| PA4 | NESDAT3  | NES DATA  (controller 3)        |
| PA5 | NESDAT2  | NES DATA  (controller 2)        |
| PA6 | NESDAT1  | NES DATA  (controller 1)        |
| PA7 | NESDAT0  | NES DATA  (controller 0)        |
| PB0 | PS2MDAT  | PS/2 DATA mouse                 |
| PB1 | PS2MCLK  | PS/2 CLK  mouse                 |
| PB2 | I2CDATA  | I2C DATA                        |
| PB3 | SERATNO  | Serial ATN  out                 |
| PB4 | SERCLKO  | Serial CLK  out                 |
| PB5 | SERDATAO | Serial DATA out                 |
| PB6 | SERCLKI  | Serial CLK  in                  |
| PB7 | SERDATAI | Serial DATA in                  |
| CB2 | I2CCLK   | I2C CLK                         |

The KERNAL uses VIA#1 Timer 1 for the 60 Hz timer interrupt and Timer 2 for timing of transmissions on the Serial Bus.

**VIA#2**

The second VIA is completely unused by the system. All its 16 GPIOs and 4 handshake I/Os can be freely used.

### Custom keyboard scan code handler

On receiving a keyboard scan code, the KERNAL jumps to the address stored in $032E-032F. This makes it possible to implement custom scan code handlers that extend or override the default behavior of the KERNAL.

Input set by the KERNAL: .X = PS/2 prefix, .A = PS/2 scan code, carry clear if key down and set if key up event.

Return from a custom handler with RTS. The KERNAL will continue handling the scan code according to the values of .X, .A and carry. To remove a keypress, return .A = 0.

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

    cmp #$11    ;Alt key scan code
    bne exit    

    lda #'a'
    jsr $ffd2

exit:
    plx		;Restore input
    pla
    plp
    rts		;Return control to Kernal
```

### I2C Bus

The Commander X16 contains an I2C bus, which is implemented through two pins of VIA#1. The system management controller (SMC) and the real-time clock (RTC) are connected through this bus. The KERNAL APIs `i2c_read_byte` and `i2c_write_byte` allow talking to these devices.

#### System Management Controller

The system management controller (SMC) controls the power and activity LEDs, and an be used to power down the system or inject RESET or NMI signals.

| Register | Value      | Description             |
|----------|------------|-------------------------|
| 0x01     | 0x00       | Power off               |
| 0x01     | 0x01       | Hard reboot             |
| 0x02     | 0x00       | Inject RESET            |
| 0x03     | 0x00       | Inject NMI              |
| 0x04     | 0x00..0xFF | Power LED brightness    |
| 0x05     | 0x00..0xFF | Activity LED brightness |

#### Real-Time-Clock

The Commander X16 contains a battery-backed Microchip MCP7940N real-time-clock (RTC) chip. It provide a real-time clock/calendar, two alarms and 64 bytes of RAM.

For more information, please refer to this device's datasheet.
