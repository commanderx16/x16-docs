## Chapter 6: Machine Language Monitor

The built-in machine language monitor can be started with the `MON` BASIC command. It is based on the monitor of the Final Cartridge III and supports most of its features.

If you invoke the monitor by mistake, you can exit with by typing `X`, followed by the `RETURN` key.

Some features specific to this monitor are:
* The `I` command prints a PETSCII/ISO-encoded memory dump.
* The `EC` command prints a binary memory dump. This is also useful for character sets.
* Scrolling the screen with the cursor keys or F3/F5 will continue memory dumps and disassemblies, and even disassemble backwards.

The following commands are used to dump memory contents in various formats:

| Dump | Prefix  | description
|------|---------|---------------
| `M`  |  `:`    | 8 hex bytes
| `I`  |  `'`    | 32 PETSCII/ISO characters
| `EC` |  `[`    | 1 binary byte (character data)
| `ES` |  `]`    | 3 binary bytes (sprite data)
| `D`  |  `,`    | disassemble
| `R`  |  `;`    | registers

Except for `R`, these commands take a start address and an optional end address (inclusive). The dumps are prefixed with one of the "Prefix" characters in the table above, so they can be edited by navigating the cursor over a printed line, changing the data and pressing RETURN.

Note that editing a disassembled line (prefix `,`) only allows changing the 1-3 opcode bytes. To edit the assembly, change the prefix to `A` (see below).

These are the remaining commands:

| Command | Syntax                          | Description            |
|---------|---------------------------------|------------------------|
| `F`     | *start* *end* *byte*            | fill                   |
| `H`     | *start* *end* *byte* [*byte*...]| hunt                   |
| `C`     | *start* *end* *start*           | compare                |
| `T`     | *start* *end* *start*           | transfer               |
| `A`     | *address* *instruction*         | assemble               |
| `G`     | *address*                       | run code               |
| `$`     | *value*                         | convert hex to decimal |
| `#`     | *value*                         | convert decimal to hex |
| `X`     |                                 | exit monitor           |
| `O`     | *bank*                          | set bank               |
| `L`     | ["*filename*"[,*dev*[,*start*]]]| load file              |
| `S`     | "*filename*",*dev*,*start*,*end*| save file              |
| `@`     | *command*                       | send drive command     |

* All addresses have to be 4 digits.
* All bytes have to be 2 digits (including device numbers).
* The end address of `S` is exclusive.
* The bank argument for `O` is
        * `00`-`FF`: switch to main RAM, set RAM and ROM banks
        * `V0`-`V1`: switch to Video RAM, set bank
        * `I`: switch to the I2C address space
* `@` takes:
        * `8`, `9` to change the default drive (also for `L`)
        * `$` to display the disk directory
        * anything else as a disk command
