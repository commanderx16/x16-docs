## Chapter 6: Machine Language Monitor

The built-in machine language monitor can be started with the `MON` BASIC command. It is based on the monitor of the Final Cartridge III and supports all its features. See the [Final Cartridge III Manual](https://rr.pokefinder.org/rrwiki/images/7/70/Final_Cartridge_III_english_Manual.pdf) more more information.

If you invoke the monitor by mistake, you can exit with by typing `X`, followed by the `RETURN` key.

Some features specific to this monitor are:
* The `I` command prints a CBM-ASCII-encoded memory dump.
* The `EC` command prints a binary memory dump. This is also useful for character sets.
* Scrolling the screen with the cursors or F3/F5 will continue memory dumps and disassemblies, and even disassemble backwards.

The following additions have been made:

* The instruction set extensions of the 65C02 are supported.
* The `O` command takes an 8 bit hex value as an argument and sets it as the ROM and RAM bank for reading and writing memory contents. The following example disassembles the beginning of the CBDOS ROM on bank 5:

      O05
      DC000 C015

* The `OV` command takes a 4 bit hex value as an argument and sets it as the bank in the video address space for reading and writing memory contents. The following example shows the character ROM in the video controller's address space:

      OV1
      ECF000 F00F

*[TODO: Full documentation]*
