# Chapter 11: Working With CMDR-DOS
This manual describes Commodore DOS on FAT32, aka CMDR-DOS. 

## CMDR-DOS

Commander-16 duplicates and extends the programming interface used by Commodore's line of disk drives, including the 
famous (or infamous) VIC-1541. Unlike CBM-DOS, which uses a proprietary disk format, CMDR-DOS uses the industry-standard
FAT-32 format, which can handle partitions as small as 32MB or as large as 2TB on SDXC or SDHC memory cards.  

CMDR-DOS works in three modes: Binary Load/Save, Sequential file, and Command mode.

## Binary Load/Save

A Binary file can be read into the computer with the `LOAD` command. Binary files can be saved to storage with the 
`SAVE` command. 

This is a brief summary of the BASIC disk commands LOAD and SAVE. For full documentation, refer to Chapter 3: BASIC 
Programming.

### LOAD

`LOAD <filename> [,device][,secondary_address][,start_address]`

This reads a program file from disk. The first two bytes of the file are the memory location to which the file will be
loaded, with the low byte first. BASIC programs will start with $01 $08, which translates to $0801, the start of BASIC
memory. 
The device number should be 8 for reading from the SD card. 

secondary_address has multiple meanings: 

* 0 or not present: load the data to address $0801, regardless of the address header. 

* 1: load to the address specified 

* 2: load into VERA RAM bank 0 (at the 16-bit address in the file)

* 3: load into VERA RAM bank 1 (at the 16-bit address in the file)

* 17 or $11: load into VERA RAM bank 16 or $0F 

start_address is the location to read your data into. If you need to relocate your data to banked RAM, for example, you 
will want to set the address to $A000 or higher. 

Examples:

`LOAD "ROBOTS.PRG",8,1` loads the program "ROBOTS.PRG" into memory at the address encoded in the file. 

`LOAD "HELLO",8` loads a program to the start of BASIC at $0801.

`LOAD "*",8,1` loads the first program on the current directory. See the section below on wildcards for more 
information about using * and ? to access files of a certain type or with unprintable characters. 

`LOAD "DATA.BIN",8,1,$A000` loads a file into banked RAM, starting at $A000. Don't forget to set the bank first: bank 
0 is used by the operating system, so 

### SAVE 

`SAVE <filename>{,device}`

Save a file from the computer to the SD card. SAVE always reads from the beginning of BASIC memory at $0801, up to the
end of the BASIC program. 

One word of caution: CMDR-DOS will not let you overwrite a file by default. To overwrite a file, you need to prefix
the filename with @:, like this: 

`SAVE "@:DEMO.PRG"`

You may need to save arbitrary binary data from other locations. To do this, use the S command in the MONITOR (Chapter 
6: Machine Language Monitor). 

`S "filename",8,<start>,<end>`

Where <start> and <end> are a 16-bit hexadecimal address. 

### BLOAD, VLOAD

BLOAD loads a file *without an address header* to an arbitrary location in memory. U

## Sequential Files

Sequential files have two basic modes: read and write. The OPEN command opens a file for reading or writing. The
PRINT# command writes to a file, and the GET# and INPUT# commands read from the file. 

todo: examples

## Command Channel

The command channel allows you to send commands to the CMDR-DOS interface. You can open and write to the command channel
using the OPEN command, or you can use the DOS command to issue commands and read the status. While DOS can be used 
in immediate mode or in a program, only the combination of OPEN/INPUT# can read the command response back into a 
variable for later processing. 

In either case, the ST psuedo-variable will allow you to quickly check the status. A status of 64 is "okay", and any 
other value should be checked by reading the error channel (shown below.) 

To open the command channel, you can use the OPEN command with secondary address 15.

`10 OPEN 15,8,15`

If you want to issue a command immediately, add your command string at the end of the OPEN statement: 

`10 OPEN 15,8,15, "CD:/"

This example changes to the root directory of your SD card. 

Now you can check your status by reading ST: 

`20 IF ST=64 THEN PRINT "OK": GOTO 50`

To actually read the error channel and clear the error status, you need to read four values: 

`30 INPUT#15,A,B$,C,D`

A is the error number. B$ is the error message. C and D are unused in CBM-DOS, but will return the track and sector when
used with a Commodore disk drive. 

`40 PRINT A;B$;C;D`
`50 CLOSE 15`

So the entire program looks like: 

```BASIC
10 OPEN 15,8,15, "CD:/"
20 IF ST=64 THEN PRINT "OK": GOTO 50
30 INPUT#15,A,B$,C,D
40 PRINT A;B$;C;D
50 CLOSE 15
```

You can also use the DOS command to send a command to CMDR-DOS. Entering DOS by itself will print the drive's status on
the screen. Entering a command in quotes or a string variable will execute the command. We will talk more about the 
status variable and DOS status message in the next section. 

```
DOS
00, 0K, 00, 00
READY.
DOS "CD:/"
```

The special case of `DOS "$"` will print a directory listing.
`DOS "$"`

You can also read the name of the current directory with "$=C"
`DOS "$=C"`

## TODO

Integrate and deprecate:
https://github.com/X16Community/x16-rom/tree/master/dos#readme

Footnote
https://github.com/X16Community/x16-rom/tree/master/dos/fat32#readme

